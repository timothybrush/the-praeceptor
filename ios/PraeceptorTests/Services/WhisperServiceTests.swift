import XCTest
@testable import Praeceptor

final class WhisperServiceTests: XCTestCase {
    var service: WhisperService!
    var tempAudioURL: URL!

    override func setUp() async throws {
        service = WhisperService(apiKey: "test-key", session: .mock())
        tempAudioURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_audio_\(UUID().uuidString).wav")
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempAudioURL)
        MockURLProtocol.requestHandler = nil
    }

    func testTranscribeReturnsTextOnSuccess() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(url: "https://api.openai.com", status: 200), TestFixtures.whisperSuccessResponse())
        }
        try TestFixtures.wavData().write(to: tempAudioURL)
        let result = try await service.transcribe(audioURL: tempAudioURL)
        XCTAssertEqual(result, "Hello from Whisper")
    }

    func testTranscribeTrimsWhitespace() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(status: 200), TestFixtures.whisperSuccessResponse(text: "  hello  "))
        }
        try TestFixtures.wavData().write(to: tempAudioURL)
        let result = try await service.transcribe(audioURL: tempAudioURL)
        XCTAssertEqual(result, "hello")
    }

    func testTranscribeThrowsEmptyAudioOnMissingFile() async throws {
        do {
            _ = try await service.transcribe(audioURL: tempAudioURL)
            XCTFail("Expected emptyAudio error")
        } catch WhisperService.TranscriptionError.emptyAudio {
            // expected
        }
    }

    func testTranscribeThrowsEmptyAudioOnZeroByteFile() async throws {
        try Data().write(to: tempAudioURL)
        do {
            _ = try await service.transcribe(audioURL: tempAudioURL)
            XCTFail("Expected emptyAudio error")
        } catch WhisperService.TranscriptionError.emptyAudio {
            // expected
        }
    }

    func testTranscribeThrows401WithReadableMessage() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(status: 401), Data())
        }
        try TestFixtures.wavData().write(to: tempAudioURL)
        do {
            _ = try await service.transcribe(audioURL: tempAudioURL)
            XCTFail("Expected httpError")
        } catch let error as WhisperService.TranscriptionError {
            XCTAssertEqual(error.errorDescription, "OpenAI API key is invalid. Check Settings.")
        }
    }

    func testTranscribeThrows429WithReadableMessage() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(status: 429), Data())
        }
        try TestFixtures.wavData().write(to: tempAudioURL)
        do {
            _ = try await service.transcribe(audioURL: tempAudioURL)
            XCTFail("Expected httpError")
        } catch let error as WhisperService.TranscriptionError {
            XCTAssertEqual(error.errorDescription, "Transcription rate limit reached. Please wait a moment.")
        }
    }

    func testTempFileDeletedAfterSuccessfulTranscription() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(url: "https://api.openai.com", status: 200), TestFixtures.whisperSuccessResponse())
        }
        try TestFixtures.wavData().write(to: tempAudioURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempAudioURL.path))
        _ = try await service.transcribe(audioURL: tempAudioURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempAudioURL.path), "Temp audio file should be deleted after transcription")
    }

    func testTranscribeSendsMultipartFormData() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (.make(status: 200), TestFixtures.whisperSuccessResponse())
        }
        try TestFixtures.wavData().write(to: tempAudioURL)
        _ = try await service.transcribe(audioURL: tempAudioURL)

        XCTAssertNotNil(capturedRequest)
        let contentType = capturedRequest?.value(forHTTPHeaderField: "Content-Type") ?? ""
        XCTAssertTrue(contentType.hasPrefix("multipart/form-data; boundary="))
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer test-key")
    }
}
