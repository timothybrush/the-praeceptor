import SwiftUI

struct SettingsView: View {
    @ObservedObject var apiKeyManager: APIKeyManager
    @Environment(\.dismiss) private var dismiss

    @State private var claudeKey: String = ""
    @State private var openAIKey: String = ""
    @State private var elevenLabsKey: String = ""

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
    }

    private func saveKeys() {
        apiKeyManager.claudeKey = claudeKey.isEmpty ? nil : claudeKey
        apiKeyManager.openAIKey = openAIKey.isEmpty ? nil : openAIKey
        apiKeyManager.elevenLabsKey = elevenLabsKey.isEmpty ? nil : elevenLabsKey
    }
}
