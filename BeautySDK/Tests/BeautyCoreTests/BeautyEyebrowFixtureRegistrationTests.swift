import CoreGraphics
import XCTest
import BeautyCore
import BeautyDetection
@_spi(Testing) import BeautySDK

final class BeautyEyebrowFixtureRegistrationTests: XCTestCase {
    func testBROW01ObservedInnerEndpointsMatchFrozenRasterBeforeRendering() throws {
        let width = 512
        // Independent copy of the frozen source's integer-PPM membership rule.
        // The expected positions are derived without a warp or an output image.
        let leftColumn = try XCTUnwrap((0..<width).last { column in
            let ppm = column * 1_000_000 / width
            return ppm >= 270_000 && ppm < 495_000
        })
        let rightColumn = try XCTUnwrap((0..<width).first { column in
            let ppm = column * 1_000_000 / width
            return ppm >= 505_000 && ppm < 730_000
        })
        let expectedLeft = (Double(leftColumn) + 0.5) / Double(width)
        let expectedRight = (Double(rightColumn) + 0.5) / Double(width)

        for (fixture, leftPresent, rightPresent): (SDKTestingFaceDetectionFixture, Bool, Bool) in [
            (.phase92PairedObservedEyebrows, true, true),
            (.phase92LeftOnlyObservedEyebrow, true, false),
            (.phase92RightOnlyObservedEyebrow, false, true),
        ] {
            let provider = SDKTestingFaceDetectionProvider([fixture])
            var detector = VisionFaceDetector(observationProvider: provider.makeObservationProvider())
            let result = detector.detect(
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                imageExtent: CGSize(width: width, height: width)
            )
            let support = try XCTUnwrap(result.observations.first?.observedEyebrowSupport)
            XCTAssertEqual(support.left != nil, leftPresent)
            XCTAssertEqual(support.right != nil, rightPresent)
            for (trace, expected) in [(support.left, expectedLeft), (support.right, expectedRight)] {
                guard let trace else { continue }
                let inner = try XCTUnwrap(trace.first)
                // Boolean diagnostics keep raw support out of test output.
                XCTAssertTrue(abs(inner.x - expected) < 0.000_001, "inner endpoint registration")
                XCTAssertTrue(inner.y >= 0.27 && inner.y < 0.41, "endpoint lies on source brow")
                XCTAssertEqual(trace.count, 5)
            }
            XCTAssertEqual(provider.invocationCount, 1)
        }
    }
}
