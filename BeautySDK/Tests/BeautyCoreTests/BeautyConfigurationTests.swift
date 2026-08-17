import CoreGraphics
import Foundation
import XCTest
import BeautySDK

final class BeautyConfigurationTests: XCTestCase {
    func testPhase73RenderBackendContractUsesOnlyCPUAndGPU() throws {
        XCTAssertEqual(BeautyRenderBackend.cpu.rawValue, "cpu")
        XCTAssertEqual(BeautyRenderBackend.gpu.rawValue, "gpu")
        XCTAssertEqual(Set([BeautyRenderBackend.cpu, .gpu]).count, 2)
        XCTAssertEqual(BeautyConfiguration().renderBackend, .cpu)
        XCTAssertEqual(BeautyConfiguration.default.renderBackend, .cpu)

        let gpu = BeautyConfiguration(renderBackend: .gpu)
        XCTAssertEqual(gpu.renderBackend, .gpu)
        assertSendable(gpu.renderBackend)
    }

    func testPhase73RenderBackendCodableDefaultsLegacyAndRejectsUnknown() throws {
        let gpu = BeautyConfiguration(renderBackend: .gpu)
        let encoded = try JSONEncoder().encode(gpu)
        let decoded = try JSONDecoder().decode(BeautyConfiguration.self, from: encoded)
        XCTAssertEqual(decoded.renderBackend, .gpu)

        var legacyObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(BeautyConfiguration.default))
                as? [String: Any]
        )
        legacyObject.removeValue(forKey: "renderBackend")
        let legacyData = try JSONSerialization.data(withJSONObject: legacyObject)
        let legacy = try JSONDecoder().decode(BeautyConfiguration.self, from: legacyData)
        XCTAssertEqual(legacy.renderBackend, .cpu)

        var invalidObject = legacyObject
        invalidObject["renderBackend"] = "metal"
        let invalidData = try JSONSerialization.data(withJSONObject: invalidObject)
        XCTAssertThrowsError(try JSONDecoder().decode(BeautyConfiguration.self, from: invalidData))
    }

    func testPhase73BackendSelectionIsNotPersistedInBeautyParameters() throws {
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(BeautyParameters()))
                as? [String: Any]
        )
        XCTAssertNil(object["renderBackend"])
        XCTAssertNil(object["backend"])
        XCTAssertEqual(object.count, 61)
    }

    func testSDK02DefaultConfigurationIsSafeForRelease() {
        let configuration = BeautyConfiguration.default

        XCTAssertNil(configuration.preferredProcessingSize)
        XCTAssertEqual(configuration.maximumFaceCount, 1)
        XCTAssertTrue(configuration.enableFaceTracking)
        XCTAssertEqual(configuration.detectionFrameInterval, 3)
        XCTAssertEqual(configuration.renderQuality, .balanced)
        XCTAssertFalse(configuration.enablePerformanceLog)
        XCTAssertFalse(configuration.enableDebugMode)
        XCTAssertEqual(configuration.logLevel, .error)
        XCTAssertEqual(configuration.maximumInputByteCount, 33_554_432)
        XCTAssertEqual(configuration.maximumInputPixelCount, 50_000_000)
    }

    func testPERF03RenderQualityModesAreStableConfigurationContract() {
        XCTAssertEqual(BeautyRenderQuality.performance.rawValue, "performance")
        XCTAssertEqual(BeautyRenderQuality.balanced.rawValue, "balanced")
        XCTAssertEqual(BeautyRenderQuality.quality.rawValue, "quality")

        let defaultConfiguration = BeautyConfiguration.default
        XCTAssertEqual(defaultConfiguration.renderQuality, .balanced)
        XCTAssertFalse(defaultConfiguration.enablePerformanceLog)
        XCTAssertEqual(defaultConfiguration.logLevel, .error)

        let performanceConfiguration = BeautyConfiguration(renderQuality: .performance)
        let qualityConfiguration = BeautyConfiguration(renderQuality: .quality)

        XCTAssertEqual(performanceConfiguration.renderQuality, .performance)
        XCTAssertEqual(qualityConfiguration.renderQuality, .quality)
        XCTAssertFalse(performanceConfiguration.enablePerformanceLog)
        XCTAssertEqual(qualityConfiguration.logLevel, .error)
        XCTAssertNotEqual(performanceConfiguration.renderQuality, qualityConfiguration.renderQuality)
        // PERF-03 currently verifies the configuration contract, not runtime quality strategy differences.
    }

    func testConfigurationClampsInvalidCountsAndSizes() {
        let configuration = BeautyConfiguration(
            preferredProcessingSize: CGSize(width: CGFloat.nan, height: 720),
            maximumFaceCount: 0,
            detectionFrameInterval: -4,
            maximumInputByteCount: 0,
            maximumInputPixelCount: -1
        )

        XCTAssertNil(configuration.preferredProcessingSize)
        XCTAssertEqual(configuration.maximumFaceCount, 1)
        XCTAssertEqual(configuration.detectionFrameInterval, 1)
        XCTAssertEqual(configuration.maximumInputByteCount, BeautyConfiguration.defaultMaximumInputByteCount)
        XCTAssertEqual(configuration.maximumInputPixelCount, BeautyConfiguration.defaultMaximumInputPixelCount)
    }

    func testInputLimitsAcceptPositiveCustomValues() {
        let configuration = BeautyConfiguration(
            maximumInputByteCount: 128,
            maximumInputPixelCount: 256
        )

        XCTAssertEqual(configuration.maximumInputByteCount, 128)
        XCTAssertEqual(configuration.maximumInputPixelCount, 256)
    }

    func testConfigurationIsCodableAndSendable() throws {
        let configuration = BeautyConfiguration(
            preferredProcessingSize: CGSize(width: 720, height: 1280),
            renderQuality: .quality,
            enablePerformanceLog: true,
            logLevel: .info
        )

        let data = try JSONEncoder().encode(configuration)
        let decoded = try JSONDecoder().decode(BeautyConfiguration.self, from: data)
        XCTAssertEqual(decoded, configuration)
        assertSendable(decoded)
    }

    func testLegacyConfigurationJSONDecodesMissingInputLimitsToDefaults() throws {
        let currentData = try JSONEncoder().encode(BeautyConfiguration.default)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: currentData) as? [String: Any])
        object.removeValue(forKey: "maximumInputByteCount")
        object.removeValue(forKey: "maximumInputPixelCount")
        let legacyData = try JSONSerialization.data(withJSONObject: object)

        let decoded = try JSONDecoder().decode(BeautyConfiguration.self, from: legacyData)

        XCTAssertEqual(decoded.maximumInputByteCount, BeautyConfiguration.defaultMaximumInputByteCount)
        XCTAssertEqual(decoded.maximumInputPixelCount, BeautyConfiguration.defaultMaximumInputPixelCount)
    }

    private func assertSendable<T: Sendable>(_ value: T) {
        _ = value
    }
}
