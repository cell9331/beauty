import XCTest
import BeautyCore
import BeautyDetection
import CoreImage
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

    func testContourCardinalityUniquePointAndClosedUnitBoundaries() {
        for count in [5, 6, 7, 15, 16, 17] {
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(
                from: observation(
                    left: polygonContour(count: count, x: 0.30, y: 0.40),
                    right: contour(x: 0.58, y: 0.40)
                )
            )
            XCTAssertEqual(geometry.leftEyeSupport != nil, (6...16).contains(count), "count=\(count)")
        }

        let threeUnique = polygonContour(count: 6, x: 0.30, y: 0.40)
            .enumerated().map { index, point in index.isMultiple(of: 2) ? point : polygonContour(count: 6, x: 0.30, y: 0.40)[0] }
        XCTAssertNil(BeautyFaceGeometryAdapter.makeGeometry(from: observation(left: threeUnique, right: contour(x: 0.58, y: 0.40))).leftEyeSupport)

        let fourUnique = polygonContour(count: 6, x: 0.30, y: 0.40)
        XCTAssertNotNil(BeautyFaceGeometryAdapter.makeGeometry(from: observation(left: fourUnique, right: contour(x: 0.58, y: 0.40))).leftEyeSupport)

        let xEdgeContours = [
            polygonContour(count: 6, x: 0.00, y: 0.40, width: 0.32),
            polygonContour(count: 6, x: 0.68, y: 0.40, width: 0.32)
        ]
        for candidate in xEdgeContours {
            XCTAssertNotNil(BeautyFaceGeometryAdapter.makeGeometry(from: observation(left: candidate, right: contour(x: 0.58, y: 0.40))).leftEyeSupport)
        }
        let yEdgeContours = [
            polygonContour(count: 6, x: 0.30, y: 0.00, height: 0.16),
            polygonContour(count: 6, x: 0.30, y: 0.84, height: 0.16)
        ]
        for candidate in yEdgeContours {
            XCTAssertNotNil(BeautyFaceGeometryAdapter.makeGeometry(from: observation(left: candidate, right: contour(x: 0.58, y: 0.40))).leftEyeSupport)
        }
        for value in [-0.000_001, 1.000_001] {
            var candidate = contour(x: 0.30, y: 0.40)
            candidate[0] = CoordinatePoint(x: value, y: candidate[0].y)
            XCTAssertNil(BeautyFaceGeometryAdapter.makeGeometry(from: observation(left: candidate, right: contour(x: 0.58, y: 0.40))).leftEyeSupport)
        }
    }

    func testComposedContourWidthAndHeightBoundariesRemainIndependent() {
        for (relative, expected) in [
            (0.039_999, false), (0.040_001, true), (0.040_002, true),
            (0.499_999, true), (0.50, true), (0.500_001, false)
        ] {
            let width = Double(relative) * Double(bounds.width)
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(
                from: observation(left: contour(x: 0.50 - width / 2, y: 0.40, width: width, height: 0.08), right: contour(x: 0.58, y: 0.40))
            )
            XCTAssertEqual(geometry.leftEyeSupport != nil, expected, "width=\(relative)")
        }
        for (relative, expected) in [
            (0.0099, false), (0.010_001, true), (0.010_002, true),
            (0.299_999, true), (0.30, true), (0.300_001, false)
        ] {
            let height = Double(relative) * Double(bounds.height)
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(
                from: observation(left: contour(x: 0.30, y: 0.50 - height / 2, width: 0.16, height: height), right: contour(x: 0.58, y: 0.40))
            )
            XCTAssertEqual(geometry.leftEyeSupport != nil, expected, "height=\(relative)")
        }
    }

    func testPupilCardinalityAndComposedContainmentOffsetPrecedence() {
        let validContour = contour(x: 0.30, y: 0.40)
        for pupils in [
            [] as [CoordinatePoint],
            [CoordinatePoint(x: 0.38, y: 0.44)],
            [CoordinatePoint(x: 0.38, y: 0.44), CoordinatePoint(x: 0.39, y: 0.44)]
        ] {
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(
                from: observation(left: validContour, right: contour(x: 0.58, y: 0.40), pupils: (pupils, nil))
            )
            XCTAssertEqual(geometry.leftEyeSupport?.pupilEligible, pupils.count == 1)
        }

        // The expanded containment edge is accepted by the pure predicate,
        // but the stricter ellipse offset rejects it in composed validation.
        XCTAssertTrue(BeautyFaceGeometryAdapter.pupilContainmentIsValid(SIMD2(0.284, 0.44), minX: 0.30, maxX: 0.46, minY: 0.40, maxY: 0.48))
        let edge = BeautyFaceGeometryAdapter.makeGeometry(
            from: observation(
                left: validContour,
                right: contour(x: 0.58, y: 0.40),
                pupils: ([CoordinatePoint(x: 0.284, y: 0.44)], nil)
            )
        )
        XCTAssertFalse(edge.leftEyeSupport?.pupilEligible == true)
    }

    func testPairedWidthAndHeightRatioBoundariesAreIndependent() {
        let left = contour(x: 0.24, y: 0.40, width: 0.16, height: 0.08)
        for (rightWidth, expected) in [(0.36, false), (0.32, true), (0.16, true), (0.08, true), (0.07, false)] {
            let right = contour(x: 0.58, y: 0.40, width: rightWidth, height: 0.08)
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(
                from: observation(
                    left: left,
                    right: right,
                    pupils: ([CoordinatePoint(x: 0.32, y: 0.44)], [CoordinatePoint(x: 0.58 + rightWidth / 2, y: 0.44)])
                )
            )
            XCTAssertEqual(geometry.leftEyeSupport?.pupilEligible, expected)
            XCTAssertEqual(geometry.rightEyeSupport?.pupilEligible, expected)
        }

        let tallRight = contour(x: 0.58, y: 0.30, width: 0.16, height: 0.20)
        let heightGeometry = BeautyFaceGeometryAdapter.makeGeometry(
            from: observation(
                left: left,
                right: tallRight,
                pupils: ([CoordinatePoint(x: 0.32, y: 0.44)], [CoordinatePoint(x: 0.66, y: 0.43)])
            )
        )
        XCTAssertFalse(heightGeometry.leftEyeSupport?.pupilEligible == true)
        XCTAssertFalse(heightGeometry.rightEyeSupport?.pupilEligible == true)
        XCTAssertTrue(heightGeometry.leftEyeSupport?.contourEligible == true)
        XCTAssertTrue(heightGeometry.rightEyeSupport?.contourEligible == true)
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

    func testObservedFaceEnvelopeKeepsContourAndMedianAbsenceIndependent() {
        let contour = faceOpenContour(count: 7)
        let median = faceMedianLine(count: 3)
        let neither = BeautyObservedFaceSupport()
        let contourOnly = BeautyObservedFaceSupport(contour: contour)
        let medianOnly = BeautyObservedFaceSupport(medianLine: median)
        let both = BeautyObservedFaceSupport(contour: contour, medianLine: median)
        let observation = BeautyFaceObservation(observedFaceSupport: both)

        XCTAssertNil(neither.contour)
        XCTAssertNil(neither.medianLine)
        XCTAssertEqual(contourOnly.contour, contour)
        XCTAssertNil(contourOnly.medianLine)
        XCTAssertNil(medianOnly.contour)
        XCTAssertEqual(medianOnly.medianLine, median)
        XCTAssertEqual(both.contour, contour)
        XCTAssertEqual(both.medianLine, median)
        XCTAssertEqual(observation.observedFaceSupport, both)
        assertSendable(neither)
        assertSendable(observation)
    }

    func testSemanticFaceSupportSeparatesContourAndCenterlineEligibility() {
        let contour = faceOpenContour(count: 7).map {
            SIMD2<Float>(Float($0.x), Float($0.y))
        }
        let median = faceMedianLine(count: 3).map {
            SIMD2<Float>(Float($0.x), Float($0.y))
        }
        let contourOnly = BeautyFaceSemanticSupport(
            contour: contour,
            medianLine: nil,
            apexIndex: nil
        )
        let complete = BeautyFaceSemanticSupport(
            contour: contour,
            medianLine: median,
            apexIndex: 3
        )
        let missingApex = BeautyFaceSemanticSupport(
            contour: contour,
            medianLine: median,
            apexIndex: nil
        )
        let empty = BeautyFaceSemanticSupport(
            contour: [],
            medianLine: median,
            apexIndex: 0
        )

        XCTAssertTrue(contourOnly.contourEligible)
        XCTAssertFalse(contourOnly.centerlineEligible)
        XCTAssertTrue(complete.contourEligible)
        XCTAssertTrue(complete.centerlineEligible)
        XCTAssertFalse(missingApex.centerlineEligible)
        XCTAssertFalse(empty.contourEligible)
        XCTAssertFalse(empty.centerlineEligible)
        assertSendable(complete)
    }

    func testFaceGeometryDefaultsObservedSupportToNilAndStoresItSeparately() {
        let proxy = [
            SIMD2<Float>(0.14, 0.34),
            SIMD2<Float>(0.196, 0.564),
            SIMD2<Float>(0.324, 0.772),
            SIMD2<Float>(0.50, 0.852),
            SIMD2<Float>(0.676, 0.772),
            SIMD2<Float>(0.804, 0.564),
            SIMD2<Float>(0.86, 0.34),
        ]
        let support = BeautyFaceSemanticSupport(
            contour: faceOpenContour(count: 7).map {
                SIMD2<Float>(Float($0.x), Float($0.y))
            },
            medianLine: nil,
            apexIndex: nil
        )
        let legacy = FaceGeometry(
            bounds: FaceBounds(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
            faceContour: proxy
        )
        let observed = FaceGeometry(
            bounds: legacy.bounds,
            faceContour: proxy,
            observedFaceSupport: support
        )

        XCTAssertNil(legacy.observedFaceSupport)
        XCTAssertEqual(observed.faceContour, proxy)
        XCTAssertEqual(observed.observedFaceSupport, support)
        XCTAssertNotEqual(observed.faceContour, support.contour)
    }

    func testLegacySevenPointFaceContourRemainsExact() {
        let geometry = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(imageBounds: bounds, landmarks: .complete)
        )
        let x = Float(bounds.x)
        let y = Float(bounds.y)
        let width = Float(bounds.width)
        let height = Float(bounds.height)
        func point(_ xFactor: Float, _ yFactor: Float) -> SIMD2<Float> {
            SIMD2<Float>(x + width * xFactor, y + height * yFactor)
        }
        XCTAssertEqual(
            geometry.faceContour,
            [
                point(0.05, 0.30),
                point(0.12, 0.58),
                point(0.28, 0.84),
                point(0.50, 0.94),
                point(0.72, 0.84),
                point(0.88, 0.58),
                point(0.95, 0.30),
            ]
        )
        XCTAssertNil(geometry.observedFaceSupport)
    }

    func testSmallFaceBoundsUseExactDimensionsForObservedValidationWithoutChangingLegacyProxy() {
        let smallBounds = CoordinateRect(x: 0.40, y: 0.35, width: 0.02, height: 0.03)
        func imagePoint(_ x: Double, _ y: Double) -> CoordinatePoint {
            CoordinatePoint(
                x: smallBounds.x + smallBounds.width * x,
                y: smallBounds.y + smallBounds.height * y
            )
        }
        let contour = faceOpenContour(count: 7).map {
            imagePoint(($0.x - 0.10) / 0.80, ($0.y - 0.15) / 0.60)
        }
        let median = faceMedianLine(count: 3).map {
            imagePoint($0.x, ($0.y - 0.20) / 0.60)
        }

        let geometry = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(
                imageBounds: smallBounds,
                landmarks: .complete,
                observedFaceSupport: BeautyObservedFaceSupport(
                    contour: contour,
                    medianLine: median
                )
            )
        )

        XCTAssertTrue(geometry.observedFaceSupport?.contourEligible == true)
        XCTAssertTrue(geometry.observedFaceSupport?.centerlineEligible == true)
        XCTAssertEqual(geometry.bounds.width, 0.05)
        XCTAssertEqual(geometry.bounds.height, 0.05)
        XCTAssertEqual(geometry.faceContour.count, 7)
        XCTAssertEqual(geometry.faceContour.first, SIMD2<Float>(0.4025, 0.365))
        XCTAssertEqual(geometry.faceContour.last, SIMD2<Float>(0.4475, 0.365))
    }

    func testFaceSupportFixturesLockCountsAndTopologyThresholdMatrices() {
        XCTAssertEqual(
            faceContourCardinalityMatrix.map(\.count),
            [6, 7, 8, 31, 32, 33]
        )
        XCTAssertEqual(
            faceContourCardinalityMatrix.map(\.eligible),
            [false, true, true, true, true, false]
        )
        XCTAssertEqual(
            faceMedianCardinalityMatrix.map(\.count),
            [2, 3, 4, 15, 16, 17]
        )
        XCTAssertEqual(
            faceMedianCardinalityMatrix.map(\.eligible),
            [false, true, true, true, true, false]
        )

        for entry in faceContourCardinalityMatrix {
            let fixture = FaceSupportFixture(
                contour: faceOpenContour(count: entry.count),
                medianLine: faceMedianLine(count: 3)
            )
            XCTAssertEqual(fixture.contour.count, entry.count)
            XCTAssertTrue(allPointsAreUnique(fixture.contour))
            XCTAssertNotEqual(fixture.contour.first, fixture.contour.last)
        }
        for entry in faceMedianCardinalityMatrix {
            let fixture = FaceSupportFixture(
                contour: faceOpenContour(count: 7),
                medianLine: faceMedianLine(count: entry.count)
            )
            XCTAssertEqual(fixture.medianLine.count, entry.count)
            XCTAssertTrue(allPointsAreUnique(fixture.medianLine))
        }

        XCTAssertEqual(Set(faceTopologyBoundaryMatrix.map(\.rule)).count, 12)
        for rule in Set(faceTopologyBoundaryMatrix.map(\.rule)) {
            let probes = faceTopologyBoundaryMatrix.filter { $0.rule == rule }
            XCTAssertTrue(probes.contains(where: { $0.position == .inside && $0.eligible }))
            XCTAssertTrue(probes.contains(where: { $0.position == .equal && $0.eligible }))
            XCTAssertTrue(probes.contains(where: { $0.position == .outside && !$0.eligible }))
        }
    }

    func testFaceOpenPathPurePredicatesLockInclusiveNumericBoundaries() {
        XCTAssertFalse(BeautyFaceGeometryAdapter.faceContourWidthIsValid(0.499_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceContourWidthIsValid(0.50))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceContourWidthIsValid(0.500_001))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceContourWidthIsValid(0.999_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceContourWidthIsValid(1.00))
        XCTAssertFalse(BeautyFaceGeometryAdapter.faceContourWidthIsValid(1.000_001))

        XCTAssertFalse(BeautyFaceGeometryAdapter.faceContourHeightIsValid(0.199_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceContourHeightIsValid(0.20))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceContourHeightIsValid(0.200_001))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceContourHeightIsValid(0.999_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceContourHeightIsValid(1.00))
        XCTAssertFalse(BeautyFaceGeometryAdapter.faceContourHeightIsValid(1.000_001))

        XCTAssertFalse(BeautyFaceGeometryAdapter.faceEndpointSeparationIsValid(0.349_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceEndpointSeparationIsValid(0.35))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceEndpointSeparationIsValid(0.350_001))

        XCTAssertFalse(BeautyFaceGeometryAdapter.faceCurvatureIsValid(0.099_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceCurvatureIsValid(0.10))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceCurvatureIsValid(0.100_001))

        XCTAssertFalse(BeautyFaceGeometryAdapter.faceMedianDownIsValid(0.249_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceMedianDownIsValid(0.25))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceMedianDownIsValid(0.250_001))

        XCTAssertFalse(BeautyFaceGeometryAdapter.faceDirectionMagnitudeIsValid(0.000_000_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceDirectionMagnitudeIsValid(0.000_001))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceDirectionMagnitudeIsValid(0.000_001_001))
        XCTAssertFalse(BeautyFaceGeometryAdapter.faceDirectionMagnitudeIsValid(.nan))
        XCTAssertFalse(BeautyFaceGeometryAdapter.faceDirectionMagnitudeIsValid(.infinity))
    }

    func testFaceOpenPathCardinalityUniquenessAndBoundsRejectMalformedInput() {
        let faceBounds = FaceBounds(x: 0.10, y: 0.10, width: 0.80, height: 0.80)
        for entry in faceContourCardinalityMatrix {
            let validated = BeautyFaceGeometryAdapter.validatedFaceContour(
                faceOpenContour(count: entry.count),
                bounds: faceBounds
            )
            XCTAssertEqual(validated != nil, entry.eligible, "contour count=\(entry.count)")
        }
        for entry in faceMedianCardinalityMatrix {
            let validated = BeautyFaceGeometryAdapter.validatedFaceMedianLine(
                faceMedianLine(count: entry.count),
                bounds: faceBounds
            )
            XCTAssertEqual(validated != nil, entry.eligible, "median count=\(entry.count)")
        }

        let validContour = faceOpenContour(count: 7)
        let validMedian = faceMedianLine(count: 3)
        var adjacentDuplicate = validContour
        adjacentDuplicate[1] = adjacentDuplicate[0]
        var repeatedEndpoint = validContour
        repeatedEndpoint[repeatedEndpoint.count - 1] = repeatedEndpoint[0]
        var nonFinite = validContour
        nonFinite[3] = CoordinatePoint(x: .nan, y: nonFinite[3].y)
        var outside = validContour
        outside[3] = CoordinatePoint(x: 1.000_001, y: outside[3].y)
        let identical = Array(repeating: CoordinatePoint(x: 0.50, y: 0.50), count: 7)
        let collinear = (0..<7).map { index in
            CoordinatePoint(x: 0.10 + 0.80 * Double(index) / 6, y: 0.50)
        }

        for malformed in [
            adjacentDuplicate,
            repeatedEndpoint,
            nonFinite,
            outside,
            identical,
            collinear,
        ] {
            XCTAssertNil(
                BeautyFaceGeometryAdapter.validatedFaceContour(malformed, bounds: faceBounds)
            )
        }

        var duplicateMedian = validMedian
        duplicateMedian[1] = duplicateMedian[0]
        let horizontalMedian = [
            CoordinatePoint(x: 0.30, y: 0.50),
            CoordinatePoint(x: 0.50, y: 0.50),
            CoordinatePoint(x: 0.70, y: 0.50),
        ]
        for malformed in [duplicateMedian, horizontalMedian] {
            XCTAssertNil(
                BeautyFaceGeometryAdapter.validatedFaceMedianLine(malformed, bounds: faceBounds)
            )
        }
    }

    func testFaceOpenPathValidationPreservesCanonicalAdjacencyAndRejectsReversedDirection() throws {
        let faceBounds = FaceBounds(x: 0.10, y: 0.10, width: 0.80, height: 0.80)
        let contour = faceOpenContour(count: 17)
        let median = faceMedianLine(count: 10)
        let reversedContour = Array(contour.reversed())
        let reversedMedian = Array(median.reversed())

        XCTAssertEqual(
            try XCTUnwrap(
                BeautyFaceGeometryAdapter.validatedFaceContour(contour, bounds: faceBounds)
            ),
            contour.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        )
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedFaceContour(
                reversedContour,
                bounds: faceBounds
            )
        )
        XCTAssertEqual(
            try XCTUnwrap(
                BeautyFaceGeometryAdapter.validatedFaceMedianLine(median, bounds: faceBounds)
            ),
            median.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        )
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedFaceMedianLine(
                reversedMedian,
                bounds: faceBounds
            )
        )
    }

    func testFaceContourRejectsNonAdjacentSegmentIntersections() {
        let faceBounds = FaceBounds(x: 0.10, y: 0.10, width: 0.80, height: 0.80)
        let bowTie = [
            CoordinatePoint(x: 0.10, y: 0.15),
            CoordinatePoint(x: 0.70, y: 0.70),
            CoordinatePoint(x: 0.25, y: 0.70),
            CoordinatePoint(x: 0.75, y: 0.25),
            CoordinatePoint(x: 0.30, y: 0.25),
            CoordinatePoint(x: 0.50, y: 0.75),
            CoordinatePoint(x: 0.90, y: 0.15),
        ]
        let zigzag = [
            CoordinatePoint(x: 0.10, y: 0.15),
            CoordinatePoint(x: 0.75, y: 0.65),
            CoordinatePoint(x: 0.20, y: 0.55),
            CoordinatePoint(x: 0.80, y: 0.25),
            CoordinatePoint(x: 0.25, y: 0.70),
            CoordinatePoint(x: 0.70, y: 0.45),
            CoordinatePoint(x: 0.90, y: 0.15),
        ]

        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedFaceContour(
                bowTie,
                bounds: faceBounds
            )
        )
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedFaceContour(
                zigzag,
                bounds: faceBounds
            )
        )
        XCTAssertNotNil(
            BeautyFaceGeometryAdapter.validatedFaceContour(
                faceOpenContour(count: 7),
                bounds: faceBounds
            )
        )
    }

    func testSelfIntersectingMedianPreservesContourOnlyEligibility() {
        let contour = faceOpenContour(count: 7)
        let crossingMedian = [
            CoordinatePoint(x: 0.50, y: 0.20),
            CoordinatePoint(x: 0.20, y: 0.80),
            CoordinatePoint(x: 0.80, y: 0.80),
            CoordinatePoint(x: 0.20, y: 0.50),
            CoordinatePoint(x: 0.50, y: 0.80),
        ]

        let geometry = BeautyFaceGeometryAdapter.makeGeometry(
            from: faceObservation(
                support: BeautyObservedFaceSupport(
                    contour: contour,
                    medianLine: crossingMedian
                )
            )
        )

        XCTAssertTrue(geometry.observedFaceSupport?.contourEligible == true)
        XCTAssertFalse(geometry.observedFaceSupport?.centerlineEligible == true)
        XCTAssertNil(geometry.observedFaceSupport?.medianLine)
        XCTAssertNil(geometry.observedFaceSupport?.apexIndex)
    }

    func testInjectedSixCaseFaceSupportAggregateFitsLockedValidationEnvelope() {
        let fixtureDimensions: [(width: Double, height: Double)] = [
            (0.56, 0.48),
            (0.60, 0.50),
            (0.64, 0.52),
            (0.68, 0.54),
            (0.72, 0.56),
            (0.76, 0.58),
        ]

        for (index, dimensions) in fixtureDimensions.enumerated() {
            let contour = faceOpenContour(
                count: 7 + index,
                width: dimensions.width,
                height: dimensions.height
            )
            let median = faceMedianLine(count: 3 + index)
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(
                from: faceObservation(
                    support: BeautyObservedFaceSupport(
                        contour: contour,
                        medianLine: median
                    )
                )
            )

            XCTAssertEqual(
                geometry.observedFaceSupport?.contour.count,
                contour.count,
                "fixture=\(index)"
            )
            XCTAssertEqual(
                geometry.observedFaceSupport?.medianLine?.count,
                median.count,
                "fixture=\(index)"
            )
            XCTAssertTrue(
                geometry.observedFaceSupport?.contourEligible == true,
                "fixture=\(index)"
            )
            XCTAssertTrue(
                geometry.observedFaceSupport?.centerlineEligible == true,
                "fixture=\(index)"
            )
        }
    }

    // Opt-in live Vision integration smoke. Standard unit runs skip before
    // any repository-local fixture discovery or Apple Vision invocation.
    func testIntegrationLocalAuthorizedPortraitAggregateFitsLockedFaceValidationEnvelope() throws {
        guard ProcessInfo.processInfo.environment[
            "BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS"
        ] == "1" else {
            throw XCTSkip(
                "Set BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS=1 on the pinned Apple Vision host"
            )
        }
        var detector = VisionFaceDetector()
        var completeSupportCount = 0
        var validatedSupportCount = 0
        var centerlineEligibleCount = 0

        for fixtureURL in try portraitFixtureURLs() {
            guard let image = CIImage(
                contentsOf: fixtureURL,
                options: [.applyOrientationProperty: true]
            ) else {
                throw FaceFixtureError.unreadable
            }
            let result = detector.detect(
                image: image,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                imageExtent: image.extent.size
            )
            for observation in result.observations {
                guard let support = observation.observedFaceSupport,
                      let contour = support.contour,
                      let median = support.medianLine,
                      let rect = observation.imageBounds
                else {
                    continue
                }
                completeSupportCount += 1
                let faceBounds = FaceBounds(
                    x: Float(rect.x),
                    y: Float(rect.y),
                    width: Float(rect.width),
                    height: Float(rect.height)
                )
                if BeautyFaceGeometryAdapter.validatedFaceContour(
                    contour,
                    bounds: faceBounds
                ) != nil,
                   BeautyFaceGeometryAdapter.validatedFaceMedianLine(
                       median,
                       bounds: faceBounds
                   ) != nil {
                    validatedSupportCount += 1
                }
                if BeautyFaceGeometryAdapter.makeGeometry(
                    from: observation
                ).observedFaceSupport?.centerlineEligible == true {
                    centerlineEligibleCount += 1
                }
            }
        }

        XCTAssertGreaterThan(completeSupportCount, 0, "expected observed aggregate support")
        XCTAssertEqual(validatedSupportCount, completeSupportCount, "aggregate validation mismatch")
        XCTAssertEqual(
            centerlineEligibleCount,
            completeSupportCount,
            "aggregate cross-support mismatch"
        )
    }

    func testIntegrationLocalAuthorizedPortraitFitsLockedEyebrowValidationEnvelope() throws {
        guard ProcessInfo.processInfo.environment[
            "BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS"
        ] == "1" else {
            throw XCTSkip(
                "Set BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS=1 on the pinned Apple Vision host"
            )
        }
        var detector = VisionFaceDetector()
        var observedPairCount = 0
        var validatedPairCount = 0

        for fixtureURL in try portraitFixtureURLs() {
            guard let image = CIImage(
                contentsOf: fixtureURL,
                options: [.applyOrientationProperty: true]
            ) else {
                throw FaceFixtureError.unreadable
            }
            let result = detector.detect(
                image: image,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                imageExtent: image.extent.size
            )
            for observation in result.observations {
                guard let support = observation.observedEyebrowSupport,
                      let left = support.left,
                      let right = support.right,
                      let rect = observation.imageBounds
                else {
                    continue
                }
                observedPairCount += 1
                let bounds = FaceBounds(
                    x: Float(rect.x),
                    y: Float(rect.y),
                    width: Float(rect.width),
                    height: Float(rect.height)
                )
                for (side, points) in [("left", left), ("right", right)] {
                    XCTAssertTrue((4...16).contains(points.count), "\(side): count")
                    XCTAssertTrue(
                        points.allSatisfy {
                            $0.isFinite && (0...1).contains($0.x) && (0...1).contains($0.y)
                        },
                        "\(side): finite unit points"
                    )
                    XCTAssertFalse(
                        BeautyFaceGeometryAdapter.browPathHasNonAdjacentIntersections(points),
                        "\(side): self intersection"
                    )
                    let local = points.map {
                        (
                            x: ($0.x - Double(bounds.x)) / Double(bounds.width),
                            y: ($0.y - Double(bounds.y)) / Double(bounds.height)
                        )
                    }
                    let chord = Float(abs(local.last!.x - local.first!.x))
                    let verticalSpan = Float(local.map(\.y).max()! - local.map(\.y).min()!)
                    XCTAssertTrue(
                        BeautyFaceGeometryAdapter.browChordIsValid(chord),
                        "\(side): chord envelope, normalizedChord=\(chord)"
                    )
                    XCTAssertTrue(
                        BeautyFaceGeometryAdapter.browVerticalSpanIsValid(verticalSpan),
                        "\(side): vertical envelope"
                    )
                }
                if BeautyFaceGeometryAdapter.makeGeometry(
                    from: observation
                ).observedEyebrowSupport?.pairedEligible == true {
                    validatedPairCount += 1
                }
            }
        }

        XCTAssertGreaterThan(observedPairCount, 0, "expected observed eyebrow pair")
        XCTAssertEqual(
            validatedPairCount,
            observedPairCount,
            "aggregate eyebrow validation mismatch"
        )
    }

    func testFaceCrossSupportPurePredicatesLockInclusiveBoundaries() {
        XCTAssertFalse(BeautyFaceGeometryAdapter.faceMedianChordPositionIsValid(0.149_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceMedianChordPositionIsValid(0.15))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceMedianChordPositionIsValid(0.150_001))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceMedianChordPositionIsValid(0.849_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceMedianChordPositionIsValid(0.85))
        XCTAssertFalse(BeautyFaceGeometryAdapter.faceMedianChordPositionIsValid(0.850_001))

        XCTAssertTrue(BeautyFaceGeometryAdapter.faceApexDistanceIsValid(0.399_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.faceApexDistanceIsValid(0.40))
        XCTAssertFalse(BeautyFaceGeometryAdapter.faceApexDistanceIsValid(0.400_001))

        XCTAssertFalse(
            BeautyFaceGeometryAdapter.faceApexInteriorPointsAreValid(before: 1, after: 3)
        )
        XCTAssertTrue(
            BeautyFaceGeometryAdapter.faceApexInteriorPointsAreValid(before: 2, after: 2)
        )
        XCTAssertTrue(
            BeautyFaceGeometryAdapter.faceApexInteriorPointsAreValid(before: 3, after: 3)
        )
        XCTAssertFalse(
            BeautyFaceGeometryAdapter.faceApexInteriorPointsAreValid(before: 3, after: 1)
        )
    }

    func testObservedFaceRegionPresenceCombinationsAttachIndependentEligibility() throws {
        let contour = faceOpenContour(count: 7)
        let median = faceMedianLine(count: 3)

        let absent = BeautyFaceGeometryAdapter.makeGeometry(
            from: faceObservation(support: nil)
        )
        let neither = BeautyFaceGeometryAdapter.makeGeometry(
            from: faceObservation(support: BeautyObservedFaceSupport())
        )
        let contourOnly = BeautyFaceGeometryAdapter.makeGeometry(
            from: faceObservation(
                support: BeautyObservedFaceSupport(contour: contour)
            )
        )
        let medianOnly = BeautyFaceGeometryAdapter.makeGeometry(
            from: faceObservation(
                support: BeautyObservedFaceSupport(medianLine: median)
            )
        )
        let complete = BeautyFaceGeometryAdapter.makeGeometry(
            from: faceObservation(
                support: BeautyObservedFaceSupport(contour: contour, medianLine: median)
            )
        )

        XCTAssertNil(absent.observedFaceSupport)
        XCTAssertNil(neither.observedFaceSupport)
        XCTAssertNil(medianOnly.observedFaceSupport)
        XCTAssertTrue(contourOnly.observedFaceSupport?.contourEligible == true)
        XCTAssertFalse(contourOnly.observedFaceSupport?.centerlineEligible == true)
        XCTAssertNil(contourOnly.observedFaceSupport?.medianLine)
        XCTAssertNil(contourOnly.observedFaceSupport?.apexIndex)
        XCTAssertTrue(complete.observedFaceSupport?.contourEligible == true)
        XCTAssertTrue(complete.observedFaceSupport?.centerlineEligible == true)
        XCTAssertEqual(complete.observedFaceSupport?.apexIndex, 3)
        XCTAssertEqual(
            try XCTUnwrap(complete.observedFaceSupport?.contour),
            contour.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        )
        XCTAssertEqual(
            try XCTUnwrap(complete.observedFaceSupport?.medianLine),
            median.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        )
    }

    func testMalformedFaceRegionsAndCrossSupportFailLocally() {
        let contour = faceOpenContour(count: 7)
        let median = faceMedianLine(count: 3)
        let invalidContour = (0..<7).map { index in
            CoordinatePoint(x: 0.10 + 0.80 * Double(index) / 6, y: 0.50)
        }
        let invalidMedian = [
            CoordinatePoint(x: 0.30, y: 0.50),
            CoordinatePoint(x: 0.50, y: 0.50),
            CoordinatePoint(x: 0.70, y: 0.50),
        ]
        let chordOutside = [
            CoordinatePoint(x: 0.18, y: 0.20),
            CoordinatePoint(x: 0.18, y: 0.50),
            CoordinatePoint(x: 0.18, y: 0.75),
        ]
        let apexTooFar = [
            CoordinatePoint(x: 0.50, y: 0.80),
            CoordinatePoint(x: 0.50, y: 0.60),
            CoordinatePoint(x: 0.50, y: 0.15),
        ]
        let edgeApex = [
            CoordinatePoint(x: contour[1].x, y: 0.15),
            CoordinatePoint(x: contour[1].x, y: 0.30),
            contour[1],
        ]

        let badContour = BeautyFaceGeometryAdapter.makeGeometry(
            from: faceObservation(
                support: BeautyObservedFaceSupport(
                    contour: invalidContour,
                    medianLine: median
                )
            )
        )
        XCTAssertNil(badContour.observedFaceSupport)

        for candidate in [invalidMedian, chordOutside, apexTooFar, edgeApex] {
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(
                from: faceObservation(
                    support: BeautyObservedFaceSupport(
                        contour: contour,
                        medianLine: candidate
                    )
                )
            )
            XCTAssertTrue(geometry.observedFaceSupport?.contourEligible == true)
            XCTAssertFalse(geometry.observedFaceSupport?.centerlineEligible == true)
            XCTAssertNil(geometry.observedFaceSupport?.medianLine)
            XCTAssertNil(geometry.observedFaceSupport?.apexIndex)
        }
    }

    func testObservedFaceSupportNeverChangesLegacyOrSiblingGeometry() {
        let baseline = BeautyFaceGeometryAdapter.makeGeometry(
            from: faceObservation(support: nil)
        )
        let observedContour = faceOpenContour(count: 7)
        let median = faceMedianLine(count: 3)
        let malformed = [
            nil,
            BeautyObservedFaceSupport(),
            BeautyObservedFaceSupport(medianLine: median),
            BeautyObservedFaceSupport(
                contour: Array(repeating: CoordinatePoint(x: 0.5, y: 0.5), count: 7),
                medianLine: median
            ),
            BeautyObservedFaceSupport(
                contour: observedContour,
                medianLine: [
                    CoordinatePoint(x: 0.3, y: 0.5),
                    CoordinatePoint(x: 0.5, y: 0.5),
                    CoordinatePoint(x: 0.7, y: 0.5),
                ]
            ),
            BeautyObservedFaceSupport(contour: observedContour, medianLine: median),
        ]

        for support in malformed {
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(
                from: faceObservation(support: support)
            )
            assertLegacyAndSiblingGeometryEqual(geometry, baseline)
        }

        let invalidEyeOrder = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(
                imageBounds: bounds,
                landmarks: .complete,
                observedEyeSupport: [
                    BeautyObservedEyeSupport(
                        side: .left,
                        contour: contour(x: 0.58, y: 0.40)
                    ),
                ],
                observedEyeOrder: .invalid,
                observedFaceSupport: BeautyObservedFaceSupport(
                    contour: observedContour,
                    medianLine: median
                )
            )
        )
        XCTAssertTrue(invalidEyeOrder.observedFaceSupport?.centerlineEligible == true)
        XCTAssertTrue(invalidEyeOrder.leftEye.isEmpty)
        XCTAssertTrue(invalidEyeOrder.rightEye.isEmpty)
        XCTAssertEqual(invalidEyeOrder.faceContour, baseline.faceContour)
        XCTAssertEqual(invalidEyeOrder.nose, baseline.nose)
        XCTAssertEqual(invalidEyeOrder.outerLips, baseline.outerLips)
    }

    func testEffectsFaceGeometryDiagnosticsExposeAggregateCountsOnly() {
        let sentinel = SIMD2<Float>(0.123_456, 0.234_567)
        let semanticSupport = BeautyFaceSemanticSupport(
            contour: Array(repeating: sentinel, count: 7),
            medianLine: Array(repeating: sentinel, count: 3),
            apexIndex: 2
        )
        let eyeSupport = BeautyEyeSemanticSupport(
            side: .left,
            contour: [sentinel],
            upper: [sentinel],
            lower: [sentinel],
            inner: [sentinel],
            outer: [sentinel],
            corners: [sentinel],
            center: sentinel,
            pupil: sentinel,
            span: sentinel,
            tilt: 0.345_678
        )
        let geometry = FaceGeometry(
            bounds: FaceBounds(
                x: 0.456_789,
                y: 0.567_891,
                width: 0.678_912,
                height: 0.789_123
            ),
            faceContour: [sentinel],
            observedFaceSupport: semanticSupport,
            leftEye: [sentinel],
            rightEye: [sentinel],
            nose: [sentinel],
            noseRoot: [sentinel],
            noseTip: [sentinel],
            outerLips: [sentinel],
            upperLips: [sentinel],
            lowerLips: [sentinel],
            innerLips: [sentinel],
            leftEyeSupport: eyeSupport,
            rightEyeSupport: eyeSupport
        )

        XCTAssertEqual(
            Mirror(reflecting: semanticSupport).children.compactMap(\.label),
            ["contourCount", "medianLineCount", "centerlineEligible"]
        )
        XCTAssertEqual(
            Mirror(reflecting: geometry).children.compactMap(\.label),
            [
                "landmarkPointCount",
                "observedEyeSupportCount",
                "observedFaceSupportAvailable",
                "observedFaceContourCount",
                "observedFaceMedianLineCount",
                "observedEyebrowSupportAvailable",
                "observedLeftEyebrowCount",
                "observedRightEyebrowCount",
                "observedEyebrowPairedEligible",
            ]
        )

        var semanticDump = ""
        var geometryDump = ""
        dump(semanticSupport, to: &semanticDump)
        dump(geometry, to: &geometryDump)

        for diagnostic in [
            String(describing: semanticSupport),
            String(reflecting: semanticSupport),
            semanticDump,
            String(describing: geometry),
            String(reflecting: geometry),
            geometryDump,
        ] {
            for prohibited in [
                "0.123456",
                "0.234567",
                "0.345678",
                "0.456789",
                "0.567891",
                "0.678912",
                "0.789123",
                "SIMD2",
                "FaceBounds",
                "apexIndex",
                "bounds",
            ] {
                XCTAssertFalse(
                    diagnostic.contains(prohibited),
                    "diagnostic leaked \(prohibited): \(diagnostic)"
                )
            }
        }
    }

    func testObservedFaceSupportIsStatelessAcrossAlternatingCalls() {
        let validObservation = faceObservation(
            support: BeautyObservedFaceSupport(
                contour: faceOpenContour(count: 7),
                medianLine: faceMedianLine(count: 3)
            )
        )
        let invalidObservation = faceObservation(
            support: BeautyObservedFaceSupport(
                contour: Array(
                    repeating: CoordinatePoint(x: 0.50, y: 0.50),
                    count: 7
                ),
                medianLine: faceMedianLine(count: 3)
            )
        )

        let first = BeautyFaceGeometryAdapter.makeGeometry(from: validObservation)
        let middle = BeautyFaceGeometryAdapter.makeGeometry(from: invalidObservation)
        let last = BeautyFaceGeometryAdapter.makeGeometry(from: validObservation)

        XCTAssertTrue(first.observedFaceSupport?.centerlineEligible == true)
        XCTAssertNil(middle.observedFaceSupport)
        XCTAssertEqual(last.observedFaceSupport, first.observedFaceSupport)
    }

    func testEyebrowSupportContractsPreserveIndependentAbsenceAndPairedEligibility() {
        let leftPoints = eyebrowTrace(side: .left)
        let raw = BeautyObservedEyebrowSupport(left: leftPoints, right: nil)
        XCTAssertEqual(raw.left, leftPoints)
        XCTAssertNil(raw.right)

        let left = semanticEyebrowTrace(side: .left)
        let right = semanticEyebrowTrace(side: .right)
        XCTAssertFalse(BeautyEyebrowSemanticSupport(left: left, right: nil).pairedEligible)
        XCTAssertTrue(BeautyEyebrowSemanticSupport(left: left, right: right).pairedEligible)
        XCTAssertFalse(BeautyEyebrowSemanticSupport(left: left, right: left).pairedEligible)
        assertSendable(raw)
        assertSendable(left)
    }

    func testEyebrowSupportDefaultsNilWithoutChangingLegacyGeometry() {
        let observation = BeautyFaceObservation(imageBounds: bounds, landmarks: .complete)
        XCTAssertNil(observation.observedEyebrowSupport)

        let baseline = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let explicit = FaceGeometry(
            bounds: baseline.bounds,
            faceContour: baseline.faceContour,
            observedFaceSupport: baseline.observedFaceSupport,
            leftEye: baseline.leftEye,
            rightEye: baseline.rightEye,
            nose: baseline.nose,
            noseRoot: baseline.noseRoot,
            noseTip: baseline.noseTip,
            outerLips: baseline.outerLips,
            upperLips: baseline.upperLips,
            lowerLips: baseline.lowerLips,
            innerLips: baseline.innerLips,
            leftEyeSupport: baseline.leftEyeSupport,
            rightEyeSupport: baseline.rightEyeSupport,
            freshness: baseline.freshness,
            observedEyebrowSupport: nil
        )
        XCTAssertEqual(explicit, baseline)
        XCTAssertEqual(explicit.center, baseline.center)
        XCTAssertEqual(explicit.freshness, baseline.freshness)
    }

    func testEyebrowSupportDiagnosticsExposeOnlyCountsAndBooleans() {
        let raw = BeautyObservedEyebrowSupport(
            left: eyebrowTrace(side: .left),
            right: eyebrowTrace(side: .right)
        )
        let semantic = BeautyEyebrowSemanticSupport(
            left: semanticEyebrowTrace(side: .left),
            right: semanticEyebrowTrace(side: .right)
        )
        let observation = BeautyFaceObservation(observedEyebrowSupport: raw)
        let geometry = FaceGeometry(
            bounds: FaceBounds(x: 0.123_456, y: 0.234_567, width: 0.345_678, height: 0.456_789),
            faceContour: [],
            observedEyebrowSupport: semantic
        )

        var dumps = [String]()
        for value in [String(describing: raw), String(reflecting: raw), String(describing: semantic), String(reflecting: semantic), String(describing: observation), String(describing: geometry)] {
            dumps.append(value)
        }
        var rawDump = ""
        var semanticDump = ""
        var observationDump = ""
        var geometryDump = ""
        dump(raw, to: &rawDump)
        dump(semantic, to: &semanticDump)
        dump(observation, to: &observationDump)
        dump(geometry, to: &geometryDump)
        dumps += [rawDump, semanticDump, observationDump, geometryDump]

        for diagnostic in dumps {
            for prohibited in ["0.123456", "0.234567", "0.345678", "0.456789", "CoordinatePoint", "SIMD2", "points", "innerEndpoint", "outerEndpoint", "center", "apexIndex"] {
                XCTAssertFalse(diagnostic.contains(prohibited), "diagnostic leaked \(prohibited): \(diagnostic)")
            }
        }
    }

    private func eyebrowTrace(side: BeautyObservedEyebrowSide) -> [CoordinatePoint] {
        switch side {
        case .left:
            return [
                CoordinatePoint(x: 0.42, y: 0.34), CoordinatePoint(x: 0.36, y: 0.31),
                CoordinatePoint(x: 0.29, y: 0.30), CoordinatePoint(x: 0.22, y: 0.33),
            ]
        case .right:
            return [
                CoordinatePoint(x: 0.58, y: 0.34), CoordinatePoint(x: 0.64, y: 0.31),
                CoordinatePoint(x: 0.71, y: 0.30), CoordinatePoint(x: 0.78, y: 0.33),
            ]
        }
    }

    /// Generates a valid inner-to-outer open polyline for one eyebrow side
    /// with at least `count` points and bounded chord / vertical-span. Only
    /// counts inside `minimumBrowPointCount...maximumBrowPointCount` produce
    /// traces that should ever pass validation.
    private func browOpenTrace(
        count: Int,
        side: BeautyObservedEyebrowSide
    ) -> [CoordinatePoint] {
        guard count >= 2 else { return [] }
        switch side {
        case .left:
            return (0..<count).map { index in
                let progress = Double(index) / Double(count - 1)
                let x = 0.42 - 0.20 * progress
                let y = 0.34 + 0.04 * (4 * progress * (1 - progress))
                return CoordinatePoint(x: x, y: y)
            }
        case .right:
            return (0..<count).map { index in
                let progress = Double(index) / Double(count - 1)
                let x = 0.58 + 0.20 * progress
                let y = 0.34 + 0.04 * (4 * progress * (1 - progress))
                return CoordinatePoint(x: x, y: y)
            }
        }
    }

    private func semanticEyebrowTrace(side: BeautyObservedEyebrowSide) -> BeautyEyebrowSemanticTrace {
        let points = eyebrowTrace(side: side).map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        return BeautyEyebrowSemanticTrace(
            side: side,
            points: points,
            innerEndpoint: points[0],
            outerEndpoint: points[points.count - 1],
            center: points.reduce(.zero, +) / Float(points.count),
            apexIndex: 1
        )
    }

    func testEyebrowWaveZeroTopologyFixturesCoverExactRowsAndLocalSiblingFailure() {
        XCTAssertEqual(eyebrowSemanticCardinalityMatrix.map(\.count), [3, 4, 5, 15, 16, 17])
        XCTAssertEqual(eyebrowSemanticCardinalityMatrix.map(\.eligible), [false, true, true, true, true, false])
        XCTAssertEqual(Set(eyebrowMalformedTopologyFixtures.map(\.kind)), Set(EyebrowMalformedTopologyKind.allCases))

        let validLeft = semanticEyebrowTrace(side: .left)
        let validRight = semanticEyebrowTrace(side: .right)
        let leftOnly = BeautyEyebrowSemanticSupport(left: validLeft, right: nil)
        let rightOnly = BeautyEyebrowSemanticSupport(left: nil, right: validRight)
        XCTAssertEqual(leftOnly.left, validLeft)
        XCTAssertNil(leftOnly.right)
        XCTAssertNil(rightOnly.left)
        XCTAssertEqual(rightOnly.right, validRight)
        XCTAssertFalse(leftOnly.pairedEligible)
        XCTAssertFalse(rightOnly.pairedEligible)
    }

    func testBrowOpenPathPurePredicatesLockInclusiveNumericBoundaries() {
        XCTAssertFalse(BeautyFaceGeometryAdapter.browChordIsValid(0.079_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.browChordIsValid(0.08))
        XCTAssertTrue(BeautyFaceGeometryAdapter.browChordIsValid(0.08 + 0.000_001))
        XCTAssertTrue(BeautyFaceGeometryAdapter.browChordIsValid(0.50 - 0.000_001))
        XCTAssertTrue(BeautyFaceGeometryAdapter.browChordIsValid(0.50))
        XCTAssertFalse(BeautyFaceGeometryAdapter.browChordIsValid(0.50 + 0.000_001))
        XCTAssertFalse(BeautyFaceGeometryAdapter.browChordIsValid(0))
        XCTAssertFalse(BeautyFaceGeometryAdapter.browChordIsValid(.nan))
        XCTAssertFalse(BeautyFaceGeometryAdapter.browChordIsValid(.infinity))

        XCTAssertTrue(BeautyFaceGeometryAdapter.browVerticalSpanIsValid(0))
        XCTAssertTrue(BeautyFaceGeometryAdapter.browVerticalSpanIsValid(0.249_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.browVerticalSpanIsValid(0.25))
        XCTAssertFalse(BeautyFaceGeometryAdapter.browVerticalSpanIsValid(0.25 + 0.000_001))
        XCTAssertFalse(BeautyFaceGeometryAdapter.browVerticalSpanIsValid(-0.000_001))
        XCTAssertFalse(BeautyFaceGeometryAdapter.browVerticalSpanIsValid(.nan))
        XCTAssertFalse(BeautyFaceGeometryAdapter.browVerticalSpanIsValid(.infinity))

        XCTAssertFalse(BeautyFaceGeometryAdapter.browProjectionMagnitudeIsValid(0.000_000_999))
        XCTAssertTrue(BeautyFaceGeometryAdapter.browProjectionMagnitudeIsValid(0.000_001))
        XCTAssertTrue(BeautyFaceGeometryAdapter.browProjectionMagnitudeIsValid(0.000_001_001))
        XCTAssertFalse(BeautyFaceGeometryAdapter.browProjectionMagnitudeIsValid(0))
        XCTAssertFalse(BeautyFaceGeometryAdapter.browProjectionMagnitudeIsValid(.nan))
        XCTAssertFalse(BeautyFaceGeometryAdapter.browProjectionMagnitudeIsValid(.infinity))
    }

    func testBrowOpenPathCardinalityUniquenessAndUnitRangeRejectMalformedInput() {
        let faceBounds = FaceBounds(x: 0.10, y: 0.10, width: 0.80, height: 0.80)
        for entry in eyebrowSemanticCardinalityMatrix {
            let validated = BeautyFaceGeometryAdapter.validatedBrowTrace(
                browOpenTrace(count: entry.count, side: .left),
                side: .left,
                bounds: faceBounds
            )
            XCTAssertEqual(validated != nil, entry.eligible, "count=\(entry.count)")
        }
        XCTAssertEqual(
            eyebrowSemanticCardinalityMatrix.map(\.count),
            [3, 4, 5, 15, 16, 17]
        )
        XCTAssertEqual(
            eyebrowSemanticCardinalityMatrix.map(\.eligible),
            [false, true, true, true, true, false]
        )

        let validCount5 = browOpenTrace(count: 5, side: .left)
        var adjacentDuplicate = validCount5
        adjacentDuplicate[1] = adjacentDuplicate[0]
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                adjacentDuplicate, side: .left, bounds: faceBounds
            )
        )

        var repeatedEndpoint = validCount5
        repeatedEndpoint[repeatedEndpoint.count - 1] = repeatedEndpoint[0]
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                repeatedEndpoint, side: .left, bounds: faceBounds
            )
        )

        var nonFinite = validCount5
        nonFinite[1] = CoordinatePoint(x: .nan, y: nonFinite[1].y)
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                nonFinite, side: .left, bounds: faceBounds
            )
        )

        var infinity = validCount5
        infinity[1] = CoordinatePoint(x: .infinity, y: infinity[1].y)
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                infinity, side: .left, bounds: faceBounds
            )
        )

        var outOfUnit = validCount5
        outOfUnit[2] = CoordinatePoint(x: 1.000_001, y: outOfUnit[2].y)
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                outOfUnit, side: .left, bounds: faceBounds
            )
        )

        for value in [-0.000_001, 1.000_001] {
            var candidate = validCount5
            candidate[0] = CoordinatePoint(x: value, y: candidate[0].y)
            XCTAssertNil(
                BeautyFaceGeometryAdapter.validatedBrowTrace(
                    candidate, side: .left, bounds: faceBounds
                )
            )
        }

        let identical = Array(repeating: CoordinatePoint(x: 0.50, y: 0.32), count: 5)
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                identical, side: .left, bounds: faceBounds
            )
        )

        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                nil, side: .left, bounds: faceBounds
            )
        )
    }

    func testBrowOpenPathValidationPreservesCanonicalAdjacencyAndRejectsReverseInnerToOuter() throws {
        let faceBounds = FaceBounds(x: 0.10, y: 0.10, width: 0.80, height: 0.80)
        let validLeft = browOpenTrace(count: 5, side: .left)
        let validRight = browOpenTrace(count: 5, side: .right)
        let reversedLeft = Array(validLeft.reversed())
        let reversedRight = Array(validRight.reversed())

        let validatedLeft = try XCTUnwrap(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                validLeft, side: .left, bounds: faceBounds
            )
        )
        XCTAssertEqual(
            validatedLeft.points,
            validLeft.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        )
        XCTAssertEqual(validatedLeft.innerEndpoint, validatedLeft.points.first)
        XCTAssertEqual(validatedLeft.outerEndpoint, validatedLeft.points.last)
        let expectedCenter = validatedLeft.points.reduce(.zero, +)
            / Float(validatedLeft.points.count)
        XCTAssertEqual(validatedLeft.center, expectedCenter)
        XCTAssertEqual(validatedLeft.side, .left)
        XCTAssertEqual(validatedLeft.points.count, 5)
        XCTAssertNotEqual(validatedLeft.innerEndpoint, validatedLeft.outerEndpoint)

        let validatedRight = try XCTUnwrap(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                validRight, side: .right, bounds: faceBounds
            )
        )
        XCTAssertEqual(validatedRight.side, .right)
        XCTAssertEqual(
            validatedRight.points,
            validRight.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        )

        // The reversed arrangement still passes the open-path envelope but the
        // semantic endpoints now point to the wrong canonical endpoint. The
        // adapter preserves input order without rotation, so reversed input
        // remains accepted and the only invariant is adjacency order.
        XCTAssertNotNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                reversedLeft, side: .left, bounds: faceBounds
            )
        )
        XCTAssertNotNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                reversedRight, side: .right, bounds: faceBounds
            )
        )
    }

    func testBrowOpenPathChordAndVerticalSpanBoundariesLockEqualAndExclusiveRows() {
        let faceBounds = FaceBounds(x: 0.10, y: 0.10, width: 0.80, height: 0.80)
        let base = browOpenTrace(count: 5, side: .left)

        // Chord below the 0.08 face-width minimum fails. Absolute chord at
        // 0.06 face-units becomes 0.075 face-relative with bounds.width 0.80.
        var shortChord = base
        shortChord[0] = CoordinatePoint(x: 0.36, y: 0.34)
        shortChord[shortChord.count - 1] = CoordinatePoint(
            x: 0.36 - 0.06,
            y: shortChord[shortChord.count - 1].y
        )
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                shortChord, side: .left, bounds: faceBounds
            )
        )

        // Chord at exactly 0.08 face-width passes. With bounds.width 0.80
        // and offset 0.10 the chord 0.064 face-units equals 0.08 face-relative.
        var equalMinimumChord = base
        equalMinimumChord[0] = CoordinatePoint(x: 0.36, y: 0.34)
        equalMinimumChord[equalMinimumChord.count - 1] = CoordinatePoint(
            x: 0.36 - Double(BeautyFaceGeometryAdapter.minimumBrowChord) * Double(faceBounds.width),
            y: equalMinimumChord[equalMinimumChord.count - 1].y
        )
        XCTAssertNotNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                equalMinimumChord, side: .left, bounds: faceBounds
            )
        )

        // Chord above 0.50 face-width fails. With bounds.width 0.80 the
        // chord 0.408 face-units equals 0.51 face-relative.
        var longChord = base
        longChord[longChord.count - 1] = CoordinatePoint(
            x: longChord[0].x - Double(BeautyFaceGeometryAdapter.maximumBrowChord) * Double(faceBounds.width) - 0.001,
            y: longChord[longChord.count - 1].y
        )
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                longChord, side: .left, bounds: faceBounds
            )
        )

        // Vertical span > 0.25 face-height fails. With bounds.height 0.80
        // the span 0.29 face-units equals 0.3625 face-relative.
        var tallSpan = base
        tallSpan[2] = CoordinatePoint(x: tallSpan[2].x, y: 0.05)
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                tallSpan, side: .left, bounds: faceBounds
            )
        )

        // Vertical span exactly 0.25 face-height passes. Anchors at
        // absolute y 0.30 and 0.50 produce face-relative y 0.25 and 0.50.
        var equalVerticalSpan = base
        equalVerticalSpan[0] = CoordinatePoint(x: equalVerticalSpan[0].x, y: 0.30)
        equalVerticalSpan[equalVerticalSpan.count - 1] = CoordinatePoint(
            x: equalVerticalSpan[equalVerticalSpan.count - 1].x,
            y: 0.30 + Double(BeautyFaceGeometryAdapter.maximumBrowVerticalSpan) * Double(faceBounds.height)
        )
        XCTAssertNotNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                equalVerticalSpan, side: .left, bounds: faceBounds
            )
        )
    }

    func testBrowRejectsNonAdjacentOpenPathSegmentIntersections() {
        let faceBounds = FaceBounds(x: 0.10, y: 0.10, width: 0.80, height: 0.80)
        let bowTie = [
            CoordinatePoint(x: 0.42, y: 0.32),
            CoordinatePoint(x: 0.34, y: 0.31),
            CoordinatePoint(x: 0.36, y: 0.30),
            CoordinatePoint(x: 0.30, y: 0.34),
            CoordinatePoint(x: 0.22, y: 0.32),
        ]
        XCTAssertNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                bowTie, side: .left, bounds: faceBounds
            )
        )

        // The valid open path with no non-adjacent crossings still passes.
        let validLeft = browOpenTrace(count: 5, side: .left)
        XCTAssertNotNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                validLeft, side: .left, bounds: faceBounds
            )
        )
        let validRight = browOpenTrace(count: 5, side: .right)
        XCTAssertNotNil(
            BeautyFaceGeometryAdapter.validatedBrowTrace(
                validRight, side: .right, bounds: faceBounds
            )
        )
    }

    func testBrowSupportAttachmentPreservesFourPresenceCombinationsAndPairedEligibility() {
        let absent = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(imageBounds: bounds, landmarks: .complete)
        )
        XCTAssertNil(absent.observedEyebrowSupport)

        let validObs = BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                left: browOpenTrace(count: 5, side: .left),
                right: browOpenTrace(count: 5, side: .right)
            )
        )
        let both = BeautyFaceGeometryAdapter.makeGeometry(from: validObs)
        XCTAssertNotNil(both.observedEyebrowSupport?.left)
        XCTAssertNotNil(both.observedEyebrowSupport?.right)
        XCTAssertTrue(both.observedEyebrowSupport?.pairedEligible == true)
        XCTAssertEqual(both.observedEyebrowSupport?.left?.side, .left)
        XCTAssertEqual(both.observedEyebrowSupport?.right?.side, .right)

        let leftOnlyObs = BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                left: browOpenTrace(count: 5, side: .left),
                right: browInvalidPoints(side: .right)
            )
        )
        let leftOnly = BeautyFaceGeometryAdapter.makeGeometry(from: leftOnlyObs)
        XCTAssertNotNil(leftOnly.observedEyebrowSupport?.left)
        XCTAssertNil(leftOnly.observedEyebrowSupport?.right)
        XCTAssertFalse(leftOnly.observedEyebrowSupport?.pairedEligible == true)

        let rightOnlyObs = BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                left: browInvalidPoints(side: .left),
                right: browOpenTrace(count: 5, side: .right)
            )
        )
        let rightOnly = BeautyFaceGeometryAdapter.makeGeometry(from: rightOnlyObs)
        XCTAssertNil(rightOnly.observedEyebrowSupport?.left)
        XCTAssertNotNil(rightOnly.observedEyebrowSupport?.right)
        XCTAssertFalse(rightOnly.observedEyebrowSupport?.pairedEligible == true)

        let neitherObs = BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                left: browInvalidPoints(side: .left),
                right: browInvalidPoints(side: .right)
            )
        )
        let neither = BeautyFaceGeometryAdapter.makeGeometry(from: neitherObs)
        XCTAssertNil(neither.observedEyebrowSupport)
    }

    func testBrowMalformedLocalFailureNeverAffectsShippedGeometrySiblings() {
        let baseline = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(imageBounds: bounds, landmarks: .complete)
        )
        let validLeft = browOpenTrace(count: 5, side: .left)
        let validRight = browOpenTrace(count: 5, side: .right)

        let malformed: [BeautyObservedEyebrowSupport?] = [
            BeautyObservedEyebrowSupport(left: nil, right: browInvalidPoints(side: .right)),
            BeautyObservedEyebrowSupport(left: browInvalidPoints(side: .left), right: nil),
            BeautyObservedEyebrowSupport(
                left: browInvalidPoints(side: .left),
                right: browInvalidPoints(side: .right)
            ),
            BeautyObservedEyebrowSupport(
                left: browInvalidPoints(side: .left),
                right: validRight
            ),
        ]

        for support in malformed {
            let observation = BeautyFaceObservation(
                imageBounds: bounds,
                landmarks: .complete,
                observedEyebrowSupport: support
            )
            let geometry = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
            assertLegacyAndSiblingGeometryEqual(geometry, baseline)
        }

        let fullyValid = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(
                imageBounds: bounds,
                landmarks: .complete,
                observedEyebrowSupport: BeautyObservedEyebrowSupport(
                    left: validLeft,
                    right: validRight
                )
            )
        )
        XCTAssertNotNil(fullyValid.observedEyebrowSupport?.left)
        XCTAssertNotNil(fullyValid.observedEyebrowSupport?.right)
        XCTAssertTrue(fullyValid.observedEyebrowSupport?.pairedEligible == true)
        assertLegacyAndSiblingGeometryEqual(fullyValid, baseline)

        // Invalid eye order never suppresses valid eyebrow attachment.
        let invalidEyeOrder = BeautyFaceGeometryAdapter.makeGeometry(
            from: BeautyFaceObservation(
                imageBounds: bounds,
                landmarks: .complete,
                observedEyeSupport: [
                    BeautyObservedEyeSupport(
                        side: .left,
                        contour: self.contour(x: 0.58, y: 0.40)
                    )
                ],
                observedEyeOrder: .invalid,
                observedEyebrowSupport: BeautyObservedEyebrowSupport(
                    left: validLeft,
                    right: validRight
                )
            )
        )
        XCTAssertNotNil(invalidEyeOrder.observedEyebrowSupport?.left)
        XCTAssertNotNil(invalidEyeOrder.observedEyebrowSupport?.right)
        XCTAssertTrue(invalidEyeOrder.observedEyebrowSupport?.pairedEligible == true)
        XCTAssertEqual(invalidEyeOrder.faceContour, baseline.faceContour)
        XCTAssertEqual(invalidEyeOrder.nose, baseline.nose)
        XCTAssertEqual(invalidEyeOrder.outerLips, baseline.outerLips)
    }

    func testBrowAlternatingLifecycleRetainsNoPriorSupport() {
        let validObservation = BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                left: browOpenTrace(count: 5, side: .left),
                right: browOpenTrace(count: 5, side: .right)
            )
        )
        let invalidObservation = BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                left: browInvalidPoints(side: .left),
                right: browInvalidPoints(side: .right)
            )
        )
        let staleFace = BeautyFaceObservation(
            landmarks: .missingRequiredGeometry
        )
        let noFace = BeautyFaceObservation(landmarks: .missingRequiredGeometry)

        let first = BeautyFaceGeometryAdapter.makeGeometry(from: validObservation)
        let middle = BeautyFaceGeometryAdapter.makeGeometry(from: invalidObservation)
        let last = BeautyFaceGeometryAdapter.makeGeometry(from: validObservation)
        XCTAssertNotNil(first.observedEyebrowSupport)
        XCTAssertNil(middle.observedEyebrowSupport)
        XCTAssertEqual(last.observedEyebrowSupport, first.observedEyebrowSupport)

        let repeated = (0..<5).map { _ in
            BeautyFaceGeometryAdapter.makeGeometry(from: validObservation)
        }
        for geometry in repeated {
            XCTAssertNotNil(geometry.observedEyebrowSupport)
            XCTAssertEqual(geometry.observedEyebrowSupport, first.observedEyebrowSupport)
        }

        let staleGeometry = BeautyFaceGeometryAdapter.makeGeometry(from: staleFace)
        XCTAssertNil(staleGeometry.observedEyebrowSupport)

        let noFaceGeometry = BeautyFaceGeometryAdapter.makeGeometry(from: noFace)
        XCTAssertNil(noFaceGeometry.observedEyebrowSupport)
    }

    func testBrowIndependentParallelGeometryConstructionsAreStateless() throws {
        let observation = BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                left: browOpenTrace(count: 5, side: .left),
                right: browOpenTrace(count: 5, side: .right)
            )
        )
        let first = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        let second = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
        XCTAssertEqual(first.observedEyebrowSupport, second.observedEyebrowSupport)
        XCTAssertEqual(
            first.observedEyebrowSupport?.left?.points,
            second.observedEyebrowSupport?.left?.points
        )
        XCTAssertEqual(
            first.observedEyebrowSupport?.right?.points,
            second.observedEyebrowSupport?.right?.points
        )

        // Independent observations with different counts must not share support.
        let alternate = BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                left: browOpenTrace(count: 6, side: .left),
                right: browOpenTrace(count: 4, side: .right)
            )
        )
        let alternateGeometry = BeautyFaceGeometryAdapter.makeGeometry(from: alternate)
        XCTAssertNotEqual(
            first.observedEyebrowSupport?.left?.points.count,
            alternateGeometry.observedEyebrowSupport?.left?.points.count
        )
        XCTAssertNotEqual(
            first.observedEyebrowSupport?.right?.points.count,
            alternateGeometry.observedEyebrowSupport?.right?.points.count
        )
    }

    private func browInvalidPoints(side: BeautyObservedEyebrowSide) -> [CoordinatePoint] {
        // Three-point trace fails the count envelope (4...16).
        switch side {
        case .left:
            return [
                CoordinatePoint(x: 0.42, y: 0.34),
                CoordinatePoint(x: 0.32, y: 0.32),
                CoordinatePoint(x: 0.22, y: 0.30),
            ]
        case .right:
            return [
                CoordinatePoint(x: 0.58, y: 0.34),
                CoordinatePoint(x: 0.68, y: 0.32),
                CoordinatePoint(x: 0.78, y: 0.30),
            ]
        }
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

    private func faceObservation(
        support: BeautyObservedFaceSupport?
    ) -> BeautyFaceObservation {
        BeautyFaceObservation(
            imageBounds: bounds,
            landmarks: .complete,
            observedFaceSupport: support
        )
    }

    private func assertLegacyAndSiblingGeometryEqual(
        _ candidate: FaceGeometry,
        _ baseline: FaceGeometry,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(candidate.bounds, baseline.bounds, file: file, line: line)
        XCTAssertEqual(candidate.faceContour, baseline.faceContour, file: file, line: line)
        XCTAssertEqual(candidate.leftEye, baseline.leftEye, file: file, line: line)
        XCTAssertEqual(candidate.rightEye, baseline.rightEye, file: file, line: line)
        XCTAssertEqual(candidate.nose, baseline.nose, file: file, line: line)
        XCTAssertEqual(candidate.noseRoot, baseline.noseRoot, file: file, line: line)
        XCTAssertEqual(candidate.noseTip, baseline.noseTip, file: file, line: line)
        XCTAssertEqual(candidate.outerLips, baseline.outerLips, file: file, line: line)
        XCTAssertEqual(candidate.upperLips, baseline.upperLips, file: file, line: line)
        XCTAssertEqual(candidate.lowerLips, baseline.lowerLips, file: file, line: line)
        XCTAssertEqual(candidate.innerLips, baseline.innerLips, file: file, line: line)
        XCTAssertEqual(
            candidate.leftEyeSupport,
            baseline.leftEyeSupport,
            file: file,
            line: line
        )
        XCTAssertEqual(
            candidate.rightEyeSupport,
            baseline.rightEyeSupport,
            file: file,
            line: line
        )
        XCTAssertEqual(candidate.freshness, baseline.freshness, file: file, line: line)
    }

    private func contour(x: Double, y: Double, width: Double = 0.16, height: Double = 0.08) -> [CoordinatePoint] {
        [
            CoordinatePoint(x: x, y: y + height * 0.375),
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

    private func polygonContour(count: Int, x: Double, y: Double, width: Double = 0.16, height: Double = 0.08) -> [CoordinatePoint] {
        (0..<count).map { index in
            let angle = (Double(index) / Double(count)) * 2 * Double.pi
            return CoordinatePoint(
                x: x + width * (0.5 + 0.5 * cos(angle)),
                y: y + height * (0.5 + 0.5 * sin(angle))
            )
        }
    }

    private func pointOrder(_ lhs: SIMD2<Float>, _ rhs: SIMD2<Float>) -> Bool {
        lhs.x == rhs.x ? lhs.y < rhs.y : lhs.x < rhs.x
    }

    private func faceOpenContour(
        count: Int,
        width: Double = 0.80,
        height: Double = 0.60
    ) -> [CoordinatePoint] {
        guard count > 1 else { return [] }
        return (0..<count).map { index in
            let progress = Double(index) / Double(count - 1)
            return CoordinatePoint(
                x: 0.10 + width * progress,
                y: 0.15 + height * 4 * progress * (1 - progress)
            )
        }
    }

    private func faceMedianLine(count: Int) -> [CoordinatePoint] {
        guard count > 1 else { return [] }
        return (0..<count).map { index in
            let progress = Double(index) / Double(count - 1)
            return CoordinatePoint(x: 0.50, y: 0.20 + 0.60 * progress)
        }
    }

    private func allPointsAreUnique(_ points: [CoordinatePoint]) -> Bool {
        points.indices.allSatisfy { index in
            !points[..<index].contains(points[index])
        }
    }

    private func portraitFixtureURLs() throws -> [URL] {
        let directory = try repositoryRootURL()
            .appendingPathComponent("example-images/input/portraits", isDirectory: true)
        return try ["p1.jpg"].map {
            let url = directory.appendingPathComponent($0)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw FaceFixtureError.missing
            }
            return url
        }
    }

    private func repositoryRootURL() throws -> URL {
        var current = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        while current.path != "/" {
            let fixture = current.appendingPathComponent(
                "example-images/input/portraits/p1.jpg"
            )
            if FileManager.default.fileExists(atPath: fixture.path) {
                return current
            }
            current.deleteLastPathComponent()
        }
        throw FaceFixtureError.missing
    }

    private func assertSendable<T: Sendable>(_ value: T) {
        _ = value
    }
}

private enum FaceFixtureError: Error {
    case missing
    case unreadable
}

private struct EyebrowSemanticCardinalityFixture {
    let count: Int
    let eligible: Bool
}

private let eyebrowSemanticCardinalityMatrix = [
    EyebrowSemanticCardinalityFixture(count: 3, eligible: false),
    EyebrowSemanticCardinalityFixture(count: 4, eligible: true),
    EyebrowSemanticCardinalityFixture(count: 5, eligible: true),
    EyebrowSemanticCardinalityFixture(count: 15, eligible: true),
    EyebrowSemanticCardinalityFixture(count: 16, eligible: true),
    EyebrowSemanticCardinalityFixture(count: 17, eligible: false),
]

private enum EyebrowMalformedTopologyKind: String, CaseIterable {
    case exactBitDuplicate
    case nan
    case infinity
    case outOfUnit
    case zeroChord
    case shortChord
    case equalMinimumChord
    case longChord
    case equalMaximumChord
    case excessiveVerticalSpan
    case equalMaximumVerticalSpan
    case wrongSide
    case wrongOrder
    case nonAdjacentCrossing
}

private struct EyebrowMalformedTopologyFixture {
    let kind: EyebrowMalformedTopologyKind
    let side: BeautyObservedEyebrowSide
    let points: [CoordinatePoint]
}

private let eyebrowMalformedTopologyFixtures: [EyebrowMalformedTopologyFixture] =
    EyebrowMalformedTopologyKind.allCases.map { kind in
        let base = [
            CoordinatePoint(x: 0.42, y: 0.34), CoordinatePoint(x: 0.36, y: 0.31),
            CoordinatePoint(x: 0.29, y: 0.30), CoordinatePoint(x: 0.22, y: 0.33),
        ]
        return EyebrowMalformedTopologyFixture(kind: kind, side: .left, points: base)
    }

private struct FaceSupportFixture {
    let contour: [CoordinatePoint]
    let medianLine: [CoordinatePoint]
}

private struct FaceCardinalityFixture {
    let count: Int
    let eligible: Bool
}

private enum FaceBoundaryPosition: Hashable {
    case inside
    case equal
    case outside
}

private struct FaceTopologyBoundaryFixture {
    let rule: String
    let value: Double
    let position: FaceBoundaryPosition
    let eligible: Bool
}

private let faceContourCardinalityMatrix = [
    FaceCardinalityFixture(count: 6, eligible: false),
    FaceCardinalityFixture(count: 7, eligible: true),
    FaceCardinalityFixture(count: 8, eligible: true),
    FaceCardinalityFixture(count: 31, eligible: true),
    FaceCardinalityFixture(count: 32, eligible: true),
    FaceCardinalityFixture(count: 33, eligible: false),
]

private let faceMedianCardinalityMatrix = [
    FaceCardinalityFixture(count: 2, eligible: false),
    FaceCardinalityFixture(count: 3, eligible: true),
    FaceCardinalityFixture(count: 4, eligible: true),
    FaceCardinalityFixture(count: 15, eligible: true),
    FaceCardinalityFixture(count: 16, eligible: true),
    FaceCardinalityFixture(count: 17, eligible: false),
]

private let faceTopologyBoundaryMatrix = [
    FaceTopologyBoundaryFixture(rule: "contourWidth", value: 0.500_001, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "contourWidth", value: 0.50, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "contourWidth", value: 0.499_999, position: .outside, eligible: false),
    FaceTopologyBoundaryFixture(rule: "contourWidthMaximum", value: 0.999_999, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "contourWidthMaximum", value: 1.00, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "contourWidthMaximum", value: 1.000_001, position: .outside, eligible: false),
    FaceTopologyBoundaryFixture(rule: "contourHeight", value: 0.200_001, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "contourHeight", value: 0.20, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "contourHeight", value: 0.199_999, position: .outside, eligible: false),
    FaceTopologyBoundaryFixture(rule: "contourHeightMaximum", value: 0.999_999, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "contourHeightMaximum", value: 1.00, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "contourHeightMaximum", value: 1.000_001, position: .outside, eligible: false),
    FaceTopologyBoundaryFixture(rule: "endpointSeparation", value: 0.350_001, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "endpointSeparation", value: 0.35, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "endpointSeparation", value: 0.349_999, position: .outside, eligible: false),
    FaceTopologyBoundaryFixture(rule: "curvature", value: 0.100_001, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "curvature", value: 0.10, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "curvature", value: 0.099_999, position: .outside, eligible: false),
    FaceTopologyBoundaryFixture(rule: "medianDown", value: 0.250_001, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "medianDown", value: 0.25, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "medianDown", value: 0.249_999, position: .outside, eligible: false),
    FaceTopologyBoundaryFixture(rule: "sideProjection", value: 0.150_001, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "sideProjection", value: 0.15, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "sideProjection", value: 0.149_999, position: .outside, eligible: false),
    FaceTopologyBoundaryFixture(rule: "sideProjectionMaximum", value: 0.849_999, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "sideProjectionMaximum", value: 0.85, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "sideProjectionMaximum", value: 0.850_001, position: .outside, eligible: false),
    FaceTopologyBoundaryFixture(rule: "apexDistance", value: 0.399_999, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "apexDistance", value: 0.40, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "apexDistance", value: 0.400_001, position: .outside, eligible: false),
    FaceTopologyBoundaryFixture(rule: "directionEpsilon", value: 0.000_001_001, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "directionEpsilon", value: 0.000_001, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "directionEpsilon", value: 0.000_000_999, position: .outside, eligible: false),
    FaceTopologyBoundaryFixture(rule: "apexInteriorPoints", value: 3, position: .inside, eligible: true),
    FaceTopologyBoundaryFixture(rule: "apexInteriorPoints", value: 2, position: .equal, eligible: true),
    FaceTopologyBoundaryFixture(rule: "apexInteriorPoints", value: 1, position: .outside, eligible: false),
]
