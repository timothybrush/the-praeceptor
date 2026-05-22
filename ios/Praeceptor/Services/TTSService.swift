import Foundation

struct TTSService {
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
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

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TTSError.apiError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        return data
    }

    enum TTSError: Error {
        case apiError(Int)
    }
}
