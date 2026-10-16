import BeautyCore
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyEffects

final class FaceSourceRefinementPlanningTests: XCTestCase {
    private let size = 512

    /// The real cap/skin edge lies above the detected face box. Its complete
    /// paired brow support is valid, while both old circular proxies overlap
    /// the brow clearance and must continue to emit zero control points.
    private func anatomy(
        freshness: LandmarkGeometryFreshness = .fresh,
        defect: Int = 0
    ) -> FaceGeometry {
        var contour = (0...10).map { i -> SIMD2<Float> in
            let a = Float(i) / 10 * .pi
            return SIMD2(0.5 - 0.3 * cos(a), 0.42 + 0.38 * sin(a))
        }
        let leftPoints = [SIMD2<Float>(0.3, 0.45), SIMD2<Float>(0.4, 0.45)]
        let rightPoints = [SIMD2<Float>(0.6, 0.45), SIMD2<Float>(0.7, 0.45)]
        let left = BeautyEyebrowSemanticTrace(side: defect == 3 ? .right : .left,
            points: defect == 4 ? [SIMD2(.nan, .nan)] : leftPoints,
            innerEndpoint: defect == 5 ? SIMD2(.nan, .nan) : leftPoints[1],
            outerEndpoint: leftPoints[0], center: SIMD2(0.35, 0.45), apexIndex: 0)
        let right = BeautyEyebrowSemanticTrace(side: .right, points: rightPoints,
            innerEndpoint: rightPoints[0], outerEndpoint: rightPoints[1],
            center: SIMD2(0.65, 0.45), apexIndex: 0)
        if defect == 6 { contour = [] }
        if defect == 7 { contour[2] = SIMD2(.nan, .nan) }
        if defect == 8 { contour = [SIMD2<Float>](repeating: SIMD2(0.5, 0.5), count: 6) }
        let support: BeautyEyebrowSemanticSupport?
        if defect == 1 {
            support = BeautyEyebrowSemanticSupport(left: nil, right: nil)
        } else if defect == 2 {
            support = BeautyEyebrowSemanticSupport(left: left, right: nil)
        } else {
            support = BeautyEyebrowSemanticSupport(left: left, right: right)
        }
        return FaceGeometry(bounds: FaceBounds(x: 0.2, y: 0.38, width: 0.6, height: 0.42),
            faceContour: contour, freshness: freshness, observedEyebrowSupport: support)
    }

    private func boundary(_ x: Int, bangs: Bool = false) -> Double {
        let u = (Double(x) - 256) / 154
        return 128 + (bangs ? 40 * (1 - u * u) : 10 * u * u)
    }

