import SwiftUI

struct EditorialView: View {
    let onContinue: () -> Void

    private var theme: TimeOfDayTheme {
        TimeOfDayTheme.current(TimeOfDay.current)
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    Text("I · Arrival")
                        .font(TimeOfDayTheme.mono(10.5))
                        .foregroundColor(theme.textTertiary)
                        .kerning(2)
                        .textCase(.uppercase)
                        .padding(.bottom, 20)

                    Group {
                        Text("The\n")
                            .font(TimeOfDayTheme.display(64))
                            .foregroundColor(theme.text)
                        + Text("Praeceptor")
                            .font(TimeOfDayTheme.displayItalic(64))
                            .foregroundColor(theme.accent)
                        + Text(".")
                            .font(TimeOfDayTheme.display(64))
                            .foregroundColor(theme.text)
                    }
                    .kerning(-2.2)
                    .padding(.bottom, 34)

                    Text("He arrived with a point of view\nbefore you said a word.")
                        .font(TimeOfDayTheme.displayItalic(22))
                        .foregroundColor(theme.text)
                        .lineSpacing(6)
                        .kerning(-0.2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)

                Spacer()

                Button(action: onContinue) {
                    HStack(spacing: 10) {
                        Text("Begin")
                            .font(TimeOfDayTheme.body(15))
                            .fontWeight(.medium)
                            .kerning(2)
                            .textCase(.uppercase)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(theme.accentInk)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: theme.accentGlow, radius: 16, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
    }
}
