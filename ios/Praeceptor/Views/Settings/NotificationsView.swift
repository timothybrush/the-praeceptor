import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss

    private var theme: TimeOfDayTheme { TimeOfDayTheme.current(TimeOfDay.current) }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reminders")
                            .font(TimeOfDayTheme.displayItalic(34))
                            .foregroundColor(theme.text)
                            .kerning(-0.5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 32)

                    notificationSection
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
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
        .padding(.vertical, 8)
    }
}
