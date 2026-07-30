import Foundation
import CoreGraphics
import CoreImage
import ImageIO
import BeautyCore
import BeautyDetection

private let phase46ObservedContour = [
    CoordinatePoint(x: 0.025, y: 0.733_333_333),
    CoordinatePoint(x: 0.000, y: 0.600_000_000),
    CoordinatePoint(x: 0.0625, y: 0.466_666_667),
    CoordinatePoint(x: 0.125, y: 0.300_000_000),
    CoordinatePoint(x: 0.2875, y: 0.116_666_667),
    CoordinatePoint(x: 0.5125, y: 0.000_000_000),
    CoordinatePoint(x: 0.7125, y: 0.150_000_000),
    CoordinatePoint(x: 0.8500, y: 0.333_333_333),
    CoordinatePoint(x: 0.9375, y: 0.516_666_667),
    CoordinatePoint(x: 1.0000, y: 0.650_000_000),
    CoordinatePoint(x: 0.9500, y: 0.766_666_667),
]

private let phase46ObservedMedianLine = [
    CoordinatePoint(x: 0.4500, y: 0.833_333_333),
    CoordinatePoint(x: 0.4875, y: 0.416_666_667),
    CoordinatePoint(x: 0.5250, y: 0.016_666_667),
]

private let phase47MalformedObservedContour = [
    CoordinatePoint(x: 0.10, y: 0.20),
    CoordinatePoint(x: 0.20, y: 0.35),
    CoordinatePoint(x: 0.30, y: 0.50),
    CoordinatePoint(x: 0.30, y: 0.50),
    CoordinatePoint(x: 0.60, y: 0.50),
    CoordinatePoint(x: 0.70, y: 0.35),
    CoordinatePoint(x: 0.80, y: 0.20),
]

private let phase50ObservedLeftEyebrow = [
    CoordinatePoint(x: 0.42, y: 0.34),
    CoordinatePoint(x: 0.37, y: 0.37),
    CoordinatePoint(x: 0.32, y: 0.38),
    CoordinatePoint(x: 0.27, y: 0.37),
    CoordinatePoint(x: 0.22, y: 0.34),
]

private let phase50ObservedRightEyebrow = [
    CoordinatePoint(x: 0.58, y: 0.34),
    CoordinatePoint(x: 0.63, y: 0.37),
    CoordinatePoint(x: 0.68, y: 0.38),
    CoordinatePoint(x: 0.73, y: 0.37),
    CoordinatePoint(x: 0.78, y: 0.34),
]

private let phase50MalformedObservedEyebrow = [
    CoordinatePoint(x: 0.42, y: 0.34),
    CoordinatePoint(x: 0.37, y: 0.37),
    CoordinatePoint(x: 0.37, y: 0.37),
    CoordinatePoint(x: 0.27, y: 0.37),
]

@_spi(Testing) public enum SDKTestingFaceDetectionFixture: Sendable {
    case usableFace
    case missingObservedFaceContour
    case malformedObservedFaceContour
    case pairedObservedEyebrows
    case leftOnlyObservedEyebrow
    case rightOnlyObservedEyebrow
    case missingObservedEyebrows
    case malformedObservedEyebrows
    case noFace
    case lowConfidence
    case missingLandmarks
    case detectorUnavailable
    case detectionTimedOut
}

@_spi(Testing) public final class SDKTestingFaceDetectionProvider: @unchecked Sendable {
    private let lock = NSLock()
    private let fixtures: [SDKTestingFaceDetectionFixture]
    private var invocationCountValue = 0

    public init(_ fixtures: [SDKTestingFaceDetectionFixture]) {
        self.fixtures = fixtures.isEmpty ? [.noFace] : fixtures
    }

