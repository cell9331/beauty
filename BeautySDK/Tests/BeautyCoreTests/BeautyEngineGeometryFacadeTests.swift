import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyEngineGeometryFacadeTests: XCTestCase {
    func testGEOMFourIndependentFieldsRouteThroughObservedSupportAndRedactedFacade() throws {
        let rows: [(name: String, parameters: BeautyParameters)] = [
            ("faceContourSmooth", BeautyParameters(faceContourSmooth: 0.20)),
            ("templeFullness", BeautyParameters(templeFullness: 0.20)),
            ("cheekboneSlim", BeautyParameters(cheekboneSlim: 0.20)),
            ("chinTaper", BeautyParameters(chinTaper: 0.20)),
        ]
        let expectedMetricKeys: Set<String> = [
            "beauty.detection.geometryRequired",
            "beauty.detection.faceCount",
            "beauty.detection.usedFaceCount",
            "beauty.effects.activeCount",
            "beauty.effects.cappedCount",
            "beauty.effects.geometryPointCount",
        ]

        for row in rows {
            let provider = SDKTestingFaceDetectionProvider([.usableFace])
            let engine = try BeautyEngine(faceDetectionProvider: provider)
            let result = try engine.processResult(
                image: Self.image,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                parameters: row.parameters
            )

            XCTAssertEqual(provider.invocationCount, 1, row.name)
            XCTAssertEqual(result.output.extent, Self.image.extent, row.name)
            XCTAssertEqual(result.detectionSummary?.availability, .usable, row.name)
            XCTAssertEqual(result.detectionSummary?.reasons, [], row.name)
            XCTAssertEqual(result.detectionSummary?.faceCount, 1, row.name)
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1, row.name)
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1, row.name)
            XCTAssertEqual(result.metrics["beauty.detection.faceCount"], 1, row.name)
            XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 1, row.name)
            XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 1, row.name)
            XCTAssertEqual(result.metrics["beauty.effects.cappedCount"], 0, row.name)
            XCTAssertGreaterThan(
                result.metrics["beauty.effects.geometryPointCount"] ?? 0,
                0,
                row.name
            )
            XCTAssertEqual(Set(result.metrics.keys), expectedMetricKeys, row.name)
            XCTAssertTrue(result.warnings.isEmpty, row.name)
            assertRedacted(result)
            assertPhase46ObservedSupportRedacted(result, name: row.name)
        }
    }

    func testGEOMUsableFacadeFixturePreservesShippedFaceAndChinEvidenceAtNewFieldZero() throws {
        let rows: [(
            name: String,
            baseline: BeautyParameters,
            explicitZero: BeautyParameters,
            expectedPointCount: Double
        )] = [
            (
                "faceSlim",
                BeautyParameters(faceSlim: 0.20),
                BeautyParameters(
                    faceSlim: 0.20,
                    faceContourSmooth: 0,
                    templeFullness: 0,
                    cheekboneSlim: 0,
                    chinTaper: 0
                ),
                2
            ),
            (
                "chinLength positive",
                BeautyParameters(chinLength: 0.20),
                BeautyParameters(
                    chinLength: 0.20,
                    faceContourSmooth: 0,
                    templeFullness: 0,
                    cheekboneSlim: 0,
                    chinTaper: 0
                ),
                1
            ),
            (
                "chinLength negative",
                BeautyParameters(chinLength: -0.20),
                BeautyParameters(
                    chinLength: -0.20,
                    faceContourSmooth: 0,
                    templeFullness: 0,
                    cheekboneSlim: 0,
                    chinTaper: 0
                ),
                1
            ),
        ]

        for row in rows {
            let baselineProvider = SDKTestingFaceDetectionProvider([.usableFace])
            let baselineEngine = try BeautyEngine(faceDetectionProvider: baselineProvider)
            let baseline = try baselineEngine.processResult(
                image: Self.image,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                parameters: row.baseline
            )

            let explicitProvider = SDKTestingFaceDetectionProvider([.usableFace])
            let explicitEngine = try BeautyEngine(faceDetectionProvider: explicitProvider)
            let explicit = try explicitEngine.processResult(
                image: Self.image,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                parameters: row.explicitZero
            )

            XCTAssertEqual(baselineProvider.invocationCount, 1, "baseline \(row.name)")
            XCTAssertEqual(explicitProvider.invocationCount, 1, "explicit zero \(row.name)")
            XCTAssertEqual(baseline.output.extent, Self.image.extent, row.name)
            XCTAssertEqual(explicit.output.extent, Self.image.extent, row.name)
            XCTAssertEqual(baseline.detectionSummary?.availability, .usable, row.name)
            XCTAssertEqual(explicit.detectionSummary, baseline.detectionSummary, row.name)
            XCTAssertEqual(
                baseline.metrics["beauty.effects.geometryPointCount"],
                row.expectedPointCount,
                "known shipped provider count \(row.name)"
            )
            XCTAssertEqual(
                explicit.metrics["beauty.effects.geometryPointCount"],
                row.expectedPointCount,
                "explicit-zero shipped provider count \(row.name)"
            )
            XCTAssertEqual(explicit.metrics, baseline.metrics, "metric drift \(row.name)")
            XCTAssertEqual(explicit.warnings, baseline.warnings, "warning drift \(row.name)")
            assertRedacted(baseline)
            assertRedacted(explicit)
            assertPhase46ObservedSupportRedacted(baseline, name: "baseline \(row.name)")
            assertPhase46ObservedSupportRedacted(explicit, name: "explicit zero \(row.name)")
        }
    }

    func testOUT03MissingAndMalformedObservedContourRemoveNewWorkWhileShippedSiblingContinues() throws {
        let fixtures: [(name: String, value: SDKTestingFaceDetectionFixture)] = [
            ("missing", .missingObservedFaceContour),
            ("malformed", .malformedObservedFaceContour),
        ]
        let requests: [(name: String, make: () -> BeautyParameters)] = [
            (
                "faceContourSmooth",
                { BeautyParameters(faceSlim: 0.20, faceContourSmooth: 0.25) }
            ),
            (
                "templeFullness",
                { BeautyParameters(faceSlim: 0.20, templeFullness: 0.25) }
            ),
            (
                "cheekboneSlim",
                { BeautyParameters(faceSlim: 0.20, cheekboneSlim: 0.25) }
            ),
            (
                "chinTaper",
                { BeautyParameters(faceSlim: 0.20, chinTaper: 0.25) }
            ),
        ]

        for fixture in fixtures {
            for request in requests {
                let baselineProvider = SDKTestingFaceDetectionProvider([fixture.value])
                let baselineEngine = try BeautyEngine(faceDetectionProvider: baselineProvider)
                let baseline = try baselineEngine.processResult(
                    image: Self.image,
                    metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                    parameters: BeautyParameters(faceSlim: 0.20)
                )

                let requestedProvider = SDKTestingFaceDetectionProvider([fixture.value])
                let requestedEngine = try BeautyEngine(faceDetectionProvider: requestedProvider)
                let requested = try requestedEngine.processResult(
                    image: Self.image,
                    metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                    parameters: request.make()
                )
                let label = "\(fixture.name) \(request.name)"

                XCTAssertEqual(baselineProvider.invocationCount, 1, "baseline \(label)")
                XCTAssertEqual(requestedProvider.invocationCount, 1, label)
                XCTAssertEqual(requested.output.extent, Self.image.extent, label)
                XCTAssertEqual(requested.detectionSummary?.availability, .usable, label)
                XCTAssertEqual(requested.detectionSummary, baseline.detectionSummary, label)
                XCTAssertEqual(requested.metrics, baseline.metrics, label)
                XCTAssertEqual(requested.warnings, baseline.warnings, label)
                XCTAssertEqual(requested.metrics["beauty.effects.activeCount"], 1, label)
                XCTAssertEqual(requested.metrics["beauty.effects.geometryPointCount"], 2, label)
                XCTAssertEqual(
                    renderedRGBABytes(from: requested.output),
                    renderedRGBABytes(from: baseline.output),
                    label
                )
                assertRedacted(requested)
                assertPhase46ObservedSupportRedacted(requested, name: label)
            }
        }
    }

    func testPhase38MOUTH08FiveIndependentFieldsRouteThroughRedactedPublicFacade() throws {
        let cases: [(String, BeautyParameters)] = [
            ("mouthYPosition", BeautyParameters(mouthYPosition: 1)),
            ("mouthTilt", BeautyParameters(mouthTilt: 1)),
            ("mouthXPosition", BeautyParameters(mouthXPosition: 1)),
            ("lipPeakDefinition", BeautyParameters(lipPeakDefinition: 1)),
            ("lipPlump", BeautyParameters(lipPlump: 1)),
        ]

        for (name, parameters) in cases {
            let provider = SDKTestingFaceDetectionProvider([.usableFace])
            let engine = try BeautyEngine(faceDetectionProvider: provider)
            let result = try engine.processResult(
                image: Self.image,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                parameters: parameters
            )

            XCTAssertEqual(provider.invocationCount, 1, name)
            XCTAssertEqual(result.output.extent, Self.image.extent, name)
            XCTAssertEqual(result.detectionSummary?.availability, .usable, name)
            XCTAssertEqual(result.detectionSummary?.faceCount, 1, name)
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1, name)
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1, name)
            XCTAssertEqual(result.metrics["beauty.detection.faceCount"], 1, name)
            XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 1, name)
            XCTAssertGreaterThan(result.metrics["beauty.effects.geometryPointCount"] ?? 0, 0, name)
            assertRedacted(result)

            let metadata = (
                result.warnings.map { "\($0.code) \($0.message)" } +
                Array(result.metrics.keys) +
                (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
            ).joined(separator: " ").lowercased()
            for forbidden in [
                "upperlips", "lowerlips", "innerlips", "support", "coordinate",
                "landmark", "controlpoint", "control point", "simd", "bounds",
                "provider", "vnface", "nsobject", "framework", "/private/", "file://",
            ] {
                XCTAssertFalse(metadata.contains(forbidden), "\(name): unexpected payload term \(forbidden)")
            }
        }
    }

    func testPhase35NOSE03IndependentNoseFieldsRouteThroughRedactedPublicFacade() throws {
        let cases = [
            BeautyParameters(noseRootNarrowing: 1),
            BeautyParameters(noseTipLift: 1),
        ]

        for parameters in cases {
            let provider = SDKTestingFaceDetectionProvider([.usableFace])
            let engine = try BeautyEngine(faceDetectionProvider: provider)
            let result = try engine.processResult(
                image: Self.image,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                parameters: parameters
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

            let metadata = (
                result.warnings.map { "\($0.code) \($0.message)" } +
                Array(result.metrics.keys) +
                (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
            ).joined(separator: " ").lowercased()
            for forbidden in [
                "noseroot", "nosetip", "support", "coordinate", "landmark",
                "controlpoint", "control point", "simd", "bounds", "bounding",
            ] {
                XCTAssertFalse(metadata.contains(forbidden), "Unexpected geometry payload term: \(forbidden)")
            }
        }
    }

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
        let spatialImage = spatialFixtureImage(width: 160, height: 160)

        let baseline = try engine.processResult(
            image: spatialImage,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: BeautyParameters()
        )
        let geometry = try engine.processResult(
            image: spatialImage,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: phase27FaceShapeParameters()
        )
        let repeatedGeometry = try engine.processResult(
            image: spatialImage,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: phase27FaceShapeParameters()
        )

        XCTAssertEqual(provider.invocationCount, 2)
        XCTAssertEqual(baseline.output.extent, spatialImage.extent)
        XCTAssertEqual(geometry.output.extent, spatialImage.extent)
        XCTAssertEqual(repeatedGeometry.output.extent, spatialImage.extent)
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

    func testEyeNoFaceRequestPreservesExtentSafeDomainsAndRedactedMetadata() throws {
        let provider = SDKTestingFaceDetectionProvider([.noFace])
        let engine = try BeautyEngine(faceDetectionProvider: provider)

        let result = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: BeautyParameters(
                brightness: 0.2,
                eyeSize: 1,
                eyeDistance: -1,
                eyeYPosition: 1,
                eyeTailLift: 1,
                eyeHeight: 1,
                eyeLength: 1,
                upperEyelidLift: 1,
                pupilSize: 1,
                gazeCorrection: 1,
                lowerEyelidDrop: 1,
                eyeTilt: -1,
                innerCornerOpen: 1,
                outerCornerOpen: 1,
                eyeSymmetry: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            )
        )

        XCTAssertEqual(provider.invocationCount, 1)
        XCTAssertEqual(result.output.extent, Self.image.extent)
        XCTAssertEqual(result.detectionSummary?.availability, .noFace)
        XCTAssertEqual(result.detectionSummary?.reasons, [.noFaceDetected])
        XCTAssertEqual(result.detectionSummary?.faceCount, 0)
        XCTAssertEqual(result.detectionSummary?.usedFaceCount, 0)
        XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
        XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 2)
        XCTAssertEqual(result.metrics["beauty.effects.skippedEyeDomains"], 1)
        XCTAssertEqual(result.metrics["beauty.effects.cappedCount"], 14)
        XCTAssertNil(result.metrics["beauty.effects.geometryPointCount"])
        XCTAssertEqual(result.warnings.filter { $0.code == "face_effects_skipped_no_face" }.count, 1)
        XCTAssertEqual(result.warnings.filter { $0.code == "beauty_strength_capped" }.count, 1)
        assertRedacted(result)
        assertNoEyeSideOrRawGeometryDisclosure(result)
    }

    func testNOSE11AllSixNoseFieldsNoFacePreserveExtentSafeDomainsAndRedactedMetadata() throws {
        let provider = SDKTestingFaceDetectionProvider([.noFace])
        let engine = try BeautyEngine(faceDetectionProvider: provider)

        let result = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: BeautyParameters(
                brightness: 0.2,
                noseSlim: 1,
                noseWingSlim: 1,
                noseTipSize: -1,
                noseBridge: 1,
                noseRootNarrowing: 1,
                noseTipLift: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            )
        )

        XCTAssertEqual(provider.invocationCount, 1)
        XCTAssertEqual(result.output.extent, Self.image.extent)
        XCTAssertEqual(result.detectionSummary?.availability, .noFace)
        XCTAssertEqual(result.detectionSummary?.reasons, [.noFaceDetected])
        XCTAssertEqual(result.detectionSummary?.faceCount, 0)
        XCTAssertEqual(result.detectionSummary?.usedFaceCount, 0)
        XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
        XCTAssertEqual(result.metrics["beauty.detection.faceCount"], 0)
        XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 0)
        XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 2)
        XCTAssertEqual(result.metrics["beauty.effects.skippedNoseDomains"], 1)
        XCTAssertEqual(result.metrics["beauty.effects.cappedCount"], 6)
        XCTAssertNil(result.metrics["beauty.effects.geometryPointCount"])
        XCTAssertEqual(result.warnings.filter { $0.code == "face_effects_skipped_no_face" }.count, 1)
        XCTAssertEqual(result.warnings.filter { $0.code == "beauty_strength_capped" }.count, 1)
        XCTAssertFalse(result.warnings.contains { $0.code == "nose_inputs_missing" })
        assertRedacted(result)
        assertNoNoseFieldOrRawGeometryDisclosure(result)
    }

    func testMOUTH13AllEightMouthFieldsNoFacePreserveExtentAndSafeDomains() throws {
        let provider = SDKTestingFaceDetectionProvider([.noFace])
        let engine = try BeautyEngine(faceDetectionProvider: provider)
        let result = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: BeautyParameters(
                brightness: 0.2,
                mouthSize: -1,
                mouthWidth: 1,
                smile: 1,
                mouthYPosition: -1,
                mouthTilt: 1,
                mouthXPosition: -1,
                lipPeakDefinition: 1,
                lipPlump: 1,
                lipColor: 1,
                filterId: "soft_clean",
                filterIntensity: 0.5
            )
        )

        XCTAssertEqual(provider.invocationCount, 1)
        XCTAssertEqual(result.output.extent, Self.image.extent)
        XCTAssertEqual(result.detectionSummary?.availability, .noFace)
        XCTAssertEqual(result.detectionSummary?.reasons, [.noFaceDetected])
        XCTAssertEqual(result.detectionSummary?.faceCount, 0)
        XCTAssertEqual(result.detectionSummary?.usedFaceCount, 0)
        XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
        XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 2)
        XCTAssertEqual(result.metrics["beauty.effects.skippedMouthDomains"], 1)
        XCTAssertEqual(result.metrics["beauty.effects.skippedLipDomains"], 1)
        XCTAssertEqual(result.metrics["beauty.effects.cappedCount"], 9)
        XCTAssertNil(result.metrics["beauty.effects.geometryPointCount"])
        XCTAssertEqual(result.warnings.filter { $0.code == "face_effects_skipped_no_face" }.count, 1)
        XCTAssertEqual(result.warnings.filter { $0.code == "beauty_strength_capped" }.count, 1)
        assertRedacted(result)
    }

    func testBROW09SevenIndependentEyebrowFieldsRouteThroughRedactedPublicFacade() throws {
        let rows: [(String, BeautyParameters)] = [
            ("eyebrowYPosition", BeautyParameters(eyebrowYPosition: -1)),
            ("eyebrowThickness", BeautyParameters(eyebrowThickness: 1)),
            ("eyebrowLength", BeautyParameters(eyebrowLength: -1)),
            ("eyebrowSpacing", BeautyParameters(eyebrowSpacing: 1)),
            ("eyebrowHeadSpacing", BeautyParameters(eyebrowHeadSpacing: -1)),
            ("eyebrowTilt", BeautyParameters(eyebrowTilt: 1)),
            ("eyebrowPeakDefinition", BeautyParameters(eyebrowPeakDefinition: 1)),
        ]

        for (name, parameters) in rows {
            let provider = SDKTestingFaceDetectionProvider([.pairedObservedEyebrows])
            let engine = try BeautyEngine(faceDetectionProvider: provider)
            let result = try engine.processResult(
                image: Self.image,
                metadata: BeautyInputMetadata(orientation: .up, source: .photo),
                parameters: parameters
            )

            XCTAssertEqual(provider.invocationCount, 1, name)
            XCTAssertEqual(result.output.extent, Self.image.extent, name)
            XCTAssertEqual(result.detectionSummary?.availability, .usable, name)
            XCTAssertEqual(result.detectionSummary?.faceCount, 1, name)
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1, name)
            XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1, name)
            XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 1, name)
            XCTAssertGreaterThan(result.metrics["beauty.effects.geometryPointCount"] ?? 0, 0, name)
            XCTAssertFalse(result.warnings.contains { $0.code == "eyebrow_inputs_missing" }, name)
            assertRedacted(result)
            assertEyebrowFacadeRedacted(result, name: name)
        }
    }

    func testBROW09SidePairMissingMalformedAndSequentialFixturesDegradeLocally() throws {
        let perSide = BeautyParameters(eyebrowYPosition: 1)
        let pairOnly = BeautyParameters(eyebrowSpacing: 1)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        for fixture in [SDKTestingFaceDetectionFixture.leftOnlyObservedEyebrow, .rightOnlyObservedEyebrow] {
            let sideProvider = SDKTestingFaceDetectionProvider([fixture])
            let sideEngine = try BeautyEngine(faceDetectionProvider: sideProvider)
            let sideResult = try sideEngine.processResult(image: Self.image, metadata: metadata, parameters: perSide)
            XCTAssertGreaterThan(sideResult.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
            XCTAssertEqual(sideResult.metrics["beauty.effects.activeCount"], 1)

            let pairProvider = SDKTestingFaceDetectionProvider([fixture])
            let pairEngine = try BeautyEngine(faceDetectionProvider: pairProvider)
            let pairResult = try pairEngine.processResult(image: Self.image, metadata: metadata, parameters: pairOnly)
            XCTAssertNil(pairResult.metrics["beauty.effects.geometryPointCount"])
            XCTAssertEqual(pairResult.metrics["beauty.effects.skippedEyebrowDomains"], 1)
            assertEyebrowFacadeRedacted(sideResult, name: "per-side")
            assertEyebrowFacadeRedacted(pairResult, name: "pair-only")
        }

        for fixture in [SDKTestingFaceDetectionFixture.missingObservedEyebrows, .malformedObservedEyebrows] {
            let provider = SDKTestingFaceDetectionProvider([fixture])
            let engine = try BeautyEngine(faceDetectionProvider: provider)
            let result = try engine.processResult(
                image: Self.image,
                metadata: metadata,
                parameters: BeautyParameters(brightness: 0.2, eyebrowYPosition: 1)
            )
            XCTAssertEqual(result.output.extent, Self.image.extent)
            XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 1, "safe color sibling continues")
            XCTAssertEqual(result.metrics["beauty.effects.skippedEyebrowDomains"], 1)
            XCTAssertNil(result.metrics["beauty.effects.geometryPointCount"])
            assertEyebrowFacadeRedacted(result, name: "missing or malformed")
        }

        let provider = SDKTestingFaceDetectionProvider([
            .pairedObservedEyebrows, .missingObservedEyebrows, .pairedObservedEyebrows,
        ])
        let engine = try BeautyEngine(faceDetectionProvider: provider)
        let first = try engine.processResult(image: Self.image, metadata: metadata, parameters: perSide)
        let middle = try engine.processResult(image: Self.image, metadata: metadata, parameters: perSide)
        let last = try engine.processResult(image: Self.image, metadata: metadata, parameters: perSide)
        XCTAssertEqual(provider.invocationCount, 3)
        XCTAssertGreaterThan(first.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
        XCTAssertNil(middle.metrics["beauty.effects.geometryPointCount"])
        XCTAssertEqual(last.metrics, first.metrics, "valid-missing-valid must not carry support")
        XCTAssertEqual(last.warnings, first.warnings)
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

    private func spatialFixtureImage(width: Int, height: Int) -> CIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        return CIImage(
            bitmapData: Data(gradientRGBABytes(width: width, height: height)),
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    private func gradientRGBABytes(width: Int, height: Int) -> [UInt8] {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(width * height * 4)
        for row in 0..<height {
            for column in 0..<width {
                bytes.append(UInt8(column * 255 / max(width - 1, 1)))
                bytes.append(UInt8(row * 255 / max(height - 1, 1)))
                bytes.append(UInt8((column + row) * 255 / max(width + height - 2, 1)))
                bytes.append(255)
            }
        }
        return bytes
    }

    private func portraitFixtureURLs() throws -> [URL] {
        let inputDirectory = try repositoryRootURL().appendingPathComponent("example-images/input/portraits", isDirectory: true)
        let fixtureNames = ["e6.jpg"]
        return try fixtureNames.map { fixtureName in
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
            let candidate = current.appendingPathComponent("example-images/input/portraits/e6.jpg")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return current
            }
            current.deleteLastPathComponent()
        }
        throw FacadeFixtureError.missing("example-images/input/portraits/e6.jpg")
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

    private func assertNoEyeSideOrRawGeometryDisclosure(
        _ result: BeautyResult<CIImage>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()
        for term in [
            "left", "right", "eye side", "landmark", "coordinate", "bounding", "bounds",
            "control point", "path", "image bytes", "raw",
        ] {
            XCTAssertFalse(metadata.contains(term), "Unexpected sensitive term: \(term)", file: file, line: line)
        }
    }

    private func assertNoNoseFieldOrRawGeometryDisclosure(
        _ result: BeautyResult<CIImage>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()
        for term in [
            "noseroot", "nosetip", "support", "landmark", "coordinate", "bounding", "bounds",
            "control point", "controlpoint", "path", "image bytes", "detector", "provider",
            "facegeometry", "simd", "raw",
        ] {
            XCTAssertFalse(metadata.contains(term), "Unexpected sensitive term: \(term)", file: file, line: line)
        }
    }

    private func assertPhase46ObservedSupportRedacted(
        _ result: BeautyResult<CIImage>,
        name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let metadata = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()
        for term in [
            "facecontour", "median", "apex", "index", "pathprogress",
            "source", "target", "radius", "falloff", "displacement",
            "support", "coordinate", "bounds", "simd", "provider",
            "vnface", "vnrequest", "vnfacelandmark", "cgpoint", "cgrect",
            "ciimage", "nsobject", "nserror", "averror", "framework",
            "/private/", "/users/", "/var/", "file://",
        ] {
            XCTAssertFalse(
                metadata.contains(term),
                "\(name): unexpected payload term \(term)",
                file: file,
                line: line
            )
        }
    }

    private func assertEyebrowFacadeRedacted(
        _ result: BeautyResult<CIImage>,
        name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var dumped = ""
        dump(result, to: &dumped)
        let mirrorLabels = Mirror(reflecting: result).children.compactMap(\.label).joined(separator: " ")
        let evidence = ([
            String(describing: result), String(reflecting: result), dumped, mirrorLabels,
        ] + result.warnings.map { "\($0.code) \($0.message)" } + Array(result.metrics.keys))
            .joined(separator: " ").lowercased()
        for term in [
            "lefteyebrow", "righteyebrow", "endpoint", "center", "apex", "axis", "normal",
            "vector", "controlpoint", "facegeometry", "eyebrowwarpprovider", "simd", "coordinate",
        ] {
            XCTAssertFalse(evidence.contains(term), "\(name): unexpected raw eyebrow term \(term)", file: file, line: line)
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
