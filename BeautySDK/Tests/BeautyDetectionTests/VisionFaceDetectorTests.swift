import CoreImage
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

    func testDefaultStillImageProviderMapsUsableFaceWithoutRawPayload() throws {
        var detector = VisionFaceDetector()
        var summaries: [String] = []

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
                XCTAssertGreaterThanOrEqual(result.summary.faceCount, 1)
                XCTAssertEqual(result.summary.usedFaceCount, 1)
                XCTAssertEqual(result.observations.count, 1)
                return
            }
        }

        XCTFail("Expected at least one portrait fixture to produce usable redacted detection; summaries=\(summaries.joined(separator: ","))")
    }

    private func metadata() -> BeautyInputMetadata {
        BeautyInputMetadata(
            orientation: .up,
            source: .testFixture
        )
    }

    private func portraitFixtureURLs() throws -> [URL] {
        let inputDirectory = try repositoryRootURL().appendingPathComponent("example-images/input", isDirectory: true)
        return try (1...5).map { index in
            let fixtureName = "e\(index).png"
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
            let candidate = current.appendingPathComponent("example-images/input/e1.png")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return current
            }
            current.deleteLastPathComponent()
        }
        throw FixtureError.missing("example-images/input/e1.png")
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
