import SwiftUI
import AVFoundation

@main
struct PraeceptorApp: App {
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var launchState = LaunchState()
    @StateObject private var notificationManager = NotificationManager()

    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionStore)
                .environmentObject(launchState)
                .environmentObject(notificationManager)
                .onOpenURL { url in
                    if url.scheme == "praeceptor" && url.host == "session" {
                        launchState.startRecording = true
                    }
                }
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetoothHFP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[Audio] Session configuration failed: \(error)")
        }
    }
}
