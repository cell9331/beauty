import Foundation
import XCTest
@testable import BeautyEffects

/// Synthetic mechanism regressions only. Native reference train/holdout
/// evaluation remains separate; these do not claim photograph qualification.
final class BeautyMouthMShapeCalibrationTests: XCTestCase {
    private typealias Model = BeautyMouthReferenceModel
    private typealias Point = SIMD2<Double>

    private func model(parameters: BeautyMouthMShapeParameters = .referenceCalibration,
                       curved: Bool = false, protectedTop: Double = -0.45) throws -> Model {
        let seam = try XCTUnwrap(Model.Seam(knots: curved
            ? [Point(-0.6, -0.02), Point(-0.3, -0.005), Point(0, 0.01),
               Point(0.3, -0.008), Point(0.6, -0.02)]
            : [Point(-0.8, 0), Point(0.8, 0)]))
        let mouth = try XCTUnwrap(parameters.configuration(upperDepth: 0.10, lowerDepth: 0.18,
            top: -0.10, bottom: 0.18, protectedTop: protectedTop))
        let whole = Model.Envelope(innerMin: Point(-1, -0.7), innerMax: Point(1, 0.7),
                                   outerMin: Point(-1.4, -1), outerMax: Point(1.4, 1))
        let lobe = Model.Lobe(center: .zero, radius: Point(0.3, 0.3), vector: .zero)
        return try XCTUnwrap(Model(configuration: .init(seam: seam,
            size: .init(rates: .zero, envelope: whole), width: .init(rates: .zero, envelope: whole),
            vertical: .init(vector: .zero, envelope: whole),
            tilt: .init(angle: 0, envelope: whole), horizontal: .init(vector: .zero, envelope: whole),
            mShape: mouth, fullness: .init(upperRate: 0, lowerRate: 0, blendHalfWidth: 0.01, envelope: whole),
            smile: .init(lobes: [lobe, lobe, lobe], envelope: whole))))
    }

    func testNineNodeProfilePreservesOuterReboundAndCornerSignChanges() throws {
        var p = BeautyMouthMShapeParameters.referenceCalibration
        p.centralPlateauHalfWidth = 0
        let m = try model(parameters: p)
        XCTAssertEqual(m.configuration.mShape.profile.knots.count, 9)
        func dy(_ x: Double) -> Double {
            m.sample(field: .mShape, strength: 1, at: Point(x, 0)).displacement.y
        }
        XCTAssertGreaterThan(dy(0), 0)
        for sign in [-1.0, 1.0] {
            XCTAssertLessThan(dy(sign * p.shoulderPosition), 0)
            XCTAssertGreaterThan(dy(sign * p.reboundPosition), 0)
            XCTAssertLessThan(dy(sign * p.cornerPosition), 0)
            let edge = m.sample(field: .mShape, strength: 1, at: Point(sign * p.supportRadius, 0))
            XCTAssertEqual(edge.displacement, .zero)
            XCTAssertEqual(edge.gradientX, .zero)
            XCTAssertEqual(edge.gradientY, .zero)
        }
    }

    func testCentralPositiveShouldersPreserveWideCoreAndOuterSignChanges() throws {
        let p = BeautyMouthMShapeParameters.referenceCalibration
        let m = try model()
        XCTAssertEqual(m.configuration.mShape.profile.knots.count, 11)
        let upper = -0.10
        func dy(_ x: Double) -> Double {
            m.sample(field: .mShape, strength: 1, at: Point(x, upper)).displacement.y
        }
        for x in stride(from: -0.10, through: 0.10, by: 0.01) {
            XCTAssertGreaterThan(dy(x), 0, "central source width \(x)")
        }
        for sign in [-1.0, 1.0] {
            XCTAssertEqual(dy(sign * p.centralPlateauHalfWidth) / dy(0), p.centralShoulderRatio,
                           accuracy: 1e-12)
            XCTAssertGreaterThan(dy(sign * p.centralPlateauHalfWidth), dy(0) * 0.60)
            XCTAssertLessThan(dy(sign * p.shoulderPosition), 0)
            XCTAssertGreaterThan(dy(sign * p.reboundPosition), 0)
            XCTAssertLessThan(dy(sign * p.cornerPosition), 0)
        }
    }

