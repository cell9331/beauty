import CoreImage
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyEngineGeometryFacadeTests: XCTestCase {
    func testGeometryTriggeredStillImageRunsDetectionAndRoutesSelectedFace() throws {
        let provider = SDKTestingFaceDetectionProvider([.usableFace])
        let engine = try BeautyEngine(faceDetectionProvider: provider)

        let result = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            parameters: BeautyParameters(
                brightness: 0.2,
                faceSlim: 0.4,
                eyeSize: 0.4,
                noseSlim: 0.4,
                mouthSize: 0.4,
                lipColor: 0.4
            )
        )

        XCTAssertEqual(provider.invocationCount, 1)
        XCTAssertEqual(result.output.extent, Self.image.extent)
        XCTAssertEqual(result.detectionSummary?.availability, .usable)
        XCTAssertEqual(result.detectionSummary?.faceCount, 1)
        XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1)
        XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
        XCTAssertEqual(result.metrics["beauty.detection.faceCount"], 1)
        XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 1)
        XCTAssertGreaterThan(result.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        assertRedacted(result)
    }

    func testNoGeometryStillImageParametersDoNotRunDetection() throws {
        let provider = SDKTestingFaceDetectionProvider([.usableFace])
        let engine = try BeautyEngine(faceDetectionProvider: provider)
        let inputs = [
            BeautyParameters(),
            BeautyParameters(skinSmoothing: 0.4),
            BeautyParameters(brightness: 0.2),
            BeautyParameters(filterId: "soft_clean", filterIntensity: 0.5)
        ]

        for parameters in inputs {
            let result = try engine.processResult(
                image: Self.image,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                parameters: parameters
            )
            XCTAssertEqual(result.detectionSummary?.availability, .notRun)
            XCTAssertNil(result.metrics["beauty.detection.geometryRequired"])
        }

        XCTAssertEqual(provider.invocationCount, 0)
    }

    func testDisabledTrackingAvoidsDetectorAndSkipsFaceDependentDomains() throws {
        let provider = SDKTestingFaceDetectionProvider([.usableFace])
        let engine = try BeautyEngine(
            configuration: BeautyConfiguration(enableFaceTracking: false),
            faceDetectionProvider: provider
        )

        let result = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            parameters: geometryAndSafeParameters()
        )

        XCTAssertEqual(provider.invocationCount, 0)
        XCTAssertEqual(result.detectionSummary?.availability, .disabled)
        XCTAssertTrue(result.metrics["beauty.effects.activeCount"] ?? 0 >= 2)
        XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
        XCTAssertFalse(result.warnings.isEmpty)
        assertRedacted(result)
    }

    func testGeometryTriggeredDetectionDegradesAndKeepsSafeDomainsActive() throws {
        let cases: [(SDKTestingFaceDetectionFixture, DetectionAvailability, DetectionDegradationReason)] = [
            (.noFace, .noFace, .noFaceDetected),
            (.lowConfidence, .lowConfidence, .lowConfidenceFace),
            (.missingLandmarks, .partial, .missingLandmarks),
            (.detectorUnavailable, .skipped, .detectorUnavailable),
            (.detectionTimedOut, .skipped, .detectionTimedOut)
        ]

        for (fixture, availability, reason) in cases {
            let provider = SDKTestingFaceDetectionProvider([fixture])
            let engine = try BeautyEngine(faceDetectionProvider: provider)

            let result = try engine.processResult(
                image: Self.image,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                parameters: geometryAndSafeParameters()
            )

            XCTAssertEqual(provider.invocationCount, 1)
            XCTAssertEqual(result.output.extent, Self.image.extent)
            XCTAssertEqual(result.detectionSummary?.availability, availability)
            XCTAssertEqual(result.detectionSummary?.reasons, [reason])
            XCTAssertTrue((result.metrics["beauty.effects.activeCount"] ?? 0) >= 2)
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
            XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 0)
            XCTAssertTrue(result.warnings.contains { $0.code == "face_effects_skipped_no_face" })
            assertRedacted(result)
        }
    }

    func testExistingExampleImageFixtureProducesUsableFaceForGeometryCase() throws {
        let engine = try BeautyEngine(configuration: .default)
        var summaries: [String] = []

        for fixtureURL in try portraitFixtureURLs() {
            let input = try fixtureImage(at: fixtureURL)
            let result = try engine.processResult(
                image: input,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                parameters: phase27FaceShapeParameters()
            )
            summaries.append("\(fixtureURL.lastPathComponent):\(result.detectionSummary?.availability.rawValue ?? "nil")")
            assertRedacted(result)

            guard result.detectionSummary?.availability == .usable else {
                continue
            }

            XCTAssertEqual(result.output.extent, input.extent)
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1)
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
            return
        }

        XCTFail("Expected at least one portrait fixture to produce usable public-facade detection; summaries=\(summaries.joined(separator: ","))")
    }

    func testRealDetectionMetadataStaysRedactedForGeometryCase() throws {
        let engine = try BeautyEngine(configuration: .default)

        for fixtureURL in try portraitFixtureURLs() {
            let input = try fixtureImage(at: fixtureURL)
            let result = try engine.processResult(
                image: input,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                parameters: phase27FaceShapeParameters()
            )

            XCTAssertEqual(result.output.extent, input.extent)
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
            assertRedacted(result)
        }
    }

    func testSelectedFaceGeometryChangesImageBeforeWatermarkComparedToNoGeometryBaseline() throws {
        let provider = SDKTestingFaceDetectionProvider([.usableFace, .usableFace])
        let engine = try BeautyEngine(faceDetectionProvider: provider)

        let baseline = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: BeautyParameters()
        )
        let geometry = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: phase27FaceShapeParameters()
        )
        let repeatedGeometry = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: phase27FaceShapeParameters()
        )

        XCTAssertEqual(provider.invocationCount, 2)
        XCTAssertEqual(baseline.output.extent, Self.image.extent)
        XCTAssertEqual(geometry.output.extent, Self.image.extent)
        XCTAssertEqual(repeatedGeometry.output.extent, Self.image.extent)
        XCTAssertEqual(geometry.detectionSummary?.availability, .usable)
        XCTAssertEqual(geometry.detectionSummary?.usedFaceCount, 1)
        XCTAssertEqual(geometry.metrics["beauty.detection.geometryRequired"], 1)
        XCTAssertGreaterThan(geometry.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)

        XCTAssertNotEqual(
            renderedRGBABytes(from: geometry.output),
            renderedRGBABytes(from: baseline.output)
        )
        XCTAssertEqual(
            renderedRGBABytes(from: geometry.output),
            renderedRGBABytes(from: repeatedGeometry.output)
        )
        assertRedacted(geometry)
    }

    func testNoFaceGeometryRequestPreservesDimensionsAndRedactedDegradation() throws {
        let provider = SDKTestingFaceDetectionProvider([.noFace])
        let engine = try BeautyEngine(faceDetectionProvider: provider)

        let result = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: phase27FaceShapeParameters()
        )

        XCTAssertEqual(provider.invocationCount, 1)
        XCTAssertEqual(result.output.extent, Self.image.extent)
        XCTAssertEqual(result.detectionSummary?.availability, .noFace)
        XCTAssertEqual(result.detectionSummary?.reasons, [.noFaceDetected])
        XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
        XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 0)
        XCTAssertTrue(result.warnings.contains { $0.code == "face_effects_skipped_no_face" })
        assertRedacted(result)
    }

    private static let image = CIImage(color: CIColor(red: 0.35, green: 0.25, blue: 0.20, alpha: 1))
        .cropped(to: CGRect(x: 0, y: 0, width: 2, height: 2))

    private func phase27FaceShapeParameters() -> BeautyParameters {
        BeautyParameters(
            faceSlim: 0.35,
            faceSmall: 0.30,
            faceVShape: 0.35,
            jawSlim: 0.30,
            chinLength: 0.20
        )
    }

    private func geometryAndSafeParameters() -> BeautyParameters {
        BeautyParameters(
            brightness: 0.2,
            faceSlim: 0.4,
            eyeSize: 0.4,
            noseSlim: 0.4,
            mouthSize: 0.4,
            lipColor: 0.4,
            filterId: "soft_clean",
            filterIntensity: 0.5
        )
    }

    private func portraitFixtureURLs() throws -> [URL] {
        let inputDirectory = try repositoryRootURL().appendingPathComponent("example-images/input", isDirectory: true)
        return try (1...5).map { index in
            let fixtureName = "e\(index).png"
            let url = inputDirectory.appendingPathComponent(fixtureName)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw FacadeFixtureError.missing(fixtureName)
            }
            return url
        }
    }

    private func fixtureImage(at url: URL) throws -> CIImage {
        guard let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]) else {
            throw FacadeFixtureError.unreadable(url.lastPathComponent)
        }
        return image
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
        throw FacadeFixtureError.missing("example-images/input/e1.png")
    }

    private func renderedRGBABytes(from image: CIImage) -> [UInt8] {
        let extent = image.extent
        let width = Int(extent.width.rounded(.toNearestOrAwayFromZero))
        let height = Int(extent.height.rounded(.toNearestOrAwayFromZero))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace
        ])
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        context.render(
            image,
            toBitmap: &bytes,
            rowBytes: width * 4,
            bounds: extent,
            format: .RGBA8,
            colorSpace: colorSpace
        )
        return bytes
    }

    private func assertRedacted(
        _ result: BeautyResult<CIImage>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ")

        for forbidden in [
            "VNFaceObservation",
            "boundingBox",
            "controlPoint",
            "/private/var",
            "NSError",
            "AVError",
            "rawPresetJson",
            "raw JSON",
            "image bytes",
            "landmarks=",
            "landmarkCoordinates",
            "rawLandmark",
            "SIMD"
        ] {
            XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)", file: file, line: line)
        }
    }
}

private enum FacadeFixtureError: Error, CustomStringConvertible {
    case missing(String)
    case unreadable(String)

    var description: String {
        switch self {
        case .missing(let name):
            "Missing required facade fixture: \(name)"
        case .unreadable(let name):
            "Could not read required facade fixture: \(name)"
        }
    }
}
