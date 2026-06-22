import XCTest
import BeautyCore
@testable import BeautyEffects

final class BeautyEffectResolverTests: XCTestCase {
    func testDefaultParametersResolveToNoActiveDomains() {
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters())

        XCTAssertTrue(plan.activeDomains.isEmpty)
        XCTAssertTrue(plan.skippedDomains.isEmpty)
        XCTAssertTrue(plan.warnings.isEmpty)
        XCTAssertEqual(plan.metrics["beauty.effects.activeCount"], 0)
    }

    func testSkinValuesKeepPublicRangeButResolveToCappedEffectiveStrengths() {
        let parameters = BeautyParameters(
            skinSmoothing: 1,
            skinWhitening: 1,
            skinRosy: 1,
            skinSharpen: 1
        )

        XCTAssertEqual(parameters.normalized().skinSmoothing, 1)

        let plan = BeautyEffectResolver.resolve(parameters: parameters)

        XCTAssertTrue(plan.activeDomains.contains(.skin))
        XCTAssertEqual(plan.effectiveStrengths.skinSmoothing, 0.60, accuracy: 0.0001)
        XCTAssertEqual(plan.effectiveStrengths.skinWhitening, 0.50, accuracy: 0.0001)
        XCTAssertEqual(plan.effectiveStrengths.skinRosy, 0.40, accuracy: 0.0001)
        XCTAssertEqual(plan.effectiveStrengths.skinSharpen, 0.40, accuracy: 0.0001)
        XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
        XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 4)
    }

    func testNonZeroSkinColorAndFilterValuesActivateExpectedDomains() {
        let parameters = BeautyParameters(
            skinWhitening: 0.35,
            brightness: 0.15,
            contrast: -0.10,
            filterId: "soft_clean",
            filterIntensity: 0.50
        )

        let plan = BeautyEffectResolver.resolve(parameters: parameters)

        XCTAssertEqual(plan.activeDomains, [.skin, .color, .filter])
        XCTAssertEqual(plan.metrics["beauty.effects.activeCount"], 3)
    }

    func testWarningsAndMetricsDoNotExposeSensitiveTerms() {
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(skinSmoothing: 1))
        let combined = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")

        for forbidden in ["/private/var", "NSError", "VNFaceObservation", "bounding", "landmark", "rawPresetJson"] {
            XCTAssertFalse(combined.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
        }
    }
}
