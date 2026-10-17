import Foundation
import XCTest
@testable import BeautyEffects

/// Synthetic source geometry only. These verify field mathematics and the
/// stated design response, rather than claiming reference-image qualification.
final class BeautyMouthReferenceModelTests: XCTestCase {
    private typealias Model = BeautyMouthReferenceModel
    private typealias Point = SIMD2<Double>

    private func configuration() throws -> Model.Configuration {
        let seam = try XCTUnwrap(Model.Seam(knots: [Point(-0.5, 0), Point(-0.25, -0.018),
            Point(0, 0.012), Point(0.25, -0.014), Point(0.5, 0)]))
        let whole = Model.Envelope(innerMin: Point(-0.60, -0.19), innerMax: Point(0.60, 0.20),
                                   outerMin: Point(-1.15, -0.65), outerMax: Point(1.15, 0.70))
        let tissue = Model.Envelope(innerMin: Point(-0.48, -0.12), innerMax: Point(0.48, 0),
                                    outerMin: Point(-0.88, -0.40), outerMax: Point(0.88, 0.24))
        let fullness = Model.Envelope(innerMin: Point(-0.40, -0.14), innerMax: Point(0.40, 0.15),
                                      outerMin: Point(-0.90, -0.50), outerMax: Point(0.90, 0.55))
        let profile = try XCTUnwrap(Model.Profile(knots: [Point(-0.60, 0), Point(-0.22, -0.004),
            Point(0, 0.008), Point(0.22, -0.005), Point(0.60, 0)]))
        return Model.Configuration(seam: seam,
            size: .init(rates: Point(0.065, 0.040), envelope: whole, center: Point(0, 0.03)),
            width: .init(rates: Point(0.083, 0), envelope: whole),
            vertical: .init(vector: Point(-0.0025, -0.036), envelope: whole),
            tilt: .init(angle: 0.137, envelope: whole, center: Point(0, 0.03)),
            horizontal: .init(vector: Point(0.096, 0.00049), envelope: whole),
            mShape: .init(profile: profile, envelope: tissue,
                lowerCenter: .init(center: Point(0, 0.13), radius: Point(0.18, 0.075), vector: Point(0, -0.010))),
            fullness: .init(upperRate: 0.30, lowerRate: 0.60, blendHalfWidth: 0.025, envelope: fullness),
            smile: .init(lobes: [
                .init(center: Point(-0.44, 0), radius: Point(0.40, 0.28), vector: Point(-0.04, -0.075)),
                .init(center: Point(0, -0.06), radius: Point(0.27, 0.18), vector: Point(0.001, 0.007)),
                .init(center: Point(0.44, 0), radius: Point(0.40, 0.28), vector: Point(0.037, -0.073))
            ], envelope: whole))
    }

    func testDistinctAffineAxesAndTwoDimensionalTranslationPlatforms() throws {
        let c = try configuration(), model = try XCTUnwrap(Model(configuration: c))
        let p = Point(0.3, 0.10)
        let size = model.sample(field: .size, strength: 1, at: p).displacement
        XCTAssertEqual(size.x, 0.065 * 0.3, accuracy: 1e-14)
        XCTAssertEqual(size.y, 0.040 * 0.07, accuracy: 1e-14)
        let width = model.sample(field: .width, strength: 1, at: p).displacement
        XCTAssertEqual(width.x, 0.083 * 0.3, accuracy: 1e-14)
        XCTAssertEqual(width.y, 0)
        for point in [Point(-0.3, -0.10), Point(0.3, 0.1)] {
            XCTAssertEqual(model.sample(field: .vertical, strength: 1, at: point).displacement, c.vertical.vector)
            XCTAssertEqual(model.sample(field: .horizontal, strength: 1, at: point).displacement, c.horizontal.vector)
        }
        XCTAssertNotEqual(c.horizontal.vector.y, 0)
        XCTAssertNotEqual(c.vertical.vector.x, 0)
    }

    func testTiltTransitionsAngleAndPreservesRadiusThroughItsSupport() throws {
        let c = try configuration(), model = try XCTUnwrap(Model(configuration: c))
        for p in [Point(0.3, 0.1), Point(0.79, 0.32), Point(-0.9, -0.4)] {
            let r = p - c.tilt.center
            let moved = p + model.sample(field: .tilt, strength: 1, at: p).displacement - c.tilt.center
            XCTAssertEqual(hypot(r.x, r.y), hypot(moved.x, moved.y), accuracy: 1e-13,
                           "Angle attenuation must not create vector-blend radial shrinkage")
        }
    }

    func testMShapeIncludesOppositeUpperCenterAndLocalizedLowerEdgeMotion() throws {
        let c = try configuration(), model = try XCTUnwrap(Model(configuration: c))
        func displacement(_ x: Double, _ depth: Double) -> Double {
            let y = c.seam.sample(at: x).value + depth
            return model.sample(field: .mShape, strength: 1, at: Point(x, y)).displacement.y
        }
        XCTAssertLessThan(displacement(-0.22, -0.05), 0)
        XCTAssertGreaterThan(displacement(0, -0.05), 0)
        XCTAssertLessThan(displacement(0.22, -0.05), 0)
        XCTAssertLessThan(displacement(0, 0.13), 0,
                          "The lower-center evidence requires an independent reverse layer")
        var withoutLower = c
        withoutLower.mShape.lowerCenter = nil
        let baseline = try XCTUnwrap(Model(configuration: withoutLower))
        let side = Point(0.25, c.seam.sample(at: 0.25).value + 0.10)
        XCTAssertEqual(model.sample(field: .mShape, strength: 1, at: side).displacement,
                       baseline.sample(field: .mShape, strength: 1, at: side).displacement,
                       "The reverse peak must be localized rather than lifting every lower point")
        // Before the lower-edge bump starts, the nonnegative depth support
        // still admits a weaker continuation rather than fixing all lower lip.
        XCTAssertGreaterThan(displacement(0, 0.035), 0)
        XCTAssertLessThan(displacement(0, 0.035), displacement(0, -0.05))
    }

    func testOrderedMProfileSupportsMeasuredCentralPlateauBoundaries() throws {
        let profile = try XCTUnwrap(Model.Profile(knots: [Point(-0.6, 0), Point(-0.16, -0.004),
            Point(-0.09, 0.006), Point(0, 0.006), Point(0.09, 0.006),
            Point(0.16, -0.004), Point(0.6, 0)]))
        for x in [-0.089, -0.05, 0, 0.05, 0.089] {
            XCTAssertEqual(profile.sample(at: x).value, 0.006, accuracy: 1e-14)
            XCTAssertEqual(profile.sample(at: x).derivative, 0, accuracy: 1e-14)
        }
        for i in 0...240 {
            let sample = profile.sample(at: -0.65 + 1.3 * Double(i) / 240)
            XCTAssertLessThanOrEqual(abs(sample.value), profile.maximumValue + 1e-12)
            XCTAssertLessThanOrEqual(abs(sample.derivative), profile.maximumDerivative + 1e-12)
        }
        XCTAssertNil(Model.Profile(knots: (0..<12).map { Point(Double($0), 0) }))
    }

