import XCTest
@testable import Praeceptor

final class SystemPromptBuilderTests: XCTestCase {

    func testBuildAlwaysIncludesCharacterLayer() {
        let prompt = SystemPromptBuilder.build(
            knowingLayer: nil,
            sessionHistory: [],
            timeOfDay: .noon
        )
        XCTAssertTrue(prompt.contains("You are The Praeceptor"))
        XCTAssertTrue(prompt.contains("Rule 0"))
    }

    func testBuildIncludesMorningModifier() {
        let prompt = SystemPromptBuilder.build(
            knowingLayer: nil,
            sessionHistory: [],
            timeOfDay: .morning
        )
        XCTAssertTrue(prompt.contains("morning"))
    }

    func testBuildIncludesNoonModifier() {
        let prompt = SystemPromptBuilder.build(
            knowingLayer: nil,
            sessionHistory: [],
            timeOfDay: .noon
        )
        XCTAssertTrue(prompt.contains("midday") || prompt.contains("noon") || prompt.contains("execution"))
    }

    func testBuildIncludesNightModifier() {
        let prompt = SystemPromptBuilder.build(
            knowingLayer: nil,
            sessionHistory: [],
            timeOfDay: .night
        )
        XCTAssertTrue(prompt.contains("evening") || prompt.contains("reflective"))
    }

    func testBuildIncludesKnowingContextWhenPresent() {
        let layer = TestFixtures.knownLayer()
        let prompt = SystemPromptBuilder.build(
            knowingLayer: layer,
            sessionHistory: [],
            timeOfDay: .noon
        )
        XCTAssertTrue(prompt.contains("Marcus"))
        XCTAssertTrue(prompt.contains("Who You're Talking To"))
    }

    func testBuildOmitsKnowingContextWhenNil() {
        let prompt = SystemPromptBuilder.build(
            knowingLayer: nil,
            sessionHistory: [],
            timeOfDay: .noon
        )
        XCTAssertFalse(prompt.contains("Who You're Talking To"))
    }

    func testBuildCharacterLayerIsConsistentAcrossCalls() {
        let p1 = SystemPromptBuilder.build(knowingLayer: nil, sessionHistory: [], timeOfDay: .morning)
        let p2 = SystemPromptBuilder.build(knowingLayer: nil, sessionHistory: [], timeOfDay: .morning)
        XCTAssertEqual(p1, p2)
    }

    func testBuildPromptsAreDifferentByTimeOfDay() {
        let morning = SystemPromptBuilder.build(knowingLayer: nil, sessionHistory: [], timeOfDay: .morning)
        let night = SystemPromptBuilder.build(knowingLayer: nil, sessionHistory: [], timeOfDay: .night)
        XCTAssertNotEqual(morning, night)
    }

    func testCharacterLayerIsNonEmpty() {
        XCTAssertFalse(SystemPromptBuilder.characterLayer.isEmpty)
        XCTAssertGreaterThan(SystemPromptBuilder.characterLayer.count, 500)
    }
}
