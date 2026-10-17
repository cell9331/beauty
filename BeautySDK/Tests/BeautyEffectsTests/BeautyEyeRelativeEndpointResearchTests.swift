import Foundation
import XCTest

final class BeautyEyeRelativeEndpointResearchTests: XCTestCase {
    private typealias Research = BeautyEyeRelativeEndpointResearch
    private typealias Point = Research.Point

    // Numerical tolerances below belong to independent analytic fixtures only.
    // They are neither photo-fit thresholds nor proposed product parameters.
    func testFiniteRigidEndpointsMatchIndependentRelativeRotationAndTranslation() throws {
        let center = Point(128, 112)
        let lowAngle = -0.18, highAngle = 0.29
        let lowTranslation = Point(-1.75, 2.25), highTranslation = Point(4.5, -1.5)
        let low = rigidBackward(center: center, angle: lowAngle, translation: lowTranslation)
        let high = rigidBackward(center: center, angle: highAngle, translation: highTranslation)
        let policy = Research.Policy(width: 256, height: 224, maximumIterations: 256,
                                     residualTolerance: 1e-11)
        let r = Point(111.25, 102.5)
        let material = center + rotated(r - center - lowTranslation, angle: -lowAngle)
        let expected = center + rotated(material - center, angle: highAngle) + highTranslation
        let result = Research.relativeForward(point: r, low: low, high: high, policy: policy)
        let q = try accepted(result)
        assertNear(q, expected, tolerance: 2e-10)
        let independentlyEvaluated = center + rotated(q - center - highTranslation, angle: -highAngle)
        XCTAssertLessThanOrEqual(distance(independentlyEvaluated, material), policy.residualTolerance)
        XCTAssertLessThanOrEqual(try XCTUnwrap(result.residual), policy.residualTolerance)
        XCTAssertGreaterThan(result.iterations, 0)
        let inverse = try accepted(Research.relativeInverse(point: q, low: low, high: high, policy: policy))
        assertNear(inverse, r, tolerance: 3e-10)
    }

    func testTrueIdentityIsExactAtImageEdgesAndDoesNotRequireAnExteriorStencil() throws {
        let source = gradient(width: 16, height: 12)
        let policy = Research.Policy(width: 16, height: 12, maximumIterations: 12,
                                     residualTolerance: 1e-10)
        for point in [Point(0, 0), Point(15, 11), Point(3.125, 4.75)] {
            let result = Research.relativeForward(point: point, low: identity, high: identity, policy: policy)
            XCTAssertEqual(try accepted(result), point)
            XCTAssertEqual(result.residual, 0)
            XCTAssertEqual(result.iterations, 0)
        }
        let result = Research.render(request(source, width: 16, height: 12, policy: policy),
                                     low: identity, high: identity)
        XCTAssertNil(result.refusal)
        XCTAssertEqual(result.status, .unchanged)
        XCTAssertEqual(result.rgba, source)
        XCTAssertEqual(result.changedPixelCount, 0)
        XCTAssertEqual(result.sampledPixelCount, 0)
    }

    func testEqualNonidentityEndpointMapsStillProduceExactRelativeIdentity() throws {
        let endpoint = Research.Endpoint(displacementLipschitzBound: 0) { $0 - Point(1.25, -0.75) }
        let policy = Research.Policy(width: 40, height: 32, maximumIterations: 20,
                                     residualTolerance: 1e-10)
        let point = Point(15.5, 12.25)
        let result = Research.relativeForward(point: point, low: endpoint, high: endpoint, policy: policy)
        XCTAssertEqual(try accepted(result), point)
        XCTAssertEqual(result.residual, 0)
        XCTAssertEqual(result.iterations, 0)
    }

    func testIdealSignedLinearRotationInversePairHasTwoAtanAngleAndUnitScale() throws {
        let center = Point(128, 112), r = center + Point(28, -11)
        let policy = Research.Policy(width: 256, height: 224, maximumIterations: 256,
                                     residualTolerance: 1e-11)
        for k in [-0.069, 0.069] {
            let low = linearRotationBackward(center: center, coefficient: -k)
            let high = linearRotationBackward(center: center, coefficient: k)
            let q = try accepted(Research.relativeForward(point: r, low: low, high: high, policy: policy))
            let expectedAngle = 2 * atan(k)
            assertNear(q, center + rotated(r - center, angle: expectedAngle), tolerance: 2e-10)
            XCTAssertEqual(distance(q, center), distance(r, center), accuracy: 2e-10)
            let a = r - center, b = q - center
            let actualAngle = atan2(a.x * b.y - a.y * b.x, a.x * b.x + a.y * b.y)
            XCTAssertEqual(actualAngle, expectedAngle, accuracy: 2e-11)
        }
    }

