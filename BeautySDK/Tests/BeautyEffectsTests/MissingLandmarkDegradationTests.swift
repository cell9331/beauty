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
        XCTAssertTrue(plan.warnings.contains { $0.code == "eye_landmarks_missing" })
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
        XCTAssertTrue(plan.warnings.contains { $0.code == "nose_landmarks_missing" })
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
}
