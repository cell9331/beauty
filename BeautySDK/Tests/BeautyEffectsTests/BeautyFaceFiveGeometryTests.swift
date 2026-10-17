import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// These source-geometry controls distinguish the five candidate mechanisms.
/// They validate signs, support and inverse mathematics, not reference likeness
/// or the as-yet-unobserved neutral/middle slider response.
final class BeautyFaceFiveGeometryTests: XCTestCase {
    private let width = 1200
    private let height = 1400
    private typealias Control = (WritableKeyPath<BeautyEffectiveStrengths, Float>, Float)
    private var controls: [Control] {
        [(\.templeFullness, BeautySafetyCaps.templeFullness),
         (\.cheekboneSlim, BeautySafetyCaps.cheekboneSlim),
         (\.chinLength, BeautySafetyCaps.chinLength),
         (\.chinTaper, BeautySafetyCaps.chinTaper),
         (\.faceVShape, BeautySafetyCaps.faceVShape)]
    }

    private func face(angle: Double = 0, origin: SIMD2<Double> = SIMD2(600, 450),
                      observedNose: Bool = true, dense: BeautyDenseFaceSupport? = nil) -> FaceGeometry {
        let x = SIMD2(cos(angle), sin(angle)), y = SIMD2(-sin(angle), cos(angle))
        func normalized(_ p: SIMD2<Double>) -> SIMD2<Float> {
            let pixel = origin + 200 * (x * p.x + y * p.y)
            return SIMD2(Float((pixel.x + 0.5) / Double(width)), Float((pixel.y + 0.5) / Double(height)))
        }
        func box(_ center: SIMD2<Double>, _ radius: SIMD2<Double>) -> [SIMD2<Float>] {
            [center + SIMD2(-radius.x, -radius.y), center + SIMD2(radius.x, -radius.y),
             center + SIMD2(radius.x, radius.y), center + SIMD2(-radius.x, radius.y)].map(normalized)
        }
        let contour = (0..<21).map { index in
            let angle = Double(index) / 20 * Double.pi
            return normalized(SIMD2(-1.10 * cos(angle), 1.80 * sin(angle)))
        }
        func eye(_ side: BeautyObservedEyeSide, _ center: SIMD2<Double>) -> BeautyEyeSemanticSupport {
            let path = box(center, SIMD2(0.22, 0.085))
            return BeautyEyeSemanticSupport(side: side, contour: path,
                upper: Array(path.prefix(2)), lower: Array(path.suffix(2)),
                inner: [path[0]], outer: [path[1]], corners: [path[0], path[1]],
                center: normalized(center), pupil: normalized(center), span: SIMD2(0.074, 0.025), tilt: 0)
        }
        let left = eye(.left, SIMD2(-0.5, 0)), right = eye(.right, SIMD2(0.5, 0))
        let lips = box(SIMD2(0, 1.10), SIMD2(0.30, 0.08))
        func coordinate(_ p: SIMD2<Double>) -> CoordinatePoint {
            let point = normalized(p)
            return CoordinatePoint(x: Double(point.x), y: Double(point.y))
        }
        let nose = BeautyObservedNoseSupport(
            crest: [SIMD2(0.0, 0.20), SIMD2(0, 0.40), SIMD2(0, 0.65)].map(coordinate),
            contour: [SIMD2(-0.2, 0.65), SIMD2(0, 0.75), SIMD2(0.2, 0.65)].map(coordinate))
        return FaceGeometry(bounds: FaceBounds(x: 0.25, y: 0.20, width: 0.50, height: 0.50),
            faceContour: contour,
            observedFaceSupport: BeautyFaceSemanticSupport(contour: contour, medianLine: nil, apexIndex: 10),
            leftEye: left.contour, rightEye: right.contour, outerLips: lips,
            leftEyeSupport: left, rightEyeSupport: right, observedOuterLips: lips,
            observedNoseSupport: observedNose ? nose : nil, denseSupport: dense)
    }

    private func geometry(_ source: FaceGeometry? = nil) throws -> BeautyFaceDisplacementGeometry {
        try XCTUnwrap(BeautyFaceDisplacementGeometry(width: width, height: height, face: source ?? face()))
    }