    public var invocationCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return invocationCountValue
    }

    package func makeObservationProvider() -> VisionFaceDetector.ObservationProvider {
        { [self] _ in
            switch nextFixture() {
            case .usableFace:
                return [
                    VisionDetectionObservation(
                        stableID: "fixture",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete,
                        observedFaceSupport: BeautyObservedFaceSupport(
                            contour: phase46ObservedContour,
                            medianLine: phase46ObservedMedianLine
                        )
                    )
                ]
            case .missingObservedFaceContour:
                return [
                    VisionDetectionObservation(
                        stableID: "fixture-missing-observed-contour",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete
                    )
                ]
            case .malformedObservedFaceContour:
                return [
                    VisionDetectionObservation(
                        stableID: "fixture-malformed-observed-contour",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete,
                        observedFaceSupport: BeautyObservedFaceSupport(
                            contour: phase47MalformedObservedContour,
                            medianLine: phase46ObservedMedianLine
                        )
                    )
                ]
            case .pairedObservedEyebrows:
                return [
                    VisionDetectionObservation(
                        stableID: "fixture-paired-observed-eyebrows",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete,
                        observedFaceSupport: BeautyObservedFaceSupport(
                            contour: phase46ObservedContour,
                            medianLine: phase46ObservedMedianLine
                        ),
                        observedEyebrowSupport: BeautyObservedEyebrowSupport(
                            left: phase50ObservedLeftEyebrow,
                            right: phase50ObservedRightEyebrow
                        )
                    )
                ]
            case .leftOnlyObservedEyebrow:
                return [
                    VisionDetectionObservation(
                        stableID: "fixture-left-only-observed-eyebrow",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete,
                        observedEyebrowSupport: BeautyObservedEyebrowSupport(
                            left: phase50ObservedLeftEyebrow
                        )
                    )
                ]
            case .rightOnlyObservedEyebrow:
                return [
                    VisionDetectionObservation(
                        stableID: "fixture-right-only-observed-eyebrow",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete,
                        observedEyebrowSupport: BeautyObservedEyebrowSupport(
                            right: phase50ObservedRightEyebrow
                        )
                    )
                ]
            case .missingObservedEyebrows:
                return [
                    VisionDetectionObservation(
                        stableID: "fixture-missing-observed-eyebrows",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete
                    )
                ]
            case .malformedObservedEyebrows:
                return [
                    VisionDetectionObservation(
                        stableID: "fixture-malformed-observed-eyebrows",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete,
                        observedEyebrowSupport: BeautyObservedEyebrowSupport(
                            left: phase50MalformedObservedEyebrow,
                            right: phase50MalformedObservedEyebrow
                        )
                    )
                ]
            case .noFace:
                return []
            case .lowConfidence:
                return [
                    VisionDetectionObservation(
                        stableID: "low",
                        confidence: 0.20,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete
                    )
                ]
            case .missingLandmarks:
                return [
                    VisionDetectionObservation(
                        stableID: "partial",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .missingRequiredGeometry
                    )
                ]
            case .detectorUnavailable:
                throw VisionFaceDetector.Failure.detectorUnavailable
            case .detectionTimedOut:
                throw VisionFaceDetector.Failure.detectionTimedOut
            }
        }
    }

    private func nextFixture() -> SDKTestingFaceDetectionFixture {
        lock.lock()
        defer { lock.unlock() }

        let index = min(invocationCountValue, fixtures.count - 1)
        invocationCountValue += 1
        return fixtures[index]
    }
}

@_spi(Testing) public extension BeautyEngine {
    convenience init(
        configuration: BeautyConfiguration = .default,
        faceDetectionProvider: SDKTestingFaceDetectionProvider
    ) throws {
        try self.init(
            configuration: configuration,
            faceDetector: VisionFaceDetector(
                observationProvider: faceDetectionProvider.makeObservationProvider()
            )
        )
    }
}

package indirect enum SDKTestingCanonicalFixture: Sendable {
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
    case losslessEncoding(
        of: SDKTestingCanonicalFixture,
        orientation: CGImagePropertyOrientation,
        mirrored: Bool
    )
}

