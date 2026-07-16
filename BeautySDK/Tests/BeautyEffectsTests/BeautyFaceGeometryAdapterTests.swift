import XCTest
import BeautyDetection
@testable import BeautyEffects

final class BeautyFaceGeometryAdapterTests: XCTestCase {
    private let bounds = CoordinateRect(x: 0.10, y: 0.10, width: 0.80, height: 0.80)

    func testObservedContoursCanonicalizeAcrossWindingAndRetainSideIdentity() {
        let left = contour(x: 0.30, y: 0.40)
        let right = contour(x: 0.58, y: 0.40)
        let forward = observation(left: left, right: right)
        let reversed = observation(left: Array(left.reversed()), right: Array(right.reversed()))

        let first = BeautyFaceGeometryAdapter.makeGeometry(from: forward)
        let second = BeautyFaceGeometryAdapter.makeGeometry(from: reversed)

        XCTAssertEqual(first.leftEyeSupport, second.leftEyeSupport)
        XCTAssertEqual(first.rightEyeSupport, second.rightEyeSupport)
        XCTAssertEqual(first.leftEyeSupport?.side, .left)
        XCTAssertEqual(first.rightEyeSupport?.side, .right)
        XCTAssertEqual(first.leftEyeSupport?.contourEligible, true)
        XCTAssertEqual(first.rightEyeSupport?.contourEligible, true)
        XCTAssertEqual(first.leftEyeSupport?.upper, first.leftEyeSupport?.upper.sorted(by: pointOrder))
    }

    func testSpanAndSignedTiltAreWindingIndependentAndDeterministic() {
        let positive = tiltedContour(x: 0.30, y: 0.40, tilt: 0.04)
        let rotated = Array(positive.dropFirst(2)) + Array(positive.prefix(2))
        let first = BeautyFaceGeometryAdapter.makeGeometry(
            from: observation(left: positive, right: contour(x: 0.58, y: 0.40))
        )
        let second = BeautyFaceGeometryAdapter.makeGeometry(
            from: observation(left: Array(rotated.reversed()), right: contour(x: 0.58, y: 0.40))
        )

        XCTAssertEqual(first.leftEyeSupport?.span.x ?? 0, 0.16, accuracy: 0.000_001)
        XCTAssertEqual(first.leftEyeSupport?.span.y ?? 0, 0.12, accuracy: 0.000_001)
        XCTAssertEqual(first.leftEyeSupport?.span, second.leftEyeSupport?.span)
        XCTAssertEqual(first.leftEyeSupport?.tilt, second.leftEyeSupport?.tilt)
        XCTAssertGreaterThan(first.leftEyeSupport?.tilt ?? 0, 0)

        let negative = tiltedContour(x: 0.30, y: 0.40, tilt: -0.04)
        let negativeGeometry = BeautyFaceGeometryAdapter.makeGeometry(
            from: observation(left: negative, right: contour(x: 0.58, y: 0.40))
        )
        XCTAssertLessThan(negativeGeometry.leftEyeSupport?.tilt ?? 0, 0)
    }

