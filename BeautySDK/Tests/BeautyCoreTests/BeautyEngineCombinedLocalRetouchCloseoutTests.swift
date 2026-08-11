import CoreImage
import XCTest
@_spi(Testing) @testable import BeautySDK

final class BeautyEngineCombinedLocalRetouchCloseoutTests: XCTestCase {
    func testCombinedFacadeMatchesIndependentStandaloneMergeThroughBothEntries() throws {
        for entry in [SDKTestingStillImageFacadeEntry.process, .processResult] {
            let source = try Self.combinedImage()
            let sourceBytes = try Self.renderedRGBA8(source)

            let teethHarness = try Self.makeHarness(.paired)
            let teeth = try teethHarness.invoke(
                entry: entry,
                image: source,
                parameters: BeautyParameters(teethWhitening: 1)
            )
            let teethBytes = try Self.renderedRGBA8(teeth.output)

            let scleraHarness = try Self.makeHarness(.paired)
            let sclera = try scleraHarness.invoke(
                entry: entry,
                image: source,
                parameters: BeautyParameters(scleraRednessReduction: 1)
            )
            let scleraBytes = try Self.renderedRGBA8(sclera.output)

            let combinedHarness = try Self.makeHarness(.paired)
            let combined = try combinedHarness.invoke(
                entry: entry,
                image: source,
                parameters: BeautyParameters(
                    teethWhitening: 1,
                    scleraRednessReduction: 1
                )
            )
            let combinedBytes = try Self.renderedRGBA8(combined.output)
            let oracle = Self.independentMerge(
                source: sourceBytes,
                first: teethBytes,
                second: scleraBytes
            )

            XCTAssertGreaterThan(Self.changedPixelCount(sourceBytes, teethBytes), 0)
            XCTAssertGreaterThan(Self.changedPixelCount(sourceBytes, scleraBytes), 0)
            XCTAssertEqual(oracle.collisionPixelCount, 0)
            XCTAssertEqual(combinedBytes, oracle.bytes)
            XCTAssertEqual(combined.width, 64)
            XCTAssertEqual(combined.height, 64)
            XCTAssertTrue(Self.hasOpaqueAlpha(combinedBytes))
            XCTAssertEqual(combinedHarness.canonicalizeCount, 1)
            XCTAssertEqual(combinedHarness.detectAndMapCount, 1)
            XCTAssertEqual(combinedHarness.requestOwnerCreationCount, 1)
            XCTAssertEqual(combinedHarness.providerObservation.invocationCount, 1)
            XCTAssertEqual(combinedHarness.scleraProviderObservation.invocationCount, 1)
            XCTAssertEqual(combinedHarness.compositionObservation.compositionInvocationCount, 1)
            XCTAssertEqual(combinedHarness.compositionObservation.acceptedUnitCount, 3)
            XCTAssertEqual(
                combinedHarness.events,
                [.canonicalize, .detectAndMap, .makeRequestContext, .compose, .render]
            )
        }
    }

