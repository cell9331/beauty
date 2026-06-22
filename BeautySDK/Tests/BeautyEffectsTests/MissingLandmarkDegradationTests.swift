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
}
