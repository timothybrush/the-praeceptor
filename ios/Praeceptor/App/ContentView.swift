import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var launchState: LaunchState
    @StateObject private var apiKeyManager = APIKeyManager()

    var body: some View {
        Group {
            if !apiKeyManager.hasRequiredKeys {
                SettingsView(apiKeyManager: apiKeyManager)
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
