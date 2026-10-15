import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

final class MouthContinuousMapTests: XCTestCase {
    private typealias Point = SIMD2<Double>
    private let caps: [Float] = [0.35, 0.35, 0.50, 0.25, 0.25, 0.25, 0.25, 0.25]

    // Source-defined two-peak upper lip, rounded lower lip, and separate oral
    // opening. The oracle below measures pixels independently of the map.
    private func upper(_ x: Double) -> Double {
        let r = (x - 0.5) / 0.18
        return 0.65 - 0.052 * sqrt(max(0, 1 - r * r)) + 0.012 * exp(-pow(r / 0.16, 2))
    }
    private func lower(_ x: Double) -> Double {
        let r = (x - 0.5) / 0.18
        return 0.65 + 0.055 * sqrt(max(0, 1 - r * r))
    }
    private func anatomy(inner: Bool = true, invalidOuter: Bool = false,
                         missingNose: Bool = false, samples: Int = 21,
                         nearMouthNose: Bool = false,
                         dense: BeautyDenseFaceSupport? = nil) -> FaceGeometry {
        var outer = (0..<samples).map { i -> SIMD2<Float> in
            let x = 0.32 + Double(i) * 0.36 / Double(samples - 1)
            return SIMD2(Float(x), Float(upper(x)))
        }
        outer += (1..<(samples - 1)).reversed().map { i -> SIMD2<Float> in
            let x = 0.32 + Double(i) * 0.36 / Double(samples - 1)
            return SIMD2(Float(x), Float(lower(x)))
        }
        if invalidOuter { outer[1] = outer[0] }
        let opening = (0..<20).map { i -> SIMD2<Float> in
            let a = Double(i) * .pi / 10
            return SIMD2(Float(0.5 + 0.14 * cos(a)), Float(0.65 + 0.010 * sin(a)))
        }
        func box(_ x: Float, _ y: Float) -> [SIMD2<Float>] {
            [SIMD2(x, y), SIMD2(x + 0.12, y), SIMD2(x + 0.12, y + 0.045), SIMD2(x, y + 0.045)]
        }
        let noseTop: Float = nearMouthNose ? 0.50 : 0.46
        let noseBottom: Float = nearMouthNose ? 0.59 : 0.55
        return FaceGeometry(bounds: FaceBounds(x: 0.18, y: 0.1, width: 0.64, height: 0.82),
            faceContour: [], leftEye: box(0.28, 0.30), rightEye: box(0.60, 0.30),
            nose: missingNose ? [] : [SIMD2(0.46, noseTop), SIMD2(0.54, noseTop),
                                     SIMD2(0.55, noseBottom), SIMD2(0.45, noseBottom)],
            outerLips: outer, upperLips: Array(outer.prefix(samples)),
            lowerLips: Array(outer.suffix(samples - 2)), innerLips: opening,
            observedOuterLips: outer, observedInnerLips: inner ? opening : [], denseSupport: dense)
    }

