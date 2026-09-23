import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

final class PortraitMouthRegistrationTests: XCTestCase {
    private let bounds = CoordinateRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
    private let lips = [CoordinatePoint(x: 0.35, y: 0.60), CoordinatePoint(x: 0.5, y: 0.57),
                        CoordinatePoint(x: 0.65, y: 0.60), CoordinatePoint(x: 0.5, y: 0.63)]

    private func geometry(_ observed: [CoordinatePoint]?) -> FaceGeometry {
        BeautyFaceGeometryAdapter.makeGeometry(from: BeautyFaceObservation(
            imageBounds: bounds, landmarks: .complete,
            observedLipSupport: observed.map { BeautyObservedLipSupport(outer: $0, inner: nil) }))
    }

    func testNegativeWidthUsesObservedCornersWhilePositivePreservesLegacy() throws {
        let face = geometry(lips)
        var negative = BeautyEffectiveStrengths(); negative.mouthWidth = -0.35
        let points = MouthWarpProvider().fieldEmissions(face: face, strengths: negative).mouthWidth
        XCTAssertEqual(points.count, 2)
        for (point, expected) in zip(points, [lips[0], lips[2]]) {
            XCTAssertEqual(point.source.x, Float(expected.x), accuracy: 0.000001)
            XCTAssertEqual(point.source.y, Float(expected.y), accuracy: 0.000001)
            XCTAssertEqual(point.target.y, point.source.y)
        }
        var positive = BeautyEffectiveStrengths(); positive.mouthWidth = 0.35
        XCTAssertEqual(MouthWarpProvider().fieldEmissions(face: face, strengths: positive),
                       MouthWarpProvider().fieldEmissions(face: geometry(nil), strengths: positive))
    }

    func testObservedInvalidLipsCannotFallBackToTemplate() {
        var negative = BeautyEffectiveStrengths(); negative.mouthWidth = -0.35
        for invalid in [[], [lips[0]], [lips[0], lips[0], lips[2], lips[3]],
                        [CoordinatePoint(x: .nan, y: 0.6)] + Array(lips.dropFirst())] {
            XCTAssertTrue(MouthWarpProvider().fieldEmissions(face: geometry(invalid), strengths: negative).mouthWidth.isEmpty)
        }
    }

    func testSmallObservedMouthDoesNotReexpandLegacyMinimumRadius() {
        let small = lips.map { CoordinatePoint(x: 0.5 + ($0.x - 0.5) * 0.4, y: $0.y) }
        var negative = BeautyEffectiveStrengths(); negative.mouthWidth = -0.35
        let points = MouthWarpProvider().fieldEmissions(face: geometry(small), strengths: negative).mouthWidth
        XCTAssertEqual(points.count, 2)
        for point in points {
            XCTAssertLessThan(point.radius, 0.02)
            XCTAssertLessThan(abs(point.target.x - point.source.x) + point.radius, 0.12 / 4)
        }
        XCTAssertTrue(HorizontalInwardWarpSafety.accepts(points, maximumSlope: 0.8))
    }

