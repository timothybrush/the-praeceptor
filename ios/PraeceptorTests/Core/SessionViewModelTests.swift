import XCTest
import AVFoundation
@testable import Praeceptor

@MainActor
final class SessionViewModelTests: XCTestCase {
    var viewModel: SessionViewModel!

    override func setUp() async throws {
        viewModel = SessionViewModel()
    }

    // MARK: — Initial State

    func testInitialPhaseIsIdle() {
        XCTAssertEqual(viewModel.phase, .idle)
    }

    func testInitialStreamingTextIsEmpty() {
        XCTAssertEqual(viewModel.streamingText, "")
    }

    func testInitialAudioLevelIsZero() {
        XCTAssertEqual(viewModel.audioLevel, 0)
    }

    // MARK: — configure()

    func testConfigureWithMissingKeysLeavesPhaseIdle() {
        let manager = APIKeyManager()
        manager.claudeKey = nil
        manager.openAIKey = nil
        viewModel.configure(apiKeyManager: manager)
        XCTAssertEqual(viewModel.phase, .idle)
    }

    func testConfigureWithBothKeysLeavesPhaseIdle() {
        let manager = APIKeyManager()
        manager.claudeKey = "sk-test-claude"
        manager.openAIKey = "sk-test-openai"
        viewModel.configure(apiKeyManager: manager)
        XCTAssertEqual(viewModel.phase, .idle)
        manager.claudeKey = nil
        manager.openAIKey = nil
    }

    func testConfigureWithOnlyClaudeKeyLeavesPhaseIdle() {
        let manager = APIKeyManager()
        manager.claudeKey = "sk-test-claude"
        manager.openAIKey = nil
        viewModel.configure(apiKeyManager: manager)
        XCTAssertEqual(viewModel.phase, .idle)
        manager.claudeKey = nil
    }

    // MARK: — dismissError()

    func testDismissErrorFromIdleSetsIdle() {
        viewModel.dismissError()
        XCTAssertEqual(viewModel.phase, .idle)
    }

    // MARK: — stopPlayback()

    func testStopPlaybackSetsIdle() {
        viewModel.stopPlayback()
        XCTAssertEqual(viewModel.phase, .idle)
    }

    func testStopPlaybackClearsStreamingText() {
        viewModel.stopPlayback()
        XCTAssertEqual(viewModel.streamingText, "")
    }

    // MARK: — startRecording() guard

    func testStartRecordingFromIdleInitiatesAsyncPermissionRequest() async throws {
        // In test environment mic permission is denied — verify the call does not crash
        // and that phase either stays .idle or transitions (both are valid outcomes)
        viewModel.startRecording()
        // Allow one run loop pass for the async permission task to begin
        try await Task.sleep(for: .milliseconds(50))
        // Phase will be either .idle (denied) or .recording (granted in simulator)
        let isExpected: Bool
        switch viewModel.phase {
        case .idle, .recording, .error: isExpected = true
        default: isExpected = false
        }
        XCTAssertTrue(isExpected)
    }

    // MARK: — Interruption (configure required for observer)

    func testInterruptionWhileIdleDoesNotChangePhase() async throws {
        let manager = APIKeyManager()
        manager.claudeKey = "sk-test"
        manager.openAIKey = "sk-test"
        viewModel.configure(apiKeyManager: manager)
        manager.claudeKey = nil
        manager.openAIKey = nil

        postInterruption(type: .began)
        try await Task.sleep(for: .milliseconds(50))

        XCTAssertEqual(viewModel.phase, .idle)
    }

    func testSecondConfigureReplacesInterruptionObserver() {
        let manager = APIKeyManager()
        manager.claudeKey = "sk-a"
        manager.openAIKey = "sk-b"
        viewModel.configure(apiKeyManager: manager)
        viewModel.configure(apiKeyManager: manager) // second call should not crash
        XCTAssertEqual(viewModel.phase, .idle)
        manager.claudeKey = nil
        manager.openAIKey = nil
    }

    // MARK: — micDenied

    func testClearMicDeniedSetsFalse() {
        viewModel.clearMicDenied()
        XCTAssertFalse(viewModel.micDenied)
    }

    // MARK: — Apple-only configure

    func testConfigureWithClaudeKeyOnlyLeavesPhaseIdle() {
        let manager = APIKeyManager()
        manager.claudeKey = "sk-test-claude"
        manager.openAIKey = nil
        viewModel.configure(apiKeyManager: manager)
        XCTAssertEqual(viewModel.phase, .idle)
        manager.claudeKey = nil
    }

    // MARK: — Helpers

    private func postInterruption(type: AVAudioSession.InterruptionType) {
        NotificationCenter.default.post(
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            userInfo: [AVAudioSessionInterruptionTypeKey: type.rawValue]
        )
    }
}