    func testIndependentMProfileEnvelopeStopsEarlyAndPreservesLowerEdgePeak() throws {
        var c = try configuration()
        let longProfile = try XCTUnwrap(Model(configuration: c))
        c.mShape.profileEnvelope = .init(innerMin: Point(-0.55, -0.12), innerMax: Point(0.55, 0.002),
                                        outerMin: Point(-0.75, -0.4), outerMax: Point(0.75, 0.075))
        let model = try XCTUnwrap(Model(configuration: c)), seam = c.seam.sample(at: 0).value
        let shallow = Point(0, seam + 0.035), lower = Point(0, seam + 0.13)
        let long = longProfile.sample(field: .mShape, strength: 1, at: shallow).displacement.y
        let short = model.sample(field: .mShape, strength: 1, at: shallow).displacement.y
        XCTAssertGreaterThan(short, 0); XCTAssertLessThan(short, long)
        var onlyLower = c
        onlyLower.mShape.profile = try XCTUnwrap(Model.Profile(knots: c.mShape.profile.knots.map { Point($0.x, 0) }))
        let lowerModel = try XCTUnwrap(Model(configuration: onlyLower))
        XCTAssertEqual(model.sample(field: .mShape, strength: 1, at: lower).displacement,
                       lowerModel.sample(field: .mShape, strength: 1, at: lower).displacement)
        XCTAssertLessThan(model.sample(field: .mShape, strength: 1, at: lower).displacement.y, 0)
        let x = 0.04, p = Point(x, c.seam.sample(at: x).value + 0.04), h = 1e-7
        let actual = model.sample(field: .mShape, strength: 1, at: p)
        func d(_ q: Point) -> Point { model.sample(field: .mShape, strength: 1, at: q).displacement }
        let dx = (d(p + Point(h, 0)) - d(p - Point(h, 0))) / (2 * h)
        let dy = (d(p + Point(0, h)) - d(p - Point(0, h))) / (2 * h)
        XCTAssertLessThan(hypot(dx.x - actual.gradientX.x, dx.y - actual.gradientX.y), 2e-7)
        XCTAssertLessThan(hypot(dy.x - actual.gradientY.x, dy.y - actual.gradientY.y), 2e-7)
        XCTAssertLessThanOrEqual(spectralNorm(actual.gradientX, actual.gradientY), model.bounds(field: .mShape, strength: 1).maximumGradient)
    }

    func testFullnessUsesCurvedSeamAndIndependentUpperLowerRates() throws {
        let c = try configuration(), model = try XCTUnwrap(Model(configuration: c))
        for x in [-0.2, 0.0, 0.2] {
            let seam = c.seam.sample(at: x).value
            let middle = model.sample(field: .fullness, strength: 1, at: Point(x, seam)).displacement
            let upper = model.sample(field: .fullness, strength: 1, at: Point(x, seam - 0.1)).displacement
            let lower = model.sample(field: .fullness, strength: 1, at: Point(x, seam + 0.1)).displacement
            XCTAssertEqual(middle, .zero)
            XCTAssertEqual(upper.x, 0); XCTAssertEqual(lower.x, 0)
            XCTAssertEqual(upper.y, -0.030, accuracy: 1e-13)
            XCTAssertEqual(lower.y, 0.060, accuracy: 1e-13)
        }
    }

    func testSmileHasCornerOutwardLiftAndWeakCentralDownwardPeak() throws {
        let c = try configuration(), model = try XCTUnwrap(Model(configuration: c))
        let left = model.sample(field: .smile, strength: 1, at: c.smile.lobes[0].center).displacement
        let center = model.sample(field: .smile, strength: 1, at: c.smile.lobes[1].center).displacement
        let right = model.sample(field: .smile, strength: 1, at: c.smile.lobes[2].center).displacement
        XCTAssertLessThan(left.x, 0); XCTAssertLessThan(left.y, 0)
        XCTAssertGreaterThan(right.x, 0); XCTAssertLessThan(right.y, 0)
        XCTAssertGreaterThan(center.y, 0)
        XCTAssertLessThan(center.y, min(abs(left.y), abs(right.y)))
    }

    func testSmileCentralPlateauReplacesCornerTailsWithCompleteTransitionDerivative() throws {
        var c = try configuration()
        c.smile.lobes[0].radius = Point(0.58, 0.34)
        c.smile.lobes[2].radius = Point(0.58, 0.34)
        // The central bell is deliberately tiny: the new plateau must use its
        // vector independently, rather than accidentally keep the old bell.
        c.smile.lobes[1].radius = Point(0.005, 0.005)
        let additive = try XCTUnwrap(Model(configuration: c))
        XCTAssertLessThan(additive.sample(field: .smile, strength: 1, at: Point(0, -0.06)).displacement.y, 0,
                          "This source fixture exposes cancellation by two negative corner tails")
        c.smile.centralEnvelope = .init(innerMin: Point(-0.16, -0.10), innerMax: Point(0.16, 0.02),
                                        outerMin: Point(-0.28, -0.22), outerMax: Point(0.28, 0.12))
        let model = try XCTUnwrap(Model(configuration: c))
        for p in [Point(0, -0.06), Point(-0.15, -0.02), Point(0.15, -0.02)] {
            XCTAssertEqual(model.sample(field: .smile, strength: 1, at: p).displacement, c.smile.lobes[1].vector)
        }
        XCTAssertLessThan(model.sample(field: .smile, strength: 1, at: Point(0, 0.21)).displacement.y, 0,
                          "The lower corner tail must survive outside the upper central envelope")
        let h = 1e-7
        for p in [Point(0.21, -0.06), Point(-0.23, 0.01), Point(0.05, 0.08), Point(0.24, 0.10)] {
            let actual = model.sample(field: .smile, strength: 1, at: p)
            func d(_ q: Point) -> Point { model.sample(field: .smile, strength: 1, at: q).displacement }
            let dx = (d(p + Point(h, 0)) - d(p - Point(h, 0))) / (2 * h)
            let dy = (d(p + Point(0, h)) - d(p - Point(0, h))) / (2 * h)
            XCTAssertLessThan(hypot(dx.x - actual.gradientX.x, dx.y - actual.gradientX.y), 2e-7)
            XCTAssertLessThan(hypot(dy.x - actual.gradientY.x, dy.y - actual.gradientY.y), 2e-7)
        }
        for sign in [-1.0, 1.0] {
            let bound = BeautyMouthReferenceCertificate.bounds(model: model, field: .smile, strength: sign)
            let scale = BeautyMouthReferenceCertificate.maximumLinearScale(model: model, field: .smile, strength: sign)
            XCTAssertGreaterThan(scale, 0)
            for ix in 0...66 { for iy in 0...48 {
                let p = Point(-1.2 + 2.4 * Double(ix) / 66, -0.75 + 1.5 * Double(iy) / 48)
                let raw = model.sample(field: .smile, strength: sign, at: p)
                XCTAssertLessThanOrEqual(hypot(raw.displacement.x, raw.displacement.y), bound.maximumDisplacement + 1e-12)
                XCTAssertLessThanOrEqual(spectralNorm(raw.gradientX, raw.gradientY), bound.maximumGradient + 1e-12)
                for fraction in [0.0, 0.31, 0.73, 1.0] {
                    let a = raw.scaled(by: scale * fraction)
                    XCTAssertGreaterThanOrEqual((1 + a.gradientX.x) * (1 + a.gradientY.y) - a.gradientY.x * a.gradientX.y,
                                               0.25 - 1e-11)
                }
            } }
        }
    }

