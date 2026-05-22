import SwiftUI

struct DataPrivacyView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var apiKeyManager: APIKeyManager
    @Environment(\.dismiss) private var dismiss

    @State private var showClearHistoryAlert = false
    @State private var showResetKnowingAlert = false
    @State private var showDeleteAllAlert = false

    private var theme: TimeOfDayTheme { TimeOfDayTheme.current(TimeOfDay.current) }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    backButton

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Data & Privacy")
                            .font(TimeOfDayTheme.displayItalic(34))
                            .foregroundColor(theme.text)
                            .kerning(-0.5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 32)

                    dataSection
                    sectionDivider
                    deleteSection
                }
                .padding(.bottom, 60)
            }
        }
        .navigationBarHidden(true)
        .alert("Clear Conversation History?", isPresented: $showClearHistoryAlert) {
            Button("Clear", role: .destructive) { sessionStore.clearSession() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Removes all messages from this session. The Praeceptor's context and your intake answers are preserved.")
        }
        .alert("Reset KNOWING Layer?", isPresented: $showResetKnowingAlert) {
            Button("Reset", role: .destructive) {
                sessionStore.resetIntake()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Clears all context, session history, and your intake answers. The Praeceptor will ask again from the beginning.")
        }
        .alert("Delete All Data?", isPresented: $showDeleteAllAlert) {
            Button("Delete Everything", role: .destructive) { deleteAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Removes all API keys, session history, context, and preferences. The app returns to first launch. This cannot be undone.")
        }
    }

    // MARK: — Sections

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SESSION DATA")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)

            VStack(spacing: 0) {
                destructiveRow(
                    title: "Clear Conversation History",
                    subtitle: "Removes messages only. Context preserved.",
                    icon: "bubble.left.and.bubble.right"
                ) { showClearHistoryAlert = true }

                theme.line.frame(height: 1)

                destructiveRow(
                    title: "Reset KNOWING Layer",
                    subtitle: "Clears context and intake. Starts over.",
                    icon: "brain"
                ) { showResetKnowingAlert = true }
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

    private var deleteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NUCLEAR")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.bad)
                .kerning(2.4)
                .textCase(.uppercase)

            Button {
                showDeleteAllAlert = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 15))
                        .foregroundColor(theme.bad)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Delete All Data")
                            .font(TimeOfDayTheme.body(15))
                            .foregroundColor(theme.bad)
                        Text("Keys · History · Context · Preferences")
                            .font(TimeOfDayTheme.body(13))
                            .foregroundColor(theme.bad.opacity(0.7))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(theme.raised)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(theme.bad.opacity(0.3), lineWidth: 1)
                )
            }

            Text("Removes everything stored on this device. You will need to re-enter your API key.")
                .font(TimeOfDayTheme.body(13))
                .foregroundColor(theme.textTertiary)
                .lineSpacing(3)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    // MARK: — Helpers

    private func destructiveRow(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(theme.bad)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(TimeOfDayTheme.body(15))
                        .foregroundColor(theme.text)
                    Text(subtitle)
                        .font(TimeOfDayTheme.body(13))
                        .foregroundColor(theme.textTertiary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
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
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    private var sectionDivider: some View {
        theme.line.frame(height: 1).padding(.horizontal, 24)
    }

    private func deleteAll() {
        apiKeyManager.claudeKey     = nil
        apiKeyManager.openAIKey     = nil
        apiKeyManager.elevenLabsKey = nil
        sessionStore.resetIntake()
        UserDefaults.standard.removeObject(forKey: "speakingSpeed")
        UserDefaults.standard.removeObject(forKey: "transcriptionProvider")
        UserDefaults.standard.removeObject(forKey: "ttsProvider")
        UserDefaults.standard.removeObject(forKey: "mentor_name")
        UserDefaults.standard.removeObject(forKey: "editorial_seen")
        dismiss()
    }
}
