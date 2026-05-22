@preconcurrency import ActivityKit

struct PraeceptorActivityAttributes: ActivityAttributes {
    let sessionLabel: String

    struct ContentState: Codable, Hashable {
        var phase: ActivityPhase
    }
}

enum ActivityPhase: String, Codable, Hashable {
    case recording
    case transcribing
    case thinking
    case speaking

    var systemImage: String {
        switch self {
        case .recording:    return "mic.fill"
        case .transcribing: return "waveform"
        case .thinking:     return "ellipsis.bubble"
        case .speaking:     return "speaker.wave.2.fill"
        }
    }

    var compactLabel: String {
        switch self {
        case .recording:    return "Listening"
        case .transcribing: return "Thinking"
        case .thinking:     return "Thinking"
        case .speaking:     return "Speaking"
        }
    }

    var expandedDescription: String {
        switch self {
        case .recording:    return "Listening..."
        case .transcribing: return "Processing what you said..."
        case .thinking:     return "The Praeceptor is thinking."
        case .speaking:     return "Speaking. Come back when it stops."
        }
    }
}
