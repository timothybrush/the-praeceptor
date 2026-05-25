import Foundation

@MainActor
final class KnowingLayerUpdater {
    private let apiKey: String
    private let model = "claude-haiku-4-5-20251001"
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func update(
        session: [ChatMessage],
        existing: KnowingLayer?,
        mentorName: String,
        store: SessionStore
    ) async {
        let userTurns = session.filter { $0.role == .user }.count
        guard userTurns >= 3 else { return }

        let existingJSON: String
        if let layer = existing,
           let data = try? JSONEncoder().encode(layer),
           let str = String(data: data, encoding: .utf8) {
            existingJSON = str
        } else {
            existingJSON = "{}"
        }

        // Last 20 messages — enough context without ballooning the Haiku call
        let recentMessages = session.suffix(20)
        let transcript = recentMessages
            .map { "\($0.role.rawValue): \($0.content)" }
            .joined(separator: "\n")

        let today: String = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withFullDate]
            return f.string(from: Date())
        }()

        let userMessage = """
        Session transcript (most recent exchanges):
        \(transcript)

        Existing KNOWING layer JSON:
        \(existingJSON)

        Today: \(today)
        Mentor name: \(mentorName)

        Update the KNOWING layer JSON. Apply these rules precisely:

        person — preserve unless the session explicitly changes a field
        currentState — update if new information surfaced
        lastThreeSessions — add today's entry, remove oldest if already 3 (max 3)
        openTensions — max 3; not observations — unresolved things that actually matter
        thesisDrift — MOST IMPORTANT FIELD: if original thesis and current state diverged, name it in one sentence; null if no drift
        hisDirective — the specific thing \(mentorName) left with the user that hasn't been acknowledged; null if none
        patternsHeSees — only from this exact list, only those confirmed visible in THIS session (max 3):
          "Motion mistaken for momentum"
          "Dispersal masquerading as optionality"
          "Financial pressure rewriting the thesis"
          "Performing the journey instead of doing the work"
          "Mistaking learning for action"
          "Gap between stated values and actual calendar"
          "Lowering the bar quietly"
        nextSessionIntent — one sentence: what \(mentorName) plans to open with or return to next time
        supplementalContext — preserve as-is if present

        Target: the full JSON must serialize to ≤800 tokens. Compress session summaries and field values if needed.
        Do NOT include the "updated" field.
        Return ONLY valid JSON. No markdown fences, no explanation.
        """

        guard let updated = await callHaiku(userMessage: userMessage) else { return }
        store.updateProfile(updated)
    }

    private func callHaiku(userMessage: String) async -> KnowingLayer? {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let systemPrompt = "You are writing session notes for a formed mentor. Record what he observed — not a neutral summary. What was the real tension? What did he leave with them? What pattern did he see? Return only valid JSON with no explanation or markdown."

        let body = MessagesRequest(
            model: model,
            maxTokens: 2000,
            system: systemPrompt,
            messages: [.init(role: "user", content: userMessage)]
        )
        guard let httpBody = try? JSONEncoder().encode(body) else { return nil }
        request.httpBody = httpBody

        guard let (data, response) = try? await session.data(for: request),
              let http = response as? HTTPURLResponse,
              http.statusCode == 200 else { return nil }

        guard let decoded = try? JSONDecoder().decode(MessagesResponse.self, from: data),
              let text = decoded.content.first(where: { $0.type == "text" })?.text else { return nil }

        // Extract JSON object — handles accidental markdown fences or surrounding prose
        guard let startIdx = text.firstIndex(of: "{"),
              let endIdx = text.lastIndex(of: "}") else { return nil }
        let jsonString = String(text[startIdx...endIdx])

        guard let jsonData = jsonString.data(using: .utf8),
              var dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return nil }

        // Inject timestamp matching KnowingLayerBridge's default JSONEncoder/Decoder strategy
        // JSONEncoder default uses timeIntervalSinceReferenceDate (2001 epoch), not 1970
        dict["updated"] = Date().timeIntervalSinceReferenceDate

        guard let patched = try? JSONSerialization.data(withJSONObject: dict),
              let layer = try? JSONDecoder().decode(KnowingLayer.self, from: patched) else { return nil }

        return layer
    }
}

private struct MessagesRequest: Encodable {
    let model: String
    let maxTokens: Int
    let system: String
    let messages: [Message]

    enum CodingKeys: String, CodingKey {
        case model, system, messages
        case maxTokens = "max_tokens"
    }

    struct Message: Encodable {
        let role: String
        let content: String
    }
}

private struct MessagesResponse: Decodable {
    let content: [ContentBlock]
    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }
}
