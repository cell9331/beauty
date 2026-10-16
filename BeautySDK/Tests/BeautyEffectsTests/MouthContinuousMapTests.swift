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

    func testHorizontalPositionOnTiltedMouthMovesPredominantlyAlongUprightImageX() throws {
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
        // The physical source boxes use upright image coordinates. Rotating
        // their support into a mouth-axis box does not preserve the same set.
        let physicalBoxes: [(minX: Double, maxX: Double, minY: Double, maxY: Double)] =
            [face.leftEye, face.rightEye, face.nose].map { points in
            let pixels = points.map { Point(Double($0.x) * Double(width), Double($0.y) * Double(height)) }
            let xValues = pixels.map(\.x), yValues = pixels.map(\.y)
            let minX = xValues.min()! - 2, maxX = xValues.max()! + 2
            let minY = yValues.min()! - 2, maxY = yValues.max()! + 2
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
                assertFiniteCertificate(map)
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
                        XCTAssertLessThanOrEqual(operatorNorm(gx, gy), map.maximumGradient + 0.005)
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
        var previous = 0.0
        for fraction: Float in [0.25, 0.5, 0.75] {
            let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                face: face, strengths: strengths(7, -fraction)))
            let response = baseline - thickness(map.applyRGBA(source))
            XCTAssertGreaterThan(response, previous)
            XCTAssertLessThan(response, total)
            previous = response
            assertFiniteCertificate(map)
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
        for sign: Float in [-1, 1] {
            var previous = 0.0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                    face: face, strengths: strengths(5, sign * fraction)))
                let targets = [left, right].map { $0 + map.forwardDisplacement(at: $0) }
                let shifts = zip([left, right], targets).map { source, target in
                    (target.x - source.x) * axis.x + (target.y - source.y) * axis.y
                }
                let motion = (shifts[0] + shifts[1]) * 0.5 * Double(sign)
                XCTAssertGreaterThan(motion, previous + 0.1)
                XCTAssertEqual(shifts[0], shifts[1], accuracy: 0.000001)
                let vector = targets[1] - targets[0]
                XCTAssertEqual(hypot(vector.x, vector.y), span, accuracy: 0.000001)
                for (source, target) in zip([left, right], targets) {
                    let recovered = try XCTUnwrap(map.sourcePoint(for: target))
                    XCTAssertLessThan(hypot(recovered.x-source.x, recovered.y-source.y), 0.001)
                }
                for point in face.nose + face.leftEye + face.rightEye {
                    XCTAssertEqual(map.displacement(at: Point(Double(point.x) * Double(width),
                                                              Double(point.y) * Double(height))), .zero)
                }
                assertFiniteCertificate(map)
                if fraction == 1 { XCTAssertGreaterThan(motion, 1) }
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

    private func assertFiniteCertificate(_ map: BeautyContinuousMouthMap,
                                         file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(map.maximumGradient.isFinite && map.maximumGradient >= 0, file: file, line: line)
        XCTAssertTrue(map.maximumDisplacement.isFinite && map.maximumDisplacement > 0, file: file, line: line)
        XCTAssertTrue(map.safetyScale.isFinite && map.safetyScale > 0 && map.safetyScale <= 1,
                      file: file, line: line)
    }

    private func certificatePoints(width: Int, height: Int) -> [Point] {
        stride(from: 0.40, through: 0.95, by: 0.05).flatMap { y in
            stride(from: 0.15, through: 0.85, by: 0.05).map { Point($0 * Double(width), y * Double(height)) }
        }
    }

    /// Independent finite differences include both off-diagonal derivatives.
    /// This is a sampled check of the implementation's global certificate,
    /// rather than a replacement for the analytic model bound.
    private func assertMappingCertificate(_ map: BeautyContinuousMouthMap, points: [Point],
                                          file: StaticString = #filePath, line: UInt = #line) throws {
        assertFiniteCertificate(map, file: file, line: line)
        let epsilon = 0.02
        for p in points {
            let displacement = map.forwardDisplacement(at: p), q = p + displacement
            let recovered = try XCTUnwrap(map.sourcePoint(for: q), file: file, line: line)
            XCTAssertLessThanOrEqual(hypot(recovered.x - p.x, recovered.y - p.y), 0.001,
                                     file: file, line: line)
            let inverseOffset = map.displacement(at: q)
            XCTAssertEqual(inverseOffset.x, displacement.x, accuracy: 0.001, file: file, line: line)
            XCTAssertEqual(inverseOffset.y, displacement.y, accuracy: 0.001, file: file, line: line)
            XCTAssertLessThanOrEqual(hypot(displacement.x, displacement.y),
                                     map.maximumDisplacement + 0.000001, file: file, line: line)
            let dx = (map.forwardDisplacement(at: p + Point(epsilon, 0))
                - map.forwardDisplacement(at: p - Point(epsilon, 0))) / (2 * epsilon)
            let dy = (map.forwardDisplacement(at: p + Point(0, epsilon))
                - map.forwardDisplacement(at: p - Point(0, epsilon))) / (2 * epsilon)
            let determinant = (1 + dx.x) * (1 + dy.y) - dy.x * dx.y
            XCTAssertGreaterThan(determinant, 0, file: file, line: line)
            let inverseX = (map.displacement(at: q + Point(epsilon, 0))
                - map.displacement(at: q - Point(epsilon, 0))) / (2 * epsilon)
            let inverseY = (map.displacement(at: q + Point(0, epsilon))
                - map.displacement(at: q - Point(0, epsilon))) / (2 * epsilon)
            XCTAssertLessThanOrEqual(operatorNorm(inverseX, inverseY), map.maximumGradient + 0.005,
                                     file: file, line: line)
        }
    }

    private func operatorNorm(_ x: Point, _ y: Point) -> Double {
        let a = x.x*x.x+x.y*x.y, b = x.x*y.x+x.y*y.y, d = y.x*y.x+y.y*y.y
        return sqrt(max(0, (a+d+sqrt((a-d)*(a-d)+4*b*b))*0.5))
    }

    /// Oral pixels can relocate with the new geometric field. Check the
    /// original source texture under the actual inverse, without recoloring,
    /// freezing a destination rectangle, or sampling a previous edited image.
    private func assertOriginalSampling(_ map: BeautyContinuousMouthMap, source: [UInt8], output: [UInt8],
                                        file: StaticString = #filePath, line: UInt = #line) throws {
        let width = map.width, height = map.height
        for y in stride(from: Int(0.63*Double(height)), through: Int(0.67*Double(height)), by: 2) {
            for x in stride(from: Int(0.36*Double(width)), through: Int(0.64*Double(width)), by: 3) {
                let sourcePoint = try XCTUnwrap(map.sourcePoint(for: Point(Double(x)+0.5, Double(y)+0.5)),
                                               file: file, line: line)
                let sx = min(Double(width-1), max(0, sourcePoint.x-0.5))
                let sy = min(Double(height-1), max(0, sourcePoint.y-0.5))
                let ix = Int(floor(sx)), iy = Int(floor(sy))
                let jx = min(ix+1, width-1), jy = min(iy+1, height-1)
                let indices = [(iy*width+ix)*4, (iy*width+jx)*4, (jy*width+ix)*4, (jy*width+jx)*4]
                let destination = (y*width+x)*4, alpha = source[destination+3]
                if !indices.allSatisfy({ source[$0+3] == alpha }) {
                    XCTAssertEqual(Array(output[destination..<destination+4]),
                                   Array(source[destination..<destination+4]), file: file, line: line)
                    continue
                }
                let ax = sx-Double(ix), ay = sy-Double(iy)
                for channel in 0..<3 {
                    let row0 = Double(source[indices[0]+channel])*(1-ax)+Double(source[indices[1]+channel])*ax
                    let row1 = Double(source[indices[2]+channel])*(1-ax)+Double(source[indices[3]+channel])*ax
                    let expected = UInt8(min(255, max(0, Int((row0*(1-ay)+row1*ay).rounded()))))
                    XCTAssertEqual(output[destination+channel], expected, file: file, line: line)
                }
                XCTAssertEqual(output[destination+3], alpha, file: file, line: line)
            }
        }
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
                        if fraction == 1 {
                            XCTAssertGreaterThan(gain, 1)
                            try assertMappingCertificate(map, points: certificatePoints(width: width, height: height))
                        }
                        previous = gain
                        assertFiniteCertificate(map)
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

    func testSmileSpreadsAndBendsCornersWithWeakerOppositeCentralMotion() throws {
        for (width, height) in [(480, 600), (600, 420)] {
            let face = anatomy()
            let source = markers(width: width, height: height,
                locations: [Point(0.335, 0.65), Point(0.5, 0.62), Point(0.665, 0.65)])
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
                    let originalCenter = centroid(source, width: width, height: height, xRange: 0.47..<0.53)
                    let movedCenter = centroid(output, width: width, height: height, xRange: 0.47..<0.53)
                    let centralDrop = (movedCenter.y - originalCenter.y) * Double(sign)
                    XCTAssertGreaterThan(centralDrop, 0)
                    XCTAssertLessThan(centralDrop, min(leftRise, rightRise))
                    XCTAssertEqual(output, map.applyRGBA(source))
                    assertFiniteCertificate(map)
                    try assertMappingCertificate(map, points: [Point(0.335 * Double(width), 0.65 * Double(height)),
                        Point(0.5 * Double(width), 0.62 * Double(height)), Point(0.665 * Double(width), 0.65 * Double(height))])
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

    func testPeakAndPlumpHaveDistinctSignedShapesAndValidInverseSampling() throws {
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
                    assertFiniteCertificate(map)
                    try assertMappingCertificate(map, points: certificatePoints(width: width, height: height))
                    // The vertical-only local fields retain column order
                    // across each lip and skin transition; the complete 2D
                    // Jacobian and inverse certificate are checked above.
                    for x in peakXs {
                        var previousSourceY: Double?
                        for y in stride(from: 0.55 * Double(height), through: 0.75 * Double(height), by: 0.25) {
                            let q = Point(x * Double(width), y)
                            let sourceY = y - map.displacement(at: q).y
                            if let previousSourceY {
                                XCTAssertGreaterThan(sourceY - previousSourceY, 0,
                                    "The complete inverse remains orientation preserving")
                            }
                            previousSourceY = sourceY
                        }
                    }
                }
            }
        }
        let peak = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height, face: face, strengths: strengths(6, 1)))
        let plump = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height, face: face, strengths: strengths(7, 1)))
        let lowerPoint = Point(240, 0.701 * 600)
        XCTAssertLessThan(peak.forwardDisplacement(at: lowerPoint).y, 0,
            "M-shape permits a localized lower-edge response")
        let xs = stride(from: 0.38, through: 0.62, by: 0.015)
        let upperMean = xs.map { x in
            abs(peak.forwardDisplacement(at: Point(x*Double(width), upper(x)*Double(height))).y)
        }.reduce(0, +)
        let lowerMean = xs.map { x in
            abs(peak.forwardDisplacement(at: Point(x*Double(width), lower(x)*Double(height))).y)
        }.reduce(0, +)
        XCTAssertGreaterThan(lowerMean, 0)
        XCTAssertLessThan(lowerMean, upperMean, "The lower lip has a weaker aggregate response, with a localized peak")
        XCTAssertGreaterThan(plump.forwardDisplacement(at: lowerPoint).y, 0,
            "Fullness expands the lower lip instead of reproducing M-shape")
        XCTAssertEqual(plump.forwardDisplacement(at: Point(240, 390)).y, 0, accuracy: 0.0001,
            "Only the source seam itself is an anchor; its surrounding band can move")
    }

    func testActualPixelsProtectNoseEyesExteriorAlphaAndSampleMovingOralTextureOnce() throws {
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
                try assertOriginalSampling(map, source: source, output: output)
                for y in 0..<height { for x in 0..<width {
                    let px = (Double(x) + 0.5) / Double(width), py = (Double(y) + 0.5) / Double(height)
                    let nose = (0.45...0.55).contains(px) && (0.46...0.55).contains(py)
                    let eyes = ((0.28...0.40).contains(px) || (0.60...0.72).contains(px)) && (0.30...0.345).contains(py)
                    let exterior = px < 0.03 || px > 0.97 || py < 0.25 || py > 0.93
                    let i = (y * width + x) * 4
                    XCTAssertEqual(output[i + 3], source[i + 3])
                    if nose || eyes || exterior {
                        XCTAssertEqual(Array(output[i..<i + 3]), Array(source[i..<i + 3]), "protected field=\(field)")
                    }
                } }
            }
        }
    }

    func testThinUpperLipPeakAndFullnessHaveSignedContinuousQuarterSteps() throws {
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
                        XCTAssertGreaterThan(gain, previous,
                            "Endpoint must continue the visible signed progression")
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
                    assertFiniteCertificate(map)
                    try assertMappingCertificate(map, points: certificatePoints(width: width, height: height))
                }
            }
        }
    }

    func testThinUpperLipPixelsPreserveNoseEyesExteriorAlphaAndMovingOralTexture() throws {
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
            try assertOriginalSampling(map, source: source, output: output)
            for y in 0..<height { for x in 0..<width {
                let px = (Double(x) + 0.5) / Double(width), py = (Double(y) + 0.5) / Double(height)
                let nose = (0.45...0.55).contains(px) && (0.46...0.55).contains(py)
                let eyes = ((0.28...0.40).contains(px) || (0.60...0.72).contains(px)) && (0.30...0.345).contains(py)
                let exterior = px < 0.03 || px > 0.97 || py < 0.25 || py > 0.93
                let i = (y * width + x) * 4
                XCTAssertEqual(output[i + 3], source[i + 3])
                if nose || eyes || exterior {
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
        let original = anatomy(samples: 11)
        let originalPath = try XCTUnwrap(original.observedOuterLips)
        for subdivisions in [1, 2, 3] {
            let path = originalPath.indices.flatMap { index in
                (0..<subdivisions).map { part in
                    originalPath[index] + (originalPath[(index + 1) % originalPath.count] - originalPath[index])
                        * Float(part) / Float(subdivisions)
                }
            }
            let face = FaceGeometry(bounds: original.bounds, faceContour: original.faceContour,
                leftEye: original.leftEye, rightEye: original.rightEye, nose: original.nose,
                outerLips: path, upperLips: [], lowerLips: [], innerLips: original.innerLips,
                observedOuterLips: path, observedInnerLips: original.observedInnerLips)
            let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                face: face, strengths: strengths(5, 1)))
            centers.append(centroid(map.applyRGBA(source), width: width, height: height))
        }
        XCTAssertEqual(centers[0].x, centers[1].x, accuracy: 0.01)
        XCTAssertEqual(centers[1].x, centers[2].x, accuracy: 0.01)
        for sign: Float in [-1, 1] {
            var combined = BeautyEffectiveStrengths()
            for (key, cap) in zip(BeautyContinuousMouthMap.keys, caps) { combined[keyPath: key] = sign * cap }
            let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height, face: anatomy(), strengths: combined))
            assertFiniteCertificate(map)
            try assertMappingCertificate(map, points: certificatePoints(width: width, height: height))
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
        let inverse = points.map { $0 + map.forwardDisplacement(at: $0) }
        for i in 0..<points.count { for j in (i + 1)..<points.count {
            let before = points[j] - points[i], after = inverse[j] - inverse[i]
            XCTAssertEqual(hypot(after.x, after.y), hypot(before.x, before.y), accuracy: 0.000001)
        } }
        assertFiniteCertificate(map)
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
                    assertFiniteCertificate(after)
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
                assertFiniteCertificate(map)
                let points = certificatePoints(width: width, height: height)
                try assertMappingCertificate(map, points: points)
                for point in points {
                    var expected = point
                    for component in components { expected += component.forwardDisplacement(at: expected) }
                    let actual = point + map.forwardDisplacement(at: point)
                    XCTAssertEqual(actual.x, expected.x, accuracy: 0.000001)
                    XCTAssertEqual(actual.y, expected.y, accuracy: 0.000001)
                }
            }
        }
    }

    func testNegativeMUsesSignedThreeLobeResponseEvenForAnInitiallyFlatUpperLip() throws {
        let width = 480, height = 600, original = anatomy()
        // A level source border still receives the signed three-lobe design.
        // The source markers define its reverse bow independently of the field;
        // a source-dependent flatten-only negative branch is no longer used.
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
        var previousDepth = 0.0
        for amount: Float in [-0.25, -0.5, -0.75, -1] {
            let map = try XCTUnwrap(BeautyContinuousMouthMap(width: width, height: height,
                face: face, strengths: strengths(6, amount)))
            let output = map.applyRGBA(source)
            let left = centroid(output, width: width, height: height, xRange: 0.41..<0.475)
            let center = centroid(output, width: width, height: height, xRange: 0.475..<0.525)
            let right = centroid(output, width: width, height: height, xRange: 0.525..<0.59)
            let reversedDepth = (left.y + right.y) * 0.5 - center.y
            XCTAssertGreaterThan(reversedDepth, previousDepth)
            XCTAssertEqual(left.y, right.y, accuracy: 0.08)
            previousDepth = reversedDepth
            try assertMappingCertificate(map, points: [Point(0.4496*Double(width), 0.61*Double(height)),
                Point(0.5*Double(width), 0.61*Double(height)), Point(0.5504*Double(width), 0.61*Double(height))])
        }
    }
}
