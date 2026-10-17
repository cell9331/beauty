import Foundation
import XCTest
@testable import BeautyEffects

/// Synthetic mathematical counterexamples for the five candidate mechanisms.
/// Numerical differences and forward residuals are independent checks of the
/// analytic implementation; no reference-image fit is implied.
final class BeautyFaceFiveModelTests: XCTestCase {
    private typealias Model = BeautyFaceDisplacementModel

    private func window(_ center: SIMD2<Double>, _ radius: SIMD2<Double>,
                        angle: Double = 0, horizontalPlateau: Double = 0,
                        verticalPlateau: SIMD2<Double>? = nil) -> Model.Window {
        Model.Window(center: center, axisX: SIMD2(cos(angle), sin(angle)),
            axisY: SIMD2(-sin(angle), cos(angle)), radius: radius,
            innerFraction: horizontalPlateau, verticalPlateau: verticalPlateau)
    }

    private func norm(_ vector: SIMD2<Double>) -> Double { hypot(vector.x, vector.y) }

    private func assertVector(_ actual: SIMD2<Double>, _ expected: SIMD2<Double>,
                              accuracy: Double = 1e-9,
                              file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual.x, expected.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.y, expected.y, accuracy: accuracy, file: file, line: line)
    }

    /// Largest singular value, computed from a numerical two-column matrix.
    private func operatorNorm(_ x: SIMD2<Double>, _ y: SIMD2<Double>) -> Double {
        let aa = x.x * x.x + x.y * x.y
        let bb = y.x * y.x + y.y * y.y
        let ab = x.x * y.x + x.y * y.y
        return sqrt(max(0, (aa + bb + hypot(aa - bb, 2 * ab)) * 0.5))
    }

    private func numericalDerivative(_ field: Model, at point: SIMD2<Double>,
                                     step: Double = 1e-6) -> (SIMD2<Double>, SIMD2<Double>) {
        let x = SIMD2(step, 0.0), y = SIMD2(0.0, step)
        return ((field.sample(at: point + x).displacement - field.sample(at: point - x).displacement) / (2 * step),
                (field.sample(at: point + y).displacement - field.sample(at: point - y).displacement) / (2 * step))
    }

    private func components() -> [Model.Component] {
        let protection = Model.Protection(window: window(SIMD2(0.05, 0.80), SIMD2(0.48, 0.60), angle: 0.10),
                                          innerFraction: 0.28)
        let overlapping = Model.Protection(window: window(SIMD2(0.20, 0.95), SIMD2(0.53, 0.46), angle: -0.18),
                                           innerFraction: 0.20)
        let temple = Model.Component(modes: [
            .affine(weight: window(SIMD2(-0.85, 0.10), SIMD2(0.75, 0.80), angle: 0.23),
                    anchor: SIMD2(0, 0.65), scale: SIMD2(0.045, 0.045), translation: .zero),
            .affine(weight: window(SIMD2(0.85, 0.10), SIMD2(0.75, 0.80), angle: -0.14),
                    anchor: SIMD2(0, 0.65), scale: SIMD2(0.045, 0.045), translation: .zero)
        ], protections: [protection, overlapping])
        let cheek = Model.Component(modes: [
            .affine(weight: window(SIMD2(-0.75, 0.65), SIMD2(0.76, 0.70), angle: -0.12),
                    anchor: SIMD2(0, 0.50), scale: SIMD2(-0.050, -0.050), translation: .zero),
            .affine(weight: window(SIMD2(0.75, 0.65), SIMD2(0.76, 0.70), angle: 0.19),
                    anchor: SIMD2(0, 0.50), scale: SIMD2(-0.050, -0.050), translation: .zero)
        ], protections: [protection, overlapping])
        let length = Model.Component(modes: [
            .affine(weight: window(SIMD2(0, 1.40), SIMD2(1.25, 0.90), angle: 0.08,
                                   horizontalPlateau: 0.15, verticalPlateau: SIMD2(-0.25, 0.35)),
                    anchor: SIMD2(0.04, 1.30), scale: SIMD2(-0.006, 0), translation: SIMD2(0, -0.055))
        ], protections: [protection, overlapping])
        let taper = Model.Component(modes: [
            .vector(weight: window(SIMD2(-0.46, 1.55), SIMD2(0.75, 0.60), angle: 0.07),
                    displacement: SIMD2(0.012, -0.050)),
            .vector(weight: window(SIMD2(0.46, 1.55), SIMD2(0.75, 0.60), angle: -0.11),
                    displacement: SIMD2(-0.012, -0.050))
        ], protections: [overlapping])
        let vFace = Model.Component(modes: [
            .affine(weight: window(SIMD2(-0.62, 1.30), SIMD2(0.87, 0.85), angle: 0.12),
                    anchor: SIMD2(0, 0.65), scale: SIMD2(-0.040, -0.040), translation: .zero),
            .affine(weight: window(SIMD2(0.62, 1.30), SIMD2(0.87, 0.85), angle: -0.12),
                    anchor: SIMD2(0, 0.65), scale: SIMD2(-0.040, -0.040), translation: .zero)
        ], protections: [protection])
        return [temple, cheek, length, taper, vFace]
    }

    func testCompleteAffineJacobianMatchesDifferencesWithRotatedAndOverlappingProtection() throws {
        let field = try XCTUnwrap(Model(components: components(), refineGradientBound: true))
        var movingSamples = 0, crossDerivativeSamples = 0
        for row in 0...26 { for column in 0...28 {
            let point = SIMD2(-1.70 + Double(column) * 0.12, -0.40 + Double(row) * 0.11)
            let sample = field.sample(at: point)
            let (dx, dy) = numericalDerivative(field, at: point)
            assertVector(sample.derivativeX, dx, accuracy: 3e-8)
            assertVector(sample.derivativeY, dy, accuracy: 3e-8)
            // Forward finite differences independently include the identity.
            let epsilon = 1e-6
            let px = point + SIMD2(epsilon, 0), mx = point - SIMD2(epsilon, 0)
            let py = point + SIMD2(0, epsilon), my = point - SIMD2(0, epsilon)
            assertVector(sample.jacobianX,
                (px + field.sample(at: px).displacement - mx - field.sample(at: mx).displacement) / (2 * epsilon),
                accuracy: 3e-8)
            assertVector(sample.jacobianY,
                (py + field.sample(at: py).displacement - my - field.sample(at: my).displacement) / (2 * epsilon),
                accuracy: 3e-8)
            XCTAssertLessThanOrEqual(operatorNorm(dx, dy), field.gradientBound + 3e-8)
            if norm(sample.displacement) > 1e-5 { movingSamples += 1 }
            if abs(dx.y) + abs(dy.x) > 1e-5 { crossDerivativeSamples += 1 }
        } }
        XCTAssertGreaterThan(movingSamples, 100)
        XCTAssertGreaterThan(crossDerivativeSamples, 100)
        XCTAssertLessThan(field.gradientBound, 1)
    }

    func testAsymmetricPlateauHasFlatCoreMonotoneTransitionsAndC2Joins() throws {
        let amplitude = SIMD2(0.025, -0.045)
        let field = try XCTUnwrap(Model(modes: [
            .vector(weight: window(.zero, SIMD2(1.5, 1), horizontalPlateau: 0.20,
                                   verticalPlateau: SIMD2(-0.40, 0.25)), displacement: amplitude)
        ], protections: []))
        XCTAssertEqual(field.amplitudeScale, 1)
        for y in [-0.40, -0.30, 0, 0.10, 0.25] {
            let sample = field.sample(at: SIMD2(0, y))
            assertVector(sample.displacement, amplitude, accuracy: 0)
            assertVector(sample.derivativeY, .zero, accuracy: 0)
        }
        var previous = 0.0
        for i in 0...20 {
            let y = -1 + 0.60 * Double(i) / 20
            let fraction = field.sample(at: SIMD2(0, y)).displacement.y / amplitude.y
            XCTAssertGreaterThanOrEqual(fraction, previous - 1e-13)
            previous = fraction
        }
        previous = 1
        for i in 0...20 {
            let y = 0.25 + 0.75 * Double(i) / 20
            let fraction = field.sample(at: SIMD2(0, y)).displacement.y / amplitude.y
            XCTAssertLessThanOrEqual(fraction, previous + 1e-13)
            previous = fraction
        }
        let epsilon = 1e-5
        for boundary in [-1.0, -0.40, 0.25, 1.0] {
            let point = SIMD2(0.0, boundary), delta = SIMD2(0.0, epsilon)
            let left = field.sample(at: point - delta), center = field.sample(at: point)
            let right = field.sample(at: point + delta)
            assertVector(left.displacement, right.displacement, accuracy: 1e-10)
            assertVector(left.derivativeY, right.derivativeY, accuracy: 1e-8)
            // Independent second differences converge to zero on both sides
            // of the compact endpoints and the two plateau joins.
            let second = (left.displacement - 2 * center.displacement + right.displacement) / (epsilon * epsilon)
            XCTAssertLessThan(norm(second), 1e-3)
        }
        for y in [-1.1, -1, 1, 1.1] {
            assertVector(field.sample(at: SIMD2(0, y)).displacement, .zero, accuracy: 0)
        }
    }

    func testOffsetPlateauProtectionOverlapCannotUnderestimateGlobalDerivativeBound() throws {
        // The true maximum is at v≈0.75, far from zero. A maximumWeight
        // implementation that assumes a centered bump underestimates this
        // narrow protection's product-rule contribution by a large factor.
        let mode = Model.Mode.affine(
            weight: window(.zero, SIMD2(2, 1), verticalPlateau: SIMD2(0.65, 0.85)),
            anchor: SIMD2(-0.3, -0.2), scale: SIMD2(0.025, -0.015), translation: SIMD2(0.04, -0.20))
        let protections = [Model.Protection(
            window: window(SIMD2(0, 0.75), SIMD2(0.10, 0.025)), innerFraction: 0.20)]
        let field = try XCTUnwrap(Model(modes: [mode], protections: protections, maximumGradient: 0.40,
                                       refineGradientBound: true))
        XCTAssertLessThan(field.amplitudeScale, 1)
        XCTAssertLessThanOrEqual(field.gradientBound, 0.40)
        var observedMaximum = 0.0
        for row in 0...50 { for column in 0...30 {
            let point = SIMD2(-0.12 + 0.24 * Double(column) / 30, 0.72 + 0.06 * Double(row) / 50)
            let (dx, dy) = numericalDerivative(field, at: point, step: 2e-7)
            let measured = operatorNorm(dx, dy)
            observedMaximum = max(observedMaximum, measured)
            XCTAssertLessThanOrEqual(measured, field.gradientBound + 1e-7)
            assertVector(field.sample(at: point).derivativeX, dx, accuracy: 1e-7)
            assertVector(field.sample(at: point).derivativeY, dy, accuracy: 1e-7)
        } }
        XCTAssertGreaterThan(observedMaximum, 0.05)
        XCTAssertGreaterThan(norm(field.sample(at: SIMD2(0.2, 0.75)).displacement), 0)
        assertVector(field.sample(at: SIMD2(0, 0.75)).displacement, .zero, accuracy: 0)
    }

    func testIllegalPlateausAndNonfiniteAffineInputsRejectBeforeZeroFiltering() {
        let invalidPlateaus = [SIMD2(-1.0, 0.5), SIMD2(0.1, 1.0), SIMD2(0.4, -0.2),
                               SIMD2(Double.nan, 0.2), SIMD2(0.2, Double.infinity), SIMD2(-Double.infinity, 0.1)]
        for plateau in invalidPlateaus {
            let weight = window(.zero, SIMD2(1, 1), verticalPlateau: plateau)
            XCTAssertNil(Model(modes: [.affine(weight: weight, anchor: .zero,
                scale: SIMD2(0.01, 0.02), translation: .zero)], protections: []))
            XCTAssertNil(Model(modes: [.affine(weight: weight, anchor: .zero,
                scale: .zero, translation: .zero)], protections: []))
        }
        let good = window(.zero, SIMD2(1, 1), verticalPlateau: SIMD2(0.3, 0.3))
        XCTAssertNotNil(Model(modes: [.affine(weight: good, anchor: .zero,
            scale: SIMD2(0.01, 0.02), translation: .zero)], protections: []))
        let invalidModes: [Model.Mode] = [
            .affine(weight: good, anchor: SIMD2(.nan, 0), scale: .zero, translation: .zero),
            .affine(weight: good, anchor: SIMD2(0, .infinity), scale: SIMD2(0.01, 0.01), translation: .zero),
            .affine(weight: good, anchor: .zero, scale: SIMD2(.nan, 0), translation: .zero),
            .affine(weight: good, anchor: .zero, scale: SIMD2(0, -.infinity), translation: .zero),
            .affine(weight: good, anchor: .zero, scale: .zero, translation: SIMD2(.infinity, 0)),
            .affine(weight: good, anchor: .zero, scale: .zero, translation: SIMD2(0, .nan)),
            .affine(weight: good, anchor: SIMD2(Double.greatestFiniteMagnitude, 0),
                    scale: SIMD2(Double.greatestFiniteMagnitude, 0), translation: .zero)
        ]
        for mode in invalidModes { XCTAssertNil(Model(modes: [mode], protections: [])) }
    }

    func testEachSyntheticCandidateAndTheirCombinationInvertWithMeasuredForwardResidual() throws {
        let parts = components()
        let models = try parts.map { try XCTUnwrap(Model(components: [$0], refineGradientBound: true)) } +
            [try XCTUnwrap(Model(components: parts, refineGradientBound: true))]
        let tolerance = 1e-10
        for field in models {
            XCTAssertFalse(field.isIdentity)
            XCTAssertLessThan(field.gradientBound, 1)
            var movingSources = 0
            for row in 0...18 { for column in 0...20 {
                let source = SIMD2(-1.80 + Double(column) * 0.18, -0.50 + Double(row) * 0.17)
                let motion = field.sample(at: source).displacement
                let (dx, dy) = numericalDerivative(field, at: source)
                XCTAssertLessThanOrEqual(operatorNorm(dx, dy), field.gradientBound + 3e-8)
                let target = source + motion
                let recovered = try XCTUnwrap(field.inverse(of: target, tolerance: tolerance))
                let residual = recovered + field.sample(at: recovered).displacement - target
                XCTAssertLessThanOrEqual(norm(residual), tolerance)
                XCTAssertLessThanOrEqual(norm(recovered - source), tolerance / (1 - field.gradientBound) + 1e-14)
                // Also solve independently chosen destination points, rather
                // than checking only targets manufactured by the forward map.
                let independentTarget = source + SIMD2(0.071, -0.053)
                let independentSource = try XCTUnwrap(field.inverse(of: independentTarget, tolerance: tolerance))
                let independentResidual = independentSource + field.sample(at: independentSource).displacement - independentTarget
                XCTAssertLessThanOrEqual(norm(independentResidual), tolerance)
                if norm(motion) > 1e-5 { movingSources += 1 }
            } }
            XCTAssertGreaterThan(movingSources, 10)
        }
    }

    func testZeroAffineAndOverlappingProtectionCoresRemainExactIdentity() throws {
        let support = window(.zero, SIMD2(2, 2), verticalPlateau: SIMD2(-0.35, 0.60))
        let core = Model.Protection(window: window(.zero, SIMD2(0.50, 0.60)), innerFraction: 0.60)
        let zero = try XCTUnwrap(Model(modes: [.affine(weight: support, anchor: SIMD2(0.2, 0.3),
            scale: .zero, translation: .zero)], protections: [core, core]))
        XCTAssertTrue(zero.isIdentity)
        XCTAssertEqual(zero.gradientBound, 0)
        XCTAssertEqual(zero.maximumDisplacement, 0)
        XCTAssertEqual(zero.amplitudeScale, 1)
        let field = try XCTUnwrap(Model(modes: [.affine(weight: support, anchor: SIMD2(0.1, 0.3),
            scale: SIMD2(-0.03, 0.02), translation: SIMD2(0.015, -0.035))], protections: [core, core]))
        for point in [SIMD2(0.0, 0), SIMD2(0.20, 0.20), SIMD2(-0.25, -0.30), SIMD2(4, 4)] {
            for candidate in [zero, field] {
                let sample = candidate.sample(at: point)
                assertVector(sample.displacement, .zero, accuracy: 0)
                assertVector(sample.derivativeX, .zero, accuracy: 0)
                assertVector(sample.derivativeY, .zero, accuracy: 0)
                assertVector(try XCTUnwrap(candidate.inverse(of: point)), point, accuracy: 0)
            }
        }
        XCTAssertGreaterThan(norm(field.sample(at: SIMD2(0.60, 0.50)).displacement), 0)
    }

    func testRefinementOptInKeepsEstablishedDefaultCertificateAndAmplitudeExact() throws {
        let displacement = SIMD2(0.12, -0.08)
        let weight = window(.zero, SIMD2(0.50, 0.75))
        let mode = Model.Mode.vector(weight: weight, displacement: displacement)
        let baseline = try XCTUnwrap(Model(modes: [mode], protections: []))
        let explicitCoarse = try XCTUnwrap(Model(modes: [mode], protections: [], refineGradientBound: false))
        // This scalar vector field has the original certificate's closed-form
        // conservative bound. Preserve its exact arithmetic and safety scale;
        // a default initialization must not opt older controls into new output.
        let c = 96 / (25 * sqrt(5.0))
        let oldWindowBound = c * (1 / 0.50 + 1 / 0.75)
        let oldCertificate = hypot(displacement.x, displacement.y) * oldWindowBound * (1 + 1e-12)
        let oldScale = 0.80 * (1 - 1e-12) / oldCertificate
        XCTAssertGreaterThan(oldCertificate, 0.80)
        XCTAssertEqual(baseline.unscaledGradientBound, oldCertificate)
        XCTAssertEqual(baseline.amplitudeScale, oldScale)
        XCTAssertEqual(baseline.unscaledGradientBound, explicitCoarse.unscaledGradientBound)
        XCTAssertEqual(baseline.amplitudeScale, explicitCoarse.amplitudeScale)
        for point in [SIMD2(0.0, 0), SIMD2(0.2, -0.3), SIMD2(-0.3, 0.5)] {
            assertVector(baseline.sample(at: point).displacement,
                         explicitCoarse.sample(at: point).displacement, accuracy: 0)
        }
        assertVector(baseline.sample(at: .zero).displacement, displacement * oldScale, accuracy: 0)
        let refined = try XCTUnwrap(Model(modes: [mode], protections: [], refineGradientBound: true))
        XCTAssertEqual(refined.amplitudeScale, 1)
        XCTAssertLessThan(refined.unscaledGradientBound, baseline.unscaledGradientBound)
    }

    func testPartitionedEnclosuresKeepDisjointModesIndependentAndBoundActualGridDerivatives() throws {
        let displacement = SIMD2(0.12, -0.08)
        let left = Model.Mode.vector(weight: window(SIMD2(-2, 0), SIMD2(0.50, 0.75)), displacement: displacement)
        let right = Model.Mode.vector(weight: window(SIMD2(2, 0), SIMD2(0.50, 0.75)), displacement: -displacement)
        let single = try XCTUnwrap(Model(modes: [left], protections: [], refineGradientBound: true))
        let separated = try XCTUnwrap(Model(modes: [left, right], protections: [], refineGradientBound: true))
        let coarse = try XCTUnwrap(Model(modes: [left, right], protections: []))
        XCTAssertEqual(single.amplitudeScale, 1)
        XCTAssertEqual(separated.amplitudeScale, 1)
        XCTAssertLessThan(coarse.amplitudeScale, 1)
        assertVector(separated.sample(at: SIMD2(-2, 0)).displacement, displacement, accuracy: 0)
        assertVector(separated.sample(at: SIMD2(2, 0)).displacement, -displacement, accuracy: 0)
        assertVector(separated.sample(at: SIMD2(-1.9, 0.2)).displacement,
                     single.sample(at: SIMD2(-1.9, 0.2)).displacement, accuracy: 0)
        for row in 0...30 { for column in 0...80 {
            let point = SIMD2(-2.6 + 5.2 * Double(column) / 80, -0.8 + 1.6 * Double(row) / 30)
            let (dx, dy) = numericalDerivative(separated, at: point)
            XCTAssertLessThanOrEqual(operatorNorm(dx, dy), separated.gradientBound + 3e-8)
        } }
        // Coincident supports do add. A local certificate must not turn the
        // disjoint-support optimization into a maximum-per-mode shortcut.
        let overlapping = try XCTUnwrap(Model(modes: [left, left], protections: [], refineGradientBound: true))
        XCTAssertLessThan(overlapping.amplitudeScale, 1)
        XCTAssertLessThan(overlapping.gradientBound, 1)
    }

    func testRefinedProtectionUsesItsOwnSymmetricQuinticProfileEvenWithoutPlateauCore() throws {
        let support = window(.zero, SIMD2(1.6, 1.5), verticalPlateau: SIMD2(0.55, 0.80))
        let mode = Model.Mode.affine(weight: support, anchor: SIMD2(0.1, -0.3),
            scale: SIMD2(0.04, -0.02), translation: SIMD2(0.06, -0.20))
        // The window's own asymmetric profile is intentionally different from
        // the protection's symmetric quintic profile. f=0 is still quintic,
        // rather than the default window's polynomial bump.
        let protection = Model.Protection(window: window(SIMD2(0, 1.0), SIMD2(0.30, 0.12),
            verticalPlateau: SIMD2(-0.2, 0.7)), innerFraction: 0)
        let field = try XCTUnwrap(Model(modes: [mode], protections: [protection], refineGradientBound: true))
        for row in 0...36 { for column in 0...36 {
            let point = SIMD2(-0.35 + 0.70 * Double(column) / 36, 0.85 + 0.30 * Double(row) / 36)
            let (dx, dy) = numericalDerivative(field, at: point)
            XCTAssertLessThanOrEqual(operatorNorm(dx, dy), field.gradientBound + 1e-7)
            assertVector(field.sample(at: point).derivativeX, dx, accuracy: 1e-7)
            assertVector(field.sample(at: point).derivativeY, dy, accuracy: 1e-7)
        } }
        assertVector(field.sample(at: SIMD2(0, 1.0)).displacement, .zero, accuracy: 0)
        XCTAssertGreaterThan(norm(field.sample(at: SIMD2(0.25, 1.0)).displacement), 0)
    }
}
