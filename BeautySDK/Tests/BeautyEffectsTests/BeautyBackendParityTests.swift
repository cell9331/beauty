import CoreImage
import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

final class BeautyBackendParityTests: XCTestCase {
    func testTextureExclusionMaskProtectsSameColorPatchOnCPUAndMetal() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        let width = 32
        let height = 32
        var source = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let detail = (x / 2 + y / 2).isMultiple(of: 2) ? 10 : -10
                source[offset] = UInt8(170 + detail)
                source[offset + 1] = UInt8(125 + detail)
                source[offset + 2] = UInt8(110 + detail)
            }
        }
        let image = CIImage(
            bitmapData: Data(source), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
        var maskBytes = [UInt8](repeating: 0, count: width * height)
        for y in 14..<19 {
            for x in 18..<23 { maskBytes[y * width + x] = 255 }
        }
        let mask = try BeautyTextureExclusionMask(
            width: width, height: height, bytes: maskBytes
        )
        let face = BeautyFaceObservation(
            imageBounds: CoordinateRect(x: 0.05, y: 0.05, width: 0.9, height: 0.9)
        )
        let plan = BeautyEffectResolver.resolve(
            parameters: BeautyParameters(skinSmoothing: 1),
            selectedFaceObservation: face
        )
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let cpuRequest = try BeautyBackendRequest(
            policy: .cpu, input: .stillImage(image), metadata: metadata,
            plan: plan, selectedFaceSupport: face, textureExclusionMask: mask
        )
        let gpuRequest = try BeautyBackendRequest(
            policy: .metal, input: .stillImage(image), metadata: metadata,
            plan: plan, selectedFaceSupport: face, textureExclusionMask: mask
        )
        let cpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(
            from: BeautyCPUBackend().execute(cpuRequest).output
        )
        let gpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(
            from: metal.execute(gpuRequest).output
        )
        for index in maskBytes.indices where maskBytes[index] == 255 {
            let offset = index * 4
            XCTAssertEqual(Array(cpuBytes[offset..<(offset + 4)]),
                           Array(source[offset..<(offset + 4)]))
            XCTAssertEqual(Array(gpuBytes[offset..<(offset + 4)]),
                           Array(source[offset..<(offset + 4)]))
        }
        let cheekOffset = (16 * width + 12) * 4
        XCTAssertNotEqual(cpuBytes[cheekOffset], source[cheekOffset])
        XCTAssertNotEqual(gpuBytes[cheekOffset], source[cheekOffset])
        XCTAssertEqual(gpuBytes, cpuBytes)
    }

    func testGeneratedNeutralPixelBufferIsStructurallyAndByteIdentical() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp()
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters())
        let cpuRequest = try BeautyBackendParityFixtureFactory.makeRequest(policy: .cpu, fixture: fixture, plan: plan)
        let gpuRequest = try BeautyBackendParityFixtureFactory.makeRequest(policy: .metal, fixture: fixture, plan: plan)
        let cpu = try BeautyCPUBackend().execute(cpuRequest)
        let gpu = try metal.execute(gpuRequest)
        let cpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: cpu.output)
        let gpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: gpu.output)
        XCTAssertEqual(gpuBytes, cpuBytes)
        XCTAssertEqual(gpu.diagnostics, cpu.diagnostics)
        XCTAssertEqual(gpu.diagnostics.width, fixture.width)
        XCTAssertEqual(gpu.diagnostics.height, fixture.height)
        XCTAssertTrue(gpu.diagnostics.preservesAlpha)
        XCTAssertTrue(gpu.diagnostics.preservesExtent)
    }

    func testGeneratedActivePixelBufferMatrixMatchesCPUWithinPinnedTolerance() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        for fixture in BeautyBackendParityFixtureFactory.fixtures() {
            for (name, plan) in BeautyBackendParityFixtureFactory.planMatrix() where name != "neutral" && name != "composed-carrier" {
                let cpuRequest = try BeautyBackendParityFixtureFactory.makeRequest(policy: .cpu, fixture: fixture, plan: plan)
                let gpuRequest = try BeautyBackendParityFixtureFactory.makeRequest(policy: .metal, fixture: fixture, plan: plan)
                let cpu = try BeautyCPUBackend().execute(cpuRequest)
                let gpu = try metal.execute(gpuRequest)
                let cpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: cpu.output)
                let gpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: gpu.output)
                let observation = try BeautyBackendParityFixtureFactory.observation(
                    inputKind: .pixelBuffer,
                    fixture: fixture,
                    before: cpuBytes,
                    after: gpuBytes,
                    diagnostics: gpu.diagnostics
                )
                XCTAssertEqual(observation.kind, .pixelBuffer, name)
                XCTAssertEqual(observation.width, fixture.width, name)
                XCTAssertEqual(observation.height, fixture.height, name)
                XCTAssertTrue(observation.preservesAlpha, name)
                XCTAssertTrue(observation.preservesExtent, name)
                XCTAssertTrue(observation.namedSRGB, name)
                XCTAssertLessThanOrEqual(observation.maxChannelDelta, BeautyBackendParityFixtureFactory.activeMaxChannelDelta, name)
                XCTAssertLessThan(observation.meanRGBDelta, BeautyBackendParityFixtureFactory.activeMeanRGBDelta, name)
            }
        }
    }

    func testGeneratedStillImagePreservesTranslatedExtentAndMetadata() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp(width: 8, height: 6)
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(brightness: 0.35))
        let cpuRequest = try BeautyBackendParityFixtureFactory.makeRequest(
            policy: .cpu, fixture: fixture, plan: plan, stillImage: true, translated: true
        )
        let gpuRequest = try BeautyBackendParityFixtureFactory.makeRequest(
            policy: .metal, fixture: fixture, plan: plan, stillImage: true, translated: true
        )
        let cpu = try BeautyCPUBackend().execute(cpuRequest)
        let gpu = try metal.execute(gpuRequest)
        guard case .stillImage(let cpuImage) = cpu.output,
              case .stillImage(let gpuImage) = gpu.output
        else { return XCTFail("backend changed still-image output kind") }
        XCTAssertEqual(gpuImage.extent, cpuImage.extent)
        XCTAssertEqual(gpuImage.extent, CGRect(x: 3, y: -2, width: 8, height: 6))
        XCTAssertEqual(gpuImage.colorSpace?.name, CGColorSpace.sRGB)
        let cpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: cpu.output)
        let gpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: gpu.output)
        let observation = try BeautyBackendParityFixtureFactory.observation(
            inputKind: .stillImage,
            fixture: fixture,
            before: cpuBytes,
            after: gpuBytes,
            diagnostics: gpu.diagnostics,
            extentPreserved: gpuImage.extent == cpuImage.extent
        )
        XCTAssertTrue(observation.preservesExtent)
        XCTAssertLessThanOrEqual(observation.maxChannelDelta, BeautyBackendParityFixtureFactory.activeMaxChannelDelta)
        XCTAssertLessThan(observation.meanRGBDelta, BeautyBackendParityFixtureFactory.activeMeanRGBDelta)
    }

    func testGeneratedOpaqueSRGBStillImageColorAndLipRowsMatchCPUWithinTightTolerance() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp(width: 32, height: 24)

        for (name, plan) in BeautyBackendParityFixtureFactory.stillImageColorPlanMatrix() {
            let cpuRequest = try BeautyBackendParityFixtureFactory.makeRequest(
                policy: .cpu,
                fixture: fixture,
                plan: plan,
                stillImage: true,
                translated: true
            )
            let gpuRequest = try BeautyBackendParityFixtureFactory.makeRequest(
                policy: .metal,
                fixture: fixture,
                plan: plan,
                stillImage: true,
                translated: true
            )
            let cpu = try BeautyCPUBackend().execute(cpuRequest)
            let gpu = try metal.execute(gpuRequest)
            guard case .stillImage(let cpuImage) = cpu.output,
                  case .stillImage(let gpuImage) = gpu.output
            else { return XCTFail("backend changed still-image output kind: \(name)") }

            let cpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: cpu.output)
            let gpuBytes = try BeautyBackendParityFixtureFactory.rgbaBytes(from: gpu.output)
            let observation = try BeautyBackendParityFixtureFactory.observation(
                inputKind: .stillImage,
                fixture: fixture,
                before: cpuBytes,
                after: gpuBytes,
                diagnostics: gpu.diagnostics,
                extentPreserved: gpuImage.extent == cpuImage.extent
            )
            XCTAssertEqual(gpuImage.extent, cpuImage.extent, name)
            XCTAssertEqual(gpuImage.colorSpace?.name, CGColorSpace.sRGB, name)
            XCTAssertEqual(alphaValues(gpuBytes), alphaValues(cpuBytes), name)
            XCTAssertTrue(observation.preservesExtent, name)
            XCTAssertTrue(observation.namedSRGB, name)
            XCTAssertNotEqual(cpuBytes, fixture.rgba8, name)
            XCTAssertNotEqual(gpuBytes, fixture.rgba8, name)
            XCTAssertLessThanOrEqual(
                observation.maxChannelDelta,
                BeautyBackendParityFixtureFactory.stillImageMaxChannelDelta,
                name
            )
            XCTAssertLessThan(
                observation.meanRGBDelta,
                BeautyBackendParityFixtureFactory.stillImageMeanRGBDelta,
                name
            )
        }
    }

    func testGeneratedNoFacePlanIsExactNeutralBytes() throws {
        guard let metal = BeautyBackendParityFixtureFactory.makeMetalBackend() else { return }
        let fixture = CPUReferenceFixtureFactory.opaqueColorRamp()
        let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(lipColor: 0.8))
        let request = try BeautyBackendParityFixtureFactory.makeRequest(
            policy: .metal,
            fixture: fixture,
            plan: plan,
            stillImage: true
        )
        let result = try metal.execute(request)
        XCTAssertEqual(try BeautyBackendParityFixtureFactory.rgbaBytes(from: result.output), fixture.rgba8)
        XCTAssertTrue(result.diagnostics.preservesAlpha)
        XCTAssertTrue(result.diagnostics.preservesExtent)
    }

    private func alphaValues(_ bytes: [UInt8]) -> [UInt8] {
        stride(from: 3, to: bytes.count, by: 4).map { bytes[$0] }
    }
}