    func testUpperPeakDecaysAtSeamAndStopsBeforeLowerMid() throws {
        // Keep the original independent vertical-response variant explicit:
        // calibrated defaults may choose a different seam/peak ratio for a
        // different current-source thickness, but this support must remain
        // expressible without changing either component's global amplitude.
        var parameters = BeautyMouthMShapeParameters.referenceCalibration
        parameters.upperTail = 0.22
        parameters.upperPlateauEndInUpperDepth = 0.40
        parameters.profileEndInLowerDepth = 0.30
        let m = try model(parameters: parameters)
        func dy(_ y: Double) -> Double {
            m.sample(field: .mShape, strength: 1, at: Point(0, y)).displacement.y
        }
        let peak = dy(-0.10), seam = dy(0), mid = dy(0.06)
        XCTAssertGreaterThan(peak, seam)
        XCTAssertGreaterThan(seam, peak * 0.5)
        XCTAssertLessThan(seam, peak * 0.75)
        XCTAssertEqual(mid, 0, accuracy: 1e-15)
        // The positive tail includes skin above the upper red-lip border.
        XCTAssertGreaterThan(dy(-0.22), peak * 0.15)
        XCTAssertLessThan(dy(-0.22), peak * 0.6)
        XCTAssertEqual(dy(-0.34), 0, accuracy: 1e-15)
    }

    func testLowerReversePeakIsLocalizedAndHasAWeakLowerTail() throws {
        let p = BeautyMouthMShapeParameters.referenceCalibration
        let m = try model(), c = try XCTUnwrap(m.configuration.mShape.lowerCenter)
        let peak = m.sample(field: .mShape, strength: 1, at: c.center).displacement.y
        XCTAssertLessThan(peak, 0)
        XCTAssertEqual(peak, p.lowerEdgePeak, accuracy: 1e-15)
        XCTAssertEqual(m.sample(field: .mShape, strength: 1,
            at: c.center + Point(c.radius.x, 0)).displacement, .zero)
        let narrow = m.sample(field: .mShape, strength: 1,
            at: c.center + Point(c.radius.x * 0.9, 0)).displacement.y
        XCTAssertLessThan(abs(narrow), abs(peak) * 0.05)
        let tail = m.sample(field: .mShape, strength: 1,
            at: c.center + Point(0, c.radius.y * 0.75)).displacement.y
        XCTAssertLessThan(tail, 0)
        XCTAssertLessThan(abs(tail), abs(peak) * 0.25)
        XCTAssertEqual(m.sample(field: .mShape, strength: 1,
            at: c.center + Point(0, c.radius.y + 0.001)).displacement, .zero)
    }

    func testComponentAmplitudesCanBeAdjustedWithoutGlobalGain() throws {
        var p = BeautyMouthMShapeParameters.referenceCalibration
        let original = try model(parameters: p)
        p.lowerEdgePeak *= 0.5
        let lowerReduced = try model(parameters: p)
        let upper = Point(0, -0.10)
        XCTAssertEqual(original.sample(field: .mShape, strength: 1, at: upper).displacement,
                       lowerReduced.sample(field: .mShape, strength: 1, at: upper).displacement)
        let lower = try XCTUnwrap(original.configuration.mShape.lowerCenter).center
        XCTAssertEqual(lowerReduced.sample(field: .mShape, strength: 1, at: lower).displacement.y,
                       original.sample(field: .mShape, strength: 1, at: lower).displacement.y * 0.5,
                       accuracy: 1e-15)
    }