    func testAnalyticCompleteDerivativesMatchIndependentFiniteDifferences() throws {
        // The compact smile peaks are C1 at their exact support boundary.
        // Central differences crossing such a boundary have O(h), not O(h²),
        // truncation error. Keep the derivative tolerance and resolve that
        // boundary at a smaller step; convergence is checked separately below.
        let c = try configuration(), model = try XCTUnwrap(Model(configuration: c)), step = 1e-7
        // Includes affine/rotation transitions, seam knots, blend band, M
        // lower-edge peak and overlapping smile peaks, rather than centers only.
        let points = [Point(-0.91, -0.37), Point(-0.68, 0.28), Point(-0.44, 0.05),
            Point(-0.25, -0.005), Point(-0.07, 0.023), Point(0, 0.013),
            Point(0.04, 0.13), Point(0.25, 0.08), Point(0.72, 0.41), Point(1.07, -0.23)]
        for field in Model.Field.allCases { for strength in [-1.0, -0.37, 0.63, 1.0] { for p in points {
            let actual = model.sample(field: field, strength: strength, at: p)
            func d(_ q: Point) -> Point { model.sample(field: field, strength: strength, at: q).displacement }
            let dx = (d(p + Point(step, 0)) - d(p - Point(step, 0))) / (2 * step)
            let dy = (d(p + Point(0, step)) - d(p - Point(0, step))) / (2 * step)
            XCTAssertLessThan(hypot(dx.x - actual.gradientX.x, dx.y - actual.gradientX.y), 2e-7,
                              "\(field) strength \(strength), point \(p), x chain rule")
            XCTAssertLessThan(hypot(dy.x - actual.gradientY.x, dy.y - actual.gradientY.y), 2e-7,
                              "\(field) strength \(strength), point \(p), y chain rule")
        } } }
    }

    func testSmileC1SupportBoundaryFiniteDifferenceConvergesToZeroDerivative() throws {
        let model = try XCTUnwrap(Model(configuration: configuration()))
        let boundaries: [(Point, Point)] = [(Point(-0.68, 0.28), Point(0, 1)),
                                            (Point(0.04, 0.13), Point(1, 0))]
        for (point, direction) in boundaries {
            let sample = model.sample(field: .smile, strength: 1, at: point)
            let analytic = direction.x != 0 ? sample.gradientX : sample.gradientY
            XCTAssertLessThan(hypot(analytic.x, analytic.y), 1e-12)
            func error(_ step: Double) -> Double {
                let plus = model.sample(field: .smile, strength: 1, at: point + direction * step).displacement
                let minus = model.sample(field: .smile, strength: 1, at: point - direction * step).displacement
                let derivative = (plus - minus) / (2 * step) - analytic
                return hypot(derivative.x, derivative.y)
            }
            let coarse = error(1e-6), half = error(5e-7), fine = error(1e-7)
            XCTAssertGreaterThan(coarse, 2e-7, "This fixture exercises a real C1 boundary truncation error")
            XCTAssertLessThan(half, 0.55 * coarse)
            XCTAssertLessThan(fine, 0.12 * coarse)
            XCTAssertLessThan(fine, 2e-7)
        }
    }

    func testAnalyticBoundsContainEvaluationsAndC1ExteriorIsIdentity() throws {
        let model = try XCTUnwrap(Model(configuration: configuration()))
        for field in Model.Field.allCases {
            let bound = model.bounds(field: field, strength: 0.73)
            // This finite grid is an algebra regression check only. The bound
            // itself comes from continuous derivative inequalities in the model.
            for ix in 0...32 { for iy in 0...24 {
                let p = Point(-1.3 + 2.6 * Double(ix) / 32, -0.8 + 1.6 * Double(iy) / 24)
                let sample = model.sample(field: field, strength: 0.73, at: p)
                XCTAssertLessThanOrEqual(hypot(sample.displacement.x, sample.displacement.y), bound.maximumDisplacement + 1e-12)
                XCTAssertLessThanOrEqual(spectralNorm(sample.gradientX, sample.gradientY), bound.maximumGradient + 1e-12)
            } }
            for p in [Point(-2, 0), Point(2, 0), Point(0, -2), Point(0, 2)] {
                let sample = model.sample(field: field, strength: 1, at: p)
                XCTAssertEqual(sample.displacement, .zero)
                XCTAssertEqual(sample.gradientX, .zero); XCTAssertEqual(sample.gradientY, .zero)
            }
            XCTAssertEqual(model.sample(field: field, strength: 0, at: Point(0.2, 0.05)).displacement, .zero)
            XCTAssertEqual(model.bounds(field: field, strength: 0).maximumGradient, 0)
        }
    }

    func testSeamIsC1AndItsAnalyticSlopeBoundCoversAllSegments() throws {
        let seam = try configuration().seam
        for knot in seam.knots {
            XCTAssertEqual(seam.sample(at: knot.x).value, knot.y, accuracy: 1e-13)
            let left = seam.sample(at: knot.x - 1e-7), right = seam.sample(at: knot.x + 1e-7)
            XCTAssertEqual(left.slope, right.slope, accuracy: 2e-6)
        }
        for i in 0...200 {
            let sample = seam.sample(at: -0.7 + 1.4 * Double(i) / 200)
            XCTAssertLessThanOrEqual(abs(sample.slope), seam.maximumSlope + 1e-12)
            XCTAssertGreaterThanOrEqual(sample.value, seam.minimumValue - 1e-12)
            XCTAssertLessThanOrEqual(sample.value, seam.maximumValue + 1e-12)
        }
    }

