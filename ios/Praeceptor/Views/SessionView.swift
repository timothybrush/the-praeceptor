import SwiftUI

struct SessionView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var apiKeyManager: APIKeyManager
    @EnvironmentObject var launchState: LaunchState
    @StateObject private var viewModel = SessionViewModel()
    @AppStorage("mentor_name") private var mentorName: String = "The Praeceptor"
    @State private var showingSettings = false
    @State private var showTextInput = false
    @State private var textInput = ""

    private var theme: TimeOfDayTheme {
        TimeOfDayTheme.current(TimeOfDay.current)
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                messageList
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                voiceControls
            }
        }
        .task {
            viewModel.configure(apiKeyManager: apiKeyManager)
            if launchState.startRecording {
                launchState.startRecording = false
                viewModel.startRecording()
            }
        }
        .onChange(of: launchState.startRecording) { _, shouldStart in
            guard shouldStart else { return }
            launchState.startRecording = false
            viewModel.startRecording()
        }
        .onChange(of: viewModel.micDenied) { _, denied in
            guard denied else { return }
            withAnimation(.easeInOut(duration: 0.2)) { showTextInput = true }
            viewModel.clearMicDenied()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(apiKeyManager: apiKeyManager)
        }
        .alert("Error", isPresented: errorBinding) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: — Header

    private var headerBar: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(mentorName)
                    .font(TimeOfDayTheme.display(21))
                    .foregroundColor(theme.text)
                    .kerning(-0.4)

                HStack(spacing: 6) {
                    Circle()
                        .fill(theme.accent)
                        .frame(width: 5, height: 5)
                    Text(sessionLabel)
                        .font(TimeOfDayTheme.mono(9.5))
                        .foregroundColor(theme.textTertiary)
                        .kerning(2.4)
                        .textCase(.uppercase)
                }
            }
            Spacer()
            HStack(spacing: 4) {
                if !sessionStore.messages.isEmpty {
                    Button(action: { sessionStore.clearSession() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16))
                            .foregroundColor(theme.textSecondary)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Restart session")
                }
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 17))
                        .foregroundColor(theme.textSecondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Open settings")
            }
            .padding(.top, 2)
        }
        .padding(.bottom, 10)
    }

    // MARK: — Messages

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    if sessionStore.messages.isEmpty {
                        emptyState
                            .id("empty")
                    }

                    ForEach(sessionStore.messages) { message in
                        MessageBubble(message: message, theme: theme, mentorName: mentorName)
                            .id(message.id)
                    }

                    if !viewModel.streamingText.isEmpty {
                        StreamingBubble(text: viewModel.streamingText, theme: theme, mentorName: mentorName)
                            .id("streaming")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .onChange(of: sessionStore.messages.count) { _, _ in
                if let last = sessionStore.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: viewModel.streamingText) { _, text in
                if !text.isEmpty { proxy.scrollTo("streaming", anchor: .bottom) }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 40)
            Text("Hold to speak.")
                .font(TimeOfDayTheme.displayItalic(36))
                .foregroundColor(theme.text)
            Text("\(mentorName) is listening.")
                .font(TimeOfDayTheme.body(14))
                .foregroundColor(theme.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .multilineTextAlignment(.center)
    }

    // MARK: — Voice Controls

    private var voiceControls: some View {
        VStack(spacing: 10) {
            phaseIndicator

            HoldToSpeakButton(
                phase: viewModel.phase,
                audioLevel: viewModel.audioLevel,
                theme: theme,
                onHold: { viewModel.startRecording() },
                onRelease: {
                    viewModel.stopRecording(
                        sessionStore: sessionStore,
                        knowingLayer: sessionStore.knowingLayer
                    )
                }
            )

            if showTextInput {
                textInputBar
            } else {
                voiceFooter
            }
        }
        .padding(.top, 6)
    }

    private var voiceFooter: some View {
        HStack(spacing: 14) {
            Text("Hold to speak")
                .font(TimeOfDayTheme.mono(10.5))
                .foregroundColor(theme.textTertiary)
                .kerning(2.2)
                .textCase(.uppercase)

            Text("·")
                .font(TimeOfDayTheme.mono(10.5))
                .foregroundColor(theme.textGhost)

            Text("Release to send")
                .font(TimeOfDayTheme.mono(10.5))
                .foregroundColor(theme.textTertiary)
                .kerning(2.2)
                .textCase(.uppercase)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showTextInput = true }
            } label: {
                Image(systemName: "keyboard")
                    .font(.system(size: 15))
                    .foregroundColor(theme.textSecondary)
                    .frame(width: 28, height: 28)
            }
        }
        .padding(.bottom, 48)
    }

    private var textInputBar: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showTextInput = false
                    textInput = ""
                }
            } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 16))
                    .foregroundColor(theme.textSecondary)
                    .frame(width: 38, height: 38)
                    .background(theme.surface)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(theme.line, lineWidth: 0.5))
            }

            TextField("Type a message…", text: $textInput, axis: .vertical)
                .font(TimeOfDayTheme.body(15))
                .foregroundColor(theme.text)
                .tint(theme.accent)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 19, style: .continuous)
                        .stroke(theme.line, lineWidth: 0.5)
                )

            if !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               viewModel.phase == .idle {
                Button(action: submitText) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.accentInk)
                        .frame(width: 38, height: 38)
                        .background(theme.accent)
                        .clipShape(Circle())
                        .shadow(color: theme.accentGlow, radius: 8, x: 0, y: 4)
                }
            } else {
                Spacer().frame(width: 38)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 48)
    }

    private func submitText() {
        let trimmed = textInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        textInput = ""
        viewModel.sendText(trimmed, sessionStore: sessionStore, knowingLayer: sessionStore.knowingLayer)
    }

    private var phaseIndicator: some View {
        Text(phaseText.isEmpty ? "·" : phaseText)
            .font(TimeOfDayTheme.mono(10.5))
            .foregroundColor(phaseColor)
            .kerning(2.5)
            .textCase(.uppercase)
            .frame(height: 22)
            .opacity(phaseText.isEmpty ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: viewModel.phase == .idle)
            .accessibilityLabel(Text(phaseText))
            .accessibilityHidden(phaseText.isEmpty)
    }

    private var phaseText: String {
        switch viewModel.phase {
        case .idle:        return ""
        case .recording:   return "Listening…"
        case .transcribing: return "Transcribing…"
        case .thinking:    return "Thinking…"
        case .speaking:    return "Speaking…"
        case .error:       return "Something went wrong"
        }
    }

    private var phaseColor: Color {
        switch viewModel.phase {
        case .recording, .speaking: return theme.accentBright
        case .error:                return theme.bad
        default:                    return theme.textSecondary
        }
    }

    private var sessionLabel: String { TimeOfDay.current.label }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { if case .error = viewModel.phase { return true }; return false },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }

    private var errorMessage: String {
        if case .error(let msg) = viewModel.phase { return msg }
        return ""
    }
}

