import BeautyCore
import BeautyDetection
import XCTest

@testable import BeautyEffects

final class BeautyDenseSupportTests: XCTestCase {
    private func mesh(closed: Bool = false, partial: Bool = false, invalidIris: Bool = false) throws
        -> BeautyFaceMesh
    {
        var points = Array(repeating: SIMD3<Float>(0.5, 0.5, 0), count: 478)
        func ellipse(_ indices: [Int], x: Float, y: Float, rx: Float, ry: Float) {
            for (i, index) in indices.enumerated() {
                let a = Float(i) * 2 * Float.pi / Float(indices.count)
                points[index] = SIMD3<Float>(x + cos(a) * rx, y + sin(a) * ry, 0)
            }
        }
        ellipse(MediaPipeFaceTopology.oval, x: 0.5, y: 0.5, rx: 0.3, ry: 0.4)
        ellipse(
            MediaPipeFaceTopology.leftEye, x: 0.4, y: 0.55, rx: 0.06,
            ry: closed ? 0.002 : (partial ? 0.012 : 0.035))
        ellipse(MediaPipeFaceTopology.rightEye, x: 0.6, y: 0.55, rx: 0.06, ry: 0.035)
        ellipse(MediaPipeFaceTopology.leftIris, x: 0.41, y: 0.55, rx: 0.015, ry: 0.015)
        ellipse(MediaPipeFaceTopology.rightIris, x: 0.6, y: 0.55, rx: 0.015, ry: 0.015)
        points[468] = SIMD3<Float>(invalidIris ? 0.9 : 0.41, 0.55, 0)
        points[473] = SIMD3<Float>(0.6, 0.55, 0)
        ellipse(MediaPipeFaceTopology.leftBrowEnvelope, x: 0.4, y: 0.47, rx: 0.06, ry: 0.01)
        ellipse(MediaPipeFaceTopology.rightBrowEnvelope, x: 0.6, y: 0.47, rx: 0.06, ry: 0.01)
        ellipse(MediaPipeFaceTopology.outerLip, x: 0.5, y: 0.68, rx: 0.08, ry: 0.035)
        ellipse(MediaPipeFaceTopology.innerLip, x: 0.5, y: 0.68, rx: 0.06, ry: 0.02)
        return try XCTUnwrap(BeautyFaceMesh(points: points))
    }
    private func eye(_ mesh: BeautyFaceMesh) -> BeautyEyeSemanticSupport {
        let contour = BeautyDenseFaceSupport.path(mesh, MediaPipeFaceTopology.leftEye)
        return BeautyEyeSemanticSupport(
            side: .left, contour: contour, upper: [], lower: [], inner: [], outer: [], corners: [],
            center: SIMD2<Float>(0.4, 0.55), pupil: SIMD2<Float>(0.41, 0.55), span: SIMD2<Float>(0.12, 0.07),
            tilt: 0)
    }
    func testIrisRingOwnsSizeAndGazeAndClosedOrInvalidSideAbstains() throws {
        for (closed, partial, invalid) in [
            (false, false, false), (false, true, false), (true, false, false), (false, false, true),
        ] {
            let mesh = try mesh(closed: closed, partial: partial, invalidIris: invalid)
            let support = eye(mesh)
            let dense = BeautyDenseFaceSupport(mesh: mesh)
            let rightContour = BeautyDenseFaceSupport.path(mesh, MediaPipeFaceTopology.rightEye)
            let right = BeautyEyeSemanticSupport(
                side: .right, contour: rightContour, upper: [], lower: [], inner: [], outer: [], corners: [],
                center: SIMD2<Float>(0.6, 0.55), pupil: SIMD2<Float>(0.6, 0.55),
                span: SIMD2<Float>(0.12, 0.07), tilt: 0)
            let face = FaceGeometry(
                bounds: FaceBounds(x: 0.2, y: 0.1, width: 0.6, height: 0.8), faceContour: [],
                leftEyeSupport: support, rightEyeSupport: right, denseSupport: dense)
            var strengths = BeautyEffectiveStrengths()
            strengths.pupilSize = 0.25
            strengths.gazeCorrection = 0.25
            let emissions = EyeWarpProvider().fieldEmissions(face: face, strengths: strengths)
            let leftSize = emissions.pupilSize.filter { $0.source.x < 0.5 }
            XCTAssertEqual(emissions.pupilSize.filter { $0.source.x > 0.5 }.count, 4)
            if closed || invalid {
                XCTAssertNil(dense.iris(side: .left, eye: support))
                XCTAssertTrue(leftSize.isEmpty)
                XCTAssertTrue(emissions.gazeCorrection.isEmpty)
            } else {
                let ring = try XCTUnwrap(dense.iris(side: .left, eye: support))
                XCTAssertTrue(leftSize.map(\.source) == ring)
                XCTAssertEqual(ring.count, partial ? 2 : 4)
                XCTAssertEqual(emissions.gazeCorrection.count, 1)
                for point in leftSize {
                    let source = point.source - support.pupil!
                    let target = point.target - support.pupil!
                    XCTAssertGreaterThan(
                        target.x * target.x + target.y * target.y, source.x * source.x + source.y * source.y)
                }
            }
        }
    }
    func testVisibleIrisRingEnlargesSourceDefinedDarkDiskPixels() throws {
        let mesh = try mesh()
        let left = eye(mesh)
        let rightContour = BeautyDenseFaceSupport.path(mesh, MediaPipeFaceTopology.rightEye)
        let right = BeautyEyeSemanticSupport(
            side: .right, contour: rightContour, upper: [], lower: [],
            inner: [], outer: [], corners: [], center: SIMD2<Float>(0.6, 0.55),
            pupil: SIMD2<Float>(0.6, 0.55), span: SIMD2<Float>(0.12, 0.07), tilt: 0)
        let face = FaceGeometry(
            bounds: FaceBounds(x: 0.2, y: 0.1, width: 0.6, height: 0.8),
            faceContour: [], leftEyeSupport: left, rightEyeSupport: right,
            denseSupport: BeautyDenseFaceSupport(mesh: mesh))
        var strengths = BeautyEffectiveStrengths()
        strengths.pupilSize = 0.25
        let points = EyeWarpProvider().fieldEmissions(face: face, strengths: strengths).pupilSize
        let width = 256
        let height = 256
        var source = [UInt8](repeating: 160, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let index = (y * width + x) * 4
                let px = (Double(x) + 0.5) / Double(width)
                let py = (Double(y) + 0.5) / Double(height)
                if hypot(px - 0.41, py - 0.55) < 0.014 || hypot(px - 0.6, py - 0.55) < 0.014 {
                    source[index] = 40
                }
                source[index + 3] = 255
            }
        }
        let map = try XCTUnwrap(
            BeautyDenseGeometryMap(width: width, height: height, face: face, points: points))
        let output = map.applyRGBA(source)
        func darkArea(_ bytes: [UInt8], centerX: Double) -> Double {
            var sum = 0.0
            for y in 132..<150 {
                for x in Int(centerX * 256 - 9)..<Int(centerX * 256 + 9) {
                    sum += Double(max(0, 160 - Int(bytes[(y * width + x) * 4]))) / 120
                }
            }
            return sum
        }
        for center in [0.41, 0.6] {
            XCTAssertGreaterThan(darkArea(output, centerX: center), darkArea(source, centerX: center) * 1.05)
        }
        XCTAssertTrue(Array(output[0..<(100 * width * 4)]) == Array(source[0..<(100 * width * 4)]))
        XCTAssertTrue(output == map.applyRGBA(source))
    }

    func testDegenerateOrCrossingOvalCannotAuthorizeTexture() throws {
        let valid = try mesh()
        var points = valid.points
        for index in MediaPipeFaceTopology.oval { points[index] = SIMD3<Float>(0.5, 0.5, 0) }
        let collapsed = BeautyDenseFaceSupport(mesh: try XCTUnwrap(BeautyFaceMesh(points: points)))
        XCTAssertFalse(collapsed.admitsTexture(x: 64, y: 64, width: 128, height: 128, radius: 2))
        let square = [
            SIMD2<Float>(0.2, 0.2), SIMD2<Float>(0.8, 0.2), SIMD2<Float>(0.8, 0.8), SIMD2<Float>(0.2, 0.8),
        ]
        XCTAssertTrue(BeautyDenseFaceSupport.simplePolygon(square))
        XCTAssertFalse(BeautyDenseFaceSupport.simplePolygon([square[0], square[2], square[1], square[3]]))
        XCTAssertFalse(BeautyDenseFaceSupport.simplePolygon(square + [square[0]]))
    }

    func testDarkSkinNoiseSmoothingAndFeatureProtection() throws {
        let dense = BeautyDenseFaceSupport(mesh: try mesh())
        var strengths = BeautyEffectiveStrengths()
        strengths.skinSmoothing = 0.6
        let plan = BeautyEffectPlan(activeDomains: [.skin], effectiveStrengths: strengths)
        let width = 128
        let height = 128
        let source = (0..<(width * height)).flatMap { i -> [UInt8] in
            let noise = (i % width / 2 + i / width / 2) % 2 == 0 ? 4 : -4
            return [UInt8(51 + noise), UInt8(34 + noise), UInt8(21 + noise), 255]
        }
        let output = BeautySkinTexturePipeline.applyRGBA(
            source, width: width, height: height,
            plan: plan, faceBounds: CoordinateRect(x: 0.2, y: 0.1, width: 0.6, height: 0.8),
            denseSupport: dense)
        func deviation(_ bytes: [UInt8]) -> Double {
            var sum = 0.0
            for y in 73..<79 { for x in 33..<39 { sum += abs(Double(bytes[(y * width + x) * 4]) - 51) } }
            return sum / 36
        }
        XCTAssertLessThan(deviation(output), deviation(source) * 0.65)
        for y in 68..<73 {
            for x in 49..<54 {
                let index = (y * width + x) * 4
                XCTAssertTrue(Array(output[index..<index + 4]) == Array(source[index..<index + 4]))
            }
        }
        XCTAssertTrue(stride(from: 3, to: output.count, by: 4).allSatisfy { output[$0] == 255 })
    }

    func testDenseFeatureExclusionAddsToCoarseGuardWithoutClaimingSegmentation() throws {
        let dense = BeautyDenseFaceSupport(mesh: try mesh())
        var strengths = BeautyEffectiveStrengths()
        strengths.skinSmoothing = 0.6
        let plan = BeautyEffectPlan(activeDomains: [.skin], effectiveStrengths: strengths)
        let width = 128
        let height = 128
        let source = (0..<(width * height)).flatMap { i -> [UInt8] in
            let value: UInt8 = (i % width / 2 + i / width / 2) % 2 == 0 ? 170 : 150
            return [value, value - 20, value - 35, 255]
        }
        let bounds = CoordinateRect(x: 0.2, y: 0.1, width: 0.6, height: 0.8)
        let coarse = BeautySkinTexturePipeline.applyRGBA(
            source, width: width, height: height, plan: plan, faceBounds: bounds)
        let output = BeautySkinTexturePipeline.applyRGBA(
            source, width: width, height: height, plan: plan,
            faceBounds: bounds, denseSupport: dense)
        // Eye at y=.55 lies outside the old rectangle (.268 ... .452).
        let index = (70 * width + 51) * 4
        XCTAssertNotEqual(Array(coarse[index..<index + 4]), Array(source[index..<index + 4]))
        XCTAssertEqual(Array(output[index..<index + 4]), Array(source[index..<index + 4]))
        let cheek = (78 * width + 39) * 4
        XCTAssertNotEqual(Array(output[cheek..<cheek + 4]), Array(source[cheek..<cheek + 4]))
        XCTAssertEqual(
            output,
            BeautySkinTexturePipeline.applyRGBA(
                source, width: width, height: height, plan: plan,
                faceBounds: bounds, denseSupport: dense))
        var dumpOutput = ""
        dump(dense, to: &dumpOutput)
        XCTAssertFalse(dumpOutput.contains("SIMD"))
    }
}