    func testFullnessVerticalDerivativeIntervalContainsFiniteDifferenceChecks() throws {
        let c = try configuration(), model = try XCTUnwrap(Model(configuration: c))
        let step = 1e-6
        for strength in [-1.0, -0.29, 0.0, 0.43, 1.0] {
            let lower = model.minimumVerticalDerivativeForFullness(strength: strength)
            XCTAssertTrue(lower.isFinite)
            XCTAssertLessThanOrEqual(lower, 0)
            for x in [-0.78, -0.31, 0.0, 0.23, 0.71] { for index in 0...160 {
                let seam = c.seam.sample(at: x).value
                let y = seam - 0.62 + 1.3 * Double(index) / 160
                let p = Point(x, y)
                let sample = model.sample(field: .fullness, strength: strength, at: p)
                let above = model.sample(field: .fullness, strength: strength, at: p - Point(0, step))
                let below = model.sample(field: .fullness, strength: strength, at: p + Point(0, step))
                let difference = (below.displacement.y - above.displacement.y) / (2 * step)
                // Evaluated points only check implementation algebra. The
                // certificate covers entire intervals and is not this grid.
                XCTAssertGreaterThanOrEqual(sample.gradientY.y, lower - 1e-12)
                XCTAssertGreaterThanOrEqual(difference, lower - 2e-8)
            } }
        }
        XCTAssertEqual(model.minimumVerticalDerivativeForFullness(strength: 0), 0)
        XCTAssertEqual(model.minimumVerticalDerivativeForFullness(strength: .nan), -.infinity)
        XCTAssertGreaterThan(model.minimumVerticalDerivativeForFullness(strength: 1),
                             -model.bounds(field: .fullness, strength: 1).maximumGradient,
                             "Column monotonicity should not pay the full shear/expansion Lipschitz bound")
    }

    func testFullnessVerticalDerivativeCertificateIsIndependentOfSeamSlopeAndHorizontalSupport() throws {
        var c = try configuration()
        let baseline = try XCTUnwrap(Model(configuration: c))
        let original = baseline.minimumVerticalDerivativeForFullness(strength: 1)
        c.seam = try XCTUnwrap(Model.Seam(knots: [Point(-0.5, 0.25), Point(0, -0.25), Point(0.5, 0.25)]))
        c.fullness.envelope.innerMin.x = -0.10
        c.fullness.envelope.innerMax.x = 0.10
        c.fullness.envelope.outerMin.x = -0.11
        c.fullness.envelope.outerMax.x = 0.11
        let steepSeam = try XCTUnwrap(Model(configuration: c))
        XCTAssertEqual(steepSeam.minimumVerticalDerivativeForFullness(strength: 1), original,
                       "dt/dy=1 and 0<=horizontal support<=1, independent of source seam shear")
        XCTAssertGreaterThan(steepSeam.bounds(field: .fullness, strength: 1).maximumGradient,
                             baseline.bounds(field: .fullness, strength: 1).maximumGradient)
    }

    func testFullnessNarrowSeamBlendKeepsFiniteDerivativeAndCertificate() throws {
        var c = try configuration()
        c.fullness.blendHalfWidth = 1e-200
        let model = try XCTUnwrap(Model(configuration: c))
        let seam = c.seam.sample(at: 0).value
        let atSeam = model.sample(field: .fullness, strength: 1, at: Point(0, seam))
        XCTAssertTrue(atSeam.gradientY.y.isFinite)
        XCTAssertTrue(model.minimumVerticalDerivativeForFullness(strength: 1).isFinite)
    }

    func testIntervalCertificatesContainDisplacementAndCompleteJacobians() throws {
        let model = try XCTUnwrap(Model(configuration: configuration()))
        let fields: [Model.Field] = [.size, .width, .vertical, .horizontal, .tilt, .smile]
        for field in fields { for strength in [-1.0, -0.31, 0.47, 1.0] {
            let bound = BeautyMouthReferenceCertificate.bounds(model: model, field: field, strength: strength)
            XCTAssertTrue(bound.maximumDisplacement.isFinite)
            XCTAssertTrue(bound.maximumGradient.isFinite)
            let simple = model.bounds(field: field, strength: strength)
            XCTAssertLessThanOrEqual(bound.maximumDisplacement, simple.maximumDisplacement)
            XCTAssertLessThanOrEqual(bound.maximumGradient, simple.maximumGradient)
            // The certificate encloses every continuous box. This finite grid
            // independently catches enclosure-algebra mistakes; it is not the
            // reason the global bound is valid.
            for ix in 0...44 { for iy in 0...32 {
                let p = Point(-1.20 + 2.4 * Double(ix) / 44, -0.75 + 1.5 * Double(iy) / 32)
                let actual = model.sample(field: field, strength: strength, at: p)
                XCTAssertLessThanOrEqual(hypot(actual.displacement.x, actual.displacement.y),
                                         bound.maximumDisplacement + 1e-12, "\(field), \(p)")
                XCTAssertLessThanOrEqual(spectralNorm(actual.gradientX, actual.gradientY),
                                         bound.maximumGradient + 1e-12, "\(field), \(p)")
            } }
        } }
    }

    func testIntervalCertificateTightensRotationAndPeakTriangleBounds() throws {
        let model = try XCTUnwrap(Model(configuration: configuration()))
        let fields: [Model.Field] = [.tilt, .smile, .horizontal]
        for field in fields {
            let tighter = BeautyMouthReferenceCertificate.bounds(model: model, field: field, strength: 1)
            let simple = model.bounds(field: field, strength: 1)
            XCTAssertLessThan(tighter.maximumGradient, simple.maximumGradient * 0.99,
                              "The spatial certificate must actually improve the loose global product")
        }
    }

    func testIntervalRotationEnclosuresIncludeTrigonometricCriticalPoints() throws {
        for angle in [-Double.pi * 0.8, -0.137, 0.137, Double.pi * 0.5, Double.pi * 0.8] {
            var c = try configuration()
            c.tilt.angle = angle
            let model = try XCTUnwrap(Model(configuration: c))
            let bound = BeautyMouthReferenceCertificate.bounds(model: model, field: .tilt, strength: 1)
            for ix in 0...34 { for iy in 0...26 {
                let p = Point(-1.15 + 2.3 * Double(ix) / 34, -0.65 + 1.35 * Double(iy) / 26)
                let actual = model.sample(field: .tilt, strength: 1, at: p)
                XCTAssertLessThanOrEqual(hypot(actual.displacement.x, actual.displacement.y), bound.maximumDisplacement + 1e-11)
                XCTAssertLessThanOrEqual(spectralNorm(actual.gradientX, actual.gradientY), bound.maximumGradient + 1e-11)
            } }
        }
    }

