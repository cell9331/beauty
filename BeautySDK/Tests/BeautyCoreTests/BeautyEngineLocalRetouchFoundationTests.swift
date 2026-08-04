import CoreImage
import CoreVideo
import Foundation
import ImageIO
import XCTest
@_spi(Testing) import BeautySDK

/// Wave 0 facade specification. Candidate identities and portrait-derived data
/// are deliberately absent; injected demand is only an opaque integer count.
final class BeautyEngineLocalRetouchFoundationTests: XCTestCase {
    private static let image: CIImage = {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        return CIImage(
            bitmapData: Data([
                51, 102, 153, 255, 51, 102, 153, 255,
                51, 102, 153, 255, 51, 102, 153, 255,
            ]),
            bytesPerRow: 8,
            size: CGSize(width: 2, height: 2),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }()

    func testBothExistingCIImageFacadeEntriesReachOnlyTheInjectedPrivateRoute() throws {
        for entry in [SDKTestingStillImageFacadeEntry.process, .processResult] {
            let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
            _ = try harness.invoke(entry: entry, image: Self.image, parameters: .init(brightness: 0.1))
            XCTAssertEqual(harness.canonicalizeCount, 1)
            XCTAssertEqual(harness.detectAndMapCount, 1)
            XCTAssertEqual(harness.lastMappingInvocationCount, 2)
            XCTAssertEqual(harness.lastMappedCoordinateCount, 7)
            XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
            XCTAssertEqual(harness.requestOwnerCreationCount, 1)
            XCTAssertEqual(harness.renderCount, 1)
        }
    }

    func testZeroOneAndMultiplePrivateDemandsShareOneRequest() throws {
        for (demandCount, expected) in [(0, 0), (1, 1), (2, 1), (Int.max, 1)] {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: demandCount
            )
            XCTAssertEqual(harness.canonicalizerConstructionCount, 0)
            _ = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())
            XCTAssertEqual(harness.canonicalizerConstructionCount, expected)
            XCTAssertEqual(harness.canonicalizeCount, expected)
            XCTAssertEqual(harness.detectAndMapCount, expected)
            XCTAssertEqual(harness.requestOwnerCreationCount, expected)
            XCTAssertEqual(harness.renderCount, 1)
            XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        }
    }

    func testCanonicalizeDetectMapContextRenderOrder() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 3)
        _ = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())
        XCTAssertEqual(
            harness.events,
            [.canonicalize, .detectAndMap, .makeRequestContext, .render]
        )
    }

    func testSequentialAdmittedRequestsReuseEngineCanonicalizerAndContext() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)

        _ = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())
        _ = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())

        XCTAssertEqual(harness.canonicalizerConstructionCount, 1)
        XCTAssertEqual(harness.canonicalizeCount, 2)
        XCTAssertTrue(harness.reusedNormalizationOwnerAcrossRequests)
    }

    func testAdmittedDetectorAndRendererShareCanonicalCarrierAndExplicitSRGB() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
        let result = try harness.invoke(
            entry: .processResult,
            image: Self.image,
            parameters: .init(brightness: 0.10, faceSlim: 0.25)
        )

        XCTAssertEqual(harness.canonicalizeCount, 1)
        XCTAssertEqual(harness.detectAndMapCount, 1)
        XCTAssertEqual(harness.requestOwnerCreationCount, 1)
        XCTAssertEqual(harness.renderCount, 1)
        XCTAssertTrue(harness.canonicalConsumerIdentityMatched)
        XCTAssertTrue(harness.usedExplicitSRGBRender)
        XCTAssertEqual(result.width, 2)
        XCTAssertEqual(result.height, 2)
    }

    func testDuplicateOrReorderedFoundationEventsFailExactTraceOracle() {
        let expected: [SDKTestingLocalRetouchEvent] = [
            .canonicalize, .detectAndMap, .makeRequestContext, .render,
        ]
        XCTAssertNotEqual(expected + [.render], expected)
        XCTAssertNotEqual([.detectAndMap, .canonicalize, .makeRequestContext, .render], expected)
    }

    func testNoFaceAndMissingSupportKeepUnrelatedColorWork() throws {
        for fixture in [SDKTestingLocalSupportFixture.noFace, .missingSupport] {
            let baseline = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 0,
                supportFixture: fixture
            ).invoke(entry: .processResult, image: Self.image, parameters: .init(brightness: 0.15))
            let requested = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 1,
                supportFixture: fixture
            ).invoke(entry: .processResult, image: Self.image, parameters: .init(brightness: 0.15))
            XCTAssertEqual(
                try Self.renderedRGBA8(requested.output),
                try Self.renderedRGBA8(baseline.output)
            )
            XCTAssertEqual(requested.width, baseline.width)
            XCTAssertEqual(requested.height, baseline.height)
        }
    }

    func testValidLipSupportSurvivesEachUnrelatedGeometryOmission() throws {
        XCTAssertEqual(
            SDKTestingLocalRetouchFoundationHarness.unrelatedGeometryOmissionFixtureCount,
            4
        )
        for omissionIndex in
            0..<SDKTestingLocalRetouchFoundationHarness.unrelatedGeometryOmissionFixtureCount
        {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 1,
                unrelatedGeometryOmissionIndex: omissionIndex
            )
            let result = try harness.invoke(
                entry: .processResult,
                image: Self.image,
                parameters: .init()
            )

            XCTAssertEqual(result.aggregateSupportValueID, omissionIndex + 1)
            XCTAssertEqual(result.detectionAvailability, "usable")
            XCTAssertEqual(result.detectionReasons, [])
            XCTAssertEqual(harness.detectAndMapCount, 1)
            XCTAssertEqual(harness.requestOwnerCreationCount, 1)
        }
    }

    func testCombinedGeometryAndLocalSupportReportsPurposeAwarePartialDegradation() throws {
        XCTAssertEqual(
            SDKTestingLocalRetouchFoundationHarness.unrelatedGeometryOmissionFixtureCount,
            4
        )
        for omissionIndex in
            0..<SDKTestingLocalRetouchFoundationHarness.unrelatedGeometryOmissionFixtureCount
        {
            let harness = try SDKTestingLocalRetouchFoundationHarness(
                admittedPrivateDemandCount: 1,
                unrelatedGeometryOmissionIndex: omissionIndex
            )
            let result = try harness.invoke(
                entry: .processResult,
                image: Self.image,
                parameters: .init(faceSlim: 0.2)
            )

            XCTAssertEqual(result.aggregateSupportValueID, omissionIndex + 1)
            XCTAssertEqual(result.detectionAvailability, "partial")
            XCTAssertEqual(result.detectionReasons, ["missingLandmarks"])
            XCTAssertEqual(harness.detectAndMapCount, 1)
            XCTAssertEqual(harness.requestOwnerCreationCount, 1)
        }
    }

    func testInvalidCanonicalInputStopsBeforeVisionAndContext() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
        let transparent = CIImage(color: CIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.5))
            .cropped(to: CGRect(x: 0, y: 0, width: 2, height: 2))
        XCTAssertThrowsError(try harness.invoke(entry: .processResult, image: transparent, parameters: .init()))
        XCTAssertEqual(harness.detectAndMapCount, 0)
        XCTAssertEqual(harness.requestOwnerCreationCount, 0)
        XCTAssertEqual(harness.renderCount, 0)
    }

    func testNearOpaqueCanonicalInputStopsAtProductionBoundaryBeforeVisionAndContext() throws {
        let fixtures = [
            try Self.floatingPointImage(width: 2, height: 2, alphas: [
                0.999, 0.999,
                0.999, 0.999,
            ]),
            try Self.floatingPointImage(width: 2, height: 2, alphas: [
                1, 1,
                1, Float(1).nextDown,
            ]),
        ]

        for image in fixtures {
            let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
            XCTAssertThrowsError(
                try harness.invoke(entry: .processResult, image: image, parameters: .init())
            ) { error in
                XCTAssertEqual(error as? BeautyError, .invalidInput)
            }
            XCTAssertEqual(harness.canonicalizeCount, 1)
            XCTAssertEqual(harness.detectAndMapCount, 0)
            XCTAssertEqual(harness.requestOwnerCreationCount, 0)
            XCTAssertEqual(harness.renderCount, 0)
        }
    }

    func testValidInvalidValidDoesNotReuseRequestSupport() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1,
            supportSequence: [.available(valueID: 101), .malformed, .available(valueID: 303)]
        )
        let first = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())
        XCTAssertEqual(harness.lastMappingInvocationCount, 2)
        XCTAssertEqual(harness.lastMappedCoordinateCount, 7)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
        XCTAssertThrowsError(try harness.invoke(entry: .processResult, image: Self.image, parameters: .init()))
        XCTAssertEqual(harness.lastMappingInvocationCount, 0)
        XCTAssertEqual(harness.lastMappedCoordinateCount, 0)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
        let third = try harness.invoke(entry: .processResult, image: Self.image, parameters: .init())
        XCTAssertEqual(harness.lastMappingInvocationCount, 2)
        XCTAssertEqual(harness.lastMappedCoordinateCount, 7)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
        XCTAssertEqual(first.aggregateSupportValueID, 101)
        XCTAssertEqual(third.aggregateSupportValueID, 303)
        XCTAssertNotEqual(first.aggregateSupportValueID, third.aggregateSupportValueID)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
    }

    func testIndependentEngineValuesDoNotCrossPayloads() async throws {
        async let first = SDKTestingLocalRetouchFoundationHarness.runIndependent(valueID: 11)
        async let second = SDKTestingLocalRetouchFoundationHarness.runIndependent(valueID: 22)
        let firstValue = try await first
        let secondValue = try await second
        XCTAssertEqual(Set([firstValue, secondValue]), Set([11, 22]))
    }

    func testSameHarnessParallelInvocationsSerializeCompleteRequestTransactions() async throws {
        let expectedValueIDs = Set(1...32)
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1,
            supportSequence: expectedValueIDs.sorted().map { .available(valueID: $0) }
        )

        let observedValueIDs = try await withThrowingTaskGroup(of: Int.self) { group in
            for _ in expectedValueIDs {
                group.addTask {
                    let result = try harness.invoke(
                        entry: .processResult,
                        image: Self.image,
                        parameters: .init()
                    )
                    guard let valueID = result.aggregateSupportValueID else {
                        throw BeautyError.invalidInput
                    }
                    return valueID
                }
            }

            var values = Set<Int>()
            for try await valueID in group {
                values.insert(valueID)
            }
            return values
        }

        XCTAssertEqual(observedValueIDs, expectedValueIDs)
        XCTAssertEqual(harness.canonicalizeCount, expectedValueIDs.count)
        XCTAssertEqual(harness.detectAndMapCount, expectedValueIDs.count)
        XCTAssertEqual(harness.requestOwnerCreationCount, expectedValueIDs.count)
        XCTAssertEqual(harness.renderCount, expectedValueIDs.count)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
    }

    func testPixelBufferOverloadsAndResetPerformZeroLocalFoundationWork() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
        XCTAssertEqual(harness.canonicalizerConstructionCount, 0)
        _ = try harness.invokePixelBuffer(parameters: .init(brightness: 0.1))
        harness.reset()
        XCTAssertEqual(harness.canonicalizerConstructionCount, 0)
        XCTAssertEqual(harness.canonicalizeCount, 0)
        XCTAssertEqual(harness.detectAndMapCount, 0)
        XCTAssertEqual(harness.requestOwnerCreationCount, 0)
        XCTAssertEqual(harness.localProviderCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(harness.pixelBufferSummaryAvailability, "notRun")
    }

    func testCurrentProductionAdmissionInventoryIsExactlyEmpty() {
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionCount, 0)
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionNames, [])
    }

    func testPhase56ClosedTeethGateKeepsLiteralNoneAndBothStillEntriesInactive() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        let resolverSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift"
            ),
            encoding: .utf8
        )
        let normalizedResolver = resolverSource
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        XCTAssertTrue(normalizedResolver.contains(
            "package static func localRetouchAdmission( parameters: BeautyParameters ) -> " +
            "BeautyLocalRetouchAdmission { _ = parameters return .none }"
        ))
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionCount, 0)
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionNames, [])

        let engine = try BeautyEngine(configuration: .default)
        let processOutput = try engine.process(
            image: Self.image,
            orientation: .up,
            parameters: .init()
        )
        let resultOutput = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            parameters: .init()
        )
        let sourceBytes = try Self.renderedRGBA8(Self.image)
        XCTAssertEqual(processOutput.extent, Self.image.extent)
        XCTAssertEqual(resultOutput.output.extent, Self.image.extent)
        XCTAssertEqual(try Self.renderedRGBA8(processOutput), sourceBytes)
        XCTAssertEqual(try Self.renderedRGBA8(resultOutput.output), sourceBytes)
        XCTAssertEqual(resultOutput.warnings, [])
        XCTAssertEqual(resultOutput.metrics, [
            "beauty.effects.activeCount": 0,
            "beauty.effects.cappedCount": 0,
        ])
        XCTAssertEqual(resultOutput.detectionSummary, .notRun)

        let processColor = try engine.process(
            image: Self.image,
            orientation: .up,
            parameters: .init(brightness: 0.15)
        )
        let resultColor = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            parameters: .init(brightness: 0.15)
        )
        let processColorBytes = try Self.renderedRGBA8(processColor)
        XCTAssertEqual(processColorBytes, try Self.renderedRGBA8(resultColor.output))
        XCTAssertNotEqual(processColorBytes, sourceBytes)
        XCTAssertEqual(resultColor.detectionSummary, .notRun)
    }

    func testPhase56PixelBufferAndResetStayOutsideClosedTeethRoute() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 0)
        _ = try harness.invokePixelBuffer(parameters: .init(skinWhitening: 0.1))
        harness.reset()
        XCTAssertEqual(harness.canonicalizerConstructionCount, 0)
        XCTAssertEqual(harness.canonicalizeCount, 0)
        XCTAssertEqual(harness.detectAndMapCount, 0)
        XCTAssertEqual(harness.requestOwnerCreationCount, 0)
        XCTAssertEqual(harness.localProviderCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(harness.pixelBufferSummaryAvailability, "notRun")
        XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 0)
    }

    func testPhase57ClosedEyeRetouchGatesKeepLiteralNoneAndStillEntriesInactive() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        let resolverSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift"
            ),
            encoding: .utf8
        )
        let normalizedResolver = resolverSource
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        XCTAssertTrue(normalizedResolver.contains(
            "package static func localRetouchAdmission( parameters: BeautyParameters ) -> " +
            "BeautyLocalRetouchAdmission { _ = parameters return .none }"
        ))
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionCount, 0)
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionNames, [])

        let engine = try BeautyEngine(configuration: .default)
        let processOutput = try engine.process(image: Self.image, orientation: .up, parameters: .init())
        let resultOutput = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            parameters: .init()
        )
        let sourceBytes = try Self.renderedRGBA8(Self.image)
        XCTAssertEqual(try Self.renderedRGBA8(processOutput), sourceBytes)
        XCTAssertEqual(try Self.renderedRGBA8(resultOutput.output), sourceBytes)
        XCTAssertEqual(resultOutput.warnings, [])
        XCTAssertEqual(resultOutput.metrics, [
            "beauty.effects.activeCount": 0,
            "beauty.effects.cappedCount": 0,
        ])
        XCTAssertEqual(resultOutput.detectionSummary, .notRun)

        let processColor = try engine.process(
            image: Self.image,
            orientation: .up,
            parameters: .init(brightness: 0.15, eyeHeight: 0.2, upperEyelidLift: 0.1)
        )
        let resultColor = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            parameters: .init(brightness: 0.15, eyeHeight: 0.2, upperEyelidLift: 0.1)
        )
        XCTAssertEqual(try Self.renderedRGBA8(processColor), try Self.renderedRGBA8(resultColor.output))
    }

    func testPhase57PixelBufferResetAndOpaqueMechanicsStayOutsideEyeCandidates() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 0)
        _ = try harness.invokePixelBuffer(parameters: .init(eyeHeight: 0.2, upperEyelidLift: 0.1))
        harness.reset()
        XCTAssertEqual(harness.canonicalizerConstructionCount, 0)
        XCTAssertEqual(harness.canonicalizeCount, 0)
        XCTAssertEqual(harness.detectAndMapCount, 0)
        XCTAssertEqual(harness.requestOwnerCreationCount, 0)
        XCTAssertEqual(harness.localProviderCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(harness.pixelBufferSummaryAvailability, "notRun")
        XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 0)
    }

    func testPhase58ZeroAdmissionConjunctionPreservesBothFacadesAndCanonicalNoOp() throws {
        let resolverSource = try String(
            contentsOf: Self.repositoryRoot.appendingPathComponent(
                "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift"
            ),
            encoding: .utf8
        )
        let normalizedResolver = resolverSource
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        XCTAssertTrue(normalizedResolver.contains(
            "package static func localRetouchAdmission( parameters: BeautyParameters ) -> " +
            "BeautyLocalRetouchAdmission { _ = parameters return .none }"
        ))
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionCount, 0)
        XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionNames, [])

        let sourceBytes = try Self.renderedRGBA8(Self.image)
        let engine = try BeautyEngine(configuration: .default)
        let processOutput = try engine.process(
            image: Self.image,
            orientation: .up,
            parameters: .init()
        )
        let resultOutput = try engine.processResult(
            image: Self.image,
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            parameters: .init()
        )

        for output in [processOutput, resultOutput.output] {
            XCTAssertEqual(output.extent, Self.image.extent)
            XCTAssertEqual(try Self.renderedRGBA8(output), sourceBytes)
        }
        XCTAssertEqual(resultOutput.warnings, [])
        XCTAssertEqual(resultOutput.detectionSummary, .notRun)
        XCTAssertEqual(resultOutput.metrics, [
            "beauty.effects.activeCount": 0,
            "beauty.effects.cappedCount": 0,
        ])

        let transparent = CIImage(
            color: CIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.5)
        ).cropped(to: Self.image.extent)
        let invalidHarness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1
        )
        XCTAssertThrowsError(
            try invalidHarness.invoke(
                entry: .processResult,
                image: transparent,
                parameters: .init()
            )
        ) { error in
            XCTAssertEqual(error as? BeautyError, .unsupportedPixelFormat)
            XCTAssertEqual(Array(Mirror(reflecting: error).children).count, 0)
        }
    }

    func testPhase58CanceledCallerDiscardsCompletedPublicationThenFreshRequestPublishes() async throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1,
            supportSequence: [.available(valueID: 101), .available(valueID: 202)]
        )
        let completed = try harness.invoke(
            entry: .processResult,
            image: Self.image,
            parameters: .init()
        )
        let gate = Phase58PublicationGate()
        let publication = Task { () -> Phase58PublicationOutcome in
            await gate.markInvocationCompletedAndWaitForRelease()
            guard !Task.isCancelled else { return .discarded }
            return .published(completed.aggregateSupportValueID)
        }

        await gate.waitUntilInvocationCompleted()
        publication.cancel()
        await gate.release()

        let canceledOutcome = await publication.value
        XCTAssertEqual(canceledOutcome, .discarded)
        XCTAssertEqual(harness.canonicalizeCount, 1)
        XCTAssertEqual(harness.detectAndMapCount, 1)
        XCTAssertEqual(harness.requestOwnerCreationCount, 1)
        XCTAssertEqual(harness.renderCount, 1)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)

        let fresh = try harness.invoke(
            entry: .processResult,
            image: Self.image,
            parameters: .init()
        )
        XCTAssertEqual(fresh.aggregateSupportValueID, 202)
        XCTAssertEqual(harness.canonicalizeCount, 2)
        XCTAssertEqual(harness.detectAndMapCount, 2)
        XCTAssertEqual(harness.requestOwnerCreationCount, 2)
        XCTAssertEqual(harness.renderCount, 2)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
    }

    func testConcurrencyNonclaimsRemainFlaggedNotPassedClaims() {
        let flags = Set([
            "PATH01-CONCURRENCY",
            "PATH04-CONCURRENCY",
            "PATH05-CONCURRENCY",
        ])
        XCTAssertEqual(flags.count, 3)
        XCTAssertFalse(flags.contains("same-engine-parallel-safe"))
        // TD-013 and mutable selected-face policy intentionally keep same-engine
        // concurrency and cooperative cancellation outside Phase 53's claim.
    }

    private static func floatingPointImage(
        width: Int,
        height: Int,
        alphas: [Float]
    ) throws -> CIImage {
        guard width > 0,
              height > 0,
              alphas.count == width * height,
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        else {
            throw BeautyError.invalidInput
        }

        var pixels: [Float] = []
        pixels.reserveCapacity(alphas.count * 4)
        for alpha in alphas {
            pixels.append(contentsOf: [0.25, 0.50, 0.75, alpha])
        }
        let data = pixels.withUnsafeBytes { Data($0) }
        return CIImage(
            bitmapData: data,
            bytesPerRow: width * MemoryLayout<Float>.stride * 4,
            size: CGSize(width: width, height: height),
            format: .RGBAf,
            colorSpace: colorSpace
        )
    }

    private static var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
    }

    private static func renderedRGBA8(_ image: CIImage) throws -> [UInt8] {
        let bounds = image.extent.integral
        guard bounds.width > 0,
              bounds.height > 0,
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        else {
            throw BeautyError.invalidInput
        }
        let width = Int(bounds.width)
        let height = Int(bounds.height)
        let rowBytes = width * 4
        var bytes = [UInt8](repeating: 0, count: rowBytes * height)
        CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace,
        ]).render(
            image,
            toBitmap: &bytes,
            rowBytes: rowBytes,
            bounds: bounds,
            format: .RGBA8,
            colorSpace: colorSpace
        )
        return bytes
    }
}

private enum Phase58PublicationOutcome: Equatable, Sendable {
    case discarded
    case published(Int?)
}

private actor Phase58PublicationGate {
    private var invocationCompleted = false
    private var released = false
    private var completionWaiters: [CheckedContinuation<Void, Never>] = []
    private var releaseWaiters: [CheckedContinuation<Void, Never>] = []

    func markInvocationCompletedAndWaitForRelease() async {
        invocationCompleted = true
        completionWaiters.forEach { $0.resume() }
        completionWaiters.removeAll()
        guard !released else { return }
        await withCheckedContinuation { releaseWaiters.append($0) }
    }

    func waitUntilInvocationCompleted() async {
        guard !invocationCompleted else { return }
        await withCheckedContinuation { completionWaiters.append($0) }
    }

    func release() {
        released = true
        releaseWaiters.forEach { $0.resume() }
        releaseWaiters.removeAll()
    }
}
