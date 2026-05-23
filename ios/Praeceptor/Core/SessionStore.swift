import Foundation
import SwiftUI

@MainActor
final class SessionStore: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @AppStorage("intake_completed") var hasIntakeCompleted: Bool = false

    let bridge = KnowingLayerBridge()

    var knowingLayer: KnowingLayer? { bridge.knowingLayer }

    private let messagesFileName = "praeceptor-session.json"

    private var messagesURL: URL? {
        (FileManager.default
            .url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)?
            .appendingPathComponent(messagesFileName)
    }

    init() {
        loadMessages()
    }

    private func loadMessages() {
        guard let url = messagesURL,
              let data = try? Data(contentsOf: url),
              let saved = try? JSONDecoder().decode([ChatMessage].self, from: data) else { return }
        messages = saved
    }

    private func saveMessages() {
        guard let url = messagesURL,
              let data = try? JSONEncoder().encode(messages) else { return }
        try? data.write(to: url, options: [.atomic, .completeFileProtection])
    }

    func appendMessage(_ message: ChatMessage) {
        messages.append(message)
        saveMessages()
    }

    func clearSession() {
        messages = []
        saveMessages()
    }

    func completeIntake(layer: KnowingLayer) {
        bridge.save(layer)
        hasIntakeCompleted = true
    }

    func updateProfile(_ layer: KnowingLayer) {
        bridge.save(layer)
    }

    func resetIntake() {
        bridge.reset()
        hasIntakeCompleted = false
        clearSession()
    }

    #if DEBUG
    func skipIntake() {
        hasIntakeCompleted = true
    }
    #endif

    private let contextPruningLimit = 40

    var conversationHistory: [[String: String]] {
        let source = messages.count > contextPruningLimit
            ? Array(messages.suffix(contextPruningLimit))
            : messages
        return source.map { ["role": $0.role.rawValue, "content": $0.content] }
    }
}