    func testSubtractingSameIndexOffsetArraysFailsIndependentRelativeOracle() throws {
        let center = Point(128, 112), r = center + Point(31, -7), k = 0.25
        let low = linearRotationBackward(center: center, coefficient: -k)
        let high = linearRotationBackward(center: center, coefficient: k)
        let policy = Research.Policy(width: 256, height: 224, maximumIterations: 256,
                                     residualTolerance: 1e-11)
        let correct = try accepted(Research.relativeForward(point: r, low: low, high: high, policy: policy))
        let expected = center + rotated(r - center, angle: 2 * atan(k))
        let lowB = r + perpendicular(r - center) * k
        let highB = r - perpendicular(r - center) * k
        let sameIndexSubtractionMutant = r + lowB - highB
        assertNear(correct, expected, tolerance: 2e-10)
        XCTAssertGreaterThan(distance(sameIndexSubtractionMutant, expected), 1)
    }

    func testRelativeInverseForwardClosureChecksActualAffineCallbacks() throws {
        let center = Point(128, 112)
        let low = Research.Endpoint(displacementLipschitzBound: 0.08) { q in
            center + (q - center) * 0.92 + Point(-2.5, 1.25)
        }
        let high = Research.Endpoint(displacementLipschitzBound: 0.15) { q in
            center + (q - center) * 0.85 + Point(1.75, -3.5)
        }
        let policy = Research.Policy(width: 256, height: 224, maximumIterations: 256,
                                     residualTolerance: 1e-10)
        for y in [78.25, 108.5, 137.75] {
            for x in [82.5, 123.25, 165.75] {
                let r = Point(x, y)
                let q = try accepted(Research.relativeForward(point: r, low: low, high: high, policy: policy))
                let material = center + (r - center) * 0.92 + Point(-2.5, 1.25)
                let expected = center + (material - center - Point(1.75, -3.5)) / 0.85
                assertNear(q, expected, tolerance: 3e-10)
                let recovered = try accepted(Research.relativeInverse(point: q, low: low, high: high, policy: policy))
                assertNear(recovered, r, tolerance: 4e-10)
            }
        }
    }

    func testOneSourceTranslationRasterMatchesIndependentLinearGradientExactly() {
        let width = 20, height = 18, shift = Point(0.375, -0.25)
        let source = gradient(width: width, height: height)
        let policy = Research.Policy(width: width, height: height, maximumIterations: 20,
                                     residualTolerance: 1e-12)
        let high = Research.Endpoint(displacementLipschitzBound: 0) { $0 - shift }
        let bounds = Research.Bounds(minX: 3, minY: 3, maxX: 14, maxY: 12)
        let result = Research.render(request(source, width: width, height: height,
                                             policy: policy, bounds: bounds), low: identity, high: high)
        XCTAssertNil(result.refusal)
        XCTAssertEqual(result.status, .applied)
        XCTAssertEqual(result.sampledPixelCount, 120)
        XCTAssertEqual(result.changedPixelCount, 120)
        for y in 0..<height {
            for x in 0..<width {
                let index = (y * width + x) * 4
                if (3...14).contains(x), (3...12).contains(y) {
                    let p = Point(Double(x), Double(y)) - shift
                    let expected = [10 + 3 * p.x + 2 * p.y,
                                    20 + 2 * p.x + p.y,
                                    30 + p.x + 2 * p.y]
                    for channel in 0..<3 {
                        XCTAssertEqual(result.rgba[index + channel], UInt8(expected[channel].rounded()))
                    }
                } else {
                    XCTAssertEqual(Array(result.rgba[index..<(index + 4)]),
                                   Array(source[index..<(index + 4)]))
                }
                XCTAssertEqual(result.rgba[index + 3], source[index + 3])
            }
        }
    }

