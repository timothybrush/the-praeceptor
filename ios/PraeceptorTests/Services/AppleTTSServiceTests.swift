import XCTest
import AVFoundation
@testable import Praeceptor

@MainActor
final class AppleTTSServiceTests: XCTestCase {
    var service: AppleTTSService!

    override func setUp() async throws {
        service = AppleTTSService()
    }

    func testServiceCanBeInstantiated() {
        XCTAssertNotNil(service)
    }

    func testStopDoesNotCrashWhenIdle() {
        // stop() with no active utterance must be a no-op
        service.stop()
    }

    func testStopAfterStopDoesNotCrash() {
        service.stop()
        service.stop()
    }
}