    func testInjectedConceptualCrossProviderCollisionPreservesSourceAndSiblings() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1,
            compositionScenario: .collision
        )
        let result = try harness.invoke(
            entry: .processResult,
            image: Self.collisionImage(),
            parameters: BeautyParameters()
        )
        let bytes = try Self.renderedRGBA8(result.output)

        XCTAssertEqual(bytes, Self.collisionExpectedBytes)
        XCTAssertEqual(Array(bytes[0..<4]), Array(Self.collisionSourceBytes[0..<4]))
        XCTAssertEqual(harness.compositionObservation.collisionPixelCount, 1)
        XCTAssertEqual(harness.compositionObservation.ownedPixelCount, 1)
        XCTAssertEqual(harness.compositionObservation.changedPixelCount, 1)
        XCTAssertEqual(harness.compositionObservation.changedOutsideUnionPixelCount, 0)
    }

    func testInjectedTeethFailureRetainsWholeScleraOutput() throws {
        let source = try Self.combinedImage()
        let scleraHarness = try Self.makeHarness(.pairedWithoutLips)
        let sclera = try scleraHarness.invoke(
            entry: .processResult,
            image: source,
            parameters: BeautyParameters(scleraRednessReduction: 1)
        )
        let combinedHarness = try Self.makeHarness(.pairedWithoutLips)
        let combined = try combinedHarness.invoke(
            entry: .processResult,
            image: source,
            parameters: BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        )

        XCTAssertEqual(
            try Self.renderedRGBA8(combined.output),
            try Self.renderedRGBA8(sclera.output)
        )
        XCTAssertEqual(combinedHarness.providerObservation.invocationCount, 1)
        XCTAssertEqual(combinedHarness.providerObservation.issuedUnitCount, 0)
        XCTAssertEqual(combinedHarness.scleraProviderObservation.issuedUnitCount, 2)
        XCTAssertEqual(combinedHarness.compositionObservation.acceptedUnitCount, 2)
    }

    func testInjectedWholeScleraFailureRetainsTeethOutput() throws {
        let source = try Self.combinedImage()
        let teethHarness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            supportSequence: [.available(valueID: 1)]
        )
        let teeth = try teethHarness.invoke(
            entry: .processResult,
            image: source,
            parameters: BeautyParameters(teethWhitening: 1)
        )
        let combinedHarness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            supportSequence: [.available(valueID: 1)]
        )
        let combined = try combinedHarness.invoke(
            entry: .processResult,
            image: source,
            parameters: BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        )

        XCTAssertEqual(
            try Self.renderedRGBA8(combined.output),
            try Self.renderedRGBA8(teeth.output)
        )
        XCTAssertEqual(combinedHarness.providerObservation.issuedUnitCount, 1)
        XCTAssertEqual(combinedHarness.scleraProviderObservation.issuedUnitCount, 0)
        XCTAssertEqual(combinedHarness.compositionObservation.acceptedUnitCount, 1)
    }

    func testInjectedLeftAndRightEyeFailuresRetainTeethAndAcceptedPeer() throws {
        let cases: [(SDKTestingScleraEyeSupport, Int, Int)] = [
            (.leftValidRightMalformed, 1, 0),
            (.rightValidLeftMalformed, 0, 1),
        ]
        for (support, acceptedLeft, acceptedRight) in cases {
            let source = try Self.combinedImage()
            let sourceBytes = try Self.renderedRGBA8(source)

            let teethHarness = try Self.makeHarness(support)
            let teeth = try teethHarness.invoke(
                entry: .processResult,
                image: source,
                parameters: BeautyParameters(teethWhitening: 1)
            )
            let teethBytes = try Self.renderedRGBA8(teeth.output)

            let scleraHarness = try Self.makeHarness(support)
            let sclera = try scleraHarness.invoke(
                entry: .processResult,
                image: source,
                parameters: BeautyParameters(scleraRednessReduction: 1)
            )
            let scleraBytes = try Self.renderedRGBA8(sclera.output)

            let combinedHarness = try Self.makeHarness(support)
            let combined = try combinedHarness.invoke(
                entry: .processResult,
                image: source,
                parameters: BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
            )
            let combinedBytes = try Self.renderedRGBA8(combined.output)
            let oracle = Self.independentMerge(
                source: sourceBytes,
                first: teethBytes,
                second: scleraBytes
            )

            XCTAssertGreaterThan(Self.changedPixelCount(sourceBytes, teethBytes), 0)
            XCTAssertGreaterThan(Self.changedPixelCount(sourceBytes, scleraBytes), 0)
            XCTAssertEqual(oracle.collisionPixelCount, 0)
            XCTAssertEqual(combinedBytes, oracle.bytes)
            XCTAssertEqual(combinedHarness.providerObservation.issuedUnitCount, 1)
            XCTAssertEqual(combinedHarness.scleraProviderObservation.issuedUnitCount, 1)
            XCTAssertEqual(combinedHarness.scleraProviderObservation.acceptedLeftEyeCount, acceptedLeft)
            XCTAssertEqual(combinedHarness.scleraProviderObservation.acceptedRightEyeCount, acceptedRight)
            XCTAssertEqual(combinedHarness.compositionObservation.acceptedUnitCount, 2)
            XCTAssertEqual(combinedHarness.compositionObservation.compositionInvocationCount, 1)
        }
    }

    func testCombinedValidInvalidValidSequenceRetainsNoPriorWork() throws {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [.paired, .invalidOrder, .paired]
        )
        let parameters = BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        let source = try Self.combinedImage()

        let first = try harness.invoke(entry: .processResult, image: source, parameters: parameters)
        let firstBytes = try Self.renderedRGBA8(first.output)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 3)

        let middle = try harness.invoke(entry: .processResult, image: source, parameters: parameters)
        XCTAssertEqual(try Self.renderedRGBA8(middle.output), try Self.renderedRGBA8(source))
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 0)
        XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 0)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)

        let third = try harness.invoke(entry: .processResult, image: source, parameters: parameters)
        XCTAssertEqual(try Self.renderedRGBA8(third.output), firstBytes)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 3)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
    }

    func testCombinedNoFaceAbstainsAndReturnsSource() throws {
        let harness = try Self.makeHarness(.noFace)
        let source = try Self.combinedImage()
        let result = try harness.invoke(
            entry: .processResult,
            image: source,
            parameters: BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        )

        XCTAssertEqual(try Self.renderedRGBA8(result.output), try Self.renderedRGBA8(source))
        XCTAssertEqual(harness.providerObservation.invocationCount, 1)
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 0)
        XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 1)
        XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 0)
        XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 1)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
    }

    func testEarlyInvalidCombinedRequestClearsPriorSummaryAndRecovers() throws {
        let harness = try Self.makeHarness(.paired)
        let parameters = BeautyParameters(
            brightness: 0.12,
            faceSlim: 0.25,
            teethWhitening: 1,
            scleraRednessReduction: 1
        )

        _ = try harness.invoke(
            entry: .processResult,
            image: try Self.combinedImage(),
            parameters: parameters
        )
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 3)
        XCTAssertTrue(harness.hasCurrentCanonicalObservation)
        XCTAssertTrue(harness.usedExplicitSRGBRender)

        XCTAssertThrowsError(try harness.invoke(
            entry: .processResult,
            image: CIImage.empty(),
            parameters: parameters
        ))
        XCTAssertEqual(harness.providerObservation, SDKTestingTeethProviderObservation())
        XCTAssertEqual(harness.scleraProviderObservation, SDKTestingScleraProviderObservation())
        XCTAssertEqual(harness.compositionObservation, SDKTestingLocalCompositionObservation())
        XCTAssertFalse(harness.canonicalConsumerIdentityMatched)
        XCTAssertFalse(harness.hasCurrentCanonicalObservation)
        XCTAssertFalse(harness.usedExplicitSRGBRender)
        XCTAssertEqual(harness.lastMappingInvocationCount, 0)
        XCTAssertEqual(harness.lastMappedCoordinateCount, 0)
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)

        _ = try harness.invoke(
            entry: .processResult,
            image: try Self.combinedImage(),
            parameters: parameters
        )
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)
        XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 2)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 3)
    }

    func testThrownCombinedRequestClearsBothObservationsAndRecovers() throws {
        let harness = try Self.makeHarness(.paired)
        let parameters = BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)

        _ = try harness.invoke(
            entry: .processResult,
            image: try Self.combinedImage(),
            parameters: parameters
        )
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)
        XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 2)

        XCTAssertThrowsError(try harness.invoke(
            entry: .processResult,
            image: Self.unsupportedImage(),
            parameters: parameters
        ))
        XCTAssertEqual(harness.providerObservation.invocationCount, 0)
        XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 0)
        XCTAssertEqual(harness.compositionObservation, SDKTestingLocalCompositionObservation())
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)

        _ = try harness.invoke(
            entry: .processResult,
            image: try Self.combinedImage(),
            parameters: parameters
        )
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)
        XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 2)
    }

    func testParallelCombinedRequestsKeepAllProviderStateLocal() async throws {
        let observations = try await withThrowingTaskGroup(
            of: (Int, Int, Int).self
        ) { group in
            for _ in 0..<12 {
                group.addTask {
                    let harness = try Self.makeHarness(.paired)
                    _ = try harness.invoke(
                        entry: .processResult,
                        image: try Self.combinedImage(),
                        parameters: BeautyParameters(
                            teethWhitening: 1,
                            scleraRednessReduction: 1
                        )
                    )
                    return (
                        harness.providerObservation.issuedUnitCount,
                        harness.scleraProviderObservation.issuedUnitCount,
                        harness.compositionObservation.acceptedUnitCount
                    )
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }
        XCTAssertEqual(observations.count, 12)
        XCTAssertTrue(observations.allSatisfy { $0 == 1 && $1 == 2 && $2 == 3 })
    }

    func testCombinedResetAndPixelBufferRoutesRetainNoLocalWork() throws {
        let harness = try Self.makeHarness(.paired)
        let parameters = BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        _ = try harness.invoke(
            entry: .processResult,
            image: try Self.combinedImage(),
            parameters: parameters
        )
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 3)

        try harness.invokePixelBuffer(parameters: parameters)
        XCTAssertEqual(harness.providerObservation.invocationCount, 0)
        XCTAssertEqual(harness.scleraProviderObservation.invocationCount, 0)
        harness.reset()
        XCTAssertEqual(harness.compositionObservation, SDKTestingLocalCompositionObservation())
        XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
        XCTAssertEqual(harness.retainedMappedCoordinateCount, 0)
        XCTAssertFalse(harness.canonicalConsumerIdentityMatched)
        XCTAssertFalse(harness.hasCurrentCanonicalObservation)
        XCTAssertFalse(harness.usedExplicitSRGBRender)
        XCTAssertEqual(harness.lastMappingInvocationCount, 0)
        XCTAssertEqual(harness.lastMappedCoordinateCount, 0)
    }

    func testCombinedWithUnrelatedEffectsUsesExplicitSRGBAndPreservesProviderWork() throws {
        let harness = try Self.makeHarness(.paired)
        let result = try harness.invoke(
            entry: .processResult,
            image: try Self.combinedImage(),
            parameters: BeautyParameters(
                brightness: 0.12,
                faceSlim: 0.25,
                teethWhitening: 1,
                scleraRednessReduction: 1
            )
        )

        XCTAssertEqual(result.width, 64)
        XCTAssertEqual(result.height, 64)
        XCTAssertTrue(Self.hasOpaqueAlpha(try Self.renderedRGBA8(result.output)))
        XCTAssertTrue(harness.usedExplicitSRGBRender)
        XCTAssertEqual(harness.providerObservation.issuedUnitCount, 1)
        XCTAssertEqual(harness.scleraProviderObservation.issuedUnitCount, 2)
        XCTAssertEqual(harness.compositionObservation.acceptedUnitCount, 3)
        XCTAssertEqual(harness.compositionObservation.changedOutsideUnionPixelCount, 0)
    }

    func testCombinedObservationsExposeFixedAggregatesOnly() throws {
        let harness = try Self.makeHarness(.paired)
        _ = try harness.invoke(
            entry: .processResult,
            image: try Self.combinedImage(),
            parameters: BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)
        )

        XCTAssertEqual(
            Set(Mirror(reflecting: harness.providerObservation).children.compactMap(\.label)),
            [
                "invocationCount", "issuedUnitCount", "abstentionCount",
                "fixedStrongPixelCount", "finalStrongPixelCount",
                "droppedFixedStrongPixelCount",
            ]
        )
        XCTAssertEqual(
            Set(Mirror(reflecting: harness.scleraProviderObservation).children.compactMap(\.label)),
            [
                "invocationCount", "issuedUnitCount", "acceptedLeftEyeCount",
                "acceptedRightEyeCount", "abstentionCount",
            ]
        )
        let description = String(describing: (
            harness.providerObservation,
            harness.scleraProviderObservation,
            harness.compositionObservation
        )).lowercased()
        for forbidden in [
            "coordinate", "pupil", "mask", "pixelindex", "candidatecolor",
            "fixture", "path", "digest", "owneridentity",
        ] {
            XCTAssertFalse(description.contains(forbidden), forbidden)
        }
    }
}

