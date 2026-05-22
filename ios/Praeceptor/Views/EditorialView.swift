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

                VStack(alignment: .leading, spacing: 28) {
                    Text("The Praeceptor.")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(theme.text)

                    Text("He arrived with a point of view\nbefore you said a word.")
                        .font(.system(size: 20))
                        .foregroundColor(theme.textSecondary)
                        .lineSpacing(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)

                Spacer()

                Button(action: onContinue) {
                    Text("Begin")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.background)
                        .padding(.horizontal, 44)
                        .padding(.vertical, 16)
                        .background(theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.bottom, 60)
            }
        }
    }
}
