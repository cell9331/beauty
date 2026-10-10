import BeautyCore
import BeautyDetection
import XCTest
@testable import BeautyEffects

final class BeautyDenseCombinationTests: XCTestCase {
    func testDenseMappedFieldsKeepIndependentSignedStrengthsWhileLegacyStillLimits() {
        var input = BeautyEffectiveStrengths()
        input.faceSlim = 0.6
        input.innerCornerOpen = 0.25
        input.noseWingSlim = 0.35
        input.mouthWidth = -0.35
        let dense = GeometryConflictResolver().resolve(strengths: input, usesDenseMap: true)
        XCTAssertEqual(dense.strengths, input)
        XCTAssertTrue(dense.warnings.isEmpty)
        XCTAssertEqual(dense.metrics["beauty.effects.denseMapCombination"], 1)
        let legacy = GeometryConflictResolver().resolve(strengths: input)
        XCTAssertLessThan(legacy.strengths.faceSlim, input.faceSlim)
        XCTAssertLessThan(abs(legacy.strengths.mouthWidth), abs(input.mouthWidth))
        XCTAssertEqual(legacy.strengths.mouthWidth.sign, .minus)
        XCTAssertEqual(legacy.warnings.map(\.code), ["combined_geometry_weakened"])
    }

    func testSourceRasterBudgetRemainsIndependentOfMappedEyeNoseAndMouthFields() {
        var input = BeautyEffectiveStrengths()
        input.faceSlim = 0.6
        input.wholeFaceYPosition = -0.25
        input.wholeFaceXPosition = 0.25
        input.foreheadHeight = -0.25
        input.philtrumLength = 0.25
        input.headWrap = 0.25
        input.hairlineHeight = 0.25
        input.doubleChinReduction = 0.25
        input.doubleChinReductionPro = 0.25
        input.faceContourSmooth = 0.25
        input.innerCornerOpen = 0.25
        input.noseWingSlim = 0.35
        input.mouthWidth = -0.35
        let dense = GeometryConflictResolver().resolve(strengths: input, usesDenseMap: true)
        XCTAssertEqual(dense.strengths.faceSlim, input.faceSlim)
        XCTAssertEqual(dense.strengths.innerCornerOpen, input.innerCornerOpen)
        XCTAssertEqual(dense.strengths.noseWingSlim, input.noseWingSlim)
        XCTAssertEqual(dense.strengths.mouthWidth, input.mouthWidth)
        let keys: [KeyPath<BeautyEffectiveStrengths, Float>] = [
            \.wholeFaceYPosition, \.wholeFaceXPosition, \.foreheadHeight,
            \.philtrumLength, \.headWrap, \.hairlineHeight, \.doubleChinReduction,
            \.doubleChinReductionPro, \.faceContourSmooth]
        for key in keys {
            XCTAssertEqual(dense.strengths[keyPath: key], input[keyPath: key] / 2.25, accuracy: 0.000001)
        }
        XCTAssertEqual(dense.warnings.map(\.code), ["combined_geometry_weakened"])
        XCTAssertEqual(dense.metrics["beauty.effects.weakenedCount"], 9)
    }