    func testNilClippedNonfiniteAndOutOfDomainMapsRefuseWithoutIdentityFallback() {
        let policy = Research.Policy(width: 40, height: 32, maximumIterations: 20,
                                     residualTolerance: 1e-10)
        let missing = Research.Endpoint(displacementLipschitzBound: 0) { _ in nil }
        let nonfinite = Research.Endpoint(displacementLipschitzBound: 0) { _ in Point(.nan, 10) }
        let outside = Research.Endpoint(displacementLipschitzBound: 0) { _ in Point(-1, 10) }
        for (bad, reason) in [(missing, Research.Refusal.unavailableOrClippedMap),
                              (nonfinite, .nonFiniteMapPoint), (outside, .mappedPointOutsideImage)] {
            let result = Research.relativeForward(point: Point(12, 14), low: identity, high: bad, policy: policy)
            XCTAssertEqual(result.refusal, reason)
            XCTAssertNil(result.point)
        }
        // The actual-map seam reports clipping as nil. The helper never asks
        // a clamped color sampler to conceal the unavailable backward point.
        let clippedSeam = Research.Endpoint(displacementLipschitzBound: 0) { q in
            q.x < 2 ? nil : q - Point(2, 0)
        }
        let clipped = Research.relativeInverse(point: Point(1, 10), low: identity,
                                              high: clippedSeam, policy: policy)
        XCTAssertEqual(clipped.refusal, .unavailableOrClippedMap)
        XCTAssertNil(clipped.point)
    }

    func testInverseIterationLimitIsExplicitAndRasterRollsBack() {
        let center = Point(20, 16)
        let high = linearRotationBackward(center: center, coefficient: 0.4)
        let policy = Research.Policy(width: 40, height: 32, maximumIterations: 1,
                                     residualTolerance: 1e-14)
        let forward = Research.relativeForward(point: Point(14, 12), low: identity, high: high, policy: policy)
        XCTAssertEqual(forward.refusal, .iterationLimit)
        XCTAssertNil(forward.point)
        XCTAssertEqual(forward.iterations, 1)
        let source = gradient(width: 40, height: 32)
        let result = Research.render(request(source, width: 40, height: 32, policy: policy,
                                             bounds: .init(minX: 12, minY: 10, maxX: 17, maxY: 14)),
                                     low: high, high: identity)
        XCTAssertEqual(result.status, .refused)
        XCTAssertEqual(result.refusal, .iterationLimit)
        XCTAssertEqual(result.rgba, source)
        XCTAssertEqual(result.changedPixelCount, 0)
    }

    func testUnsafeDeclaredDisplacementBoundsAreRejectedBeforeCallbacks() {
        let policy = Research.Policy(width: 40, height: 32, maximumIterations: 20,
                                     residualTolerance: 1e-10)
        var calls = 0
        for bound in [-0.01, 1, Double.infinity, Double.nan] {
            let unsafe = Research.Endpoint(displacementLipschitzBound: bound) { q in calls += 1; return q }
            let result = Research.relativeForward(point: Point(12, 14), low: identity, high: unsafe, policy: policy)
            XCTAssertEqual(result.refusal, .unsafeGradientBound)
            XCTAssertNil(result.point)
        }
        XCTAssertEqual(calls, 0)
    }

    func testBindingDimensionsAndMalformedPoliciesCannotAuthorizeRaster() {
        let width = 20, height = 18, source = gradient(width: 20, height: 18)
        let policy = Research.Policy(width: width, height: height, maximumIterations: 20,
                                     residualTolerance: 1e-10)
        let binding = Research.SourceBinding.bind(sourceRGBA: source, width: width, height: height)
        var changed = source
        changed[0] += 1
        let stale = Research.Request(sourceRGBA: changed, width: width, height: height,
                                     sourceBinding: binding, policy: policy)
        XCTAssertEqual(Research.render(stale, low: identity, high: identity).refusal, .sourceMismatch)
        let wrongDimensions = Research.SourceBinding.bind(sourceRGBA: source, width: width - 1, height: height)
        let mismatched = Research.Request(sourceRGBA: source, width: width, height: height,
                                          sourceBinding: wrongDimensions, policy: policy)
        XCTAssertEqual(Research.render(mismatched, low: identity, high: identity).refusal, .sourceMismatch)
        let short = Research.Request(sourceRGBA: Array(source.dropLast()), width: width, height: height,
                                     sourceBinding: binding, policy: policy)
        XCTAssertEqual(Research.render(short, low: identity, high: identity).refusal, .invalidImage)
        let oversized = Research.Request(sourceRGBA: [], width: Int.max, height: 2,
                                         sourceBinding: binding, policy: policy)
        XCTAssertEqual(Research.render(oversized, low: identity, high: identity).refusal, .invalidImage)
        for invalid in [Research.Policy(width: width, height: height, maximumIterations: 0, residualTolerance: 1e-10),
                        .init(width: width, height: height, maximumIterations: Int.max, residualTolerance: 1e-10),
                        .init(width: width, height: height, maximumIterations: 20, residualTolerance: .nan),
                        .init(width: width, height: height, maximumIterations: 20, residualTolerance: 0),
                        .init(width: width + 1, height: height, maximumIterations: 20, residualTolerance: 1e-10)] {
            let malformed = Research.Request(sourceRGBA: source, width: width, height: height,
                                             sourceBinding: binding, policy: invalid)
            XCTAssertEqual(Research.render(malformed, low: identity, high: identity).refusal, .invalidPolicy)
        }
    }

