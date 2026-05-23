import XCTest
import AVFoundation
@testable import Praeceptor

@MainActor
final class AudioPlayerTests: XCTestCase {

    func testPlayerCanBeInstantiated() {
        let player = AudioPlayer()
        XCTAssertNotNil(player)
    }

    func testStopIsNoOpWhenIdle() {
        let player = AudioPlayer()
        player.stop()
        XCTAssertFalse(player.isPlaying)
    }

    func testStopAfterStopDoesNotCrash() {
        let player = AudioPlayer()
        player.stop()
        player.stop()
    }

    func testPlayWithInvalidDataThrows() {
        let player = AudioPlayer()
        XCTAssertThrowsError(
            try player.play(data: Data(), onComplete: {})
        )
    }
}
