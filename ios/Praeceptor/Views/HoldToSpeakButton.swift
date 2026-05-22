import SwiftUI

struct HoldToSpeakButton: View {
    let phase: SessionPhase
    let audioLevel: Float
    let theme: TimeOfDayTheme
    let onHold: () -> Void
    let onRelease: () -> Void

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var isRecording: Bool {
        if case .recording = phase { return true }
        return false
    }

    var isProcessing: Bool {
        switch phase {
        case .transcribing, .thinking, .speaking: return true
        default: return false
        }
    }

    var isSpeaking: Bool {
        if case .speaking = phase { return true }
        return false
    }

    var buttonColor: Color {
        if isRecording { return theme.holdButtonActive }
        if isProcessing { return theme.accent.opacity(0.6) }
        return theme.holdButtonIdle
    }

    var body: some View {
        ZStack {
            if isRecording && !reduceMotion {
                Circle()
                    .stroke(theme.accent.opacity(0.3), lineWidth: 2)
                    .frame(
                        width: 120 + CGFloat(audioLevel) * 40,
                        height: 120 + CGFloat(audioLevel) * 40
                    )
                    .animation(.easeOut(duration: 0.05), value: audioLevel)
            }

            Circle()
                .fill(buttonColor)
                .frame(width: 100, height: 100)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2), value: isPressed)

            buttonIcon
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed && phase == .idle {
                        isPressed = true
                        onHold()
                    }
                }
                .onEnded { _ in
                    if isPressed {
                        isPressed = false
                        onRelease()
                    }
                }
        )
        .disabled(isProcessing)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(phase == .idle ? "Double tap and hold to speak. Release to send." : "")
        .accessibilityAddTraits(isProcessing ? .updatesFrequently : [])
    }

    @ViewBuilder
    private var buttonIcon: some View {
        if isRecording {
            Image(systemName: "waveform")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
        } else if isProcessing {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.2)
        } else {
            Image(systemName: "mic.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
        }
    }

    private var accessibilityLabel: Text {
        switch phase {
        case .idle: return Text("Speak to The Praeceptor")
        case .recording: return Text("Recording. Release to send.")
        case .transcribing: return Text("Transcribing your message")
        case .thinking: return Text("The Praeceptor is thinking")
        case .speaking: return Text("The Praeceptor is speaking")
        case .error: return Text("Error occurred")
        }
    }
}
