import BeautyCore
import BeautyDetection
import XCTest
@testable import BeautyEffects

final class BeautyStillImageGeometryStageTests: XCTestCase {
    func testSharedDiagnosticsBoundsCompositionCountersWithoutOverflowOrRawFields() {
        let summary = BeautyLocalRetouchCompositionSummary(
            acceptedUnitCount: Int.max, rejectedUnitCount: Int.max,
            ownedPixelCount: Int.max, changedPixelCount: Int.max,
            collisionPixelCount: Int.max
        )
        for (width, height, expected) in [(2, 3, 6),
            (Int.max, 2, BeautyConfiguration.defaultMaximumInputPixelCount)] {
            let counters = BeautyBackendDiagnostics(
                width: width, height: height, compositionSummary: summary
            )
            XCTAssertEqual(counters.unitCount, expected)
            XCTAssertEqual(counters.failureCount, expected)
            XCTAssertEqual(counters.collisionCount, expected)
            XCTAssertEqual(counters.changedPixelCount, expected)
            XCTAssertTrue(counters.preservesAlpha)
            XCTAssertTrue(counters.preservesExtent)
            XCTAssertEqual(Mirror(reflecting: counters).children.count, 8)
        }
    }

    func testMissingFaceCannotAuthorizeGeometryOrTranslation() {
        let pixels = CPUReferenceFixtureFactory.geometryPattern(width: 160, height: 192).rgba8
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 0.15, wholeFaceXPosition: 0.05),
            faceGeometry: .fixture
        )
        XCTAssertFalse(BeautyGeometryEffectPipeline.controlPoints(for: plan, face: .fixture).isEmpty)
        let stage = BeautyStillImageGeometryStage(
            sourceRGBA: pixels, width: 160, height: 192, plan: plan, face: nil
        )
        XCTAssertFalse(stage.usesDenseMap)
        XCTAssertTrue(stage.controlPoints.isEmpty)
        XCTAssertEqual(stage.sourceRGBA, pixels)
        XCTAssertEqual(stage.applyingDenseMap(to: pixels), pixels)
        XCTAssertEqual(stage.applyingTranslation(to: pixels), pixels)
    }

    func testRejectedSourceWorkCannotRestoreProxyPointsOrRemoveAdmittedSibling() throws {
        // Uniform skin has no registered hair cap, lip or isolated silhouette.
        let skin: [UInt8] = [170, 125, 110, 255]
        let source = Array(repeating: skin, count: 160 * 192).flatMap { $0 }
        for face in [FaceGeometry.fixture, try denseFace()] {
            let sibling = BeautyEffectResolver.resolve(
                parameters: BeautyParameters(faceSlim: 0.15), faceGeometry: face
            )
            let mixed = BeautyEffectResolver.resolve(
                parameters: BeautyParameters(
                    faceSlim: 0.15, faceContourSmooth: 0.05,
                    wholeFaceYPosition: 0.05, wholeFaceXPosition: -0.05,
                    foreheadHeight: 0.05, philtrumLength: -0.05, headWrap: 0.05,
                    hairlineHeight: -0.05, doubleChinReduction: 0.05,
                    doubleChinReductionPro: 0.05
                ), faceGeometry: face
            )
            let expected = BeautyStillImageGeometryStage(
                sourceRGBA: source, width: 160, height: 192, plan: sibling, face: face
            )
            let actual = BeautyStillImageGeometryStage(
                sourceRGBA: source, width: 160, height: 192, plan: mixed, face: face
            )
            XCTAssertFalse(expected.controlPoints.isEmpty)
            XCTAssertGreaterThan(
                BeautyGeometryEffectPipeline.controlPoints(for: mixed, face: face).count,
                expected.controlPoints.count
            )
            XCTAssertEqual(actual.sourceRGBA, source)
            XCTAssertEqual(actual.controlPoints, expected.controlPoints)
            let warped = actual.applyingDenseMap(to: actual.sourceRGBA)
            XCTAssertEqual(actual.applyingTranslation(to: warped), warped)
        }
    }

    func testRejectedDensePosePreservesSuppliedColorRasterAndLaterRequestRecovers() throws {
        let source = CPUReferenceFixtureFactory.geometryPattern(width: 160, height: 192).rgba8
        let backFacing = try denseFace(matrix: [
            -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1
        ])
        let face = try denseFace()
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(faceSlim: 0.15), faceGeometry: face
        )
        let rejected = BeautyStillImageGeometryStage(
            sourceRGBA: source, width: 160, height: 192, plan: plan, face: backFacing
        )
        XCTAssertTrue(rejected.usesDenseMap)
        XCTAssertFalse(rejected.controlPoints.isEmpty)
        XCTAssertEqual(rejected.applyingDenseMap(to: source), source)

        let recovered = BeautyStillImageGeometryStage(
            sourceRGBA: source, width: 160, height: 192, plan: plan, face: face
        )
        let output = recovered.applyingDenseMap(to: recovered.sourceRGBA)
        XCTAssertNotEqual(output, source)
        XCTAssertEqual(output, recovered.applyingDenseMap(to: recovered.sourceRGBA))
        XCTAssertEqual(rejected.applyingDenseMap(to: source), source)
        for y in 0..<192 {
            for x in 0..<160 {
                let offset = (y * 160 + x) * 4
                XCTAssertEqual(output[offset + 3], source[offset + 3])
                if x == 0 || y == 0 || x == 159 || y == 191 {
                    XCTAssertTrue(output[offset..<(offset + 4)].elementsEqual(source[offset..<(offset + 4)]))
                }
            }
        }
    }

    private func denseFace(matrix: [Float]? = nil) throws -> FaceGeometry {
        let base = FaceGeometry.fixture
        var points = (0..<478).map { i in
            SIMD3<Float>(0.30 + Float(i % 23) / 60, 0.20 + Float(i / 23) / 40, 0)
        }
        for (i, index) in MediaPipeFaceTopology.oval.enumerated() {
            let angle = Double(i) * 2 * Double.pi / Double(MediaPipeFaceTopology.oval.count)
            points[index] = SIMD3<Float>(0.5 + Float(cos(angle)) * 0.2, 0.5 + Float(sin(angle)) * 0.3, 0)
        }
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points, facialTransformation: matrix))
        return FaceGeometry(
            bounds: base.bounds, faceContour: base.faceContour,
            leftEye: base.leftEye, rightEye: base.rightEye,
            nose: base.nose, noseRoot: base.noseRoot, noseTip: base.noseTip,
            outerLips: base.outerLips, upperLips: base.upperLips,
            lowerLips: base.lowerLips, innerLips: base.innerLips,
            denseSupport: BeautyDenseFaceSupport(mesh: mesh)
        )
    }
}
