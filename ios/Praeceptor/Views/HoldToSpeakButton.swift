import SwiftUI

struct HoldToSpeakButton: View {
    let phase: SessionPhase
    let audioLevel: Float
    let theme: TimeOfDayTheme
    let onHold: () -> Void
    let onRelease: () -> Void

    @State private var isPressed = false

    var isRecording: Bool {
        if case .recording = phase { return true }
        return false
    }

    var isProcessing: Bool {
        switch phase {
        case .transcribing, .thinking: return true
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
        if isSpeaking { return theme.accent.opacity(0.4) }
        return theme.holdButtonIdle
    }

    var pulseScale: CGFloat {
        isRecording ? 1.0 + CGFloat(audioLevel) * 0.3 : 1.0
    }

    var body: some View {
        ZStack {
            // Pulse ring when recording
            if isRecording {
                Circle()
                    .stroke(theme.accent.opacity(0.3), lineWidth: 2)
                    .frame(width: 120 + CGFloat(audioLevel) * 40, height: 120 + CGFloat(audioLevel) * 40)
                    .animation(.easeOut(duration: 0.05), value: audioLevel)
            }

            // Main button
            Circle()
                .fill(buttonColor)
                .frame(width: 100, height: 100)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2), value: isPressed)

            // Icon
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
        } else if isSpeaking {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(.white)
        } else {
            Image(systemName: "mic.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
        }
    }
}
