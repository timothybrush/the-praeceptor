import SwiftUI

struct IntakeView: View {
    @EnvironmentObject var sessionStore: SessionStore
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

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                progressBar
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                Spacer()

                stepContent
                    .padding(.horizontal, 32)

                Spacer()

                navigationButtons
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    // MARK: — Progress

    private var progressBar: some View {
        let steps = IntakeStep.allCases
        let current = steps.firstIndex(of: step) ?? 0
        let total = steps.count - 2 // exclude welcome and complete

        return HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i < current ? theme.accent : theme.surface)
                    .frame(height: 3)
            }
        }
    }

    // MARK: — Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .welcome:
            VStack(spacing: 20) {
                Text("The Praeceptor")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(theme.text)
                Text("Before we begin, I need to know who I'm talking to.\n\nNot your background. Not your credentials.\n\nWho you are, what you're building, and where you actually stand.")
                    .font(.system(size: 16))
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

        case .name:
            intakeField(
                question: "What's your name?",
                hint: "First name is fine.",
                binding: $name
            )

        case .mission:
            intakeField(
                question: "What are you actually building?",
                hint: "One sentence. What's the real thing — not the pitch.",
                binding: $primaryMission
            )

        case .stage:
            intakeField(
                question: "Where do you stand right now?",
                hint: "Income, stability, what you're depending on. Be specific.",
                binding: $sovereigntyStage
            )

        case .thesis:
            intakeField(
                question: "What was the original thesis?",
                hint: "What did you say this was when you started? Before the revisions.",
                binding: $originalThesis
            )

        case .current:
            intakeField(
                question: "What are you working on right now?",
                hint: "The thing that's actually getting your time this week.",
                binding: $currentFocus
            )

        case .commitment:
            intakeField(
                question: "What did you say you were going to do — and what did you actually do?",
                hint: "The most recent thing you committed to. What happened.",
                binding: $lastCommitment
            )

        case .tension:
            intakeField(
                question: "What's the one thing that keeps surfacing?",
                hint: "The thing you haven't fully dealt with. The thing that comes back.",
                binding: $openTension
            )

        case .complete:
            VStack(spacing: 20) {
                Text("That's enough to start.")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(theme.text)
                Text("I'll learn the rest as we work.")
                    .font(.system(size: 16))
                    .foregroundColor(theme.textSecondary)
            }
        }
    }

    private func intakeField(question: String, hint: String, binding: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(theme.text)
                .fixedSize(horizontal: false, vertical: true)
            Text(hint)
                .font(.system(size: 13))
                .foregroundColor(theme.textSecondary)
            TextField("", text: binding, axis: .vertical)
                .font(.system(size: 16))
                .foregroundColor(theme.text)
                .padding(16)
                .background(theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .lineLimit(4)
                .tint(theme.accent)
        }
    }

    // MARK: — Navigation

    private var navigationButtons: some View {
        HStack {
            if step != .welcome {
                Button(action: goBack) {
                    Text("Back")
                        .font(.system(size: 16))
                        .foregroundColor(theme.textSecondary)
                }
            }
            Spacer()
            Button(action: goForward) {
                Text(step == .complete ? "Begin" : "Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.background)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!canContinue)
            .opacity(canContinue ? 1.0 : 0.4)
        }
    }

    private var canContinue: Bool {
        switch step {
        case .welcome, .complete: return true
        case .name: return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .mission: return !primaryMission.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .stage: return !sovereigntyStage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .thesis: return !originalThesis.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .current: return !currentFocus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .commitment: return !lastCommitment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .tension: return true
        }
    }

    private func goForward() {
        let steps = IntakeStep.allCases
        if step == .complete {
            completeIntake()
            return
        }
        if let idx = steps.firstIndex(of: step), idx + 1 < steps.count {
            step = steps[idx + 1]
        }
    }

    private func goBack() {
        let steps = IntakeStep.allCases
        if let idx = steps.firstIndex(of: step), idx > 0 {
            step = steps[idx - 1]
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
