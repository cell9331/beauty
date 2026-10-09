import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import XCTest

@testable import BeautyEffects

final class BeautyDenseGeometryTests: XCTestCase {
    private func denseFace(matrix: [Float]? = nil) throws -> FaceGeometry {
        var points = (0..<478).map { i in
            SIMD3<Float>(0.2 + Float(i % 23) / 40, 0.15 + Float(i / 23) / 30, 0)
        }
        for (i, index) in MediaPipeFaceTopology.oval.enumerated() {
            let angle = Double(i) * 2 * Double.pi / 36
            points[index] = SIMD3<Float>(0.5 + Float(cos(angle)) * 0.3, 0.5 + Float(sin(angle)) * 0.4, 0)
        }
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: points, facialTransformation: matrix))
        return FaceGeometry(
            bounds: FaceBounds(x: 0.2, y: 0.1, width: 0.6, height: 0.8),
            faceContour: [
                SIMD2<Float>(0.2, 0.3), SIMD2<Float>(0.2, 0.5), SIMD2<Float>(0.3, 0.75),
                SIMD2<Float>(0.5, 0.9), SIMD2<Float>(0.7, 0.75), SIMD2<Float>(0.8, 0.5),
                SIMD2<Float>(0.8, 0.3),
            ], denseSupport: BeautyDenseFaceSupport(mesh: mesh))
    }
    private func point(
        _ x: Float = 0.5, y: Float = 0.5, dx: Float = 0.02, dy: Float = 0, radius: Float = 0.12
    ) -> WarpControlPoint {
        WarpControlPoint(
            source: SIMD2<Float>(x - dx, y - dy), target: SIMD2<Float>(x, y), radius: radius, strength: 0.5,
            falloff: 2)
    }
    private func raster(width: Int, height: Int) -> [UInt8] {
        (0..<(width * height)).flatMap { i -> [UInt8] in
            let x = i % width
            let y = i / width
            return [UInt8(x % 256), UInt8(y % 256), UInt8((x / 5 + y / 7) % 2 == 0 ? 40 : 210), 255]
        }
    }

    func testPixelCenterIdentityCoverageAndIndependentTranslationDirection() throws {
        let face = try denseFace()
        XCTAssertNil(BeautyDenseGeometryMap(width: 128, height: 96, face: face, points: []))
        let map = try XCTUnwrap(BeautyDenseGeometryMap(width: 128, height: 96, face: face, points: [point()]))
        let source = raster(width: 128, height: 96)
        let output = map.applyRGBA(source)
        XCTAssertEqual(output.count, source.count)
        // Red encodes x itself: rightward content motion must sample lower x.
        XCTAssertLessThan(output[(48 * 128 + 64) * 4], source[(48 * 128 + 64) * 4])
        for y in [0, 95] {
            for x in 0..<128 {
                XCTAssertEqual(
                    Array(output[(y * 128 + x) * 4..<(y * 128 + x + 1) * 4]),
                    Array(source[(y * 128 + x) * 4..<(y * 128 + x + 1) * 4]))
            }
        }
        for y in 0..<96 {
            for x in [0, 127] {
                XCTAssertEqual(
                    Array(output[(y * 128 + x) * 4..<(y * 128 + x + 1) * 4]),
                    Array(source[(y * 128 + x) * 4..<(y * 128 + x + 1) * 4]))
            }
        }
        XCTAssertEqual(output, map.applyRGBA(source))
        XCTAssertTrue(stride(from: 3, to: output.count, by: 4).allSatisfy { output[$0] == 255 })
        for y in stride(from: 0.0, through: 1.0, by: 0.05) {
            for x in stride(from: 0.0, through: 1.0, by: 0.05) {
                let delta = map.displacement(at: SIMD2<Double>(x, y))
                XCTAssertTrue(delta.x.isFinite && delta.y.isFinite)
            }
        }
    }

    func testPixelMetricFootprintIsCircularOnWideAndTallImages() throws {
        for (width, height) in [(256, 128), (128, 256)] {
            let map = try XCTUnwrap(
                BeautyDenseGeometryMap(
                    width: width, height: height, face: denseFace(), points: [point(radius: 0.16)]))
            let distance = Double(width) * 0.06
            let horizontal = map.displacement(at: SIMD2<Double>(0.5 + distance / Double(width), 0.5))
            let vertical = map.displacement(at: SIMD2<Double>(0.5, 0.5 + distance / Double(height)))
            XCTAssertEqual(horizontal.x, vertical.x, accuracy: 0.12)
            XCTAssertEqual(horizontal.y, vertical.y, accuracy: 0.000001)
        }
    }

    func testExtremeCompositionHasBoundedDisplacementAndPositiveAllTriangleAreas() throws {
        let face = try denseFace()
        var points = [WarpControlPoint]()
        for i in 0..<400 {
            let x: Float = 0.3 + Float(i % 20) * 0.02
            let y: Float = 0.3 + Float(i / 20) * 0.02
            let dx: Float = i % 2 == 0 ? 0.09 : -0.09
            let dy: Float = i % 3 == 0 ? 0.08 : -0.08
            points.append(point(x, y: y, dx: dx, dy: dy, radius: 0.2))
        }
        let map = try XCTUnwrap(BeautyDenseGeometryMap(width: 256, height: 160, face: face, points: points))
        XCTAssertLessThan(map.appliedScale, 1)
        XCTAssertLessThanOrEqual(map.maximumDisplacement, 160 * 0.8 * 0.06 + 0.00001)
        XCTAssertLessThanOrEqual(map.maximumGradient, 0.45 + 0.000001)
        // Independently compute oriented source triangle area, not the map's
        // admission flag. Entire fixed output topology must survive.
        func node(_ col: Int, _ row: Int) -> SIMD2<Double> {
            SIMD2<Double>(map.xs[col] * 256, map.ys[row] * 160) - map.offsets[row * map.xs.count + col]
        }
        func area(_ a: SIMD2<Double>, _ b: SIMD2<Double>, _ c: SIMD2<Double>) -> Double {
            (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
        }
        for row in 0..<(map.ys.count - 1) {
            for col in 0..<(map.xs.count - 1) {
                let a = node(col, row)
                let b = node(col + 1, row)
                let c = node(col + 1, row + 1)
                let d = node(col, row + 1)
                let dx = (map.xs[col + 1] - map.xs[col]) * 256
                let dy = (map.ys[row + 1] - map.ys[row]) * 160
                let original = dx * dy
                XCTAssertGreaterThan(area(a, b, c), original * 0.30)
                XCTAssertGreaterThan(area(a, c, d), original * 0.30)
            }
        }
        XCTAssertLessThanOrEqual(map.xs.count, 60)
        XCTAssertLessThanOrEqual(map.ys.count, 60)
    }

    func testInvalidCandidateAbstainsAndRowOwnedProtectionRemainsExact() throws {
        let face = try denseFace()
        var bad = point()
        bad = WarpControlPoint(
            source: SIMD2<Float>(.nan, 0.5), target: bad.target, radius: bad.radius, strength: 0.5, falloff: 2
        )
        XCTAssertNil(BeautyDenseGeometryMap(width: 128, height: 96, face: face, points: [bad]))
        var cutoff = point(y: 0.43)
        cutoff.exclusiveMaximumY = 0.5
        let map = try XCTUnwrap(BeautyDenseGeometryMap(width: 128, height: 96, face: face, points: [cutoff]))
        let source = raster(width: 128, height: 96)
        let output = map.applyRGBA(source)
        XCTAssertNotEqual(source, output)
        XCTAssertEqual(Array(output[(48 * 128 * 4)...]), Array(source[(48 * 128 * 4)...]))
        var dumpOutput = ""
        dump(map, to: &dumpOutput)
        XCTAssertFalse(dumpOutput.contains("SIMD"))
        XCTAssertFalse(dumpOutput.contains("offsets"))
    }

    func testSourceFixedRingAndImpulseMoveBothDirectionsWithoutTouchingExterior() throws {
        let width = 128
        let height = 96
        for ring in [false, true] {
            var source = [UInt8](repeating: 128, count: width * height * 4)
            for y in 0..<height {
                for x in 0..<width {
                    let distance = hypot(Double(x) - 63.5, Double(y) - 47.5)
                    let marked = ring ? (distance >= 5 && distance <= 7) : (distance <= 1.5)
                    let offset = (y * width + x) * 4
                    source[offset] = marked ? 20 : 128
                    source[offset + 3] = 255
                }
            }
            func centroid(_ bytes: [UInt8]) -> Double {
                var weightedX = 0.0
                var total = 0.0
                for y in 30..<66 {
                    for x in 45..<83 {
                        let weight = max(0, 128 - Int(bytes[(y * width + x) * 4]))
                        weightedX += Double(x) * Double(weight)
                        total += Double(weight)
                    }
                }
                return weightedX / total
            }
            let baseline = centroid(source)
            for direction: Float in [-1, 1] {
                let map = try XCTUnwrap(
                    BeautyDenseGeometryMap(
                        width: width, height: height,
                        face: denseFace(), points: [point(dx: direction * 0.02, radius: 0.16)]))
                let output = map.applyRGBA(source)
                XCTAssertGreaterThan((centroid(output) - baseline) * Double(direction), 0.2)
                XCTAssertTrue(Array(output[0..<(20 * width * 4)]) == Array(source[0..<(20 * width * 4)]))
                XCTAssertTrue(stride(from: 3, to: output.count, by: 4).allSatisfy { output[$0] == 255 })
            }
        }
    }

    func testDenseImageRouteKeepsNonzeroExtentColorAndRepeatBytes() throws {
        let source = raster(width: 128, height: 96)
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let image = CIImage(
            bitmapData: Data(source), bytesPerRow: 512,
            size: CGSize(width: 128, height: 96), format: .RGBA8, colorSpace: colorSpace
        )
        .transformed(by: CGAffineTransform(translationX: 7, y: -3))
        let face = try denseFace()
        var strengths = BeautyEffectiveStrengths()
        strengths.faceSlim = 0.4
        let plan = BeautyEffectPlan(activeDomains: [.faceShape], effectiveStrengths: strengths)
        let first = BeautyGeometryEffectPipeline.applyMVPProxy(to: image, plan: plan, face: face)
        let repeated = BeautyGeometryEffectPipeline.applyMVPProxy(to: image, plan: plan, face: face)
        XCTAssertEqual(first.extent, image.extent)
        XCTAssertEqual(first.colorSpace?.name, colorSpace.name)
        func bytes(_ image: CIImage) -> [UInt8] {
            var result = [UInt8](repeating: 0, count: source.count)
            BeautyImageContexts.context(for: colorSpace).render(
                image, toBitmap: &result,
                rowBytes: 512, bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
            return result
        }
        XCTAssertTrue(bytes(first) != source)
        XCTAssertTrue(bytes(first) == bytes(repeated))
        let neutral = BeautyGeometryEffectPipeline.applyMVPProxy(to: image, plan: .init(), face: face)
        XCTAssertTrue(bytes(neutral) == source)
    }

    func testValidatedPoseAttenuatesYawPitchButNotRollAndRejectsShear() throws {
        func rotation(yaw: Double = 0, pitch: Double = 0, roll: Double = 0) -> [Float] {
            let cy = cos(yaw)
            let sy = sin(yaw)
            let cp = cos(pitch)
            let sp = sin(pitch)
            let cr = cos(roll)
            let sr = sin(roll)
            return [
                cr * cy, cr * sy * sp - sr * cp, cr * sy * cp + sr * sp, 2,
                sr * cy, sr * sy * sp + cr * cp, sr * sy * cp - cr * sp, 3,
                -sy, cy * sp, cy * cp, 4, 0, 0, 0, 1,
            ].map(Float.init)
        }
        XCTAssertEqual(BeautyDenseFaceSupport.poseScale(rotation()), 1)
        XCTAssertEqual(BeautyDenseFaceSupport.poseScale(rotation(roll: 1.2)), 1)
        for matrix in [rotation(yaw: 0.9), rotation(yaw: -0.9), rotation(pitch: 0.9)] {
            let scale = try XCTUnwrap(BeautyDenseFaceSupport.poseScale(matrix))
            XCTAssertGreaterThan(scale, 0)
            XCTAssertLessThan(scale, 0.6)
        }
        XCTAssertEqual(BeautyDenseFaceSupport.poseScale(rotation(yaw: 1.3)), 0)
        XCTAssertEqual(BeautyDenseFaceSupport.poseScale(rotation(yaw: .pi)), 0)
        XCTAssertNil(
            BeautyDenseGeometryMap(
                width: 128, height: 96, face: try denseFace(matrix: rotation(yaw: 1.3)), points: [point()]))
        var shear = rotation()
        shear[1] = 0.5
        XCTAssertNil(BeautyDenseFaceSupport.poseScale(shear))
        var scaled = rotation()
        for i in [0, 5, 10] { scaled[i] *= 2 }
        XCTAssertEqual(BeautyDenseFaceSupport.poseScale(scaled), 1)
    }
}
