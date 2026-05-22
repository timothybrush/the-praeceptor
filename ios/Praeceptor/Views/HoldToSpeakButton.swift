import SwiftUI
import UIKit

private let kButtonSize: CGFloat = 100

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

    var isWaiting: Bool {
        switch phase {
        case .transcribing, .thinking: return true
        default: return false
        }
    }

    // Phase-driven button appearance
    var buttonColor: Color {
        if isRecording { return theme.accentBright }
        if isSpeaking  { return theme.accentDeep }
        return theme.accent
    }

    var buttonOpacity: Double {
        if isWaiting   { return 0.45 }
        if isSpeaking  { return 0.65 }
        return 1.0
    }

    // Pulse rings driven by audio level (0..1 → +20..+60 diameter)
    var pulseOffset: CGFloat {
        isRecording ? (20 + CGFloat(audioLevel) * 40) : 0
    }

    var body: some View {
        ZStack {
            // Idle hairline ring
            if !isRecording {
                Circle()
                    .stroke(theme.accentLine, lineWidth: 0.5)
                    .frame(width: kButtonSize + 14, height: kButtonSize + 14)
                    .opacity(0.55)
            }

            // Recording outer pulse ring
            if isRecording && !reduceMotion {
                Circle()
                    .stroke(theme.accent, lineWidth: 1.5)
                    .frame(
                        width: kButtonSize + pulseOffset,
                        height: kButtonSize + pulseOffset
                    )
                    .opacity(0.32)
                    .animation(.easeOut(duration: 0.05), value: audioLevel)

                Circle()
                    .stroke(theme.accent, lineWidth: 1)
                    .frame(
                        width: kButtonSize + pulseOffset * 0.55 + 12,
                        height: kButtonSize + pulseOffset * 0.55 + 12
                    )
                    .opacity(0.18)
                    .animation(.easeOut(duration: 0.05), value: audioLevel)
            }

            // Core button
            Circle()
                .fill(buttonColor)
                .frame(width: kButtonSize, height: kButtonSize)
                .opacity(buttonOpacity)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2), value: isPressed)
                .shadow(color: theme.accentGlow, radius: isRecording ? 16 : 10, x: 0, y: 6)

            buttonGlyph
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed && phase == .idle {
                        isPressed = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onHold()
                    }
                }
                .onEnded { _ in
                    if isPressed {
                        isPressed = false
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
    private var buttonGlyph: some View {
        if isRecording {
            Image(systemName: "waveform")
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(theme.accentInk)
        } else if isSpeaking {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(theme.accentInk)
        } else if isWaiting {
            ProgressView()
                .tint(theme.accentInk)
                .scaleEffect(1.2)
        } else {
            Image(systemName: "mic.fill")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(theme.accentInk)
        }
    }

    private var accessibilityLabel: Text {
        switch phase {
        case .idle:        return Text("Speak to The Praeceptor")
        case .recording:   return Text("Recording. Release to send.")
        case .transcribing: return Text("Transcribing your message")
        case .thinking:    return Text("The Praeceptor is thinking")
        case .speaking:    return Text("The Praeceptor is speaking")
        case .error:       return Text("Error occurred")
        }
    }
}