    func testRadialEnvelopeIncludesCompleteProductDerivativeAndIntervalCertificate() throws {
        var c = try configuration()
        let radial = Model.Radial(center: Point(0, 0.02), radiusX: 1.03,
                                  radiusUp: 0.58, radiusDown: 0.65, innerRadius: 0.42)
        c.size.envelope.radial = radial; c.width.envelope.radial = radial
        c.vertical.envelope.radial = radial; c.horizontal.envelope.radial = radial
        c.tilt.envelope.radial = radial; c.smile.envelope.radial = radial
        let model = try XCTUnwrap(Model(configuration: c)), step = 1e-7
        let fields: [Model.Field] = [.size, .width, .vertical, .horizontal, .tilt, .smile]
        for field in fields {
            let bound = BeautyMouthReferenceCertificate.bounds(model: model, field: field, strength: 1)
            for ix in 0...34 { for iy in 0...26 {
                let p = Point(-1.15 + 2.3 * Double(ix) / 34, -0.65 + 1.35 * Double(iy) / 26)
                let actual = model.sample(field: field, strength: 1, at: p)
                XCTAssertLessThanOrEqual(hypot(actual.displacement.x, actual.displacement.y), bound.maximumDisplacement + 1e-12)
                XCTAssertLessThanOrEqual(spectralNorm(actual.gradientX, actual.gradientY), bound.maximumGradient + 1e-12)
            } }
            for p in [Point(-0.61, -0.21), Point(0.37, 0.29), Point(0.65, 0.13), Point(0.72, 0.0201)] {
                let actual = model.sample(field: field, strength: 1, at: p)
                func d(_ q: Point) -> Point { model.sample(field: field, strength: 1, at: q).displacement }
                let dx = (d(p + Point(step, 0)) - d(p - Point(step, 0))) / (2 * step)
                let dy = (d(p + Point(0, step)) - d(p - Point(0, step))) / (2 * step)
                XCTAssertLessThan(hypot(dx.x - actual.gradientX.x, dx.y - actual.gradientX.y), 2e-7)
                XCTAssertLessThan(hypot(dy.x - actual.gradientY.x, dy.y - actual.gradientY.y), 2e-7)
            }
        }
        // The radial y radius changes across this line. Its gradient must be
        // continuous there, and r=0 must use the finite central platform.
        let upper = model.sample(field: .horizontal, strength: 1, at: Point(0.7, 0.02 - 1e-7))
        let lower = model.sample(field: .horizontal, strength: 1, at: Point(0.7, 0.02 + 1e-7))
        XCTAssertLessThan(hypot(upper.gradientY.x, upper.gradientY.y), 1e-5)
        XCTAssertLessThan(hypot(lower.gradientY.x, lower.gradientY.y), 1e-5)
        XCTAssertEqual(model.sample(field: .horizontal, strength: 1, at: radial.center).gradientY, .zero)
        let outside = model.sample(field: .horizontal, strength: 1,
                                   at: radial.center + Point(radial.radiusX * 1.01, 0))
        XCTAssertEqual(outside.displacement, .zero)
        XCTAssertEqual(outside.gradientX, .zero); XCTAssertEqual(outside.gradientY, .zero)
    }

    func testMShapeAbsoluteSourceEnvelopeProtectsNoseWithoutChangingSeamDomain() throws {
        var c = try configuration()
        let without = try XCTUnwrap(Model(configuration: c))
        c.mShape.sourceEnvelope = .init(innerMin: Point(-0.8, -0.04), innerMax: Point(0.8, 0.4),
                                       outerMin: Point(-1, -0.12), outerMax: Point(1, 0.6))
        let model = try XCTUnwrap(Model(configuration: c))
        let protected = Point(0, -0.15)
        XCTAssertGreaterThan(without.sample(field: .mShape, strength: 1, at: protected).displacement.y, 0)
        let fixed = model.sample(field: .mShape, strength: 1, at: protected)
        XCTAssertEqual(fixed.displacement, .zero)
        XCTAssertEqual(fixed.gradientX, .zero); XCTAssertEqual(fixed.gradientY, .zero)
        let p = Point(0.04, -0.07), h = 1e-7
        let actual = model.sample(field: .mShape, strength: 1, at: p)
        func d(_ q: Point) -> Point { model.sample(field: .mShape, strength: 1, at: q).displacement }
        let dx = (d(p + Point(h, 0)) - d(p - Point(h, 0))) / (2 * h)
        let dy = (d(p + Point(0, h)) - d(p - Point(0, h))) / (2 * h)
        XCTAssertLessThan(hypot(dx.x - actual.gradientX.x, dx.y - actual.gradientX.y), 2e-7)
        XCTAssertLessThan(hypot(dy.x - actual.gradientY.x, dy.y - actual.gradientY.y), 2e-7)
        let bound = model.bounds(field: .mShape, strength: 1)
        XCTAssertGreaterThan(bound.maximumGradient, without.bounds(field: .mShape, strength: 1).maximumGradient)
        XCTAssertLessThanOrEqual(spectralNorm(actual.gradientX, actual.gradientY), bound.maximumGradient)
    }

    func testTranslationDirectedDerivativeCertificateContainsAnalyticAndFiniteDifferenceTrace() throws {
        let fields: [Model.Field] = [.vertical, .horizontal]
        let h = 1e-7
        for radial in [false, true] {
            var c = try configuration()
            if radial {
                let r = Model.Radial(center: Point(0, 0.02), radiusX: 1.04,
                                     radiusUp: 0.57, radiusDown: 0.66, innerRadius: 0.40)
                c.vertical.envelope.radial = r; c.horizontal.envelope.radial = r
            }
            let model = try XCTUnwrap(Model(configuration: c))
            for field in fields { for strength in [-1.0, -0.37, 0.51, 1.0] {
                let lower = BeautyMouthReferenceCertificate.minimumTranslationDeterminantOffset(
                    model: model, field: field, strength: strength)
                XCTAssertTrue(lower.isFinite); XCTAssertLessThanOrEqual(lower, 0)
                for ix in 0...36 { for iy in 0...28 {
                    let p = Point(-1.2 + 2.4 * Double(ix) / 36, -0.75 + 1.5 * Double(iy) / 28)
                    let sample = model.sample(field: field, strength: strength, at: p)
                    let trace = sample.gradientX.x + sample.gradientY.y
                    func d(_ q: Point) -> Point { model.sample(field: field, strength: strength, at: q).displacement }
                    let dx = (d(p + Point(h, 0)).x - d(p - Point(h, 0)).x) / (2 * h)
                    let dy = (d(p + Point(0, h)).y - d(p - Point(0, h)).y) / (2 * h)
                    XCTAssertGreaterThanOrEqual(trace, lower - 1e-12)
                    XCTAssertGreaterThanOrEqual(dx + dy, lower - 2e-7)
                } }
            } }
            XCTAssertEqual(BeautyMouthReferenceCertificate.minimumTranslationDeterminantOffset(
                model: model, field: .horizontal, strength: 0), 0)
            XCTAssertEqual(BeautyMouthReferenceCertificate.minimumTranslationDeterminantOffset(
                model: model, field: .size, strength: 1), -.infinity)
        }
    }

