import Foundation

struct ClaudeService: Sendable {
    private let apiKey: String
    private let model = "claude-sonnet-4-6"
    private let maxTokens = 2048
    let session: URLSession

    init(apiKey: String, session: URLSession? = nil) {
        self.apiKey = apiKey
        self.session = session ?? NetworkSession.make(requestTimeout: 10, resourceTimeout: 120)
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

                    let (asyncBytes, response) = try await session.bytes(for: request)

                    guard let http = response as? HTTPURLResponse else {
                        continuation.finish(throwing: ClaudeError.httpError(0))
                        return
                    }
                    guard http.statusCode == 200 else {
                        continuation.finish(throwing: ClaudeError.httpError(http.statusCode))
                        return
                    }

                    for try await line in asyncBytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonStr = String(line.dropFirst(6))

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

    enum ClaudeError: Error, LocalizedError {
        case httpError(Int)

        var errorDescription: String? {
            switch self {
            case .httpError(let code):
                switch code {
                case 401: return "Claude API key is invalid. Check Settings."
                case 429: return "Claude rate limit reached. Please wait a moment."
                case 529: return "Claude is overloaded. Please try again shortly."
                case 500, 503: return "Claude service is temporarily unavailable."
                default: return "Claude error (\(code)). Please try again."
                }
            }
        }
    }

    private struct StreamEvent: Decodable {
        let delta: Delta?
        struct Delta: Decodable {
            let text: String?
        }
    }
}
