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

        for supports in [[leftAtRight, rightAtLeft], [leftAtRight, duplicate]] {
            var detector = VisionFaceDetector { _ in
                [VisionDetectionObservation(visionBounds: bounds, observedEyeSupport: supports)]
            }
            let result = detector.detect(metadata: metadata(orientation: .up))
            XCTAssertEqual(result.observations.count, 1)
            XCTAssertEqual(result.observations[0].observedEyeOrder, .invalid)
        }
    }

    func testEYE05OutOfUnitObservedPointFailsClosedWithRedactedSummary() {
        let malformed = BeautyObservedEyeSupport(
            side: .left,
            contour: [CoordinatePoint(x: 1.25, y: 0.50)]
        )
        var detector = VisionFaceDetector { _ in
            [VisionDetectionObservation(
                visionBounds: CoordinateRect(x: 0.20, y: 0.20, width: 0.60, height: 0.60),
                observedEyeSupport: [malformed]
            )]
        }

        let result = detector.detect(metadata: metadata(orientation: .up))
        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .partial)
        XCTAssertEqual(result.summary.reasons, [.mappingFailed])
        XCTAssertEqual(result.summary.faceCount, 1)
        XCTAssertEqual(result.summary.usedFaceCount, 0)
        XCTAssertFalse(String(describing: result.summary).contains("1.25"))
        XCTAssertFalse(String(describing: result.summary).contains("left"))
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
