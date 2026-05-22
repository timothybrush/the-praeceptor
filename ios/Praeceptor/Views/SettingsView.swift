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

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Anthropic API Key", text: $claudeKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                } header: {
                    Text("Claude API")
                } footer: {
                    Text("Required. Powers The Praeceptor's responses.")
                }

                Section {
                    SecureField("OpenAI API Key", text: $openAIKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                } header: {
                    Text("OpenAI API")
                } footer: {
                    Text("Required. Powers voice transcription (Whisper) and speech output (TTS).")
                }

                Section {
                    SecureField("ElevenLabs API Key (optional)", text: $elevenLabsKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                } header: {
                    Text("ElevenLabs (Premium Voice)")
                } footer: {
                    Text("Optional. Enables premium voice output. Leave blank to use OpenAI TTS.")
                }

                Section {
                    ForEach(SessionReminder.allCases, id: \.rawValue) { reminder in
                        Toggle(isOn: Binding(
                            get: { notificationManager.isEnabled(reminder) },
                            set: { _ in Task { await notificationManager.toggle(reminder) } }
                        )) {
                            HStack {
                                Text(reminder.label)
                                Spacer()
                                Text(reminder.subtitle)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Session Reminders")
                } footer: {
                    Text("Opt in to any. He doesn't chase.")
                }

                if sessionStore.knowingLayer != nil {
                    Section {
                        Button {
                            showProfileContext = true
                        } label: {
                            HStack {
                                Text("Profile & Context")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.primary)
                    } header: {
                        Text("The Praeceptor Knows")
                    } footer: {
                        Text("Edit your answers from intake. Add context files to deepen his understanding.")
                    }
                }

                Section {
                    Button("Save Keys") {
                        saveKeys()
                        dismiss()
                    }
                    .disabled(claudeKey.isEmpty || openAIKey.isEmpty)
                }
            }
            .navigationTitle("API Keys")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            claudeKey = apiKeyManager.claudeKey ?? ""
            openAIKey = apiKeyManager.openAIKey ?? ""
            elevenLabsKey = apiKeyManager.elevenLabsKey ?? ""
        }
        .sheet(isPresented: $showProfileContext) {
            ProfileContextView()
                .environmentObject(sessionStore)
        }
    }

    private func saveKeys() {
        apiKeyManager.claudeKey = claudeKey.isEmpty ? nil : claudeKey
        apiKeyManager.openAIKey = openAIKey.isEmpty ? nil : openAIKey
        apiKeyManager.elevenLabsKey = elevenLabsKey.isEmpty ? nil : elevenLabsKey
    }
}