    func testChinDisksRespectObservedLipClearanceAndRejectMalformedLips() {
        let contour: [SIMD2<Float>] = [
            .init(0.32, 0.72), .init(0.38, 0.76), .init(0.44, 0.80), .init(0.50, 0.82),
            .init(0.56, 0.80), .init(0.62, 0.76), .init(0.68, 0.72)]
        let support = BeautyFaceSemanticSupport(contour: contour,
            medianLine: [.init(0.5, 0.4), .init(0.5, 0.9)], apexIndex: 3)
        let observed = lips.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        var active = BeautyEffectiveStrengths(); active.chinTaper = 0.25
        func emitted(_ lipPoints: [SIMD2<Float>]) -> [WarpControlPoint] {
            let face = FaceGeometry(bounds: .init(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
                faceContour: contour, observedFaceSupport: support, observedOuterLips: lipPoints)
            return ChinWarpProvider().fieldEmissions(face: face, strengths: active).chinTaper
        }
        let points = emitted(observed)
        XCTAssertEqual(points.count, 6)
        for p in points {
            XCTAssertGreaterThan(p.target.y - p.radius, 0.63)
            XCTAssertEqual(p.source.y, p.target.y)
        }
        XCTAssertEqual(points, emitted(observed))
        XCTAssertTrue(emitted([]).isEmpty)
        XCTAssertTrue(emitted(Array(repeating: observed[0], count: 4)).isEmpty)
        XCTAssertTrue(emitted(observed.map { SIMD2<Float>($0.x, $0.y + 0.15) }).isEmpty)
        let highLips = observed.map { SIMD2<Float>($0.x, $0.y + 0.12) }
        let lowerPair = emitted(highLips)
        XCTAssertEqual(lowerPair.count, 2)
        for point in lowerPair {
            XCTAssertGreaterThanOrEqual(point.target.y - point.radius, 0.75 + 0.8 * 0.04 - 0.000001)
            XCTAssertLessThan(point.radius, 0.04)
            XCTAssertLessThanOrEqual(abs(point.target.x - point.source.x) / point.radius, 0.8)
        }
        XCTAssertTrue(HorizontalInwardWarpSafety.accepts(lowerPair, maximumSlope: 0.8))
    }

    func testRevisedChinDisplacementRetainsOriginalSlopeCeiling() {
        let contour: [SIMD2<Float>] = [
            .init(0.32, 0.72), .init(0.38, 0.76), .init(0.44, 0.80), .init(0.50, 0.82),
            .init(0.56, 0.80), .init(0.62, 0.76), .init(0.68, 0.72)]
        let support = BeautyFaceSemanticSupport(contour: contour,
            medianLine: [.init(0.5, 0.4), .init(0.5, 0.9)], apexIndex: 3)
        let observed = lips.map { SIMD2<Float>(Float($0.x), Float($0.y + 0.05)) }
        let face = FaceGeometry(bounds: .init(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
            faceContour: contour, observedFaceSupport: support, observedOuterLips: observed)
        var active = BeautyEffectiveStrengths(); active.chinTaper = 0.25
        let points = ChinWarpProvider().fieldEmissions(face: face, strengths: active).chinTaper
        XCTAssertEqual(points.count, 6)
        XCTAssertTrue(HorizontalInwardWarpSafety.accepts(points, maximumSlope: 0.8))
        XCTAssertTrue(points.allSatisfy {
            abs($0.target.x - $0.source.x) <= 0.8 * 0.024 && $0.pixelCenterSampling
        })
        XCTAssertTrue(points.contains { abs($0.target.x - $0.source.x) > 0.8 * 0.016 })
        XCTAssertTrue(points.contains {
            abs($0.target.x - $0.source.x) / $0.radius > 0.8 / 3
        }, "Unused shares must be available to narrower eligible supports")
    }

    func testActualPixelsChangeOnlyAroundObservedCornersWithRepeatAndNeutralIdentity() throws {
        let size = 256
        let color = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        var source = [UInt8](repeating: 255, count: size * size * 4)
        for y in 0..<size { for x in 0..<size {
            let i = (y * size + x) * 4
            source[i] = UInt8((x * 13 + y * 7) % 256)
            source[i + 1] = UInt8((x * 3 + y * 17) % 256)
        } }
        let image = CIImage(bitmapData: Data(source), bytesPerRow: size * 4,
                            size: CGSize(width: size, height: size), format: .RGBA8, colorSpace: color)
        let face = geometry(lips)
        func render(_ amount: Float) -> [UInt8] {
            let plan = BeautyEffectResolver.resolve(parameters: .init(mouthWidth: amount), faceGeometry: face)
            let output = BeautyGeometryEffectPipeline.applyMVPProxy(to: image, plan: plan, face: face)
            var bytes = [UInt8](repeating: 0, count: source.count)
            CIContext(options: [.workingColorSpace: color, .outputColorSpace: color]).render(
                output, toBitmap: &bytes, rowBytes: size * 4, bounds: image.extent,
                format: .RGBA8, colorSpace: color)
            return bytes
        }
        let neutral = render(0), output = render(-0.35)
        XCTAssertEqual(neutral, source)
        XCTAssertEqual(output, render(-0.35))
        var inside = 0, outside = 0
        for y in 0..<size { for x in 0..<size {
            let i = (y * size + x) * 4
            XCTAssertEqual(output[i + 3], source[i + 3])
            guard output[i..<i+3] != source[i..<i+3] else { continue }
            let px = Double(x) / Double(size), py = Double(y) / Double(size)
            // Each corner owns at most one quarter of the observed mouth gap;
            // the middle half remains protected independent of field amplitude.
            if abs(py - 0.60) < 0.075 && (abs(px - 0.35) < 0.075 || abs(px - 0.65) < 0.075) {
                inside += 1
            } else { outside += 1 }
        } }
        XCTAssertGreaterThan(inside, 100)
        XCTAssertEqual(outside, 0)
    }
}
