import CoreImage
import XCTest
import BeautyCore
@testable import BeautyEffects

final class BeautyBackendParityTests: XCTestCase {
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
}
