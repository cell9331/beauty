import XCTest
import BeautyCore
@testable import BeautyEffects

final class GeometryConflictResolverTests: XCTestCase {
    func testCombinedHighFaceShapeStrengthsAreWeakenedBelowIndependentCappedSum() {
        let independent = strengths(faceSlim: 1, faceSmall: 1, faceVShape: 1, jawSlim: 1, chinLength: 1)
        let resolved = GeometryConflictResolver().resolve(strengths: independent)

        XCTAssertLessThan(resolved.strengths.faceShapeTotal, independent.faceShapeTotal)
        XCTAssertTrue(resolved.warnings.contains { $0.code == "combined_geometry_weakened" })
    }

    func testResolverReportsGeometryPointAndCapMetricsForFaceShapeContext() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 1, faceSmall: 1, faceVShape: 1, jawSlim: 1, chinLength: 1),
            faceGeometry: .fixture
        )

        XCTAssertTrue(plan.activeDomains.contains(.faceShape))
        XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        XCTAssertGreaterThanOrEqual(plan.metrics["beauty.effects.cappedCount"] ?? 0, 5)
        XCTAssertTrue(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
    }

    func testGeometryPipelineProducesDeterministicRenderPlanEvidence() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 1, chinLength: 1),
            faceGeometry: .fixture
        )

        let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: .fixture)

        XCTAssertFalse(points.isEmpty)
        XCTAssertEqual(points, BeautyGeometryEffectPipeline.controlPoints(for: plan, face: .fixture))
    }

    func testNoFaceSkipsFaceShapeButKeepsColorAndFilterDomains() {
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(
                brightness: 0.2,
                faceSlim: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            ),
            faceGeometry: nil
        )

        XCTAssertFalse(plan.activeDomains.contains(.faceShape))
        XCTAssertTrue(plan.activeDomains.contains(.color))
        XCTAssertTrue(plan.activeDomains.contains(.filter))
        XCTAssertTrue(plan.skippedDomains.contains(.faceShape))
        XCTAssertTrue(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
    }

    private func strengths(
        faceSlim: Float = 0,
        faceSmall: Float = 0,
        faceVShape: Float = 0,
        jawSlim: Float = 0,
        chinLength: Float = 0
    ) -> BeautyEffectiveStrengths {
        var strengths = BeautyEffectiveStrengths()
        strengths.faceSlim = min(faceSlim, BeautySafetyCaps.faceSlim)
        strengths.faceSmall = min(faceSmall, BeautySafetyCaps.faceSmall)
        strengths.faceVShape = min(faceVShape, BeautySafetyCaps.faceVShape)
        strengths.jawSlim = min(jawSlim, BeautySafetyCaps.jawSlim)
        strengths.chinLength = min(max(chinLength, -BeautySafetyCaps.chinLength), BeautySafetyCaps.chinLength)
        return strengths
    }
}

private extension BeautyEffectiveStrengths {
    var faceShapeTotal: Float {
        faceSlim + faceSmall + faceVShape + jawSlim + abs(chinLength)
    }
}
