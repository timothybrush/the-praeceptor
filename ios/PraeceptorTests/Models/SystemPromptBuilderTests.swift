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

    func testVoiceLayerContainsStoriesSection() {
        XCTAssertTrue(SystemPromptBuilder.voiceLayer.contains("Stories You Carry"))
        XCTAssertGreaterThan(SystemPromptBuilder.voiceLayer.count, 500)
    }

    func testReferenceLayerContainsAllSixteenComposites() {
        let layer = SystemPromptBuilder.referenceLayer
        let figures = ["Grove", "Munger", "Campbell", "Walsh", "Marshall", "Ohno",
                       "Seneca", "Aurelius", "Naval", "Scott", "Drucker",
                       "Kahneman", "Lencioni", "Catmull", "Rogers", "Greene"]
        for figure in figures {
            XCTAssertTrue(layer.contains("**\(figure):**"), "Missing mechanism for \(figure)")
        }
    }

    func testBuildIncludesVoiceAndReferenceLayers() {
        let prompt = SystemPromptBuilder.build(knowingLayer: nil, sessionHistory: [], timeOfDay: .noon)
        XCTAssertTrue(prompt.contains("Stories You Carry"))
        XCTAssertTrue(prompt.contains("Composite Mechanisms"))
    }

    func testPromptRemainsUnderTokenBudget() {
        let prompt = SystemPromptBuilder.build(knowingLayer: nil, sessionHistory: [], timeOfDay: .noon)
        // Rough token estimate: ~4 chars per token. Budget: voiceLayer + referenceLayer < 4000 tokens.
        let combinedLength = SystemPromptBuilder.voiceLayer.count + SystemPromptBuilder.referenceLayer.count
        XCTAssertLessThan(combinedLength / 4, 4000, "voiceLayer + referenceLayer exceeds token budget")
        XCTAssertGreaterThan(prompt.count, 1000)
    }
}
