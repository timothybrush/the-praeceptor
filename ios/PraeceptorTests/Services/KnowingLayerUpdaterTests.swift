import XCTest
@testable import Praeceptor

@MainActor
final class KnowingLayerUpdaterTests: XCTestCase {
    var updater: KnowingLayerUpdater!
    var store: SessionStore!

    override func setUp() async throws {
        store = SessionStore()
        store.resetIntake()  // ensure no persisted knowing layer bleeds across tests
        updater = KnowingLayerUpdater(apiKey: "test-key", session: .mock())
    }

    override func tearDown() async throws {
        MockURLProtocol.requestHandler = nil
        store.resetIntake()  // clean up any layer saved during this test
    }

    // MARK: — Exchange guard

    func testUpdateSkipsWhenFewerThan3UserTurns() async throws {
        MockURLProtocol.requestHandler = { _ in
            XCTFail("Network call should not fire with < 3 user turns")
            return (.make(status: 200), Data())
        }

        let messages = [
            ChatMessage(role: .user,      content: "Hello",  timestamp: Date()),
            ChatMessage(role: .assistant, content: "Hi",     timestamp: Date()),
            ChatMessage(role: .user,      content: "Again",  timestamp: Date()),
            ChatMessage(role: .assistant, content: "Sure",   timestamp: Date()),
        ]
        await updater.update(session: messages, existing: nil, mentorName: "Test", store: store)
        XCTAssertNil(store.knowingLayer)
    }

    func testUpdateFiresWhenAtLeast3UserTurns() async throws {
        let knownLayer = TestFixtures.knownLayer()
        let layerData = try JSONEncoder().encode(knownLayer)
        let layerString = String(data: layerData, encoding: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            (.make(status: 200), TestFixtures.haikuSuccessResponse(layerString: layerString))
        }

        let messages = makeSession(userTurns: 3)
        await updater.update(session: messages, existing: nil, mentorName: "Test", store: store)
        XCTAssertNotNil(store.knowingLayer)
    }

    // MARK: — Model

    func testUpdateUsesHaikuModel() async throws {
        let knownLayer = TestFixtures.knownLayer()
        let layerData = try JSONEncoder().encode(knownLayer)
        let layerString = String(data: layerData, encoding: .utf8)!

        var capturedBody: [String: Any]?
        MockURLProtocol.requestHandler = { request in
            capturedBody = try? JSONSerialization.jsonObject(with: request.bodyData ?? Data()) as? [String: Any]
            return (.make(status: 200), TestFixtures.haikuSuccessResponse(layerString: layerString))
        }

        await updater.update(session: makeSession(userTurns: 3), existing: nil, mentorName: "Test", store: store)
        XCTAssertEqual(capturedBody?["model"] as? String, "claude-haiku-4-5-20251001")
    }

    // MARK: — JSON resilience

    func testUpdateSilentlyIgnoresMalformedJSONResponse() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(status: 200), TestFixtures.haikuSuccessResponse(layerString: "not valid json at all"))
        }

        await updater.update(session: makeSession(userTurns: 3), existing: nil, mentorName: "Test", store: store)
        XCTAssertNil(store.knowingLayer)
    }

    func testUpdateSilentlyIgnoresHttpError() async throws {
        MockURLProtocol.requestHandler = { _ in
            (.make(status: 500), Data())
        }

        await updater.update(session: makeSession(userTurns: 3), existing: nil, mentorName: "Test", store: store)
        XCTAssertNil(store.knowingLayer)
    }

    // MARK: — Helpers

    private func makeSession(userTurns: Int) -> [ChatMessage] {
        (0..<userTurns).flatMap { i in [
            ChatMessage(role: .user,      content: "message \(i)", timestamp: Date()),
            ChatMessage(role: .assistant, content: "reply \(i)",   timestamp: Date())
        ]}
    }
}
