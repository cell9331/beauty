import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// The observed source-raster stage owns smoothing on dense carriers as well
/// as coarse carriers. Source rejection must not revive the planning proxy.
final class FaceSmoothSourceStageTests: XCTestCase {
    private let width = 800, height = 800

    private func denseObservedFace() throws -> FaceGeometry {
        let base = FaceGeometry.phase46AsymmetricComplete
        var points = Array(repeating: SIMD3<Float>(0.5, 0.5, 0), count: 478)
        func ellipse(_ indices: [Int], x: Float, y: Float, rx: Float, ry: Float) {
            for (ordinal, index) in indices.enumerated() {
                let angle = Float(ordinal) * 2 * .pi / Float(indices.count)
                points[index] = SIMD3(x + cos(angle) * rx, y + sin(angle) * ry, 0)
            }
        }
        ellipse(MediaPipeFaceTopology.oval, x: 0.5, y: 0.5, rx: 0.3, ry: 0.4)
        ellipse(MediaPipeFaceTopology.leftEye, x: 0.4, y: 0.42, rx: 0.05, ry: 0.025)
        ellipse(MediaPipeFaceTopology.rightEye, x: 0.6, y: 0.42, rx: 0.05, ry: 0.025)
        ellipse(MediaPipeFaceTopology.leftBrowEnvelope, x: 0.4, y: 0.36, rx: 0.055, ry: 0.01)
        ellipse(MediaPipeFaceTopology.rightBrowEnvelope, x: 0.6, y: 0.36, rx: 0.055, ry: 0.01)
        ellipse(MediaPipeFaceTopology.noseCrest, x: 0.5, y: 0.51, rx: 0.01, ry: 0.04)
        ellipse(MediaPipeFaceTopology.noseContour, x: 0.5, y: 0.55, rx: 0.035, ry: 0.025)
        ellipse(MediaPipeFaceTopology.outerLip, x: 0.5, y: 0.65, rx: 0.06, ry: 0.035)
        ellipse(MediaPipeFaceTopology.innerLip, x: 0.5, y: 0.65, rx: 0.045, ry: 0.02)
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points))
        let dense = BeautyDenseFaceSupport(mesh: mesh)
        XCTAssertFalse(dense.oval.isEmpty, "the regression must actually enter the dense stage")
        return FaceGeometry(bounds: base.bounds, faceContour: base.faceContour,
            observedFaceSupport: base.observedFaceSupport,
            leftEye: base.leftEye, rightEye: base.rightEye,
            nose: base.nose, noseRoot: base.noseRoot, noseTip: base.noseTip,
            outerLips: base.outerLips, upperLips: base.upperLips,
            lowerLips: base.lowerLips, innerLips: base.innerLips,
            leftEyeSupport: base.leftEyeSupport, rightEyeSupport: base.rightEyeSupport,
            freshness: base.freshness, denseSupport: dense)
    }

    /// The existing source-clean/observed-cheek fixture geometry supplies the
    /// silhouette. Its offset rough edge has no dark-hair veto on either side.
    private func roughSource(face: FaceGeometry) throws -> [UInt8] {
        let runs = try XCTUnwrap(FaceContourLateralRuns.make(from:
            try XCTUnwrap(face.observedFaceSupport?.contour)))
        func center(_ run: FaceContourLateralRuns.Run, y: Float) -> Float? {
            guard let first = run.ordered.first, let last = run.ordered.last,
                  y >= first.y, y < last.y else { return nil }
            for (a, b) in zip(run.ordered, run.ordered.dropFirst()) where y >= a.y && y <= b.y {
                return (a.x + (b.x - a.x) * (y - a.y) / (b.y - a.y)) * Float(width)
            }
            return nil
        }
        var source = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            let normalizedY = (Float(y) + 0.5) / Float(height)
            let left = center(runs[0], y: normalizedY).map { $0 - 12 }
            let right = center(runs[1], y: normalizedY).map { $0 + 12 }
            let wave = Float(4 * sin(Double(y) * 2 * .pi / 28))
            for x in 0..<width {
                let q = Float(x), i = (y * width + x) * 4
                let inside = left.map { q >= $0 + wave } == true && right.map { q <= $0 - wave } == true
                let rgb: [UInt8] = inside ? [170, 120, 105] : [220, 220, 220]
                for c in 0..<3 { source[i + c] = rgb[c] }
                if (300..<500).contains(x) {
                    source[i] = UInt8(110 + (x * 7 + y * 3) % 100)
                    source[i + 1] = UInt8(90 + (x * 5 + y * 11) % 80)
                    source[i + 2] = UInt8(65 + (x * 3 + y * 7) % 80)
                }
            }
        }
        return source
    }

    private func plan(smooth: Bool, crown: Bool = false) -> BeautyEffectPlan {
        var strengths = BeautyEffectiveStrengths()
        strengths.faceContourSmooth = smooth ? BeautySafetyCaps.faceContourSmooth : 0
        strengths.cranialCrownHeight = crown ? BeautySafetyCaps.cranialCrownHeight * 0.5 : 0
        return BeautyEffectPlan(activeDomains: [.faceShape], effectiveStrengths: strengths)
    }

    func testAcceptedObservedSourceSmoothOwnsDenseRasterAndKeepsSiblingPoints() throws {
        let face = try denseObservedFace(), source = try roughSource(face: face)
        let smooth = plan(smooth: true)
        XCTAssertFalse(FaceShapeWarpProvider().fieldEmissions(face: face,
            strengths: smooth.effectiveStrengths).faceContourSmooth.isEmpty,
            "the planning proxy must exist for this regression to detect duplicate ownership")
        let refined = FaceContourSubpixelRefiner.refineWithProtection(source, width: width,
            height: height, face: face, strength: smooth.effectiveStrengths.faceContourSmooth)
        XCTAssertFalse(refined.protectedLeft)
        XCTAssertFalse(refined.protectedRight)
        let changed = stride(from: 0, to: source.count, by: 4).filter {
            source[$0..<$0 + 4] != refined.bytes[$0..<$0 + 4]
        }.count
        XCTAssertGreaterThan(changed, 16, "source ownership requires a useful active raster")
        let stage = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height,
            plan: smooth, face: face)
        XCTAssertTrue(stage.usesDenseMap)
        XCTAssertTrue(stage.sourceRGBA == refined.bytes)
        XCTAssertTrue(stage.controlPoints.isEmpty, "the accepted source raster cannot also emit smooth proxies")
        let sibling = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height,
            plan: plan(smooth: false, crown: true), face: face)
        let mixed = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height,
            plan: plan(smooth: true, crown: true), face: face)
        XCTAssertFalse(sibling.controlPoints.isEmpty)
        XCTAssertTrue(mixed.controlPoints == sibling.controlPoints, "suppress only the source-owned smooth field")
        XCTAssertTrue(mixed.sourceRGBA == refined.bytes)
    }

    func testRejectedObservedSourceSmoothCannotRestoreDenseProxyOrRemoveSibling() throws {
        let face = try denseObservedFace()
        let pixel: [UInt8] = [170, 125, 110, 255]
        let source: [UInt8] = Array(repeating: pixel, count: width * height).flatMap { $0 }
        let smooth = plan(smooth: true)
        XCTAssertFalse(FaceShapeWarpProvider().fieldEmissions(face: face,
            strengths: smooth.effectiveStrengths).faceContourSmooth.isEmpty)
        let refined = FaceContourSubpixelRefiner.refineWithProtection(source, width: width,
            height: height, face: face, strength: smooth.effectiveStrengths.faceContourSmooth)
        XCTAssertTrue(refined.bytes == source, "a uniform source supplies no silhouette to refine")
        let stage = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height,
            plan: smooth, face: face)
        XCTAssertTrue(stage.usesDenseMap)
        XCTAssertTrue(stage.sourceRGBA == source)
        XCTAssertTrue(stage.controlPoints.isEmpty, "source refusal must not revive a smooth proxy")
        let sibling = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height,
            plan: plan(smooth: false, crown: true), face: face)
        let mixed = BeautyStillImageGeometryStage(sourceRGBA: source, width: width, height: height,
            plan: plan(smooth: true, crown: true), face: face)
        XCTAssertFalse(sibling.controlPoints.isEmpty)
        XCTAssertTrue(mixed.controlPoints == sibling.controlPoints)
        XCTAssertTrue(mixed.sourceRGBA == source)
    }
}
