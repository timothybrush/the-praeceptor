import Foundation
@testable import Praeceptor

enum TestFixtures {
    // MARK: — Audio

    static func wavData(seconds: Double = 0.1) -> Data {
        // Minimal valid WAV header + silence
        let sampleRate: Int32 = 16000
        let channels: Int16 = 1
        let bitsPerSample: Int16 = 16
        let numSamples = Int(Double(sampleRate) * seconds)
        let dataSize = numSamples * Int(channels) * Int(bitsPerSample / 8)
        let fileSize = 36 + dataSize

        var data = Data()
        func append(_ string: String) { data.append(contentsOf: string.utf8) }
        func append<T: FixedWidthInteger>(_ value: T) {
            var v = value.littleEndian
            data.append(contentsOf: withUnsafeBytes(of: &v, Array.init))
        }

        append("RIFF")
        append(Int32(fileSize))
        append("WAVE")
        append("fmt ")
        append(Int32(16))
        append(Int16(1))
        append(channels)
        append(sampleRate)
        append(Int32(sampleRate * Int32(channels) * Int32(bitsPerSample) / 8))
        append(Int16(Int(channels) * Int(bitsPerSample) / 8))
        append(bitsPerSample)
        append("data")
        append(Int32(dataSize))
        data.append(contentsOf: [UInt8](repeating: 0, count: dataSize))
        return data
    }

    // MARK: — Whisper

    static func whisperSuccessResponse(text: String = "Hello from Whisper") -> Data {
        try! JSONEncoder().encode(["text": text])
    }

    // MARK: — Claude SSE

    static func claudeSSEResponse(chunks: [String]) -> Data {
        var lines: [String] = []
        for chunk in chunks {
            let escaped = chunk.replacingOccurrences(of: "\"", with: "\\\"")
            lines.append("data: {\"type\":\"content_block_delta\",\"index\":0,\"delta\":{\"type\":\"text_delta\",\"text\":\"\(escaped)\"}}")
            lines.append("")
        }
        lines.append("data: {\"type\":\"message_stop\"}")
        lines.append("")
        return lines.joined(separator: "\n").data(using: .utf8)!
    }

    // MARK: — TTS

    static let mp3Data = Data([0xFF, 0xFB, 0x90, 0x00]) // Minimal mp3 header bytes

    // MARK: — KnowingLayer

    static func knownLayer() -> KnowingLayer {
        KnowingLayer(
            updated: Date(),
            person: KnowingLayer.PersonContext(
                name: "Marcus",
                primaryMission: "Build B2B SaaS from consulting relationships",
                sovereigntyStage: "Consulting covers expenses",
                originalThesis: "Productize the retainer"
            ),
            currentState: KnowingLayer.CurrentState(
                activeProject: "Pitch deck",
                activePhase: "Refinement",
                whatTheyAreDoing: "Polishing financial model",
                whatTheySaidTheyWouldDo: "Send deck to two contacts"
            ),
            lastThreeSessions: [],
            openTensions: ["Deck refinement is avoidance"],
            thesisDrift: nil,
            hisDirective: "Send the deck this week.",
            patternsHeSees: [],
            nextSessionIntent: "Open with: did you send it?"
        )
    }
}
