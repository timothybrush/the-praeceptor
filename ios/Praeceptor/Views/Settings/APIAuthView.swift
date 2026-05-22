import SwiftUI

struct APIAuthView: View {
    @EnvironmentObject var apiKeyManager: APIKeyManager
    @Environment(\.dismiss) private var dismiss

    @State private var claudeKey = ""
    @State private var openAIKey = ""
    @State private var elevenLabsKey = ""

    private var theme: TimeOfDayTheme { TimeOfDayTheme.current(TimeOfDay.current) }
    private var canSave: Bool { !claudeKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    keySection(
                        label: "CLAUDE API",
                        note: "Required. Powers responses. Pro/Max subscribers have SDK credits (~$20–$200/mo) — get your key at console.anthropic.com.",
                        field: $claudeKey,
                        placeholder: "sk-ant-…"
                    )
                    sectionDivider
                    keySection(
                        label: "OPENAI (OPTIONAL)",
                        note: "Enables Whisper transcription and OpenAI voice (onyx). Set in Voice settings after adding.",
                        field: $openAIKey,
                        placeholder: "sk-…"
                    )
                    sectionDivider
                    keySection(
                        label: "ELEVENLABS (OPTIONAL)",
                        note: "Enables premium voice output. Set in Voice settings after adding.",
                        field: $elevenLabsKey,
                        placeholder: "Leave blank for default voice"
                    )

                    saveButton
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            claudeKey     = apiKeyManager.claudeKey     ?? ""
            openAIKey     = apiKeyManager.openAIKey     ?? ""
            elevenLabsKey = apiKeyManager.elevenLabsKey ?? ""
        }
    }

    // MARK: — Subviews

    private var header: some View {
        HStack(alignment: .center) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.text)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

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

    private var sectionDivider: some View {
        theme.line.frame(height: 1).padding(.horizontal, 24)
    }

    private var saveButton: some View {
        Button(action: { saveKeys(); dismiss() }) {
            HStack(spacing: 10) {
                Text("Save")
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

    private func saveKeys() {
        let c = claudeKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let o = openAIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let e = elevenLabsKey.trimmingCharacters(in: .whitespacesAndNewlines)
        apiKeyManager.claudeKey     = c.isEmpty ? nil : c
        apiKeyManager.openAIKey     = o.isEmpty ? nil : o
        apiKeyManager.elevenLabsKey = e.isEmpty ? nil : e
    }
}
