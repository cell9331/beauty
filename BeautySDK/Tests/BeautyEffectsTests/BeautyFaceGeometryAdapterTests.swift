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

    func testFaceOpenPathValidationPreservesForwardAndReversedAdjacency() throws {
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
        XCTAssertEqual(
            try XCTUnwrap(
                BeautyFaceGeometryAdapter.validatedFaceContour(reversedContour, bounds: faceBounds)
            ),
            reversedContour.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        )
        XCTAssertEqual(
            try XCTUnwrap(
                BeautyFaceGeometryAdapter.validatedFaceMedianLine(median, bounds: faceBounds)
            ),
            median.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        )
        XCTAssertEqual(
            try XCTUnwrap(
                BeautyFaceGeometryAdapter.validatedFaceMedianLine(reversedMedian, bounds: faceBounds)
            ),
            reversedMedian.map { SIMD2<Float>(Float($0.x), Float($0.y)) }
        )
    }

    func testCommittedPortraitAggregateFitsLockedFaceValidationEnvelope() throws {
        var detector = VisionFaceDetector()
        var completeSupportCount = 0
        var validatedSupportCount = 0

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
            }
        }

        XCTAssertGreaterThan(completeSupportCount, 0, "expected observed aggregate support")
        XCTAssertEqual(validatedSupportCount, completeSupportCount, "aggregate validation mismatch")
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
        return try ["e1.png", "e2.png", "e3.png", "e4.png", "e5.png", "e6.jpg"].map {
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
                "example-images/input/portraits/e1.png"
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