    func testHorizontalPositionOnTiltedMouthMovesInUprightImageWithoutVerticalDrift() throws {
        let width = 480, height = 600, original = anatomy()
        let angle = 20.0 * Double.pi / 180, origin = Point(240, 390)
        func rotate(_ p: SIMD2<Float>) -> SIMD2<Float> {
            let q = Point(Double(p.x) * Double(width), Double(p.y) * Double(height)) - origin
            let moved = origin + Point(q.x * cos(angle) - q.y * sin(angle),
                                       q.x * sin(angle) + q.y * cos(angle))
            return SIMD2(Float(moved.x / Double(width)), Float(moved.y / Double(height)))
        }
        let face = FaceGeometry(bounds: original.bounds, faceContour: [],
            leftEye: original.leftEye.map(rotate), rightEye: original.rightEye.map(rotate),
            nose: original.nose.map(rotate), outerLips: original.outerLips.map(rotate),
            upperLips: original.upperLips.map(rotate), lowerLips: original.lowerLips.map(rotate),
            innerLips: original.innerLips.map(rotate),
            observedOuterLips: original.observedOuterLips?.map(rotate),
            observedInnerLips: original.observedInnerLips?.map(rotate))
        let source = markers(width: width, height: height, locations: [Point(0.5, 0.65)])
        let baseline = centroid(source, width: width, height: height)
        let observed = try XCTUnwrap(face.observedOuterLips).map {
            Point(Double($0.x) * Double(width), Double($0.y) * Double(height))
        }
        let left = try XCTUnwrap(observed.min(by: { $0.x < $1.x }))
        let right = try XCTUnwrap(observed.max(by: { $0.x < $1.x }))
        let sourceSpan = hypot(right.x - left.x, right.y - left.y)
        // The physical source boxes use upright image coordinates. Rotating
        // their support into a mouth-axis box does not preserve the same set.
        let physicalBoxes: [(minX: Double, maxX: Double, minY: Double, maxY: Double)] =
            [face.leftEye, face.rightEye, face.nose].enumerated().map { index, points in
            let pixels = points.map { Point(Double($0.x) * Double(width), Double($0.y) * Double(height)) }
            let xValues = pixels.map(\.x), yValues = pixels.map(\.y)
            let extraBottom: Double = index == 2 ? max(3, sourceSpan * 0.03) : 0
            let minX = xValues.min()! - 2, maxX = xValues.max()! + 2
            let minY = yValues.min()! - 2, maxY = yValues.max()! + 2 + extraBottom
            return (minX: minX, maxX: maxX, minY: minY, maxY: maxY)
        }
        for sign: Float in [-1, 1] {
            var previous = 0.0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                    face: face, strengths: strengths(5, sign * fraction)))
                let output = map.applyRGBA(source)
                let moved = centroid(output, width: width, height: height) - baseline
                let gain = moved.x * Double(sign)
                XCTAssertGreaterThan(gain, previous + 0.12)
                XCTAssertEqual(moved.y, 0, accuracy: 0.3,
                    "Horizontal position follows upright image X even on a tilted mouth")
                XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                for point in face.nose + face.leftEye + face.rightEye {
                    XCTAssertEqual(map.displacement(at: Point(Double(point.x) * Double(width),
                                                              Double(point.y) * Double(height))), .zero)
                }
                for box in physicalBoxes {
                    var maximumProtectedMotion = 0.0
                    for y in max(0, Int(floor(box.minY)))..<min(height, Int(ceil(box.maxY))) {
                        for x in max(0, Int(floor(box.minX)))..<min(width, Int(ceil(box.maxX))) {
                            let pixel = Point(Double(x) + 0.5, Double(y) + 0.5)
                            if pixel.x >= box.minX, pixel.x <= box.maxX,
                               pixel.y >= box.minY, pixel.y <= box.maxY {
                                let displacement = map.displacement(at: pixel)
                                maximumProtectedMotion = max(maximumProtectedMotion,
                                    hypot(displacement.x, displacement.y))
                            }
                        }
                    }
                    XCTAssertEqual(maximumProtectedMotion, 0,
                        "Original physical source nose/eye boxes must remain exactly fixed")
                }
                // Check the sampled field independently of its reported
                // bound, including transitions around a tilted source.
                for y in stride(from: 310.25, through: 470.25, by: 8) {
                    for x in stride(from: 140.25, through: 340.25, by: 8) {
                        let p = Point(x, y), epsilon = 0.001
                        let gx = (map.displacement(at: p + Point(epsilon, 0))
                            - map.displacement(at: p - Point(epsilon, 0))) / (2 * epsilon)
                        let gy = (map.displacement(at: p + Point(0, epsilon))
                            - map.displacement(at: p - Point(0, epsilon))) / (2 * epsilon)
                        XCTAssertLessThanOrEqual(sqrt(gx.x * gx.x + gx.y * gx.y
                            + gy.x * gy.x + gy.y * gy.y), 0.450001)
                        XCTAssertLessThanOrEqual(hypot(map.displacement(at: p).x,
                            map.displacement(at: p).y), map.maximumDisplacement + 1e-6)
                    }
                }
                previous = gain
            }
        }
    }

    func testNegativeFullnessQuarterStepsHavePredictableVisibleThinningResponse() throws {
        let width = 480, height = 600, face = anatomy()
        let source = markers(width: width, height: height,
            locations: [Point(0.5, 0.612), Point(0.5, 0.701)])
        func thickness(_ bytes: [UInt8]) -> Double {
            centroid(bytes, width: width, height: height, yRange: 0.65..<1).y
                - centroid(bytes, width: width, height: height, yRange: 0..<0.65).y
        }
        let baseline = thickness(source)
        let endpoint = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
            face: face, strengths: strengths(7, -1)))
        let total = baseline - thickness(endpoint.applyRGBA(source))
        XCTAssertGreaterThan(total, 1)
        for fraction: Float in [0.25, 0.5, 0.75] {
            let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                face: face, strengths: strengths(7, -fraction)))
            let response = (baseline - thickness(map.applyRGBA(source))) / total
            XCTAssertEqual(response, Double(fraction), accuracy: 0.045,
                "Equal slider steps should produce predictable visible thinning")
            XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
        }
    }

    func testHorizontalPositionNearNoseRetainsAvailableMotionAndMaterialWidth() throws {
        let width = 480, height = 600, face = anatomy(nearMouthNose: true)
        let outer = try XCTUnwrap(face.observedOuterLips).map {
            Point(Double($0.x) * Double(width), Double($0.y) * Double(height))
        }
        let left = try XCTUnwrap(outer.min(by: { $0.x < $1.x }))
        let right = try XCTUnwrap(outer.max(by: { $0.x < $1.x }))
        let span = hypot(right.x - left.x, right.y - left.y)
        let axis = (right - left) / span
        let radius = min(span * 0.20,
                         min(Double(face.bounds.width) * Double(width), Double(face.bounds.height) * Double(height)) * 0.06)
        for sign: Float in [-1, 1] {
            var previous = 0.0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                    face: face, strengths: strengths(5, sign * fraction)))
                // Follow the two fixed source corners through the actual
                // inverse sampler. Its retained gradient < 1 makes this
                // material-point inverse unique, independent of construction.
                let shifts = [left, right].map { source -> Double in
                    var low = -radius, high = radius
                    for _ in 0..<70 {
                        let shift = (low + high) * 0.5
                        let delta = map.displacement(at: source + axis * shift)
                        let projected = delta.x * axis.x + delta.y * axis.y
                        if shift - projected < 0 { low = shift } else { high = shift }
                    }
                    return (low + high) * 0.5
                }
                let motion = (shifts[0] + shifts[1]) * 0.5 * Double(sign)
                XCTAssertGreaterThan(motion, previous + 0.1)
                XCTAssertEqual(shifts[0], shifts[1], accuracy: 0.45)
                XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                XCTAssertLessThanOrEqual(map.maximumDisplacement, radius + 0.000001)
                for point in face.nose + face.leftEye + face.rightEye {
                    XCTAssertEqual(map.displacement(at: Point(Double(point.x) * Double(width),
                                                              Double(point.y) * Double(height))), .zero)
                }
                if fraction == 1 {
                    // Frozen before candidate output: this generated source's
                    // fixed anchors admit at least 18.2238 px of corner motion
                    // under the same cap and actual lattice gradient bound.
                    // The previous width-correction field delivered 17.4073.
                    XCTAssertGreaterThanOrEqual(motion, 18.20)
                }
                previous = motion
            }
        }
    }

    // Independent thin-upper-lip source: a visible bow remains above a narrow
    // opening, but its tissue is much thinner than the general fixture above.
    // The source contour and pixel oracle do not use map availability weights.
    private func thinUpper(_ x: Double) -> Double {
        let r = (x - 0.5) / 0.18
        return 0.65 - 0.009 * sqrt(max(0, 1 - r * r)) + 0.003 * exp(-pow(r / 0.18, 2))
    }

    private func thinAnatomy() -> FaceGeometry {
        let samples = 31
        var outer = (0..<samples).map { i -> SIMD2<Float> in
            let x = 0.32 + Double(i) * 0.36 / Double(samples - 1)
            return SIMD2(Float(x), Float(thinUpper(x)))
        }
        outer += (1..<(samples - 1)).reversed().map { i -> SIMD2<Float> in
            let x = 0.32 + Double(i) * 0.36 / Double(samples - 1)
            let r = (x - 0.5) / 0.18
            return SIMD2(Float(x), Float(0.65 + 0.010 * sqrt(max(0, 1 - r * r))))
        }
        let opening = (0..<24).map { i -> SIMD2<Float> in
            let a = Double(i) * .pi / 12
            return SIMD2(Float(0.5 + 0.14 * cos(a)), Float(0.65 + 0.0015 * sin(a)))
        }
        let face = anatomy()
        return FaceGeometry(bounds: face.bounds, faceContour: face.faceContour,
            leftEye: face.leftEye, rightEye: face.rightEye, nose: face.nose,
            outerLips: outer, upperLips: Array(outer.prefix(samples)),
            lowerLips: Array(outer.suffix(samples - 2)), innerLips: opening,
            observedOuterLips: outer, observedInnerLips: opening)
    }

    private func strengths(_ field: Int, _ amount: Float) -> BeautyEffectiveStrengths {
        var result = BeautyEffectiveStrengths()
        result[keyPath: BeautyContinuousMouthMap.keys[field]] = amount * caps[field]
        return result
    }

    private func markers(width: Int, height: Int, locations: [Point]) -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let distance = locations.map { p in
                pow(Double(x) + 0.5 - p.x * Double(width), 2)
                    + pow(Double(y) + 0.5 - p.y * Double(height), 2)
            }.min()!
            let i = (y * width + x) * 4
            bytes[i] = UInt8((128 - 110 * exp(-distance / 8)).rounded())
            bytes[i + 1] = 128; bytes[i + 2] = 128
        } }
        return bytes
    }

    private func centroid(_ bytes: [UInt8], width: Int, height: Int,
                          xRange: Range<Double> = 0..<1, yRange: Range<Double> = 0..<1) -> Point {
        var total = 0.0, sum = Point.zero
        for y in max(0, Int(yRange.lowerBound * Double(height)))..<min(height, Int(ceil(yRange.upperBound * Double(height)))) {
            for x in max(0, Int(xRange.lowerBound * Double(width)))..<min(width, Int(ceil(xRange.upperBound * Double(width)))) {
                let weight = Double(max(0, 128 - Int(bytes[(y * width + x) * 4])))
                total += weight; sum += Point(Double(x) + 0.5, Double(y) + 0.5) * weight
            }
        }
        return total > 0 ? sum / total : Point(.nan, .nan)
    }

    func testWholeMouthDirectionsAndQuarterStepsUseActualPixelsInBothAspects() throws {
        for (width, height) in [(480, 600), (600, 420)] {
            let face = anatomy()
            let horizontal = [Point(0.38, 0.65), Point(0.62, 0.65)]
            for field in [0, 1, 2, 3, 4, 5] {
                let marks: [Point]
                switch field {
                case 2: marks = [Point(0.335, 0.65), Point(0.665, 0.65)]
                case 3, 5: marks = [Point(0.5, 0.65)]
                default: marks = horizontal
                }
                let source = markers(width: width, height: height, locations: marks)
                func measure(_ bytes: [UInt8]) -> Double {
                    if field == 3 { return centroid(bytes, width: width, height: height).y }
                    if field == 5 { return centroid(bytes, width: width, height: height).x }
                    if field == 2 { return -centroid(bytes, width: width, height: height).y }
                    let left = centroid(bytes, width: width, height: height, xRange: 0..<0.5)
                    let right = centroid(bytes, width: width, height: height, xRange: 0.5..<1)
                    return field == 4 ? right.y - left.y : right.x - left.x
                }
                let baseline = measure(source)
                for sign: Float in [-1, 1] {
                    var previous = 0.0
                    for fraction: Float in [0.25, 0.5, 0.75, 1] {
                        let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                            face: face, strengths: strengths(field, sign * fraction)))
                        let output = map.applyRGBA(source)
                        let gain = (measure(output) - baseline) * Double(sign)
                        XCTAssertGreaterThan(gain, previous + 0.12, "field=\(field), fraction=\(fraction), sign=\(sign)")
                        if fraction == 1 { XCTAssertGreaterThan(gain, 1) }
                        previous = gain
                        XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                        XCTAssertEqual(output, map.applyRGBA(source))
                        if field == 4 {
                            let a = centroid(output, width: width, height: height, xRange: 0..<0.5)
                            let b = centroid(output, width: width, height: height, xRange: 0.5..<1)
                            XCTAssertEqual(hypot(b.x - a.x, b.y - a.y), 0.24 * Double(width), accuracy: 0.7)
                        }
                    }
                }
            }
        }
    }

    func testSmileSpreadsAndBendsBothCornersMonotonicallyWhileCenterSeamStaysFixed() throws {
        for (width, height) in [(480, 600), (600, 420)] {
            let face = anatomy()
            let source = markers(width: width, height: height,
                locations: [Point(0.335, 0.65), Point(0.5, 0.65), Point(0.665, 0.65)])
            func corners(_ bytes: [UInt8]) -> (Point, Point) {
                (centroid(bytes, width: width, height: height, xRange: 0.25..<0.43),
                 centroid(bytes, width: width, height: height, xRange: 0.57..<0.75))
            }
            let (sourceLeft, sourceRight) = corners(source)
            for sign: Float in [-1, 1] {
                var previousSpanGain = 0.0, previousLeftRise = 0.0, previousRightRise = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                        face: face, strengths: strengths(2, sign * fraction)))
                    let output = map.applyRGBA(source)
                    let (left, right) = corners(output)
                    let spanGain = ((right.x - left.x) - (sourceRight.x - sourceLeft.x)) * Double(sign)
                    let leftRise = (sourceLeft.y - left.y) * Double(sign)
                    let rightRise = (sourceRight.y - right.y) * Double(sign)
                    XCTAssertGreaterThan(spanGain, previousSpanGain + 0.12)
                    XCTAssertGreaterThan(leftRise, previousLeftRise + 0.12)
                    XCTAssertGreaterThan(rightRise, previousRightRise + 0.12)
                    XCTAssertGreaterThan((sourceLeft.x - left.x) * Double(sign), 0)
                    XCTAssertGreaterThan((right.x - sourceRight.x) * Double(sign), 0)
                    XCTAssertEqual(leftRise, rightRise, accuracy: 0.15)
                    if fraction == 1 {
                        XCTAssertGreaterThan(spanGain, 1)
                        XCTAssertGreaterThan(leftRise, 1)
                        print("smile corner pixels aspect=\(width)x\(height) sign=\(sign) spanGain=\(spanGain) leftRise=\(leftRise) rightRise=\(rightRise)")
                    }
                    for y in Int(0.642 * Double(height))..<Int(0.658 * Double(height)) {
                        for x in Int(0.48 * Double(width))..<Int(0.52 * Double(width)) {
                            let offset = (y * width + x) * 4
                            XCTAssertEqual(Array(output[offset..<offset + 4]), Array(source[offset..<offset + 4]))
                        }
                    }
                    XCTAssertEqual(output, map.applyRGBA(source))
                    XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                    let faceSpan = min(0.64 * Double(width), 0.82 * Double(height))
                    XCTAssertLessThanOrEqual(map.maximumDisplacement,
                        min(0.36 * Double(width) * 0.20, faceSpan * 0.06) + 0.0001)
                    previousSpanGain = spanGain
                    previousLeftRise = leftRise
                    previousRightRise = rightRise
                }
                // Width changes the whole horizontal scale without bending
                // either corner; smile couples its local spread to a bend.
                let widthMap = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                    face: face, strengths: strengths(1, sign)))
                let (wideLeft, wideRight) = corners(widthMap.applyRGBA(source))
                XCTAssertGreaterThan(((wideRight.x - wideLeft.x) - (sourceRight.x - sourceLeft.x)) * Double(sign), 1)
                XCTAssertEqual(wideLeft.y, sourceLeft.y, accuracy: 0.12)
                XCTAssertEqual(wideRight.y, sourceRight.y, accuracy: 0.12)
            }
        }
    }

    func testSizeChangesBothDimensionsWhileWidthPreservesMouthHeight() throws {
        let width = 480, height = 600, face = anatomy()
        let source = markers(width: width, height: height, locations: [Point(0.5, 0.612), Point(0.5, 0.695)])
        func gap(_ bytes: [UInt8]) -> Double {
            centroid(bytes, width: width, height: height, yRange: 0.65..<1).y
                - centroid(bytes, width: width, height: height, yRange: 0..<0.65).y
        }
        let baseline = gap(source)
        for sign: Float in [-1, 1] {
            let size = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                face: face, strengths: strengths(0, sign)))
            XCTAssertGreaterThan((gap(size.applyRGBA(source)) - baseline) * Double(sign), 1)
            let widthMap = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                face: face, strengths: strengths(1, sign)))
            XCTAssertEqual(gap(widthMap.applyRGBA(source)), baseline, accuracy: 0.12)
        }
    }

    func testPeakAndPlumpHaveDistinctMonotoneShapesAndProtectOpeningAndCorners() throws {
        let width = 480, height = 600, face = anatomy()
        let peakXs = [0.4496, 0.5, 0.5504]
        let peakSource = markers(width: width, height: height, locations: peakXs.map { Point($0, upper($0)) })
        let plumpSource = markers(width: width, height: height, locations: [Point(0.5, 0.612), Point(0.5, 0.701)])
        func peakScore(_ bytes: [UInt8]) -> Double {
            let left = centroid(bytes, width: width, height: height, xRange: 0.41..<0.475)
            let center = centroid(bytes, width: width, height: height, xRange: 0.475..<0.525)
            let right = centroid(bytes, width: width, height: height, xRange: 0.525..<0.59)
            return center.y - (left.y + right.y) * 0.5
        }
        func thicknessScore(_ bytes: [UInt8]) -> Double {
            centroid(bytes, width: width, height: height, yRange: 0.65..<1).y
                - centroid(bytes, width: width, height: height, yRange: 0..<0.65).y
        }
        for field in [6, 7] {
            let source = field == 6 ? peakSource : plumpSource
            let baseline = field == 6 ? peakScore(source) : thicknessScore(source)
            for sign: Float in [-1, 1] {
                var previous = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                        face: face, strengths: strengths(field, sign * fraction)))
                    let output = map.applyRGBA(source)
                    let metric = field == 6 ? peakScore(output) : thicknessScore(output)
                    let gain = (metric - baseline) * Double(sign)
                    XCTAssertGreaterThan(gain, previous + 0.08, "field=\(field), fraction=\(fraction), sign=\(sign)")
                    if fraction == 1 { XCTAssertGreaterThan(gain, 0.8) }
                    previous = gain
                    XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                    // The exact oral envelope and both corner centers are
                    // invariant for these two local morphology controls.
                    for y in stride(from: 0.641, through: 0.659, by: 0.003) {
                        for x in stride(from: 0.34, through: 0.66, by: 0.02) {
                            XCTAssertEqual(map.displacement(at: Point(x * Double(width), y * Double(height))), .zero)
                        }
                    }
                    for x in [0.32, 0.68] {
                        XCTAssertEqual(map.displacement(at: Point(x * Double(width), 0.65 * Double(height))), .zero)
                    }
                    // Check the actual interpolated inverse across each lip
                    // edge and its skin transition. The retained 0.45 bound
                    // leaves at least 0.55 of every vertical source interval;
                    // a depth plateau must remain continuous and cannot fold.
                    for x in peakXs {
                        var previousSourceY: Double?
                        for y in stride(from: 0.55 * Double(height), through: 0.75 * Double(height), by: 0.25) {
                            let q = Point(x * Double(width), y)
                            let sourceY = y - map.displacement(at: q).y
                            if let previousSourceY {
                                XCTAssertGreaterThanOrEqual(sourceY - previousSourceY, 0.25 * 0.55 - 0.000001)
                            }
                            previousSourceY = sourceY
                        }
                    }
                }
            }
        }
        let peak = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height, face: face, strengths: strengths(6, 1)))
        let plump = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height, face: face, strengths: strengths(7, 1)))
        XCTAssertEqual(peak.displacement(at: Point(240, 0.701 * 600)), .zero)
        XCTAssertGreaterThan(plump.displacement(at: Point(240, 0.701 * 600)).y, 1)
    }

    func testActualPixelsProtectNoseEyesExteriorAlphaAndOralBandUnderLocalShapeWork() throws {
        let width = 240, height = 320, face = anatomy()
        var source = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            source[i] = UInt8((x * 11 + y * 7) % 256)
            source[i + 1] = UInt8((x * 5 + y * 13) % 256)
            source[i + 2] = UInt8((x * 17 + y * 3) % 256)
            if x < 12 { source[i + 3] = 128 }
        } }
        for field in 0..<8 {
            for sign: Float in [-1, 1] {
                let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                    face: face, strengths: strengths(field, sign)))
                let output = map.applyRGBA(source)
                XCTAssertEqual(output.count, source.count)
                XCTAssertEqual(output, map.applyRGBA(source))
                for y in 0..<height { for x in 0..<width {
                    let px = (Double(x) + 0.5) / Double(width), py = (Double(y) + 0.5) / Double(height)
                    let nose = (0.45...0.55).contains(px) && (0.46...0.55).contains(py)
                    let eyes = ((0.28...0.40).contains(px) || (0.60...0.72).contains(px)) && (0.30...0.345).contains(py)
                    let exterior = px < 0.03 || px > 0.97 || py < 0.25 || py > 0.93
                    let oral = field >= 6 && (0.35...0.65).contains(px) && (0.641...0.659).contains(py)
                    let i = (y * width + x) * 4
                    XCTAssertEqual(output[i + 3], source[i + 3])
                    if nose || eyes || exterior || oral {
                        XCTAssertEqual(Array(output[i..<i + 3]), Array(source[i..<i + 3]), "protected field=\(field)")
                    }
                } }
            }
        }
    }

    func testThinUpperLipPeakAndFullnessHaveVisibleBidirectionalQuarterSteps() throws {
        let width = 640, height = 800, face = thinAnatomy()
        let peakXs = [0.4496, 0.5, 0.5504]
        let peakSource = markers(width: width, height: height,
            locations: peakXs.map { Point($0, thinUpper($0)) })
        let thicknessSource = markers(width: width, height: height,
            locations: [Point(0.5, thinUpper(0.5)), Point(0.5, 0.660)])
        func peakScore(_ bytes: [UInt8]) -> Double {
            let left = centroid(bytes, width: width, height: height, xRange: 0.41..<0.475)
            let center = centroid(bytes, width: width, height: height, xRange: 0.475..<0.525)
            let right = centroid(bytes, width: width, height: height, xRange: 0.525..<0.59)
            return center.y - (left.y + right.y) * 0.5
        }
        func upperEdge(_ bytes: [UInt8]) -> Double {
            centroid(bytes, width: width, height: height, yRange: 0..<0.65).y
        }
        func thicknessScore(_ bytes: [UInt8]) -> Double {
            centroid(bytes, width: width, height: height, yRange: 0.65..<1).y - upperEdge(bytes)
        }
        for field in [6, 7] {
            let source = field == 6 ? peakSource : thicknessSource
            let baseline = field == 6 ? peakScore(source) : thicknessScore(source)
            let baselineUpper = upperEdge(thicknessSource)
            for sign: Float in [-1, 1] {
                var previous = 0.0, previousUpper = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                        face: face, strengths: strengths(field, sign * fraction)))
                    let output = map.applyRGBA(source)
                    let metric = field == 6 ? peakScore(output) : thicknessScore(output)
                    let gain = (metric - baseline) * Double(sign)
                    XCTAssertGreaterThan(gain, previous + (field == 6 ? 0.10 : 0.15),
                        "thin field=\(field), fraction=\(fraction), sign=\(sign), gain=\(gain)")
                    if fraction == 1 {
                        XCTAssertGreaterThan(gain, field == 6 ? 0.85 : 1.5,
                            "thin endpoint field=\(field), sign=\(sign), gain=\(gain)")
                        print("Thin-upper-lip endpoint field=\(field), sign=\(sign), measuredGainPx=\(gain), gradient=\(map.maximumGradient), displacementPx=\(map.maximumDisplacement)")
                    }
                    previous = gain
                    if field == 7 {
                        let upperGain = (baselineUpper - upperEdge(output)) * Double(sign)
                        XCTAssertGreaterThan(upperGain, previousUpper + 0.06,
                            "thin upper fullness fraction=\(fraction), sign=\(sign), gain=\(upperGain)")
                        if fraction == 1 {
                            XCTAssertGreaterThan(upperGain, 0.4, "thin upper fullness endpoint sign=\(sign), gain=\(upperGain)")
                            print("Thin-upper-lip fullness sign=\(sign), upperGainPx=\(upperGain)")
                        }
                        previousUpper = upperGain
                    }
                    XCTAssertEqual(output, map.applyRGBA(source))
                    XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
                    XCTAssertLessThanOrEqual(map.maximumDisplacement,
                        min(0.36 * Double(width) * 0.20, 0.64 * Double(width) * 0.06) + 0.0001)
                    // Cover the complete opening bbox, including its margins,
                    // rather than only the centerline or sampled inner points.
                    for y in stride(from: 0.648, through: 0.652, by: 0.0005) {
                        for x in stride(from: 0.20, through: 0.80, by: 0.02) {
                            XCTAssertEqual(map.displacement(at: Point(x * Double(width), y * Double(height))), .zero)
                        }
                    }
                    for x in [0.32, 0.68] {
                        XCTAssertEqual(map.displacement(at: Point(x * Double(width), 0.65 * Double(height))), .zero)
                    }
                }
            }
        }
    }

    func testThinUpperLipActualPixelsPreserveOpeningNoseEyesExteriorAndAlpha() throws {
        let width = 320, height = 400, face = thinAnatomy()
        var source = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            source[i] = UInt8((x * 11 + y * 7) % 256)
            source[i + 1] = UInt8((x * 5 + y * 13) % 256)
            source[i + 2] = UInt8((x * 17 + y * 3) % 256)
            if (128..<144).contains(x) { source[i + 3] = 192 }
        } }
        for field in [6, 7] { for sign: Float in [-1, 1] {
            let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                face: face, strengths: strengths(field, sign)))
            let output = map.applyRGBA(source)
            XCTAssertNotEqual(output, source)
            for y in 0..<height { for x in 0..<width {
                let px = (Double(x) + 0.5) / Double(width), py = (Double(y) + 0.5) / Double(height)
                let nose = (0.45...0.55).contains(px) && (0.46...0.55).contains(py)
                let eyes = ((0.28...0.40).contains(px) || (0.60...0.72).contains(px)) && (0.30...0.345).contains(py)
                let exterior = px < 0.03 || px > 0.97 || py < 0.25 || py > 0.93
                let oral = (0.36...0.64).contains(px) && (0.6485...0.6515).contains(py)
                let i = (y * width + x) * 4
                XCTAssertEqual(output[i + 3], source[i + 3])
                if nose || eyes || exterior || oral {
                    XCTAssertEqual(Array(output[i..<i + 3]), Array(source[i..<i + 3]), "protected thin field=\(field)")
                }
            } }
        } }
    }

    func testMissingAndMalformedSupportFailsOnlyItsDependentFields() throws {
        XCTAssertEqual(BeautyContinuousMouthMap.eligibleFieldMask(face: anatomy()), 255)
        XCTAssertEqual(BeautyContinuousMouthMap.eligibleFieldMask(face: anatomy(inner: false)), 63)
        XCTAssertEqual(BeautyContinuousMouthMap.eligibleFieldMask(face: anatomy(invalidOuter: true)), 0)
        XCTAssertEqual(BeautyContinuousMouthMap.eligibleFieldMask(face: anatomy(missingNose: true)), 0)
        var combined = BeautyEffectiveStrengths()
        for (key, cap) in zip(BeautyContinuousMouthMap.keys, caps) { combined[keyPath: key] = -cap }
        let emission = MouthWarpProvider().planningEmissions(face: anatomy(inner: false), strengths: combined)
        XCTAssertEqual(emission.continuousFieldMask, 63)
        XCTAssertTrue(emission.points.isEmpty)
        let admitted = emission.sanitizing(combined)
        XCTAssertEqual(admitted.mouthWidth, -0.35)
        XCTAssertEqual(admitted.smile, -0.5)
        XCTAssertEqual(admitted.lipPeakDefinition, 0)
        XCTAssertEqual(admitted.lipPlump, 0)
        XCTAssertNil(BeautyContinuousMouthMap(width: 240, height: 320, face: anatomy(), strengths: .init()))
        XCTAssertNil(BeautyContinuousMouthMap(width: 240, height: 320, face: anatomy(inner: false), strengths: strengths(7, 1)))
        XCTAssertNil(BeautyContinuousMouthMap(width: 240, height: 320, face: anatomy(invalidOuter: true), strengths: strengths(0, 1)))
        let map = try XCTUnwrap(BeautyContinuousMouthMap(width: 240, height: 320, face: anatomy(), strengths: strengths(0, 1)))
        XCTAssertEqual(map.applyRGBA([1, 2, 3]), [1, 2, 3])
        XCTAssertFalse(String(reflecting: map).contains("offsets"))
        XCTAssertFalse(String(reflecting: map).contains("origin"))
    }

    func testDetectorSamplingDensityDoesNotMultiplyMouthMotionAndCombinationsStayBounded() throws {
        let width = 360, height = 480
        let source = markers(width: width, height: height, locations: [Point(0.5, 0.65)])
        var centers = [Point]()
        for samples in [11, 21, 31] {
            let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                face: anatomy(samples: samples), strengths: strengths(5, 1)))
            centers.append(centroid(map.applyRGBA(source), width: width, height: height))
        }
        XCTAssertEqual(centers[0].x, centers[1].x, accuracy: 0.05)
        XCTAssertEqual(centers[1].x, centers[2].x, accuracy: 0.05)
        for sign: Float in [-1, 1] {
            var combined = BeautyEffectiveStrengths()
            for (key, cap) in zip(BeautyContinuousMouthMap.keys, caps) { combined[keyPath: key] = sign * cap }
            let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height, face: anatomy(), strengths: combined))
            XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
            XCTAssertLessThanOrEqual(map.maximumDisplacement, Double(width) * 0.64 * 0.06 + 0.0001)
            XCTAssertEqual(map.applyRGBA(source), map.applyRGBA(source))
        }
    }

    func testObservedInnerPathReachesGeometryAndLegacyNewNegativeHalvesAreAvailable() throws {
        let source = anatomy()
        let observed = BeautyFaceObservation(
            imageBounds: CoordinateRect(x: 0.18, y: 0.1, width: 0.64, height: 0.82),
            landmarks: .complete,
            observedLipSupport: BeautyObservedLipSupport(
                outer: source.observedOuterLips!.map { CoordinatePoint(x: Double($0.x), y: Double($0.y)) },
                inner: source.observedInnerLips!.map { CoordinatePoint(x: Double($0.x), y: Double($0.y)) }))
        let mapped = BeautyFaceGeometryAdapter.makeGeometry(from: observed)
        XCTAssertEqual(mapped.observedInnerLips, source.observedInnerLips)
        XCTAssertEqual(mapped.observedOuterLips, source.observedOuterLips)

        let coarse = BeautyFaceGeometryAdapter.makeGeometry(from: BeautyFaceObservation(
            imageBounds: CoordinateRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8), landmarks: .complete))
        XCTAssertFalse(BeautyContinuousMouthMap.replacesLegacy(for: coarse))
        let provider = MouthWarpProvider()
        let smile = provider.fieldEmissions(face: coarse, strengths: strengths(2, -1)).smile
        XCTAssertEqual(smile.count, 2)
        XCTAssertTrue(smile.allSatisfy { $0.target.y > $0.source.y })
        let peak = provider.fieldEmissions(face: coarse, strengths: strengths(6, -1)).lipPeakDefinition
        XCTAssertEqual(peak.count, 3)
        XCTAssertLessThan(peak[1].target.y, peak[1].source.y)
        XCTAssertGreaterThan(peak[0].target.y, peak[0].source.y)
        XCTAssertGreaterThan(peak[2].target.y, peak[2].source.y)
        let plump = provider.fieldEmissions(face: coarse, strengths: strengths(7, -1)).lipPlump
        XCTAssertEqual(plump.count, 6)
        let center = coarse.innerLips.reduce(SIMD2<Float>.zero, +) / Float(coarse.innerLips.count)
        for p in plump {
            let from = p.source - center, to = p.target - center
            XCTAssertLessThan(to.x * to.x + to.y * to.y, from.x * from.x + from.y * from.y)
        }
    }

    func testPoseLimitedPureTiltRetainsRigidCoreDistances() throws {
        let cosine: Float = 0.635, sine = sqrt(1 - cosine * cosine)
        let matrix: [Float] = [cosine, 0, sine, 0, 0, 1, 0, 0, -sine, 0, cosine, 0, 0, 0, 0, 1]
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: Array(repeating: SIMD3<Float>(0.5, 0.5, 0), count: 478),
                                              facialTransformation: matrix))
        let dense = BeautyDenseFaceSupport(mesh: mesh)
        XCTAssertEqual(dense.geometryScale, 0.5, accuracy: 0.0001)
        let map = try XCTUnwrap(BeautyContinuousMouthMap(width: 480, height: 600,
            face: anatomy(dense: dense), strengths: strengths(4, 1)))
        let points = [Point(216, 390), Point(264, 390), Point(240, 408)]
        let inverse = points.map { $0 - map.displacement(at: $0) }
        for i in 0..<points.count { for j in (i + 1)..<points.count {
            let before = points[j] - points[i], after = inverse[j] - inverse[i]
            XCTAssertEqual(hypot(after.x, after.y), hypot(before.x, before.y), accuracy: 0.000001)
        } }
        XCTAssertLessThanOrEqual(map.maximumGradient, 0.450001)
    }

    func testAddingNearNeutralMouthShapeDoesNotJumpAnExistingSliderEdit() throws {
        let width = 240, height = 320, face = anatomy()
        let probes = [Point(102, 195), Point(120, 195), Point(138, 195),
                      Point(102, 208), Point(120, 208), Point(138, 208), Point(120, 222)]
        let transitionProbes = stride(from: 150.25, through: 260.25, by: 1).flatMap { y in
            stride(from: 50.25, through: 190.25, by: 1).map { Point($0, y) }
        }
        // A user keeps one control edited, selects another and starts dragging
        // across zero. An arbitrarily small new request must not re-budget the
        // existing edit as though the new control were already at its endpoint.
        for (field, amount) in [(5, Float(0.75)), (6, Float(0.75)), (7, Float(-0.75))] {
            let current = strengths(field, amount)
            let before = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                face: face, strengths: current))
            for sibling in [5, 6, 7] where sibling != field {
                for sign: Float in [-1, 1] {
                    var next = current
                    next[keyPath: BeautyContinuousMouthMap.keys[sibling]] = caps[sibling] * sign * 0.00001
                    let after = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                        face: face, strengths: next))
                    for point in probes + (field == 5 ? transitionProbes : []) {
                        let jump = after.displacement(at: point) - before.displacement(at: point)
                        XCTAssertLessThan(hypot(jump.x, jump.y), 0.01,
                            "existing=\(field), new=\(sibling), sign=\(sign)")
                    }
                    XCTAssertLessThanOrEqual(after.maximumGradient, 0.450001)
                }
            }
        }
    }

    func testLocalCombinationsRetainPoseBudgetWithoutApplyingPoseTwice() throws {
        let cosine: Float = 0.635, sine = sqrt(1 - cosine * cosine)
        let matrix: [Float] = [cosine, 0, sine, 0, 0, 1, 0, 0, -sine, 0, cosine, 0, 0, 0, 0, 1]
        let mesh = try XCTUnwrap(BeautyFaceMesh(points: Array(repeating: SIMD3<Float>(0.5, 0.5, 0), count: 478),
                                              facialTransformation: matrix))
        let dense = BeautyDenseFaceSupport(mesh: mesh)
        let width = 240, height = 320, face = anatomy(dense: dense)
        let pose = Double(dense.geometryScale)
        XCTAssertEqual(pose, 0.5, accuracy: 0.0001)
        for fields in [[6, 7], [5, 6, 7]] {
            for amount: Float in [0.05, 1] {
                var requested = BeautyEffectiveStrengths()
                var components = [BeautyContinuousMouthMap]()
                for field in fields {
                    let value = amount * (field == 7 ? -1 : 1)
                    requested[keyPath: BeautyContinuousMouthMap.keys[field]] = caps[field] * value
                    components.append(try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                        face: face, strengths: strengths(field, value))))
                }
                let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                    face: face, strengths: requested))
                XCTAssertLessThanOrEqual(map.maximumGradient, 0.45 * pose + 0.000001)
                XCTAssertLessThanOrEqual(map.maximumDisplacement,
                    min(0.36 * Double(width) * 0.20, 0.64 * Double(width) * 0.06) * pose + 0.0001)
                for y in stride(from: 150.25, through: 260.25, by: 4) {
                    for x in stride(from: 50.25, through: 190.25, by: 4) {
                        let point = Point(x, y), epsilon = 0.001
                        let gx = (map.displacement(at: point + Point(epsilon, 0))
                            - map.displacement(at: point - Point(epsilon, 0))) / (2 * epsilon)
                        let gy = (map.displacement(at: point + Point(0, epsilon))
                            - map.displacement(at: point - Point(0, epsilon))) / (2 * epsilon)
                        XCTAssertLessThanOrEqual(sqrt(gx.x * gx.x + gx.y * gx.y
                            + gy.x * gy.x + gy.y * gy.y), 0.45 * pose + 0.000001)
                        let actual = map.displacement(at: point)
                        XCTAssertLessThanOrEqual(hypot(actual.x, actual.y),
                            map.maximumDisplacement + 0.000001)
                    }
                }
                if amount < 0.1 {
                    for point in [Point(102, 195), Point(120, 195), Point(138, 195), Point(120, 222)] {
                        let expected = components.reduce(Point.zero) { $0 + $1.displacement(at: point) }
                        let actual = map.displacement(at: point)
                        XCTAssertEqual(actual.x, expected.x, accuracy: 0.000001)
                        XCTAssertEqual(actual.y, expected.y, accuracy: 0.000001)
                    }
                }
            }
        }
    }

    func testNegativeMLeavesAnAlreadyFlatCentralUpperLipFlat() throws {
        let width = 480, height = 600, original = anatomy()
        // A registered negative source has a level central border rather than
        // two peaks. Its pixel markers define flatness independently of the
        // displacement formula and must not become an inverted bow.
        let outer = original.observedOuterLips!.map { point -> SIMD2<Float> in
            if (0.38...0.62).contains(point.x), point.y < 0.65 { return SIMD2(point.x, 0.61) }
            return point
        }
        let face = FaceGeometry(bounds: original.bounds, faceContour: original.faceContour,
            leftEye: original.leftEye, rightEye: original.rightEye, nose: original.nose,
            outerLips: outer, upperLips: Array(outer.prefix(21)), lowerLips: Array(outer.suffix(19)),
            innerLips: original.innerLips, observedOuterLips: outer,
            observedInnerLips: original.observedInnerLips)
        XCTAssertEqual(BeautyContinuousMouthMap.eligibleFieldMask(face: face), 255)
        XCTAssertNotNil(BeautyContinuousMouthMap(width: width, height: height,
            face: face, strengths: strengths(6, 1)))
        let source = markers(width: width, height: height,
            locations: [Point(0.4496, 0.61), Point(0.5, 0.61), Point(0.5504, 0.61)])
        for amount: Float in [-0.25, -0.5, -0.75, -1] {
            let map = BeautyContinuousMouthMap(width: width, height: height,
                face: face, strengths: strengths(6, amount))
            let output = map?.applyRGBA(source) ?? source
            let left = centroid(output, width: width, height: height, xRange: 0.41..<0.475)
            let center = centroid(output, width: width, height: height, xRange: 0.475..<0.525)
            let right = centroid(output, width: width, height: height, xRange: 0.525..<0.59)
            XCTAssertEqual(center.y - (left.y + right.y) * 0.5, 0, accuracy: 0.08)
            XCTAssertEqual(left.y, right.y, accuracy: 0.08)
        }
    }
}