    func testSideInvertedObservedPairFailsClosedBeforeContourUse() {
        let invalid = BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyeSupport: [
                BeautyObservedEyeSupport(side: .left, contour: contour(x: 0.58, y: 0.40)),
                BeautyObservedEyeSupport(side: .right, contour: contour(x: 0.30, y: 0.40))
            ],
            observedEyeOrder: .invalid
        )
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: invalid)
        XCTAssertTrue(geometry.leftEye.isEmpty)
        XCTAssertTrue(geometry.rightEye.isEmpty)
        XCTAssertNil(geometry.leftEyeSupport)
        XCTAssertNil(geometry.rightEyeSupport)
    }

    func testMissingOrDuplicateObservedSidesFailClosedWithoutDiscardingSafeDomains() {
        let left = BeautyObservedEyeSupport(side: .left, contour: contour(x: 0.30, y: 0.40))
        for supports in [[left], [left, left]] {
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(
                from: BeautyFaceObservation(
                    imageBounds: bounds,
                    landmarks: .complete,
                    observedEyeSupport: supports,
                    observedEyeOrder: .invalid
                )
            )
            XCTAssertTrue(geometry.leftEye.isEmpty)
            XCTAssertTrue(geometry.rightEye.isEmpty)
            XCTAssertFalse(geometry.nose.isEmpty)
        }
    }

    func testLockedPurePredicatesCoverExactInsideAndOutsideBoundaries() {
        XCTAssertFalse(BeautyFaceGeometryAdapter.contourWidthIsValid(0.039_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.contourWidthIsValid(0.04))
        XCTAssertTrue(BeautyFaceGeometryAdapter.contourWidthIsValid(0.040_001))
        XCTAssertTrue(BeautyFaceGeometryAdapter.contourWidthIsValid(0.499_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.contourWidthIsValid(0.50))
        XCTAssertFalse(BeautyFaceGeometryAdapter.contourWidthIsValid(0.500_001))

        XCTAssertFalse(BeautyFaceGeometryAdapter.contourHeightIsValid(0.009_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.contourHeightIsValid(0.01))
        XCTAssertTrue(BeautyFaceGeometryAdapter.contourHeightIsValid(0.010_001))
        XCTAssertTrue(BeautyFaceGeometryAdapter.contourHeightIsValid(0.299_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.contourHeightIsValid(0.30))
        XCTAssertFalse(BeautyFaceGeometryAdapter.contourHeightIsValid(0.300_001))

        XCTAssertFalse(BeautyFaceGeometryAdapter.contourAreaIsValid(0.000_399))
        XCTAssertFalse(BeautyFaceGeometryAdapter.contourAreaIsValid(0.0004))
        XCTAssertTrue(BeautyFaceGeometryAdapter.contourAreaIsValid(0.000_401))

        let inside = SIMD2<Float>(0.5, 0.5)
        XCTAssertTrue(BeautyFaceGeometryAdapter.pupilContainmentIsValid(inside, minX: 0.4, maxX: 0.6, minY: 0.4, maxY: 0.6))
        XCTAssertTrue(BeautyFaceGeometryAdapter.pupilContainmentIsValid(SIMD2(0.38, 0.5), minX: 0.4, maxX: 0.6, minY: 0.4, maxY: 0.6))
        XCTAssertFalse(BeautyFaceGeometryAdapter.pupilContainmentIsValid(SIMD2(0.379_999, 0.5), minX: 0.4, maxX: 0.6, minY: 0.4, maxY: 0.6))
        XCTAssertTrue(BeautyFaceGeometryAdapter.pupilContainmentIsValid(SIMD2(0.62, 0.5), minX: 0.4, maxX: 0.6, minY: 0.4, maxY: 0.6))
        XCTAssertFalse(BeautyFaceGeometryAdapter.pupilContainmentIsValid(SIMD2(0.620_001, 0.5), minX: 0.4, maxX: 0.6, minY: 0.4, maxY: 0.6))
        XCTAssertTrue(BeautyFaceGeometryAdapter.pupilContainmentIsValid(SIMD2(0.5, 0.38), minX: 0.4, maxX: 0.6, minY: 0.4, maxY: 0.6))
        XCTAssertFalse(BeautyFaceGeometryAdapter.pupilContainmentIsValid(SIMD2(0.5, 0.379_999), minX: 0.4, maxX: 0.6, minY: 0.4, maxY: 0.6))
        XCTAssertTrue(BeautyFaceGeometryAdapter.pupilContainmentIsValid(SIMD2(0.5, 0.62), minX: 0.4, maxX: 0.6, minY: 0.4, maxY: 0.6))
        XCTAssertFalse(BeautyFaceGeometryAdapter.pupilContainmentIsValid(SIMD2(0.5, 0.620_001), minX: 0.4, maxX: 0.6, minY: 0.4, maxY: 0.6))

        XCTAssertTrue(BeautyFaceGeometryAdapter.pupilEllipseOffsetIsValid(0.699_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.pupilEllipseOffsetIsValid(0.70))
        XCTAssertFalse(BeautyFaceGeometryAdapter.pupilEllipseOffsetIsValid(0.700_001))

        XCTAssertFalse(BeautyFaceGeometryAdapter.pairedRatioIsValid(0.499_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.pairedRatioIsValid(0.50))
        XCTAssertTrue(BeautyFaceGeometryAdapter.pairedRatioIsValid(0.500_001))
        XCTAssertTrue(BeautyFaceGeometryAdapter.pairedRatioIsValid(1.999_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.pairedRatioIsValid(2.00))
        XCTAssertFalse(BeautyFaceGeometryAdapter.pairedRatioIsValid(2.000_001))
    }

    func testPairedRatioFailureClearsPupilsOnlyAndRetainsBothContours() {
        let left = BeautyObservedEyeSupport(
            side: .left,
            contour: contour(x: 0.24, y: 0.40, width: 0.08),
            pupil: [CoordinatePoint(x: 0.28, y: 0.44)]
        )
        let right = BeautyObservedEyeSupport(
            side: .right,
            contour: contour(x: 0.58, y: 0.40, width: 0.20),
            pupil: [CoordinatePoint(x: 0.68, y: 0.44)]
        )
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: observation(left: left.contour, right: right.contour, pupils: (left.pupil, right.pupil)))
        XCTAssertTrue(geometry.leftEyeSupport?.contourEligible == true)
        XCTAssertTrue(geometry.rightEyeSupport?.contourEligible == true)
        XCTAssertFalse(geometry.leftEyeSupport?.pupilEligible == true)
        XCTAssertFalse(geometry.rightEyeSupport?.pupilEligible == true)
    }

    func testInvalidContoursFailClosedWithoutProxyFallback() {
        let malformed: [[CoordinatePoint]] = [
            [],
            Array(repeating: CoordinatePoint(x: 0.4, y: 0.4), count: 6),
            contour(x: 0.30, y: 0.40).map { CoordinatePoint(x: $0.x, y: .infinity) },
            contour(x: 0.30, y: 0.40).map { CoordinatePoint(x: 1.2, y: $0.y) },
            Array(contour(x: 0.30, y: 0.40).prefix(5)),
            contour(x: 0.30, y: 0.40) + [CoordinatePoint(x: 0.31, y: 0.41)] + Array(repeating: CoordinatePoint(x: 0.31, y: 0.41), count: 10)
        ]

        for contour in malformed {
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(
                from: observation(left: contour, right: self.contour(x: 0.58, y: 0.40))
            )
            XCTAssertTrue(geometry.leftEye.isEmpty)
            XCTAssertNil(geometry.leftEyeSupport)
            XCTAssertFalse(geometry.rightEye.isEmpty)
        }
    }

    func testInvalidPupilPreservesContourSupportAndDoesNotSynthesizePupil() {
        let left = BeautyObservedEyeSupport(
            side: .left,
            contour: contour(x: 0.30, y: 0.40),
            pupil: [CoordinatePoint(x: 0.10, y: 0.10)]
        )
        let right = BeautyObservedEyeSupport(
            side: .right,
            contour: contour(x: 0.58, y: 0.40),
            pupil: [CoordinatePoint(x: 0.62, y: 0.44)]
        )
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(imageBounds: bounds, landmarks: .complete, observedEyeSupport: [left, right], observedEyeOrder: .canonical)
        )

        XCTAssertTrue(geometry.leftEyeSupport?.contourEligible == true)
        XCTAssertFalse(geometry.leftEyeSupport?.pupilEligible == true)
        XCTAssertTrue(geometry.rightEyeSupport?.contourEligible == true)
        XCTAssertTrue(geometry.rightEyeSupport?.pupilEligible == true)
    }

    func testNilObservedSupportKeepsLegacyProxyOnlyForCompatibility() {
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(imageBounds: bounds, landmarks: .complete)
        )
        XCTAssertFalse(geometry.leftEye.isEmpty)
        XCTAssertFalse(geometry.rightEye.isEmpty)
        XCTAssertNil(geometry.leftEyeSupport)
        XCTAssertNil(geometry.rightEyeSupport)
    }

    private func observation(left: [CoordinatePoint], right: [CoordinatePoint], pupils: ([CoordinatePoint]?, [CoordinatePoint]?) = (nil, nil)) -> BeautyFaceObservation {
        BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyeSupport: [
                BeautyObservedEyeSupport(side: .left, contour: left, pupil: pupils.0),
                BeautyObservedEyeSupport(side: .right, contour: right, pupil: pupils.1)
            ],
            observedEyeOrder: .canonical
        )
    }

    private func contour(x: Double, y: Double, width: Double = 0.16, height: Double = 0.08) -> [CoordinatePoint] {
        [
            CoordinatePoint(x: x, y: y + 0.03),
            CoordinatePoint(x: x + width * 0.25, y: y),
            CoordinatePoint(x: x + width * 0.75, y: y),
            CoordinatePoint(x: x + width, y: y + height * 0.375),
            CoordinatePoint(x: x + width * 0.75, y: y + height),
            CoordinatePoint(x: x + width * 0.25, y: y + height),
        ]
    }

    private func tiltedContour(x: Double, y: Double, tilt: Double) -> [CoordinatePoint] {
        [
            CoordinatePoint(x: x, y: y + 0.03),
            CoordinatePoint(x: x + 0.04, y: y),
            CoordinatePoint(x: x + 0.12, y: y + tilt),
            CoordinatePoint(x: x + 0.16, y: y + 0.03 + tilt),
            CoordinatePoint(x: x + 0.12, y: y + 0.08 + tilt),
            CoordinatePoint(x: x + 0.04, y: y + 0.08),
        ]
    }

    private func pointOrder(_ lhs: SIMD2<Float>, _ rhs: SIMD2<Float>) -> Bool {
        lhs.x == rhs.x ? lhs.y < rhs.y : lhs.x < rhs.x
    }
}