    func testOwnerPreferredProfileScalesSourceDisplacementAndCompleteDerivatives() throws {
        let calibration = BeautyMouthMShapeParameters.referenceCalibration
        let preference = BeautyMouthMShapeParameters.ownerPreferredCalibration
        XCTAssertEqual(calibration.profileGain, 1)
        XCTAssertEqual(preference.profileGain, 1.5)
        let original = try model(parameters: calibration)
        let enhanced = try model(parameters: preference)
        let firstProfile = original.configuration.mShape.profile
        let secondProfile = enhanced.configuration.mShape.profile
        XCTAssertEqual(firstProfile.knots.count, 11)
        XCTAssertEqual(secondProfile.knots.count, firstProfile.knots.count)
        for (a, b) in zip(firstProfile.knots, secondProfile.knots) {
            XCTAssertEqual(a.x, b.x)
            XCTAssertEqual(b.y, a.y * 1.5, accuracy: 1e-15)
        }
        XCTAssertEqual(secondProfile.maximumValue, firstProfile.maximumValue * 1.5, accuracy: 1e-15)
        XCTAssertEqual(secondProfile.maximumDerivative, firstProfile.maximumDerivative * 1.5, accuracy: 1e-14)
        // At identical source points the lower component is outside support.
        // These cover profile x transitions and both vertical feather terms.
        let points = [Point(0, -0.10), Point(0.045, -0.06), Point(0.09, 0.01),
                      Point(-0.23, -0.16), Point(0.40, 0)]
        for point in points {
            let a = original.sample(field: .mShape, strength: 1, at: point)
            let b = enhanced.sample(field: .mShape, strength: 1, at: point)
            for (first, second) in [(a.displacement, b.displacement),
                                    (a.gradientX, b.gradientX), (a.gradientY, b.gradientY)] {
                XCTAssertEqual(second.x, first.x * 1.5, accuracy: 1e-13)
                XCTAssertEqual(second.y, first.y * 1.5, accuracy: 1e-13)
            }
        }
    }

    func testOwnerPreferredProfileLeavesLowerFieldAndSourceProtectionUnchanged() throws {
        let original = try model(parameters: .referenceCalibration, protectedTop: -0.17)
        let enhanced = try model(parameters: .ownerPreferredCalibration, protectedTop: -0.17)
        let lower = try XCTUnwrap(original.configuration.mShape.lowerCenter)
        let enhancedLower = try XCTUnwrap(enhanced.configuration.mShape.lowerCenter)
        XCTAssertEqual(lower.center, enhancedLower.center)
        XCTAssertEqual(lower.radius, enhancedLower.radius)
        XCTAssertEqual(lower.vector, enhancedLower.vector)
        // The upper profile has ended throughout these local lower-edge points.
        let points = [lower.center, lower.center + Point(0.04, -0.04),
                      lower.center + Point(-0.03, 0.06),
                      lower.center + Point(0, lower.radius.y * 0.75)]
        for point in points {
            let a = original.sample(field: .mShape, strength: 1, at: point)
            let b = enhanced.sample(field: .mShape, strength: 1, at: point)
            XCTAssertEqual(a.displacement, b.displacement)
            XCTAssertEqual(a.gradientX, b.gradientX)
            XCTAssertEqual(a.gradientY, b.gradientY)
        }
        let source = try XCTUnwrap(original.configuration.mShape.sourceEnvelope)
        let enhancedSource = try XCTUnwrap(enhanced.configuration.mShape.sourceEnvelope)
        XCTAssertEqual(source.outerMin, enhancedSource.outerMin)
        XCTAssertEqual(source.outerMax, enhancedSource.outerMax)
        XCTAssertEqual(source.innerMin, enhancedSource.innerMin)
        XCTAssertEqual(source.innerMax, enhancedSource.innerMax)
        var unprotectedConfiguration = original.configuration
        unprotectedConfiguration.mShape.sourceEnvelope = nil
        let unprotected = try XCTUnwrap(Model(configuration: unprotectedConfiguration))
        XCTAssertGreaterThan(unprotected.sample(field: .mShape, strength: 1,
            at: Point(0, source.outerMin.y)).displacement.y, 0)
        for x in [-0.3, 0, 0.3] {
            for y in [source.outerMin.y, source.outerMin.y - 0.001] {
                for m in [original, enhanced] {
                    let s = m.sample(field: .mShape, strength: 1, at: Point(x, y))
                    XCTAssertEqual(s.displacement, .zero)
                    XCTAssertEqual(s.gradientX, .zero)
                    XCTAssertEqual(s.gradientY, .zero)
                }
            }
        }
    }

