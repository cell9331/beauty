import CoreGraphics
import XCTest
import BeautySDK

final class BeautyConfigurationTests: XCTestCase {
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
    }

    func testConfigurationClampsInvalidCountsAndSizes() {
        let configuration = BeautyConfiguration(
            preferredProcessingSize: CGSize(width: CGFloat.nan, height: 720),
            maximumFaceCount: 0,
            detectionFrameInterval: -4
        )

        XCTAssertNil(configuration.preferredProcessingSize)
        XCTAssertEqual(configuration.maximumFaceCount, 1)
        XCTAssertEqual(configuration.detectionFrameInterval, 1)
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

    private func assertSendable<T: Sendable>(_ value: T) {
        _ = value
    }
}