    func testResolvedDenseHighCombinationHasRealBoundedRepeatablePixelsAndProtectedBorder() throws {
        let face = try faceWithMesh()
        let requested = BeautyParameters(faceSlim: 0.6, faceSmall: 0.45, faceVShape: 0.35,
                                         jawSlim: 0.35, chinLength: -0.35, noseWingSlim: 0.35,
                                         mouthWidth: -0.35)
        let plan = BeautyEffectResolver.resolve(parameters: requested, faceGeometry: face)
        XCTAssertEqual(plan.effectiveStrengths.faceSlim, requested.faceSlim)
        XCTAssertEqual(plan.effectiveStrengths.faceSmall, requested.faceSmall)
        XCTAssertEqual(plan.effectiveStrengths.noseWingSlim, requested.noseWingSlim)
        XCTAssertEqual(plan.effectiveStrengths.mouthWidth, requested.mouthWidth)
        XCTAssertFalse(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
        let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face)
        let width = 160, height = 192
        let map = try XCTUnwrap(BeautyDenseGeometryMap(width: width, height: height, face: face, points: points))
        XCTAssertLessThanOrEqual(map.maximumDisplacement, Double(width) * 0.4 * 0.06 + 0.00001)
        XCTAssertLessThanOrEqual(map.maximumGradient, 0.45 + 0.000001)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                pixels[offset] = UInt8(x)
                pixels[offset + 1] = UInt8(y)
                pixels[offset + 2] = (x / 3 + y / 3) % 2 == 0 ? 25 : 210
                pixels[offset + 3] = 255
            }
        }
        let output = map.applyRGBA(pixels)
        XCTAssertEqual(output.count, pixels.count)
        XCTAssertTrue(output != pixels)
        XCTAssertTrue(output == map.applyRGBA(pixels))
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                XCTAssertEqual(output[offset + 3], 255)
                if x == 0 || y == 0 || x == width - 1 || y == height - 1 {
                    XCTAssertTrue(output[offset..<(offset + 4)].elementsEqual(pixels[offset..<(offset + 4)]))
                }
            }
        }
        // Independently inspect both oriented source triangles in every cell.
        func node(_ x: Int, _ y: Int) -> SIMD2<Double> {
            SIMD2<Double>(map.xs[x] * Double(width), map.ys[y] * Double(height))
                - map.offsets[y * map.xs.count + x]
        }
        func area(_ a: SIMD2<Double>, _ b: SIMD2<Double>, _ c: SIMD2<Double>) -> Double {
            (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
        }
        for y in 0..<(map.ys.count - 1) {
            for x in 0..<(map.xs.count - 1) {
                let a = node(x, y), b = node(x + 1, y), c = node(x + 1, y + 1), d = node(x, y + 1)
                XCTAssertGreaterThan(area(a, b, c), 0)
                XCTAssertGreaterThan(area(a, c, d), 0)
            }
        }
    }

    func testNonfreshDenseCarrierCannotAuthorizeTheNewCombinationRoute() throws {
        let parameters = BeautyParameters(faceSlim: 0.6, noseWingSlim: 0.35, mouthWidth: -0.35)
        for freshness in [LandmarkGeometryFreshness.reused, .stale] {
            let face = try faceWithMesh(freshness: freshness)
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            XCTAssertNil(plan.metrics["beauty.effects.denseMapCombination"])
            XCTAssertNil(BeautyDenseGeometryMap(width: 160, height: 192, face: face,
                points: BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face)))
            if freshness == .stale {
                // Legacy face-shape values remain in the plan while the
                // domain is explicitly skipped; they cannot authorize output.
                XCTAssertFalse(plan.activeDomains.contains(.faceShape))
                XCTAssertTrue(plan.skippedDomains.contains(.faceShape))
                XCTAssertTrue(BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face).isEmpty)
                XCTAssertEqual(plan.effectiveStrengths.noseWingSlim, 0)
                XCTAssertEqual(plan.effectiveStrengths.mouthWidth, 0)
            } else {
                XCTAssertLessThan(plan.effectiveStrengths.faceSlim, parameters.faceSlim)
                XCTAssertLessThan(plan.effectiveStrengths.noseWingSlim, parameters.noseWingSlim)
            }
        }
    }

    private func faceWithMesh(freshness: LandmarkGeometryFreshness = .fresh) throws -> FaceGeometry {
        let base = FaceGeometry.fixture
        var points = (0..<478).map { i in
            SIMD3<Float>(0.30 + Float(i % 23) / 60, 0.20 + Float(i / 23) / 40, 0)
        }
        for (i, index) in MediaPipeFaceTopology.oval.enumerated() {
            let angle = Double(i) * 2 * Double.pi / Double(MediaPipeFaceTopology.oval.count)
            points[index] = SIMD3<Float>(0.5 + Float(cos(angle)) * 0.2, 0.5 + Float(sin(angle)) * 0.3, 0)
        }
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points))
        return FaceGeometry(bounds: base.bounds, faceContour: base.faceContour,
                            leftEye: base.leftEye, rightEye: base.rightEye,
                            nose: base.nose, noseRoot: base.noseRoot, noseTip: base.noseTip,
                            outerLips: base.outerLips, upperLips: base.upperLips,
                            lowerLips: base.lowerLips, innerLips: base.innerLips, freshness: freshness,
                            denseSupport: BeautyDenseFaceSupport(mesh: mesh))
    }
}