private extension BeautyEngineCombinedLocalRetouchCloseoutTests {
    static func makeHarness(
        _ support: SDKTestingScleraEyeSupport
    ) throws -> SDKTestingLocalRetouchFoundationHarness {
        try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 0,
            eyeSupportSequence: [support]
        )
    }

    static func independentMerge(
        source: [UInt8],
        first: [UInt8],
        second: [UInt8]
    ) -> (bytes: [UInt8], collisionPixelCount: Int) {
        precondition(source.count == first.count && source.count == second.count)
        var output = source
        var collisions = 0
        for offset in stride(from: 0, to: source.count, by: 4) {
            let sourceRGB = Array(source[offset..<(offset + 3)])
            let firstRGB = Array(first[offset..<(offset + 3)])
            let secondRGB = Array(second[offset..<(offset + 3)])
            let firstChanged = firstRGB != sourceRGB
            let secondChanged = secondRGB != sourceRGB
            if firstChanged && secondChanged {
                collisions += 1
                continue
            }
            let selected = firstChanged ? firstRGB : secondChanged ? secondRGB : sourceRGB
            output.replaceSubrange(offset..<(offset + 3), with: selected)
        }
        return (output, collisions)
    }

    static func changedPixelCount(_ source: [UInt8], _ output: [UInt8]) -> Int {
        stride(from: 0, to: source.count, by: 4).reduce(into: 0) { count, offset in
            if source[offset..<(offset + 3)] != output[offset..<(offset + 3)] {
                count += 1
            }
        }
    }

    static func hasOpaqueAlpha(_ bytes: [UInt8]) -> Bool {
        stride(from: 3, to: bytes.count, by: 4).allSatisfy { bytes[$0] == .max }
    }

    static func renderedRGBA8(_ image: CIImage) throws -> [UInt8] {
        let bounds = image.extent.integral
        guard bounds.width > 0,
              bounds.height > 0,
              bounds.width.rounded(.towardZero) == bounds.width,
              bounds.height.rounded(.towardZero) == bounds.height,
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        else {
            throw BeautyError.invalidInput
        }
        let width = Int(bounds.width)
        let height = Int(bounds.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace,
        ]).render(
            image,
            toBitmap: &bytes,
            rowBytes: width * 4,
            bounds: bounds,
            format: .RGBA8,
            colorSpace: colorSpace
        )
        return bytes
    }

    static func combinedImage() throws -> CIImage {
        let width = 64
        let height = 64
        var bytes = Array(repeating: UInt8(0), count: width * height * 4)
        for index in 0..<(width * height) {
            let offset = index * 4
            bytes[offset] = 45
            bytes[offset + 1] = 24
            bytes[offset + 2] = 30
            bytes[offset + 3] = .max
        }
        for y in 16...29 {
            for x in 20...43 {
                let offset = (y * width + x) * 4
                bytes[offset] = 209
                bytes[offset + 1] = 150
                bytes[offset + 2] = 150
            }
        }
        for y in 32...33 {
            for x in 29...34 {
                let offset = (y * width + x) * 4
                bytes[offset] = 181
                bytes[offset + 1] = 161
                bytes[offset + 2] = 120
            }
        }
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.unsupportedPixelFormat
        }
        return CIImage(
            bitmapData: Data(bytes),
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    static func unsupportedImage() -> CIImage {
        CIImage(color: CIColor(red: 0.8, green: 0.6, blue: 0.6, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 80, height: 48))
    }

    static let collisionSourceBytes: [UInt8] = [
        51, 102, 153, 255, 51, 102, 153, 255,
        51, 102, 153, 255, 51, 102, 153, 255,
    ]
    static let collisionExpectedBytes: [UInt8] = [
        51, 102, 153, 255, 71, 31, 221, 255,
        51, 102, 153, 255, 51, 102, 153, 255,
    ]

    static func collisionImage() -> CIImage {
        CIImage(
            bitmapData: Data(collisionSourceBytes),
            bytesPerRow: 8,
            size: CGSize(width: 2, height: 2),
            format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }
}
