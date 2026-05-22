import XCTest
@testable import Praeceptor

final class ClaudeServiceTests: XCTestCase {
    var service: ClaudeService!

    override func setUp() async throws {
        service = ClaudeService(apiKey: "test-key", session: .mock())
    }

    override func tearDown() async throws {
        MockURLProtocol.requestHandler = nil
    }

    func testStreamYieldsTextChunks() async throws {
        MockURLProtocol.requestHandler = { _ in
            let sseData = TestFixtures.claudeSSEResponse(chunks: ["Hello", " world"])
            return (.make(status: 200), sseData)
        }

        var collected: [String] = []
        for try await chunk in service.stream(systemPrompt: "test", messages: []) {
            collected.append(chunk)
        }

        XCTAssertEqual(collected, ["Hello", " world"])
    }

    func testStreamProducesCorrectJoinedText() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(status: 200), TestFixtures.claudeSSEResponse(chunks: ["The ", "answer ", "is 42"]))
        }
        var result = ""
        for try await chunk in service.stream(systemPrompt: "test", messages: []) {
            result += chunk
        }
        XCTAssertEqual(result, "The answer is 42")
    }

    func testStreamThrows401WithReadableMessage() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(status: 401), Data())
        }
        do {
            for try await _ in service.stream(systemPrompt: "test", messages: []) {}
            XCTFail("Expected error")
        } catch let error as ClaudeService.ClaudeError {
            XCTAssertEqual(error.errorDescription, "Claude API key is invalid. Check Settings.")
        }
    }

    func testStreamThrows429WithReadableMessage() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(status: 429), Data())
        }
        do {
            for try await _ in service.stream(systemPrompt: "test", messages: []) {}
            XCTFail("Expected error")
        } catch let error as ClaudeService.ClaudeError {
            XCTAssertEqual(error.errorDescription, "Claude rate limit reached. Please wait a moment.")
        }
    }

    func testStreamHandlesPingEventsWithoutYielding() async throws {
        let sseWithPing = """
        data: {"type":"ping"}

        data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hi"}}

        data: {"type":"message_stop"}

        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in (.make(status: 200), sseWithPing) }

        var collected: [String] = []
        for try await chunk in service.stream(systemPrompt: "test", messages: []) {
            collected.append(chunk)
        }
        XCTAssertEqual(collected, ["Hi"])
    }

    func testStreamSendsCorrectHeaders() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (.make(status: 200), TestFixtures.claudeSSEResponse(chunks: []))
        }

        for try await _ in service.stream(systemPrompt: "test", messages: []) {}

        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "x-api-key"), "test-key")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "anthropic-version"), "2023-06-01")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testStreamSendsMax8000Tokens() async throws {
        var capturedBody: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            if let body = request.bodyData {
                capturedBody = try? JSONSerialization.jsonObject(with: body) as? [String: Any]
            }
            return (.make(status: 200), TestFixtures.claudeSSEResponse(chunks: []))
        }

        for try await _ in service.stream(systemPrompt: "test", messages: []) {}
        XCTAssertEqual(capturedBody?["max_tokens"] as? Int, 8000)
    }

    func testStreamSendsBetaHeader() async throws {
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (.make(status: 200), TestFixtures.claudeSSEResponse(chunks: []))
        }

        for try await _ in service.stream(systemPrompt: "test", messages: []) {}
        XCTAssertEqual(
            capturedRequest?.value(forHTTPHeaderField: "anthropic-beta"),
            "interleaved-thinking-2025-05-14"
        )
    }

    func testStreamSendsThinkingParam() async throws {
        var capturedBody: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            capturedBody = try? JSONSerialization.jsonObject(with: request.bodyData ?? Data()) as? [String: Any]
            return (.make(status: 200), TestFixtures.claudeSSEResponse(chunks: []))
        }

        for try await _ in service.stream(systemPrompt: "test", messages: []) {}
        let thinking = capturedBody?["thinking"] as? [String: Any]
        XCTAssertEqual(thinking?["type"] as? String, "enabled")
        XCTAssertEqual(thinking?["budget_tokens"] as? Int, 5000)
    }

    func testStreamSkipsThinkingDeltaEvents() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(status: 200), TestFixtures.claudeSSEResponseWithThinking(
                thinkingText: "Let me reason about this...",
                responseChunks: ["Answer"]
            ))
        }

        var collected: [String] = []
        for try await chunk in service.stream(systemPrompt: "test", messages: []) {
            collected.append(chunk)
        }
        // Thinking delta must not appear — only the text chunk
        XCTAssertEqual(collected, ["Answer"])
        XCTAssertFalse(collected.contains { $0.contains("reason") })
    }
}
