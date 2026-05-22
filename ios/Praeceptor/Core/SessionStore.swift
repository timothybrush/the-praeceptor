import Foundation
import SwiftUI

@MainActor
final class SessionStore: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var phase: SessionPhase = .idle
    @Published var streamingText: String = ""

    @AppStorage("intake_completed") var hasIntakeCompleted: Bool = false

    let bridge = KnowingLayerBridge()

    var knowingLayer: KnowingLayer? { bridge.knowingLayer }

    func appendMessage(_ message: ChatMessage) {
        messages.append(message)
    }

    func clearSession() {
        messages = []
        streamingText = ""
        phase = .idle
    }

    func completeIntake(layer: KnowingLayer) {
        bridge.save(layer)
        hasIntakeCompleted = true
    }

    func resetIntake() {
        bridge.reset()
        hasIntakeCompleted = false
        clearSession()
    }

    var conversationHistory: [[String: String]] {
        messages.map { ["role": $0.role.rawValue, "content": $0.content] }
    }
}
