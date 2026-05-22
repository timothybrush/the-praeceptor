import Foundation

enum TranscriptionProvider: String, CaseIterable, Codable {
    case apple
    case openAI
}

enum TTSProvider: String, CaseIterable, Codable {
    case apple
    case openAI
    case elevenLabs
}
