import SwiftUI

struct SessionView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var apiKeyManager: APIKeyManager
    @EnvironmentObject var launchState: LaunchState
    @StateObject private var viewModel = SessionViewModel()
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
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("The Praeceptor")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.text)
                Text(sessionLabel)
                    .font(.system(size: 12))
                    .foregroundColor(theme.textSecondary)
            }
            Spacer()
            HStack(spacing: 16) {
                if !sessionStore.messages.isEmpty {
                    Button(action: { sessionStore.clearSession() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16))
                            .foregroundColor(theme.textSecondary)
                    }
                }
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
        .padding(.bottom, 8)
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
                        MessageBubble(message: message, theme: theme)
                            .id(message.id)
                    }

                    if !viewModel.streamingText.isEmpty {
                        StreamingBubble(text: viewModel.streamingText, theme: theme)
                            .id("streaming")
                    }
                }
                .padding(.horizontal, 24)
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
        VStack(spacing: 12) {
            Spacer().frame(height: 60)
            Text("Hold to speak.")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(theme.text)
            Text("The Praeceptor is listening.")
                .font(.system(size: 14))
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: — Voice Controls

    private var voiceControls: some View {
        VStack(spacing: 12) {
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
        .padding(.top, 8)
    }

    private var voiceFooter: some View {
        HStack(spacing: 6) {
            Text("Hold to speak · Release to send")
                .font(.system(size: 12))
                .foregroundColor(theme.textSecondary)
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showTextInput = true }
            } label: {
                Image(systemName: "keyboard")
                    .font(.system(size: 13))
                    .foregroundColor(theme.textSecondary.opacity(0.5))
            }
        }
        .padding(.bottom, 48)
    }

    private var textInputBar: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Type a message...", text: $textInput, axis: .vertical)
                .font(.system(size: 15))
                .foregroundColor(theme.text)
                .tint(theme.accent)
                .lineLimit(1...4)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            if !textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               viewModel.phase == .idle {
                Button(action: submitText) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(theme.accent)
                }
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showTextInput = false
                    textInput = ""
                }
            } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 16))
                    .foregroundColor(theme.textSecondary.opacity(0.6))
                    .frame(width: 30, height: 30)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 48)
    }

    private func submitText() {
        let trimmed = textInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        textInput = ""
        viewModel.sendText(trimmed, sessionStore: sessionStore, knowingLayer: sessionStore.knowingLayer)
    }

    private var phaseIndicator: some View {
        Text(phaseText)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(phaseColor)
            .frame(height: 20)
            .animation(.easeInOut(duration: 0.2), value: viewModel.phase == .idle)
    }

    private var phaseText: String {
        switch viewModel.phase {
        case .idle: return ""
        case .recording: return "Listening..."
        case .transcribing: return "Transcribing..."
        case .thinking: return "Thinking..."
        case .speaking: return "Speaking..."
        case .error: return "Something went wrong"
        }
    }

    private var phaseColor: Color {
        switch viewModel.phase {
        case .recording, .speaking: return theme.accent
        case .error: return .red
        default: return theme.textSecondary
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

struct MessageBubble: View {
    let message: ChatMessage
    let theme: TimeOfDayTheme

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 48) }
            Text(message.content)
                .font(.system(size: 15))
                .foregroundColor(isUser ? theme.background : theme.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(isUser ? theme.accent : theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            if !isUser { Spacer(minLength: 48) }
        }
    }
}

struct StreamingBubble: View {
    let text: String
    let theme: TimeOfDayTheme

    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(theme.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            Spacer(minLength: 48)
        }
    }
}