    func testNonopaqueInputRefusesEvenIdentityAndInactiveExterior() {
        var source = gradient(width: 20, height: 18)
        source[3] = 254
        let policy = Research.Policy(width: 20, height: 18, maximumIterations: 20,
                                     residualTolerance: 1e-10)
        let result = Research.render(request(source, width: 20, height: 18, policy: policy,
                                             bounds: .init(minX: 4, minY: 4, maxX: 8, maxY: 8)),
                                     low: identity, high: identity)
        XCTAssertEqual(result.refusal, .nonOpaqueSource)
        XCTAssertEqual(result.status, .refused)
        XCTAssertEqual(result.rgba, source)
        XCTAssertEqual(result.sampledPixelCount, 0)
    }

    func testCompleteFourTapFootprintIsRequiredAtSourceImageBoundary() {
        let width = 20, height = 18, source = gradient(width: 20, height: 18)
        let policy = Research.Policy(width: width, height: height, maximumIterations: 20,
                                     residualTolerance: 1e-10)
        let low = Research.Endpoint(displacementLipschitzBound: 0) { $0 - Point(1, 0) }
        let result = Research.render(request(source, width: width, height: height, policy: policy,
                                             bounds: .init(minX: 18, minY: 6, maxX: 18, maxY: 6)),
                                     low: low, high: identity)
        XCTAssertEqual(result.refusal, .sourceFootprintOutOfBounds)
        XCTAssertEqual(result.rgba, source)
        XCTAssertEqual(result.changedPixelCount, 0)
    }

    func testCallbackFailureAfterSuccessfulSamplesDiscardsEntireResearchRaster() {
        let width = 20, height = 18, source = gradient(width: 20, height: 18)
        let policy = Research.Policy(width: width, height: height, maximumIterations: 20,
                                     residualTolerance: 1e-10)
        let high = Research.Endpoint(displacementLipschitzBound: 0) { q in
            q.x >= 5 ? nil : q - Point(0.25, 0)
        }
        let result = Research.render(request(source, width: width, height: height, policy: policy,
                                             bounds: .init(minX: 3, minY: 4, maxX: 6, maxY: 4)),
                                     low: identity, high: high)
        XCTAssertEqual(result.refusal, .unavailableOrClippedMap)
        XCTAssertEqual(result.status, .refused)
        XCTAssertEqual(result.sampledPixelCount, 2)
        XCTAssertEqual(result.changedPixelCount, 0)
        XCTAssertEqual(result.rgba, source)
    }

    func testInvalidPointAndEvaluationBoundsNeverClampIntoTheImage() {
        let policy = Research.Policy(width: 20, height: 18, maximumIterations: 20,
                                     residualTolerance: 1e-10)
        for point in [Point(.infinity, 2), Point(2, .nan)] {
            XCTAssertEqual(Research.relativeForward(point: point, low: identity, high: identity,
                                                   policy: policy).refusal, .nonFinitePoint)
        }
        for point in [Point(-0.01, 2), Point(19.01, 2), Point(2, 17.01)] {
            XCTAssertEqual(Research.relativeInverse(point: point, low: identity, high: identity,
                                                   policy: policy).refusal, .pointOutsideImage)
        }
        let source = gradient(width: 20, height: 18)
        for bounds in [Research.Bounds(minX: -1, minY: 0, maxX: 5, maxY: 5),
                       .init(minX: 5, minY: 0, maxX: 4, maxY: 5),
                       .init(minX: 0, minY: 0, maxX: 20, maxY: 5)] {
            let result = Research.render(request(source, width: 20, height: 18, policy: policy, bounds: bounds),
                                         low: identity, high: identity)
            XCTAssertEqual(result.refusal, .invalidActiveBounds)
            XCTAssertEqual(result.rgba, source)
        }
    }

