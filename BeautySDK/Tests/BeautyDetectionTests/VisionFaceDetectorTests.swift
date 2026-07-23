import CoreImage
import Foundation
import ImageIO
import XCTest
import BeautyCore
@testable import BeautyDetection

final class VisionFaceDetectorTests: XCTestCase {
    func testPIPE07NoObservationsReturnsNoFaceSummary() {
        var detector = VisionFaceDetector { _ in [] }

        let result = detector.detect(metadata: metadata())

        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .noFace)
        XCTAssertEqual(result.summary.reasons, [.noFaceDetected])
        XCTAssertEqual(result.summary.faceCount, 0)
        XCTAssertEqual(result.summary.usedFaceCount, 0)
    }

    func testPIPE07LowConfidenceObservationReturnsLowConfidenceSummary() {
        var detector = VisionFaceDetector { _ in
            [
                VisionDetectionObservation(
                    stableID: "low",
                    confidence: 0.20,
                    normalizedArea: 0.40,
                    landmarks: .complete
                )
            ]
        }

        let result = detector.detect(metadata: metadata())

        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .lowConfidence)
        XCTAssertEqual(result.summary.reasons, [.lowConfidenceFace])
        XCTAssertEqual(result.summary.faceCount, 1)
        XCTAssertEqual(result.summary.usedFaceCount, 0)
    }

    func testPIPE07MissingRequiredLandmarksReturnsPartialSummary() {
        var detector = VisionFaceDetector { _ in
            [
                VisionDetectionObservation(
                    stableID: "partial",
                    confidence: 0.90,
                    normalizedArea: 0.40,
                    landmarks: .missingRequiredGeometry
                )
            ]
        }

        let result = detector.detect(metadata: metadata())

        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .partial)
        XCTAssertEqual(result.summary.reasons, [.missingLandmarks])
        XCTAssertEqual(result.summary.faceCount, 1)
        XCTAssertEqual(result.summary.usedFaceCount, 0)
    }

    func testPhase38MOUTH04MissingOnlyInnerLipsRemainsUsableAndSelected() {
        let groups = Set(BeautyLandmarkGroup.allCases).subtracting([.innerLips])
        let landmarks = BeautyFaceLandmarks(availableGroups: groups)
        XCTAssertTrue(landmarks.hasRequiredGeometry)
        XCTAssertFalse(landmarks.availableGroups.contains(.innerLips))
        XCTAssertTrue(landmarks.availableGroups.contains(.outerLips))

        var detector = VisionFaceDetector { _ in
            [
                VisionDetectionObservation(
                    stableID: "outer-only",
                    confidence: 0.95,
                    normalizedArea: 0.40,
                    landmarks: landmarks
                )
            ]
        }

        let result = detector.detect(metadata: metadata())

        XCTAssertEqual(result.observations.map(\.stableID), ["outer-only"])
        XCTAssertEqual(result.summary.availability, .usable)
        XCTAssertEqual(result.summary.reasons, [])
        XCTAssertEqual(result.summary.faceCount, 1)
        XCTAssertEqual(result.summary.usedFaceCount, 1)
        assertNoRawVisionDiagnostics(in: String(describing: result.summary))
    }

    func testPhase38MOUTH04MissingOuterLipsRemainsPartialWhenInnerLipsIsAvailable() {
        let groups = Set(BeautyLandmarkGroup.allCases).subtracting([.outerLips])
        let landmarks = BeautyFaceLandmarks(availableGroups: groups)
        XCTAssertFalse(landmarks.hasRequiredGeometry)
        XCTAssertTrue(landmarks.availableGroups.contains(.innerLips))

        var detector = VisionFaceDetector { _ in
            [
                VisionDetectionObservation(
                    stableID: "inner-only",
                    confidence: 0.95,
                    normalizedArea: 0.40,
                    landmarks: landmarks
                )
            ]
        }

        let result = detector.detect(metadata: metadata())

        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .partial)
        XCTAssertEqual(result.summary.reasons, [.missingLandmarks])
        XCTAssertEqual(result.summary.faceCount, 1)
        XCTAssertEqual(result.summary.usedFaceCount, 0)
        assertNoRawVisionDiagnostics(in: String(describing: result.summary))
    }

    func testPIPE07UsableObservationsUseSelectionPolicyAndPublicCounts() {
        var detector = VisionFaceDetector { _ in
            [
                VisionDetectionObservation(stableID: "a", confidence: 0.95, normalizedArea: 0.40),
                VisionDetectionObservation(stableID: "b", confidence: 0.95, normalizedArea: 0.30)
            ]
        }

        let result = detector.detect(
            metadata: metadata(),
            configuration: BeautyConfiguration(maximumFaceCount: 1)
        )

        XCTAssertEqual(result.observations.map(\.stableID), ["a"])
        XCTAssertEqual(result.summary.availability, .usable)
        XCTAssertEqual(result.summary.reasons, [.faceLimitApplied])
        XCTAssertEqual(result.summary.faceCount, 2)
        XCTAssertEqual(result.summary.usedFaceCount, 1)
    }

    func testEYE05InjectedObservedSupportMapsBothSidesAndKeepsMissingPupilAbsent() {
        let left = BeautyObservedEyeSupport(
            side: .left,
            contour: [CoordinatePoint(x: 0.20, y: 0.20), CoordinatePoint(x: 0.30, y: 0.20)],
            pupil: nil
        )
        let right = BeautyObservedEyeSupport(
            side: .right,
            contour: [CoordinatePoint(x: 0.60, y: 0.20), CoordinatePoint(x: 0.70, y: 0.20)],
            pupil: [CoordinatePoint(x: 0.65, y: 0.20)]
        )
        var detector = VisionFaceDetector { _ in
            [VisionDetectionObservation(
                visionBounds: CoordinateRect(x: 0.10, y: 0.20, width: 0.80, height: 0.60),
                observedEyeSupport: [left, right]
            )]
        }

        let result = detector.detect(metadata: metadata())
        let support = result.observations[0].observedEyeSupport

        XCTAssertEqual(support?.map(\.side), [.left, .right])
        XCTAssertNil(support?.first(where: { $0.side == .left })?.pupil)
        guard let pupil = support?.first(where: { $0.side == .right })?.pupil,
              let point = pupil.first
        else {
            XCTFail("Expected one mapped right-eye pupil point")
            return
        }
        XCTAssertEqual(pupil.count, 1)
        XCTAssertEqual(point.x, 0.62, accuracy: 0.000_001)
        XCTAssertEqual(point.y, 0.68, accuracy: 0.000_001)
    }

    func testEYE05ObservedSupportWithoutFiniteFaceBoundsFailsClosed() {
        let support = BeautyObservedEyeSupport(
            side: .left,
            contour: [CoordinatePoint(x: 0.20, y: 0.20)]
        )
        var detector = VisionFaceDetector { _ in
            [VisionDetectionObservation(observedEyeSupport: [support])]
        }

        let result = detector.detect(metadata: metadata())

        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .partial)
        XCTAssertEqual(result.summary.reasons, [.mappingFailed])
        XCTAssertFalse(String(describing: result.summary).contains("CoordinateRect"))
    }

    func testSUPP01InjectedContourAndMedianMapExactlyOnceIntoImageCoordinates() throws {
        let support = BeautyObservedFaceSupport(
            contour: [
                CoordinatePoint(x: 0.10, y: 0.20),
                CoordinatePoint(x: 0.90, y: 0.20)
            ],
            medianLine: [
                CoordinatePoint(x: 0.50, y: 0.90),
                CoordinatePoint(x: 0.50, y: 0.10)
            ]
        )
        var detector = VisionFaceDetector { _ in
            [VisionDetectionObservation(
                visionBounds: CoordinateRect(x: 0.10, y: 0.20, width: 0.80, height: 0.60),
                observedFaceSupport: support
            )]
        }

        let result = detector.detect(metadata: metadata())
        let mapped = try XCTUnwrap(result.observations.first?.observedFaceSupport)
        let contour = try XCTUnwrap(mapped.contour)
        let medianLine = try XCTUnwrap(mapped.medianLine)

        assertPoint(contour[0], x: 0.18, y: 0.68)
        assertPoint(contour[1], x: 0.82, y: 0.68)
        assertPoint(medianLine[0], x: 0.50, y: 0.26)
        assertPoint(medianLine[1], x: 0.50, y: 0.74)
    }

    func testSUPP02NilAndSingleFaceRegionsRemainIndependent() {
        let contour = [
            CoordinatePoint(x: 0.10, y: 0.20),
            CoordinatePoint(x: 0.90, y: 0.20)
        ]
        let medianLine = [
            CoordinatePoint(x: 0.50, y: 0.90),
            CoordinatePoint(x: 0.50, y: 0.10)
        ]
        let cases: [(BeautyObservedFaceSupport?, Bool, Bool)] = [
            (BeautyObservedFaceSupport(contour: contour), true, false),
            (BeautyObservedFaceSupport(medianLine: medianLine), false, true),
            (BeautyObservedFaceSupport(), false, false),
            (nil, false, false)
        ]

        for (support, expectsContour, expectsMedian) in cases {
            var detector = VisionFaceDetector { _ in
                [VisionDetectionObservation(
                    visionBounds: CoordinateRect(x: 0.10, y: 0.20, width: 0.80, height: 0.60),
                    observedFaceSupport: support
                )]
            }

            let mapped = detector.detect(metadata: metadata())
                .observations.first?.observedFaceSupport
            XCTAssertEqual(mapped?.contour != nil, expectsContour)
            XCTAssertEqual(mapped?.medianLine != nil, expectsMedian)
            XCTAssertEqual(mapped != nil, expectsContour || expectsMedian)
        }
    }

    func testSUPP02MalformedOrOversizedContourPreservesValidMedianAndFace() {
        let validMedian = [
            CoordinatePoint(x: 0.50, y: 0.90),
            CoordinatePoint(x: 0.50, y: 0.10)
        ]
        let invalidContours = [
            [CoordinatePoint(x: .nan, y: 0.20), CoordinatePoint(x: 0.90, y: 0.20)],
            Array(repeating: CoordinatePoint(x: 0.50, y: 0.50), count: 33)
        ]

        for contour in invalidContours {
            var detector = VisionFaceDetector { _ in
                [VisionDetectionObservation(
                    visionBounds: CoordinateRect(x: 0.10, y: 0.20, width: 0.80, height: 0.60),
                    observedFaceSupport: BeautyObservedFaceSupport(
                        contour: contour,
                        medianLine: validMedian
                    )
                )]
            }

            let result = detector.detect(metadata: metadata())
            XCTAssertEqual(result.observations.count, 1)
            XCTAssertNil(result.observations[0].observedFaceSupport?.contour)
            XCTAssertEqual(result.observations[0].observedFaceSupport?.medianLine?.count, 2)
        }
    }

    func testSUPP02MalformedOrOversizedMedianPreservesValidContourAndFace() {
        let validContour = [
            CoordinatePoint(x: 0.10, y: 0.20),
            CoordinatePoint(x: 0.90, y: 0.20)
        ]
        let invalidMedians = [
            [CoordinatePoint(x: 0.50, y: -0.01), CoordinatePoint(x: 0.50, y: 0.10)],
            Array(repeating: CoordinatePoint(x: 0.50, y: 0.50), count: 17)
        ]

        for medianLine in invalidMedians {
            var detector = VisionFaceDetector { _ in
                [VisionDetectionObservation(
                    visionBounds: CoordinateRect(x: 0.10, y: 0.20, width: 0.80, height: 0.60),
                    observedFaceSupport: BeautyObservedFaceSupport(
                        contour: validContour,
                        medianLine: medianLine
                    )
                )]
            }

            let result = detector.detect(metadata: metadata())
            XCTAssertEqual(result.observations.count, 1)
            XCTAssertEqual(result.observations[0].observedFaceSupport?.contour?.count, 2)
            XCTAssertNil(result.observations[0].observedFaceSupport?.medianLine)
        }
    }

    func testSUPP02FaceSupportWithInvalidSharedBoundsKeepsObservationLevelFailure() {
        var detector = VisionFaceDetector { _ in
            [VisionDetectionObservation(
                observedFaceSupport: BeautyObservedFaceSupport(
                    contour: [
                        CoordinatePoint(x: 0.10, y: 0.20),
                        CoordinatePoint(x: 0.90, y: 0.20)
                    ]
                )
            )]
        }

        let result = detector.detect(metadata: metadata())

        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .partial)
        XCTAssertEqual(result.summary.reasons, [.mappingFailed])
        assertNoRawVisionDiagnostics(in: String(describing: result.summary))
    }

    func testSUPP04ConsecutiveRequestsCallProviderOnceAndRetainNoPriorFaceSupport() {
        let provider = FaceSupportObservationProvider()
        var detector = VisionFaceDetector(observationProvider: provider.call)

        let first = detector.detect(metadata: metadata())
        let second = detector.detect(metadata: metadata())

        XCTAssertEqual(provider.invocationCount, 2)
        XCTAssertNotNil(first.observations.first?.observedFaceSupport?.contour)
        XCTAssertNil(second.observations.first?.observedFaceSupport)
    }

    func testPIPE07DetectorUnavailableFailureUsesStructuredReasonOnly() {
        var detector = VisionFaceDetector { _ in
            throw VisionFaceDetector.Failure.detectorUnavailable
        }

        let result = detector.detect(metadata: metadata())

        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .skipped)
        XCTAssertEqual(result.summary.reasons, [.detectorUnavailable])
        assertNoRawVisionDiagnostics(in: String(describing: result.summary))
    }

    func testPIPE07DetectionTimeoutFailureUsesStructuredReasonOnly() {
        var detector = VisionFaceDetector { _ in
            throw VisionFaceDetector.Failure.detectionTimedOut
        }

        let result = detector.detect(metadata: metadata())

        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .skipped)
        XCTAssertEqual(result.summary.reasons, [.detectionTimedOut])
        assertNoRawVisionDiagnostics(in: String(describing: result.summary))
    }

    func testDefaultStillImageProviderReturnsRedactedNoFaceForNoFaceFixture() {
        var detector = VisionFaceDetector()
        let image = CIImage(color: CIColor(red: 0.10, green: 0.12, blue: 0.15, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 64, height: 64))

        let result = detector.detect(
            image: image,
            metadata: metadata(),
            imageExtent: image.extent.size
        )

        XCTAssertEqual(result.observations, [])
        XCTAssertEqual(result.summary.availability, .noFace)
        XCTAssertEqual(result.summary.reasons, [.noFaceDetected])
        XCTAssertEqual(result.summary.faceCount, 0)
        XCTAssertEqual(result.summary.usedFaceCount, 0)
        assertNoRawVisionDiagnostics(in: String(describing: result.summary))
    }

    func testDefaultStillImageProviderReportsAggregateObservedFaceAvailabilityWithoutRawPayload() throws {
        var detector = VisionFaceDetector()
        var summaries: [String] = []
        var usableFaceCount = 0
        var completeSupportCount = 0

        for fixtureURL in try portraitFixtureURLs() {
            guard let image = CIImage(contentsOf: fixtureURL, options: [.applyOrientationProperty: true]) else {
                throw FixtureError.unreadable(fixtureURL.lastPathComponent)
            }

            let result = detector.detect(
                image: image,
                metadata: metadata(),
                imageExtent: image.extent.size
            )
            summaries.append("\(fixtureURL.lastPathComponent):\(result.summary.availability.rawValue)")
            assertNoRawVisionDiagnostics(in: String(describing: result.summary))

            if result.summary.availability == .usable {
                usableFaceCount += result.observations.count
                XCTAssertGreaterThanOrEqual(result.summary.faceCount, 1)
                XCTAssertEqual(result.summary.usedFaceCount, 1)
                XCTAssertEqual(result.observations.count, 1)
                if result.observations.first?.observedFaceSupport?.contour != nil,
                   result.observations.first?.observedFaceSupport?.medianLine != nil {
                    completeSupportCount += 1
                }
            }
        }

        XCTAssertGreaterThan(usableFaceCount, 0, "Expected usable aggregate detection; summaries=\(summaries.joined(separator: ","))")
        XCTAssertGreaterThan(completeSupportCount, 0, "Expected complete aggregate observed-face support")
    }

    private func metadata() -> BeautyInputMetadata {
        BeautyInputMetadata(
            orientation: .up,
            source: .testFixture
        )
    }

    private func portraitFixtureURLs() throws -> [URL] {
        let inputDirectory = try repositoryRootURL().appendingPathComponent("example-images/input/portraits", isDirectory: true)
        let fixtureNames = [
            "e1.png",
            "e2.png",
            "e3.png",
            "e4.png",
            "e5.png",
            "e6.jpg"
        ]
        return try fixtureNames.map { fixtureName in
            let url = inputDirectory.appendingPathComponent(fixtureName)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw FixtureError.missing(fixtureName)
            }
            return url
        }
    }

    private func repositoryRootURL() throws -> URL {
        var current = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        while current.path != "/" {
            let candidate = current.appendingPathComponent("example-images/input/portraits/e1.png")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return current
            }
            current.deleteLastPathComponent()
        }
        throw FixtureError.missing("example-images/input/portraits/e1.png")
    }

    private func assertNoRawVisionDiagnostics(
        in diagnostic: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let forbiddenTokens = ["VNFaceObservation", "boundingBox", "landmark", "NSError", "/"]
        for token in forbiddenTokens {
            XCTAssertFalse(
                diagnostic.contains(token),
                "diagnostic leaked \(token): \(diagnostic)",
                file: file,
                line: line
            )
        }
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

private final class FaceSupportObservationProvider: @unchecked Sendable {
    private let lock = NSLock()
    private var invocations = 0

    var invocationCount: Int {
        lock.withLock { invocations }
    }

    func call(_ input: VisionFaceDetectionInput) throws -> [VisionDetectionObservation] {
        let invocation = lock.withLock {
            invocations += 1
            return invocations
        }
        let support = invocation == 1
            ? BeautyObservedFaceSupport(
                contour: [
                    CoordinatePoint(x: 0.10, y: 0.20),
                    CoordinatePoint(x: 0.90, y: 0.20)
                ]
            )
            : nil
        return [
            VisionDetectionObservation(
                visionBounds: CoordinateRect(x: 0.10, y: 0.20, width: 0.80, height: 0.60),
                observedFaceSupport: support
            )
        ]
    }
}

private enum FixtureError: Error, CustomStringConvertible {
    case missing(String)
    case unreadable(String)

    var description: String {
        switch self {
        case .missing(let name):
            "Missing required fixture: \(name)"
        case .unreadable(let name):
            "Could not read required fixture: \(name)"
        }
    }
}
