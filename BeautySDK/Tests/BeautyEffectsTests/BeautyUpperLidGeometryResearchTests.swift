import Foundation
import XCTest

/// Synthetic mathematical controls only. Their coordinates/amplitudes do not
/// calibrate portraits, identify 去脂, close evidence gaps, or qualify an effect.
final class BeautyUpperLidGeometryResearchTests: XCTestCase {
    private typealias Lab = BeautyUpperLidGeometryResearch
    private typealias Point = Lab.Point
    private typealias Calibration = Lab.Calibration
    private let width = 144, height = 96
    private let policy = Lab.SolverPolicy(maximumIterations: 100, residualTolerancePixels: 1e-9)
    private func calibration(side: Lab.Side = .left, center: Point = Point(x: 40, y: 40),
                             rx: Double = 18, ry: Double = 10, amplitude: Double = 2,
                             angle: Double = 0, owned: Lab.Region? = nil,
                             protected: [Lab.Region] = []) -> Calibration {
        Calibration(side: side, center: center, axisX: Point(x: cos(angle), y: sin(angle)),
            superiorAxis: Point(x: sin(angle), y: -cos(angle)), supportRadiusX: rx, supportRadiusY: ry,
            amplitudePixels: amplitude,
            ownedSourceDomain: owned ?? .rectangle(minX: 0, minY: 0, maxX: Double(width - 1), maxY: Double(height - 1)),
            protectedRegions: protected)
    }
    private func request(_ source: [UInt8], _ calibrations: [Calibration], progress: Double = 1,
                         policy: Lab.SolverPolicy? = nil, binding: Lab.SourceBinding? = nil) -> Lab.Request {
        Lab.Request(sourceRGBA: source, width: width, height: height,
                    sourceBinding: binding ?? .bind(sourceRGBA: source, width: width, height: height),
                    calibrations: calibrations, progress: progress, solverPolicy: policy ?? self.policy)
    }
    private func texture() -> [UInt8] {
        var out = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            out[i] = UInt8(x); out[i + 1] = UInt8(2 * y); out[i + 2] = UInt8(25 + (x * 7 + y * 13) % 190)
        } }
        return out
    }
    private func distance(_ p: Point, _ q: Point) -> Double { hypot(p.x - q.x, p.y - q.y) }

    // Independent monotone bisection of the straight axis-aligned y equation.
    // The production inverse, bump and derivative are not used by this oracle.
    private func referenceInverse(_ q: Point, amplitude: Double = 2) -> Point {
        let tx = (q.x - 40) / 18
        if abs(tx) >= 1 || abs(q.y - 40) >= 10 { return q }
        let along = (1 - tx * tx) * (1 - tx * tx)
        var lower = 30.0, upper = 50.0
        for _ in 0..<100 {
            let y = (lower + upper) / 2, t = (y - 40) / 10
            let mapped = y - amplitude * along * (1 - t * t) * (1 - t * t)
            if mapped < q.y { lower = y } else { upper = y }
        }
        return Point(x: q.x, y: (lower + upper) / 2)
    }

    func testSuperiorDirectionFollowsRotatedSourceFrameAndFixedScreenNegativeFails() throws {
        let angle = Double.pi / 6, c = calibration(amplitude: 3, angle: angle)
        let expected = Point(x: 40 + 3 * sin(angle), y: 40 - 3 * cos(angle))
        let q = try XCTUnwrap(Lab.forwardPoint(c.center, calibration: c, progress: 1))
        XCTAssertLessThan(distance(q, expected), 1e-12)
        XCTAssertGreaterThan(q.x - c.center.x, 1)
        let screenUpMutant = Point(x: 40, y: 37)
        XCTAssertGreaterThan(distance(screenUpMutant, expected), 1)
        let partial = try XCTUnwrap(Lab.forwardPoint(c.center, calibration: c, progress: 0.25))
        XCTAssertEqual(partial.x - 40, 0.75 * sin(angle), accuracy: 1e-12)
    }

    func testIndependentBisectionInverseAndImmutableSourceRasterOracle() throws {
        let c = calibration(), source = texture()
        let result = Lab.render(request(source, [c]))
        XCTAssertEqual(result.status, .applied)
        for q in [Point(x: 40, y: 39), Point(x: 46, y: 42), Point(x: 31, y: 36)] {
            let expected = referenceInverse(q)
            let actual = try XCTUnwrap(Lab.inversePoint(q, calibration: c, progress: 1, solverPolicy: policy))
            XCTAssertLessThan(distance(actual, expected), 2e-9)
            let forward = try XCTUnwrap(Lab.forwardPoint(actual, calibration: c, progress: 1))
            XCTAssertLessThan(distance(forward, q), 1e-9)
            let i = (Int(q.y) * width + Int(q.x)) * 4
            XCTAssertEqual(Double(result.rgba[i]), expected.x, accuracy: 0.500001)
            XCTAssertEqual(Double(result.rgba[i + 1]), 2 * expected.y, accuracy: 0.500001)
        }
        let q = Point(x: 40, y: 36)
        let expected = referenceInverse(q)
        // A single q-D(q) evaluation is observably wrong for this nonuniform bump.
        let t = (q.y - 40) / 10, oneStepY = q.y + 2 * (1 - t * t) * (1 - t * t)
        XCTAssertGreaterThan(abs(oneStepY - expected.y), 0.05)
    }

    func testCompactBoundaryAndFullJacobianAgainstIndependentFiniteDifferences() throws {
        let c = calibration(angle: 0.41), p = Point(x: 45, y: 37), epsilon = 1e-4
        let d = try XCTUnwrap(Lab.displacementDerivative(at: p, calibration: c, progress: 0.8))
        func f(_ x: Double, _ y: Double) throws -> Point {
            try XCTUnwrap(Lab.forwardPoint(Point(x: x, y: y), calibration: c, progress: 0.8))
        }
        let xp = try f(p.x + epsilon, p.y), xm = try f(p.x - epsilon, p.y)
        let yp = try f(p.x, p.y + epsilon), ym = try f(p.x, p.y - epsilon)
        XCTAssertEqual(d.xx, (xp.x - xm.x) / (2 * epsilon) - 1, accuracy: 2e-9)
        XCTAssertEqual(d.yx, (xp.y - xm.y) / (2 * epsilon), accuracy: 2e-9)
        XCTAssertEqual(d.xy, (yp.x - ym.x) / (2 * epsilon), accuracy: 2e-9)
        XCTAssertEqual(d.yy, (yp.y - ym.y) / (2 * epsilon) - 1, accuracy: 2e-9)
        // Check both compact edges in the simple frame, including their first derivative.
        let straight = calibration()
        for edge in [Point(x: 58, y: 40), Point(x: 40, y: 30)] {
            let mapped = try XCTUnwrap(Lab.forwardPoint(edge, calibration: straight, progress: 1))
            XCTAssertEqual(mapped, edge)
            let j = try XCTUnwrap(Lab.displacementDerivative(at: edge, calibration: straight, progress: 1))
            XCTAssertEqual(abs(j.xx) + abs(j.xy) + abs(j.yx) + abs(j.yy), 0)
        }
        let near = Point(x: 58 - 1e-5, y: 40)
        let mapped = try XCTUnwrap(Lab.forwardPoint(near, calibration: straight, progress: 1))
        XCTAssertLessThan(distance(near, mapped), 1e-10)
    }

    func testGlobalCertificateBoundsFullDerivativeAndRetainsNearBasisErrors() throws {
        let c = calibration(angle: 0.5)
        let bound = try XCTUnwrap(Lab.contractionBound(calibration: c, progress: 1))
        for y in stride(from: 25.0, through: 55, by: 1.5) { for x in stride(from: 18.0, through: 62, by: 2.5) {
            let d = try XCTUnwrap(Lab.displacementDerivative(at: Point(x: x, y: y), calibration: c, progress: 1))
            // The derivative is a rank-one outer product, hence Frobenius=operator norm.
            let norm = sqrt(d.xx * d.xx + d.xy * d.xy + d.yx * d.yx + d.yy * d.yy)
            XCTAssertLessThanOrEqual(norm, bound)
        } }
        let a = 1 + 4e-9, m = 8 / (3 * sqrt(3.0)), rx = 2e8
        let amplitude = (1 - 1e-10) / (m * (1 / rx + 1))
        let nearBasis = Calibration(side: .left, center: Point(x: 40, y: 40), axisX: Point(x: a, y: 0),
            superiorAxis: Point(x: 0, y: -a), supportRadiusX: rx, supportRadiusY: 1,
            amplitudePixels: amplitude, ownedSourceDomain: .rectangle(minX: 0, minY: 0, maxX: 143, maxY: 95), protectedRegions: [])
        XCTAssertLessThan(amplitude * m * (1 / rx + 1), 1)
        XCTAssertGreaterThan(amplitude * a * a * m, 1)
        XCTAssertGreaterThan(try XCTUnwrap(Lab.contractionBound(calibration: nearBasis, progress: 1)), 1)
        XCTAssertEqual(Lab.render(request(texture(), [nearBasis])).refusalCounts[.unsafeContraction], 1)
    }

    func testInverseTransposeRectangleSupportCoversNearBasisPerimeterCell() throws {
        let a = 1 - 4e-9, center = Point(x: -200000000.3, y: 0)
        let c = Calibration(side: .left, center: center, axisX: Point(x: a, y: 0), superiorAxis: Point(x: 0, y: -a),
            supportRadiusX: 2e8, supportRadiusY: 10, amplitudePixels: 0.1,
            ownedSourceDomain: .rectangle(minX: 0, minY: 0, maxX: 143, maxY: 95), protectedRegions: [])
        XCTAssertLessThan(center.x + 2e8 * a, 0)
        XCTAssertGreaterThan(center.x + 2e8 / a, 0)
        let p = Point(x: 0, y: 0)
        let q = try XCTUnwrap(Lab.forwardPoint(p, calibration: c, progress: 1))
        XCTAssertLessThan(q.y, p.y)
        let result = Lab.render(request(texture(), [c]))
        XCTAssertEqual(result.status, .applied, "Sub-quantization coverage control, not visual efficacy")
        XCTAssertNil(result.refusalCounts[.emptySupport])
    }

    func testZeroAmplitudeZeroProgressAndExteriorAreByteExact() {
        let source = texture()
        let zero = Lab.render(request(source, [calibration()], progress: 0))
        let noAmplitude = Lab.render(request(source, [calibration(amplitude: 0)]))
        XCTAssertEqual(zero.status, .unchanged); XCTAssertEqual(noAmplitude.status, .unchanged)
        XCTAssertTrue(zero.rgba == source); XCTAssertTrue(noAmplitude.rgba == source)
        let actual = Lab.render(request(source, [calibration()]))
        for y in 0..<height { for x in 0..<width where abs(x - 40) >= 18 || abs(y - 40) >= 10 {
            let i = (y * width + x) * 4
            XCTAssertTrue(actual.rgba[i..<(i + 4)] == source[i..<(i + 4)])
        } }
    }

    private func markers() -> [UInt8] {
        let centers = [Point(x: 44, y: 38), Point(x: 43, y: 56), Point(x: 40, y: 17)]
        var source = [UInt8](repeating: 200, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            for channel in 0..<3 {
                let p = centers[channel], d = pow(Double(x) - p.x, 2) + pow(Double(y) - p.y, 2)
                source[i + channel] = UInt8((200 - 170 * exp(-d / 1.28)).rounded())
            }
            source[i + 3] = 255
        } }
        return source
    }
    private func centroid(_ source: [UInt8], channel: Int) -> Point {
        var mass = 0.0, xsum = 0.0, ysum = 0.0
        for y in 5..<75 { for x in 15..<70 {
            let value = Double(200 - Int(source[(y * width + x) * 4 + channel]))
            mass += value; xsum += Double(x) * value; ysum += Double(y) * value
        } }
        return Point(x: xsum / mass, y: ysum / mass)
    }
    private func localMovementOracle(_ output: [UInt8], source: [UInt8]) -> Bool {
        let tx: Double = 4.0 / 18.0, ty: Double = -2.0 / 10.0
        let xbase = 1.0 - tx * tx, ybase = 1.0 - ty * ty
        let wx = xbase * xbase, wy = ybase * ybase
        let expected = Point(x: 44, y: 38 - 2 * wx * wy)
        if distance(centroid(output, channel: 0), expected) >= 0.2 { return false }
        for channel in [1, 2] {
            if distance(centroid(output, channel: channel), centroid(source, channel: channel)) > 0.001 { return false }
        }
        return true
    }
    // Test-owned bilinear negative-control renderer. It does not use the helper's
    // field/inverse/sampler and is intentionally unqualified for any real image.
    private func negativeRender(_ source: [UInt8], sourceY: (Double) -> Double) -> [UInt8] {
        var out = source
        for y in 0..<height { for x in 0..<width {
            let py = min(Double(height - 1), max(0, sourceY(Double(y)))), sy = Int(floor(py))
            let next = min(height - 1, sy + 1), fraction = py - Double(sy)
            for channel in 0..<3 {
                let a = Double(source[(sy * width + x) * 4 + channel]), b = Double(source[(next * width + x) * 4 + channel])
                out[(y * width + x) * 4 + channel] = UInt8((a * (1 - fraction) + b * fraction).rounded())
            }
        } }
        return out
    }
    func testLocalizedCorrespondenceOracleRejectsAlwaysNoopGlobalAndEyeHeightLikeAliases() {
        let source = markers(), actual = Lab.render(request(source, [calibration()]))
        XCTAssertEqual(actual.status, .applied)
        XCTAssertTrue(localMovementOracle(actual.rgba, source: source))
        XCTAssertFalse(localMovementOracle(source, source: source), "Always-no-op must fail intended motion")
        let global = negativeRender(source, sourceY: { $0 + 2 })
        let eyeHeightLike = negativeRender(source, sourceY: { 44 + ($0 - 44) / 1.12 })
        XCTAssertFalse(localMovementOracle(global, source: source), "Global translation must fail protected texture")
        XCTAssertFalse(localMovementOracle(eyeHeightLike, source: source), "Symmetric vertical scaling is a distinguishable alias")
    }

    func testUnsafeNonFiniteNegativeAndDegenerateCalibrationsFailLocally() {
        let source = texture(), peer = calibration(side: .right, center: Point(x: 106, y: 40))
        for (bad, reason) in [(calibration(amplitude: 10), Lab.RefusalReason.unsafeContraction),
                              (calibration(amplitude: .nan), .invalidCalibration),
                              (calibration(amplitude: -1), .invalidCalibration),
                              (calibration(rx: 0), .invalidCalibration)] {
            let r = Lab.render(request(source, [bad, peer]))
            XCTAssertEqual(r.refusalCounts[reason], 1); assertLocalPeer(r, source)
        }
        let degenerate = Calibration(side: .left, center: Point(x: 40, y: 40), axisX: Point(x: 1, y: 0),
            superiorAxis: Point(x: 1, y: 0), supportRadiusX: 18, supportRadiusY: 10, amplitudePixels: 2,
            ownedSourceDomain: .rectangle(minX: 0, minY: 0, maxX: 143, maxY: 95), protectedRegions: [])
        let r = Lab.render(request(source, [degenerate, peer]))
        XCTAssertEqual(r.refusalCounts[.invalidCalibration], 1); assertLocalPeer(r, source)
    }

    func testSourceBindingUsesActualRasterAndDimensions() {
        let source = texture(), r = request(source, [calibration()])
        var changed = source; changed[100] ^= 1
        let stale = Lab.render(r, sourceRGBA: changed, width: width, height: height)
        XCTAssertEqual(stale.refusalCounts[.sourceMismatch], 1); XCTAssertTrue(stale.rgba == changed)
        let dimensions = Lab.render(r, sourceRGBA: source, width: height, height: width)
        XCTAssertEqual(dimensions.refusalCounts[.sourceMismatch], 1); XCTAssertTrue(dimensions.rgba == source)
    }

    func testOwnershipAndBoundsPreservePeerWhileTransparencyRefusesWholeInput() {
        let source = texture(), peer = calibration(side: .right, center: Point(x: 106, y: 40))
        let footprintDomain = Lab.Region.rectangle(minX: 22, minY: 30, maxX: 58, maxY: 49.5)
        let unowned = Lab.render(request(source, [calibration(owned: footprintDomain), peer]))
        XCTAssertEqual(unowned.refusalCounts[.unownedSource], 1); assertLocalPeer(unowned, source)
        // This transparent pixel is ON the compact edge, where the target is
        // stationary, but is a fourth interpolation tap for a moving neighbor.
        var alpha = source; alpha[(50 * width + 41) * 4 + 3] = 254
        let opacity = Lab.render(request(alpha, [calibration(), peer]))
        XCTAssertEqual(opacity.refusalCounts[.nonOpaqueInput], 2)
        XCTAssertEqual(opacity.status, .refused); XCTAssertTrue(opacity.rgba == alpha)
        let alphaNoop = Lab.render(request(alpha, [calibration()], progress: 0))
        XCTAssertEqual(alphaNoop.refusalCounts[.nonOpaqueInput], 1)
        XCTAssertEqual(alphaNoop.status, .refused); XCTAssertTrue(alphaNoop.rgba == alpha)
        var exteriorAlpha = source; exteriorAlpha[3] = 0
        let exteriorOpacity = Lab.render(request(exteriorAlpha, [calibration()]))
        XCTAssertEqual(exteriorOpacity.refusalCounts[.nonOpaqueInput], 1)
        XCTAssertEqual(exteriorOpacity.status, .refused); XCTAssertTrue(exteriorOpacity.rgba == exteriorAlpha)
        let bounds = Lab.render(request(source, [calibration(center: Point(x: 40, y: 94)), peer]))
        XCTAssertEqual(bounds.refusalCounts[.sourceFootprintOutOfBounds], 1); assertLocalPeer(bounds, source)
    }

    func testInverseFailureIsTransactionalAndPreservesConvergentPeer() {
        let source = texture(), p = Lab.SolverPolicy(maximumIterations: 1, residualTolerancePixels: 0.0003)
        let r = Lab.render(request(source, [calibration(), calibration(side: .right, center: Point(x: 106, y: 40), amplitude: 0.04)], policy: p))
        XCTAssertEqual(r.refusalCounts[.inverseDidNotConverge], 1); assertLocalPeer(r, source)
    }

    func testOverlapDuplicateAndProtectedSupportRefuseWithoutPartialPixels() {
        let source = texture()
        let overlap = Lab.render(request(source, [calibration(), calibration(side: .right, center: Point(x: 60, y: 40))]))
        XCTAssertEqual(overlap.refusalCounts[.overlappingSupport], 2); XCTAssertTrue(overlap.rgba == source)
        let duplicate = Lab.render(request(source, [calibration(), calibration(center: Point(x: 106, y: 40))]))
        XCTAssertEqual(duplicate.refusalCounts[.duplicateSide], 2); XCTAssertTrue(duplicate.rgba == source)
        let protected = Lab.render(request(source, [calibration(protected: [.ellipse(center: Point(x: 40, y: 31), radiusX: 3, radiusY: 2)]),
                                                   calibration(side: .right, center: Point(x: 106, y: 40))]))
        XCTAssertEqual(protected.refusalCounts[.protectedSupport], 1); assertLocalPeer(protected, source)
    }

    func testMalformedRequestsAreExplicitRefusalsAndDiagnosticsAreRedacted() {
        let source = texture()
        for progress in [Double.nan, -0.1, 1.1] {
            let r = Lab.render(request(source, [calibration()], progress: progress))
            XCTAssertEqual(r.refusalCounts[.invalidProgress], 1); XCTAssertTrue(r.rgba == source)
        }
        XCTAssertEqual(Lab.render(request(source, [calibration()], policy: Lab.SolverPolicy(maximumIterations: 0, residualTolerancePixels: 1e-8))).refusalCounts[.invalidSolverPolicy], 1)
        XCTAssertEqual(Lab.render(request(source, [])).refusalCounts[.invalidCount], 1)
        let invalid = Lab.Request(sourceRGBA: [], width: Int.max, height: 4,
            sourceBinding: .bind(sourceRGBA: [], width: Int.max, height: 4), calibrations: [calibration()], progress: 1, solverPolicy: policy)
        XCTAssertEqual(Lab.render(invalid).refusalCounts[.invalidImage], 1)
        let r = request(source, [calibration()])
        let privateValues: [Any] = [calibration().center, calibration(), calibration().ownedSourceDomain, r.sourceBinding, r, Lab.render(r)]
        for value in privateValues {
            XCTAssertEqual(Mirror(reflecting: value).children.count, 0)
            let debug = String(reflecting: value)
            XCTAssertFalse(debug.contains("sourceRGBA")); XCTAssertFalse(debug.contains("digest")); XCTAssertFalse(debug.contains("40.0"))
        }
    }
    private func assertLocalPeer(_ result: Lab.Result, _ source: [UInt8], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(result.status, .partiallyApplied, file: file, line: line)
        var peerChanged = false
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4, equal = result.rgba[i..<(i + 4)] == source[i..<(i + 4)]
            if x < 75 { XCTAssertTrue(equal, file: file, line: line) } else if !equal { peerChanged = true }
        } }
        XCTAssertTrue(peerChanged, file: file, line: line)
    }
}
