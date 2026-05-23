import Foundation
import SwiftUI
import AVFoundation
import UIKit

@MainActor
final class SessionViewModel: ObservableObject {
    @Published private(set) var phase: SessionPhase = .idle
    @Published private(set) var streamingText: String = ""
    @Published private(set) var audioLevel: Float = 0
    @Published private(set) var micDenied: Bool = false

    private let recorder = AudioRecorder()
    private let player = AudioPlayer()
    private let liveActivity = LiveActivityManager()
    private let networkMonitor = NetworkMonitor()

    private var claudeService: ClaudeService?
    private var whisperService: WhisperService?
    private var ttsService: TTSService?
    private var appleSpeechService: AppleSpeechService?
    private var appleTTSService: AppleTTSService?
    private var knowingLayerUpdater: KnowingLayerUpdater?
    private var apiKeyManager: APIKeyManager?

    private var interruptionObserver: Task<Void, Never>?

    func configure(apiKeyManager: APIKeyManager) {
        self.apiKeyManager = apiKeyManager
        guard let claudeKey = apiKeyManager.claudeKey else { return }
        claudeService = ClaudeService(apiKey: claudeKey)
        knowingLayerUpdater = KnowingLayerUpdater(apiKey: claudeKey)
        if appleSpeechService == nil { appleSpeechService = AppleSpeechService() }
        if appleTTSService == nil { appleTTSService = AppleTTSService() }
        if let openAIKey = apiKeyManager.openAIKey {
            whisperService = WhisperService(apiKey: openAIKey)
            ttsService = TTSService(apiKey: openAIKey)
        }
        startInterruptionObserver()
    }

    // MARK: — Audio Session Interruptions

    private func startInterruptionObserver() {
        interruptionObserver?.cancel()
        interruptionObserver = Task { @MainActor [weak self] in
            let notifications = NotificationCenter.default.notifications(
                named: AVAudioSession.interruptionNotification
            )
            for await notification in notifications {
                self?.handleInterruption(notification)
            }
        }
    }

