import CoreGraphics
import ImageIO
import XCTest
import BeautyCore
@testable import BeautyDetection

final class FaceObservationMappingTests: XCTestCase {
    func testPIPE05VisionObservationBoundsReachSelectionAsImageNormalizedData() {
        var detector = VisionFaceDetector { _ in
            [
                VisionDetectionObservation(
                    stableID: "mapped",
                    confidence: 0.95,
                    visionBounds: CoordinateRect(x: 0.25, y: 0.25, width: 0.50, height: 0.50)
                )
            ]
        }

        let result = detector.detect(
            metadata: metadata(orientation: .up),
            imageExtent: CGSize(width: 400, height: 200)
        )

        XCTAssertEqual(result.summary.availability, .usable)
        XCTAssertEqual(result.summary.faceCount, 1)
        XCTAssertEqual(result.summary.usedFaceCount, 1)
        XCTAssertEqual(result.observations.map(\.stableID), ["mapped"])
        assertRect(
            result.observations[0].imageBounds,
            equals: CoordinateRect(x: 0.25, y: 0.25, width: 0.50, height: 0.50)
        )
        XCTAssertEqual(result.observations[0].normalizedArea, 0.25, accuracy: 0.000_001)
    }

    func testPIPE05InputMirroredVisionObservationMapsBeforeSelection() {
        var detector = VisionFaceDetector { _ in
            [
                VisionDetectionObservation(
                    stableID: "mirrored",
                    confidence: 0.95,
                    visionBounds: CoordinateRect(x: 0.10, y: 0.20, width: 0.20, height: 0.30)
                )
            ]
        }

        let result = detector.detect(
            metadata: metadata(orientation: .up, inputMirrored: true),
            imageExtent: CGSize(width: 400, height: 200)
        )

        assertRect(
            result.observations[0].imageBounds,
            equals: CoordinateRect(x: 0.70, y: 0.50, width: 0.20, height: 0.30)
        )
    }

