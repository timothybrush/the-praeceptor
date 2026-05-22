import SwiftUI
import AVFoundation

@main
struct PraeceptorApp: App {
    @StateObject private var sessionStore = SessionStore()

    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionStore)
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetooth]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[Audio] Session configuration failed: \(error)")
        }
    }
}
