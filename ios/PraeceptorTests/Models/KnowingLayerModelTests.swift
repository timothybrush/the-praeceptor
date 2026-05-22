import XCTest
@testable import Praeceptor

final class KnowingLayerModelTests: XCTestCase {

    func testEmptyReturnsValidInstance() {
        let layer = KnowingLayer.empty
        XCTAssertEqual(layer.person.name, "")
        XCTAssertEqual(layer.person.primaryMission, "")
        XCTAssertTrue(layer.lastThreeSessions.isEmpty)
        XCTAssertTrue(layer.openTensions.isEmpty)
        XCTAssertNil(layer.thesisDrift)
        XCTAssertNil(layer.hisDirective)
    }

    func testEncodingAndDecodingRoundTrip() throws {
        let original = TestFixtures.knownLayer()
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(KnowingLayer.self, from: encoded)

        XCTAssertEqual(decoded.person.name, original.person.name)
        XCTAssertEqual(decoded.person.primaryMission, original.person.primaryMission)
        XCTAssertEqual(decoded.currentState.whatTheyAreDoing, original.currentState.whatTheyAreDoing)
        XCTAssertEqual(decoded.hisDirective, original.hisDirective)
    }

    func testToCompressedContextIncludesPerson() {
        let layer = TestFixtures.knownLayer()
        let context = layer.toCompressedContext()
        XCTAssertTrue(context.contains("Marcus"))
        XCTAssertTrue(context.contains("B2B SaaS"))
    }

    func testToCompressedContextIncludesCurrentState() {
        let layer = TestFixtures.knownLayer()
        let context = layer.toCompressedContext()
        XCTAssertTrue(context.contains("Polishing financial model"))
        XCTAssertTrue(context.contains("Send deck to two contacts"))
    }

    func testToCompressedContextIncludesOpenTensions() {
        let layer = TestFixtures.knownLayer()
        let context = layer.toCompressedContext()
        XCTAssertTrue(context.contains("Deck refinement is avoidance"))
    }

    func testToCompressedContextIncludesDirective() {
        let layer = TestFixtures.knownLayer()
        let context = layer.toCompressedContext()
        XCTAssertTrue(context.contains("Send the deck this week."))
    }

    func testToCompressedContextOmitsNilThesisDrift() {
        var layer = TestFixtures.knownLayer()
        layer.thesisDrift = nil
        let context = layer.toCompressedContext()
        XCTAssertFalse(context.contains("Thesis drift"))
    }

    func testToCompressedContextIncludesThesisDriftWhenPresent() {
        var layer = TestFixtures.knownLayer()
        layer.thesisDrift = "Moved from productized retainer to platform play"
        let context = layer.toCompressedContext()
        XCTAssertTrue(context.contains("Thesis drift"))
        XCTAssertTrue(context.contains("platform play"))
    }

    func testToCompressedContextHandlesEmptyOptionals() {
        let layer = KnowingLayer.empty
        let context = layer.toCompressedContext()
        XCTAssertFalse(context.isEmpty)
        XCTAssertFalse(context.contains("His directive"))
        XCTAssertFalse(context.contains("Thesis drift"))
    }

    func testLastThreeSessionsLimitEnforced() {
        var layer = TestFixtures.knownLayer()
        layer.lastThreeSessions = [
            KnowingLayer.SessionSummary(date: "2026-05-01", whatSurfaced: "session-alpha-unique", whatWasDecided: nil, whatWasAvoided: nil),
            KnowingLayer.SessionSummary(date: "2026-05-08", whatSurfaced: "session-beta-unique", whatWasDecided: nil, whatWasAvoided: nil),
            KnowingLayer.SessionSummary(date: "2026-05-15", whatSurfaced: "session-gamma-unique", whatWasDecided: nil, whatWasAvoided: nil),
            KnowingLayer.SessionSummary(date: "2026-05-22", whatSurfaced: "session-delta-unique", whatWasDecided: nil, whatWasAvoided: nil)
        ]
        let context = layer.toCompressedContext()
        // prefix(3) means only the first 3 sessions appear
        XCTAssertTrue(context.contains("session-alpha-unique"))
        XCTAssertTrue(context.contains("session-beta-unique"))
        XCTAssertTrue(context.contains("session-gamma-unique"))
        XCTAssertFalse(context.contains("session-delta-unique"))
    }
}
