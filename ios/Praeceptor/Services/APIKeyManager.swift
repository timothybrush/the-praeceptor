import Foundation
import Security

@MainActor
final class APIKeyManager: ObservableObject {
    private let keychainService = "com.praeceptor.app"

    @Published var hasRequiredKeys: Bool = false

    var transcriptionProvider: TranscriptionProvider {
        get {
            TranscriptionProvider(rawValue: UserDefaults.standard.string(forKey: "transcriptionProvider") ?? "") ?? .apple
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "transcriptionProvider")
            objectWillChange.send()
        }
    }

    var ttsProvider: TTSProvider {
        get {
            TTSProvider(rawValue: UserDefaults.standard.string(forKey: "ttsProvider") ?? "") ?? .apple
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "ttsProvider")
            objectWillChange.send()
        }
    }

    var voiceResponsesEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "voiceResponsesEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "voiceResponsesEnabled"); objectWillChange.send() }
    }

    var speakingSpeed: Double {
        get {
            let v = UserDefaults.standard.double(forKey: "speakingSpeed")
            return v == 0.0 ? 0.92 : v
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "speakingSpeed")
            objectWillChange.send()
        }
    }

    init() {
        hasRequiredKeys = claudeKey != nil
    }

    var claudeKey: String? {
        get { load(key: "claude_api_key") }
        set {
            if let value = newValue { save(key: "claude_api_key", value: value) }
            else { delete(key: "claude_api_key") }
            hasRequiredKeys = claudeKey != nil
        }
    }

    var openAIKey: String? {
        get { load(key: "openai_api_key") }
        set {
            if let value = newValue { save(key: "openai_api_key", value: value) }
            else { delete(key: "openai_api_key") }
        }
    }

    var elevenLabsKey: String? {
        get { load(key: "elevenlabs_api_key") }
        set {
            if let value = newValue { save(key: "elevenlabs_api_key", value: value) }
            else { delete(key: "elevenlabs_api_key") }
        }
    }

    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else { return nil }
        return string.isEmpty ? nil : string
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
