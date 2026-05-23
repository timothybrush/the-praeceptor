import Foundation

struct ElevenLabsTTSService {
    private let apiKey: String
    private let voiceID: String
    private let session: URLSession

    init(apiKey: String, voiceID: String, session: URLSession? = nil) {
        self.apiKey = apiKey
        self.voiceID = voiceID
        self.session = session ?? NetworkSession.make(requestTimeout: 30, resourceTimeout: 60)
    }

    func synthesize(text: String) async throws -> Data {
        let input = text.count > 5000 ? String(text.prefix(5000)) : text

        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")

        let body: [String: Any] = [
            "text": input,
            "model_id": "eleven_multilingual_v2",
            "voice_settings": [
                "stability": 0.82,
                "similarity_boost": 0.78,
                "style": 0.18,
                "use_speaker_boost": true
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ElevenLabsError.httpError(0)
        }
        guard http.statusCode == 200 else {
            throw ElevenLabsError.httpError(http.statusCode)
        }

        return data
    }

    enum ElevenLabsError: Error, LocalizedError {
        case httpError(Int)

        var errorDescription: String? {
            switch self {
            case .httpError(let code):
                switch code {
                case 401: return "ElevenLabs API key is invalid. Check Settings."
                case 422: return "ElevenLabs voice ID is invalid. Check Voice settings."
                case 429: return "ElevenLabs rate limit reached. Please wait a moment."
                case 500, 503: return "ElevenLabs service is temporarily unavailable."
                default: return "ElevenLabs voice synthesis failed (error \(code)). Please try again."
                }
            }
        }
    }
}
