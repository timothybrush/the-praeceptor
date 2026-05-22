import XCTest
@testable import Praeceptor

@MainActor
final class APIKeyManagerTests: XCTestCase {
    var manager: APIKeyManager!

    override func setUp() async throws {
        manager = APIKeyManager()
        // Clean slate before each test
        manager.claudeKey = nil
        manager.openAIKey = nil
        manager.elevenLabsKey = nil
    }

    override func tearDown() async throws {
        manager.claudeKey = nil
        manager.openAIKey = nil
        manager.elevenLabsKey = nil
    }

    func testHasRequiredKeysIsFalseWithNoKeys() {
        XCTAssertFalse(manager.hasRequiredKeys)
    }

    func testHasRequiredKeysIsFalseWithOnlyClaudeKey() {
        manager.claudeKey = "sk-claude"
        XCTAssertFalse(manager.hasRequiredKeys)
    }

    func testHasRequiredKeysIsFalseWithOnlyOpenAIKey() {
        manager.openAIKey = "sk-openai"
        XCTAssertFalse(manager.hasRequiredKeys)
    }

    func testHasRequiredKeysIsTrueWithBothRequiredKeys() {
        manager.claudeKey = "sk-claude"
        manager.openAIKey = "sk-openai"
        XCTAssertTrue(manager.hasRequiredKeys)
    }

    func testElevenLabsKeyIsOptional() {
        manager.claudeKey = "sk-claude"
        manager.openAIKey = "sk-openai"
        XCTAssertTrue(manager.hasRequiredKeys)
        XCTAssertNil(manager.elevenLabsKey)
    }

    func testSaveAndLoadClaudeKey() {
        manager.claudeKey = "sk-ant-test-key"
        XCTAssertEqual(manager.claudeKey, "sk-ant-test-key")
    }

    func testSaveAndLoadOpenAIKey() {
        manager.openAIKey = "sk-openai-test-key"
        XCTAssertEqual(manager.openAIKey, "sk-openai-test-key")
    }

    func testSaveAndLoadElevenLabsKey() {
        manager.elevenLabsKey = "eleven-test-key"
        XCTAssertEqual(manager.elevenLabsKey, "eleven-test-key")
    }

    func testDeleteClaudeKey() {
        manager.claudeKey = "sk-ant-test"
        manager.claudeKey = nil
        XCTAssertNil(manager.claudeKey)
    }

    func testDeleteUpdatesHasRequiredKeys() {
        manager.claudeKey = "sk-claude"
        manager.openAIKey = "sk-openai"
        XCTAssertTrue(manager.hasRequiredKeys)
        manager.claudeKey = nil
        XCTAssertFalse(manager.hasRequiredKeys)
    }

    func testKeyPersistsAcrossNewManagerInstance() {
        manager.claudeKey = "sk-persist-test"
        let newManager = APIKeyManager()
        XCTAssertEqual(newManager.claudeKey, "sk-persist-test")
        newManager.claudeKey = nil
    }
}
