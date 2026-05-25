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
        guard let url = messagesURL else { return }
        do {
            let data = try Data(contentsOf: url)
            messages = try JSONDecoder().decode([ChatMessage].self, from: data)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            // Normal first launch
        } catch {
            print("[SessionStore] load failed: \(error)")
        }
    }

    private func saveMessages() {
        guard let url = messagesURL else {
            print("[SessionStore] save skipped — no storage URL")
            return
        }
        do {
            let data = try JSONEncoder().encode(messages)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("[SessionStore] save failed: \(error)")
        }
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
