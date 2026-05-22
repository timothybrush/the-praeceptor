import Foundation

struct ClaudeService: Sendable {
    private let apiKey: String
    private let model = "claude-sonnet-4-6"
    private let maxTokens = 1024

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func stream(
        systemPrompt: String,
        messages: [[String: String]]
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let url = URL(string: "https://api.anthropic.com/v1/messages")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

                    let body: [String: Any] = [
                        "model": model,
                        "max_tokens": maxTokens,
                        "stream": true,
                        "system": systemPrompt,
                        "messages": messages
                    ]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                        continuation.finish(throwing: ClaudeError.httpError(
                            (response as? HTTPURLResponse)?.statusCode ?? 0
                        ))
                        return
                    }

                    for try await line in asyncBytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonStr = String(line.dropFirst(6))
                        guard jsonStr != "[DONE]" else { break }

                        if let data = jsonStr.data(using: .utf8),
                           let event = try? JSONDecoder().decode(StreamEvent.self, from: data),
                           let text = event.delta?.text {
                            continuation.yield(text)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    enum ClaudeError: Error {
        case httpError(Int)
    }

    private struct StreamEvent: Decodable {
        let delta: Delta?
        struct Delta: Decodable {
            let text: String?
        }
    }
}
