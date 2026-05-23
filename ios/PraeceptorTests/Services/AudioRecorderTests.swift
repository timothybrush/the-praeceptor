import XCTest
import AVFoundation
@testable import Praeceptor

@MainActor
final class AudioRecorderTests: XCTestCase {

    func testRecorderCanBeInstantiated() {
        let recorder = AudioRecorder()
        XCTAssertNotNil(recorder)
    }

    func testInitialStateIsNotRecording() {
        let recorder = AudioRecorder()
        XCTAssertFalse(recorder.isRecording)
        XCTAssertEqual(recorder.audioLevel, 0.0)
    }

    func testStopWhenNotRecordingReturnsURL() {
        let recorder = AudioRecorder()
        // stop() returns the output URL even if not actively recording
        let url = recorder.stop()
        XCTAssertNotNil(url)
    }

    func testAudioLevelIsNormalizedBetweenZeroAndOne() {
        let recorder = AudioRecorder()
        XCTAssertGreaterThanOrEqual(recorder.audioLevel, 0.0)
        XCTAssertLessThanOrEqual(recorder.audioLevel, 1.0)
    }
}
