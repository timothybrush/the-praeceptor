import Foundation

struct WhisperService {
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
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

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TranscriptionError.apiError(String(data: data, encoding: .utf8) ?? "Unknown error")
        }

        let result = try JSONDecoder().decode(WhisperResponse.self, from: data)
        return result.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    enum TranscriptionError: Error, LocalizedError {
        case emptyAudio
        case apiError(String)

        var errorDescription: String? {
            switch self {
            case .emptyAudio: return "No audio was recorded."
            case .apiError(let msg): return "Whisper API error: \(msg)"
            }
        }
    }

    private struct WhisperResponse: Decodable {
        let text: String
    }
}
