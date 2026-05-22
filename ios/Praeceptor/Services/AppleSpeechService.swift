import Foundation
import Speech

struct AppleSpeechService {
    func transcribe(audioURL: URL) async throws -> String {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard status == .authorized else { throw SpeechError.notAuthorized }

        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            throw SpeechError.unavailable
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.requiresOnDeviceRecognition = false

        return try await withCheckedThrowingContinuation { continuation in
            let holder = ContinuationHolder(continuation)
            recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    holder.resume(throwing: error)
                } else if let result, result.isFinal {
                    holder.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }

    enum SpeechError: Error, LocalizedError {
        case notAuthorized
        case unavailable

        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "Speech recognition was denied. Enable it in Settings → Privacy → Speech Recognition."
            case .unavailable:
                return "Speech recognition is not available on this device."
            }
        }
    }
}

// Thread-safe continuation wrapper — prevents double-resume from partial result callbacks.
private final class ContinuationHolder<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<T, any Error>?

    init(_ continuation: CheckedContinuation<T, any Error>) {
        self.continuation = continuation
    }

    func resume(returning value: T) {
        lock.withLock {
            let c = continuation; continuation = nil
            c?.resume(returning: value)
        }
    }

    func resume(throwing error: any Error) {
        lock.withLock {
            let c = continuation; continuation = nil
            c?.resume(throwing: error)
        }
    }
}
