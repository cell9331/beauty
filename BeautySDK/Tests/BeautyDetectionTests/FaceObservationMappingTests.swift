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

    private func metadata(
        orientation: CGImagePropertyOrientation,
        inputMirrored: Bool = false
    ) -> BeautyInputMetadata {
        BeautyInputMetadata(
            orientation: orientation,
            isInputMirrored: inputMirrored,
            source: .testFixture
        )
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
}
