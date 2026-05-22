import SwiftUI

struct SettingsView: View {
    @ObservedObject var apiKeyManager: APIKeyManager
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss

    private var theme: TimeOfDayTheme { TimeOfDayTheme.current(TimeOfDay.current) }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        HStack(alignment: .center) {
                            Text("Settings")
                                .font(TimeOfDayTheme.displayItalic(34))
                                .foregroundColor(theme.text)
                                .kerning(-0.5)
                            Spacer()
                            if apiKeyManager.hasRequiredKeys {
                                Button("Done") { dismiss() }
                                    .font(TimeOfDayTheme.body(15))
                                    .foregroundColor(theme.accent)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 36)
                        .padding(.bottom, 36)

                        // Navigation group
                        VStack(spacing: 0) {
                            navRow(label: "API & AUTHORIZATION", detail: "Claude · OpenAI · ElevenLabs",
                                   destination: SettingsDestination.apiAuth)
                            rowDivider
                            navRow(label: "VOICE", detail: "Transcription · Output · Speed",
                                   destination: SettingsDestination.voice)
                            rowDivider
                            navRow(label: "REMINDERS", detail: "Morning · Midday · Evening",
                                   destination: SettingsDestination.notifications)
                            rowDivider
                            navRow(label: "MENTOR CONTEXT", detail: "Name · Knowledge · Intake",
                                   destination: SettingsDestination.mentorContext)
                            rowDivider
                            navRow(label: "DATA & PRIVACY", detail: "History · Context · Delete",
                                   destination: SettingsDestination.dataPrivacy)
                        }
                        .background(theme.raised)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(theme.line, lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: SettingsDestination.self) { dest in
                switch dest {
                case .apiAuth:       APIAuthView()
                case .voice:         VoiceSettingsView()
                case .notifications: NotificationsView()
                case .mentorContext: MentorContextView()
                case .dataPrivacy:   DataPrivacyView()
                }
            }
        }
    }

    // MARK: — Helpers

    private func navRow(label: String, detail: String, destination: SettingsDestination) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(label)
                        .font(TimeOfDayTheme.mono(9))
                        .foregroundColor(theme.accent)
                        .kerning(2.2)
                        .textCase(.uppercase)
                    Text(detail)
                        .font(TimeOfDayTheme.body(15))
                        .foregroundColor(theme.text)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.textTertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }

    private var rowDivider: some View {
        theme.line.frame(height: 1).padding(.horizontal, 20)
    }
}

enum SettingsDestination: Hashable {
    case apiAuth
    case voice
    case notifications
    case mentorContext
    case dataPrivacy
}
