import Foundation

struct WhisperService {
    private let apiKey: String
    let session: URLSession

    init(apiKey: String, session: URLSession? = nil) {
        self.apiKey = apiKey
        self.session = session ?? NetworkSession.make(requestTimeout: 30, resourceTimeout: 120)
    }

    func transcribe(audioURL: URL) async throws -> String {
        guard let audioData = try? Data(contentsOf: audioURL), !audioData.isEmpty else {
            throw TranscriptionError.emptyAudio
        }

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw TranscriptionError.apiError("No response received.")
        }
        guard http.statusCode == 200 else {
            throw TranscriptionError.httpError(http.statusCode)
        }

        let result = try JSONDecoder().decode(WhisperResponse.self, from: data)
        return result.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    enum TranscriptionError: Error, LocalizedError {
        case emptyAudio
        case apiError(String)
        case httpError(Int)

        var errorDescription: String? {
            switch self {
            case .emptyAudio:
                return "No audio recorded. Hold the button and speak."
            case .apiError(let msg):
                return "Transcription error: \(msg)"
            case .httpError(let code):
                switch code {
                case 401: return "OpenAI API key is invalid. Check Settings."
                case 429: return "Transcription rate limit reached. Please wait a moment."
                case 500, 503: return "OpenAI service is temporarily unavailable."
                default: return "Transcription failed (error \(code)). Please try again."
                }
            }
        }
    }

    private struct WhisperResponse: Decodable {
        let text: String
    }
}
