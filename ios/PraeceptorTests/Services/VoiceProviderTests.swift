import XCTest
@testable import Praeceptor

final class VoiceProviderTests: XCTestCase {

    // MARK: — TranscriptionProvider

    func testTranscriptionProviderRawValues() {
        XCTAssertEqual(TranscriptionProvider.apple.rawValue,  "apple")
        XCTAssertEqual(TranscriptionProvider.openAI.rawValue, "openAI")
    }

    func testTranscriptionProviderHasTwoCases() {
        XCTAssertEqual(TranscriptionProvider.allCases.count, 2)
    }

    func testTranscriptionProviderRoundTripsFromRawValue() {
        XCTAssertEqual(TranscriptionProvider(rawValue: "apple"),  .apple)
        XCTAssertEqual(TranscriptionProvider(rawValue: "openAI"), .openAI)
        XCTAssertNil(TranscriptionProvider(rawValue: "unknown"))
    }

    // MARK: — TTSProvider

    func testTTSProviderRawValues() {
        XCTAssertEqual(TTSProvider.apple.rawValue,       "apple")
        XCTAssertEqual(TTSProvider.openAI.rawValue,      "openAI")
        XCTAssertEqual(TTSProvider.elevenLabs.rawValue,  "elevenLabs")
    }

    func testTTSProviderHasThreeCases() {
        XCTAssertEqual(TTSProvider.allCases.count, 3)
    }

    func testTTSProviderRoundTripsFromRawValue() {
        XCTAssertEqual(TTSProvider(rawValue: "apple"),      .apple)
        XCTAssertEqual(TTSProvider(rawValue: "openAI"),     .openAI)
        XCTAssertEqual(TTSProvider(rawValue: "elevenLabs"), .elevenLabs)
        XCTAssertNil(TTSProvider(rawValue: "unknown"))
    }

    // MARK: — Codable roundtrip

    func testTranscriptionProviderEncodesAndDecodes() throws {
        let encoded = try JSONEncoder().encode(TranscriptionProvider.openAI)
        let decoded = try JSONDecoder().decode(TranscriptionProvider.self, from: encoded)
        XCTAssertEqual(decoded, .openAI)
    }

    func testTTSProviderEncodesAndDecodes() throws {
        for provider in TTSProvider.allCases {
            let encoded = try JSONEncoder().encode(provider)
            let decoded = try JSONDecoder().decode(TTSProvider.self, from: encoded)
            XCTAssertEqual(decoded, provider)
        }
    }
}
