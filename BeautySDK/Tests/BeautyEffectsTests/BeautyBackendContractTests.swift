import BeautyCore
import BeautyDetection
import BeautyRender
import CoreImage
import CoreVideo
import Foundation
import ImageIO
import XCTest
@testable import BeautyEffects

final class BeautyBackendContractTests: XCTestCase {
    func testValidStillImageRequestCarriesCanonicalCarrierAndAggregateResult() throws {
        let metadata = Self.metadata()
        let canonical = try Self.canonical(width: 2, height: 1, metadata: metadata)
        let request = try BeautyBackendRequest(
            input: .stillImage(canonical.ciImage),
            metadata: metadata,
            plan: BeautyEffectPlan(),
            canonicalImage: canonical,
            compositionSummary: BeautyLocalRetouchCompositionSummary(
                acceptedUnitCount: 1,
                ownedPixelCount: 1,
                changedPixelCount: 1
            )
        )

        let diagnostics = BeautyBackendDiagnostics(
            width: 2,
            height: 1,
            preservesAlpha: true,
            preservesExtent: true,
            unitCount: 1,
            changedPixelCount: 1
        )
        let result = try BeautyBackendResult(
            output: .stillImage(canonical.ciImage),
            diagnostics: diagnostics,
            for: request
        )

        XCTAssertEqual(request.inputKind, .stillImage)
        XCTAssertEqual(result.diagnostics, diagnostics)
        XCTAssertTrue(result.diagnostics.preservesAlpha)
        XCTAssertTrue(result.diagnostics.preservesExtent)
    }

    func testValidPixelBufferRequestUsesTheSingleCPUPolicy() throws {
        let pixelBuffer = try PixelBufferFactory().makePixelBuffer(width: 2, height: 2)
        let request = try BeautyBackendRequest(
            input: .pixelBuffer(pixelBuffer),
            metadata: Self.metadata(),
            plan: BeautyEffectPlan(),
            selectedFaceSupport: Self.faceSupport()
        )

        XCTAssertEqual(request.policy, .cpu)
        XCTAssertEqual(request.inputKind, .pixelBuffer)
        XCTAssertNotNil(request.selectedFaceSupport)
    }

    func testCanonicalMetadataAndCarrierConsistencyRejectsMalformedRequests() throws {
        let metadata = Self.metadata()
        let canonical = try Self.canonical(width: 2, height: 1, metadata: metadata)

        XCTAssertThrowsError(try BeautyBackendRequest(
            input: .stillImage(canonical.ciImage),
            metadata: BeautyInputMetadata(
                orientation: .up,
                isPreviewMirrored: true,
                source: .testFixture
            ),
            plan: BeautyEffectPlan(),
            canonicalImage: canonical
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }

        let wrongExtent = Self.image(width: 1, height: 1)
        XCTAssertThrowsError(try BeautyBackendRequest(
            input: .stillImage(wrongExtent),
            metadata: metadata,
            plan: BeautyEffectPlan(),
            canonicalImage: canonical
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
    }

    func testMalformedDimensionsAndNormalizedPlanRejectBeforeExecutorWork() throws {
        let metadata = Self.metadata()
        let nonIntegralExtent = CIImage.empty()
        XCTAssertThrowsError(try BeautyBackendRequest(
            input: .stillImage(nonIntegralExtent),
            metadata: metadata,
            plan: BeautyEffectPlan()
        ))

        var strengths = BeautyEffectiveStrengths()
        strengths.brightness = .nan
        XCTAssertThrowsError(try BeautyBackendRequest(
            input: .stillImage(Self.image(width: 1, height: 1)),
            metadata: metadata,
            plan: BeautyEffectPlan(effectiveStrengths: strengths)
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
    }

    func testOutputKindMismatchIsRejected() throws {
        let request = try BeautyBackendRequest(
            input: .stillImage(Self.image(width: 1, height: 1)),
            metadata: Self.metadata(),
            plan: BeautyEffectPlan()
        )
        let pixelBuffer = try PixelBufferFactory().makePixelBuffer(width: 1, height: 1)
        let diagnostics = BeautyBackendDiagnostics(
            width: 1,
            height: 1,
            preservesAlpha: true,
            preservesExtent: true
        )

        XCTAssertThrowsError(try BeautyBackendResult(
            output: .pixelBuffer(pixelBuffer),
            diagnostics: diagnostics,
            for: request
        )) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
    }

    func testAggregateDiagnosticsAreBoundedAndDeterministic() throws {
        let request = try BeautyBackendRequest(
            input: .stillImage(Self.image(width: 2, height: 2)),
            metadata: Self.metadata(),
            plan: BeautyEffectPlan()
        )
        let diagnostics = BeautyBackendDiagnostics(
            width: 2,
            height: 2,
            preservesAlpha: false,
            preservesExtent: true,
            unitCount: 2,
            failureCount: 1,
            collisionCount: 1,
            changedPixelCount: 2
        )
        let first = try BeautyBackendResult(
            output: .stillImage(Self.image(width: 2, height: 2)),
            diagnostics: diagnostics,
            for: request
        )
        let second = try BeautyBackendResult(
            output: .stillImage(Self.image(width: 2, height: 2)),
            diagnostics: diagnostics,
            for: request
        )

        XCTAssertEqual(first.diagnostics, second.diagnostics)
        XCTAssertEqual(first.diagnostics.unitCount, 2)
        XCTAssertEqual(first.diagnostics.failureCount, 1)
        XCTAssertEqual(first.diagnostics.collisionCount, 1)
        XCTAssertEqual(first.diagnostics.changedPixelCount, 2)
        XCTAssertEqual(Mirror(reflecting: first.diagnostics).children.count, 8)
    }

    func testExecutorErrorIsTerminalAndNeverRetriedOrSilentlySwitched() throws {
        let executor = FailingExecutor()
        let request = try BeautyBackendRequest(
            input: .stillImage(Self.image(width: 1, height: 1)),
            metadata: Self.metadata(),
            plan: BeautyEffectPlan()
        )

        XCTAssertThrowsError(try executor.execute(request)) { error in
            XCTAssertEqual(error as? BeautyError, .renderFailed("terminal"))
        }
        XCTAssertEqual(executor.callCount, 1)
    }

    private static func metadata() -> BeautyInputMetadata {
        BeautyInputMetadata(orientation: .up, source: .testFixture)
    }

    private static func faceSupport() -> BeautyFaceObservation {
        BeautyFaceObservation(landmarks: .missingRequiredGeometry)
    }

    private static func canonical(
        width: Int,
        height: Int,
        metadata: BeautyInputMetadata
    ) throws -> BeautyCanonicalStillImage {
        let byteCount = width * height * 4
        var bytes = Array(repeating: UInt8(0), count: byteCount)
        for index in stride(from: 3, to: bytes.count, by: 4) {
            bytes[index] = 255
        }
        return try BeautyCanonicalStillImage(
            rgba8Data: Data(bytes),
            width: width,
            height: height,
            rowBytes: width * 4,
            metadata: metadata
        )
    }

    private static func image(width: Int, height: Int) -> CIImage {
        let bytes = Data(repeating: 255, count: width * height * 4)
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        return CIImage(
            bitmapData: bytes,
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }
}

private final class FailingExecutor: BeautyBackendExecutor {
    private(set) var callCount = 0

    func execute(_ request: BeautyBackendRequest) throws -> BeautyBackendResult {
        callCount += 1
        _ = request
        throw BeautyError.renderFailed("terminal")
    }
}
