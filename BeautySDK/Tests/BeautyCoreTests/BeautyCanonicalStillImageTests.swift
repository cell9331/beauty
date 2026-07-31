import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
import BeautySDK

/// Wave 0 specification for the still-image carrier.  The SPI harness is
/// intentionally supplied by Plans 53-02/53-04, so this suite is RED until the
/// production boundary exists.
final class BeautyCanonicalStillImageTests: XCTestCase {
    private let orientations: [CGImagePropertyOrientation] = [
        .up, .upMirrored, .down, .downMirrored,
        .leftMirrored, .right, .rightMirrored, .left,
    ]

    func testCarrierOwnsOneZeroOriginUpSRGBRGBA8Raster() throws {
        let harness = SDKTestingCanonicalStillImageHarness(maximumPixelCount: 64)
        let result = try harness.canonicalize(
            fixture: .asymmetricRGBA8(width: 3, height: 2),
            orientation: .up,
            isInputMirrored: false
        )

        XCTAssertEqual(result.extent, CGRect(x: 0, y: 0, width: 3, height: 2))
        XCTAssertEqual(result.width, 3)
        XCTAssertEqual(result.height, 2)
        XCTAssertEqual(result.rowBytes, 12)
        XCTAssertEqual(result.byteCount, 24)
        XCTAssertEqual(result.orientation, .up)
        XCTAssertEqual(result.pixelFormat, "RGBA8")
        XCTAssertEqual(result.colorSpace, "sRGB")
        XCTAssertTrue(result.isOpaque)
    }

    func testAllEightOrientationsAndMirrorVariantsNormalizeIdentically() throws {
        let harness = SDKTestingCanonicalStillImageHarness(maximumPixelCount: 64)
        let expected = try harness.canonicalize(
            fixture: .asymmetricRGBA8(width: 3, height: 2),
            orientation: .up,
            isInputMirrored: false
        ).rgba8Digest

        XCTAssertEqual(orientations.count, 8)
        for orientation in orientations {
            for isInputMirrored in [false, true] {
                let actual = try harness.canonicalize(
                    fixture: .losslessEncoding(of: .asymmetricRGBA8(width: 3, height: 2),
                                               orientation: orientation,
                                               mirrored: isInputMirrored),
                    orientation: orientation,
                    isInputMirrored: isInputMirrored
                )
                XCTAssertEqual(actual.rgba8Digest, expected, "\(orientation), mirror=\(isInputMirrored)")
                XCTAssertEqual(actual.extent.origin, .zero)
            }
        }
    }

    func testDisplayP3ConvertsToSRGBWithoutTopologyIdentityClaim() throws {
        let harness = SDKTestingCanonicalStillImageHarness(maximumPixelCount: 64)
        let result = try harness.canonicalize(
            fixture: .displayP3RGBA8(width: 3, height: 2),
            orientation: .up,
            isInputMirrored: false
        )

        XCTAssertEqual(result.colorSpace, "sRGB")
        XCTAssertEqual(result.pixelFormat, "RGBA8")
        XCTAssertFalse(result.claimsCrossProfileLandmarkOrMaskTopologyIdentity)
    }

    func testInvalidExtentsAndCheckedAllocationFailBeforeVision() {
        let harness = SDKTestingCanonicalStillImageHarness(maximumPixelCount: 16)
        let extents: [SDKTestingCanonicalFixture] = [
            .extent(.zero),
            .extent(CGRect(x: 0, y: 0, width: CGFloat.nan, height: 1)),
            .extent(CGRect(x: 0, y: 0, width: CGFloat.infinity, height: 1)),
            .extent(CGRect(x: 0, y: 0, width: 1.5, height: 2)),
            .extent(CGRect(x: 0, y: 0, width: 4, height: 5)), // one over 16
            .overflowShaped(width: Int.max, height: Int.max, bytesPerPixel: 4),
        ]

        for fixture in extents {
            XCTAssertThrowsError(try harness.canonicalize(fixture: fixture, orientation: .up, isInputMirrored: false)) {
                XCTAssertTrue(Self.isPayloadFreeAllowlistedError($0))
            }
            XCTAssertEqual(harness.detectorInvocationCount, 0)
            XCTAssertEqual(harness.supportInvocationCount, 0)
        }

        XCTAssertNoThrow(try harness.canonicalize(
            fixture: .asymmetricRGBA8(width: 4, height: 4), // exact ceiling
            orientation: .up,
            isInputMirrored: false
        ))
    }

