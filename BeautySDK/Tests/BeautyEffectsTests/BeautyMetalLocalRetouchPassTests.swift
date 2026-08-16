import CoreImage
import Foundation
import Metal
import XCTest
import BeautyCore
import BeautyDetection
import BeautyRender
@testable import BeautyEffects

/// Generated in-memory proof that Metal consumes the composition owner's
/// canonical carrier rather than a second local-retouch implementation.
final class BeautyMetalLocalRetouchPassTests: XCTestCase {
    func testComposedCarrierPreservesQ16ProtectedBytesAlphaExtentAndSummary() throws {
        guard let runtime = makeRuntime() else { return }
        let sourceBytes = sourceBytes(count: 8)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let source = try canonical(sourceBytes, width: 8, height: 1, metadata: metadata)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let protected = try XCTUnwrap(owner.makeUnit(proposals: [proposal(1, weight: 32_768, target: (240, 40, 20))]))
        let changed = try XCTUnwrap(owner.makeUnit(proposals: [proposal(2, weight: UInt32.max, target: (10, 210, 80))]))
        let composition = try owner.compose([protected, changed])
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .stillImage(composition.canonicalImage.ciImage),
            metadata: metadata,
            plan: BeautyEffectPlan(),
            canonicalImage: composition.canonicalImage,
            compositionSummary: composition.summary
        )

