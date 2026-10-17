import Foundation
import XCTest
@testable import BeautyEffects

/// Every image, coordinate and gain below is a test-owned synthetic control.
/// None supplies a production default, neutral split or reference calibration.
final class BeautyIrisFollowingMapTests: XCTestCase {
    private typealias Point = BeautyIrisFollowingPoint
    private typealias Eye = BeautyIrisFollowingEyeCalibration
    private typealias Region = BeautyIrisFollowingRegion
    private let width = 160
    private let height = 100
    private let policy = BeautyIrisFollowingSolverPolicy(maximumIterations: 100, residualTolerancePixels: 1e-9)

    private func texture() -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            bytes[i] = UInt8(x)
            bytes[i + 1] = UInt8(y * 2)
            bytes[i + 2] = UInt8(30 + ((x * 7 + y * 11) % 190))
        } }
        return bytes
    }
    private func eye(side: BeautyIrisFollowingSide = .left,
                     center: Point = Point(x: 45, y: 50),
                     rx: Double = 25, ry: Double = 20,
                     gx: Double = 0.22, gy: Double = 0.15,
                     angle: Double = 0, owned: Region? = nil,
                     protected: [Region] = []) -> Eye {
        Eye(side: side, center: center,
            axisX: Point(x: cos(angle), y: sin(angle)), axisY: Point(x: -sin(angle), y: cos(angle)),
            supportRadiusX: rx, supportRadiusY: ry, forwardGainX: gx, forwardGainY: gy,
            ownedSourceDomain: owned ?? .rectangle(minX: 0, minY: 0, maxX: Double(width - 1), maxY: Double(height - 1)),
            protectedRegions: protected)
    }
    private func request(_ source: [UInt8], eyes: [Eye], progress: Double = 1,
                         policy: BeautyIrisFollowingSolverPolicy? = nil,
                         binding: BeautyIrisFollowingSourceBinding? = nil) -> BeautyIrisFollowingRequest {
        BeautyIrisFollowingRequest(sourceRGBA: source, width: width, height: height,
            sourceBinding: binding ?? .bind(sourceRGBA: source, width: width, height: height),
            eyes: eyes, progress: progress, solverPolicy: policy ?? self.policy)
    }
    private func distance(_ a: Point, _ b: Point) -> Double { hypot(a.x - b.x, a.y - b.y) }

    // Independent one-dimensional bisection of the radial forward equation.
    // Does not call the production field, inverse, derivative or sampler.
    private func radialInverse(_ q: Point, center: Point, radius: Double, gain: Double) -> Point {
        let dx = q.x - center.x, dy = q.y - center.y, targetRadius = hypot(dx, dy)
        if targetRadius == 0 || targetRadius >= radius { return q }
        var lo = 0.0, hi = radius
        for _ in 0..<100 {
            let mid = (lo + hi) / 2, s = mid * mid / (radius * radius)
            let mapped = mid * (1 + gain * (1 - s) * (1 - s))
            if mapped < targetRadius { lo = mid } else { hi = mid }
        }
        let r = (lo + hi) / 2
        return Point(x: center.x + dx * r / targetRadius, y: center.y + dy * r / targetRadius)
    }

    func testKnownForwardExpansionAndInverseAgainstIndependentBisection() throws {
        let e = eye(rx: 24, ry: 24, gx: 0.3, gy: 0.3)
        let p = Point(x: 53, y: 56), s = 100.0 / (24 * 24)
        let factor = 1 + 0.3 * (1 - s) * (1 - s)
        let expected = Point(x: 45 + 8 * factor, y: 50 + 6 * factor)
        let q = try XCTUnwrap(BeautyIrisFollowingMap.forwardPoint(p, eye: e, progress: 1))
        XCTAssertLessThan(distance(q, expected), 1e-12)
        let recovered = try XCTUnwrap(BeautyIrisFollowingMap.inversePoint(q, eye: e, progress: 1, solverPolicy: policy))
        XCTAssertLessThan(distance(recovered, p), 2e-9)
        let independent = radialInverse(q, center: e.center, radius: 24, gain: 0.3)
        XCTAssertLessThan(distance(recovered, independent), 2e-9)
        // The old one-step inverse is detectably different at this control point.
        let targetAsSource = try XCTUnwrap(BeautyIrisFollowingMap.forwardPoint(q, eye: e, progress: 1))
        let oneStep = Point(x: 2 * q.x - targetAsSource.x, y: 2 * q.y - targetAsSource.y)
        XCTAssertGreaterThan(distance(oneStep, p), 0.02)
    }

    func testRasterUsesIndependentInverseAndOneOriginalSample() throws {
        let source = texture(), e = eye(rx: 24, ry: 24, gx: 0.3, gy: 0.3)
        let result = BeautyIrisFollowingMap.render(request(source, eyes: [e]))
        XCTAssertEqual(result.status, .applied)
        for q in [Point(x: 52, y: 53), Point(x: 38, y: 59), Point(x: 59, y: 47)] {
            let p = radialInverse(q, center: e.center, radius: 24, gain: 0.3)
            let offset = (Int(q.y) * width + Int(q.x)) * 4
            // R and G are analytic linear coordinate encodings. Their bilinear
            // values are known without using the candidate's sampler.
            XCTAssertEqual(Double(result.rgba[offset]), p.x, accuracy: 0.500001)
            XCTAssertEqual(Double(result.rgba[offset + 1]), 2 * p.y, accuracy: 0.500001)
            XCTAssertEqual(result.rgba[offset + 3], 255)
        }
    }

    private func markerImage() -> [UInt8] {
        var bytes = [UInt8](repeating: 200, count: width * height * 4)
        // The channels identify iris, upper-lid and exposed-sclera texture.
        let markers = [Point(x: 49, y: 50), Point(x: 45, y: 42), Point(x: 57, y: 51)]
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            for c in 0..<3 {
                let dx = Double(x) - markers[c].x, dy = Double(y) - markers[c].y
                bytes[i + c] = UInt8((200 - 170 * exp(-(dx * dx + dy * dy) / 1.28)).rounded())
            }
            bytes[i + 3] = 255
        } }
        return bytes
    }
    private func markerCentroid(_ image: [UInt8], channel: Int) -> Point {
        var mass = 0.0, sumX = 0.0, sumY = 0.0
        for y in 20..<80 { for x in 15..<76 {
            let weight = Double(200 - Int(image[(y * width + x) * 4 + channel]))
            mass += weight; sumX += Double(x) * weight; sumY += Double(y) * weight
        } }
        return Point(x: sumX / mass, y: sumY / mass)
    }
    private func followsAllMarkers(_ image: [UInt8]) -> Bool {
        // Expected positions calculated independently from this synthetic
        // source and declared candidate equation, not from measured output.
        let points = [Point(x: 49, y: 50), Point(x: 45, y: 42), Point(x: 57, y: 51)]
        return points.enumerated().allSatisfy { channel, p in
            let x = p.x - 45, y = p.y - 50
            let s = x * x / 625 + y * y / 400, w = (1 - s) * (1 - s)
            let expected = Point(x: p.x + 0.22 * x * w, y: p.y + 0.15 * y * w)
            return distance(markerCentroid(image, channel: channel), expected) < 0.16
        }
    }

    func testIrisLidAndScleraCorrespondencesFollowAndFixedLidMutantFails() {
        let source = markerImage()
        let result = BeautyIrisFollowingMap.render(request(source, eyes: [eye()]))
        XCTAssertEqual(result.status, .applied)
        XCTAssertTrue(followsAllMarkers(result.rgba), "All three independently identified materials must move")
        var fixedLidMutant = result.rgba
        // A fixed-aperture/legacy-style negative control retains original lid
        // pixels even though the iris and sclera channels were transformed.
        for i in stride(from: 0, to: source.count, by: 4) { fixedLidMutant[i + 1] = source[i + 1] }
        XCTAssertFalse(followsAllMarkers(fixedLidMutant))
        XCTAssertGreaterThan(distance(markerCentroid(result.rgba, channel: 1), Point(x: 45, y: 42)), 0.5)
        XCTAssertGreaterThan(distance(markerCentroid(result.rgba, channel: 2), Point(x: 57, y: 51)), 0.5)
    }

    func testZeroAndOutsideSupportAreByteExactAndBroadWarpNegativeFailsQuietOracle() {
        let source = texture(), e = eye()
        let zero = BeautyIrisFollowingMap.render(request(source, eyes: [e], progress: 0))
        XCTAssertEqual(zero.status, .unchanged)
        XCTAssertTrue(zero.rgba == source)
        let actual = BeautyIrisFollowingMap.render(request(source, eyes: [e]))
        func quiet(_ image: [UInt8]) -> Bool {
            // Independent declared quiet window strictly outside the support.
            for y in 44...56 { for x in 72...79 {
                let i = (y * width + x) * 4
                if image[i..<(i + 4)] != source[i..<(i + 4)] { return false }
            } }
            return true
        }
        XCTAssertTrue(quiet(actual.rgba))
        let broad = BeautyIrisFollowingMap.render(request(source, eyes: [eye(rx: 40, ry: 30)]))
        XCTAssertEqual(broad.status, .applied)
        XCTAssertFalse(quiet(broad.rgba), "A whole-eye-scale overreach must fail the quiet-region oracle")
    }

    func testCompleteDerivativeMatchesFiniteDifferencesInRotatedFrame() throws {
        let e = eye(rx: 25, ry: 16, gx: 0.24, gy: -0.17, angle: 0.42)
        let p = Point(x: 56, y: 55), h = 1e-4
        let d = try XCTUnwrap(BeautyIrisFollowingMap.displacementDerivative(at: p, eye: e, progress: 0.7))
        func forward(_ x: Double, _ y: Double) throws -> Point {
            try XCTUnwrap(BeautyIrisFollowingMap.forwardPoint(Point(x: x, y: y), eye: e, progress: 0.7))
        }
        let xp = try forward(p.x + h, p.y), xm = try forward(p.x - h, p.y)
        let yp = try forward(p.x, p.y + h), ym = try forward(p.x, p.y - h)
        XCTAssertEqual(d.xx, (xp.x - xm.x) / (2 * h) - 1, accuracy: 2e-9)
        XCTAssertEqual(d.yx, (xp.y - xm.y) / (2 * h), accuracy: 2e-9)
        XCTAssertEqual(d.xy, (yp.x - ym.x) / (2 * h), accuracy: 2e-9)
        XCTAssertEqual(d.yy, (yp.y - ym.y) / (2 * h) - 1, accuracy: 2e-9)
        // This location is in the decay band: a derivative omitting dw fails.
        let naiveXX = 0.7 * 0.24
        XCTAssertGreaterThan(abs(d.xx - naiveXX), 0.05)
    }

    func testAnalyticCertificateIncludesAspectAndBoundsFullDerivative() throws {
        let e = eye(rx: 30, ry: 10, gx: 0.2, gy: -0.14, angle: 0.3)
        let bound = try XCTUnwrap(BeautyIrisFollowingMap.contractionBound(eye: e, progress: 1))
        let c = (3.0 + 1.0 / 3) / 2
        XCTAssertEqual(bound, 0.2 * 4 * c * c / (4 * c - 1), accuracy: 1e-14)
        for y in stride(from: 40.0, through: 60, by: 1.5) {
            for x in stride(from: 15.0, through: 75, by: 2.5) {
                let d = try XCTUnwrap(BeautyIrisFollowingMap.displacementDerivative(at: Point(x: x, y: y), eye: e, progress: 1))
                let trace = d.xx * d.xx + d.xy * d.xy + d.yx * d.yx + d.yy * d.yy
                let determinant = d.xx * d.yy - d.xy * d.yx
                let norm = sqrt((trace + sqrt(max(0, trace * trace - 4 * determinant * determinant))) / 2)
                XCTAssertLessThanOrEqual(norm, bound + 1e-12)
            }
        }
    }

    func testNearOrthonormalExtremeAspectCannotBypassWorldContractionCertificate() throws {
        // A numerical basis admitted by the 1e-8 representation tolerance is
        // still NOT an exact rotation. This independently derived counterexample
        // used to pass a local-only certificate while ||world dD|| exceeded one.
        let a = 1 + 4e-9, rx = 2e8, ry = 1.0
        let c = (rx / ry + ry / rx) / 2, coefficient = c / (1 - 0.25 / c)
        let gain = (1 - 1e-10) / coefficient
        let e = Eye(side: .left, center: Point(x: 45, y: 50),
            axisX: Point(x: a, y: 0), axisY: Point(x: 0, y: a),
            supportRadiusX: rx, supportRadiusY: ry, forwardGainX: gain, forwardGainY: gain,
            ownedSourceDomain: .rectangle(minX: 0, minY: 0, maxX: 159, maxY: 99), protectedRegions: [])
        let localOnlyBound = gain * coefficient
        XCTAssertLessThan(localOnlyBound, 1)
        let independentWorldXY = -a * a * gain * 1e8
        XCTAssertGreaterThan(abs(independentWorldXY), 1)
        let p = Point(x: 45 + 1e8 / a, y: 50 + 0.5 / a)
        let derivative = try XCTUnwrap(BeautyIrisFollowingMap.displacementDerivative(at: p, eye: e, progress: 1))
        XCTAssertEqual(derivative.xy, independentWorldXY, accuracy: 2e-12)
        XCTAssertGreaterThan(try XCTUnwrap(BeautyIrisFollowingMap.contractionBound(eye: e, progress: 1)), 1)
        XCTAssertNil(BeautyIrisFollowingMap.inversePoint(Point(x: 46, y: 50), eye: e, progress: 1, solverPolicy: policy))
        let result = BeautyIrisFollowingMap.render(request(texture(), eyes: [e]))
        XCTAssertEqual(result.refusalCounts[.unsafeContraction], 1)
    }

    func testNearOrthonormalExtremeAspectBoundingBoxCoversActualPerimeterCell() throws {
        // With R=aI and a<1, actual source support is diag(rx/a,ry/a),
        // whereas using R*diag(rx,ry) misses >1 pixel at this extreme aspect.
        // Only column 0 enters the image. Its displacement is intentionally
        // sub-quantization: this checks coverage/admission, not visual efficacy.
        let a = 1 - 4e-9, center = Point(x: -200000000.3, y: 50)
        let e = Eye(side: .left, center: center,
            axisX: Point(x: a, y: 0), axisY: Point(x: 0, y: a),
            supportRadiusX: 2e8, supportRadiusY: 1, forwardGainX: -1e-9, forwardGainY: 0,
            ownedSourceDomain: .rectangle(minX: 0, minY: 0, maxX: 159, maxY: 99), protectedRegions: [])
        XCTAssertLessThan(center.x + 2e8 * a, 0, "The old R-based box would exclude the actual image cell")
        XCTAssertGreaterThan(center.x + 2e8 / a, 0)
        let sourcePoint = Point(x: 0, y: 50)
        let mapped = try XCTUnwrap(BeautyIrisFollowingMap.forwardPoint(sourcePoint, eye: e, progress: 1))
        XCTAssertLessThan(mapped.x, 0)
        let result = BeautyIrisFollowingMap.render(request(texture(), eyes: [e]))
        XCTAssertEqual(result.status, .applied)
        XCTAssertEqual(result.appliedEyeCount, 1)
        XCTAssertNil(result.refusalCounts[.emptySupport])
    }

    func testUnsafeCalibrationRefusesOneEyeAndPreservesValidPeer() {
        let source = texture()
        let result = BeautyIrisFollowingMap.render(request(source,
            eyes: [eye(gx: 0.95), eye(side: .right, center: Point(x: 115, y: 50))]))
        XCTAssertEqual(result.status, .partiallyApplied)
        XCTAssertEqual(result.refusalCounts[.unsafeContraction], 1)
        assertLeftUnchangedAndPeerChanged(result.rgba, source)
    }

    func testMalformedFrameAndNonFiniteGainAreLocalRefusals() {
        let source = texture(), right = eye(side: .right, center: Point(x: 115, y: 50))
        let invalid = Eye(side: .left, center: Point(x: 45, y: 50), axisX: Point(x: 1, y: 0),
            axisY: Point(x: 1, y: 0), supportRadiusX: 25, supportRadiusY: 20,
            forwardGainX: 0.2, forwardGainY: 0.2,
            ownedSourceDomain: .rectangle(minX: 0, minY: 0, maxX: 159, maxY: 99), protectedRegions: [])
        for bad in [invalid, eye(gx: .nan), eye(rx: 0)] {
            let result = BeautyIrisFollowingMap.render(request(source, eyes: [bad, right]))
            XCTAssertEqual(result.refusalCounts[.invalidCalibration], 1)
            XCTAssertEqual(result.status, .partiallyApplied)
            assertLeftUnchangedAndPeerChanged(result.rgba, source)
        }
    }

    func testOverlappingSupportsAndDuplicateSidesNeverComposeUncertifiedFields() {
        let source = texture()
        let overlap = BeautyIrisFollowingMap.render(request(source,
            eyes: [eye(), eye(side: .right, center: Point(x: 70, y: 50))]))
        XCTAssertEqual(overlap.refusalCounts[.overlappingSupport], 2)
        XCTAssertTrue(overlap.rgba == source)
        let duplicate = BeautyIrisFollowingMap.render(request(source,
            eyes: [eye(), eye(center: Point(x: 115, y: 50))]))
        XCTAssertEqual(duplicate.refusalCounts[.duplicateSide], 2)
        XCTAssertTrue(duplicate.rgba == source)
    }

    func testProtectedSupportRefusesLocallyAndLeavesProtectedPixelsExact() {
        let source = texture()
        let protected = Region.ellipse(center: Point(x: 45, y: 33), radiusX: 5, radiusY: 2)
        let result = BeautyIrisFollowingMap.render(request(source,
            eyes: [eye(protected: [protected]), eye(side: .right, center: Point(x: 115, y: 50))]))
        XCTAssertEqual(result.refusalCounts[.protectedSupport], 1)
        XCTAssertEqual(result.status, .partiallyApplied)
        assertLeftUnchangedAndPeerChanged(result.rgba, source)
    }

    func testStrongSourceBindingRejectsByteChangeAndSameAreaDimensionChange() {
        let source = texture(), binding = BeautyIrisFollowingSourceBinding.bind(sourceRGBA: source, width: width, height: height)
        var changed = source; changed[(50 * width + 49) * 4 + 1] ^= 1
        let result = BeautyIrisFollowingMap.render(request(changed, eyes: [eye()], binding: binding))
        XCTAssertEqual(result.refusalCounts[.sourceMismatch], 1)
        XCTAssertTrue(result.rgba == changed)
        let staleRequest = request(source, eyes: [eye()])
        let stageSource = BeautyIrisFollowingMap.render(staleRequest, sourceRGBA: changed, width: width, height: height)
        XCTAssertEqual(stageSource.refusalCounts[.sourceMismatch], 1)
        XCTAssertTrue(stageSource.rgba == changed, "Refusal must preserve the actual stage source, not the stale retained source")
        let dimensions = BeautyIrisFollowingRequest(sourceRGBA: source, width: height, height: width,
            sourceBinding: binding, eyes: [eye()], progress: 1, solverPolicy: policy)
        XCTAssertEqual(BeautyIrisFollowingMap.render(dimensions).refusalCounts[.sourceMismatch], 1)
    }

    func testUnknownOwnershipAndAlphaRefuseWholeEyeBeforeSamplingAndPreservePeer() {
        let source = texture(), right = eye(side: .right, center: Point(x: 115, y: 50))
        let tooSmall = Region.rectangle(minX: 25, minY: 32, maxX: 65, maxY: 68)
        let ownership = BeautyIrisFollowingMap.render(request(source, eyes: [eye(owned: tooSmall), right]))
        XCTAssertEqual(ownership.refusalCounts[.unownedSource], 1)
        assertLeftUnchangedAndPeerChanged(ownership.rgba, source)
        var alpha = source; alpha[(50 * width + 49) * 4 + 3] = 254
        let opacity = BeautyIrisFollowingMap.render(request(alpha, eyes: [eye(), right]))
        XCTAssertEqual(opacity.refusalCounts[.nonOpaqueSource], 1)
        assertLeftUnchangedAndPeerChanged(opacity.rgba, alpha)
    }

    func testBilinearFootprintChecksAllFourTapsIncludingEllipseOwnership() {
        let source = texture()
        // Although each target is inside the declared support, an exterior
        // corner tap lies outside this exact ellipse. The eye must be refused.
        let exactEllipse = Region.ellipse(center: Point(x: 45, y: 50), radiusX: 25, radiusY: 20)
        let result = BeautyIrisFollowingMap.render(request(source, eyes: [eye(gx: -0.22, gy: -0.15, owned: exactEllipse)]))
        XCTAssertEqual(result.refusalCounts[.unownedSource], 1)
        XCTAssertTrue(result.rgba == source)
        let boundary = BeautyIrisFollowingMap.render(request(source,
            eyes: [eye(center: Point(x: 3, y: 50), rx: 8, ry: 8, gx: -0.2, gy: -0.2)]))
        XCTAssertEqual(boundary.refusalCounts[.sourceFootprintOutOfBounds], 1)
        XCTAssertTrue(boundary.rgba == source)
    }

    func testInverseNonConvergenceIsTransactionalAndValidPeerStillApplies() {
        let source = texture()
        let result = BeautyIrisFollowingMap.render(request(source,
            eyes: [eye(gx: 0.4, gy: 0.35), eye(side: .right, center: Point(x: 115, y: 50), gx: 0.01, gy: 0.01)],
            policy: BeautyIrisFollowingSolverPolicy(maximumIterations: 1, residualTolerancePixels: 0.002)))
        XCTAssertEqual(result.refusalCounts[.inverseDidNotConverge], 1)
        XCTAssertEqual(result.status, .partiallyApplied)
        assertLeftUnchangedAndPeerChanged(result.rgba, source)
    }

    func testStageObservedSideAdmissionRefusesMissingSideAndPreservesValidPeer() {
        let source = texture(), r = request(source,
            eyes: [eye(), eye(side: .right, center: Point(x: 115, y: 50))])
        let peer = BeautyIrisFollowingMap.render(r, sourceRGBA: source, width: width, height: height,
                                                availableObservedSides: [.right])
        XCTAssertEqual(peer.refusalCounts[.missingObservedEyeSupport], 1)
        XCTAssertEqual(peer.status, .partiallyApplied)
        assertLeftUnchangedAndPeerChanged(peer.rgba, source)
        let noFace = BeautyIrisFollowingMap.render(r, sourceRGBA: source, width: width, height: height,
                                                  availableObservedSides: [])
        XCTAssertEqual(noFace.refusalCounts[.missingObservedEyeSupport], 2)
        XCTAssertTrue(noFace.rgba == source)
    }

    func testMalformedRequestReturnsExplicitRefusalInsteadOfAbsence() {
        let source = texture()
        for progress in [Double.nan, -.infinity, -0.01, 1.01] {
            let result = BeautyIrisFollowingMap.render(request(source, eyes: [eye()], progress: progress))
            XCTAssertEqual(result.status, .refused)
            XCTAssertEqual(result.refusalCounts[.invalidProgress], 1)
            XCTAssertTrue(result.rgba == source)
        }
        for p in [BeautyIrisFollowingSolverPolicy(maximumIterations: 0, residualTolerancePixels: 1e-6),
                  BeautyIrisFollowingSolverPolicy(maximumIterations: 2, residualTolerancePixels: .nan)] {
            XCTAssertEqual(BeautyIrisFollowingMap.render(request(source, eyes: [eye()], policy: p)).refusalCounts[.invalidSolverPolicy], 1)
        }
        XCTAssertEqual(BeautyIrisFollowingMap.render(request(source, eyes: [])).refusalCounts[.invalidEyeCount], 1)
        let invalid = BeautyIrisFollowingRequest(sourceRGBA: [], width: Int.max, height: 4,
            sourceBinding: .bind(sourceRGBA: [], width: Int.max, height: 4), eyes: [eye()], progress: 1, solverPolicy: policy)
        XCTAssertEqual(BeautyIrisFollowingMap.render(invalid).refusalCounts[.invalidImage], 1)
    }

    func testPrivacyDescriptionsAndReflectionDoNotExposePixelsCoordinatesOrBinding() {
        let source = texture(), e = eye(), r = request(source, eyes: [e])
        let values: [Any] = [e.center, e, e.ownedSourceDomain, r.sourceBinding, r, BeautyIrisFollowingMap.render(r)]
        for value in values {
            XCTAssertEqual(Mirror(reflecting: value).children.count, 0)
            let debug = String(reflecting: value)
            XCTAssertFalse(debug.contains("sourceRGBA"))
            XCTAssertFalse(debug.contains("digest"))
            XCTAssertFalse(debug.contains("supportRadius"))
            XCTAssertFalse(debug.contains("45.0"))
        }
    }

    private func assertLeftUnchangedAndPeerChanged(_ image: [UInt8], _ source: [UInt8],
                                                  file: StaticString = #filePath, line: UInt = #line) {
        var peerChanged = false
        for y in 0..<height { for x in 0..<width {
            let i = (y * width + x) * 4
            if x < 80 {
                XCTAssertTrue(image[i..<(i + 4)] == source[i..<(i + 4)], file: file, line: line)
            } else if image[i..<(i + 4)] != source[i..<(i + 4)] { peerChanged = true }
        } }
        XCTAssertTrue(peerChanged, file: file, line: line)
    }
}
