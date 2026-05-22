import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: Role
    let content: String
    let timestamp: Date

    enum Role: String {
        case user, assistant
    }
}

enum SessionPhase: Equatable {
    case idle
    case recording
    case transcribing
    case thinking
    case speaking
    case error(String)
}

enum TimeOfDay {
    case morning   // 5am–12pm — amber/gold, forward-looking
    case noon      // 12pm–5pm — grey/blue, execution
    case night     // 5pm–5am  — navy/earth, reflective

    static var current: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return .morning
        case 12..<17: return .noon
        default: return .night
        }
    }

    var ttsSpeed: Double {
        switch self {
        case .morning: return 0.92
        case .noon: return 0.95
        case .night: return 0.88
        }
    }

    var systemPromptModifier: String {
        switch self {
        case .morning:
            return "This is a morning session. The person is looking forward. Questions and energy should be oriented toward what the day and near future holds."
        case .noon:
            return "This is a midday session. The focus is execution — what is happening now, what is being done, what needs to move."
        case .night:
            return "This is an evening session. The register should be more reflective — what happened today, what was learned, what matters."
        }
    }
}