package struct SDKTestingCanonicalResult: Sendable {
    package let extent: CGRect
    package let width: Int
    package let height: Int
    package let rowBytes: Int
    package let byteCount: Int
    package let orientation: CGImagePropertyOrientation
    package let pixelFormat: String
    package let colorSpace: String
    package let isOpaque: Bool
    package let backingIdentity: Int
    package let visionBackingIdentity: Int
    package let renderBackingIdentity: Int
    package let rgba8Digest: String
    package let claimsCrossProfileLandmarkOrMaskTopologyIdentity: Bool
}

package final class SDKTestingCanonicalStillImageHarness: @unchecked Sendable {
    private let maximumPixelCount: Int
    private let canonicalizer: BeautyStillImageCanonicalizer

    package let detectorInvocationCount = 0
    package let supportInvocationCount = 0

    package init(maximumPixelCount: Int) {
        self.maximumPixelCount = maximumPixelCount
        self.canonicalizer = BeautyStillImageCanonicalizer()
    }

    package func canonicalize(
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

    package func canonicalize(
        fixture: SDKTestingCanonicalFixture,
        rawExifOrientation: Int,
        isInputMirrored: Bool
    ) throws -> SDKTestingCanonicalResult {
        let input = try makeInput(fixture)
        let carrier = try canonicalizer.canonicalize(
            image: input.image,
            rawExifOrientation: rawExifOrientation,
            isInputMirrored: isInputMirrored,
            isPreviewMirrored: false,
            source: .testFixture,
            timestamp: nil,
            maximumPixelCount: maximumPixelCount,
            inputColorSemantics: input.colorSemantics,
            extentOverride: input.extentOverride
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
            rgba8Digest: Self.digest(carrier.rgba8Data),
            claimsCrossProfileLandmarkOrMaskTopologyIdentity: false
        )
    }

    private struct Input {
        let image: CIImage
        let colorSemantics: BeautyStillImageCanonicalizer.InputColorSemantics
        let extentOverride: CGRect?
    }

    private func makeInput(_ fixture: SDKTestingCanonicalFixture) throws -> Input {
        switch fixture {
        case .asymmetricRGBA8(let width, let height):
            return Input(
                image: try Self.bitmapImage(width: width, height: height, alpha: 255, colorSpace: Self.sRGB()),
                colorSemantics: .image,
                extentOverride: nil
            )
        case .displayP3RGBA8(let width, let height):
            guard let displayP3 = CGColorSpace(name: CGColorSpace.displayP3) else {
                throw BeautyError.unsupportedPixelFormat
            }
            return Input(
                image: try Self.bitmapImage(width: width, height: height, alpha: 255, colorSpace: displayP3),
                colorSemantics: .image,
                extentOverride: nil
            )
        case .rgba8(let width, let height, let alpha):
            return Input(
                image: try Self.bitmapImage(width: width, height: height, alpha: alpha, colorSpace: Self.sRGB()),
                colorSemantics: .image,
                extentOverride: nil
            )
        case .nilColorSpace(let width, let height):
            return Input(
                image: try Self.bitmapImage(width: width, height: height, alpha: 255, colorSpace: Self.sRGB()),
                colorSemantics: .missing,
                extentOverride: nil
            )
        case .gray8(let width, let height):
            return Input(
                image: try Self.bitmapImage(width: width, height: height, alpha: 255, colorSpace: Self.sRGB()),
                colorSemantics: .colorSpace(CGColorSpaceCreateDeviceGray()),
                extentOverride: nil
            )
        case .unknownColorModel(let width, let height):
            return Input(
                image: try Self.bitmapImage(width: width, height: height, alpha: 255, colorSpace: Self.sRGB()),
                colorSemantics: .colorSpace(try Self.indexedColorSpace()),
                extentOverride: nil
            )
        case .cmyk8(let width, let height):
            return Input(
                image: try Self.bitmapImage(width: width, height: height, alpha: 255, colorSpace: Self.sRGB()),
                colorSemantics: .colorSpace(CGColorSpaceCreateDeviceCMYK()),
                extentOverride: nil
            )
        case .extendedRangeRGB(let width, let height):
            guard let extendedSRGB = CGColorSpace(name: CGColorSpace.extendedSRGB) else {
                throw BeautyError.unsupportedPixelFormat
            }
            return Input(
                image: try Self.bitmapImage(width: width, height: height, alpha: 255, colorSpace: Self.sRGB()),
                colorSemantics: .colorSpace(extendedSRGB),
                extentOverride: nil
            )
        case .extent(let extent):
            return Input(
                image: try Self.bitmapImage(width: 1, height: 1, alpha: 255, colorSpace: Self.sRGB()),
                colorSemantics: .image,
                extentOverride: extent
            )
        case .overflowShaped(let width, let height, let bytesPerPixel):
            _ = bytesPerPixel
            return Input(
                image: try Self.bitmapImage(width: 1, height: 1, alpha: 255, colorSpace: Self.sRGB()),
                colorSemantics: .image,
                extentOverride: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
            )
        case .losslessEncoding(let base, let orientation, let mirrored):
            let baseInput = try makeInput(base)
            var desiredBeforeOrientation = baseInput.image
            if mirrored {
                desiredBeforeOrientation = Self.mirroredHorizontally(desiredBeforeOrientation)
            }
            let encoded = desiredBeforeOrientation.oriented(
                forExifOrientation: Int32(Self.inverse(orientation).rawValue)
            )
            return Input(
                image: encoded,
                colorSemantics: baseInput.colorSemantics,
                extentOverride: nil
            )
        }
    }

    private static func sRGB() throws -> CGColorSpace {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.unsupportedPixelFormat
        }
        return colorSpace
    }

    private static func indexedColorSpace() throws -> CGColorSpace {
        let baseColorSpace = try sRGB()
        let colorTable: [UInt8] = [
            0, 0, 0,
            255, 255, 255,
        ]
        guard let colorSpace = colorTable.withUnsafeBufferPointer({ table -> CGColorSpace? in
            guard let baseAddress = table.baseAddress else {
                return nil
            }
            return CGColorSpace(indexedBaseSpace: baseColorSpace, last: 1, colorTable: baseAddress)
        }) else {
            throw BeautyError.unsupportedPixelFormat
        }
        return colorSpace
    }

    private static func bitmapImage(
        width: Int,
        height: Int,
        alpha: UInt8,
        colorSpace: CGColorSpace
    ) throws -> CIImage {
        guard width > 0,
              height > 0
        else {
            throw BeautyError.invalidInput
        }
        let (rowBytes, rowOverflow) = width.multipliedReportingOverflow(by: 4)
        let (byteCount, totalOverflow) = rowBytes.multipliedReportingOverflow(by: height)
        guard rowOverflow == false,
              totalOverflow == false
        else {
            throw BeautyError.invalidInput
        }

        var bytes = Data(count: byteCount)
        for pixel in 0..<(width * height) {
            let offset = pixel * 4
            bytes[offset] = UInt8(truncatingIfNeeded: pixel &* 53 &+ 17)
            bytes[offset + 1] = UInt8(truncatingIfNeeded: pixel &* 97 &+ 29)
            bytes[offset + 2] = UInt8(truncatingIfNeeded: pixel &* 31 &+ 43)
            bytes[offset + 3] = alpha
        }
        return CIImage(
            bitmapData: bytes,
            bytesPerRow: rowBytes,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    private static func mirroredHorizontally(_ image: CIImage) -> CIImage {
        let extent = image.extent
        return image.transformed(by: CGAffineTransform(
            a: -1,
            b: 0,
            c: 0,
            d: 1,
            tx: extent.minX + extent.maxX,
            ty: 0
        ))
    }

    private static func inverse(_ orientation: CGImagePropertyOrientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .right:
            .left
        case .left:
            .right
        default:
            orientation
        }
    }

    private static func digest(_ bytes: Data) -> String {
        let hash = bytes.reduce(UInt64(1_469_598_103_934_665_603)) { partial, byte in
            (partial ^ UInt64(byte)) &* 1_099_511_628_211
        }
        return String(hash, radix: 16)
    }
}
