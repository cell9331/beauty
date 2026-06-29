import XCTest
import BeautyCore
@testable import BeautyEffects

final class MissingLandmarkDegradationTests: XCTestCase {
    func testMissingOneEyeGroupSkipsOnlyEyesAndKeepsSafeDomainsActive() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                eyeSize: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            ),
            faceGeometry: .missingLeftEye
        )

        XCTAssertFalse(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertEqual(plan.skippedDomains, [.eyes])
        XCTAssertTrue(plan.warnings.contains { $0.code == "eye_inputs_missing" })
    }

    func testEyeDegradationMetadataIsRedacted() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(eyeSize: 1),
            faceGeometry: .missingLeftEye
        )
        let combined = (
            plan.warnings.map { "\($0.code) \($0.message)" } +
            Array(plan.metrics.keys)
        ).joined(separator: " ")

        for forbidden in ["/private/var", "VNFaceObservation", "bounding", "CoordinateRect", "image bytes", "[0.", "SIMD"] {
            XCTAssertFalse(combined.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
        }
    }

    func testMissingStaleAndReusedGeometryMetadataStayRedacted() {
        let plans = [
            BeautyEffectResolver.resolve(
                parameters: BeautyParameters(eyeSize: 1),
                faceGeometry: .missingLeftEye
            ),
            BeautyEffectResolver.resolve(
                parameters: BeautyParameters(noseSlim: 1),
                faceGeometry: .missingNose
            ),
            BeautyEffectResolver.resolve(
                parameters: BeautyParameters(mouthSize: 1, lipColor: 1),
                faceGeometry: .missingMouth
            ),
            BeautyEffectResolver.resolve(
                parameters: BeautyParameters(faceSlim: 1, eyeSize: 1, noseSlim: 1, mouthSize: 1),
                faceGeometry: .stale
            ),
            BeautyEffectResolver.resolve(
                parameters: BeautyParameters(faceSlim: 1, eyeSize: 1, noseSlim: 1, mouthSize: 1),
                faceGeometry: .reused
            )
        ]

        for plan in plans {
            assertRedacted(plan)
        }
    }

    func testMissingNoseSkipsOnlyNoseAndKeepsEyeAndSafeDomainsActive() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                eyeSize: 0.2,
                noseSlim: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            ),
            faceGeometry: .missingNose
        )

        XCTAssertFalse(plan.activeDomains.contains(.nose))
        XCTAssertTrue(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertEqual(plan.skippedDomains, [.nose])
        XCTAssertTrue(plan.warnings.contains { $0.code == "nose_inputs_missing" })
    }

    func testNoseGeometryProducesDeterministicProxyEvidenceAndCapMetadata() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(noseSlim: 1, noseTipSize: 1),
            faceGeometry: .fixture
        )
        let input: [UInt8] = [
            30, 40, 50, 255,
            90, 100, 110, 255
        ]

        let output = BeautyGeometryEffectPipeline.applyMVPProxy(toBGRA: input, plan: plan, face: .fixture)

        XCTAssertTrue(plan.activeDomains.contains(.nose))
        XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        XCTAssertNotEqual(output, input)
    }

    func testReusedLandmarksReduceEyeAndNoseGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(eyeSize: 1, noseSlim: 1),
            faceGeometry: .reused
        )

        XCTAssertTrue(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.activeDomains.contains(.nose))
        XCTAssertLessThan(plan.effectiveStrengths.eyeSize, BeautySafetyCaps.eyeSize)
        XCTAssertLessThan(plan.effectiveStrengths.noseSlim, BeautySafetyCaps.noseSlim)
        XCTAssertTrue(plan.warnings.contains { $0.code == "geometry_stale_reduced" })
    }

    func testStaleLandmarksSkipStrongEyeAndNoseGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(brightness: 0.2, eyeSize: 1, noseSlim: 1),
            faceGeometry: .stale
        )

        XCTAssertFalse(plan.activeDomains.contains(.eyes))
        XCTAssertFalse(plan.activeDomains.contains(.nose))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.skippedDomains.contains(.eyes))
        XCTAssertTrue(plan.skippedDomains.contains(.nose))
        XCTAssertTrue(plan.warnings.contains { $0.code == "geometry_stale_skipped" })
    }

    func testMissingMouthSkipsOnlyMouthAndKeepsEyeNoseAndSafeDomainsActive() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                eyeSize: 0.2,
                noseSlim: 0.2,
                mouthSize: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            ),
            faceGeometry: .missingMouth
        )

        XCTAssertFalse(plan.activeDomains.contains(.mouth))
        XCTAssertTrue(plan.activeDomains.contains(.eyes))
        XCTAssertTrue(plan.activeDomains.contains(.nose))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertEqual(plan.skippedDomains, [.mouth])
        XCTAssertTrue(plan.warnings.contains { $0.code == "mouth_inputs_missing" })
    }

    func testReusedLandmarksReduceMouthGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(mouthSize: 1, mouthWidth: 1, smile: 1),
            faceGeometry: .reused
        )

        XCTAssertTrue(plan.activeDomains.contains(.mouth))
        XCTAssertLessThan(plan.effectiveStrengths.mouthSize, BeautySafetyCaps.mouthSize)
        XCTAssertLessThan(plan.effectiveStrengths.mouthWidth, BeautySafetyCaps.mouthWidth)
        XCTAssertLessThan(plan.effectiveStrengths.smile, BeautySafetyCaps.smile)
        XCTAssertTrue(plan.warnings.contains { $0.code == "geometry_stale_reduced" })
    }

    func testStaleLandmarksSkipStrongMouthGeometry() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(brightness: 0.2, mouthSize: 1, mouthWidth: 1, smile: 1),
            faceGeometry: .stale
        )

        XCTAssertFalse(plan.activeDomains.contains(.mouth))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.skippedDomains.contains(.mouth))
        XCTAssertTrue(plan.warnings.contains { $0.code == "geometry_stale_skipped" })
    }

    func testMissingMouthSkipsLipColorAndKeepsSafeDomainsActive() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                lipColor: 1,
                filterId: "warm_light",
                filterIntensity: 0.5
            ),
            faceGeometry: .missingMouth
        )

        XCTAssertFalse(plan.activeDomains.contains(.lipColor))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertTrue(plan.skippedDomains.contains(.lipColor))
        XCTAssertTrue(plan.warnings.contains { $0.code == "lip_inputs_missing" })
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
