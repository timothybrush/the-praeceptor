import SwiftUI

struct VoiceSettingsView: View {
    @EnvironmentObject var apiKeyManager: APIKeyManager
    @Environment(\.dismiss) private var dismiss

    private var theme: TimeOfDayTheme { TimeOfDayTheme.current(TimeOfDay.current) }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    backButton

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Voice")
                            .font(TimeOfDayTheme.displayItalic(34))
                            .foregroundColor(theme.text)
                            .kerning(-0.5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 32)

                    transcriptionSection
                    sectionDivider
                    ttsSection
                    sectionDivider
                    speedSection
                }
                .padding(.bottom, 60)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: — Transcription

    private var transcriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TRANSCRIPTION")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)

            VStack(spacing: 0) {
                providerRow(
                    title: "Apple (on-device)",
                    subtitle: "Free · Works offline",
                    isSelected: apiKeyManager.transcriptionProvider == .apple,
                    isAvailable: true,
                    unavailableNote: nil
                ) { apiKeyManager.transcriptionProvider = .apple }

                theme.line.frame(height: 1)

                providerRow(
                    title: "OpenAI Whisper",
                    subtitle: apiKeyManager.openAIKey != nil
                        ? "Using your OpenAI key"
                        : "Add key in API & Authorization →",
                    isSelected: apiKeyManager.transcriptionProvider == .openAI,
                    isAvailable: apiKeyManager.openAIKey != nil,
                    unavailableNote: apiKeyManager.openAIKey == nil ? "Requires OpenAI key" : nil
                ) {
                    guard apiKeyManager.openAIKey != nil else { return }
                    apiKeyManager.transcriptionProvider = .openAI
                }
            }
            .background(theme.raised)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    // MARK: — TTS

    private var ttsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("VOICE OUTPUT")
                    .font(TimeOfDayTheme.mono(10))
                    .foregroundColor(theme.accent)
                    .kerning(2.4)
                    .textCase(.uppercase)
                Spacer()
                Toggle("Voice responses enabled", isOn: Binding(
                    get: { apiKeyManager.voiceResponsesEnabled },
                    set: { apiKeyManager.voiceResponsesEnabled = $0 }
                ))
                .tint(theme.accent)
                .labelsHidden()
                .accessibilityLabel("Voice responses enabled")
            }

            VStack(spacing: 0) {
                providerRow(
                    title: "Apple",
                    subtitle: "Free · On-device synthesis",
                    isSelected: apiKeyManager.ttsProvider == .apple,
                    isAvailable: apiKeyManager.voiceResponsesEnabled,
                    unavailableNote: nil
                ) { apiKeyManager.ttsProvider = .apple }

                theme.line.frame(height: 1)

                providerRow(
                    title: "OpenAI (onyx)",
                    subtitle: apiKeyManager.openAIKey != nil
                        ? "Using your OpenAI key"
                        : "Add key in API & Authorization →",
                    isSelected: apiKeyManager.ttsProvider == .openAI,
                    isAvailable: apiKeyManager.voiceResponsesEnabled && apiKeyManager.openAIKey != nil,
                    unavailableNote: apiKeyManager.openAIKey == nil ? "Requires OpenAI key" : nil
                ) {
                    guard apiKeyManager.openAIKey != nil else { return }
                    apiKeyManager.ttsProvider = .openAI
                }

                theme.line.frame(height: 1)

                providerRow(
                    title: "ElevenLabs",
                    subtitle: apiKeyManager.elevenLabsKey != nil
                        ? "Using your ElevenLabs key"
                        : "Add key in API & Authorization →",
                    isSelected: apiKeyManager.ttsProvider == .elevenLabs,
                    isAvailable: apiKeyManager.voiceResponsesEnabled && apiKeyManager.elevenLabsKey != nil,
                    unavailableNote: apiKeyManager.elevenLabsKey == nil ? "Requires ElevenLabs key" : nil
                ) {
                    guard apiKeyManager.elevenLabsKey != nil else { return }
                    apiKeyManager.ttsProvider = .elevenLabs
                }
            }
            .background(theme.raised)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )

            if apiKeyManager.elevenLabsKey != nil {
                voiceIDField
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private var voiceIDField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("VOICE ID")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)

            TextField("Voice ID", text: Binding(
                get: { apiKeyManager.elevenLabsVoiceID },
                set: { apiKeyManager.elevenLabsVoiceID = $0 }
            ))
            .font(TimeOfDayTheme.mono(13))
            .foregroundColor(theme.text)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(theme.raised)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(theme.line, lineWidth: 1)
            )

            Text("Find your voice ID in the ElevenLabs dashboard under Voices.")
                .font(TimeOfDayTheme.body(13))
                .foregroundColor(theme.textTertiary)
                .lineSpacing(3)
        }
        .padding(.top, 16)
    }

    // MARK: — Speed

    @ViewBuilder
    private var speedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("SPEAKING SPEED")
                    .opacity(apiKeyManager.voiceResponsesEnabled ? 1 : 0.4)
                    .font(TimeOfDayTheme.mono(10))
                    .foregroundColor(theme.accent)
                    .kerning(2.4)
                    .textCase(.uppercase)
                Spacer()
                Text(String(format: "%.2f×", apiKeyManager.speakingSpeed))
                    .font(TimeOfDayTheme.mono(11))
                    .foregroundColor(theme.textSecondary)
            }

            Slider(
                value: Binding(
                    get: { apiKeyManager.speakingSpeed },
                    set: { apiKeyManager.speakingSpeed = $0 }
                ),
                in: 0.8...1.1,
                step: 0.01
            )
            .tint(theme.accent)
            .disabled(!apiKeyManager.voiceResponsesEnabled)
            .opacity(apiKeyManager.voiceResponsesEnabled ? 1 : 0.4)

            HStack {
                Text("Slower")
                    .font(TimeOfDayTheme.mono(9))
                    .foregroundColor(theme.textGhost)
                    .kerning(1.6)
                    .textCase(.uppercase)
                Spacer()
                Text("Faster")
                    .font(TimeOfDayTheme.mono(9))
                    .foregroundColor(theme.textGhost)
                    .kerning(1.6)
                    .textCase(.uppercase)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    // MARK: — Helpers

    private func providerRow(
        title: String,
        subtitle: String,
        isSelected: Bool,
        isAvailable: Bool,
        unavailableNote: String?,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? theme.accent : (isAvailable ? theme.textSecondary : theme.textGhost))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(TimeOfDayTheme.body(15))
                        .foregroundColor(isAvailable ? theme.text : theme.textTertiary)
                    Text(subtitle)
                        .font(TimeOfDayTheme.body(13))
                        .foregroundColor(isAvailable ? theme.textSecondary : theme.textGhost)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .opacity(isAvailable ? 1.0 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }

    private var backButton: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.text)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Back")
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    private var sectionDivider: some View {
        theme.line.frame(height: 1).padding(.horizontal, 24)
    }
}
