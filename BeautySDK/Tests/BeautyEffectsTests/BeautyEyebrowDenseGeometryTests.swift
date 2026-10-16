import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

/// Native topology wiring, using invented geometry and an independently drawn
/// source. The 478-point carrier uses MediaPipe's actual ordered feature IDs;
/// no private image or detected landmark coordinates are stored here.
final class BeautyEyebrowDenseGeometryTests: XCTestCase {
    private let width = 400, height = 480
    private let center = SIMD2(200.0, 240)

    private enum HeadShape: Equatable {
        case ordinary, verticalUpperEdge, returningUpperEdge
    }

    private struct Fixture {
        let face: FaceGeometry
        let pixels: [UInt8]
    }

    private func rotate(_ point: SIMD2<Double>, angle: Double) -> SIMD2<Double> {
        let relative = point - center
        return center + SIMD2(relative.x * cos(angle) - relative.y * sin(angle),
                              relative.x * sin(angle) + relative.y * cos(angle))
    }

    private func fixture(shape: HeadShape = .ordinary, angle: Double = 0,
                         weakShoulder: Bool = false, halfThickness: Double = 4,
                         asymmetric: Bool = false) throws -> Fixture {
        var points = [SIMD2<Double>](repeating: center, count: 478)
        let eyeY = asymmetric ? 205.0 : 230.0
        func put(_ index: Int, _ point: SIMD2<Double>) { points[index] = point }
        func ellipse(_ indices: [Int], center: SIMD2<Double>, radii: SIMD2<Double>,
                     phase: Double = 0, direction: Double = 1) {
            for (offset, index) in indices.enumerated() {
                let a = phase + 2 * Double.pi * Double(offset) / Double(indices.count)
                put(index, center + SIMD2(direction * radii.x * cos(a), radii.y * sin(a)))
            }
        }
        ellipse(MediaPipeFaceTopology.oval, center: SIMD2(200, 244), radii: SIMD2(150, 210), phase: -.pi / 2)
        for (indices, eyeCenter, direction) in [
            (MediaPipeFaceTopology.leftEye, SIMD2(146.0, eyeY), -1.0),
            (MediaPipeFaceTopology.rightEye, SIMD2(254.0, eyeY), 1.0)
        ] {
            ellipse(indices, center: eyeCenter, radii: SIMD2(24, 10), direction: direction)
        }
        ellipse(MediaPipeFaceTopology.leftIris, center: SIMD2(146, eyeY), radii: SIMD2(6, 6))
        ellipse(MediaPipeFaceTopology.rightIris, center: SIMD2(254, eyeY), radii: SIMD2(6, 6))
        put(468, SIMD2(146, eyeY)); put(473, SIMD2(254, eyeY))
        ellipse(MediaPipeFaceTopology.outerLip, center: SIMD2(200, 369), radii: SIMD2(47, 15), phase: .pi)
        ellipse(MediaPipeFaceTopology.innerLip, center: SIMD2(200, 369), radii: SIMD2(33, 6), phase: .pi)
        ellipse(MediaPipeFaceTopology.noseContour, center: SIMD2(200, 293), radii: SIMD2(25, 27))
        for (offset, index) in MediaPipeFaceTopology.noseCrest.enumerated() {
            put(index, SIMD2(200, 238 + Double(offset) * 10))
        }
        put(193, SIMD2(187, 238)); put(417, SIMD2(213, 238))

        // The five upper points are the semantic trace. The lower edge has
        // different head/tail projections: [4,88], versus the upper [0,84].
        // This is a closed native envelope, not two equal-column polylines.
        let second: SIMD2<Double>
        switch shape {
        case .ordinary: second = SIMD2(20, -12)
        case .verticalUpperEdge: second = SIMD2(0, -9)
        case .returningUpperEdge: second = SIMD2(-1.5, -9)
        }
        let outline = [SIMD2(0.0, -4), second, SIMD2(44, -18), SIMD2(68, -12), SIMD2(84, -4),
                       SIMD2(88, 4), SIMD2(69, -2), SIMD2(42, -8), SIMD2(18, -4), SIMD2(4, 4)]
        for (indices, headX, direction) in [
            (MediaPipeFaceTopology.leftBrowEnvelope, 176.0, -1.0),
            (MediaPipeFaceTopology.rightBrowEnvelope, 224.0, 1.0)
        ] {
            // Different joint ridge/thickness extrema and eye clearances are
            // deliberate. Both source cores remain inside the measured native
            // envelopes, with the same face frame and projection length.
            let localOutline = asymmetric && direction > 0
                ? [SIMD2(0.0,-4),SIMD2(20,-20),SIMD2(44,-28),SIMD2(68,-17),SIMD2(84,-4),
                   SIMD2(88,5),SIMD2(69,-6),SIMD2(42,-12),SIMD2(18,-7),SIMD2(4,6)] : outline
            let headY = asymmetric && direction < 0 ? 135.0 : 165.0
            for (index, point) in zip(indices, localOutline) {
                put(index, SIMD2(headX + point.x * direction, headY + point.y))
            }
        }

        let normalized = points.map { point -> SIMD3<Float> in
            let rolled = rotate(point, angle: angle)
            // Native normalized landmarks address pixel boundaries; integer
            // pixel centres therefore convert with the explicit half pixel.
            return SIMD3(Float((rolled.x + 0.5) / Double(width)),
                         Float((rolled.y + 0.5) / Double(height)), 0)
        }
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: normalized))
        let observation = try XCTUnwrap(MediaPipeFaceTopology.observation(from: mesh))
        let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        XCTAssertNotNil(face.denseSupport)
        XCTAssertNotNil(face.observedEyebrowSupport?.left)
        XCTAssertNotNil(face.observedEyebrowSupport?.right)
        XCTAssertFalse(face.leftEye.isEmpty)
        XCTAssertFalse(face.rightEye.isEmpty)

        var pixels = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let base = rotate(SIMD2(Double(x), Double(y)), angle: -angle)
            // The source is a smooth sinusoidal tube, independent of the ten
            // landmark vertices and independent of the candidate warp.
            let sourceCores = [(176.0, -1.0), (224.0, 1.0)].map { headX, direction in
                let r = (base.x - headX) * direction
                let clamped = min(84, max(0, r))
                let arch = asymmetric && direction > 0 ? 20.0 : 12.0
                let headY = asymmetric && direction < 0 ? 135.0 : 165.0
                let wave = sin(.pi * clamped / 84)
                let ridgeY = headY - arch * wave
                let half = asymmetric && direction > 0 ? halfThickness * (0.75 + wave*wave) : halfThickness
                return (distance: hypot(r - clamped, base.y - ridgeY), half: half)
            }
            let distance = sourceCores.map(\.distance).min()!
            let index = (y * width + x) * 4
            if sourceCores.contains(where: { $0.distance <= $0.half }) {
                pixels[index] = 35; pixels[index + 1] = 28; pixels[index + 2] = 24
            } else {
                // Independent photometric stressor: a broad skin-coloured
                // shadow is only 35 levels darker than bare skin. It is wider
                // than the dark hair core and fades over its last three px.
                let edge = min(1, max(0, (distance - 9) / 3))
                let shoulder = weakShoulder ? 35 * (1 - edge * edge * (3 - 2 * edge)) : 0
                pixels[index] = UInt8((195 + 10 * sin(base.x * 0.03) + 4 * cos(base.y * 0.02) - shoulder).rounded())
                pixels[index + 1] = UInt8((155 + 8 * sin(base.x * 0.02) + 5 * cos(base.y * 0.03) - shoulder).rounded())
                pixels[index + 2] = UInt8((132 + 7 * sin(base.x * 0.025) - shoulder).rounded())
            }
        } }
        return Fixture(face: face, pixels: pixels)
    }

    private func strengths(_ index: Int, _ value: Float = 0.75) -> BeautyEffectiveStrengths {
        var result = BeautyEffectiveStrengths()
        result[keyPath: BeautyContinuousEyebrowMap.keys[index]] = BeautyContinuousEyebrowMap.caps[index] * value
        return result
    }

    private func assertSourceGeometry(_ fixture: Fixture,
                                      file: StaticString = #filePath, line: UInt = #line) throws {
        let frame = try XCTUnwrap(BeautyEyebrowSourceGeometry.frame(face: fixture.face, width: width, height: height),
                                  file: file, line: line)
        for trace in [fixture.face.observedEyebrowSupport?.left, fixture.face.observedEyebrowSupport?.right] {
            let trace = try XCTUnwrap(trace, file: file, line: line)
            let geometry = try XCTUnwrap(BeautyEyebrowSourceGeometry.make(width: width, height: height,
                face: fixture.face, trace: trace, sourceRGBA: fixture.pixels,
                horizontal: frame.horizontal, vertical: frame.vertical), file: file, line: line)
            XCTAssertGreaterThan(geometry.length, 80, file: file, line: line)
            XCTAssertGreaterThan(geometry.upper.value(at: geometry.length * 0.5), 0, file: file, line: line)
            XCTAssertGreaterThan(geometry.lower.value(at: geometry.length * 0.5), 0, file: file, line: line)
        }
    }

    func testThicknessAndLengthCombinationUsesTheSameDenseGeometry() throws {
        let fixture = try fixture(shape: .returningUpperEdge, angle: 0.28)
        for thickness: Float in [-0.25, 0.25] {
            for length: Float in [-0.16, 0.1368159] {
                var values = BeautyEffectiveStrengths()
                values.eyebrowThickness = thickness
                values.eyebrowLength = length
                let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                    face: fixture.face, strengths: values, sourceRGBA: fixture.pixels))
                XCTAssertEqual(map.admittedBrowCount, 2)
                XCTAssertNotEqual(map.applyRGBA(fixture.pixels), fixture.pixels)
                XCTAssertLessThanOrEqual(map.maximumInverseContraction, BeautyContinuousEyebrowMap.gradientBudget + 1e-9)
            }
        }
    }

    func testAsymmetricDensePeakMovesBothSourceBrowsAtBothSigns() throws {
        let fixture = try fixture(asymmetric: true)
        try assertSourceGeometry(fixture)
        let frame = try XCTUnwrap(BeautyEyebrowSourceGeometry.frame(face: fixture.face, width: width, height: height))
        let calibration = BeautyEyebrowDisplacementModel.Calibration()
        for sign: Float in [-1,1] {
            let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                face: fixture.face, strengths: strengths(6,sign), sourceRGBA: fixture.pixels))
            var appliedCounts = [Int]()
            let output = map.applyRGBA(fixture.pixels,onAppliedSideCount:{ appliedCounts.append($0) })
            XCTAssertEqual(appliedCounts,[2],"both asymmetric source cores must actually be admitted")
            XCTAssertLessThanOrEqual(map.maximumGradient,BeautyContinuousEyebrowMap.gradientBudget+1e-9,
                                     "single peak keeps its Euclidean contraction certificate")
            for trace in [fixture.face.observedEyebrowSupport?.left,fixture.face.observedEyebrowSupport?.right] {
                let trace = try XCTUnwrap(trace)
                let geometry = try XCTUnwrap(BeautyEyebrowSourceGeometry.make(width: width, height: height,
                    face: fixture.face, trace: trace, sourceRGBA: fixture.pixels,
                    horizontal: frame.horizontal, vertical: frame.vertical))
                let r=geometry.length*calibration.peakPositionT
                let point=geometry.origin+geometry.outward*r+geometry.vertical*geometry.ridge.value(at:r)
                let displacement=map.displacement(at:point)
                let signedLift = -(displacement.x*frame.vertical.x+displacement.y*frame.vertical.y)*Double(sign)
                XCTAssertGreaterThan(signedLift,geometry.length*0.015,"\(trace.side): each peak has actual core motion")
                let before=peakMarker(fixture.pixels,isLeft:trace.side == .left)
                let after=peakMarker(output,isLeft:trace.side == .left)
                XCTAssertGreaterThan(before.mass,100,"independent source texture marker exists")
                XCTAssertGreaterThan(after.mass,100,"the source marker remains visible")
                XCTAssertGreaterThan((before.y-after.y)*Double(sign),0.5,
                                     "\(trace.side): each peak must visibly move its own source texture")
            }
        }
    }

    func testAsymmetricDenseSpacingAndHeadSpacingHaveFullVisibleMotionOnBothSides() throws {
        let fixture = try fixture(asymmetric: true)
        try assertSourceGeometry(fixture)
        let frame = try XCTUnwrap(BeautyEyebrowSourceGeometry.frame(face: fixture.face, width: width, height: height))
        for index in [3,4] { for sign: Float in [-1,1] {
            let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                face: fixture.face, strengths: strengths(index,sign), sourceRGBA: fixture.pixels))
            var appliedCounts = [Int]()
            let output=map.applyRGBA(fixture.pixels,onAppliedSideCount:{ appliedCounts.append($0) })
            XCTAssertEqual(appliedCounts,[2])
            XCTAssertNotEqual(output,fixture.pixels)
            XCTAssertLessThanOrEqual(map.maximumInverseContraction,BeautyContinuousEyebrowMap.gradientBudget+1e-9)
            for trace in [fixture.face.observedEyebrowSupport?.left,fixture.face.observedEyebrowSupport?.right] {
                let trace=try XCTUnwrap(trace)
                let geometry=try XCTUnwrap(BeautyEyebrowSourceGeometry.make(width: width, height: height,
                    face: fixture.face, trace: trace, sourceRGBA: fixture.pixels,
                    horizontal: frame.horizontal, vertical: frame.vertical))
                let r=geometry.length*0.12
                let point=geometry.origin+geometry.outward*r+geometry.vertical*geometry.ridge.value(at:r)
                let displacement=map.displacement(at:point)
                let horizontal=displacement.x*geometry.outward.x+displacement.y*geometry.outward.y
                let vertical=displacement.x*frame.vertical.x+displacement.y*frame.vertical.y
                let minimumFullPixels=index == 3 ? 2.0 : 3.0
                XCTAssertGreaterThan(horizontal*Double(sign),minimumFullPixels,
                                     "field \(index), \(trace.side): full control has actual horizontal motion")
                XCTAssertEqual(vertical,0,accuracy:1e-9)
            }
        } }
    }

    func testOneULPNativeStationEndpointCannotInflateScalarAdmissionBounds() throws {
        typealias Model=BeautyEyebrowDisplacementModel
        // This is the production source measurement's 49-station arithmetic.
        // Multiplying and dividing does not always reproduce the exact model
        // endpoint. Both directions below create a real one-ULP cell at L.
        for length in [Double(100).nextUp.nextUp,Double(100).nextDown.nextDown] {
            let stations=(0..<49).map { length*Double($0)/48 }
            let endpoint=try XCTUnwrap(stations.last)
            XCTAssertNotEqual(endpoint,length,"the regression must actually contain the near-coincident knots")
            XCTAssertEqual(abs(endpoint-length),length.ulp)
            var exactStations=stations
            exactStations[48]=length
            func field(_ positions: [Double], _ index: Int) throws -> Model {
                let ridge=try XCTUnwrap(Model.Profile(samples:positions.map { SIMD2($0,0) }))
                let thickness=try XCTUnwrap(Model.Profile(samples:positions.map { SIMD2($0,4) }))
                let geometry=Model.Geometry(origin:.zero,horizontal:SIMD2(1,0),vertical:SIMD2(0,1),
                    isLeft:false,length:length,ridge:ridge,upper:thickness,lower:thickness)
                var values=[Double](repeating:0,count:7)
                values[index]=1
                let support=Model.Support(upper:length*0.35,lower:length*0.25,head:length*0.30,tail:length*0.30)
                return try XCTUnwrap(Model(geometry:geometry,values:values,supports:Array(repeating:support,count:7),
                    ownerBoundary:-length,ownerTransition:length*0.05))
            }
            for index in [3,4,6] {
                let near=try field(stations,index),reference=try field(exactStations,index)
                XCTAssertTrue(near.maximumGradient.isFinite)
                XCTAssertGreaterThan(reference.maximumGradient,0)
                XCTAssertLessThanOrEqual(near.maximumGradient,reference.maximumGradient*1.001+1e-9,
                    "field \(index): a rounding-width cell must not amplify Bernstein coefficient error")
                XCTAssertLessThanOrEqual(near.inverseContraction,reference.inverseContraction*1.001+1e-9)
                let scale=min(1,BeautyContinuousEyebrowMap.gradientBudget/near.inverseContraction)
                let admitted=try XCTUnwrap(near.scaled(by:scale))
                let position=index == 6 ? Model.Calibration().peakPositionT : 0.12
                let point=SIMD2(length*position,0.0)
                let actual=admitted.displacement(at:point)
                XCTAssertGreaterThan(hypot(actual.x,actual.y),length*0.03,
                    "field \(index): an artificial derivative spike cannot collapse a valid core response")
            }
        }
    }

    /// A source-only dark-texture centroid, using the independently drawn tube
    /// and a fixed inner/outer band. It never consults a candidate field/mask.
    private func peakMarker(_ pixels: [UInt8], isLeft: Bool) -> (mass: Double,y: Double) {
        let headX=isLeft ? 176.0 : 224.0, direction=isLeft ? -1.0 : 1.0
        var mass=0.0,moment=0.0
        for y in 0..<height { for x in 0..<width {
            let r=(Double(x)-headX)*direction
            guard r >= 84*0.52, r <= 84*0.84 else { continue }
            let weight=Double(max(0,100-Int(pixels[(y*width+x)*4])))
            mass += weight; moment += (Double(y)+0.5)*weight
        } }
        return (mass,mass > 0 ? moment/mass : .nan)
    }

    func testNarrowStrongCoreWithBroadWeakShouldersStillAdmitsLengthAndThickness() throws {
        let fixture = try fixture(weakShoulder: true)
        // The generated source has an 8 px dark core. Its 35-level shoulder is
        // about .26L wide, above 20% of the hair contrast but below half-max.
        // It must not be treated as an excessively broad strong hair core.
        // Verify that distinction directly in one source column, independently
        // of production's donor selection and connected-component estimator.
        func intensity(_ y: Int) -> Double {
            let index = (y * width + 266) * 4
            return (0..<3).reduce(0.0) { $0 + Double(fixture.pixels[index + $1]) } / 3
        }
        let bareSkin = (intensity(135) + intensity(171)) * 0.5
        let deficits = (-15...15).map { max(0, bareSkin - intensity(153 + $0)) }
        let peak = try XCTUnwrap(deficits.max())
        func widthAbove(_ fraction: Double) throws -> Double {
            let indices = deficits.indices.filter { deficits[$0] >= peak * fraction }
            let first = try XCTUnwrap(indices.first), last = try XCTUnwrap(indices.last)
            return Double(last - first)
        }
        XCTAssertLessThan(try widthAbove(0.5), 84 * 0.19)
        XCTAssertGreaterThan(try widthAbove(0.2), 84 * 0.19)
        try assertSourceGeometry(fixture)
        for index in [1, 2] {
            let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                face: fixture.face, strengths: strengths(index), sourceRGBA: fixture.pixels), "control \(index)")
            XCTAssertEqual(map.admittedBrowCount, 2, "control \(index)")
            XCTAssertNotEqual(map.applyRGBA(fixture.pixels), fixture.pixels,
                              "weak skin-coloured shoulders must not disable a narrow strong core")
        }
    }

    func testGenuinelyBroadStrongCoreIsStillRejected() throws {
        let fixture = try fixture(halfThickness: 10)
        XCTAssertGreaterThan(20, 84 * 0.19, "the independently drawn strong core exceeds the admission width")
        let frame = try XCTUnwrap(BeautyEyebrowSourceGeometry.frame(face: fixture.face, width: width, height: height))
        for trace in [fixture.face.observedEyebrowSupport?.left, fixture.face.observedEyebrowSupport?.right] {
            let trace = try XCTUnwrap(trace)
            XCTAssertNil(BeautyEyebrowSourceGeometry.make(width: width, height: height,
                face: fixture.face, trace: trace, sourceRGBA: fixture.pixels,
                horizontal: frame.horizontal, vertical: frame.vertical),
                         "separating weak fringe must retain rejection of an over-wide dark core")
        }
        for index in [1, 2] {
            XCTAssertNil(BeautyContinuousEyebrowMap(width: width, height: height,
                face: fixture.face, strengths: strengths(index), sourceRGBA: fixture.pixels), "control \(index)")
        }
    }

    func testOffsetNativeEnvelopeAdmitsBothBrowsAndAllSevenControlsChangePixels() throws {
        let fixture = try fixture()
        let dense = try XCTUnwrap(fixture.face.denseSupport)
        let frame = try XCTUnwrap(BeautyEyebrowSourceGeometry.frame(face: fixture.face, width: width, height: height))
        for (indices, trace) in [
            (MediaPipeFaceTopology.leftBrowEnvelope, fixture.face.observedEyebrowSupport?.left),
            (MediaPipeFaceTopology.rightBrowEnvelope, fixture.face.observedEyebrowSupport?.right)
        ] {
            let trace = try XCTUnwrap(trace)
            let envelope = BeautyDenseFaceSupport.path(dense.mesh, indices)
            XCTAssertTrue(BeautyDenseFaceSupport.simplePolygon(envelope))
            let outward = frame.horizontal * (trace.side == .left ? -1.0 : 1.0)
            func projection(_ point: SIMD2<Float>) -> Double {
                let delta = SIMD2(Double(point.x - trace.innerEndpoint.x) * Double(width),
                                  Double(point.y - trace.innerEndpoint.y) * Double(height))
                return delta.x * outward.x + delta.y * outward.y
            }
            let lower = envelope.suffix(5).map(projection)
            XCTAssertGreaterThan(try XCTUnwrap(lower.min()), 3.5,
                                 "lower landmarks need not reach the upper semantic head")
            XCTAssertGreaterThan(try XCTUnwrap(lower.max()), projection(trace.outerEndpoint) + 3.5,
                                 "lower landmarks may extend past the upper semantic tail")
        }
        try assertSourceGeometry(fixture)
        for index in 0..<7 {
            let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                face: fixture.face, strengths: strengths(index), sourceRGBA: fixture.pixels), "control \(index)")
            XCTAssertEqual(map.admittedBrowCount, 2, "control \(index)")
            var appliedCounts = [Int]()
            let output = map.applyRGBA(fixture.pixels,onAppliedSideCount:{ appliedCounts.append($0) })
            XCTAssertEqual(appliedCounts,[2],"both native sides must pass actual source ownership")
            XCTAssertNotEqual(output, fixture.pixels,
                              "valid native geometry must not silently produce an unchanged image: control \(index)")
        }
    }

    func testRolledNativeClosedEnvelopeDoesNotRequireStrictlyIncreasingUpperTrace() throws {
        for shape in [HeadShape.verticalUpperEdge, .returningUpperEdge] {
            let fixture = try fixture(shape: shape, angle: 0.28)
            let dense = try XCTUnwrap(fixture.face.denseSupport)
            let frame = try XCTUnwrap(BeautyEyebrowSourceGeometry.frame(face: fixture.face, width: width, height: height))
            for (indices, trace) in [
                (MediaPipeFaceTopology.leftBrowEnvelope, fixture.face.observedEyebrowSupport?.left),
                (MediaPipeFaceTopology.rightBrowEnvelope, fixture.face.observedEyebrowSupport?.right)
            ] {
                let trace = try XCTUnwrap(trace)
                XCTAssertTrue(BeautyDenseFaceSupport.simplePolygon(BeautyDenseFaceSupport.path(dense.mesh, indices)))
                let outward = frame.horizontal * (trace.side == .left ? -1.0 : 1.0)
                let delta = SIMD2(Double(trace.points[1].x - trace.points[0].x) * Double(width),
                                  Double(trace.points[1].y - trace.points[0].y) * Double(height))
                let firstStep = delta.x * outward.x + delta.y * outward.y
                if shape == .verticalUpperEdge { XCTAssertEqual(firstStep, 0, accuracy: 0.001) }
                else { XCTAssertLessThan(firstStep, -1) }
            }
            try assertSourceGeometry(fixture)
            let map = try XCTUnwrap(BeautyContinuousEyebrowMap(width: width, height: height,
                face: fixture.face, strengths: strengths(2), sourceRGBA: fixture.pixels))
            XCTAssertEqual(map.admittedBrowCount, 2)
            XCTAssertNotEqual(map.applyRGBA(fixture.pixels), fixture.pixels,
                              "length must work for a valid native envelope after roll")
        }
    }
}
