import Foundation
import XCTest
@testable import BeautyEffects

/// These tests use known geometry rather than inferred hair pixels. They check
/// the proposed mechanisms, not whether uncalibrated defaults match a photo.
final class BeautyEyebrowDisplacementModelTests: XCTestCase {
    private typealias Model = BeautyEyebrowDisplacementModel
    private let length = 100.0

    private func profile(_ samples: [SIMD2<Double>]) throws -> Model.Profile {
        try XCTUnwrap(Model.Profile(samples: samples))
    }

    private func geometry(angle: Double = 0, isLeft: Bool = false,
                          origin: SIMD2<Double> = .zero, scale: Double = 1,
                          ridge: Model.Profile? = nil) throws -> Model.Geometry {
        Model.Geometry(origin: origin,
            horizontal: SIMD2(cos(angle), sin(angle)),
            vertical: SIMD2(-sin(angle), cos(angle)), isLeft: isLeft,
            length: length * scale,
            ridge: try ridge ?? profile([SIMD2(0, 0), SIMD2(length * scale, 0)]),
            upper: try profile([SIMD2(0, 5 * scale), SIMD2(length * scale, 5 * scale)]),
            lower: try profile([SIMD2(0, 5 * scale), SIMD2(length * scale, 5 * scale)]))
    }

    private func supports(scale: Double = 1) -> [Model.Support] {
        Array(repeating: Model.Support(upper: 40 * scale, lower: 20 * scale,
                                      head: 30 * scale, tail: 30 * scale), count: 7)
    }

    private func model(index: Int, value: Double = 1,
                       calibration: Model.Calibration = .init(),
                       geometry: Model.Geometry? = nil,
                       supports: [Model.Support]? = nil,
                       scale: Double = 1) throws -> Model {
        var values = [Double](repeating: 0, count: 7)
        values[index] = value
        return try model(values: values, calibration: calibration,
                         geometry: geometry, supports: supports, scale: scale)
    }

    private func model(values: [Double], calibration: Model.Calibration = .init(),
                       geometry: Model.Geometry? = nil,
                       supports: [Model.Support]? = nil,
                       scale: Double = 1) throws -> Model {
        try XCTUnwrap(Model(geometry: try geometry ?? self.geometry(scale: scale),
            values: values, supports: supports ?? self.supports(scale: scale),
            calibration: calibration, ownerBoundary: -100 * scale,
            ownerTransition: 10 * scale))
    }

    private func magnitude(_ vector: SIMD2<Double>) -> Double {
        hypot(vector.x, vector.y)
    }

    private func numericalJacobianNorm(_ field: Model, at point: SIMD2<Double>) -> Double {
        let epsilon = 1e-4
        let x = (field.displacement(at: point + SIMD2(epsilon, 0)) -
                 field.displacement(at: point - SIMD2(epsilon, 0))) / (2 * epsilon)
        let y = (field.displacement(at: point + SIMD2(0, epsilon)) -
                 field.displacement(at: point - SIMD2(0, epsilon))) / (2 * epsilon)
        let trace = x.x * x.x + x.y * x.y + y.x * y.x + y.y * y.y
        let determinant = x.x * y.y - x.y * y.x
        let discriminant = max(0, trace * trace - 4 * determinant * determinant)
        return sqrt((trace + sqrt(discriminant)) / 2)
    }

    private func numericalWeightedJacobianNorm(_ field: Model, at point: SIMD2<Double>) -> Double {
        // Independently form Q from the actual horizontal axis, differentiate
        // in those ORTHONORMAL directions, and explicitly multiply W*J/W.
        // This oracle does not reuse the production rank-one derivative bound.
        let horizontal = field.geometry.horizontal
        let qx = horizontal / magnitude(horizontal), qy = SIMD2(-qx.y, qx.x)
        let epsilon = 1e-4
        let dx = (field.displacement(at: point + qx * epsilon) -
                  field.displacement(at: point - qx * epsilon)) / (2 * epsilon)
        let dy = (field.displacement(at: point + qy * epsilon) -
                  field.displacement(at: point - qy * epsilon)) / (2 * epsilon)
        let a = dx.x * qx.x + dx.y * qx.y
        let b = (dy.x * qx.x + dy.y * qx.y) / 2
        let c = 2 * (dx.x * qy.x + dx.y * qy.y)
        let d = dy.x * qy.x + dy.y * qy.y
        let trace = a * a + b * b + c * c + d * d
        let determinant = a * d - b * c
        let discriminant = max(0, trace * trace - 4 * determinant * determinant)
        return sqrt((trace + sqrt(discriminant)) / 2)
    }