        let result = try BeautyMetalBackend(runtime: runtime).execute(request)
        guard case .stillImage(let output) = result.output else {
            return XCTFail("Metal changed the output kind")
        }
        let outputBytes = try bytes(from: output, width: 8, height: 1)
        XCTAssertEqual(outputBytes, Array(composition.canonicalImage.rgba8Data))
        XCTAssertEqual(Array(outputBytes[8..<12]), [10, 210, 80, 255])
        XCTAssertEqual(Array(outputBytes[4..<8]), [161, 41, 21, 255])
        XCTAssertEqual(alphaBytes(outputBytes), alphaBytes(sourceBytes))
        XCTAssertEqual(output.extent, composition.canonicalImage.ciImage.extent)
        XCTAssertEqual(output.colorSpace?.name, CGColorSpace(name: CGColorSpace.sRGB)?.name)
        XCTAssertEqual(result.diagnostics.unitCount, composition.summary.acceptedUnitCount)
        XCTAssertEqual(result.diagnostics.failureCount, composition.summary.rejectedUnitCount)
        XCTAssertEqual(result.diagnostics.changedPixelCount, composition.summary.changedPixelCount)
    }

    func testOwnerIsolationKeepsValidInvalidValidAndCollisionToSource() throws {
        let sourceBytes = sourceBytes(count: 8)
        let source = try canonical(sourceBytes, width: 8, height: 1)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let foreignOwner = BeautyLocalRetouchCompositionOwner(source: source)
        let first = try XCTUnwrap(owner.makeUnit(proposals: [proposal(1, target: (220, 30, 20))]))
        let collisionA = try XCTUnwrap(owner.makeUnit(proposals: [proposal(2, target: (240, 20, 10))]))
        let collisionB = try XCTUnwrap(owner.makeUnit(proposals: [proposal(2, target: (10, 240, 20))]))
        let last = try XCTUnwrap(owner.makeUnit(proposals: [proposal(3, target: (30, 40, 230))]))
        let foreign = try XCTUnwrap(foreignOwner.makeUnit(proposals: [proposal(4, target: (10, 10, 10))]))

        let result = try owner.compose([first, foreign, collisionA, collisionB, last])
        let output = Array(result.canonicalImage.rgba8Data)
        XCTAssertEqual(result.summary.acceptedUnitCount, 4)
        XCTAssertEqual(result.summary.rejectedUnitCount, 1)
        XCTAssertEqual(result.summary.collisionPixelCount, 1)
        XCTAssertEqual(Array(output[8..<12]), Array(sourceBytes[8..<12]))
        XCTAssertEqual(Array(output[12..<16]), [30, 40, 230, 255])
        XCTAssertEqual(Array(output[16..<20]), Array(sourceBytes[16..<20]))
        XCTAssertEqual(try owner.compose([]).canonicalImage.rgba8Data, Data(sourceBytes))
    }

    func testMalformedSupportAndDuplicateClaimsFailLocally() throws {
        let sourceBytes = sourceBytes(count: 8)
        let source = try canonical(sourceBytes, width: 8, height: 1)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        XCTAssertNil(owner.makeUnit(proposals: [
            proposal(1), proposal(1),
        ]))
        XCTAssertNil(owner.makeUnit(proposals: [
            BeautyLocalPixelProposal(
                pixelIndex: -1,
                isInsideHardEnvelope: true,
                softWeightQ16: 65_536,
                targetRed: 1,
                targetGreen: 2,
                targetBlue: 3
            ),
        ]))

        let valid = try XCTUnwrap(owner.makeUnit(proposals: [proposal(5, target: (200, 100, 40))]))
        let result = try owner.compose([valid, valid])
        XCTAssertEqual(result.summary.acceptedUnitCount, 0)
        XCTAssertEqual(result.summary.rejectedUnitCount, 2)
        XCTAssertEqual(result.canonicalImage.rgba8Data, Data(sourceBytes))
    }

    func testMixedComposedColorAndGeometryStartsFromCarrierAndRecovers() throws {
        guard let runtime = makeRuntime() else { return }
        let width = 32
        let height = 24
        let sourceBytes = gradientBytes(width: width, height: height)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let source = try canonical(sourceBytes, width: width, height: height, metadata: metadata)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let unit = try XCTUnwrap(owner.makeUnit(proposals: [proposal(12, target: (240, 30, 20))]))
        let composition = try owner.compose([unit])
        let face = BeautyFaceObservation(
            imageBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
            landmarks: .complete
        )
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(brightness: 0.25, faceSlim: 0.35),
            faceGeometry: BeautyFaceGeometryAdapter.makeGeometry(from: face)
        )
        let metalRequest = try makeRequest(
            policy: .metal,
            carrier: composition.canonicalImage,
            metadata: metadata,
            plan: plan,
            face: face,
            summary: composition.summary
        )
        let cpuRequest = try makeRequest(
            policy: .cpu,
            carrier: composition.canonicalImage,
            metadata: metadata,
            plan: plan,
            face: face,
            summary: composition.summary
        )
        let metalResult = try BeautyMetalBackend(runtime: runtime).execute(metalRequest)
        let cpuResult = try BeautyCPUBackend().execute(cpuRequest)
        guard case .stillImage(let metalImage) = metalResult.output,
              case .stillImage(let cpuImage) = cpuResult.output
        else { return XCTFail("Mixed pass output kind changed") }

        let metal = try self.bytes(from: metalImage, width: width, height: height)
        let cpu = try self.bytes(from: cpuImage, width: width, height: height)
        XCTAssertEqual(alphaBytes(metal), alphaBytes(sourceBytes))
        XCTAssertEqual(metalImage.extent, cpuImage.extent)
        XCTAssertLessThan(meanRGBDelta(metal, cpu), 8)
        let composedAlpha = metal[12 * 4 + 3]
        XCTAssertEqual(composedAlpha, 255)
        XCTAssertEqual(metalResult.diagnostics.changedPixelCount, composition.summary.changedPixelCount)
    }

    func testMetalFailureDoesNotPublishPartialCarrierAndReleasesResources() throws {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        var dependencies = BeautyMetalRuntime.Dependencies.live
        dependencies.deviceProvider = { device }
        dependencies.commandStatusProvider = { _ in .error }
        let runtime = try BeautyMetalRuntime(dependencies: dependencies)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let source = try canonical(sourceBytes(count: 4), width: 4, height: 1, metadata: metadata)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let unit = try XCTUnwrap(owner.makeUnit(proposals: [proposal(1, target: (200, 40, 20))]))
        let composition = try owner.compose([unit])
        let request = try BeautyBackendRequest(
            policy: .metal,
            input: .stillImage(composition.canonicalImage.ciImage),
            metadata: metadata,
            plan: BeautyEffectPlan(),
            canonicalImage: composition.canonicalImage,
            compositionSummary: composition.summary
        )
        let errors = ErrorCounter()
        let backend = BeautyMetalBackend(
            runtime: runtime,
            hooks: .init(onTerminalError: { _ in errors.increment() })
        )

        XCTAssertThrowsError(try backend.execute(request)) { error in
            XCTAssertEqual(error as? BeautyError, .renderFailed("command_failed"))
        }
        XCTAssertEqual(errors.value, 1)
        XCTAssertEqual(runtime.resourceCountersForTesting.active, 0)
        XCTAssertEqual(runtime.resourceCountersForTesting.created, runtime.resourceCountersForTesting.released)
    }

    private func makeRuntime() -> BeautyMetalRuntime? {
        do { return try BeautyMetalRuntime() }
        catch BeautyError.metalUnavailable { return nil }
        catch { XCTFail("unexpected runtime setup failure: \(error)"); return nil }
    }

    private func makeRequest(
        policy: BeautyBackendExecutionPolicy,
        carrier: BeautyCanonicalStillImage,
        metadata: BeautyInputMetadata,
        plan: BeautyEffectPlan,
        face: BeautyFaceObservation,
        summary: BeautyLocalRetouchCompositionSummary
    ) throws -> BeautyBackendRequest {
        try BeautyBackendRequest(
            policy: policy,
            input: .stillImage(carrier.ciImage),
            metadata: metadata,
            plan: plan,
            selectedFaceSupport: face,
            canonicalImage: carrier,
            compositionSummary: summary
        )
    }

    private func canonical(
        _ bytes: [UInt8],
        width: Int,
        height: Int,
        metadata: BeautyInputMetadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
    ) throws -> BeautyCanonicalStillImage {
        try BeautyCanonicalStillImage(
            rgba8Data: Data(bytes),
            width: width,
            height: height,
            rowBytes: width * 4,
            metadata: metadata
        )
    }

    private func proposal(
        _ index: Int,
        weight: UInt32 = UInt32.max,
        target: (UInt8, UInt8, UInt8) = (200, 80, 30)
    ) -> BeautyLocalPixelProposal {
        BeautyLocalPixelProposal(
            pixelIndex: index,
            isInsideHardEnvelope: true,
            softWeightQ16: weight,
            targetRed: target.0,
            targetGreen: target.1,
            targetBlue: target.2
        )
    }

    private func sourceBytes(count: Int) -> [UInt8] {
        var result: [UInt8] = []
        result.reserveCapacity(count * 4)
        for index in 0..<count {
            result.append(UInt8(80 + index))
            result.append(UInt8(40 + index))
            result.append(UInt8(20 + index))
            result.append(255)
        }
        return result
    }

    private func gradientBytes(width: Int, height: Int) -> [UInt8] {
        (0..<(width * height)).flatMap { index in
            let x = index % width
            let y = index / width
            return [UInt8((x * 7 + y) % 240), UInt8((y * 9 + 30) % 240), UInt8((x * 5 + 40) % 240), 255]
        }
    }

    private func bytes(from image: CIImage, width: Int, height: Int) throws -> [UInt8] {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        guard let cgImage = context.createCGImage(
            image,
            from: CGRect(x: 0, y: 0, width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        ), let data = cgImage.dataProvider?.data else {
            throw BeautyError.renderFailed("output_conversion_failed")
        }
        let source = CFDataGetBytePtr(data)!
        var result = [UInt8](repeating: 0, count: width * height * 4)
        for row in 0..<height {
            result.withUnsafeMutableBytes { destination in
                memcpy(
                    destination.baseAddress!.advanced(by: row * width * 4),
                    source.advanced(by: row * cgImage.bytesPerRow),
                    width * 4
                )
            }
        }
        return result
    }

    private func alphaBytes(_ bytes: [UInt8]) -> [UInt8] {
        stride(from: 3, to: bytes.count, by: 4).map { bytes[$0] }
    }

    private func meanRGBDelta(_ lhs: [UInt8], _ rhs: [UInt8]) -> Double {
        let values = stride(from: 0, to: min(lhs.count, rhs.count), by: 4).flatMap { offset in
            (0..<3).map { abs(Int(lhs[offset + $0]) - Int(rhs[offset + $0])) }
        }
        return Double(values.reduce(0, +)) / Double(max(1, values.count))
    }
}

private final class ErrorCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var storage = 0

    func increment() {
        lock.lock()
        storage += 1
        lock.unlock()
    }

    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }
}
