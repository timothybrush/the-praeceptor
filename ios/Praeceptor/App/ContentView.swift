import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var launchState: LaunchState
    @StateObject private var apiKeyManager = APIKeyManager()
    @AppStorage("editorial_seen") private var editorialSeen: Bool = false
    @State private var splashDone: Bool = false

    var body: some View {
        Group {
            if !splashDone {
                SplashView(onComplete: { splashDone = true })
            } else if !apiKeyManager.hasRequiredKeys {
                SettingsView(apiKeyManager: apiKeyManager)
            } else if !editorialSeen {
                PreceptorIntroView(onContinue: { editorialSeen = true })
            } else if !sessionStore.hasIntakeCompleted {
                IntakeView()
                    .environmentObject(sessionStore)
            } else {
                SessionView()
                    .environmentObject(sessionStore)
                    .environmentObject(launchState)
            }
        }
        .environmentObject(apiKeyManager)
    }
}