// MARK: — Message Bubble

struct MessageBubble: View {
    let message: ChatMessage
    let theme: TimeOfDayTheme
    let mentorName: String

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }
            Text(message.content)
                .font(TimeOfDayTheme.body(15))
                .foregroundColor(isUser ? theme.accentInk : theme.text)
                .fontWeight(isUser ? .medium : .regular)
                .lineSpacing(3)
                .padding(.horizontal, isUser ? 16 : 18)
                .padding(.vertical, isUser ? 12 : 14)
                .background(isUser ? theme.accent : theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(
                    color: isUser ? theme.accentGlow : theme.line,
                    radius: isUser ? 6 : 1,
                    x: 0,
                    y: isUser ? 3 : 1
                )
            if !isUser { Spacer(minLength: 0) }
        }
        .accessibilityLabel(isUser ? "You said: \(message.content)" : "\(mentorName) said: \(message.content)")
    }
}

// MARK: — Streaming Bubble

struct StreamingBubble: View {
    let text: String
    let theme: TimeOfDayTheme
    let mentorName: String

    var body: some View {
        HStack {
            Text(text)
                .font(TimeOfDayTheme.body(15))
                .foregroundColor(theme.text)
                .lineSpacing(3)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            Spacer(minLength: 0)
        }
        .accessibilityLabel("\(mentorName) is responding")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

