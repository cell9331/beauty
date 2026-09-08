import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautyCore
import BeautyDetection
@_spi(Testing) import BeautySDK

final class BeautyEyebrowFixtureRegistrationTests: XCTestCase {
    func testBROW01BothSignsPreserveMissingPeerPixels() throws {
        let width = 512
        var source = [UInt8](repeating: 255, count: width * width * 4)
        for y in 0..<width {
            for x in 0..<width {
                let xPPM = x * 1_000_000 / width
                let yPPM = y * 1_000_000 / width
                if yPPM >= 270_000 && yPPM < 410_000,
                   (xPPM >= 270_000 && xPPM < 495_000)
                    || (xPPM >= 505_000 && xPPM < 730_000) {
                    let offset = (y * width + x) * 4
                    let texture = UInt8((x * 31 + y * 17) % 61)
                    source[offset] = 35 + texture
                    source[offset + 1] = 45 + texture
                    source[offset + 2] = 55 + texture
                }
            }
        }
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let image = CIImage(bitmapData: Data(source), bytesPerRow: width * 4,
                            size: CGSize(width: width, height: width), format: .RGBA8,
                            colorSpace: colorSpace)
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        for strength: Float in [-0.25, 0.25] {
            for (fixture, missingLeft): (SDKTestingFaceDetectionFixture, Bool) in [
                (.phase92LeftOnlyObservedEyebrow, false),
                (.phase92RightOnlyObservedEyebrow, true),
            ] {
                let provider = SDKTestingFaceDetectionProvider([fixture])
                let engine = try BeautyEngine(faceDetectionProvider: provider)
                let result = try engine.processResult(
                    image: image,
                    metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                    parameters: BeautyParameters(eyebrowHeadSpacing: strength)
                )
                var output = [UInt8](repeating: 0, count: source.count)
                context.render(result.output, toBitmap: &output, rowBytes: width * 4,
                               bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
                var peerChanges = 0
                var ownChanges = 0
                for y in 0..<width {
                    for x in 0..<width {
                        let offset = (y * width + x) * 4
                        guard output[offset..<(offset + 4)] != source[offset..<(offset + 4)] else { continue }
                        if (x < width / 2) == missingLeft { peerChanges += 1 }
                        else { ownChanges += 1 }
                    }
                }
                XCTAssertEqual(peerChanges, 0, "both-sign peer isolation")
                XCTAssertGreaterThan(ownChanges, 0, "eligible side remains effective")
                XCTAssertEqual(provider.invocationCount, 1)
            }
        }
    }

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