    func testLooseResidualToleranceDoesNotReplaceNonzeroMotionWithIdentity() throws {
        let policy = Research.Policy(width: 40, height: 32, maximumIterations: 20,
                                     residualTolerance: 0.01)
        let high = Research.Endpoint(displacementLipschitzBound: 0) { $0 - Point(0.00001, 0) }
        let point = Point(15, 12)
        let result = Research.relativeForward(point: point, low: identity, high: high, policy: policy)
        let actual = try accepted(result)
        XCTAssertGreaterThan(actual.x, point.x)
        XCTAssertEqual(actual.y, point.y)
        XCTAssertGreaterThan(result.iterations, 0)
    }

    func testDebugAndReflectionExposeOnlyAggregateResults() throws {
        let source = gradient(width: 20, height: 18)
        let policy = Research.Policy(width: 20, height: 18, maximumIterations: 20,
                                     residualTolerance: 1e-10)
        let input = request(source, width: 20, height: 18, policy: policy)
        let pointResult = Research.relativeForward(point: Point(11.125, 9.75), low: identity,
                                                  high: identity, policy: policy)
        let raster = Research.render(input, low: identity, high: identity)
        let debug = [String(reflecting: input), String(reflecting: input.sourceBinding),
                     String(reflecting: identity), String(reflecting: policy),
                     String(reflecting: pointResult), String(reflecting: raster)].joined(separator: "\n")
        for forbidden in ["11.125", "9.75", "digest", "sourceRGBA", "backward", "activeBounds"] {
            XCTAssertFalse(debug.contains(forbidden), forbidden)
        }
        XCTAssertTrue(Mirror(reflecting: input.sourceBinding).children.isEmpty)
        XCTAssertTrue(Mirror(reflecting: identity).children.isEmpty)
        XCTAssertEqual(Set(Mirror(reflecting: input).children.compactMap(\.label)), ["byteCount"])
        XCTAssertEqual(Set(Mirror(reflecting: pointResult).children.compactMap(\.label)), ["refused", "iterations"])
        XCTAssertEqual(Set(Mirror(reflecting: raster).children.compactMap(\.label)),
                       ["status", "changedPixelCount", "sampledPixelCount"])
        XCTAssertEqual(try accepted(pointResult), Point(11.125, 9.75))
    }

    private var identity: Research.Endpoint {
        Research.Endpoint(displacementLipschitzBound: 0) { $0 }
    }

    private func request(_ source: [UInt8], width: Int, height: Int, policy: Research.Policy,
                         bounds: Research.Bounds? = nil) -> Research.Request {
        Research.Request(sourceRGBA: source, width: width, height: height,
                         sourceBinding: .bind(sourceRGBA: source, width: width, height: height),
                         policy: policy, activeBounds: bounds)
    }

    private func rigidBackward(center: Point, angle: Double, translation: Point) -> Research.Endpoint {
        Research.Endpoint(displacementLipschitzBound: 2 * abs(sin(angle / 2))) { q in
            let offset = q - center - translation
            let c = cos(-angle), s = sin(-angle)
            return center + Point(c * offset.x - s * offset.y, s * offset.x + c * offset.y)
        }
    }

    private func linearRotationBackward(center: Point, coefficient: Double) -> Research.Endpoint {
        Research.Endpoint(displacementLipschitzBound: abs(coefficient)) { q in
            let p = q - center
            return q - Point(-p.y, p.x) * coefficient
        }
    }

    private func rotated(_ p: Point, angle: Double) -> Point {
        Point(cos(angle) * p.x - sin(angle) * p.y,
              sin(angle) * p.x + cos(angle) * p.y)
    }

    private func perpendicular(_ p: Point) -> Point { Point(-p.y, p.x) }
    private func distance(_ a: Point, _ b: Point) -> Double { hypot(a.x - b.x, a.y - b.y) }

    private func accepted(_ result: Research.PointResult,
                          file: StaticString = #filePath, line: UInt = #line) throws -> Point {
        XCTAssertNil(result.refusal, file: file, line: line)
        return try XCTUnwrap(result.point, file: file, line: line)
    }

    private func assertNear(_ actual: Point, _ expected: Point, tolerance: Double,
                            file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertLessThanOrEqual(distance(actual, expected), tolerance, file: file, line: line)
    }

    private func gradient(width: Int, height: Int) -> [UInt8] {
        var rgba = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let index = (y * width + x) * 4
                // Small fixtures remain below byte saturation, preserving an
                // independent exact bilinear oracle on the three affine ramps.
                rgba[index] = UInt8(min(255, 10 + 3 * x + 2 * y))
                rgba[index + 1] = UInt8(min(255, 20 + 2 * x + y))
                rgba[index + 2] = UInt8(min(255, 30 + x + 2 * y))
            }
        }
        return rgba
    }
}
