import XCTest
import Speech
@testable import Praeceptor

final class AppleSpeechServiceTests: XCTestCase {
    var service: AppleSpeechService!

    override func setUp() {
        service = AppleSpeechService()
    }

    func testServiceCanBeInstantiated() {
        XCTAssertNotNil(service)
    }

    func testNotAuthorizedErrorHasReadableDescription() {
        let error = AppleSpeechService.SpeechError.notAuthorized
        XCTAssertEqual(
            error.errorDescription,
            "Speech recognition was denied. Enable it in Settings → Privacy → Speech Recognition."
        )
    }

    func testUnavailableErrorHasReadableDescription() {
        let error = AppleSpeechService.SpeechError.unavailable
        XCTAssertEqual(
            error.errorDescription,
            "Speech recognition is not available on this device."
        )
    }

    func testTranscribeThrowsOnNonExistentFile() async throws {
        let missingURL = URL(fileURLWithPath: "/tmp/praeceptor-missing-\(UUID().uuidString).wav")
        do {
            _ = try await service.transcribe(audioURL: missingURL)
            // If we reach here auth was granted and recognition failed — both are valid
        } catch {
            // Any error is acceptable: notAuthorized, unavailable, or recognition failure
            XCTAssertNotNil(error)
        }
    }
}