    private func request(_ key: WritableKeyPath<BeautyEffectiveStrengths, Float>,
                         _ amount: Float) -> BeautyEffectiveStrengths {
        var values = BeautyEffectiveStrengths(); values[keyPath: key] = amount
        return values
    }

    private func vectorEqual(_ actual: SIMD2<Double>, _ expected: SIMD2<Double>,
                             accuracy: Double = 1e-6, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(actual.x, expected.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(actual.y, expected.y, accuracy: accuracy, file: file, line: line)
    }

    func testTempleExpandsAndRisesWithPositionDependentRadialDirection() throws {
        let source = try geometry()
        let field = try XCTUnwrap(source.model(strengths: request(\.templeFullness, BeautySafetyCaps.templeFullness)))
        let upper = field.sample(at: SIMD2(-1.10, -0.05)).displacement
        let lower = field.sample(at: SIMD2(-1.10, 0.15)).displacement
        let right = field.sample(at: SIMD2(1.10, -0.05)).displacement
        XCTAssertLessThan(upper.x, 0); XCTAssertLessThan(upper.y, 0)
        XCTAssertGreaterThan(right.x, 0); XCTAssertLessThan(right.y, 0)
        // A constant slant or horizontal-only field cannot satisfy this ratio.
        XCTAssertGreaterThan(abs(upper.y / upper.x), abs(lower.y / lower.x))
        let browTail = field.sample(at: SIMD2(-0.78, -0.20)).displacement
        XCTAssertLessThan(browTail.x, 0); XCTAssertLessThan(browTail.y, 0)
        for point in [SIMD2(-0.5, 0), SIMD2(0.5, 0), SIMD2(0, 0.55), SIMD2(0, 1.10), SIMD2(0, 1.80)] {
            vectorEqual(field.sample(at: point).displacement, .zero, accuracy: 0)
        }
    }

    func testCheekContractsHorizontallyAndChangesVerticalSignAcrossItsAnchor() throws {
        let field = try XCTUnwrap(try geometry().model(strengths: request(\.cheekboneSlim, BeautySafetyCaps.cheekboneSlim)))
        let upper = field.sample(at: SIMD2(-1.0, 0.10)).displacement
        let lower = field.sample(at: SIMD2(-1.0, 0.55)).displacement
        let right = field.sample(at: SIMD2(1.0, 0.55)).displacement
        XCTAssertGreaterThan(upper.x, 0); XCTAssertGreaterThan(upper.y, 0)
        XCTAssertGreaterThan(lower.x, 0); XCTAssertLessThan(lower.y, 0)
        XCTAssertLessThan(right.x, 0); XCTAssertLessThan(right.y, 0)
        XCTAssertGreaterThan(field.sample(at: SIMD2(-0.80, 0.10)).displacement.x, 0)
        for point in [SIMD2(-0.5, 0), SIMD2(0.5, 0), SIMD2(0, 0.55), SIMD2(0, 1.80)] {
            vectorEqual(field.sample(at: point).displacement, .zero, accuracy: 0)
        }
    }

    func testChinLengthHasIndependentUpperIngressPlateauAndLowerRelease() throws {
        let source = try geometry()
        let negative = try XCTUnwrap(source.model(strengths: request(\.chinLength, -BeautySafetyCaps.chinLength)))
        let first = negative.sample(at: SIMD2(0, 1.67)).displacement
        let last = negative.sample(at: SIMD2(0, 1.72)).displacement
        let upper = negative.sample(at: SIMD2(0, 1.30)).displacement
        let neck = negative.sample(at: SIMD2(0, 2.10)).displacement
        XCTAssertLessThan(first.y, 0)
        vectorEqual(first, last, accuracy: 1e-9)
        XCTAssertLessThan(abs(upper.y), abs(first.y))
        XCTAssertLessThan(abs(neck.y), abs(first.y)); XCTAssertLessThan(neck.y, 0)
        // The initial k=0 baseline has no unsupported horizontal contraction.
        XCTAssertEqual(negative.sample(at: SIMD2(0.30, 1.70)).displacement.x, 0)
        XCTAssertLessThan(negative.sample(at: SIMD2(0.15, 1.20)).displacement.y, 0)
        vectorEqual(negative.sample(at: SIMD2(0, 2.60)).displacement, .zero, accuracy: 0)
        let positive = try XCTUnwrap(source.model(strengths: request(\.chinLength, BeautySafetyCaps.chinLength)))
        vectorEqual(positive.sample(at: SIMD2(0, 1.67)).displacement, -first, accuracy: 1e-12)
    }

    func testChinTaperHasTwoInwardUpwardPeaksAndNonzeroCentralTail() throws {
        let source = try geometry()
        let field = try XCTUnwrap(source.model(strengths: request(\.chinTaper, BeautySafetyCaps.chinTaper)))
        let left = field.sample(at: SIMD2(-0.30, 1.73)).displacement
        let right = field.sample(at: SIMD2(0.30, 1.73)).displacement
        let center = field.sample(at: SIMD2(0, 1.80)).displacement
        XCTAssertGreaterThan(left.x, 0); XCTAssertLessThan(left.y, 0)
        XCTAssertLessThan(right.x, 0); XCTAssertLessThan(right.y, 0)
        XCTAssertLessThan(center.y, 0)
        XCTAssertEqual(center.x, 0, accuracy: 1e-8)
        XCTAssertGreaterThan(abs(left.y), abs(center.y) * 2)
        XCTAssertGreaterThan(abs(right.y), abs(center.y) * 2)
        vectorEqual(field.sample(at: SIMD2(0, 1.10)).displacement, .zero, accuracy: 0)
        vectorEqual(field.sample(at: SIMD2(0, 2.30)).displacement, .zero, accuracy: 0)
        let reverse = try XCTUnwrap(source.model(strengths: request(\.chinTaper, -BeautySafetyCaps.chinTaper)))
        vectorEqual(reverse.sample(at: SIMD2(-0.30, 1.73)).displacement, -left, accuracy: 1e-12)
    }

    func testChinTaperStaysInLowerChinWithoutPullingUpperLateralJaw() throws {
        let field = try XCTUnwrap(try geometry().model(strengths: request(\.chinTaper, BeautySafetyCaps.chinTaper)))
        let tip = field.sample(at: SIMD2(0, 1.80)).displacement
        XCTAssertLessThan(tip.y, 0)
        // These probes are fixed anatomical partitions of the synthetic face,
        // independent of the mode centres. The earlier, higher scope pulled
        // both upper flanks and the region beneath the lower lip too strongly.
        for point in [SIMD2(-0.80, 1.40), SIMD2(0.80, 1.40), SIMD2(0, 1.30)] {
            vectorEqual(field.sample(at: point).displacement, .zero, accuracy: 0)
        }
        let upperCentral = field.sample(at: SIMD2(0, 1.40)).displacement
        XCTAssertLessThan(abs(upperCentral.y), abs(tip.y) * 0.10)
        for point in [SIMD2(-0.30, 1.73), SIMD2(0.30, 1.73)] {
            XCTAssertGreaterThan(abs(field.sample(at: point).displacement.y), abs(tip.y) * 2)
        }
    }

    func testVConvergesInTwoDimensionsAndKeepsChinTailAndMouthCornerMotion() throws {
        let field = try XCTUnwrap(try geometry().model(strengths: request(\.faceVShape, BeautySafetyCaps.faceVShape)))
        let left = field.sample(at: SIMD2(-0.66, 1.415)).displacement
        let right = field.sample(at: SIMD2(0.66, 1.415)).displacement
        let center = field.sample(at: SIMD2(0, 1.80)).displacement
        XCTAssertGreaterThan(left.x, 0); XCTAssertLessThan(left.y, 0)
        XCTAssertLessThan(right.x, 0); XCTAssertLessThan(right.y, 0)
        XCTAssertLessThan(center.y, 0); XCTAssertLessThan(abs(center.y), abs(left.y))
        XCTAssertEqual(center.x, 0, accuracy: 1e-8)
        vectorEqual(field.sample(at: SIMD2(0, 1.10)).displacement, .zero, accuracy: 0)
        let corner = field.sample(at: SIMD2(0.30, 1.13)).displacement
        XCTAssertGreaterThan(hypot(corner.x, corner.y), 0)
        vectorEqual(field.sample(at: SIMD2(0, 2.50)).displacement, .zero, accuracy: 0)
    }

    func testEachNewFieldHasFiniteCapZeroIdentityAndExactSignedResponse() throws {
        let source = try geometry()
        XCTAssertTrue(try XCTUnwrap(source.model(strengths: BeautyEffectiveStrengths())).isIdentity)
        for (key, cap) in controls {
            for invalid in [Float.nan, .infinity, -.infinity] {
                XCTAssertNil(source.model(strengths: request(key, invalid)))
            }
            let capped = try XCTUnwrap(source.model(strengths: request(key, cap)))
            let excessive = try XCTUnwrap(source.model(strengths: request(key, cap * 3)))
            for point in [SIMD2(-1.1, 0), SIMD2(-1, 0.7), SIMD2(-0.5, 1.6), SIMD2(0, 1.8)] {
                vectorEqual(capped.sample(at: point).displacement, excessive.sample(at: point).displacement, accuracy: 0)
            }
            vectorEqual(capped.sample(at: SIMD2(3, 3)).displacement, .zero, accuracy: 0)
        }
        XCTAssertTrue(try XCTUnwrap(source.model(strengths: request(\.faceVShape, -0.1))).isIdentity)
    }

    func testNewFieldSourceGeometryFollowsRollAndPoseBeforeCertification() throws {
        let full = try geometry(), rolled = try geometry(face(angle: 0.31))
        let points = (0..<478).map { index in
            SIMD3<Float>(0.2 + Float(index % 23) / 40, 0.15 + Float(index / 23) / 30, 0)
        }
        let cosine = 0.635, sine = sqrt(1 - cosine * cosine)
        let matrix = [cosine, 0, sine, 0, 0, 1, 0, 0, -sine, 0, cosine, 0, 0, 0, 0, 1].map(Float.init)
        let dense = BeautyDenseFaceSupport(mesh: try XCTUnwrap(BeautyFaceMesh(points: points, facialTransformation: matrix)))
        let half = try geometry(face(dense: dense))
        XCTAssertEqual(dense.geometryScale, 0.5, accuracy: 1e-6)
        for (key, cap) in controls {
            let strengths = request(key, cap * 0.025)
            let a = try XCTUnwrap(full.model(strengths: strengths))
            let b = try XCTUnwrap(rolled.model(strengths: strengths))
            let c = try XCTUnwrap(half.model(strengths: strengths))
            XCTAssertEqual(a.amplitudeScale, 1); XCTAssertEqual(c.amplitudeScale, 1)
            for point in [SIMD2(-1.1, 0), SIMD2(-1, 0.7), SIMD2(-0.5, 1.6), SIMD2(0, 1.8)] {
                vectorEqual(b.sample(at: point).displacement, a.sample(at: point).displacement, accuracy: 1e-7)
                vectorEqual(c.sample(at: point).displacement,
                            a.sample(at: point).displacement * Double(dense.geometryScale), accuracy: 1e-10)
                let target = point + a.sample(at: point).displacement
                let inverse = try XCTUnwrap(a.inverse(of: target, tolerance: 1e-10))
                vectorEqual(inverse, point, accuracy: 1e-9)
            }
        }
    }

    func testMissingNasalCoreOrTruncatedSupportRejectsWholeRequestedField() throws {
        let noNose = try geometry(face(observedNose: false))
        for (key, cap) in controls {
            XCTAssertNil(noNose.model(strengths: request(key, cap)))
        }
        let nearLeft = try geometry(face(origin: SIMD2(225, 450)))
        for key in [\BeautyEffectiveStrengths.templeFullness, \.cheekboneSlim] {
            XCTAssertNil(nearLeft.model(strengths: request(key, 0.20)))
        }
        let nearBottom = try geometry(face(origin: SIMD2(600, 1000)))
        for key in [\BeautyEffectiveStrengths.chinLength, \.chinTaper, \.faceVShape] {
            XCTAssertNil(nearBottom.model(strengths: request(key, 0.20)))
        }
    }
}
