import SwiftUI

struct SessionView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var apiKeyManager: APIKeyManager
    @StateObject private var viewModel = SessionViewModel()
    @State private var showingSettings = false

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
                onHold: {
                    viewModel.startRecording()
                },
                onRelease: {
                    viewModel.stopRecording(
                        sessionStore: sessionStore,
                        knowingLayer: sessionStore.knowingLayer
                    )
                }
            )

            Text("Hold to speak · Release to send")
                .font(.system(size: 12))
                .foregroundColor(theme.textSecondary)
                .padding(.bottom, 48)
        }
        .padding(.top, 8)
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

    private var sessionLabel: String {
        switch TimeOfDay.current {
        case .morning: return "Morning session"
        case .noon: return "Midday session"
        case .night: return "Evening session"
        }
    }

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
