import Foundation

struct TTSService {
    private let apiKey: String
    let session: URLSession

    init(apiKey: String, session: URLSession? = nil) {
        self.apiKey = apiKey
        self.session = session ?? NetworkSession.make(requestTimeout: 30, resourceTimeout: 60)
    }

    func synthesize(text: String, speed: Double = 0.92) async throws -> Data {
        // OpenAI TTS hard limit is 4096 characters
        let input = text.count > 4096 ? String(text.prefix(4096)) : text

        let url = URL(string: "https://api.openai.com/v1/audio/speech")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "tts-1",
            "input": input,
            "voice": "onyx",
            "speed": speed,
            "response_format": "mp3"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw TTSError.httpError(0)
        }
        guard http.statusCode == 200 else {
            throw TTSError.httpError(http.statusCode)
        }

        return data
    }

    enum TTSError: Error, LocalizedError {
        case httpError(Int)

        var errorDescription: String? {
            switch self {
            case .httpError(let code):
                switch code {
                case 401: return "OpenAI API key is invalid. Check Settings."
                case 429: return "Voice synthesis rate limit reached. Please wait a moment."
                case 500, 503: return "Voice synthesis service is temporarily unavailable."
                default: return "Voice synthesis failed (error \(code)). Please try again."
                }
            }
        }
    }
}