    func testTranslationDeterminantCertificateDoesNotPenalizePerpendicularShear() throws {
        var c = try configuration()
        c.horizontal.vector = Point(0.1, 0)
        let baseline = try XCTUnwrap(Model(configuration: c))
        let a = BeautyMouthReferenceCertificate.minimumTranslationDeterminantOffset(
            model: baseline, field: .horizontal, strength: 1)
        c.horizontal.envelope.outerMin.y = c.horizontal.envelope.innerMin.y - 0.0001
        c.horizontal.envelope.outerMax.y = c.horizontal.envelope.innerMax.y + 0.0001
        let shear = try XCTUnwrap(Model(configuration: c))
        let b = BeautyMouthReferenceCertificate.minimumTranslationDeterminantOffset(
            model: shear, field: .horizontal, strength: 1)
        XCTAssertEqual(a, b, accuracy: 1e-12,
                       "Only the derivative along t controls rank-one invertibility")
        XCTAssertGreaterThan(shear.bounds(field: .horizontal, strength: 1).maximumGradient,
                             100 * baseline.bounds(field: .horizontal, strength: 1).maximumGradient)
    }

    func testTiltDirectedDeterminantCertificateContainsAnalyticAndFiniteDifferenceJacobians() throws {
        let h = 1e-7
        for radial in [false, true] {
            var c = try configuration()
            if radial {
                c.tilt.envelope.radial = .init(center: c.tilt.center, radiusX: 1.04,
                    radiusUp: 0.57, radiusDown: 0.66, innerRadius: 0.40)
            }
            let model = try XCTUnwrap(Model(configuration: c))
            for strength in [-1.0, -0.41, 0.57, 1.0] {
                let lower = BeautyMouthReferenceCertificate.minimumTiltDeterminantOffset(model: model, strength: strength)
                XCTAssertTrue(lower.isFinite); XCTAssertLessThanOrEqual(lower, 0)
                for ix in 0...32 { for iy in 0...24 {
                    let p = Point(-1.2 + 2.4 * Double(ix) / 32, -0.75 + 1.5 * Double(iy) / 24)
                    let actual = model.sample(field: .tilt, strength: strength, at: p)
                    let determinant = (1 + actual.gradientX.x) * (1 + actual.gradientY.y)
                        - actual.gradientY.x * actual.gradientX.y
                    func d(_ q: Point) -> Point { model.sample(field: .tilt, strength: strength, at: q).displacement }
                    let dx = (d(p + Point(h, 0)) - d(p - Point(h, 0))) / (2 * h)
                    let dy = (d(p + Point(0, h)) - d(p - Point(0, h))) / (2 * h)
                    let finiteDeterminant = (1 + dx.x) * (1 + dy.y) - dy.x * dx.y
                    XCTAssertGreaterThanOrEqual(determinant - 1, lower - 1e-12)
                    XCTAssertGreaterThanOrEqual(finiteDeterminant - 1, lower - 2e-7)
                } }
            }
        }
    }

    func testAdaptiveTiltCertificateClosesContinuousMinimumGap() throws {
        for radial in [false, true] {
            var c = try configuration()
            if radial {
                c.tilt.envelope.radial = .init(center: c.tilt.center, radiusX: 0.80,
                    radiusUp: 0.41, radiusDown: 0.61, innerRadius: 0.73)
            }
            let model = try XCTUnwrap(Model(configuration: c))
            for strength in [-1.0, 1.0] {
                let range = BeautyMouthReferenceCertificate.tiltDeterminantRange(model: model, strength: strength)
                XCTAssertTrue(range.reachedTolerance)
                XCTAssertLessThanOrEqual(range.lower, range.upper)
                XCTAssertLessThanOrEqual(range.upper - range.lower, 0.02)
                XCTAssertGreaterThan(range.boxes, 0)
                for ix in 0...80 { for iy in 0...60 {
                    let p = Point(-1.2 + 2.4 * Double(ix) / 80, -0.75 + 1.5 * Double(iy) / 60)
                    let a = model.sample(field: .tilt, strength: strength, at: p)
                    let determinantOffset = (1 + a.gradientX.x) * (1 + a.gradientY.y)
                        - a.gradientY.x * a.gradientX.y - 1
                    XCTAssertGreaterThanOrEqual(determinantOffset, range.lower - 1e-12)
                } }
            }
        }
    }

    func testTiltCertificateRetainsCircularRadialAngularCancellation() throws {
        var c = try configuration()
        c.tilt.envelope = .init(innerMin: Point(-1.2, -1.2), innerMax: Point(1.2, 1.2),
            outerMin: Point(-1.5, -1.5), outerMax: Point(1.5, 1.5),
            radial: .init(center: c.tilt.center, radiusX: 0.8, radiusUp: 0.8, radiusDown: 0.8, innerRadius: 0.4))
        let model = try XCTUnwrap(Model(configuration: c))
        let range = BeautyMouthReferenceCertificate.tiltDeterminantRange(model: model, strength: 1)
        XCTAssertTrue(range.reachedTolerance)
        XCTAssertGreaterThan(range.lower, -1e-10,
                             "A centered circular taper has zero angular derivative despite nonzero radial shear")
    }

