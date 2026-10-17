import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyEffects

final class FaceSourceRefinementPlanningTests: XCTestCase {
    private let size = 512

    /// Complete independent face/eye/lip/brow observations qualify an attempt.
    /// Pixel qualification and the broad field remain separate from planning.
    private func anatomy(
        freshness: LandmarkGeometryFreshness = .fresh,
        defect: Int = 0
    ) -> FaceGeometry {
        var contour = (0...10).map { i -> SIMD2<Float> in
            let a = Float(i) / 10 * .pi
            return SIMD2(0.5 - 0.3 * cos(a), 0.42 + 0.38 * sin(a))
        }
        let leftPoints = (0...4).map { SIMD2<Float>(0.3 + Float($0) * 0.025, 0.45) }
        let rightPoints = (0...4).map { SIMD2<Float>(0.6 + Float($0) * 0.025, 0.45) }
        let left = BeautyEyebrowSemanticTrace(side: defect == 3 ? .right : .left,
            points: defect == 4 ? [SIMD2(.nan, .nan)] : leftPoints,
            innerEndpoint: defect == 5 ? SIMD2(.nan, .nan) : leftPoints[4],
            outerEndpoint: leftPoints[0], center: SIMD2(0.35, 0.45), apexIndex: 0)
        let right = BeautyEyebrowSemanticTrace(side: .right, points: rightPoints,
            innerEndpoint: rightPoints[0], outerEndpoint: rightPoints[4],
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
        func box(_ center: SIMD2<Float>, _ radius: SIMD2<Float>) -> [SIMD2<Float>] {
            [center + SIMD2(-radius.x, -radius.y), center + SIMD2(radius.x, -radius.y),
             center + SIMD2(radius.x, radius.y), center + SIMD2(-radius.x, radius.y)]
        }
        func eye(_ side: BeautyObservedEyeSide, _ center: SIMD2<Float>) -> BeautyEyeSemanticSupport {
            let path = box(center, SIMD2(0.04, 0.014))
            return BeautyEyeSemanticSupport(side: side, contour: path,
                upper: Array(path.prefix(2)), lower: Array(path.suffix(2)), inner: [path[0]], outer: [path[1]],
                corners: [path[0], path[1]], center: center, pupil: center,
                span: SIMD2(0.08, 0.028), tilt: 0)
        }
        let leftEye = eye(.left, SIMD2(0.392, 0.52)), rightEye = eye(.right, SIMD2(0.608, 0.52))
        let lips = box(SIMD2(0.5, 0.69), SIMD2(0.065, 0.018))
        return FaceGeometry(bounds: FaceBounds(x: 0.2, y: 0.38, width: 0.6, height: 0.42),
            faceContour: contour,
            observedFaceSupport: defect == 9 ? nil : BeautyFaceSemanticSupport(contour: contour, medianLine: nil, apexIndex: 5),
            leftEye: leftEye.contour, rightEye: rightEye.contour, outerLips: lips,
            leftEyeSupport: defect == 10 ? nil : leftEye,
            rightEyeSupport: defect == 11 ? nil : rightEye,
            freshness: freshness, observedEyebrowSupport: support,
            observedOuterLips: defect == 12 ? nil : lips)
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
            if kind == 4 && (160...180).contains(y) {
                bytes[i] = 50; bytes[i + 1] = 45; bytes[i + 2] = 40
            }
            // Patterned source-fixed brow/forehead core and distant hair make
            // incidental color-space or proxy work observable byte-for-byte.
            if y >= 225 || x < 128 || x > 384 {
                bytes[i] = UInt8(30 + (x * 17 + y * 3) % 180)
                bytes[i + 1] = UInt8(25 + (x * 7 + y * 11) % 170)
                bytes[i + 2] = UInt8(20 + (x * 5 + y * 13) % 160)
            }
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
                let qualified = provider.planningEmissions(face: face, strengths: values)
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
                    let crownCore = (220...292).contains(x) && y < 32
                    let leftBrowCore = (170...188).contains(x) && (228...232).contains(y)
                    let rightBrowCore = (324...342).contains(x) && (228...232).contains(y)
                    if crownCore || leftBrowCore || rightBrowCore || x < 8 || x > 504 || y >= 300 {
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
        var faces = (1...12).map { anatomy(defect: $0) }
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

    func testGeometryQualificationDoesNotAdmitHairlessAmbiguousOrTransparentSource() throws {
        let face = anatomy(), colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        for kind in [1, 4, 5] {
            var source = pixels(kind: kind)
            if kind == 5 { for channel in 0..<4 { source[channel] = 0 } }
            let input = image(source, colorSpace: colorSpace)
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
        // Complete source geometry qualifies hairline. Missing independent
        // nasal support still rejects the separately owned jaw/V fields.
        parameters.jawSlim = BeautySafetyCaps.jawSlim
        parameters.faceVShape = BeautySafetyCaps.faceVShape
        var values = BeautyEffectiveStrengths()
        values.hairlineHeight = parameters.hairlineHeight
        let expected = GeometryConflictResolver().resolve(strengths: values).strengths
        var iterations = [BeautyRetainedMaskIteration]()
        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face,
            onRetainedMaskIteration: { iterations.append($0) })
        XCTAssertEqual(plan.effectiveStrengths, expected)
        XCTAssertEqual(plan.effectiveStrengths.faceVShape, 0)
        XCTAssertEqual(plan.effectiveStrengths.jawSlim, 0)
        XCTAssertGreaterThan(plan.effectiveStrengths.hairlineHeight, 0)
        XCTAssertTrue(iterations.allSatisfy { $0.retainedFieldNames.contains("hairlineHeight") })
        let final = provider.planningEmissions(face: face, strengths: plan.effectiveStrengths)
        XCTAssertTrue(final.hairlineHeight.isEmpty)
        XCTAssertTrue(final.points.isEmpty)
        XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
        let siblingKeys: [WritableKeyPath<BeautyEffectiveStrengths, Float>] = [
            \.foreheadHeight,
            \.headSmall, \.cranialCrownHeight, \.wholeFaceXPosition
        ]
        for key in siblingKeys {
            var sibling = BeautyEffectiveStrengths(); sibling[keyPath: key] = 0.1
            XCTAssertEqual(provider.planningEmissions(face: face, strengths: sibling),
                provider.fieldEmissions(face: face, strengths: sibling), "zero hairline preserves sibling planning")
        }
        var vOnly = BeautyEffectiveStrengths(); vOnly.faceVShape = 0.1
        XCTAssertFalse(provider.fieldEmissions(face: face, strengths: vOnly).faceVShape.isEmpty,
            "the old V inventory exists but cannot qualify the new source field")
        let rejectedV = provider.planningEmissions(face: face, strengths: vOnly)
        XCTAssertTrue(rejectedV.points.isEmpty)
        XCTAssertEqual(rejectedV.continuousFaceMask, 0)
        XCTAssertFalse(rejectedV.hasAdmittedWork)
        XCTAssertEqual(rejectedV.sanitizing(vOnly).faceVShape, 0)
    }
}