    private func assertVector(_ actual: SIMD2<Double>, _ expected: SIMD2<Double>,
                              accuracy: Double = 1e-10,
                              file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual.x, expected.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.y, expected.y, accuracy: accuracy, file: file, line: line)
    }

    func testVerticalFieldHasFullCoreAndContinuousAsymmetricSkinSupport() throws {
        var calibration = Model.Calibration()
        calibration.verticalPositiveFraction = 0.04
        let field = try model(index: 0, calibration: calibration)
        let core = field.displacement(at: SIMD2(50, 0))
        XCTAssertGreaterThan(core.y, 0, "the SDK raw positive direction remains downward")
        for y in [-5.0, -2.0, 3.0, 5.0] {
            assertVector(field.displacement(at: SIMD2(50, y)), core)
        }

        let upperSkin = field.displacement(at: SIMD2(50, -15))
        let lowerSkin = field.displacement(at: SIMD2(50, 15))
        XCTAssertGreaterThan(upperSkin.y, lowerSkin.y, "the upper transition is wider")
        XCTAssertGreaterThan(lowerSkin.y, 0, "surrounding skin participates in the warp")
        XCTAssertLessThan(upperSkin.y, core.y)
        XCTAssertGreaterThan(field.displacement(at: SIMD2(-10, 0)).y, 0)

        for point in [SIMD2(-30.0, 0), SIMD2(-31, 0), SIMD2(130, 0),
                      SIMD2(131, 0), SIMD2(50, -45), SIMD2(50, -46),
                      SIMD2(50, 25), SIMD2(50, 26)] {
            assertVector(field.displacement(at: point), .zero, accuracy: 0)
        }

        // Compare one-sided derivatives at the core and exterior boundaries.
        let epsilon = 1e-4
        for y in [-45.0, -5.0, 5.0, 25.0] {
            let point = SIMD2(50.0, y)
            let left = (field.displacement(at: point) -
                        field.displacement(at: point - SIMD2(0, epsilon))) / epsilon
            let right = (field.displacement(at: point + SIMD2(0, epsilon)) -
                         field.displacement(at: point)) / epsilon
            assertVector(left, right, accuracy: 1e-4)
            XCTAssertLessThan(magnitude(left), 1e-4)
        }
        for r in [-30.0, 0.0, 100.0, 130.0] {
            let point = SIMD2(r, 0.0)
            let left = (field.displacement(at: point) -
                        field.displacement(at: point - SIMD2(epsilon, 0))) / epsilon
            let right = (field.displacement(at: point + SIMD2(epsilon, 0)) -
                         field.displacement(at: point)) / epsilon
            assertVector(left, right, accuracy: 1e-4)
            XCTAssertLessThan(magnitude(left), 1e-4)
        }
    }

    func testEachAdjustmentUsesItsOwnSkinTransition() throws {
        var independentSupports = supports()
        independentSupports[6] = Model.Support(upper: 10, lower: 10, head: 30, tail: 30)
        let vertical = try model(index: 0, supports: independentSupports)
        let peak = try model(index: 6, supports: independentSupports)
        let skin = SIMD2(68.0, -20)
        XCTAssertGreaterThan(magnitude(vertical.displacement(at: skin)), 0)
        assertVector(peak.displacement(at: skin), .zero, accuracy: 0)
    }

    func testPeakIsAConfigurableLocalBumpWithFiniteOuterStop() throws {
        var calibration = Model.Calibration()
        calibration.peakStartT = 0.10
        calibration.peakPositionT = 0.55
        calibration.peakEndT = 1.10
        calibration.peakPositiveFraction = 0.06
        calibration.peakNegativeFraction = 0.02
        let peak = try model(index: 6, calibration: calibration)
        let summit = peak.displacement(at: SIMD2(55, 0))
        XCTAssertLessThan(summit.y, 0)
        XCTAssertEqual(summit.x, 0)
        for r in [30.0, 80.0, 100.0] {
            let value = peak.displacement(at: SIMD2(r, 0))
            XCTAssertGreaterThan(value.y, summit.y)
            XCTAssertLessThan(value.y, 0)
        }
        for r in [0.0, 10.0, 110.0, 115.0] {
            assertVector(peak.displacement(at: SIMD2(r, 0)), .zero, accuracy: 1e-12)
        }

        calibration.peakPositionT = 0.80
        let moved = try model(index: 6, calibration: calibration)
        assertVector(moved.displacement(at: SIMD2(80, 0)), summit)
        XCTAssertGreaterThan(moved.displacement(at: SIMD2(55, 0)).y, summit.y)
        let lowered = try model(index: 6, value: -1, calibration: calibration)
        XCTAssertGreaterThan(lowered.displacement(at: SIMD2(80, 0)).y, 0)
    }

    func testThicknessAnchorsCurvedRidgeAndMovesAlongFaceVertical() throws {
        let ridge = try profile([SIMD2(0, 0), SIMD2(45, -12), SIMD2(100, -3)])
        let geometry = try geometry(ridge: ridge)
        var calibration = Model.Calibration()
        calibration.thicknessUpperPositive = 0.25
        calibration.thicknessLowerPositive = 0.40
        calibration.thicknessBlendWidthFraction = 0.005
        for sign in [-1.0, 1.0] {
            let field = try model(index: 1, value: sign, calibration: calibration, geometry: geometry)
            for r in [20.0, 45.0, 80.0] {
                let center = SIMD2(r, ridge.value(at: r))
                assertVector(field.displacement(at: center), .zero, accuracy: 0)
                let upper = field.displacement(at: center - SIMD2(0, 3))
                let lower = field.displacement(at: center + SIMD2(0, 3))
                XCTAssertEqual(upper.x, 0)
                XCTAssertEqual(lower.x, 0)
                XCTAssertLessThan(upper.y * sign, 0)
                XCTAssertGreaterThan(lower.y * sign, 0)
            }
        }
    }

    func testLengthKeepsInnerAnchorAndReachesAHorizontalOuterPlateau() throws {
        var calibration = Model.Calibration()
        calibration.lengthAnchorT = 0.20
        calibration.lengthPlateauT = 0.65
        for sign in [-1.0, 1.0] {
            let field = try model(index: 2, value: sign, calibration: calibration)
            for r in [-10.0, 0.0, 10.0, 20.0] {
                assertVector(field.displacement(at: SIMD2(r, 0)), .zero, accuracy: 0)
            }
            let middle = field.displacement(at: SIMD2(45, 0))
            let outer = field.displacement(at: SIMD2(80, 0))
            XCTAssertGreaterThan(middle.x * sign, 0)
            XCTAssertGreaterThan(outer.x * sign, middle.x * sign)
            XCTAssertEqual(outer.y, 0)
            assertVector(outer, field.displacement(at: SIMD2(100, 0)))
        }
    }

    func testWholeSpacingRetainsTailMotionWhileHeadSpacingStopsBeforeTail() throws {
        var calibration = Model.Calibration()
        calibration.headPlateauEndT = 0.10
        calibration.headZeroT = 0.70
        for isLeft in [false, true] {
            let geometry = try geometry(isLeft: isLeft)
            let direction = isLeft ? -1.0 : 1.0
            func point(_ r: Double) -> SIMD2<Double> { SIMD2(r * direction, 0) }
            for sign in [-1.0, 1.0] {
                let spacing = try model(index: 3, value: sign, calibration: calibration, geometry: geometry)
                let head = spacing.displacement(at: point(0))
                let tail = spacing.displacement(at: point(100))
                XCTAssertGreaterThan(head.x * sign * direction, tail.x * sign * direction)
                XCTAssertGreaterThan(tail.x * sign * direction, 0)
                XCTAssertEqual(head.y, 0)
                XCTAssertEqual(tail.y, 0)

                let headSpacing = try model(index: 4, value: sign, calibration: calibration, geometry: geometry)
                let inner = headSpacing.displacement(at: point(0))
                XCTAssertGreaterThan(inner.x * sign * direction, 0)
                assertVector(headSpacing.displacement(at: point(5)), inner)
                for r in [70.0, 85.0, 100.0, 115.0] {
                    assertVector(headSpacing.displacement(at: point(r)), .zero, accuracy: 0)
                }
            }
        }
    }

    func testTiltAndStrengthLimitingPreserveFiniteRotationInsideCore() throws {
        var calibration = Model.Calibration()
        calibration.tiltPositiveRadians = 0.12
        calibration.tiltNegativeRadians = 0.09
        calibration.tiltPivotT = 0.65
        let a = SIMD2(30.0, -3), b = SIMD2(85.0, 4)
        let field = try model(index: 5, calibration: calibration)
        let limited = try XCTUnwrap(field.scaled(by: 0.5))
        for current in [field, limited] {
            let transformedA = a + current.displacement(at: a)
            let transformedB = b + current.displacement(at: b)
            XCTAssertEqual(magnitude(transformedB - transformedA), magnitude(b - a), accuracy: 1e-10)
            XCTAssertLessThan(current.displacement(at: SIMD2(90, 0)).y, 0,
                              "SDK raw positive tilt raises the tail")
        }

        // Independently apply a half angle about the specified pivot. Simply
        // halving R(theta)-I would shorten the distance between these points.
        let relative = a - SIMD2(65, 0)
        let expected = SIMD2(relative.x * cos(0.06) + relative.y * sin(0.06),
                             -relative.x * sin(0.06) + relative.y * cos(0.06)) - relative
        assertVector(limited.displacement(at: a), expected)
        XCTAssertGreaterThan(magnitude(limited.displacement(at: a) - field.displacement(at: a) * 0.5), 0.01)
        let zero = try XCTUnwrap(field.scaled(by: 0))
        assertVector(zero.displacement(at: a), .zero, accuracy: 0)
        XCTAssertEqual(zero.maximumGradient, 0)
        XCTAssertEqual(zero.maximumDisplacement, 0)
    }

    func testProfileIsC1AndExtrapolatesWithEndpointSlope() throws {
        let curve = try profile([SIMD2(0, 0), SIMD2(30, -8), SIMD2(60, -10), SIMD2(100, 0)])
        let epsilon = 1e-5
        for r in [0.0, 30.0, 60.0, 100.0] {
            XCTAssertEqual(curve.derivative(at: r - epsilon), curve.derivative(at: r + epsilon), accuracy: 1e-5)
            let numerical = (curve.value(at: r + epsilon) - curve.value(at: r - epsilon)) / (2 * epsilon)
            XCTAssertEqual(numerical, curve.derivative(at: r), accuracy: 1e-5)
        }
        XCTAssertEqual(curve.value(at: -15), curve.value(at: 0) - 15 * curve.derivative(at: 0), accuracy: 1e-10)
        XCTAssertEqual(curve.value(at: 115), curve.value(at: 100) + 15 * curve.derivative(at: 100), accuracy: 1e-10)
        XCTAssertEqual(curve.derivative(at: -15), curve.derivative(at: 0), accuracy: 1e-10)
        XCTAssertEqual(curve.derivative(at: 115), curve.derivative(at: 100), accuracy: 1e-10)
        let continuedBounds = curve.bounds(in: -20...120)
        for r in stride(from: -20.0, through: 120, by: 2) {
            XCTAssertLessThanOrEqual(abs(curve.derivative(at: r)), curve.maximumAbsoluteDerivative + 1e-10)
            XCTAssertGreaterThanOrEqual(curve.value(at: r), continuedBounds.minimum)
            XCTAssertLessThanOrEqual(curve.value(at: r), continuedBounds.maximum)
            if (0...100).contains(r) {
                XCTAssertGreaterThanOrEqual(curve.value(at: r), curve.minimumValue)
                XCTAssertLessThanOrEqual(curve.value(at: r), curve.maximumValue)
            }
        }
    }

    func testAnalyticBoundsCoverIndependentFiniteDifferenceLowerBounds() throws {
        let ridge = try profile([SIMD2(0, 0), SIMD2(40, -9), SIMD2(100, -2)])
        let field = try model(values: [-0.7, 0.8, -0.6, 0.6, -0.5, 0.8, 0.7],
                              geometry: geometry(ridge: ridge))
        XCTAssertTrue(field.maximumGradient.isFinite)
        XCTAssertGreaterThan(field.maximumGradient, 0)
        XCTAssertTrue(field.maximumDisplacement.isFinite)
        let epsilon = 1e-4
        let directions = [SIMD2(1.0, 0), SIMD2(0, 1), SIMD2(sqrt(0.5), sqrt(0.5))]
        // Samples provide independent lower bounds only. The field's global
        // safety upper bound must still be derived analytically by production.
        for r in stride(from: -35.0, through: 135, by: 10) {
            for y in stride(from: -55.0, through: 30, by: 5) {
                let point = SIMD2(r, y)
                XCTAssertLessThanOrEqual(magnitude(field.displacement(at: point)), field.maximumDisplacement + 1e-8)
                for direction in directions {
                    let derivative = (field.displacement(at: point + direction * epsilon) -
                                      field.displacement(at: point - direction * epsilon)) / (2 * epsilon)
                    XCTAssertLessThanOrEqual(magnitude(derivative), field.maximumGradient + 1e-6)
                }
            }
        }
    }

    func testAllFieldsFollowFaceRotationReflectionAndScale() throws {
        let angle = 0.38, scale = 2.4
        let origin = SIMD2(140.0, 90)
        let rotatedGeometry = try geometry(angle: angle, origin: origin)
        let mirroredGeometry = try geometry(isLeft: true)
        func rotate(_ vector: SIMD2<Double>) -> SIMD2<Double> {
            SIMD2(vector.x * cos(angle) - vector.y * sin(angle),
                  vector.x * sin(angle) + vector.y * cos(angle))
        }
        for index in 0..<7 {
            let field = try model(index: index, value: 0.6)
            let rotated = try model(index: index, value: 0.6, geometry: rotatedGeometry)
            let mirrored = try model(index: index, value: 0.6, geometry: mirroredGeometry)
            let enlarged = try model(index: index, value: 0.6, scale: scale)
            for point in [SIMD2(35.0, -2), SIMD2(75, 4), SIMD2(85, -17)] {
                let original = field.displacement(at: point)
                assertVector(rotated.displacement(at: origin + rotate(point)), rotate(original), accuracy: 1e-9)
                assertVector(mirrored.displacement(at: SIMD2(-point.x, point.y)),
                             SIMD2(-original.x, original.y), accuracy: 1e-9)
                assertVector(enlarged.displacement(at: point * scale), original * scale, accuracy: 1e-9)
            }
        }
    }

    func testInactiveEndsDoNotConsumeAnchoredOrLocalControlBudgets() throws {
        for index in [2, 6] {
            let baseline = try model(index: index)
            var narrow = supports()
            narrow[index] = Model.Support(upper: 40, lower: 20, head: 0.01, tail: 30)
            let limitedHead = try model(index: index, supports: narrow)
            XCTAssertEqual(limitedHead.maximumGradient, baseline.maximumGradient, accuracy: 1e-10,
                           "the length anchor and default local bump vanish throughout the head transition")
        }
        let head = try model(index: 4)
        var narrow = supports()
        narrow[4] = Model.Support(upper: 40, lower: 20, head: 30, tail: 0.01)
        let limitedTail = try model(index: 4, supports: narrow)
        XCTAssertEqual(limitedTail.maximumGradient, head.maximumGradient, accuracy: 1e-10,
                       "head spacing has a stationary outer segment before the tail transition")

        var verticalSupports = supports()
        verticalSupports[0] = Model.Support(upper: 40, lower: 20, head: 0.01, tail: 30)
        XCTAssertGreaterThan(try model(index: 0, supports: verticalSupports).maximumGradient,
                             try model(index: 0).maximumGradient * 100,
                             "a moving core still pays for its genuinely narrow head transition")
    }

    func testScalarPartitionBoundsImproveOnUnrelatedGlobalTriangleMaxima() throws {
        let calibration = Model.Calibration()
        let amplitudes = [calibration.verticalPositiveFraction, calibration.lengthPositiveFraction,
                          calibration.spacingPositiveFraction, calibration.headSpacingPositiveFraction,
                          calibration.peakPositiveFraction]
        let shapeDerivatives = [0.0, 1.5 / 45, 0.7 * 1.5 / 100,
                                1.5 / 67, 1.5 / 40]
        for (offset, index) in [0, 2, 3, 4, 6].enumerated() {
            let field = try model(index: index)
            let oldTriangleBound = amplitudes[offset] * length * (shapeDerivatives[offset] + 1.5 / 20 + 1.5 / 30)
            XCTAssertLessThan(field.maximumGradient, oldTriangleBound * 0.85,
                             "unrelated maximum derivatives should not unnecessarily attenuate control \(index)")
        }
    }

    func testPartitionBoundsCoverCustomShapeAndCurvedCoreJacobianLowerBounds() throws {
        let ridge = try profile([SIMD2(0, 0), SIMD2(35, -12), SIMD2(70, -5), SIMD2(100, -2)])
        let upper = try XCTUnwrap(Model.Profile(samples: [SIMD2(0, 4), SIMD2(50, 8), SIMD2(100, 6)],
                                                endpointDerivatives: .zero))
        let lower = try XCTUnwrap(Model.Profile(samples: [SIMD2(0, 6), SIMD2(45, 4), SIMD2(100, 7)],
                                                endpointDerivatives: .zero))
        let geometry = Model.Geometry(origin: .zero, horizontal: SIMD2(1, 0), vertical: SIMD2(0, 1),
                                      isLeft: false, length: length, ridge: ridge, upper: upper, lower: lower)
        var calibration = Model.Calibration()
        calibration.lengthTailDecayStartT = 0.82
        calibration.lengthTailZeroT = 1.16
        calibration.spacingTailRatio = 0.05
        calibration.headPlateauEndT = 0.35
        calibration.headZeroT = 0.82
        calibration.peakStartT = -0.15
        calibration.peakPositionT = 0.72
        calibration.peakEndT = 1.20
        calibration.thicknessLowerPositive = 0.37
        calibration.thicknessUpperNegative = 0.31
        for index in 0..<7 {
            for sign in [-1.0, 1.0] {
                var values = [Double](repeating: 0, count: 7)
                values[index] = sign
                let field = try XCTUnwrap(Model(geometry: geometry, values: values, supports: supports(),
                    calibration: calibration, ownerBoundary: -22, ownerTransition: 17))
                // These finite differences are independent LOWER-bound oracles.
                // Production still proves its upper bound over whole intervals.
                for r in stride(from: -30.0, through: 130, by: 8) {
                    for y in stride(from: -65.0, through: 50, by: 6) {
                        let norm = numericalJacobianNorm(field, at: SIMD2(r, y))
                        XCTAssertLessThanOrEqual(norm, field.maximumGradient + 1e-6,
                                                 "control \(index), sign \(sign), point \(r),\(y)")
                    }
                }
                let scaled = try XCTUnwrap(field.scaled(by: 0.37))
                XCTAssertLessThanOrEqual(scaled.maximumGradient, field.maximumGradient * 0.37 + 1e-12)
            }
        }
    }

    func testTiltUsesTransitionRadiiAndKeepsALinearAdmissionBound() throws {
        let field = try model(index: 5)
        let radius = hypot(95.0, 45)
        let oldGlobalBound = (Double.pi / 40) * (1 + radius * (1.5 / 20 + 1.5 / 30))
        XCTAssertLessThan(field.maximumGradient, oldGlobalBound * 0.8)
        for scale in [0.1, 0.37, 0.8] {
            let scaled = try XCTUnwrap(field.scaled(by: scale))
            XCTAssertLessThanOrEqual(scaled.maximumGradient, field.maximumGradient * scale + 1e-12)
        }
    }

    func testWeightedSpacingBoundsCoverRotatedMirroredAndApproximateAxes() throws {
        let ridge = try profile([SIMD2(0, 0), SIMD2(40, -9), SIMD2(100, -2)])
        for isLeft in [false, true] {
            for approximateAxes in [false, true] {
                let original = try geometry(angle: 0.47, isLeft: isLeft, origin: SIMD2(80, 60), ridge: ridge)
                let horizontal = original.horizontal * (approximateAxes ? 1 + 3e-7 : 1)
                let vertical = original.vertical + original.horizontal * (approximateAxes ? 4e-7 : 0)
                let geometry = Model.Geometry(origin: original.origin, horizontal: horizontal, vertical: vertical,
                    isLeft: isLeft, length: original.length, ridge: ridge, upper: original.upper, lower: original.lower)
                for index in [3, 4] {
                    for sign in [-1.0, 1.0] {
                        let field = try model(index: index, value: sign, geometry: geometry)
                        for r in stride(from: -30.0, through: 130, by: 10) {
                            for y in stride(from: -55.0, through: 35, by: 6) {
                                let point = geometry.origin + geometry.outward * r + geometry.vertical * y
                                let lowerBound = numericalWeightedJacobianNorm(field, at: point)
                                XCTAssertLessThanOrEqual(lowerBound, field.maximumWeightedGradient + 2e-6,
                                    "weighted control \(index), left=\(isLeft), axis error=\(approximateAxes)")
                            }
                        }
                    }
                }
            }
        }
    }

    func testCombinationCertificateSelectsOneCommonNormInsteadOfMixingComponentNorms() throws {
        let field = try model(values: [0.7, -0.4, 0.6, 1, -0.8, 0.5, -0.7])
        XCTAssertEqual(field.maximumGradient, field.componentMaximumGradients.reduce(0, +))
        XCTAssertEqual(field.maximumWeightedGradient, field.componentWeightedMaximumGradients.reduce(0, +))
        XCTAssertEqual(field.inverseContraction, min(field.maximumGradient, field.maximumWeightedGradient))
        let mixedNormSum = zip(field.componentMaximumGradients, field.componentWeightedMaximumGradients)
            .map { min($0, $1) }.reduce(0, +)
        XCTAssertGreaterThan(field.inverseContraction, mixedNormSum,
                             "adding bounds from different norms is not a global contraction certificate")
        for r in stride(from: -30.0, through: 130, by: 10) {
            for y in stride(from: -50.0, through: 30, by: 5) {
                let point = SIMD2(r, y)
                let lowerBound = field.maximumGradient <= field.maximumWeightedGradient
                    ? numericalJacobianNorm(field, at: point) : numericalWeightedJacobianNorm(field, at: point)
                XCTAssertLessThanOrEqual(lowerBound, field.inverseContraction + 1e-6)
            }
        }
    }

    func testWeightedBoundsScaleLinearlyAndOtherControlsKeepEuclideanCertificate() throws {
        for index in 0..<7 {
            let field = try model(index: index, value: -0.8)
            XCTAssertEqual(field.componentWeightedMaximumGradients.count, 7)
            for other in 0..<7 where other != index {
                XCTAssertEqual(field.componentWeightedMaximumGradients[other], 0)
            }
            if index == 3 || index == 4 {
                XCTAssertLessThan(field.maximumWeightedGradient, field.maximumGradient)
            } else {
                XCTAssertEqual(field.maximumWeightedGradient, 2 * field.maximumGradient)
                XCTAssertEqual(field.inverseContraction, field.maximumGradient)
            }
            for scale in [0.0, 0.17, 0.63, 1.0] {
                let scaled = try XCTUnwrap(field.scaled(by: scale))
                XCTAssertEqual(scaled.maximumWeightedGradient, field.maximumWeightedGradient * scale, accuracy: 1e-11)
                XCTAssertEqual(scaled.inverseContraction, field.inverseContraction * scale, accuracy: 1e-11)
                for component in 0..<7 {
                    XCTAssertEqual(scaled.componentWeightedMaximumGradients[component],
                                   field.componentWeightedMaximumGradients[component] * scale, accuracy: 1e-11)
                }
            }
        }
    }

    func testNearbyCustomBreakpointsKeepAnalyticBoundsWithoutMergingIntervals() throws {
        let length = 88.79591691565949
        var calibration = Model.Calibration()
        calibration.lengthTailDecayStartT = 1.0.nextDown
        calibration.lengthTailZeroT = 1.16
        calibration.headPlateauEndT = Double.leastNonzeroMagnitude
        calibration.headZeroT = 0.77
        calibration.peakStartT = 0.23
        calibration.peakPositionT = 0.71
        calibration.peakEndT = 1.0.nextUp
        let breaks = [0.0, length, calibration.lengthAnchorT * length, calibration.lengthPlateauT * length,
            calibration.lengthTailDecayStartT! * length, calibration.lengthTailZeroT! * length,
            calibration.headPlateauEndT * length, calibration.headZeroT * length,
            calibration.peakStartT * length, calibration.peakPositionT * length, calibration.peakEndT * length]
        // These constant-ridge knots alter only the partition, not the field.
        // Keep every adjacent representable boundary instead of merging them.
        let knots = Array(Set(breaks.flatMap { [$0.nextDown, $0, $0.nextUp] })).sorted()
        let ridge = try profile(knots.map { SIMD2($0, 0) })
        let core = try profile([SIMD2(0, 5), SIMD2(length, 5)])
        let geometry = Model.Geometry(origin: .zero, horizontal: SIMD2(1, 0), vertical: SIMD2(0, 1),
                                      isLeft: false, length: length, ridge: ridge, upper: core, lower: core)
        let plain = Model.Geometry(origin: .zero, horizontal: SIMD2(1, 0), vertical: SIMD2(0, 1),
            isLeft: false, length: length, ridge: try profile([SIMD2(0, 0), SIMD2(length, 0)]), upper: core, lower: core)
        for index in [2, 3, 4, 6] {
            for sign in [-1.0, 1.0] {
                let field = try model(index: index, value: sign, calibration: calibration, geometry: geometry)
                let baseline = try model(index: index, value: sign, calibration: calibration, geometry: plain)
                XCTAssertTrue(field.maximumGradient.isFinite)
                XCTAssertLessThanOrEqual(field.maximumGradient, baseline.maximumGradient * 1.08 + 1e-10,
                                         "an unrelated ULP-sized partition must not consume the effect budget")
                XCTAssertLessThanOrEqual(field.inverseContraction, baseline.inverseContraction * 1.08 + 1e-10)
                for r in breaks + [10.0, 35.0, 55.0, 75.0, 100.0] {
                    for y in [-15.0, 0.0, 15.0] {
                        let point = SIMD2(r, y)
                        assertVector(field.displacement(at: point), baseline.displacement(at: point))
                        XCTAssertLessThanOrEqual(numericalJacobianNorm(field, at: point), field.maximumGradient + 2e-6)
                        XCTAssertLessThanOrEqual(numericalWeightedJacobianNorm(field, at: point),
                                                 field.maximumWeightedGradient + 2e-6)
                    }
                }
                let scaled = try XCTUnwrap(field.scaled(by: 0.31))
                XCTAssertEqual(scaled.inverseContraction, field.inverseContraction * 0.31, accuracy: 1e-10)
            }
        }
    }

}