    private func pixels(kind: Int = 0) -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: size * size * 4)
        for y in 0..<size { for x in 0..<size {
            let edge = boundary(x, bangs: kind == 2)
            let t = min(1, max(0, (Double(y) - edge) / 16)), v = t * t * (3 - 2 * t)
            let hair = [50.0, 45.0, 40.0], skin = [220.0, 170.0, 130.0]
            let i = (y * size + x) * 4
            for c in 0..<3 {
                bytes[i + c] = UInt8((hair[c] + (skin[c] - hair[c]) * v).rounded())
                if kind == 1 || (kind == 3 && (248...252).contains(x)) {
                    bytes[i + c] = UInt8(skin[c])
                }
            }
            // Patterned source-fixed brow/forehead core and distant hair make
            // incidental color-space or proxy work observable byte-for-byte.
            if y >= 225 || x < 128 || x > 384 {
                bytes[i] = UInt8(30 + (x * 17 + y * 3) % 180)
                bytes[i + 1] = UInt8(25 + (x * 7 + y * 11) % 170)
                bytes[i + 2] = UInt8(20 + (x * 5 + y * 13) % 160)
            }
            if x < 80 && y < 80 { for c in 0..<4 { bytes[i + c] = 0 } }
        } }
        return bytes
    }

    private func edge(_ bytes: [UInt8]) -> Double {
        var total = 0.0, sum = 0.0
        for x in 230...282 { for y in 80..<190 {
            let value = max(0, Int(bytes[(y * size + x) * 4]) - Int(bytes[((y - 1) * size + x) * 4]))
            total += Double(value); sum += Double(value * y)
        } }
        return sum / total
    }

    private func image(_ source: [UInt8], colorSpace: CGColorSpace) -> CIImage {
        CIImage(bitmapData: Data(source), bytesPerRow: size * 4,
            size: CGSize(width: size, height: size), format: .RGBA8, colorSpace: colorSpace)
    }

    private func bytes(_ image: CIImage, colorSpace: CGColorSpace) -> [UInt8] {
        var output = [UInt8](repeating: 0, count: size * size * 4)
        CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace]).render(
            image, toBitmap: &output, rowBytes: size * 4, bounds: image.extent,
            format: .RGBA8, colorSpace: colorSpace)
        return output
    }

    func testQualifiedSourceWorkSurvivesZeroProxyPlanningAndDispatchesWithExactProtection() throws {
        let face = anatomy(), source = pixels(), provider = FaceShapeWarpProvider()
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let input = image(source, colorSpace: colorSpace), baseline = edge(source)
        XCTAssertTrue(bytes(input, colorSpace: colorSpace) == source, "sRGB source roundtrip")
        let neutral = BeautyEffectResolver.resolve(parameters: BeautyParameters(), faceGeometry: face)
        XCTAssertTrue(bytes(BeautyGeometryEffectPipeline.applyMVPProxy(to: input, plan: neutral, face: face),
            colorSpace: colorSpace) == source, "neutral exact identity")
        for sign: Float in [-1, 1] {
            var previous = 0.0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let strength = sign * BeautySafetyCaps.hairlineHeight * fraction
                var values = BeautyEffectiveStrengths(); values.hairlineHeight = strength
                let old = provider.fieldEmissions(face: face, strengths: values)
                let qualified = provider.planningEmissions(face: face, strengths: values)
                XCTAssertTrue(old.points.isEmpty)
                XCTAssertTrue(qualified.points.isEmpty, "source work must not add a fake proxy")
                XCTAssertEqual(qualified.sourceRefinementMask, 1)
                XCTAssertTrue(qualified.hasAdmittedWork)
                XCTAssertEqual(qualified.sanitizing(values), values)
                var parameters = BeautyParameters(); parameters.hairlineHeight = strength
                var iterations = [BeautyRetainedMaskIteration]()
                let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face,
                    onRetainedMaskIteration: { iterations.append($0) })
                XCTAssertEqual(plan.effectiveStrengths.hairlineHeight, strength)
                XCTAssertTrue(plan.activeDomains.contains(.faceShape))
                XCTAssertFalse(plan.skippedDomains.contains(.faceShape))
                XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
                XCTAssertTrue(BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face).isEmpty)
                XCTAssertFalse(iterations.isEmpty)
                XCTAssertTrue(iterations.allSatisfy { $0.retainedFieldNames.contains("hairlineHeight") })
                let outputImage = BeautyGeometryEffectPipeline.applyMVPProxy(to: input, plan: plan, face: face)
                XCTAssertEqual(outputImage.extent, input.extent)
                let output = bytes(outputImage, colorSpace: colorSpace)
                let movement = (edge(output) - baseline) * Double(sign)
                XCTAssertGreaterThan(movement, previous + 0.1)
                if fraction == 1 { XCTAssertGreaterThan(movement, 1) }
                previous = movement
                var protectedPixels = 0, alphaPixels = 0
                for y in 0..<size { for x in 0..<size {
                    let i = (y * size + x) * 4
                    if abs(Double(y) - boundary(x)) > 32 || x < 128 || x > 384 || y >= 225 {
                        if (0..<4).contains(where: { source[i + $0] != output[i + $0] }) { protectedPixels += 1 }
                    }
                    if source[i + 3] != output[i + 3] { alphaPixels += 1 }
                } }
                XCTAssertEqual(protectedPixels, 0); XCTAssertEqual(alphaPixels, 0)
                let repeated = bytes(BeautyGeometryEffectPipeline.applyMVPProxy(to: input, plan: plan, face: face),
                    colorSpace: colorSpace)
                XCTAssertTrue(repeated == output, "determinism")
            }
        }
    }

    func testMalformedMissingAndExpiredSupportCannotKeepZeroProxySourceWork() throws {
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let source = pixels(), input = image(source, colorSpace: colorSpace)
        var faces = (1...8).map { anatomy(defect: $0) }
        faces += [anatomy(freshness: .stale), anatomy(freshness: .reused)]
        for face in faces { for sign: Float in [-1, 1] {
            let strength = sign * BeautySafetyCaps.hairlineHeight
            var values = BeautyEffectiveStrengths(); values.hairlineHeight = strength
            XCTAssertFalse(FaceShapeWarpProvider.hasSourceHairlineGeometry(face: face, strength: strength))
            let qualified = FaceShapeWarpProvider().planningEmissions(face: face, strengths: values)
            XCTAssertTrue(qualified.points.isEmpty)
            XCTAssertEqual(qualified.sourceRefinementMask, 0)
            XCTAssertFalse(qualified.hasAdmittedWork)
            var parameters = BeautyParameters(); parameters.hairlineHeight = strength
            let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
            XCTAssertEqual(plan.effectiveStrengths.hairlineHeight, 0)
            XCTAssertFalse(plan.activeDomains.contains(.faceShape))
            XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
            XCTAssertTrue(bytes(BeautyGeometryEffectPipeline.applyMVPProxy(to: input, plan: plan, face: face),
                colorSpace: colorSpace) == source, "rejected geometric qualification preserves source")
        } }
        var parameters = BeautyParameters(); parameters.hairlineHeight = BeautySafetyCaps.hairlineHeight
        let missing = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: nil)
        XCTAssertEqual(missing.effectiveStrengths.hairlineHeight, 0)
        XCTAssertFalse(missing.activeDomains.contains(.faceShape))
    }

    func testGeometryQualificationDoesNotAdmitHairlessBangsOrIncompleteSourceEdges() throws {
        let face = anatomy(), colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        for kind in [1, 2, 3] {
            let source = pixels(kind: kind), input = image(source, colorSpace: colorSpace)
            for sign: Float in [-1, 1] {
                var parameters = BeautyParameters(); parameters.hairlineHeight = sign * BeautySafetyCaps.hairlineHeight
                let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
                XCTAssertTrue(plan.activeDomains.contains(.faceShape), "geometry qualifies only an attempt")
                XCTAssertTrue(bytes(BeautyGeometryEffectPipeline.applyMVPProxy(to: input, plan: plan, face: face),
                    colorSpace: colorSpace) == source, "RGB rejection must remain exact; kind=\(kind)")
            }
        }
    }

    func testConflictRetainsQualifiedHairlineAndCountsOnlyRealPoints() {
        let face = anatomy(), provider = FaceShapeWarpProvider()
        var parameters = BeautyParameters()
        parameters.hairlineHeight = BeautySafetyCaps.hairlineHeight
        parameters.faceSlim = BeautySafetyCaps.faceSlim
        parameters.faceSmall = BeautySafetyCaps.faceSmall
        var values = BeautyEffectiveStrengths()
        values.hairlineHeight = parameters.hairlineHeight
        values.faceSlim = parameters.faceSlim; values.faceSmall = parameters.faceSmall
        let expected = GeometryConflictResolver().resolve(strengths: values).strengths
        var iterations = [BeautyRetainedMaskIteration]()
        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face,
            onRetainedMaskIteration: { iterations.append($0) })
        XCTAssertEqual(plan.effectiveStrengths, expected)
        XCTAssertGreaterThan(plan.effectiveStrengths.hairlineHeight, 0)
        XCTAssertTrue(iterations.allSatisfy { $0.retainedFieldNames.contains("hairlineHeight") })
        let final = provider.planningEmissions(face: face, strengths: plan.effectiveStrengths)
        XCTAssertTrue(final.hairlineHeight.isEmpty)
        XCTAssertGreaterThan(final.points.count, 0)
        XCTAssertEqual(plan.metrics["beauty.effects.geometryPointCount"], Double(final.points.count))
        let siblingKeys: [WritableKeyPath<BeautyEffectiveStrengths, Float>] = [
            \.faceSlim, \.faceSmall, \.jawSlim, \.faceVShape, \.foreheadHeight,
            \.headSmall, \.cranialCrownHeight, \.wholeFaceXPosition
        ]
        for key in siblingKeys {
            var sibling = BeautyEffectiveStrengths(); sibling[keyPath: key] = 0.1
            XCTAssertEqual(provider.planningEmissions(face: face, strengths: sibling),
                provider.fieldEmissions(face: face, strengths: sibling), "zero hairline preserves sibling planning")
        }
    }
}
