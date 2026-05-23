import XCTest
import Security
@testable import Praeceptor

/// One-shot test: inject real API keys into simulator keychain so the app routes past settings.
/// Run this test ONCE before screenshot capture. Never commit with real keys.
final class KeychainInjectorTests: XCTestCase {

    private let service = "com.praeceptor.app"

    func testInjectKeys() throws {
        // Read from /tmp plist — never stored in project files or committed
        let url = URL(fileURLWithPath: "/tmp/praeceptor_keys.plist")
        guard let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String]
        else {
            XCTFail("Run: write keys plist to /tmp/praeceptor_keys.plist first")
            return
        }
        let claudeKey  = dict["claude"]     ?? ""
        let openAIKey  = dict["openai"]     ?? ""
        let elevenKey  = dict["elevenlabs"] ?? ""

        guard !claudeKey.isEmpty else {
            XCTFail("claude key missing from plist")
            return
        }

        writeKey("claude_api_key",    value: claudeKey)
        writeKey("openai_api_key",    value: openAIKey)
        writeKey("elevenlabs_api_key", value: elevenKey)

        // Verify Claude key persists (the required one)
        let loaded = readKey("claude_api_key")
        XCTAssertEqual(loaded, claudeKey)
        print("[KeychainInjector] ✅ Claude key injected")
        print("[KeychainInjector] OpenAI: \(openAIKey.isEmpty ? "skipped" : "injected")")
        print("[KeychainInjector] ElevenLabs: \(elevenKey.isEmpty ? "skipped" : "injected")")
    }

    private func writeKey(_ account: String, value: String) {
        guard !value.isEmpty, let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        var add = query
        add[kSecValueData as String] = data
        add[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        SecItemAdd(add as CFDictionary, nil)
    }

    private func readKey(_ account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
