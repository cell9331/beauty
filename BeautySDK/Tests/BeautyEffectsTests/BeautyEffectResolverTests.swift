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

    func testPublicResolverKeepsBasicSkinActiveWithoutFaceGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(skinSmoothing: 0.4, skinWhitening: 0.3)
        )

        XCTAssertTrue(plan.activeDomains.contains(.skin))
        XCTAssertFalse(plan.skippedDomains.contains(.skin))
        XCTAssertFalse(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
        XCTAssertEqual(plan.metrics["beauty.effects.activeCount"], 1)
    }

    func testPublicResolverDoesNotActivateGeometryDomainsWithoutFaceGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                faceSlim: 1,
                eyeSize: 1,
                noseSlim: 1,
                mouthSize: 1,
                lipColor: 1
            )
        )

        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertFalse(plan.activeDomains.contains(.faceShape))
        XCTAssertFalse(plan.activeDomains.contains(.eyes))
        XCTAssertFalse(plan.activeDomains.contains(.nose))
        XCTAssertFalse(plan.activeDomains.contains(.mouth))
        XCTAssertFalse(plan.activeDomains.contains(.lipColor))
        XCTAssertTrue(plan.skippedDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth, .lipColor]))
        XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
        assertRedacted(plan)
    }

    func testInternalNoFaceResolverSkipsBasicSkinWithRedactedWarning() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(skinSmoothing: 0.4, skinWhitening: 0.3),
            faceGeometry: nil
        )

        XCTAssertFalse(plan.activeDomains.contains(.skin))
        XCTAssertTrue(plan.skippedDomains.contains(.skin))
        XCTAssertTrue(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
        XCTAssertEqual(plan.metrics["beauty.effects.skippedFaceDomains"], 1)

        let combined = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")
        for forbidden in ["/private/var", "NSError", "VNFaceObservation", "bounding", "landmark", "rawPresetJson"] {
            XCTAssertFalse(combined.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
        }
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

    private func assertRedacted(_ plan: BeautyEffectPlan, file: StaticString = #filePath, line: UInt = #line) {
        let metadata = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")

        for forbidden in ["landmark", "control point", "controlPoint", "bounding", "VNFaceObservation", "/private/var", "image bytes", "SIMD", "[0."] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)", file: file, line: line)
        }
    }
}
