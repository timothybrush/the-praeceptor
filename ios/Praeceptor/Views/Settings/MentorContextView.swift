import SwiftUI

struct MentorContextView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var apiKeyManager: APIKeyManager
    @Environment(\.dismiss) private var dismiss

    @AppStorage("mentor_name") private var mentorName: String = "The Praeceptor"
    @State private var showResetAlert = false
    @State private var showFullContext = false

    private var theme: TimeOfDayTheme { TimeOfDayTheme.current(TimeOfDay.current) }
    private var layer: KnowingLayer? { sessionStore.knowingLayer }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    backButton

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Mentor Context")
                            .font(TimeOfDayTheme.displayItalic(34))
                            .foregroundColor(theme.text)
                            .kerning(-0.5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 32)

                    nameSection
                    sectionDivider
                    if layer != nil {
                        sessionContextSection
                        sectionDivider
                    }
                    actionsSection
                }
                .padding(.bottom, 60)
            }
        }
        .navigationBarHidden(true)
        .alert("Reset & Retake Intake?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) {
                sessionStore.resetIntake()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears your KNOWING layer and session history. The Praeceptor will ask for context again.")
        }
        .sheet(isPresented: $showFullContext) {
            ProfileContextView()
                .environmentObject(sessionStore)
        }
    }

    // MARK: — Sections

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

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MENTOR NAME")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)

            TextField("The Praeceptor", text: $mentorName)
                .font(TimeOfDayTheme.body(15))
                .foregroundColor(theme.text)
                .tint(theme.accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(theme.raised)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )

            Text("Used in session headers, notifications, and greetings.")
                .font(TimeOfDayTheme.body(13))
                .foregroundColor(theme.textTertiary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    @ViewBuilder
    private var sessionContextSection: some View {
        if let layer {
            VStack(alignment: .leading, spacing: 12) {
                Text("SESSION CONTEXT")
                    .font(TimeOfDayTheme.mono(10))
                    .foregroundColor(theme.accent)
                    .kerning(2.4)
                    .textCase(.uppercase)

                VStack(spacing: 0) {
                    contextRow(label: "Name", value: layer.person.name)
                    theme.line.frame(height: 1)
                    contextRow(label: "Mission", value: layer.person.primaryMission)
                    theme.line.frame(height: 1)
                    contextRow(label: "Active project", value: layer.currentState.activeProject.isEmpty ? layer.currentState.whatTheyAreDoing : layer.currentState.activeProject)
                }
                .background(theme.raised)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )

                Button {
                    showFullContext = true
                } label: {
                    HStack {
                        Text("View Full Context")
                            .font(TimeOfDayTheme.body(15))
                            .foregroundColor(theme.text)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
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
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INTAKE")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)

            Button {
                showResetAlert = true
            } label: {
                HStack {
                    Text("Reset & Retake Intake")
                        .font(TimeOfDayTheme.body(15))
                        .foregroundColor(theme.bad)
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13))
                        .foregroundColor(theme.bad)
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

            Text("Clears your context and starts intake over.")
                .font(TimeOfDayTheme.body(13))
                .foregroundColor(theme.textTertiary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    // MARK: — Helpers

    private func contextRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.textTertiary)
                .kerning(1.6)
                .textCase(.uppercase)
                .frame(width: 90, alignment: .leading)
            Text(value.isEmpty ? "—" : value)
                .font(TimeOfDayTheme.body(14))
                .foregroundColor(value.isEmpty ? theme.textGhost : theme.text)
                .lineSpacing(2)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var sectionDivider: some View {
        theme.line.frame(height: 1).padding(.horizontal, 24)
    }
}