    func testClippedUpperTailRetainsFiniteFeatherAndFullLipPeak() throws {
        // A valid protection boundary truncates the requested upper tail.
        // Previously this gap produced a 1e-4W feather and about 135 of
        // unnecessary vertical derivative bound before endpoint admission.
        let m = try model(protectedTop: -0.17)
        let source = try XCTUnwrap(m.configuration.mShape.sourceEnvelope)
        XCTAssertEqual(source.outerMin.y, -0.17)
        XCTAssertGreaterThan(source.innerMin.y - source.outerMin.y, 0.02)
        XCTAssertLessThan(source.innerMin.y, -0.10)
        XCTAssertLessThan(source.gradientBounds.y, 50)
        let peak = m.sample(field: .mShape, strength: 1, at: Point(0, -0.10))
        XCTAssertEqual(peak.displacement.y, BeautyMouthMShapeParameters.referenceCalibration.centralPeak,
                       accuracy: 1e-15)
        let protected = m.sample(field: .mShape, strength: 1, at: Point(0, source.outerMin.y))
        XCTAssertEqual(protected.displacement, .zero)
        XCTAssertEqual(protected.gradientX, .zero)
        XCTAssertEqual(protected.gradientY, .zero)
    }

    func testSourceProtectionAndCompleteTransitionDerivatives() throws {
        let m = try model(curved: true)
        let source = try XCTUnwrap(m.configuration.mShape.sourceEnvelope)
        for x in [-0.7, -0.3, 0, 0.3, 0.7] {
            let protected = m.sample(field: .mShape, strength: 1, at: Point(x, source.outerMin.y))
            XCTAssertEqual(protected.displacement, .zero)
            XCTAssertEqual(protected.gradientX, .zero)
            XCTAssertEqual(protected.gradientY, .zero)
        }
        let points = [Point(-0.68, -0.18), Point(-0.28, -0.12), Point(0.06, 0.005),
                      Point(0.035, 0.21), Point(0, -0.28)]
        let epsilon = 1e-6
        let bounds = m.bounds(field: .mShape, strength: 1)
        for point in points {
            let actual = m.sample(field: .mShape, strength: 1, at: point)
            func displacement(_ p: Point) -> Point {
                m.sample(field: .mShape, strength: 1, at: p).displacement
            }
            let dx = (displacement(point + Point(epsilon, 0))
                      - displacement(point - Point(epsilon, 0))) / (2 * epsilon)
            let dy = (displacement(point + Point(0, epsilon))
                      - displacement(point - Point(0, epsilon))) / (2 * epsilon)
            XCTAssertEqual(actual.gradientX.x, dx.x, accuracy: 1e-7)
            XCTAssertEqual(actual.gradientX.y, dx.y, accuracy: 1e-7)
            XCTAssertEqual(actual.gradientY.x, dy.x, accuracy: 1e-7)
            XCTAssertEqual(actual.gradientY.y, dy.y, accuracy: 1e-7)
            XCTAssertLessThanOrEqual(hypot(actual.displacement.x, actual.displacement.y), bounds.maximumDisplacement)
            // M shape is vertical-only: the matrix norm is the row norm.
            XCTAssertLessThanOrEqual(hypot(actual.gradientX.y, actual.gradientY.y), bounds.maximumGradient)
        }
    }

    func testInvalidVariantFailsBeforeConfigurationEntersSharedModel() {
        func configuration(_ p: BeautyMouthMShapeParameters) -> Model.MShape? {
            p.configuration(upperDepth: 0.1, lowerDepth: 0.18, top: -0.1, bottom: 0.18, protectedTop: -0.45)
        }
        var p = BeautyMouthMShapeParameters.referenceCalibration
        p.reboundPosition = p.shoulderPosition
        XCTAssertNil(configuration(p))
        p = .referenceCalibration; p.lowerVerticalRadiusInLowerDepth = 0
        XCTAssertNil(configuration(p))
        p = .referenceCalibration; p.centralPeak = .nan
        XCTAssertNil(configuration(p))
        p = .referenceCalibration; p.centralPlateauHalfWidth = p.shoulderPosition
        XCTAssertNil(configuration(p))
        p = .referenceCalibration; p.centralShoulderRatio = 1.1
        XCTAssertNil(configuration(p))
        p = .referenceCalibration; p.profileGain = 0
        XCTAssertNil(configuration(p))
        p = .referenceCalibration; p.profileGain = .nan
        XCTAssertNil(configuration(p))
        p = .referenceCalibration
        XCTAssertNil(p.configuration(upperDepth: 0.1, lowerDepth: 0.18,
            top: -0.1, bottom: 0.18, protectedTop: -0.1))
    }
}
