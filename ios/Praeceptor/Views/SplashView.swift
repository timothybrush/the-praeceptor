import SwiftUI

// Every cold launch — definition fades in, holds, fades out, then onComplete fires.
// Not persisted — shows on every fresh app open.
struct SplashView: View {
    let onComplete: () -> Void

    @State private var opacity: Double = 0

    private var theme: TimeOfDayTheme {
        TimeOfDayTheme.current(TimeOfDay.current)
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(maxHeight: 220)
                definitionBlock
                Spacer()
            }
            .opacity(opacity)
        }
        .task { await run() }
    }

    // MARK: — Definition block (shared with PreceptorIntroView)

    var definitionBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("prae·cep·tor")
                .font(TimeOfDayTheme.displayItalic(44))
                .foregroundColor(theme.text)
                .kerning(-1.0)
                .padding(.bottom, 18)

            Text("Latin.")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.accent)
                .kerning(2.4)
                .textCase(.uppercase)
                .padding(.bottom, 10)

            Text("A teacher who instructs before\nthe lesson is required.")
                .font(TimeOfDayTheme.display(20))
                .foregroundColor(theme.textSecondary)
                .lineSpacing(5)
                .kerning(-0.3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 44)
    }

    @MainActor
    private func run() async {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--skip-splash") {
            onComplete()
            return
        }
        #endif

        // Fade in
        try? await Task.sleep(nanoseconds: 200_000_000)
        withAnimation(.easeIn(duration: 0.7)) { opacity = 1 }

        // Hold
        try? await Task.sleep(nanoseconds: 2_500_000_000)

        // Fade out
        withAnimation(.easeOut(duration: 0.6)) { opacity = 0 }
        try? await Task.sleep(nanoseconds: 650_000_000)

        onComplete()
    }
}
