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

    private static let image = CIImage(color: CIColor(red: 0.35, green: 0.25, blue: 0.20, alpha: 1))
        .cropped(to: CGRect(x: 0, y: 0, width: 2, height: 2))

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
