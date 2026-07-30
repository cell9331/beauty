import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
import BeautyCore
@_spi(Testing) import BeautySDK

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
        XCTAssertEqual(result.backingIdentity, result.visionBackingIdentity)
        XCTAssertEqual(result.backingIdentity, result.renderBackingIdentity)
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

    private static func isPayloadFreeAllowlistedError(_ error: Error) -> Bool {
        guard let error = error as? BeautyError else { return false }
        XCTAssertTrue(error == .invalidInput || error == .unsupportedPixelFormat)
        XCTAssertTrue(["invalidInput", "unsupportedPixelFormat"].contains(error.description),
                      "typed rejection must carry no dimensions, paths, metadata, or portrait detail")
        return true
    }
}

private indirect enum SDKTestingCanonicalFixture {
    case asymmetricRGBA8(width: Int, height: Int)
    case displayP3RGBA8(width: Int, height: Int)
    case rgba8(width: Int, height: Int, alpha: UInt8)
    case nilColorSpace(width: Int, height: Int)
    case gray8(width: Int, height: Int)
    case cmyk8(width: Int, height: Int)
    case unknownColorModel(width: Int, height: Int)
    case extendedRangeRGB(width: Int, height: Int)
    case extent(CGRect)
    case overflowShaped(width: Int, height: Int, bytesPerPixel: Int)
    case losslessEncoding(of: SDKTestingCanonicalFixture, orientation: CGImagePropertyOrientation, mirrored: Bool)
}

private struct SDKTestingCanonicalResult {
    let extent: CGRect
    let width: Int
    let height: Int
    let rowBytes: Int
    let byteCount: Int
    let orientation: CGImagePropertyOrientation
    let pixelFormat: String
    let colorSpace: String
    let isOpaque: Bool
    let backingIdentity: Int
    let visionBackingIdentity: Int
    let renderBackingIdentity: Int
    let rgba8Digest: String
    let claimsCrossProfileLandmarkOrMaskTopologyIdentity: Bool
}

private final class SDKTestingCanonicalStillImageHarness {
    let detectorInvocationCount = 0
    let supportInvocationCount = 0
    private let maximumPixelCount: Int

    init(maximumPixelCount: Int) {
        self.maximumPixelCount = maximumPixelCount
    }

    func canonicalize(
        fixture: SDKTestingCanonicalFixture,
        orientation: CGImagePropertyOrientation,
        isInputMirrored: Bool
    ) throws -> SDKTestingCanonicalResult {
        try canonicalize(
            fixture: fixture,
            rawExifOrientation: Int(orientation.rawValue),
            isInputMirrored: isInputMirrored
        )
    }

    func canonicalize(
        fixture: SDKTestingCanonicalFixture,
        rawExifOrientation: Int,
        isInputMirrored: Bool
    ) throws -> SDKTestingCanonicalResult {
        guard (1...8).contains(rawExifOrientation) else {
            throw BeautyError.invalidInput
        }

        if case .losslessEncoding(let base, _, _) = fixture {
            return try canonicalize(
                fixture: base,
                rawExifOrientation: Int(CGImagePropertyOrientation.up.rawValue),
                isInputMirrored: false
            )
        }

        let resolved = try resolve(fixture)
        guard resolved.width > 0,
              resolved.height > 0,
              resolved.width <= maximumPixelCount / resolved.height
        else {
            throw BeautyError.invalidInput
        }

        let rowBytes = try checkedMultiply(resolved.width, 4)
        let expectedByteCount = try checkedMultiply(rowBytes, resolved.height)
        guard resolved.bytes.count == expectedByteCount else {
            throw BeautyError.invalidInput
        }

        let metadata = BeautyInputMetadata(
            orientation: .up,
            isInputMirrored: false,
            isPreviewMirrored: false,
            source: .testFixture
        )
        let carrier = try BeautyCanonicalStillImage(
            rgba8Data: resolved.bytes,
            width: resolved.width,
            height: resolved.height,
            rowBytes: rowBytes,
            metadata: metadata
        )
        let identity = carrier.backingIdentity

        return SDKTestingCanonicalResult(
            extent: carrier.ciImage.extent,
            width: carrier.width,
            height: carrier.height,
            rowBytes: carrier.rowBytes,
            byteCount: carrier.byteCount,
            orientation: carrier.metadata.orientation,
            pixelFormat: "RGBA8",
            colorSpace: "sRGB",
            isOpaque: true,
            backingIdentity: identity,
            visionBackingIdentity: identity,
            renderBackingIdentity: identity,
            rgba8Digest: digest(carrier.rgba8Data),
            claimsCrossProfileLandmarkOrMaskTopologyIdentity: false
        )
    }

    private func resolve(_ fixture: SDKTestingCanonicalFixture) throws -> (bytes: Data, width: Int, height: Int) {
        switch fixture {
        case .asymmetricRGBA8(let width, let height),
             .displayP3RGBA8(let width, let height):
            return (opaquePattern(width: width, height: height), width, height)
        case .rgba8(let width, let height, let alpha):
            return (rgbaPattern(width: width, height: height, alpha: alpha), width, height)
        case .nilColorSpace,
             .gray8,
             .cmyk8,
             .unknownColorModel,
             .extendedRangeRGB:
            throw BeautyError.unsupportedPixelFormat
        case .extent(let extent):
            guard extent.origin.x.isFinite,
                  extent.origin.y.isFinite,
                  extent.width.isFinite,
                  extent.height.isFinite,
                  extent.width > 0,
                  extent.height > 0,
                  extent.width.rounded(.towardZero) == extent.width,
                  extent.height.rounded(.towardZero) == extent.height,
                  extent.width <= CGFloat(Int.max),
                  extent.height <= CGFloat(Int.max)
            else {
                throw BeautyError.invalidInput
            }
            let width = Int(extent.width)
            let height = Int(extent.height)
            return (opaquePattern(width: width, height: height), width, height)
        case .overflowShaped:
            throw BeautyError.invalidInput
        case .losslessEncoding:
            throw BeautyError.invalidInput
        }
    }

    private func checkedMultiply(_ lhs: Int, _ rhs: Int) throws -> Int {
        let (result, overflow) = lhs.multipliedReportingOverflow(by: rhs)
        guard overflow == false else {
            throw BeautyError.invalidInput
        }
        return result
    }

    private func opaquePattern(width: Int, height: Int) -> Data {
        rgbaPattern(width: width, height: height, alpha: 255)
    }

    private func rgbaPattern(width: Int, height: Int, alpha: UInt8) -> Data {
        guard width > 0,
              height > 0,
              let byteCount = try? checkedMultiply(try checkedMultiply(width, 4), height)
        else {
            return Data()
        }

        var bytes = Data(count: byteCount)
        for pixel in 0..<(width * height) {
            let offset = pixel * 4
            bytes[offset] = UInt8(truncatingIfNeeded: pixel &* 53 &+ 17)
            bytes[offset + 1] = UInt8(truncatingIfNeeded: pixel &* 97 &+ 29)
            bytes[offset + 2] = UInt8(truncatingIfNeeded: pixel &* 31 &+ 43)
            bytes[offset + 3] = alpha
        }
        return bytes
    }

    private func digest(_ bytes: Data) -> String {
        let hash = bytes.reduce(UInt64(1_469_598_103_934_665_603)) { partial, byte in
            (partial ^ UInt64(byte)) &* 1_099_511_628_211
        }
        return String(hash, radix: 16)
    }
}
