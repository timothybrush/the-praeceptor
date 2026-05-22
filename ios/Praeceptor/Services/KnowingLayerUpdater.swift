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

        let transcript = session
            .map { "\($0.role.rawValue): \($0.content)" }
            .joined(separator: "\n")

        let today: String = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withFullDate]
            return f.string(from: Date())
        }()

        let userMessage = """
        Session transcript:
        \(transcript)

        Existing KNOWING layer JSON:
        \(existingJSON)

        Today's date: \(today)

        Return an updated KNOWING layer JSON. Rules:
        - Preserve all person fields unless the session explicitly changes them
        - Update currentState fields if new information surfaced
        - Add a new SessionSummary entry for today to lastThreeSessions (keep at most 3, remove oldest)
        - Update openTensions, thesisDrift, hisDirective, patternsHeSees, nextSessionIntent based on what surfaced
        - Do NOT include the "updated" field
        - Return ONLY valid JSON. No markdown fences, no explanation.
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

        let systemPrompt = "You maintain a structured JSON context object for a voice mentor app. Return only valid JSON with no explanation or markdown formatting."

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 2000,
            "system": systemPrompt,
            "messages": [["role": "user", "content": userMessage]]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        request.httpBody = httpBody

        guard let (data, response) = try? await session.data(for: request),
              let http = response as? HTTPURLResponse,
              http.statusCode == 200 else { return nil }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let first = content.first,
              let text = first["text"] as? String else { return nil }

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
