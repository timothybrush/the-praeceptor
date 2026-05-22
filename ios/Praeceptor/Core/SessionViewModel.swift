import Foundation
import SwiftUI
import AVFoundation

@MainActor
final class SessionViewModel: ObservableObject {
    @Published private(set) var phase: SessionPhase = .idle
    @Published private(set) var streamingText: String = ""
    @Published private(set) var audioLevel: Float = 0

    private let recorder = AudioRecorder()
    private let player = AudioPlayer()

    private var claudeService: ClaudeService?
    private var whisperService: WhisperService?
    private var ttsService: TTSService?

    private var interruptionObserver: Task<Void, Never>?

    func configure(apiKeyManager: APIKeyManager) {
        guard let claudeKey = apiKeyManager.claudeKey,
              let openAIKey = apiKeyManager.openAIKey else { return }
        claudeService = ClaudeService(apiKey: claudeKey)
        whisperService = WhisperService(apiKey: openAIKey)
        ttsService = TTSService(apiKey: openAIKey)
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
                phase = .idle
            case .speaking:
                player.stop()
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

    func startRecording() {
        guard phase == .idle else { return }
        Task {
            let granted = await AVAudioApplication.requestRecordPermission()
            guard granted else {
                phase = .error("Microphone access required. Enable it in Settings → Privacy → Microphone.")
                return
            }
            do {
                try recorder.start()
                phase = .recording
                // Mirror audio level from recorder into viewModel
                Task { @MainActor [weak self] in
                    while self?.phase == .recording {
                        self?.audioLevel = self?.recorder.audioLevel ?? 0
                        try? await Task.sleep(for: .milliseconds(50))
                    }
                    self?.audioLevel = 0
                }
            } catch {
                phase = .error(error.localizedDescription)
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

    private func runPipeline(
        audioURL: URL,
        sessionStore: SessionStore,
        knowingLayer: KnowingLayer?
    ) async {
        guard let whisper = whisperService,
              let claude = claudeService,
              let tts = ttsService else {
            phase = .error("Services not configured — check API keys in Settings.")
            return
        }

        // 1. Transcribe
        phase = .transcribing
        let transcript: String
        do {
            transcript = try await whisper.transcribe(audioURL: audioURL)
        } catch {
            phase = .error(error.localizedDescription)
            return
        }

        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            phase = .idle
            return
        }

        sessionStore.appendMessage(ChatMessage(role: .user, content: transcript, timestamp: Date()))

        // 2. Stream Claude response
        phase = .thinking
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
            phase = .error(error.localizedDescription)
            return
        }

        guard !fullResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            phase = .error("No response received. Please try again.")
            return
        }

        sessionStore.appendMessage(ChatMessage(role: .assistant, content: fullResponse, timestamp: Date()))
        streamingText = ""

        // 3. TTS + Playback
        phase = .speaking
        do {
            let audioData = try await tts.synthesize(text: fullResponse, speed: TimeOfDay.current.ttsSpeed)
            try player.play(data: audioData) { [weak self] in
                Task { @MainActor in self?.phase = .idle }
            }
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    func stopPlayback() {
        player.stop()
        phase = .idle
    }

    func dismissError() {
        phase = .idle
    }
}
