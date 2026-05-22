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
                liveActivity.endActivity()
                phase = .idle
            case .speaking:
                player.stop()
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

    func startRecording() {
        guard phase == .idle else { return }
        Task {
            let granted = await AVAudioApplication.requestRecordPermission()
            guard granted else {
                micDenied = true
                return
            }
            do {
                try recorder.start()
                phase = .recording
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
        guard let whisper = whisperService else {
            setError("Services not configured — check API keys in Settings.")
            return
        }

        phase = .transcribing
        liveActivity.updateActivity(phase: .transcribing)
        let transcript: String
        do {
            transcript = try await whisper.transcribe(audioURL: audioURL)
        } catch {
            setError(error.localizedDescription)
            return
        }

        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            phase = .idle
            return
        }

        await runFromText(transcript, sessionStore: sessionStore, knowingLayer: knowingLayer)
    }

    private func runFromText(
        _ text: String,
        sessionStore: SessionStore,
        knowingLayer: KnowingLayer?
    ) async {
        guard let claude = claudeService, let tts = ttsService else {
            setError("Services not configured — check API keys in Settings.")
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
        phase = .speaking
        liveActivity.updateActivity(phase: .speaking)
        do {
            let audioData = try await tts.synthesize(text: fullResponse, speed: TimeOfDay.current.ttsSpeed)
            try player.play(data: audioData) { [weak self] in
                Task { @MainActor in
                    self?.liveActivity.endActivity()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    self?.phase = .idle
                }
            }
        } catch {
            setError(error.localizedDescription)
        }
    }

    func stopPlayback() {
        player.stop()
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
