import SwiftUI

// First-run intro — fires once after API keys, before intake.
// Phase 1: Latin definition fades in, holds, fades out.
// Phase 2: Character description reveals line by line.
// Phase 3: Continue → intake.
struct PreceptorIntroView: View {
    let onContinue: () -> Void

    private enum Phase { case definition, description }

    @State private var phase: Phase = .definition
    @State private var defOpacity: Double = 0
    @State private var visibleLines: Int = 0
    @State private var showContinue: Bool = false

    private var theme: TimeOfDayTheme {
        TimeOfDayTheme.current(TimeOfDay.current)
    }

    // Character description lines
    private let lines: [(text: String, size: CGFloat, italic: Bool, color: KeyPath<TimeOfDayTheme, Color>)] = [
        ("A mentor.",
         44, true,  \.text),
        ("Not a coach. Not an AI assistant.\nA composite of the voices that actually built things.",
         20, false, \.textSecondary),
        ("He sees the gap between what you say you're doing and what you're actually doing.",
         20, false, \.text),
        ("He doesn't chase. He doesn't encourage.\nHe already has a point of view.",
         20, true,  \.textSecondary),
    ]

    // Intervals between each item in description phase
    // [label, line0, line1, line2, line3]
    private let descIntervals: [Double] = [0.3, 1.0, 1.3, 1.3, 1.3]
    private let continueInterval: Double = 1.2

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            // Phase 1 — definition (same layout as SplashView)
            if phase == .definition {
                VStack(spacing: 0) {
                    Spacer().frame(maxHeight: 220)
                    definitionBlock
                        .opacity(defOpacity)
                    Spacer()
                }
            }

            // Phase 2 — character description
            if phase == .description {
                VStack(spacing: 0) {
                    Spacer()
                    descriptionBlock
                        .padding(.horizontal, 40)
                    Spacer()
                    continueButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                }
            }
        }
        .task { await runSequence() }
    }

    // MARK: — Definition block

    private var definitionBlock: some View {
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

    // MARK: — Description block

    private var descriptionBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section label
            Text("THE PRAECEPTOR")
                .font(TimeOfDayTheme.mono(10))
                .foregroundColor(theme.textTertiary)
                .kerning(2.4)
                .textCase(.uppercase)
                .padding(.bottom, 28)
                .opacity(visibleLines >= 1 ? 1 : 0)
                .animation(.easeIn(duration: 0.5), value: visibleLines >= 1)

            // Lines — label = slot 1, line[i] = slot i+2
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                let slot = index + 2
                Group {
                    if line.italic {
                        Text(line.text).font(TimeOfDayTheme.displayItalic(line.size))
                    } else {
                        Text(line.text).font(TimeOfDayTheme.display(line.size))
                    }
                }
                .foregroundColor(theme[keyPath: line.color])
                .lineSpacing(5)
                .kerning(index == 0 ? -1.0 : -0.3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, index == 0 ? 28 : 20)
                .opacity(visibleLines >= slot ? 1 : 0)
                .offset(y: visibleLines >= slot ? 0 : 8)
                .animation(.easeOut(duration: 0.6), value: visibleLines >= slot)
            }

            // Hairline with last line
            Rectangle()
                .fill(theme.accentLine)
                .frame(height: 1)
                .padding(.top, 8)
                .opacity(visibleLines >= lines.count + 1 ? 1 : 0)
                .animation(.easeIn(duration: 0.8), value: visibleLines >= lines.count + 1)
        }
    }

    // MARK: — Continue button

    private var continueButton: some View {
        Button(action: onContinue) {
            HStack(spacing: 10) {
                Text("Continue")
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
        .opacity(showContinue ? 1 : 0)
        .offset(y: showContinue ? 0 : 12)
        .animation(.easeOut(duration: 0.5), value: showContinue)
        .disabled(!showContinue)
    }

    // MARK: — Sequence

    @MainActor
    private func runSequence() async {
        // Phase 1: definition
        try? await Task.sleep(nanoseconds: 300_000_000)
        withAnimation(.easeIn(duration: 0.7)) { defOpacity = 1 }

        try? await Task.sleep(nanoseconds: 2_700_000_000)

        withAnimation(.easeOut(duration: 0.6)) { defOpacity = 0 }
        try? await Task.sleep(nanoseconds: 700_000_000)

        // Phase 2: description
        withAnimation(.easeIn(duration: 0.3)) { phase = .description }

        let totalItems = 1 + lines.count
        for i in 0..<totalItems {
            let interval = i < descIntervals.count ? descIntervals[i] : 1.0
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            visibleLines = i + 1
        }

        try? await Task.sleep(nanoseconds: UInt64(continueInterval * 1_000_000_000))
        showContinue = true
    }
}