    private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            switch phase {
            case .recording:
                _ = recorder.stop()
                liveActivity.endActivity()
                phase = .idle
            case .speaking:
                player.stop()
                appleTTSService?.stop()
                liveActivity.endActivity()
                phase = .idle
            default:
                break
            }
        case .ended:
            try? AVAudioSession.sharedInstance().setActive(true)
        @unknown default:
            break
        }
    }

    // MARK: — Voice Pipeline

    private var requiresNetwork: Bool {
        let transcription = apiKeyManager?.transcriptionProvider ?? .apple
        let tts = apiKeyManager?.ttsProvider ?? .apple
        return transcription == .openAI || tts == .openAI || tts == .elevenLabs
    }

    func startRecording() {
        guard phase == .idle else { return }
        if requiresNetwork && !networkMonitor.isConnected {
            setError("No internet connection. Switch to Apple voice in Settings → Voice.")
            return
        }
        Task {
            let granted = await AVAudioApplication.requestRecordPermission()
            guard granted else {
                micDenied = true
                return
            }
            do {
                try recorder.start()
                phase = .recording
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                liveActivity.startActivity(sessionLabel: TimeOfDay.current.label)
                // Mirror audio level from recorder into viewModel
                Task { @MainActor [weak self] in
                    while self?.phase == .recording {
                        self?.audioLevel = self?.recorder.audioLevel ?? 0
                        try? await Task.sleep(for: .milliseconds(50))
                    }
                    self?.audioLevel = 0
                }
            } catch {
                setError(error.localizedDescription)
            }
        }
    }

    func stopRecording(sessionStore: SessionStore, knowingLayer: KnowingLayer?) {
        guard phase == .recording else { return }
        guard let audioURL = recorder.stop() else { phase = .idle; return }
        Task {
            await runPipeline(audioURL: audioURL, sessionStore: sessionStore, knowingLayer: knowingLayer)
        }
    }

    func sendText(_ text: String, sessionStore: SessionStore, knowingLayer: KnowingLayer?) {
        guard phase == .idle else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if requiresNetwork && !networkMonitor.isConnected {
            setError("No internet connection. Switch to Apple voice in Settings → Voice.")
            return
        }
        liveActivity.startActivity(sessionLabel: TimeOfDay.current.label)
        Task {
            await runFromText(trimmed, sessionStore: sessionStore, knowingLayer: knowingLayer)
        }
    }

    func clearMicDenied() {
        micDenied = false
    }

    private func runPipeline(
        audioURL: URL,
        sessionStore: SessionStore,
        knowingLayer: KnowingLayer?
    ) async {
        phase = .transcribing
        liveActivity.updateActivity(phase: .transcribing)

        let transcript: String
        do {
            switch apiKeyManager?.transcriptionProvider ?? .apple {
            case .apple:
                guard let svc = appleSpeechService else {
                    setError("Speech service not initialized.")
                    return
                }
                transcript = try await svc.transcribe(audioURL: audioURL)
            case .openAI:
                guard let svc = whisperService else {
                    setError("OpenAI key required for Whisper. Add it in Settings → API & Authorization.")
                    return
                }
                transcript = try await svc.transcribe(audioURL: audioURL)
            }
        } catch {
            setError(error.localizedDescription)
            return
        }

        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            phase = .idle
            return
        }

        // Transcription complete: soft double-tap — something was understood
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        try? await Task.sleep(for: .milliseconds(80))
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        await runFromText(transcript, sessionStore: sessionStore, knowingLayer: knowingLayer)
    }

    private func runFromText(
        _ text: String,
        sessionStore: SessionStore,
        knowingLayer: KnowingLayer?
    ) async {
        guard let claude = claudeService else {
            setError("Claude API key required. Add it in Settings → API & Authorization.")
            return
        }

        sessionStore.appendMessage(ChatMessage(role: .user, content: text, timestamp: Date()))

        // 1. Stream Claude response
        phase = .thinking
        liveActivity.updateActivity(phase: .thinking)
        streamingText = ""

        let systemPrompt = SystemPromptBuilder.build(
            knowingLayer: knowingLayer,
            sessionHistory: sessionStore.conversationHistory,
            timeOfDay: TimeOfDay.current
        )

        var fullResponse = ""
        do {
            for try await chunk in claude.stream(
                systemPrompt: systemPrompt,
                messages: sessionStore.conversationHistory
            ) {
                fullResponse += chunk
                streamingText = fullResponse
            }
        } catch {
            setError(error.localizedDescription)
            return
        }

        guard !fullResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            setError("No response received. Please try again.")
            return
        }

        sessionStore.appendMessage(ChatMessage(role: .assistant, content: fullResponse, timestamp: Date()))
        streamingText = ""

        // 2. TTS + Playback
        guard apiKeyManager?.voiceResponsesEnabled ?? true else {
            liveActivity.endActivity()
            phase = .idle
            fireKnowingUpdate(sessionStore: sessionStore)
            return
        }

        phase = .speaking
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        liveActivity.updateActivity(phase: .speaking)

        switch apiKeyManager?.ttsProvider ?? .apple {
        case .apple, .elevenLabs:
            // elevenLabs falls through to Apple TTS until service is implemented
            guard let svc = appleTTSService else {
                setError("Voice service not initialized.")
                return
            }
            await svc.speak(text: fullResponse, speed: apiKeyManager?.speakingSpeed ?? TimeOfDay.current.ttsSpeed)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            try? await Task.sleep(for: .milliseconds(120))
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            try? await Task.sleep(for: .milliseconds(180))
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            try? await Task.sleep(for: .milliseconds(400))
            liveActivity.endActivity()
            phase = .idle
            fireKnowingUpdate(sessionStore: sessionStore)

        case .openAI:
            guard let svc = ttsService else {
                setError("OpenAI key required for this voice. Add it in Settings → API & Authorization.")
                return
            }
            do {
                let audioData = try await svc.synthesize(text: fullResponse, speed: apiKeyManager?.speakingSpeed ?? TimeOfDay.current.ttsSpeed)
                try player.play(data: audioData) { [weak self] in
                    Task { @MainActor in
                        // Session close ritual: sustained rumble → fade
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        try? await Task.sleep(for: .milliseconds(120))
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        try? await Task.sleep(for: .milliseconds(180))
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        try? await Task.sleep(for: .milliseconds(400))
                        self?.liveActivity.endActivity()
                        self?.phase = .idle
                        self?.fireKnowingUpdate(sessionStore: sessionStore)
                    }
                }
            } catch {
                setError(error.localizedDescription)
            }
        }
    }

    private func fireKnowingUpdate(sessionStore: SessionStore) {
        guard let updater = knowingLayerUpdater else { return }
        let messages = sessionStore.messages
        let existing = sessionStore.knowingLayer
        let mentorName = UserDefaults.standard.string(forKey: "mentor_name") ?? "The Praeceptor"
        Task {
            await updater.update(session: messages, existing: existing, mentorName: mentorName, store: sessionStore)
        }
    }

    func stopPlayback() {
        player.stop()
        appleTTSService?.stop()
        liveActivity.endActivity()
        phase = .idle
    }

    func dismissError() {
        phase = .idle
    }

    private func setError(_ message: String) {
        liveActivity.endActivity()
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        phase = .error(message)
    }
}
