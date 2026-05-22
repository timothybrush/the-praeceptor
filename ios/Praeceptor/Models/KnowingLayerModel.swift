import Foundation

struct KnowingLayer: Codable {
    var updated: Date
    var person: PersonContext
    var currentState: CurrentState
    var lastThreeSessions: [SessionSummary]
    var openTensions: [String]
    var thesisDrift: String?
    var hisDirective: String?
    var patternsHeSees: [String]
    var nextSessionIntent: String?

    struct PersonContext: Codable {
        var name: String
        var primaryMission: String
        var sovereigntyStage: String
        var originalThesis: String
    }

    struct CurrentState: Codable {
        var activeProject: String
        var activePhase: String
        var whatTheyAreDoing: String
        var whatTheySaidTheyWouldDo: String
    }

    struct SessionSummary: Codable {
        var date: String
        var whatSurfaced: String
        var whatWasDecided: String?
        var whatWasAvoided: String?
    }

    static var empty: KnowingLayer {
        KnowingLayer(
            updated: Date(),
            person: PersonContext(
                name: "",
                primaryMission: "",
                sovereigntyStage: "",
                originalThesis: ""
            ),
            currentState: CurrentState(
                activeProject: "",
                activePhase: "",
                whatTheyAreDoing: "",
                whatTheySaidTheyWouldDo: ""
            ),
            lastThreeSessions: [],
            openTensions: [],
            thesisDrift: nil,
            hisDirective: nil,
            patternsHeSees: [],
            nextSessionIntent: nil
        )
    }

    func toCompressedContext() -> String {
        var parts: [String] = []
        parts.append("Person: \(person.name) — \(person.primaryMission)")
        parts.append("Stage: \(person.sovereigntyStage)")
        if !person.originalThesis.isEmpty {
            parts.append("Original thesis: \(person.originalThesis)")
        }
        parts.append("Now: \(currentState.whatTheyAreDoing)")
        parts.append("Said they would: \(currentState.whatTheySaidTheyWouldDo)")
        if !lastThreeSessions.isEmpty {
            parts.append("Last sessions:")
            for s in lastThreeSessions.prefix(3) {
                parts.append("  \(s.date): \(s.whatSurfaced)")
                if let decided = s.whatWasDecided { parts.append("    Decided: \(decided)") }
                if let avoided = s.whatWasAvoided { parts.append("    Avoided: \(avoided)") }
            }
        }
        if !openTensions.isEmpty {
            parts.append("Open tensions: \(openTensions.joined(separator: "; "))")
        }
        if let drift = thesisDrift {
            parts.append("Thesis drift: \(drift)")
        }
        if let directive = hisDirective {
            parts.append("His directive (unacknowledged): \(directive)")
        }
        return parts.joined(separator: "\n")
    }
}
