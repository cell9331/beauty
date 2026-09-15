import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
@testable import BeautyEffects

/// Sampling/color/readback mechanics only. Control points are inputs to this
/// sampler oracle, never evidence of anatomical motion or portrait efficacy.
final class Phase95ImageFormationTests: XCTestCase {
    private func fixture(width: Int, height: Int) throws -> (BeautyCanonicalStillImage, [UInt8]) {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width { for c in 0..<3 {
            bytes[(y * width + x) * 4 + c] = UInt8(40 + (x * 73 + y * 29 + c * 47 + x * y) % 176)
        } } }
        return (try BeautyCanonicalStillImage(rgba8Data: Data(bytes), width: width,
            height: height, rowBytes: width * 4,
            metadata: .init(orientation: .up, source: .testFixture)), bytes)
    }

    private func bytes(_ image: CIImage, context: CIContext, color: CGColorSpace) -> [UInt8] {
        let w = Int(image.extent.width), h = Int(image.extent.height)
        var output = [UInt8](repeating: 0, count: w * h * 4)
        context.render(image, toBitmap: &output, rowBytes: w * 4, bounds: image.extent,
                       format: .RGBA8, colorSpace: color)
        return output
    }

    private func pngRoundTrip(_ image: CIImage, context: CIContext, color: CGColorSpace) throws -> CIImage {
        let data = try XCTUnwrap(context.pngRepresentation(of: image, format: .RGBA8,
                                                          colorSpace: color, options: [:]))
        let source = try XCTUnwrap(CGImageSourceCreateWithData(data as CFData, nil))
        let cg = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil))
        XCTAssertEqual(cg.width, Int(image.extent.width))
        XCTAssertEqual(cg.height, Int(image.extent.height))
        return CIImage(cgImage: cg)
    }

    func testCanonicalNeutralAndMemoryPNGPreserveOpaqueRGBBytes() throws {
        let color = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
        for (w, h) in [(64, 48), (257, 193)] {
            let (canonical, original) = try fixture(width: w, height: h)
            let face = BeautyFaceGeometryAdapter.makeGeometry(from: BeautyFaceObservation(
                imageBounds: .init(x: 0.1, y: 0.1, width: 0.8, height: 0.8), landmarks: .complete))
            let plan = BeautyEffectResolver.resolve(parameters: .init(), faceGeometry: face)
            let neutral = BeautyGeometryEffectPipeline.applyMVPProxy(to: canonical.ciImage,
                canonicalImage: canonical, plan: plan, face: face)
            XCTAssertEqual(neutral.extent, canonical.ciImage.extent)
            XCTAssertEqual(zip(bytes(neutral, context: context, color: color), original).filter { $0 != $1 }.count, 0)
            let reloaded = try pngRoundTrip(neutral, context: context, color: color)
            XCTAssertEqual(zip(bytes(reloaded, context: context, color: color), original).filter { $0 != $1 }.count, 0)
        }
    }

    func testCanonicalHorizontalFieldMatchesIndependentDoubleSamplerAfterPNG() throws {
        let color = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
        let lips = [CoordinatePoint(x: 0.35, y: 0.60), CoordinatePoint(x: 0.50, y: 0.57),
                    CoordinatePoint(x: 0.65, y: 0.60), CoordinatePoint(x: 0.50, y: 0.63)]
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: BeautyFaceObservation(
            imageBounds: .init(x: 0.1, y: 0.1, width: 0.8, height: 0.8), landmarks: .complete,
            observedLipSupport: .init(outer: lips)))
        for (w, h) in [(64, 48), (257, 193)] {
            let (canonical, original) = try fixture(width: w, height: h)
            let plan = BeautyEffectResolver.resolve(parameters: .init(mouthWidth: -0.35), faceGeometry: face)
            let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: face)
            XCTAssertEqual(points.count, 2)
            guard points.count == 2, points.allSatisfy({ $0.pixelCenterSampling && $0.falloff == 1 &&
                $0.radius >= 0.001 && $0.radius <= 1 && $0.source.y == $0.target.y }) else {
                return XCTFail("Fixture must reach the admitted horizontal sampler")
            }
            let result = BeautyGeometryEffectPipeline.applyMVPProxy(to: canonical.ciImage,
                canonicalImage: canonical, plan: plan, face: face)
            XCTAssertEqual(result.extent, canonical.ciImage.extent)
            let output = bytes(result, context: context, color: color)
            let reload = bytes(try pngRoundTrip(result, context: context, color: color), context: context, color: color)
            XCTAssertEqual(zip(output, reload).filter { $0 != $1 }.count, 0)
            var maximumError = 0.0
            var changed = 0, outsideChanged = 0
            for y in 0..<h { for x in 0..<w {
                let px = (Double(x) + 0.5) / Double(w), py = (Double(y) + 0.5) / Double(h)
                var displacement = 0.0, influenced = false
                for p in points {
                    let dx = px - Double(p.target.x), dy = py - Double(p.target.y)
                    let radius = Double(p.radius), distance = (dx * dx + dy * dy).squareRoot()
                    if distance < radius {
                        influenced = true
                        displacement += (Double(p.target.x) - Double(p.source.x)) * (1 - distance / radius)
                    }
                }
                // Double reference samples the original row, because this
                // input field is exactly horizontal; no production helpers.
                let q = min(Double(w - 1), max(0, Double(x) - displacement * Double(w)))
                let lo = Int(floor(q)), hi = min(lo + 1, w - 1), fraction = q - Double(lo)
                for c in 0..<3 {
                    let index = (y * w + x) * 4 + c
                    let expected = Double(original[(y * w + lo) * 4 + c]) * (1 - fraction)
                        + Double(original[(y * w + hi) * 4 + c]) * fraction
                    maximumError = max(maximumError, abs(Double(output[index]) - expected))
                    if output[index] != original[index] {
                        changed += 1
                        if !influenced { outsideChanged += 1 }
                    }
                }
                XCTAssertEqual(output[(y * w + x) * 4 + 3], 255)
            } }
            XCTAssertGreaterThan(changed, 0)
            XCTAssertEqual(outsideChanged, 0)
            XCTAssertLessThanOrEqual(maximumError, 1,
                "Selected canonical geometry/PNG path must match UNROUNDED Double sampling within one byte")
        }
    }
}