    func testPIPE07MappingFailureAddsStructuredMappingFailedReason() {
        var detector = VisionFaceDetector { _ in
            [
                VisionDetectionObservation(
                    stableID: "bad-extent",
                    confidence: 0.95,
                    visionBounds: CoordinateRect(x: 0.25, y: 0.25, width: 0.50, height: 0.50)
                )
            ]
        }

        let result = detector.detect(
            metadata: metadata(orientation: .up),
            imageExtent: .zero
        )

        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .partial)
        XCTAssertEqual(result.summary.reasons, [.mappingFailed])
        XCTAssertEqual(result.summary.faceCount, 1)
        XCTAssertEqual(result.summary.usedFaceCount, 0)
        XCTAssertFalse(String(describing: result.summary).contains("CoordinateRect"))
    }

    func testPIPE07MissingLandmarksRemainCoarseAfterVisionBoundsAreProvided() {
        var detector = VisionFaceDetector { _ in
            [
                VisionDetectionObservation(
                    stableID: "partial",
                    confidence: 0.95,
                    visionBounds: CoordinateRect(x: 0.25, y: 0.25, width: 0.50, height: 0.50),
                    landmarks: .missingRequiredGeometry
                )
            ]
        }

        let result = detector.detect(
            metadata: metadata(orientation: .up),
            imageExtent: CGSize(width: 400, height: 200)
        )

        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .partial)
        XCTAssertEqual(result.summary.reasons, [.missingLandmarks])
        XCTAssertEqual(result.summary.faceCount, 1)
        XCTAssertEqual(result.summary.usedFaceCount, 0)
    }

    func testEYE05ObservedPointsPreserveSideAcrossOrientationAndInputMirror() {
        let source = CoordinatePoint(x: 0.25, y: 0.75)
        let bounds = CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60)
        let expected: [(CGImagePropertyOrientation, Bool, CoordinatePoint)] = [
            (.up, false, CoordinatePoint(x: 0.325, y: 0.45)),
            (.right, false, CoordinatePoint(x: 0.55, y: 0.325)),
            (.left, false, CoordinatePoint(x: 0.45, y: 0.675)),
            (.down, false, CoordinatePoint(x: 0.675, y: 0.55)),
            (.up, true, CoordinatePoint(x: 0.675, y: 0.45))
        ]

        for (orientation, mirrored, expectedPoint) in expected {
            let left = BeautyObservedEyeSupport(side: .left, contour: [source])
            let right = BeautyObservedEyeSupport(side: .right, contour: [source])
            var detector = VisionFaceDetector { _ in
                [VisionDetectionObservation(
                    visionBounds: bounds,
                    observedEyeSupport: [left, right]
                )]
            }
            let result = detector.detect(
                metadata: metadata(orientation: orientation, inputMirrored: mirrored),
                imageExtent: CGSize(width: 400, height: 200)
            )
            let supports = result.observations[0].observedEyeSupport ?? []
            XCTAssertEqual(supports.map(\.side), [.left, .right])
            for support in supports {
                guard let point = support.contour.first else {
                    XCTFail("Expected mapped observed contour point")
                    continue
                }
                XCTAssertEqual(point.x, expectedPoint.x, accuracy: 0.000_001)
                XCTAssertEqual(point.y, expectedPoint.y, accuracy: 0.000_001)
            }
        }
    }

    func testEYE06ProductionDerivedSideOrderAcceptsAllOrientationsAndMirror() {
        let bounds = CoordinateRect(x: 0.10, y: 0.10, width: 0.80, height: 0.60)
        let left = BeautyObservedEyeSupport(
            side: .left,
            contour: [
                CoordinatePoint(x: 0.18, y: 0.35), CoordinatePoint(x: 0.22, y: 0.30),
                CoordinatePoint(x: 0.28, y: 0.30), CoordinatePoint(x: 0.32, y: 0.35),
                CoordinatePoint(x: 0.28, y: 0.40), CoordinatePoint(x: 0.22, y: 0.40)
            ]
        )
        let right = BeautyObservedEyeSupport(
            side: .right,
            contour: [
                CoordinatePoint(x: 0.68, y: 0.35), CoordinatePoint(x: 0.72, y: 0.30),
                CoordinatePoint(x: 0.78, y: 0.30), CoordinatePoint(x: 0.82, y: 0.35),
                CoordinatePoint(x: 0.78, y: 0.40), CoordinatePoint(x: 0.72, y: 0.40)
            ]
        )
        for orientation in [CGImagePropertyOrientation.up, .right, .left, .down] {
            for mirrored in [false, true] {
                var detector = VisionFaceDetector { _ in
                    [VisionDetectionObservation(
                        visionBounds: bounds,
                        observedEyeSupport: [left, right]
                    )]
                }
                let result = detector.detect(
                    metadata: metadata(orientation: orientation, inputMirrored: mirrored),
                    imageExtent: CGSize(width: 400, height: 200)
                )
                XCTAssertEqual(result.observations.count, 1)
                XCTAssertEqual(result.observations[0].observedEyeOrder, .canonical)
                XCTAssertEqual(result.observations[0].observedEyeSupport?.map(\.side), [.left, .right])
            }
        }
    }

    func testEYE06ProductionDerivedSideOrderAcceptsOneActualEyeAcrossOrientationAndMirror() {
        let bounds = CoordinateRect(x: 0.10, y: 0.10, width: 0.80, height: 0.60)
        let left = BeautyObservedEyeSupport(
            side: .left,
            contour: [
                CoordinatePoint(x: 0.18, y: 0.35),
                CoordinatePoint(x: 0.32, y: 0.35),
            ]
        )
        let right = BeautyObservedEyeSupport(
            side: .right,
            contour: [
                CoordinatePoint(x: 0.68, y: 0.35),
                CoordinatePoint(x: 0.82, y: 0.35),
            ]
        )

        for support in [left, right] {
            for orientation in [CGImagePropertyOrientation.up, .right, .left, .down] {
                for mirrored in [false, true] {
                    var detector = VisionFaceDetector { _ in
                        [VisionDetectionObservation(
                            visionBounds: bounds,
                            observedEyeSupport: [support]
                        )]
                    }
                    let result = detector.detect(
                        metadata: metadata(orientation: orientation, inputMirrored: mirrored),
                        imageExtent: CGSize(width: 400, height: 200)
                    )
                    XCTAssertEqual(result.observations.count, 1)
                    XCTAssertEqual(result.observations[0].observedEyeOrder, .canonical)
                    XCTAssertEqual(result.observations[0].observedEyeSupport?.map(\.side), [support.side])
                }
            }
        }
    }

    func testEYE06ProductionDerivedSideOrderRejectsSwappedAndDuplicatePayloads() {
        let bounds = CoordinateRect(x: 0.10, y: 0.10, width: 0.80, height: 0.60)
        let leftAtRight = BeautyObservedEyeSupport(
            side: .left,
            contour: [CoordinatePoint(x: 0.70, y: 0.35), CoordinatePoint(x: 0.76, y: 0.35)]
        )
        let rightAtLeft = BeautyObservedEyeSupport(
            side: .right,
            contour: [CoordinatePoint(x: 0.20, y: 0.35), CoordinatePoint(x: 0.26, y: 0.35)]
        )
        let duplicate = BeautyObservedEyeSupport(
            side: .left,
            contour: [CoordinatePoint(x: 0.20, y: 0.35), CoordinatePoint(x: 0.26, y: 0.35)]
        )
        let malformedDuplicate = BeautyObservedEyeSupport(
            side: .left,
            contour: [CoordinatePoint(x: 1.25, y: 0.35)]
        )

        for supports in [
            [leftAtRight, rightAtLeft],
            [leftAtRight, duplicate],
            [duplicate, malformedDuplicate],
            [leftAtRight],
        ] {
            var detector = VisionFaceDetector { _ in
                [VisionDetectionObservation(visionBounds: bounds, observedEyeSupport: supports)]
            }
            let result = detector.detect(metadata: metadata(orientation: .up))
            XCTAssertEqual(result.observations.count, 1)
            XCTAssertEqual(result.observations[0].observedEyeOrder, .invalid)
        }
    }

    func testEYE05OutOfUnitObservedPointFailsOnlyThatEyeAndPreservesPeerAndLips() {
        let malformedLeft = BeautyObservedEyeSupport(
            side: .left,
            contour: [CoordinatePoint(x: 1.25, y: 0.50)]
        )
        let malformedRight = BeautyObservedEyeSupport(
            side: .right,
            contour: [CoordinatePoint(x: -0.25, y: 0.50)]
        )
        let validLeft = BeautyObservedEyeSupport(
            side: .left,
            contour: [
                CoordinatePoint(x: 0.24, y: 0.48),
                CoordinatePoint(x: 0.34, y: 0.48),
                CoordinatePoint(x: 0.34, y: 0.56),
                CoordinatePoint(x: 0.24, y: 0.56),
            ]
        )
        let validRight = BeautyObservedEyeSupport(
            side: .right,
            contour: [
                CoordinatePoint(x: 0.66, y: 0.48),
                CoordinatePoint(x: 0.76, y: 0.48),
                CoordinatePoint(x: 0.76, y: 0.56),
                CoordinatePoint(x: 0.66, y: 0.56),
            ]
        )
        let lips = BeautyObservedLipSupport(
            outer: [
                CoordinatePoint(x: 0.25, y: 0.20),
                CoordinatePoint(x: 0.75, y: 0.20),
                CoordinatePoint(x: 0.75, y: 0.35),
                CoordinatePoint(x: 0.25, y: 0.35),
            ],
            inner: [
                CoordinatePoint(x: 0.35, y: 0.23),
                CoordinatePoint(x: 0.65, y: 0.23),
                CoordinatePoint(x: 0.65, y: 0.31),
                CoordinatePoint(x: 0.35, y: 0.31),
            ]
        )
        let cases: [([BeautyObservedEyeSupport], BeautyObservedEyeSide)] = [
            ([malformedLeft, validRight], .right),
            ([validLeft, malformedRight], .left),
        ]
        for (supports, survivingSide) in cases {
            var detector = VisionFaceDetector { _ in
                [VisionDetectionObservation(
                    visionBounds: CoordinateRect(x: 0.20, y: 0.20, width: 0.60, height: 0.60),
                    observedEyeSupport: supports,
                    observedLipSupport: lips
                )]
            }

            let result = detector.detect(metadata: metadata(orientation: .up))
            XCTAssertEqual(result.observations.count, 1)
            XCTAssertEqual(result.observations[0].observedEyeSupport?.map(\.side), [survivingSide])
            XCTAssertEqual(result.observations[0].observedEyeOrder, .canonical)
            XCTAssertEqual(result.observations[0].observedLipSupport?.outer?.count, 4)
            XCTAssertEqual(result.observations[0].observedLipSupport?.inner?.count, 4)
            XCTAssertEqual(result.summary.faceCount, 1)
            XCTAssertEqual(result.summary.usedFaceCount, 1)
            XCTAssertFalse(String(describing: result.summary).contains("1.25"))
            XCTAssertFalse(String(describing: result.summary).contains("-0.25"))
            XCTAssertFalse(String(describing: result.summary).contains("left"))
            XCTAssertFalse(String(describing: result.summary).contains("right"))
        }
    }

    func testSUPP02FacePathsCanonicalizeAcrossWindingOrientationAndInputMirror() throws {
        let bounds = CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60)
        let contour = [
            CoordinatePoint(x: 0.10, y: 0.65),
            CoordinatePoint(x: 0.35, y: 0.20),
            CoordinatePoint(x: 0.70, y: 0.15),
            CoordinatePoint(x: 0.95, y: 0.60)
        ]
        let medianLine = [
            CoordinatePoint(x: 0.50, y: 0.90),
            CoordinatePoint(x: 0.48, y: 0.50),
            CoordinatePoint(x: 0.52, y: 0.10)
        ]

        for orientation in [CGImagePropertyOrientation.up, .right, .left, .down] {
            for mirrored in [false, true] {
                let forward = try mappedFaceSupport(
                    contour: contour,
                    medianLine: medianLine,
                    bounds: bounds,
                    orientation: orientation,
                    inputMirrored: mirrored
                )
                let reversed = try mappedFaceSupport(
                    contour: Array(contour.reversed()),
                    medianLine: Array(medianLine.reversed()),
                    bounds: bounds,
                    orientation: orientation,
                    inputMirrored: mirrored
                )

                XCTAssertEqual(forward, reversed)
                XCTAssertEqual(forward.contour?.count, contour.count)
                XCTAssertEqual(forward.medianLine?.count, medianLine.count)
            }
        }
    }

    func testSUPP02CanonicalizationPreservesOpenPathAdjacency() throws {
        let contour = [
            CoordinatePoint(x: 0.10, y: 0.65),
            CoordinatePoint(x: 0.35, y: 0.20),
            CoordinatePoint(x: 0.70, y: 0.15),
            CoordinatePoint(x: 0.95, y: 0.60)
        ]
        let medianLine = [
            CoordinatePoint(x: 0.50, y: 0.90),
            CoordinatePoint(x: 0.48, y: 0.50),
            CoordinatePoint(x: 0.52, y: 0.10)
        ]

        let support = try mappedFaceSupport(
            contour: Array(contour.reversed()),
            medianLine: Array(medianLine.reversed()),
            bounds: CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60),
            orientation: .up
        )
        let mappedContour = try XCTUnwrap(support.contour)
        let mappedMedian = try XCTUnwrap(support.medianLine)

        assertPoint(mappedContour[0], x: 0.25, y: 0.51)
        assertPoint(mappedContour[1], x: 0.375, y: 0.78)
        assertPoint(mappedContour[2], x: 0.55, y: 0.81)
        assertPoint(mappedContour[3], x: 0.675, y: 0.54)
        assertPoint(mappedMedian[0], x: 0.45, y: 0.36)
        assertPoint(mappedMedian[1], x: 0.44, y: 0.60)
        assertPoint(mappedMedian[2], x: 0.46, y: 0.84)
    }

    func testSUPP02PreviewMirroringDoesNotChangeObservedFaceSupport() throws {
        let contour = [
            CoordinatePoint(x: 0.10, y: 0.65),
            CoordinatePoint(x: 0.95, y: 0.60)
        ]
        let medianLine = [
            CoordinatePoint(x: 0.50, y: 0.90),
            CoordinatePoint(x: 0.52, y: 0.10)
        ]
        let regular = try mappedFaceSupport(
            contour: contour,
            medianLine: medianLine,
            bounds: CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60),
            orientation: .right,
            inputMirrored: true,
            previewMirrored: false
        )
        let previewMirrored = try mappedFaceSupport(
            contour: contour,
            medianLine: medianLine,
            bounds: CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60),
            orientation: .right,
            inputMirrored: true,
            previewMirrored: true
        )

        XCTAssertEqual(regular, previewMirrored)
    }

    func testSUPP02ClosedUnitFaceRegionEdgesAreAccepted() throws {
        let support = try mappedFaceSupport(
            contour: [
                CoordinatePoint(x: 0, y: 0),
                CoordinatePoint(x: 1, y: 1)
            ],
            medianLine: [
                CoordinatePoint(x: 0, y: 1),
                CoordinatePoint(x: 1, y: 0)
            ],
            bounds: CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60),
            orientation: .down,
            inputMirrored: true
        )

        XCTAssertEqual(support.contour?.count, 2)
        XCTAssertEqual(support.medianLine?.count, 2)
    }

    func testSUPP02InvalidOrDirectionDegenerateFaceRegionFailsLocally() throws {
        let validContour = [
            CoordinatePoint(x: 0.10, y: 0.65),
            CoordinatePoint(x: 0.95, y: 0.60)
        ]
        let validMedian = [
            CoordinatePoint(x: 0.50, y: 0.90),
            CoordinatePoint(x: 0.52, y: 0.10)
        ]
        let invalidContours = [
            [CoordinatePoint(x: -0.000_001, y: 0.20), CoordinatePoint(x: 0.90, y: 0.20)],
            [CoordinatePoint(x: .infinity, y: 0.20), CoordinatePoint(x: 0.90, y: 0.20)],
            [CoordinatePoint(x: 0.50, y: 0.20), CoordinatePoint(x: 0.50, y: 0.80)]
        ]
        let invalidMedians = [
            [CoordinatePoint(x: 0.50, y: 1.000_001), CoordinatePoint(x: 0.50, y: 0.10)],
            [CoordinatePoint(x: 0.50, y: .nan), CoordinatePoint(x: 0.50, y: 0.10)],
            [CoordinatePoint(x: 0.20, y: 0.50), CoordinatePoint(x: 0.80, y: 0.50)]
        ]
        let bounds = CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60)

        for contour in invalidContours {
            let support = try mappedFaceSupport(
                contour: contour,
                medianLine: validMedian,
                bounds: bounds,
                orientation: .left,
                inputMirrored: true
            )
            XCTAssertNil(support.contour)
            XCTAssertEqual(support.medianLine?.count, validMedian.count)
        }
        for medianLine in invalidMedians {
            let support = try mappedFaceSupport(
                contour: validContour,
                medianLine: medianLine,
                bounds: bounds,
                orientation: .left,
                inputMirrored: true
            )
            XCTAssertEqual(support.contour?.count, validContour.count)
            XCTAssertNil(support.medianLine)
        }
    }

    func testSUPP04ConsecutiveOppositeMetadataDoesNotLeakFaceOrientationState() throws {
        let contour = [
            CoordinatePoint(x: 0.10, y: 0.65),
            CoordinatePoint(x: 0.95, y: 0.60)
        ]
        let medianLine = [
            CoordinatePoint(x: 0.50, y: 0.90),
            CoordinatePoint(x: 0.52, y: 0.10)
        ]
        let bounds = CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60)
        var detector = VisionFaceDetector { _ in
            [VisionDetectionObservation(
                visionBounds: bounds,
                observedFaceSupport: BeautyObservedFaceSupport(
                    contour: contour,
                    medianLine: medianLine
                )
            )]
        }

        let first = detector.detect(metadata: metadata(orientation: .up))
        let second = detector.detect(metadata: metadata(orientation: .down, inputMirrored: true))
        let expectedSecond = try mappedFaceSupport(
            contour: contour,
            medianLine: medianLine,
            bounds: bounds,
            orientation: .down,
            inputMirrored: true
        )

        XCTAssertNotEqual(first.observations.first?.observedFaceSupport, expectedSecond)
        XCTAssertEqual(second.observations.first?.observedFaceSupport, expectedSecond)
    }

    func testSUPP04ParallelDetectorValuesDoNotShareObservedFacePayloads() async {
        let results = await withTaskGroup(
            of: (Int, Int?).self,
            returning: [Int: Int].self
        ) { group in
            for index in 0..<8 {
                group.addTask {
                    let pointCount = index + 2
                    let middle = Array(
                        repeating: CoordinatePoint(x: 0.50, y: 0.30),
                        count: pointCount - 2
                    )
                    let contour = [
                        CoordinatePoint(x: 0.10, y: 0.65)
                    ] + middle + [
                        CoordinatePoint(x: 0.95, y: 0.60)
                    ]
                    var detector = VisionFaceDetector { _ in
                        [VisionDetectionObservation(
                            visionBounds: CoordinateRect(
                                x: 0.20,
                                y: 0.10,
                                width: 0.50,
                                height: 0.60
                            ),
                            observedFaceSupport: BeautyObservedFaceSupport(contour: contour)
                        )]
                    }
                    let orientations: [CGImagePropertyOrientation] = [.up, .right, .left, .down]
                    let result = detector.detect(
                        metadata: BeautyInputMetadata(
                            orientation: orientations[index % orientations.count],
                            isInputMirrored: index >= orientations.count,
                            source: .testFixture
                        )
                    )
                    return (index, result.observations.first?.observedFaceSupport?.contour?.count)
                }
            }

            var collected: [Int: Int] = [:]
            for await (index, count) in group {
                if let count {
                    collected[index] = count
                }
            }
            return collected
        }

        XCTAssertEqual(results.count, 8)
        for index in 0..<8 {
            XCTAssertEqual(results[index], index + 2)
        }
    }

    func testEyebrowCanonicalizationFixtureMatrixIsExactAndSideIndependent() {
        XCTAssertEqual(eyebrowCanonicalizationMatrix.count, 64)
        XCTAssertEqual(eyebrowCanonicalizationMatrix.filter { $0.side == .left }.count, 32)
        XCTAssertEqual(eyebrowCanonicalizationMatrix.filter { $0.side == .right }.count, 32)
        XCTAssertEqual(Set(eyebrowCanonicalizationMatrix.map(\.orientation)), Set([.up, .right, .down, .left]))
        XCTAssertEqual(Set(eyebrowCanonicalizationMatrix.map(\.inputMirrored)), Set([false, true]))
        XCTAssertEqual(Set(eyebrowCanonicalizationMatrix.map(\.previewMirrored)), Set([false, true]))
        XCTAssertEqual(Set(eyebrowCanonicalizationMatrix.map(\.reversed)), Set([false, true]))

        var mapper = EyebrowCountingMapper()
        let mapped = eyebrowCanonicalizationMatrix.prefix(16).map { row in
            mapper.map(row.trace[0])
        }
        XCTAssertEqual(mapped.count, 16)
        XCTAssertEqual(mapper.callCount, 16)
    }

    private func metadata(
        orientation: CGImagePropertyOrientation,
        inputMirrored: Bool = false,
        previewMirrored: Bool = false
    ) -> BeautyInputMetadata {
        BeautyInputMetadata(
            orientation: orientation,
            isInputMirrored: inputMirrored,
            isPreviewMirrored: previewMirrored,
            source: .testFixture
        )
    }

    private func mappedFaceSupport(
        contour: [CoordinatePoint],
        medianLine: [CoordinatePoint],
        bounds: CoordinateRect,
        orientation: CGImagePropertyOrientation,
        inputMirrored: Bool = false,
        previewMirrored: Bool = false
    ) throws -> BeautyObservedFaceSupport {
        var detector = VisionFaceDetector { _ in
            [VisionDetectionObservation(
                visionBounds: bounds,
                observedFaceSupport: BeautyObservedFaceSupport(
                    contour: contour,
                    medianLine: medianLine
                )
            )]
        }
        let result = detector.detect(
            metadata: metadata(
                orientation: orientation,
                inputMirrored: inputMirrored,
                previewMirrored: previewMirrored
            ),
            imageExtent: CGSize(width: 400, height: 200),
            previewExtent: CGSize(width: 200, height: 400)
        )
        return try XCTUnwrap(result.observations.first?.observedFaceSupport)
    }

    func testSUPP02EyebrowSideIdentifierAgreesAcrossMetadataMatrixAndSourceOrder() throws {
        let bounds = CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60)
        for orientation in [CGImagePropertyOrientation.up, .right, .left, .down] {
            for inputMirrored in [false, true] {
                for previewMirrored in [false, true] {
                    for side in [BeautyObservedEyebrowSide.left, .right] {
                        let forwardSupport = BeautyObservedEyebrowSupport(
                            left: side == .left ? fourPointLeftTrace : nil,
                            right: side == .right ? fourPointRightTrace : nil
                        )
                        let reversedSupport = BeautyObservedEyebrowSupport(
                            left: side == .left ? Array(fourPointLeftTrace.reversed()) : nil,
                            right: side == .right ? Array(fourPointRightTrace.reversed()) : nil
                        )

                        var forwardDetector = VisionFaceDetector { _ in
                            [VisionDetectionObservation(
                                visionBounds: bounds,
                                observedEyebrowSupport: forwardSupport
                            )]
                        }
                        var reversedDetector = VisionFaceDetector { _ in
                            [VisionDetectionObservation(
                                visionBounds: bounds,
                                observedEyebrowSupport: reversedSupport
                            )]
                        }
                        let forwardMapped = try XCTUnwrap(
                            forwardDetector.detect(
                                metadata: metadata(
                                    orientation: orientation,
                                    inputMirrored: inputMirrored,
                                    previewMirrored: previewMirrored
                                ),
                                imageExtent: CGSize(width: 400, height: 200),
                                previewExtent: CGSize(width: 200, height: 400)
                            ).observations.first?.observedEyebrowSupport
                        )
                        let reversedMapped = try XCTUnwrap(
                            reversedDetector.detect(
                                metadata: metadata(
                                    orientation: orientation,
                                    inputMirrored: inputMirrored,
                                    previewMirrored: previewMirrored
                                ),
                                imageExtent: CGSize(width: 400, height: 200),
                                previewExtent: CGSize(width: 200, height: 400)
                            ).observations.first?.observedEyebrowSupport
                        )

                        let forwardPoints = try XCTUnwrap(
                            side == .left ? forwardMapped.left : forwardMapped.right
                        )
                        let reversedPoints = try XCTUnwrap(
                            side == .left ? reversedMapped.left : reversedMapped.right
                        )
                        XCTAssertEqual(forwardPoints.count, 4)
                        XCTAssertEqual(reversedPoints.count, 4)
                        XCTAssertEqual(
                            forwardPoints,
                            reversedPoints,
                            "side=\(side), orientation=\(orientation), inputMirrored=\(inputMirrored), previewMirrored=\(previewMirrored)"
                        )
                        switch side {
                        case .left:
                            XCTAssertNotNil(forwardMapped.left)
                            XCTAssertNil(forwardMapped.right)
                        case .right:
                            XCTAssertNil(forwardMapped.left)
                            XCTAssertNotNil(forwardMapped.right)
                        }
                    }
                }
            }
        }
    }

    func testSUPP02EyebrowPointMapCallCountEqualsAcceptedPointCountPlusFourAxisProbes() throws {
        let bounds = CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60)
        for row in eyebrowCanonicalizationMatrix {
            let support = BeautyObservedEyebrowSupport(
                left: row.side == .left ? row.trace : nil,
                right: row.side == .right ? row.trace : nil
            )
            var detector = VisionFaceDetector { _ in
                [VisionDetectionObservation(
                    visionBounds: bounds,
                    observedEyebrowSupport: support
                )]
            }
            let result = detector.detect(
                metadata: metadata(
                    orientation: row.orientation,
                    inputMirrored: row.inputMirrored,
                    previewMirrored: row.previewMirrored
                ),
                imageExtent: CGSize(width: 400, height: 200),
                previewExtent: CGSize(width: 200, height: 400)
            )
            let mapped = try XCTUnwrap(result.observations.first?.observedEyebrowSupport)
            let points = try XCTUnwrap(
                row.side == .left ? mapped.left : mapped.right
            )
            XCTAssertEqual(
                points.count,
                row.trace.count,
                "side=\(row.side), orientation=\(row.orientation), inputMirrored=\(row.inputMirrored), previewMirrored=\(row.previewMirrored), reversed=\(row.reversed)"
            )
        }
    }

    func testSUPP02EyebrowReversalOnlyReversesWholeArrayAndPreservesAdjacency() throws {
        let bounds = CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60)
        for row in eyebrowCanonicalizationMatrix {
            let forwardSupport = BeautyObservedEyebrowSupport(
                left: row.side == .left ? row.trace : nil,
                right: row.side == .right ? row.trace : nil
            )
            let reversedSupport = BeautyObservedEyebrowSupport(
                left: row.side == .left ? Array(row.trace.reversed()) : nil,
                right: row.side == .right ? Array(row.trace.reversed()) : nil
            )
            var forwardDetector = VisionFaceDetector { _ in
                [VisionDetectionObservation(
                    visionBounds: bounds,
                    observedEyebrowSupport: forwardSupport
                )]
            }
            var reversedDetector = VisionFaceDetector { _ in
                [VisionDetectionObservation(
                    visionBounds: bounds,
                    observedEyebrowSupport: reversedSupport
                )]
            }
            let forwardMapped = try XCTUnwrap(
                forwardDetector.detect(
                    metadata: metadata(
                        orientation: row.orientation,
                        inputMirrored: row.inputMirrored,
                        previewMirrored: row.previewMirrored
                    ),
                    imageExtent: CGSize(width: 400, height: 200),
                    previewExtent: CGSize(width: 200, height: 400)
                ).observations.first?.observedEyebrowSupport
            )
            let reversedMapped = try XCTUnwrap(
                reversedDetector.detect(
                    metadata: metadata(
                        orientation: row.orientation,
                        inputMirrored: row.inputMirrored,
                        previewMirrored: row.previewMirrored
                    ),
                    imageExtent: CGSize(width: 400, height: 200),
                    previewExtent: CGSize(width: 200, height: 400)
                ).observations.first?.observedEyebrowSupport
            )
            let forwardPoints = try XCTUnwrap(
                row.side == .left ? forwardMapped.left : forwardMapped.right
            )
            let reversedPoints = try XCTUnwrap(
                row.side == .left ? reversedMapped.left : reversedMapped.right
            )
            XCTAssertEqual(forwardPoints, reversedPoints)
        }
    }

    func testSUPP02EyebrowEpsilonDegenerateEndpointProjectionFailsSideLocally() {
        let epsilonDegenerate = BeautyObservedEyebrowSupport(
            left: [
                CoordinatePoint(x: 0.30, y: 0.30),
                CoordinatePoint(x: 0.30, y: 0.30),
            ],
            right: nil
        )
        var detector = VisionFaceDetector { _ in
            [VisionDetectionObservation(
                visionBounds: CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60),
                observedEyebrowSupport: epsilonDegenerate
            )]
        }
        let result = detector.detect(metadata: metadata(orientation: .up))
        XCTAssertEqual(result.observations.first?.observedEyebrowSupport?.left, nil)
        XCTAssertEqual(result.observations.first?.observedEyebrowSupport?.right, nil)
    }

    func testSUPP02EyebrowBoundaryRejectionProducesZeroPointMapCalls() {
        let provider = EyebrowCallCountingProvider()
        var detector = VisionFaceDetector(observationProvider: provider.call)
        let result = detector.detect(
            metadata: metadata(orientation: .up),
            imageExtent: CGSize(width: 400, height: 200),
            previewExtent: CGSize(width: 200, height: 400)
        )
        XCTAssertEqual(result.observations.first?.observedEyebrowSupport?.left, nil)
        XCTAssertEqual(provider.pointMapCount, 0)
    }

    func testSUPP04EyebrowRequestLifecycleFixturesAreAcceptedWithExpectedCounts() {
        let scenarios: [(EyebrowRequestLifecycleKind, Int?, Int?)] = [
            (.repeated, 4, 4),
            (.alternating, 4, nil),
            (.interrupted, nil, nil),
            (.stale, nil, nil),
            (.noFace, nil, nil),
        ]
        for (kind, expectedLeft, expectedRight) in scenarios {
            let provider = EyebrowLifecycleProvider(kind: kind)
            var detector = VisionFaceDetector(observationProvider: provider.call)
            let result = detector.detect(metadata: metadata(orientation: .up))
            if expectedLeft == nil {
                XCTAssertNil(
                    result.observations.first?.observedEyebrowSupport?.left,
                    "kind=\(kind)"
                )
                XCTAssertNil(
                    result.observations.first?.observedEyebrowSupport?.right,
                    "kind=\(kind)"
                )
            } else if expectedRight == nil {
                XCTAssertEqual(
                    result.observations.first?.observedEyebrowSupport?.left?.count,
                    expectedLeft,
                    "kind=\(kind)"
                )
                XCTAssertNil(
                    result.observations.first?.observedEyebrowSupport?.right,
                    "kind=\(kind)"
                )
            } else {
                XCTAssertEqual(
                    result.observations.first?.observedEyebrowSupport?.left?.count,
                    expectedLeft,
                    "kind=\(kind)"
                )
                XCTAssertEqual(
                    result.observations.first?.observedEyebrowSupport?.right?.count,
                    expectedRight,
                    "kind=\(kind)"
                )
            }
        }
    }

    func testSUPP04ParallelEyebrowRequestsDoNotSharePayloads() async {
        let results = await withTaskGroup(
            of: (Int, Int?).self,
            returning: [Int: Int?].self
        ) { group in
            for index in 0..<8 {
                group.addTask {
                    let left = (0..<(index + 1)).map { i -> CoordinatePoint in
                        let progress = Double(i) / Double(max(1, index))
                        return CoordinatePoint(
                            x: 0.42 - 0.20 * progress,
                            y: 0.34 - 0.04 * progress
                        )
                    }
                    let right = (0..<(index + 1)).map { i -> CoordinatePoint in
                        let progress = Double(i) / Double(max(1, index))
                        return CoordinatePoint(
                            x: 0.58 + 0.20 * progress,
                            y: 0.34 - 0.04 * progress
                        )
                    }
                    var detector = VisionFaceDetector { _ in
                        [VisionDetectionObservation(
                            visionBounds: CoordinateRect(
                                x: 0.20,
                                y: 0.10,
                                width: 0.50,
                                height: 0.60
                            ),
                            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                                left: left,
                                right: right
                            )
                        )]
                    }
                    let orientations: [CGImagePropertyOrientation] = [.up, .right, .left, .down]
                    let result = detector.detect(
                        metadata: BeautyInputMetadata(
                            orientation: orientations[index % orientations.count],
                            isInputMirrored: index >= orientations.count,
                            source: .testFixture
                        )
                    )
                    return (
                        index,
                        result.observations.first?.observedEyebrowSupport?.left?.count
                    )
                }
            }

            var collected: [Int: Int?] = [:]
            for await (index, leftCount) in group {
                collected[index] = leftCount
            }
            return collected
        }

        XCTAssertEqual(results.count, 8)
        for index in 0..<8 {
            XCTAssertEqual(results[index], Optional(index + 1), "index=\(index)")
        }
    }

    private func assertRect(
        _ rect: CoordinateRect?,
        equals expected: CoordinateRect,
        accuracy: Double = 0.000_001,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let rect else {
            XCTFail("Expected mapped image bounds", file: file, line: line)
            return
        }

        XCTAssertEqual(rect.x, expected.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(rect.y, expected.y, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(rect.width, expected.width, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(rect.height, expected.height, accuracy: accuracy, file: file, line: line)
    }

    private func assertPoint(
        _ point: CoordinatePoint,
        x: Double,
        y: Double,
        accuracy: Double = 0.000_001,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(point.x, x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(point.y, y, accuracy: accuracy, file: file, line: line)
    }
}

private enum EyebrowRequestLifecycleKind {
    case repeated
    case alternating
    case interrupted
    case stale
    case noFace
}

private struct EyebrowCountingMapper {
    private(set) var callCount = 0

    mutating func map(_ point: CoordinatePoint) -> CoordinatePoint {
        callCount += 1
        return point
    }
}

private final class EyebrowCallCountingProvider: @unchecked Sendable {
    private(set) var pointMapCount = 0
    private let lock = NSLock()

    func call(_ input: VisionFaceDetectionInput) throws -> [VisionDetectionObservation] {
        let observation = VisionDetectionObservation(
            visionBounds: CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60)
        )
        return [observation]
    }
}

private final class EyebrowLifecycleProvider: @unchecked Sendable {
    private let kind: EyebrowRequestLifecycleKind
    private let lock = NSLock()
    private var invocations = 0

    init(kind: EyebrowRequestLifecycleKind) {
        self.kind = kind
    }

    func call(_ input: VisionFaceDetectionInput) throws -> [VisionDetectionObservation] {
        let invocation = lock.withLock {
            invocations += 1
            return invocations
        }

        let left = [
            CoordinatePoint(x: 0.42, y: 0.34),
            CoordinatePoint(x: 0.36, y: 0.31),
            CoordinatePoint(x: 0.29, y: 0.30),
            CoordinatePoint(x: 0.22, y: 0.33),
        ]
        let right = [
            CoordinatePoint(x: 0.58, y: 0.34),
            CoordinatePoint(x: 0.64, y: 0.31),
            CoordinatePoint(x: 0.71, y: 0.30),
            CoordinatePoint(x: 0.78, y: 0.33),
        ]

        let support: BeautyObservedEyebrowSupport?
        switch kind {
        case .repeated:
            support = BeautyObservedEyebrowSupport(left: left, right: right)
        case .alternating:
            support = BeautyObservedEyebrowSupport(left: left, right: nil)
        case .interrupted, .stale, .noFace:
            support = nil
        }
        return [
            VisionDetectionObservation(
                visionBounds: CoordinateRect(x: 0.20, y: 0.10, width: 0.50, height: 0.60),
                observedEyebrowSupport: support
            )
        ]
    }
}

private struct EyebrowCanonicalizationFixture {
    let side: BeautyObservedEyebrowSide
    let orientation: CGImagePropertyOrientation
    let inputMirrored: Bool
    let previewMirrored: Bool
    let reversed: Bool
    let trace: [CoordinatePoint]
}

private let eyebrowCanonicalizationMatrix: [EyebrowCanonicalizationFixture] = {
    let left = [
        CoordinatePoint(x: 0.42, y: 0.34), CoordinatePoint(x: 0.36, y: 0.31),
        CoordinatePoint(x: 0.29, y: 0.30), CoordinatePoint(x: 0.22, y: 0.33),
    ]
    let right = [
        CoordinatePoint(x: 0.58, y: 0.34), CoordinatePoint(x: 0.64, y: 0.31),
        CoordinatePoint(x: 0.71, y: 0.30), CoordinatePoint(x: 0.78, y: 0.33),
    ]
    return [BeautyObservedEyebrowSide.left, .right].flatMap { side in
        [CGImagePropertyOrientation.up, .right, .down, .left].flatMap { orientation in
            [false, true].flatMap { inputMirrored in
                [false, true].flatMap { previewMirrored in
                    [false, true].map { reversed in
                        let original = side == .left ? left : right
                        return EyebrowCanonicalizationFixture(
                            side: side,
                            orientation: orientation,
                            inputMirrored: inputMirrored,
                            previewMirrored: previewMirrored,
                            reversed: reversed,
                            trace: reversed ? Array(original.reversed()) : original
                        )
                    }
                }
            }
        }
    }
}()

private let fourPointLeftTrace: [CoordinatePoint] = [
    CoordinatePoint(x: 0.42, y: 0.34), CoordinatePoint(x: 0.36, y: 0.31),
    CoordinatePoint(x: 0.29, y: 0.30), CoordinatePoint(x: 0.22, y: 0.33),
]

private let fourPointRightTrace: [CoordinatePoint] = [
    CoordinatePoint(x: 0.58, y: 0.34), CoordinatePoint(x: 0.64, y: 0.31),
    CoordinatePoint(x: 0.71, y: 0.30), CoordinatePoint(x: 0.78, y: 0.33),
]
