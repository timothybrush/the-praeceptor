import SwiftUI

struct IntakeView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @AppStorage("mentor_name") private var mentorName: String = "The Praeceptor"
    @State private var step: IntakeStep = .welcome
    @State private var name: String = ""
    @State private var primaryMission: String = ""
    @State private var sovereigntyStage: String = ""
    @State private var originalThesis: String = ""
    @State private var currentFocus: String = ""
    @State private var lastCommitment: String = ""
    @State private var openTension: String = ""

    enum IntakeStep: CaseIterable {
        case welcome, name, mission, stage, thesis, current, commitment, tension, complete
    }

    private var theme: TimeOfDayTheme {
        TimeOfDayTheme.current(TimeOfDay.current)
    }

    // Steps that show the dot progress bar (not welcome/complete)
    private var questionSteps: [IntakeStep] {
        [.name, .mission, .stage, .thesis, .current, .commitment, .tension]
    }

    private var questionIndex: Int? {
        questionSteps.firstIndex(of: step)
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                intakeHeader
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                Spacer()

                stepContent
                    .padding(.horizontal, 32)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(step)

                Spacer()

                continueButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
        .animation(.easeInOut(duration: 0.28), value: step)
    }

    // MARK: — Header (back chevron + progress dots)

    private var intakeHeader: some View {
        HStack {
            Button(action: goBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(theme.textSecondary)
                    .frame(width: 34, height: 34)
            }
            .opacity(step != .welcome ? 1 : 0)
            .disabled(step == .welcome)

            Spacer()

            // Progress dots — only during question steps
            if let idx = questionIndex {
                HStack(spacing: 4) {
                    ForEach(0..<questionSteps.count, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i <= idx ? theme.accent : theme.lineStrong)
                            .frame(width: i == idx ? 18 : 6, height: 2)
                            .animation(.spring(response: 0.3), value: step)
                    }
                }
            }
        }
    }

    // MARK: — Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .welcome:
            welcomeContent

        case .name:
            questionContent(
                roman: "I", label: "Name",
                question: "What's your name?",
                hint: "First name is fine.",
                binding: $name,
                isOptional: false
            )

        case .mission:
            questionContent(
                roman: "II", label: "The Work",
                question: "What are you actually building?",
                hint: "One sentence. What's the real thing — not the pitch.",
                binding: $primaryMission,
                isOptional: false
            )

        case .stage:
            questionContent(
                roman: "III", label: "Where You Stand",
                question: "Where do you stand right now?",
                hint: "Income, stability, what you're depending on. Be specific.",
                binding: $sovereigntyStage,
                isOptional: false
            )

        case .thesis:
            questionContent(
                roman: "IV", label: "Original Thesis",
                question: "What was the original thesis?",
                hint: "What did you say this was when you started? Before the revisions.",
                binding: $originalThesis,
                isOptional: false
            )

        case .current:
            questionContent(
                roman: "V", label: "This Week",
                question: "What are you working on right now?",
                hint: "The thing that's actually getting your time this week.",
                binding: $currentFocus,
                isOptional: false
            )

        case .commitment:
            questionContent(
                roman: "VI", label: "Commitment",
                question: "What did you say you were going to do — and what did you actually do?",
                hint: "The most recent thing you committed to. What happened.",
                binding: $lastCommitment,
                isOptional: false
            )

        case .tension:
            questionContent(
                roman: "VII", label: "What Surfaces",
                question: "What's the one thing that keeps surfacing?",
                hint: "The thing you haven't fully dealt with. The thing that comes back.",
                binding: $openTension,
                isOptional: true
            )

        case .complete:
            completionContent
        }
    }

    // Renders "The\nX." with "The" in regular and "X" in italic accent,
    // or just "Name." fully italic for names that don't start with "The ".
    @ViewBuilder
    private var welcomeTitle: some View {
        let words = mentorName.components(separatedBy: " ")
        if words.count > 1, words[0].lowercased() == "the" {
            Text(words[0] + "\n")
                .font(TimeOfDayTheme.display(64))
                .foregroundColor(theme.text)
            + Text(words.dropFirst().joined(separator: " "))
                .font(TimeOfDayTheme.displayItalic(64))
                .foregroundColor(theme.accent)
            + Text(".")
                .font(TimeOfDayTheme.display(64))
                .foregroundColor(theme.text)
        } else {
            Text(mentorName)
                .font(TimeOfDayTheme.displayItalic(64))
                .foregroundColor(theme.accent)
            + Text(".")
                .font(TimeOfDayTheme.display(64))
                .foregroundColor(theme.text)
        }
    }

    // Welcome screen
    private var welcomeContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("I · Arrival")
                .font(TimeOfDayTheme.mono(10.5))
                .foregroundColor(theme.textTertiary)
                .kerning(2)
                .textCase(.uppercase)
                .padding(.bottom, 16)

            welcomeTitle
                .lineSpacing(-4)
                .kerning(-2.2)
                .padding(.bottom, 30)

            Text("Before we begin, I need to know who I'm talking to.")
                .font(TimeOfDayTheme.displayItalic(22))
                .foregroundColor(theme.text)
                .lineSpacing(5)
                .kerning(-0.2)
                .padding(.bottom, 24)

            Text("Not your background. Not your credentials. Who you are, what you're building, and where you actually stand.")
                .font(TimeOfDayTheme.body(15))
                .foregroundColor(theme.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Individual question screen
    private func questionContent(
        roman: String,
        label: String,
        question: String,
        hint: String,
        binding: Binding<String>,
        isOptional: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("\(roman) · \(label)")
                    .font(TimeOfDayTheme.mono(10.5))
                    .foregroundColor(theme.textTertiary)
                    .kerning(2)
                    .textCase(.uppercase)
                if isOptional {
                    Text("  ·  Optional")
                        .font(TimeOfDayTheme.mono(10.5))
                        .foregroundColor(theme.textGhost)
                        .kerning(2)
                        .textCase(.uppercase)
                }
            }
            .padding(.bottom, 18)

            Text(question)
                .font(TimeOfDayTheme.display(34))
                .foregroundColor(theme.text)
                .lineSpacing(2)
                .kerning(-0.8)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 18)

            Text(hint)
                .font(TimeOfDayTheme.displayItalic(16))
                .foregroundColor(theme.textSecondary)
                .lineSpacing(4)
                .padding(.bottom, 36)

            // Answer input area
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .bottomLeading) {
                    // Invisible field for typing
                    TextField("", text: binding, axis: .vertical)
                        .font(TimeOfDayTheme.display(22))
                        .foregroundColor(theme.text)
                        .kerning(-0.2)
                        .lineLimit(1...5)
                        .tint(theme.accent)
                        .opacity(binding.wrappedValue.isEmpty ? 0 : 1)

                    // Placeholder
                    if binding.wrappedValue.isEmpty {
                        Text("…")
                            .font(TimeOfDayTheme.displayItalic(22))
                            .foregroundColor(theme.textTertiary)
                            .kerning(-0.2)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.bottom, 14)

                Rectangle()
                    .fill(theme.lineStrong)
                    .frame(height: 1)

                HStack {
                    Text(isOptional ? "Skip if nothing comes to mind" : "Take your time")
                        .font(TimeOfDayTheme.mono(9.5))
                        .foregroundColor(theme.textGhost)
                        .kerning(2)
                        .textCase(.uppercase)
                    Spacer()
                    Text("\(binding.wrappedValue.count) chars")
                        .font(TimeOfDayTheme.mono(9.5))
                        .foregroundColor(theme.textGhost)
                        .kerning(1.6)
                        .textCase(.uppercase)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Completion screen
    private var completionContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("IX · Enough")
                .font(TimeOfDayTheme.mono(10.5))
                .foregroundColor(theme.textTertiary)
                .kerning(2)
                .textCase(.uppercase)
                .padding(.bottom, 22)

            Text("That's enough\nto start.")
                .font(TimeOfDayTheme.displayItalic(44))
                .foregroundColor(theme.text)
                .lineSpacing(2)
                .kerning(-1.2)
                .padding(.bottom, 26)

            Text("I'll learn the rest as we work.")
                .font(TimeOfDayTheme.body(16))
                .foregroundColor(theme.textSecondary)
                .lineSpacing(4)

            Spacer().frame(height: 40)

            HStack(spacing: 12) {
                Rectangle()
                    .fill(theme.lineStrong)
                    .frame(width: 24, height: 1)
                Text("Seven answers logged")
                    .font(TimeOfDayTheme.mono(9.5))
                    .foregroundColor(theme.textTertiary)
                    .kerning(2.5)
                    .textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: — Continue Button

    private var continueButton: some View {
        Button(action: goForward) {
            HStack(spacing: 10) {
                Text(step == .complete ? "Begin" : "Continue")
                    .font(TimeOfDayTheme.body(15))
                    .fontWeight(.medium)
                    .kerning(2)
                    .textCase(.uppercase)

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(canContinue ? theme.accentInk : theme.textTertiary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(canContinue ? theme.accent : theme.raised)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(
                color: canContinue ? theme.accentGlow : .clear,
                radius: 16,
                x: 0,
                y: 6
            )
        }
        .disabled(!canContinue)
        .animation(.easeInOut(duration: 0.2), value: canContinue)
    }

    // MARK: — Navigation

    private var canContinue: Bool {
        switch step {
        case .welcome, .complete, .tension: return true
        case .name:       return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .mission:    return !primaryMission.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .stage:      return !sovereigntyStage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .thesis:     return !originalThesis.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .current:    return !currentFocus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .commitment: return !lastCommitment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private func goForward() {
        let steps = IntakeStep.allCases
        if step == .complete {
            completeIntake()
            return
        }
        if let idx = steps.firstIndex(of: step), idx + 1 < steps.count {
            withAnimation(.easeInOut(duration: 0.28)) {
                step = steps[idx + 1]
            }
        }
    }

    private func goBack() {
        let steps = IntakeStep.allCases
        if let idx = steps.firstIndex(of: step), idx > 0 {
            withAnimation(.easeInOut(duration: 0.28)) {
                step = steps[idx - 1]
            }
        }
    }

    private func completeIntake() {
        var layer = KnowingLayer.empty
        layer.updated = Date()
        layer.person.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.person.primaryMission = primaryMission.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.person.sovereigntyStage = sovereigntyStage.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.person.originalThesis = originalThesis.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.currentState.whatTheyAreDoing = currentFocus.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.currentState.whatTheySaidTheyWouldDo = lastCommitment.trimmingCharacters(in: .whitespacesAndNewlines)
        layer.currentState.activeProject = ""
        layer.currentState.activePhase = ""

        let tension = openTension.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tension.isEmpty { layer.openTensions = [tension] }

        sessionStore.completeIntake(layer: layer)
    }
}
