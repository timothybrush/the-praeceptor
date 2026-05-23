import XCTest
@testable import Praeceptor

@MainActor
final class SessionStoreTests: XCTestCase {

    func testPruningLimitIsFortyMessages() {
        let store = SessionStore()
        store.messages = (0..<50).map { i in
            ChatMessage(role: i % 2 == 0 ? .user : .assistant, content: "msg \(i)", timestamp: Date())
        }
        let history = store.conversationHistory
        XCTAssertEqual(history.count, 40)
    }

    func testConversationHistoryReturnsAllMessagesWhenBelowLimit() {
        let store = SessionStore()
        store.messages = (0..<20).map { i in
            ChatMessage(role: .user, content: "msg \(i)", timestamp: Date())
        }
        XCTAssertEqual(store.conversationHistory.count, 20)
    }

    func testPruningKeepsNewestMessages() {
        let store = SessionStore()
        store.messages = (0..<50).map { i in
            ChatMessage(role: .user, content: "msg \(i)", timestamp: Date())
        }
        let history = store.conversationHistory
        XCTAssertEqual(history.first?["content"], "msg 10")
        XCTAssertEqual(history.last?["content"], "msg 49")
    }

    func testConversationHistoryFormatsRoleAndContent() {
        let store = SessionStore()
        store.messages = [
            ChatMessage(role: .user, content: "Hello", timestamp: Date()),
            ChatMessage(role: .assistant, content: "World", timestamp: Date())
        ]
        let history = store.conversationHistory
        XCTAssertEqual(history[0]["role"], "user")
        XCTAssertEqual(history[0]["content"], "Hello")
        XCTAssertEqual(history[1]["role"], "assistant")
        XCTAssertEqual(history[1]["content"], "World")
    }

    func testClearSessionRemovesAllMessages() {
        let store = SessionStore()
        store.messages = [ChatMessage(role: .user, content: "test", timestamp: Date())]
        store.clearSession()
        XCTAssertTrue(store.messages.isEmpty)
        XCTAssertTrue(store.conversationHistory.isEmpty)
    }

    func testAppendMessageIncreasesCount() {
        let store = SessionStore()
        store.messages = []
        let msg = ChatMessage(role: .user, content: "hi", timestamp: Date())
        store.appendMessage(msg)
        XCTAssertEqual(store.messages.count, 1)
    }
}
