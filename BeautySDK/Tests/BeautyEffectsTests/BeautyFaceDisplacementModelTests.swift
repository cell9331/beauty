import Foundation
import XCTest
@testable import BeautyEffects

/// Synthetic controls verify the proposed mathematics and safety qualification;
/// they do not qualify the defaults as a fit of any reference photograph.
final class BeautyFaceDisplacementModelTests: XCTestCase {
    private typealias Model = BeautyFaceDisplacementModel

    private func window(center: SIMD2<Double> = .zero,
                        radius: SIMD2<Double> = SIMD2(1, 1), angle: Double = 0,
                        innerFraction: Double = 0) -> Model.Window {
        Model.Window(center: center, axisX: SIMD2(cos(angle), sin(angle)),
                     axisY: SIMD2(-sin(angle), cos(angle)), radius: radius, innerFraction: innerFraction)
    }

    private func assertVector(_ actual: SIMD2<Double>, _ expected: SIMD2<Double>,
                              accuracy: Double = 1e-10,
                              file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual.x, expected.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.y, expected.y, accuracy: accuracy, file: file, line: line)
    }

    private func derivativeNorm(_ sample: Model.Sample) -> Double {
        let x = sample.derivativeX, y = sample.derivativeY
        let trace = x.x * x.x + x.y * x.y + y.x * y.x + y.y * y.y
        let determinant = x.x * y.y - x.y * y.x
        return sqrt((trace + sqrt(max(0, trace * trace - 4 * determinant * determinant))) * 0.5)
    }

    func testVectorFieldKeepsBothComponentsAndCompactC2Boundary() throws {
        let displacement = SIMD2(0.03, -0.02)
        let field = try XCTUnwrap(Model(modes: [.vector(weight: window(), displacement: displacement)], protections: []))
        assertVector(field.sample(at: .zero).displacement, displacement)
        for point in [SIMD2(1.0, 0), SIMD2(-1, 0), SIMD2(0, 1), SIMD2(0, -1), SIMD2(2, 2)] {
            let sample = field.sample(at: point)
            assertVector(sample.displacement, .zero, accuracy: 0)
            assertVector(sample.derivativeX, .zero, accuracy: 0)
            assertVector(sample.derivativeY, .zero, accuracy: 0)
        }
        let epsilon = 1e-5
        // At a compact edge the second derivative also converges to zero.
        let derivative = field.sample(at: SIMD2(1 - epsilon, 0)).derivativeX
        let edgeSecondDerivative = derivative / epsilon
        XCTAssertLessThan(hypot(edgeSecondDerivative.x, edgeSecondDerivative.y), 1e-4)
    }

    func testCompleteJacobianIncludesRotatedWindowsAndOverlappingProtections() throws {
        let broad = window(center: SIMD2(0.1, 0.4), radius: SIMD2(1.5, 1.8), angle: 0.23)
        let vertical = window(center: SIMD2(0, 1.2), radius: SIMD2(1.2, 1.1))
        let protections = [
            Model.Protection(window: window(center: SIMD2(-0.1, 0.4), radius: SIMD2(0.5, 0.6), angle: 0.1)),
            Model.Protection(window: window(center: SIMD2(0.2, 0.45), radius: SIMD2(0.55, 0.45), angle: -0.2),
                             innerFraction: 0.3)
        ]
        let field = try XCTUnwrap(Model(modes: [
            .vector(weight: broad, displacement: SIMD2(0.03, -0.04)),
            .smallFace(horizontal: broad, vertical: vertical, horizontalAmount: 0.04,
                       verticalAmount: 0.025, anchorY: 0.05)
        ], protections: protections))
        let epsilon = 1e-6
        for point in [SIMD2(-0.48, 0.25), SIMD2(0.38, 0.79), SIMD2(0.62, 0.4), SIMD2(-0.8, 1.2)] {
            let sample = field.sample(at: point)
            let dx = (field.sample(at: point + SIMD2(epsilon, 0)).displacement -
                      field.sample(at: point - SIMD2(epsilon, 0)).displacement) / (2 * epsilon)
            let dy = (field.sample(at: point + SIMD2(0, epsilon)).displacement -
                      field.sample(at: point - SIMD2(0, epsilon)).displacement) / (2 * epsilon)
            assertVector(sample.derivativeX, dx, accuracy: 2e-8)
            assertVector(sample.derivativeY, dy, accuracy: 2e-8)
            assertVector(sample.jacobianX, dx + SIMD2(1, 0), accuracy: 2e-8)
            assertVector(sample.jacobianY, dy + SIMD2(0, 1), accuracy: 2e-8)
        }
    }

    func testProtectionCoresAreExactAndTransitionsHaveNoDivisionByZero() throws {
        let broad = window(radius: SIMD2(2, 2))
        let protection = Model.Protection(window: window(radius: SIMD2(0.5, 0.5)))
        let field = try XCTUnwrap(Model(modes: [.vector(weight: broad, displacement: SIMD2(0.1, -0.06))],
                                       protections: [protection, protection]))
        for point in [SIMD2(0.0, 0), SIMD2(0.2, 0.2), SIMD2(-0.3, 0)] {
            let sample = field.sample(at: point)
            assertVector(sample.displacement, .zero, accuracy: 0)
            assertVector(sample.derivativeX, .zero, accuracy: 0)
            assertVector(sample.derivativeY, .zero, accuracy: 0)
            assertVector(try XCTUnwrap(field.inverse(of: point)), point, accuracy: 0)
        }
        XCTAssertGreaterThan(field.sample(at: SIMD2(0.4, 0)).displacement.x, 0)
        for boundary in [0.3, 0.5] {
            let epsilon = 1e-6
            let left = field.sample(at: SIMD2(boundary - epsilon, 0)).derivativeX
            let right = field.sample(at: SIMD2(boundary + epsilon, 0)).derivativeX
            assertVector(left, right, accuracy: 1e-7)
        }
    }

    func testSmallFaceMovesMouthAndChinWithIndependentHorizontalAndVerticalAmounts() throws {
        let horizontal = window(center: SIMD2(0, 1), radius: SIMD2(1.3, 1.5))
        let vertical = window(center: SIMD2(0, 1.25), radius: SIMD2(1.3, 1.25))
        let field = try XCTUnwrap(Model(modes: [.smallFace(horizontal: horizontal, vertical: vertical,
            horizontalAmount: 0.03, verticalAmount: 0.04, anchorY: 0)], protections: []))
        let left = field.sample(at: SIMD2(-0.6, 1)).displacement
        let right = field.sample(at: SIMD2(0.6, 1)).displacement
        XCTAssertGreaterThan(left.x, 0)
        XCTAssertLessThan(right.x, 0)
        let mouth = field.sample(at: SIMD2(0, 0.75)).displacement
        let chin = field.sample(at: SIMD2(0, 1.25)).displacement
        XCTAssertLessThan(mouth.y, 0)
        XCTAssertLessThan(chin.y, mouth.y)
        assertVector(field.sample(at: SIMD2(0, -0.01)).displacement, .zero, accuracy: 0)
        let horizontalOnly = try XCTUnwrap(Model(modes: [.smallFace(horizontal: horizontal, vertical: vertical,
            horizontalAmount: 0.03, verticalAmount: 0, anchorY: 0)], protections: []))
        XCTAssertEqual(horizontalOnly.sample(at: SIMD2(0.6, 1)).displacement.y, 0)
        let verticalOnly = try XCTUnwrap(Model(modes: [.smallFace(horizontal: horizontal, vertical: vertical,
            horizontalAmount: 0, verticalAmount: 0.04, anchorY: 0)], protections: []))
        XCTAssertEqual(verticalOnly.sample(at: SIMD2(0.6, 1)).displacement.x, 0)
    }

    func testAnalyticQualificationScalesTheWholeFieldAndInverseChecksForwardResidual() throws {
        let support = window(center: SIMD2(0.2, 0.3), radius: SIMD2(0.6, 0.8), angle: 0.5)
        let field = try XCTUnwrap(Model(modes: [.vector(weight: support, displacement: SIMD2(3, -2))],
            protections: [Model.Protection(window: window(center: SIMD2(-0.1, 0), radius: SIMD2(0.3, 0.4)))],
            maximumGradient: 0.65))
        XCTAssertGreaterThan(field.unscaledGradientBound, 1)
        XCTAssertGreaterThan(field.amplitudeScale, 0)
        XCTAssertLessThan(field.amplitudeScale, 1)
        XCTAssertLessThan(field.gradientBound, 0.65)
        for row in 0...24 {
            for column in 0...24 {
                let point = SIMD2(-0.8 + Double(column) * 0.08, -0.8 + Double(row) * 0.09)
                let sample = field.sample(at: point)
                // Grid is a counterexample check; the admitted bound itself
                // comes from polynomial extrema and interval arithmetic.
                XCTAssertLessThanOrEqual(derivativeNorm(sample), field.gradientBound + 1e-12)
                let target = point + sample.displacement
                let source = try XCTUnwrap(field.inverse(of: target, tolerance: 1e-10))
                let residual = source + field.sample(at: source).displacement - target
                XCTAssertLessThanOrEqual(hypot(residual.x, residual.y), 1e-10)
                assertVector(source, point, accuracy: 1e-9)
            }
        }
        XCTAssertNil(field.inverse(of: SIMD2(0.45, 0.5), tolerance: 1e-16, maxIterations: 1))
    }

    func testZeroStrengthIsExactIdentityAndDistantProtectionDoesNotReduceAmplitude() throws {
        let zero = try XCTUnwrap(Model(modes: [.vector(weight: window(), displacement: .zero)], protections: []))
        XCTAssertTrue(zero.isIdentity)
        XCTAssertEqual(zero.gradientBound, 0)
        XCTAssertEqual(zero.amplitudeScale, 1)
        let point = SIMD2(0.234, 0.789)
        assertVector(zero.sample(at: point).displacement, .zero, accuracy: 0)
        assertVector(try XCTUnwrap(zero.inverse(of: point)), point, accuracy: 0)
        let mode = Model.Mode.vector(weight: window(), displacement: SIMD2(0.01, 0.02))
        let plain = try XCTUnwrap(Model(modes: [mode], protections: []))
        let distant = try XCTUnwrap(Model(modes: [mode], protections: [
            Model.Protection(window: window(center: SIMD2(10, 10), radius: SIMD2(0.01, 0.01)))
        ]))
        XCTAssertEqual(plain.gradientBound, distant.gradientBound)
        assertVector(plain.sample(at: point).displacement, distant.sample(at: point).displacement, accuracy: 0)
    }

    func testEachComponentOwnsProtectionWithoutFreezingOtherDirection() throws {
        let support = window(radius: SIMD2(2, 2))
        let core = Model.Protection(window: window(radius: SIMD2(0.5, 0.5)))
        let horizontal = Model.Mode.vector(weight: support, displacement: SIMD2(0.01, 0))
        let vertical = Model.Mode.vector(weight: support, displacement: SIMD2(0, -0.02))
        let field = try XCTUnwrap(Model(components: [
            .init(modes: [horizontal], protections: [core]),
            .init(modes: [vertical], protections: [])
        ]))
        let protected = field.sample(at: .zero)
        XCTAssertEqual(protected.displacement.x, 0)
        XCTAssertEqual(protected.displacement.y, -0.02 * field.amplitudeScale, accuracy: 1e-15)
        XCTAssertLessThan(field.sample(at: SIMD2(0.4, 0)).displacement.y, 0)
        XCTAssertGreaterThan(field.sample(at: SIMD2(0.4, 0)).displacement.x, 0)
        let point = SIMD2(0.4, 0.2), epsilon = 1e-6
        let numericalDX = (field.sample(at: point + SIMD2(epsilon, 0)).displacement -
                           field.sample(at: point - SIMD2(epsilon, 0)).displacement) / (2 * epsilon)
        let numericalDY = (field.sample(at: point + SIMD2(0, epsilon)).displacement -
                           field.sample(at: point - SIMD2(0, epsilon)).displacement) / (2 * epsilon)
        assertVector(field.sample(at: point).derivativeX, numericalDX, accuracy: 1e-8)
        assertVector(field.sample(at: point).derivativeY, numericalDY, accuracy: 1e-8)
        XCTAssertLessThan(field.gradientBound, 1)
    }

    func testPlateauWindowKeepsChinTrendAndCertifiesCompleteTransitionDerivative() throws {
        let support = window(center: SIMD2(0, 1.2), radius: SIMD2(1.4, 1.2), innerFraction: 0.6)
        let field = try XCTUnwrap(Model(modes: [
            .smallFace(horizontal: support, vertical: support, horizontalAmount: 0.02,
                       verticalAmount: 0.03, anchorY: 0)
        ], protections: []))
        let mouth = field.sample(at: SIMD2(0, 0.75)).displacement
        let chin = field.sample(at: SIMD2(0, 1.5)).displacement
        XCTAssertLessThan(chin.y, mouth.y)
        XCTAssertEqual(chin.y, 2 * mouth.y, accuracy: 1e-12)
        let epsilon = 1e-6
        for point in [SIMD2(1.1, 1.2), SIMD2(0.2, 2.1), SIMD2(-1.0, 0.3)] {
            let sample = field.sample(at: point)
            let dx = (field.sample(at: point + SIMD2(epsilon, 0)).displacement -
                      field.sample(at: point - SIMD2(epsilon, 0)).displacement) / (2 * epsilon)
            let dy = (field.sample(at: point + SIMD2(0, epsilon)).displacement -
                      field.sample(at: point - SIMD2(0, epsilon)).displacement) / (2 * epsilon)
            assertVector(sample.derivativeX, dx, accuracy: 1e-8)
            assertVector(sample.derivativeY, dy, accuracy: 1e-8)
            XCTAssertLessThanOrEqual(derivativeNorm(sample), field.gradientBound)
            let target = point + sample.displacement
            let source = try XCTUnwrap(field.inverse(of: target, tolerance: 1e-10))
            assertVector(source, point, accuracy: 1e-9)
        }
        assertVector(field.sample(at: SIMD2(0, 2.4)).displacement, .zero, accuracy: 0)
        // Both plateau joins are C². Constant-vector mode isolates the window
        // from the affine small-face interior's nonzero derivative.
        let constant = try XCTUnwrap(Model(modes: [
            .vector(weight: window(innerFraction: 0.6), displacement: SIMD2(0.02, -0.01))
        ], protections: []))
        for edge in [0.6, 1.0] {
            let left = constant.sample(at: SIMD2(edge - epsilon, 0)).derivativeX
            let right = constant.sample(at: SIMD2(edge + epsilon, 0)).derivativeX
            assertVector(left, right, accuracy: 1e-9)
            XCTAssertLessThan(hypot(left.x, left.y) / epsilon, 1e-4)
        }
        XCTAssertNil(Model(modes: [.vector(weight: window(innerFraction: 1), displacement: SIMD2(0.1, 0))],
                           protections: []))
    }

    func testRejectsInvalidAxesWindowsProtectionsAndOppositeAnchorLobe() {
        let good = window()
        let invalid = [window(radius: SIMD2(0, 1)), window(radius: SIMD2(.infinity, 1)),
            Model.Window(center: .zero, axisX: SIMD2(1, 0), axisY: SIMD2(1, 0), radius: SIMD2(1, 1)),
            Model.Window(center: .zero, axisX: SIMD2(2, 0), axisY: SIMD2(0, 1), radius: SIMD2(1, 1))]
        for weight in invalid {
            XCTAssertNil(Model(modes: [.vector(weight: weight, displacement: SIMD2(0.1, 0))], protections: []))
        }
        XCTAssertNil(Model(modes: [.vector(weight: good, displacement: SIMD2(.nan, 0))], protections: []))
        XCTAssertNil(Model(modes: [], protections: [.init(window: good, innerFraction: 1)]))
        XCTAssertNil(Model(modes: [], protections: [], maximumGradient: 1))
        XCTAssertNil(Model(modes: [.smallFace(horizontal: good, vertical: good,
            horizontalAmount: 0.01, verticalAmount: 0.01, anchorY: 0)], protections: []))
        let identity = Model(modes: [], protections: [])
        XCTAssertNil(identity?.inverse(of: SIMD2(.infinity, 0)))
        XCTAssertNil(identity?.inverse(of: .zero, tolerance: 0))
    }
}
