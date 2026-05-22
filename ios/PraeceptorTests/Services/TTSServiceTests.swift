import XCTest
@testable import Praeceptor

final class TTSServiceTests: XCTestCase {
    var service: TTSService!

    override func setUp() async throws {
        service = TTSService(apiKey: "test-key", session: .mock())
    }

    override func tearDown() async throws {
        MockURLProtocol.requestHandler = nil
    }

    func testSynthesizeReturnsDataOnSuccess() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(status: 200), TestFixtures.mp3Data)
        }
        let data = try await service.synthesize(text: "Hello")
        XCTAssertEqual(data, TestFixtures.mp3Data)
    }

    func testSynthesizeTruncatesTextAt4096Chars() async throws {
        var capturedBody: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            capturedBody = try? JSONSerialization.jsonObject(with: request.bodyData ?? Data()) as? [String: Any]
            return (.make(status: 200), TestFixtures.mp3Data)
        }

        let longText = String(repeating: "a", count: 5000)
        _ = try await service.synthesize(text: longText)

        let sentInput = capturedBody?["input"] as? String ?? ""
        XCTAssertEqual(sentInput.count, 4096)
    }

    func testSynthesizePassesShortTextUnchanged() async throws {
        var capturedBody: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            capturedBody = try? JSONSerialization.jsonObject(with: request.bodyData ?? Data()) as? [String: Any]
            return (.make(status: 200), TestFixtures.mp3Data)
        }

        _ = try await service.synthesize(text: "Short text")
        XCTAssertEqual(capturedBody?["input"] as? String, "Short text")
    }

    func testSynthesizeUsesOnyxVoice() async throws {
        var capturedBody: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            capturedBody = try? JSONSerialization.jsonObject(with: request.bodyData ?? Data()) as? [String: Any]
            return (.make(status: 200), TestFixtures.mp3Data)
        }

        _ = try await service.synthesize(text: "Test")
        XCTAssertEqual(capturedBody?["voice"] as? String, "onyx")
    }

    func testSynthesizePassesCustomSpeed() async throws {
        var capturedBody: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            capturedBody = try? JSONSerialization.jsonObject(with: request.bodyData ?? Data()) as? [String: Any]
            return (.make(status: 200), TestFixtures.mp3Data)
        }

        _ = try await service.synthesize(text: "Test", speed: 0.88)
        XCTAssertEqual(capturedBody?["speed"] as? Double, 0.88)
    }

    func testSynthesizeThrows401WithReadableMessage() async throws {
        MockURLProtocol.requestHandler = { _ in (.make(status: 401), Data()) }
        do {
            _ = try await service.synthesize(text: "Test")
            XCTFail("Expected error")
        } catch let error as TTSService.TTSError {
            XCTAssertEqual(error.errorDescription, "OpenAI API key is invalid. Check Settings.")
        }
    }

    func testSynthesizeThrows429WithReadableMessage() async throws {
        MockURLProtocol.requestHandler = { _ in (.make(status: 429), Data()) }
        do {
            _ = try await service.synthesize(text: "Test")
            XCTFail("Expected error")
        } catch let error as TTSService.TTSError {
            XCTAssertEqual(error.errorDescription, "Voice synthesis rate limit reached. Please wait a moment.")
        }
    }
}
