import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
@testable import BeautyEffects

/// Generated sampler/model applicability checks, NOT portrait effect scoring.
/// Emitted points are sampler inputs, never independent anatomical-motion truth.
final class Phase95RootImageFormationTests: XCTestCase {
    private func face() -> FaceGeometry {
        let crest = [0.30, 0.35, 0.40, 0.45, 0.50].map { CoordinatePoint(x: 0.50, y: $0) }
        let contour = [CoordinatePoint(x: 0.44, y: 0.51), .init(x: 0.46, y: 0.55),
                       .init(x: 0.50, y: 0.56), .init(x: 0.54, y: 0.55), .init(x: 0.56, y: 0.51)]
        let base = BeautyFaceGeometryAdapter.makeGeometry(from: BeautyFaceObservation(
            imageBounds: .init(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
            landmarks: .complete, observedNoseSupport: .init(crest: crest, contour: contour)))
        func eye(_ side: BeautyObservedEyeSide, _ x: Float) -> BeautyEyeSemanticSupport {
            let trace: [SIMD2<Float>] = [.init(x - 0.04, 0.28), .init(x, 0.26),
                                       .init(x + 0.04, 0.28), .init(x, 0.30)]
            return .init(side: side, contour: trace, upper: Array(trace.prefix(3)),
                lower: [trace[0], trace[3], trace[2]], inner: [side == .left ? trace[2] : trace[0]],
                outer: [side == .left ? trace[0] : trace[2]], corners: [trace[0], trace[2]],
                center: .init(x, 0.28), pupil: nil, span: .init(0.08, 0.04), tilt: 0)
        }
        return FaceGeometry(bounds: base.bounds, faceContour: base.faceContour, nose: base.nose,
            leftEyeSupport: eye(.left, 0.38), rightEyeSupport: eye(.right, 0.62),
            observedNoseSupport: base.observedNoseSupport)
    }

    private func displacement(_ x: Int, _ y: Int, _ size: Int, _ points: [WarpControlPoint]) -> Double {
        let px = (Double(x) + 0.5) / Double(size), py = (Double(y) + 0.5) / Double(size)
        return points.reduce(0) { sum, p in
            let dx = px - Double(p.target.x), dy = py - Double(p.target.y)
            let weight = max(0, 1 - (dx * dx + dy * dy).squareRoot() / Double(p.radius))
            return sum + (Double(p.target.x) - Double(p.source.x)) * weight * Double(size)
        }
    }

    private func read(_ image: CIImage, size: Int, context: CIContext, color: CGColorSpace) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: size * size * 4)
        context.render(image, toBitmap: &bytes, rowBytes: size * 4, bounds: image.extent,
                       format: .RGBA8, colorSpace: color)
        return bytes
    }

    func testActualRootCanonicalSamplerAndMemoryPNGMatchUnroundedReference() throws {
        let color = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
        let geometry = face()
        for size in [256, 512] {
            var original = [UInt8](repeating: 255, count: size * size * 4)
            for y in 0..<size { for x in 0..<size { for c in 0..<3 {
                original[(y * size + x) * 4 + c] = UInt8(40 + (x * 73 + y * 29 + c * 47 + x * y) % 176)
            } } }
            let canonical = try BeautyCanonicalStillImage(rgba8Data: Data(original), width: size,
                height: size, rowBytes: size * 4, metadata: .init(orientation: .up, source: .testFixture))
            for strength: Float in [0, 0.125, 0.25] {
                let plan = BeautyEffectResolver.resolve(parameters: .init(noseRootNarrowing: strength),
                                                        faceGeometry: geometry)
                let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: geometry)
                XCTAssertEqual(points.count, strength == 0 ? 0 : 6)
                guard points.allSatisfy({ $0.pixelCenterSampling && $0.falloff == 1 &&
                    $0.radius >= 0.001 && $0.radius <= 1 && $0.target.y == $0.source.y }) else {
                    return XCTFail("Generated root must enter horizontal canonical sampling")
                }
                let outputImage = BeautyGeometryEffectPipeline.applyMVPProxy(to: canonical.ciImage,
                    canonicalImage: canonical, plan: plan, face: geometry)
                XCTAssertEqual(outputImage.extent, canonical.ciImage.extent)
                let output = read(outputImage, size: size, context: context, color: color)
                let png = try XCTUnwrap(context.pngRepresentation(of: outputImage, format: .RGBA8,
                                                                  colorSpace: color, options: [:]))
                let decoded = try XCTUnwrap(CGImageSourceCreateWithData(png as CFData, nil))
                let cg = try XCTUnwrap(CGImageSourceCreateImageAtIndex(decoded, 0, nil))
                XCTAssertEqual(cg.width, size); XCTAssertEqual(cg.height, size)
                let reloaded = read(CIImage(cgImage: cg), size: size, context: context, color: color)
                XCTAssertEqual(zip(output, reloaded).filter { $0 != $1 }.count, 0)
                var changed = 0, outsideChanged = 0, alphaChanged = 0
                var maximumError = 0.0
                for y in 0..<size { for x in 0..<size {
                    let d = displacement(x, y, size, points)
                    let q = min(Double(size - 1), max(0, Double(x) - d))
                    let lo = Int(floor(q)), hi = min(lo + 1, size - 1), f = q - Double(lo)
                    for c in 0..<3 {
                        let i = (y * size + x) * 4 + c
                        let expected = Double(original[(y * size + lo) * 4 + c]) * (1 - f)
                            + Double(original[(y * size + hi) * 4 + c]) * f
                        maximumError = max(maximumError, abs(Double(output[i]) - expected))
                        if output[i] != original[i] {
                            changed += 1
                            if d == 0 { outsideChanged += 1 }
                        }
                    }
                    if output[(y * size + x) * 4 + 3] != 255 { alphaChanged += 1 }
                } }
                XCTAssertEqual(outsideChanged, 0); XCTAssertEqual(alphaChanged, 0)
                if strength == 0 { XCTAssertEqual(changed, 0) }
                else { XCTAssertGreaterThan(changed, 0) }
                XCTAssertLessThanOrEqual(maximumError, 1,
                    "Selected root canonical/PNG path must match unrounded Double within one byte")
            }
        }
    }

    func testActualRootFieldExceedsUnitSearchAndExactAffinePatchAssumptions() {
        let geometry = face()
        let plan = BeautyEffectResolver.resolve(parameters: .init(noseRootNarrowing: 0.25),
                                                faceGeometry: geometry)
        let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: geometry)
        XCTAssertEqual(points.count, 6)
        for size in [256, 512] {
            var maximumDisplacement = 0.0, affineResidualLowerBound = 0.0
            for y in 0..<size { for x in 2..<size - 2 {
                let center = displacement(x, y, size, points)
                maximumDisplacement = max(maximumDisplacement, abs(center))
                // Any affine fit on x-2,x,x+2 has zero second difference.
                // If its maximum error is e, this difference is bounded by4e.
                let secondDifference = displacement(x - 2, y, size, points)
                    - 2 * center + displacement(x + 2, y, size, points)
                affineResidualLowerBound = max(affineResidualLowerBound, abs(secondDifference) / 4)
            } }
            XCTAssertGreaterThan(maximumDisplacement, 1,
                "Unit-pixel generated search cannot cover this actual root field")
            XCTAssertGreaterThan(affineResidualLowerBound, 0.05,
                "Exact affine five-sample model misses curvature/cusps in this actual field")
        }
    }
}