    func testLinearHomotopyCertificateContainsIntermediateDeterminants() throws {
        let fields: [Model.Field] = [.size, .width, .smile]
        for radial in [false, true] {
            var c = try configuration()
            if radial {
                let r = Model.Radial(center: Point(0, 0.02), radiusX: 1.04,
                                     radiusUp: 0.57, radiusDown: 0.66, innerRadius: 0.40)
                c.size.envelope.radial = r; c.width.envelope.radial = r; c.smile.envelope.radial = r
            }
            let model = try XCTUnwrap(Model(configuration: c))
            for field in fields { for strength in [-1.0, 1.0] {
                let scale = BeautyMouthReferenceCertificate.maximumLinearScale(model: model, field: field,
                    strength: strength, minimumDeterminant: 0.25)
                XCTAssertGreaterThan(scale, 0); XCTAssertLessThanOrEqual(scale, 1)
                // Regression only: the proof covers every s, not these five.
                for fraction in [0.0, 0.17, 0.39, 0.73, 1.0] {
                    for ix in 0...30 { for iy in 0...22 {
                        let p = Point(-1.2 + 2.4 * Double(ix) / 30, -0.75 + 1.5 * Double(iy) / 22)
                        let a = model.sample(field: field, strength: strength, at: p).scaled(by: scale * fraction)
                        let determinant = (1 + a.gradientX.x) * (1 + a.gradientY.y) - a.gradientY.x * a.gradientX.y
                        XCTAssertGreaterThanOrEqual(determinant, 0.25 - 1e-11, "\(field), s=\(scale * fraction), p=\(p)")
                    } }
                }
            } }
        }
    }

    func testLinearHomotopyCertificateReducesUnsafeWidthEndpointAndRejectsUnsupportedFields() throws {
        var c = try configuration()
        c.width.rates = Point(2, 0)
        let model = try XCTUnwrap(Model(configuration: c))
        let scale = BeautyMouthReferenceCertificate.maximumLinearScale(model: model, field: .width, strength: 1)
        XCTAssertGreaterThan(scale, 0)
        XCTAssertLessThan(scale, 1)
        for ix in 0...180 {
            let p = Point(-1.15 + 2.3 * Double(ix) / 180, 0)
            let a = model.sample(field: .width, strength: 1, at: p).scaled(by: scale)
            XCTAssertGreaterThanOrEqual((1 + a.gradientX.x) * (1 + a.gradientY.y) - a.gradientY.x * a.gradientX.y,
                                       0.25 - 1e-11)
        }
        XCTAssertEqual(BeautyMouthReferenceCertificate.maximumLinearScale(model: model, field: .width, strength: 0), 1)
        XCTAssertEqual(BeautyMouthReferenceCertificate.maximumLinearScale(model: model, field: .fullness, strength: 1), 0)
        XCTAssertEqual(BeautyMouthReferenceCertificate.maximumLinearScale(model: model, field: .width, strength: .nan), 0)
        XCTAssertEqual(BeautyMouthReferenceCertificate.maximumLinearScale(model: model, field: .width, strength: 1,
                                                                          minimumDeterminant: 1.01), 0)
    }

    func testAdaptiveHighGradientSmileCertificateContainsCompleteHomotopyAndComponents() throws {
        var c = try configuration()
        c.smile.envelope.radial = .init(center: Point(0, 0.02), radiusX: 0.83,
            radiusUp: 0.41, radiusDown: 0.61, innerRadius: 0.73)
        for i in c.smile.lobes.indices { c.smile.lobes[i].vector *= 3 }
        let model = try XCTUnwrap(Model(configuration: c))
        for sign in [-1.0, 1.0] {
            let range = BeautyMouthReferenceCertificate.linearScaleRange(model: model, field: .smile, strength: sign)
            XCTAssertTrue(range.reachedTolerance)
            XCTAssertGreaterThan(range.lower, 0)
            XCTAssertLessThanOrEqual(range.lower, range.upper)
            XCTAssertLessThanOrEqual(range.upper - range.lower, 0.01)
            let complete = BeautyMouthReferenceCertificate.bounds(model: model, field: .smile, strength: sign)
            // These evaluated points only check the enclosure algebra. Every
            // source box and every homotopy amount are covered by the proof.
            for fraction in [0.0, 0.13, 0.37, 0.69, 1.0] {
                for ix in 0...72 { for iy in 0...52 {
                    let p = Point(-1.2 + 2.4 * Double(ix) / 72, -0.75 + 1.5 * Double(iy) / 52)
                    let raw = model.sample(field: .smile, strength: sign, at: p)
                    for component in [raw.gradientX.x, raw.gradientX.y, raw.gradientY.x, raw.gradientY.y] {
                        XCTAssertLessThanOrEqual(abs(component), complete.maximumGradient + 1e-12)
                    }
                    XCTAssertLessThanOrEqual(hypot(raw.displacement.x, raw.displacement.y), complete.maximumDisplacement + 1e-12)
                    let a = raw.scaled(by: range.lower * fraction)
                    let determinant = (1 + a.gradientX.x) * (1 + a.gradientY.y) - a.gradientY.x * a.gradientX.y
                    XCTAssertGreaterThanOrEqual(determinant, 0.25 - 1e-11)
                } }
            }
            let h = 1e-7
            for p in [Point(-0.7, -0.13), Point(0.2, 0.06), Point(0.62, 0.24)] {
                let a = model.sample(field: .smile, strength: sign, at: p).scaled(by: range.lower)
                func d(_ q: Point) -> Point {
                    model.sample(field: .smile, strength: sign, at: q).displacement * range.lower
                }
                let dx = (d(p + Point(h, 0)) - d(p - Point(h, 0))) / (2 * h)
                let dy = (d(p + Point(0, h)) - d(p - Point(0, h))) / (2 * h)
                XCTAssertLessThan(hypot(dx.x - a.gradientX.x, dx.y - a.gradientX.y), 2e-7)
                XCTAssertLessThan(hypot(dy.x - a.gradientY.x, dy.y - a.gradientY.y), 2e-7)
            }
        }
    }

