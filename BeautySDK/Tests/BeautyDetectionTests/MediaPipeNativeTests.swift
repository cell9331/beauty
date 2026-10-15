#if os(iOS)
import BeautyCore
import CoreGraphics
import CoreImage
import XCTest
@testable import BeautyDetection

final class MediaPipeNativeTests: XCTestCase {
    func testOversizedNativeFaceBudgetAbstainsBeforeAllocationAndRecovers() {
        var detector = BeautyFaceDetector.production()
        let image = CIImage(color: CIColor(red: 0.5, green: 0.5, blue: 0.5))
            .cropped(to: CGRect(x: 0, y: 0, width: 256, height: 256))
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        for budget in [33, Int.max] {
            let invalid = detector.detect(image: image, metadata: metadata, imageExtent: image.extent.size,
                configuration: BeautyConfiguration(maximumFaceCount: budget))
            XCTAssertEqual(invalid.summary.reasons, [.detectorUnavailable])
        }
        XCTAssertEqual(detector.detect(image: image, metadata: metadata, imageExtent: image.extent.size)
            .summary.availability, .noFace)
    }

    func testProductionMediaPipeNoFaceRepeatedAndResetRemainEmpty() {
        var detector = BeautyFaceDetector.production()
        let image = CIImage(color: CIColor(red: 0.5, green: 0.5, blue: 0.5))
            .cropped(to: CGRect(x: 0, y: 0, width: 256, height: 256))
        for index in 0..<6 {
            if index == 3 { detector.resetTracking() }
            let result = detector.detect(image: image, metadata: .init(orientation: .up, source: .testFixture),
                imageExtent: image.extent.size)
            XCTAssertTrue(result.observations.isEmpty)
            XCTAssertEqual(result.summary.availability, .noFace)
            XCTAssertEqual(result.summary.reasons, [.noFaceDetected])
        }
    }

    func testProductionInvalidRasterAbstainsAndRecoversOnValidNoFace() {
        var detector = BeautyFaceDetector.production()
        let image = CIImage(color: CIColor(red: 0.5, green: 0.5, blue: 0.5))
            .cropped(to: CGRect(x: 0, y: 0, width: 256, height: 256))
        let invalid = detector.detect(image: image, metadata: .init(orientation: .up, source: .testFixture),
            imageExtent: CGSize(width: 2, height: 2))
        XCTAssertEqual(invalid.summary.reasons, [.detectorUnavailable])
        let valid = detector.detect(image: image, metadata: .init(orientation: .up, source: .testFixture),
            imageExtent: image.extent.size)
        XCTAssertEqual(valid.summary.availability, .noFace)
        XCTAssertTrue(valid.observations.isEmpty)
    }
}
#endif
