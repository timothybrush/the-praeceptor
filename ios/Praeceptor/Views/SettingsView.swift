import SwiftUI

struct SettingsView: View {
    @ObservedObject var apiKeyManager: APIKeyManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var sessionStore: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var claudeKey: String = ""
    @State private var openAIKey: String = ""
    @State private var elevenLabsKey: String = ""
    @State private var showProfileContext = false

    private var theme: TimeOfDayTheme {
        TimeOfDayTheme.current(TimeOfDay.current)
    }

    private var canSave: Bool { !claudeKey.isEmpty && !openAIKey.isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // Title block
                        VStack(alignment: .leading, spacing: 6) {
                            Text("API Keys")
                                .font(TimeOfDayTheme.displayItalic(34))
                                .foregroundColor(theme.text)
                                .kerning(-0.5)
                            Text("Required to proceed.")
                                .font(TimeOfDayTheme.mono(11))
                                .foregroundColor(theme.textTertiary)
                                .kerning(1.8)
                                .textCase(.uppercase)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 36)
                        .padding(.bottom, 36)

                        // Claude
                        keySection(
                            label: "CLAUDE API",
                            note: "Required. Powers The Praeceptor's responses.",
                            field: $claudeKey,
                            placeholder: "sk-ant-…"
                        )

                        divider

                        // OpenAI
                        keySection(
                            label: "OPENAI API",
                            note: "Required. Powers voice transcription (Whisper) and speech output (TTS).",
                            field: $openAIKey,
                            placeholder: "sk-…"
                        )

                        divider

                        // ElevenLabs
                        keySection(
                            label: "ELEVENLABS (OPTIONAL)",
                            note: "Optional. Enables premium voice output. Leave blank to use OpenAI TTS.",
                            field: $elevenLabsKey,
                            placeholder: "Leave blank for default voice"
                        )

                        divider

                        // Notifications
                        notificationSection

                        // Profile context (post-intake)
                        if sessionStore.knowingLayer != nil {
                            divider
                            profileSection
                        }

                        // Save button
                        Button(action: { saveKeys(); dismiss() }) {
                            HStack(spacing: 10) {
                                Text("Save & Continue")
                                    .font(TimeOfDayTheme.body(15))
                                    .fontWeight(.medium)
                                    .kerning(2)
                                    .textCase(.uppercase)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(canSave ? theme.accentInk : theme.textTertiary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(canSave ? theme.accent : theme.raised)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: canSave ? theme.accentGlow : .clear, radius: 16, x: 0, y: 6)
                        }
                        .disabled(!canSave)
                        .padding(.horizontal, 24)
                        .padding(.top, 36)
                        .padding(.bottom, 60)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            claudeKey    = apiKeyManager.claudeKey    ?? ""
            openAIKey    = apiKeyManager.openAIKey    ?? ""
            elevenLabsKey = apiKeyManager.elevenLabsKey ?? ""
        }
        .sheet(isPresented: $showProfileContext) {
            ProfileContextView()
                .environmentObject(sessionStore)
        }
    }

    // MARK: — Subviews

    private func keySection(
        label: String,
        note: String,
        field: Binding<String>,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)

            SecureField(placeholder, text: field)
                .font(TimeOfDayTheme.body(15))
                .foregroundColor(theme.text)
                .textContentType(.password)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(theme.raised)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )

            Text(note)
                .font(TimeOfDayTheme.body(13))
                .foregroundColor(theme.textTertiary)
                .lineSpacing(3)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private var divider: some View {
        theme.line
            .frame(height: 1)
            .padding(.horizontal, 24)
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SESSION REMINDERS")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)

            VStack(spacing: 0) {
                ForEach(Array(SessionReminder.allCases.enumerated()), id: \.element.rawValue) { index, reminder in
                    if index > 0 {
                        theme.line.frame(height: 1)
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(reminder.label)
                                .font(TimeOfDayTheme.body(15))
                                .foregroundColor(theme.text)
                            Text(reminder.subtitle)
                                .font(TimeOfDayTheme.body(13))
                                .foregroundColor(theme.textTertiary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { notificationManager.isEnabled(reminder) },
                            set: { _ in Task { await notificationManager.toggle(reminder) } }
                        ))
                        .tint(theme.accent)
                        .labelsHidden()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .background(theme.raised)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )

            Text("He doesn't chase.")
                .font(TimeOfDayTheme.body(13))
                .foregroundColor(theme.textTertiary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THE PRAECEPTOR KNOWS")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)

            Button {
                showProfileContext = true
            } label: {
                HStack {
                    Text("Profile & Context")
                        .font(TimeOfDayTheme.body(15))
                        .foregroundColor(theme.text)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13))
                        .foregroundColor(theme.textTertiary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(theme.raised)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
            }

            Text("Edit your answers from intake. Add context files to deepen his understanding.")
                .font(TimeOfDayTheme.body(13))
                .foregroundColor(theme.textTertiary)
                .lineSpacing(3)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private func saveKeys() {
        apiKeyManager.claudeKey    = claudeKey.isEmpty    ? nil : claudeKey
        apiKeyManager.openAIKey    = openAIKey.isEmpty    ? nil : openAIKey
        apiKeyManager.elevenLabsKey = elevenLabsKey.isEmpty ? nil : elevenLabsKey
    }
}