    func testFullnessSourceProtectionIncludesCompleteProductAndSeamDerivatives() throws {
        var c = try configuration()
        c.fullness.depthCurvature = 0.65
        c.fullness.upperDepth = 0.14; c.fullness.lowerDepth = 0.15
        c.fullness.upperEnvelope = c.fullness.envelope
        c.fullness.upperEnvelope?.innerMin.x *= 1.35
        c.fullness.upperEnvelope?.innerMax.x *= 1.35
        c.fullness.upperEnvelope?.outerMin.x *= 1.35
        c.fullness.upperEnvelope?.outerMax.x *= 1.35
        c.fullness.sourceEnvelope = .init(innerMin: Point(-0.45, -0.15), innerMax: Point(0.45, 0.18),
                                         outerMin: Point(-0.75, -0.35), outerMax: Point(0.75, 0.39))
        let model = try XCTUnwrap(Model(configuration: c)), h = 1e-7
        for strength in [-1.0, 0.37, 1.0] {
            let bounds = model.bounds(field: .fullness, strength: strength)
            for p in [Point(-0.6, -0.23), Point(-0.2, -0.24), Point(0.1, 0.25), Point(0.6, 0.28),
                      Point(-0.6, -0.08), Point(-0.2, -0.08), Point(0.1, 0.10),
                      Point(0.65, 0.005), Point(0.65, -0.01)] {
                let a = model.sample(field: .fullness, strength: strength, at: p)
                func d(_ q: Point) -> Point { model.sample(field: .fullness, strength: strength, at: q).displacement }
                let dx = (d(p + Point(h, 0)) - d(p - Point(h, 0))) / (2 * h)
                let dy = (d(p + Point(0, h)) - d(p - Point(0, h))) / (2 * h)
                XCTAssertLessThan(hypot(dx.x - a.gradientX.x, dx.y - a.gradientX.y), 2e-8)
                XCTAssertLessThan(hypot(dy.x - a.gradientY.x, dy.y - a.gradientY.y), 2e-8)
                XCTAssertLessThanOrEqual(spectralNorm(a.gradientX, a.gradientY), bounds.maximumGradient)
                XCTAssertLessThanOrEqual(hypot(a.displacement.x, a.displacement.y), bounds.maximumDisplacement)
            }
            let protected = model.sample(field: .fullness, strength: strength, at: Point(0, -0.35))
            XCTAssertEqual(protected.displacement, .zero)
            XCTAssertEqual(protected.gradientX, .zero)
            XCTAssertEqual(protected.gradientY, .zero)
        }
    }

    func testFullnessCertificateEnclosesSourceBranchesAcrossCurvedSeamForBothSigns() throws {
        var c = try configuration()
        c.seam = try XCTUnwrap(Model.Seam(knots: [Point(-0.5, -0.06), Point(0, 0.07), Point(0.5, -0.06)]))
        c.fullness.upperDepth = 0.14; c.fullness.lowerDepth = 0.15
        c.fullness.upperEnvelope = c.fullness.envelope
        c.fullness.upperEnvelope?.innerMin.x *= 1.4
        c.fullness.upperEnvelope?.innerMax.x *= 1.4
        c.fullness.upperEnvelope?.outerMin.x *= 1.4
        c.fullness.upperEnvelope?.outerMax.x *= 1.4
        for upperFeather in [0.006, 0.04, 0.18] {
          for curvature in [0.0, 0.65, 1.0] {
            c.fullness.depthCurvature = curvature
            c.fullness.sourceEnvelope = .init(innerMin: Point(-0.45, -0.28 + upperFeather),
                innerMax: Point(0.45, 0.21), outerMin: Point(-0.75, -0.28), outerMax: Point(0.75, 0.33))
            let model = try XCTUnwrap(Model(configuration: c))
            for strength in [-1.0, -0.23, 0.41, 1.0] {
                let minimum = model.minimumVerticalDerivativeForFullness(strength: strength)
                XCTAssertTrue(minimum.isFinite)
                let scale = min(1, minimum < 0 ? 0.78 / -minimum : 1)
                // These points check the enclosure algebra; the production
                // certificate itself encloses whole intervals and branches.
                for ix in 0...24 { for iy in 0...180 {
                    let p = Point(-0.8 + 1.6 * Double(ix) / 24, -0.6 + 1.2 * Double(iy) / 180)
                    let a = model.sample(field: .fullness, strength: strength, at: p)
                    XCTAssertGreaterThanOrEqual(a.gradientY.y, minimum - 1e-12)
                    XCTAssertGreaterThanOrEqual(1 + scale * a.gradientY.y, 0.22 - 1e-12)
                    XCTAssertEqual(a.displacement.x, 0)
                } }
            }
          }
        }
    }

    func testInvalidConfigurationFailsClosed() throws {
        XCTAssertNil(Model.Seam(knots: [Point(0, 0), Point(0, 0.1)]))
        XCTAssertNil(Model.Profile(knots: [Point(-1, 0), Point(0, 0.1), Point(1, 0)]))
        var c = try configuration()
        c.fullness.blendHalfWidth = 0
        XCTAssertNil(Model(configuration: c))
        c = try configuration()
        c.fullness.depthCurvature = 1.01
        XCTAssertNil(Model(configuration: c))
        c.fullness.depthCurvature = 0.5; c.fullness.upperDepth = 0
        XCTAssertNil(Model(configuration: c))
        c = try configuration()
        c.fullness.upperEnvelope = c.fullness.envelope
        c.fullness.upperEnvelope?.innerMin.y += 0.01
        XCTAssertNil(Model(configuration: c), "The lateral blend certificate requires a common vertical envelope")
        c = try configuration()
        c.size.envelope.outerMin.x = c.size.envelope.innerMin.x
        XCTAssertNil(Model(configuration: c))
        c = try configuration()
        c.smile.lobes[1].radius.x = .nan
        XCTAssertNil(Model(configuration: c))
        c = try configuration()
        c.size.envelope.radial = .init(center: .zero, radiusX: -1, radiusUp: 1, radiusDown: 1, innerRadius: 0.4)
        XCTAssertNil(Model(configuration: c))
        c = try configuration()
        c.fullness.envelope.radial = .init(center: .zero, radiusX: 1, radiusUp: 1, radiusDown: 1, innerRadius: 0.4)
        XCTAssertNil(Model(configuration: c), "The one-dimensional fullness certificate excludes radial factors")
        c = try configuration()
        c.fullness.sourceEnvelope = c.fullness.envelope
        c.fullness.sourceEnvelope?.radial = .init(center: .zero, radiusX: 1, radiusUp: 1, radiusDown: 1, innerRadius: 0.4)
        XCTAssertNil(Model(configuration: c), "Absolute source protection must also remain separable")
        c.fullness.sourceEnvelope?.radial = nil
        let invalidTop = c.fullness.sourceEnvelope!.outerMin.y
        c.fullness.sourceEnvelope?.innerMin.y = invalidTop
        XCTAssertNil(Model(configuration: c))
        c = try configuration()
        c.smile.centralEnvelope = .init(innerMin: Point(-0.2, -0.1), innerMax: Point(0.2, 0.1),
                                        outerMin: Point(-0.2, -0.2), outerMax: Point(0.3, 0.2))
        XCTAssertNil(Model(configuration: c))
    }

    private func spectralNorm(_ x: Point, _ y: Point) -> Double {
        let a = x.x * x.x + x.y * x.y, b = x.x * y.x + x.y * y.y
        let d = y.x * y.x + y.y * y.y
        return sqrt(max(0, (a + d + hypot(a - d, 2 * b)) * 0.5))
    }
}