    func testMalformedOrientationAndUnsupportedColorSemanticsFailBeforeVision() {
        let harness = SDKTestingCanonicalStillImageHarness(maximumPixelCount: 64)
        let fixtures: [(SDKTestingCanonicalFixture, Int)] = [
            (.asymmetricRGBA8(width: 2, height: 2), -1),
            (.asymmetricRGBA8(width: 2, height: 2), 0),
            (.asymmetricRGBA8(width: 2, height: 2), 9),
            (.nilColorSpace(width: 2, height: 2), 1),
            (.gray8(width: 2, height: 2), 1),
            (.cmyk8(width: 2, height: 2), 1),
            (.unknownColorModel(width: 2, height: 2), 1),
            (.extendedRangeRGB(width: 2, height: 2), 1),
        ]

        for (fixture, rawOrientation) in fixtures {
            XCTAssertThrowsError(try harness.canonicalize(
                fixture: fixture,
                rawExifOrientation: rawOrientation,
                isInputMirrored: false
            )) { XCTAssertTrue(Self.isPayloadFreeAllowlistedError($0)) }
            XCTAssertEqual(harness.detectorInvocationCount, 0)
            XCTAssertEqual(harness.supportInvocationCount, 0)
        }
    }

    func testPartialAndZeroAlphaFailBeforeVisionWithoutCompositingOrForcingOpaque() {
        let harness = SDKTestingCanonicalStillImageHarness(maximumPixelCount: 64)
        for alpha in [UInt8(254), UInt8(1), UInt8(0)] {
            XCTAssertThrowsError(try harness.canonicalize(
                fixture: .rgba8(width: 2, height: 2, alpha: alpha),
                orientation: .up,
                isInputMirrored: false
            )) { XCTAssertTrue(Self.isPayloadFreeAllowlistedError($0)) }
            XCTAssertEqual(harness.detectorInvocationCount, 0)
            XCTAssertEqual(harness.supportInvocationCount, 0)
        }
    }

    func testNearOpaqueFloatingAlphaFailsBeforeLossyRGBA8RenderAndVision() {
        let harness = SDKTestingCanonicalStillImageHarness(maximumPixelCount: 64)
        let fixtures: [SDKTestingCanonicalFixture] = [
            .rgbaFloat(width: 2, height: 2, alpha: 0.999),
            .rgbaFloat(width: 2, height: 2, alpha: Float(1).nextDown),
            .rgbaFloatWithOneNearOpaquePixel(width: 3, height: 2, alpha: 0.999),
        ]

        for fixture in fixtures {
            XCTAssertThrowsError(try harness.canonicalize(
                fixture: fixture,
                orientation: .up,
                isInputMirrored: false
            )) { XCTAssertTrue(Self.isPayloadFreeAllowlistedError($0)) }
            XCTAssertEqual(harness.detectorInvocationCount, 0)
            XCTAssertEqual(harness.supportInvocationCount, 0)
        }
    }

    private static func isPayloadFreeAllowlistedError(_ error: Error) -> Bool {
        guard let error = error as? BeautyError else { return false }
        XCTAssertTrue(error == .invalidInput || error == .unsupportedPixelFormat)
        XCTAssertTrue(["invalidInput", "unsupportedPixelFormat"].contains(error.description),
                      "typed rejection must carry no dimensions, paths, metadata, or portrait detail")
        return true
    }
}
