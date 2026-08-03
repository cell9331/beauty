import Foundation
import CoreGraphics
import CoreImage
import ImageIO
import BeautyCore
import BeautyDetection
import BeautyEffects

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
    case rgbaFloat(width: Int, height: Int, alpha: Float)
    case rgbaFloatWithOneNearOpaquePixel(width: Int, height: Int, alpha: Float)
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
        case .rgbaFloat(let width, let height, let alpha):
            return Input(
                image: try Self.floatingPointImage(
                    width: width,
                    height: height,
                    alphas: Array(repeating: alpha, count: width * height),
                    colorSpace: Self.sRGB()
                ),
                colorSemantics: .image,
                extentOverride: nil
            )
        case .rgbaFloatWithOneNearOpaquePixel(let width, let height, let alpha):
            var alphas = Array(repeating: Float(1), count: width * height)
            guard alphas.isEmpty == false else {
                throw BeautyError.invalidInput
            }
            alphas[alphas.count / 2] = alpha
            return Input(
                image: try Self.floatingPointImage(
                    width: width,
                    height: height,
                    alphas: alphas,
                    colorSpace: Self.sRGB()
                ),
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

    private static func floatingPointImage(
        width: Int,
        height: Int,
        alphas: [Float],
        colorSpace: CGColorSpace
    ) throws -> CIImage {
        guard width > 0,
              height > 0,
              alphas.count == width * height
        else {
            throw BeautyError.invalidInput
        }

        var pixels = [Float]()
        pixels.reserveCapacity(alphas.count * 4)
        for alpha in alphas {
            pixels.append(contentsOf: [0.25, 0.50, 0.75, alpha])
        }
        let data = pixels.withUnsafeBytes { Data($0) }
        return CIImage(
            bitmapData: data,
            bytesPerRow: width * MemoryLayout<Float>.stride * 4,
            size: CGSize(width: width, height: height),
            format: .RGBAf,
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

// MARK: - Phase 53 request-local foundation testing seam

@_spi(Testing) public enum SDKTestingStillImageFacadeEntry: Sendable {
    case process
    case processResult
}

@_spi(Testing) public enum SDKTestingLocalRetouchEvent: Equatable, Sendable {
    case canonicalize
    case detectAndMap
    case makeRequestContext
    case compose
    case render
}

@_spi(Testing) public enum SDKTestingLocalCompositionScenario: Sendable {
    case disjoint
    case collision
    case invalidUnit
    case empty
    case firstUnitAbsent
    case pairedUnitsAbsent
    case secondUnitAbsent
    case thirdUnitAbsent
}

@_spi(Testing) public struct SDKTestingLocalCompositionObservation: Equatable, Sendable {
    public let width: Int
    public let height: Int
    public let compositionInvocationCount: Int
    public let sourceBindingMatched: Bool
    public let acceptedUnitCount: Int
    public let rejectedUnitCount: Int
    public let ownedPixelCount: Int
    public let changedPixelCount: Int
    public let changedOutsideUnionPixelCount: Int
    public let collisionPixelCount: Int

    public init(
        width: Int = 0,
        height: Int = 0,
        compositionInvocationCount: Int = 0,
        sourceBindingMatched: Bool = false,
        acceptedUnitCount: Int = 0,
        rejectedUnitCount: Int = 0,
        ownedPixelCount: Int = 0,
        changedPixelCount: Int = 0,
        changedOutsideUnionPixelCount: Int = 0,
        collisionPixelCount: Int = 0
    ) {
        self.width = width
        self.height = height
        self.compositionInvocationCount = compositionInvocationCount
        self.sourceBindingMatched = sourceBindingMatched
        self.acceptedUnitCount = acceptedUnitCount
        self.rejectedUnitCount = rejectedUnitCount
        self.ownedPixelCount = ownedPixelCount
        self.changedPixelCount = changedPixelCount
        self.changedOutsideUnionPixelCount = changedOutsideUnionPixelCount
        self.collisionPixelCount = collisionPixelCount
    }
}

@_spi(Testing) public enum SDKTestingLocalSupportFixture: Sendable {
    case noFace
    case missingSupport
}

@_spi(Testing) public enum SDKTestingLocalSupportSequence: Sendable {
    case available(valueID: Int)
    case malformed
}

@_spi(Testing) public struct SDKTestingLocalResult: @unchecked Sendable {
    public let output: CIImage
    public let width: Int
    public let height: Int
    public let aggregateSupportValueID: Int?
    public let detectionAvailability: String?
    public let detectionReasons: [String]
}

package final class BeautyLocalRetouchTestingHooks: @unchecked Sendable {
    package enum Fixture: Sendable {
        case noFace
        case missingSupport
        case available(valueID: Int)
        case availableMissingUnrelatedGeometry(valueID: Int, omissionIndex: Int)
        case malformed
    }

    package let admittedPrivateDemandCount: Int

    private let lock = NSLock()
    private let fixtures: [Fixture]
    private let compositionScenarios: [SDKTestingLocalCompositionScenario?]
    private var fixtureIndex = 0
    private var compositionScenarioIndex = 0
    private var currentCompositionScenario: SDKTestingLocalCompositionScenario?
    private var currentCompositionSourceBindingMatched = false
    private var lastCompositionObservationValue = SDKTestingLocalCompositionObservation()
    private var eventsValue: [SDKTestingLocalRetouchEvent] = []
    private var canonicalizeCountValue = 0
    private var detectAndMapCountValue = 0
    private var makeRequestContextCountValue = 0
    private var renderCountValue = 0
    private var activeRequestContextCountValue = 0
    private var currentAggregateSupportValueID: Int?
    private var lastAggregateSupportValueIDValue: Int?
    private var currentRequestIsMalformed = false
    private var currentCanonicalBackingIdentity: Int?
    private var currentCanonicalViewIdentity: ObjectIdentifier?
    private var detectorViewIdentity: ObjectIdentifier?
    private var rendererBackingIdentity: Int?
    private var rendererUsesExplicitSRGB = false
    private var canonicalizerIdentities: [ObjectIdentifier] = []
    private var canonicalizerContextIdentities: [ObjectIdentifier] = []
    private var canonicalizerConstructionCountValue = 0
    private var activeMappingInvocationCountValue = 0
    private var activeMappedPointCountValue = 0
    private var lastMappingInvocationCountValue = 0
    private var lastMappedPointCountValue = 0

    package init(
        admittedPrivateDemandCount: Int,
        fixtures: [Fixture],
        compositionScenarios: [SDKTestingLocalCompositionScenario?] = [nil]
    ) {
        self.admittedPrivateDemandCount = max(0, admittedPrivateDemandCount)
        self.fixtures = fixtures.isEmpty ? [.missingSupport] : fixtures
        self.compositionScenarios = compositionScenarios.isEmpty ? [nil] : compositionScenarios
    }

    package var events: [SDKTestingLocalRetouchEvent] { withLock { eventsValue } }
    package var canonicalizeCount: Int { withLock { canonicalizeCountValue } }
    package var detectAndMapCount: Int { withLock { detectAndMapCountValue } }
    package var makeRequestContextCount: Int { withLock { makeRequestContextCountValue } }
    package var renderCount: Int { withLock { renderCountValue } }
    package var activeRequestContextCount: Int { withLock { activeRequestContextCountValue } }
    package var lastAggregateSupportValueID: Int? { withLock { lastAggregateSupportValueIDValue } }
    package var canonicalConsumerIdentityMatched: Bool {
        withLock {
            currentCanonicalBackingIdentity != nil &&
                currentCanonicalBackingIdentity == rendererBackingIdentity &&
                currentCanonicalViewIdentity != nil &&
                currentCanonicalViewIdentity == detectorViewIdentity
        }
    }
    package var usedExplicitSRGBRender: Bool { withLock { rendererUsesExplicitSRGB } }
    package var canonicalizerConstructionCount: Int {
        withLock { canonicalizerConstructionCountValue }
    }
    package var lastMappingInvocationCount: Int {
        withLock { lastMappingInvocationCountValue }
    }
    package var lastMappedPointCount: Int {
        withLock { lastMappedPointCountValue }
    }
    package var compositionObservation: SDKTestingLocalCompositionObservation {
        withLock { lastCompositionObservationValue }
    }
    package var hasOpaqueCompositionScenario: Bool {
        withLock { currentCompositionScenario != nil }
    }
    package var retainedMappedPointCount: Int {
        withLock { activeMappedPointCountValue }
    }
    package var reusedCanonicalizerAndContextAcrossRequests: Bool {
        withLock {
            canonicalizerIdentities.count >= 2 &&
                Set(canonicalizerIdentities).count == 1 &&
                canonicalizerContextIdentities.count == canonicalizerIdentities.count &&
                Set(canonicalizerContextIdentities).count == 1
        }
    }

    package func beginStillRequest() {
        withLock {
            let scenarioIndex = min(compositionScenarioIndex, compositionScenarios.count - 1)
            currentCompositionScenario = compositionScenarios[scenarioIndex]
            compositionScenarioIndex += 1
            currentCompositionSourceBindingMatched = false
            lastCompositionObservationValue = SDKTestingLocalCompositionObservation()
            currentAggregateSupportValueID = nil
            lastAggregateSupportValueIDValue = nil
            currentRequestIsMalformed = false
            activeRequestContextCountValue = 0
            currentCanonicalBackingIdentity = nil
            currentCanonicalViewIdentity = nil
            detectorViewIdentity = nil
            rendererBackingIdentity = nil
            rendererUsesExplicitSRGB = false
        }
    }

    package func finishStillRequest() {
        withLock {
            currentCompositionScenario = nil
            currentCompositionSourceBindingMatched = false
            currentAggregateSupportValueID = nil
            currentRequestIsMalformed = false
            activeRequestContextCountValue = 0
        }
    }

    package func recordCanonicalCarrier(_ carrier: BeautyCanonicalStillImage) {
        withLock {
            currentCanonicalBackingIdentity = carrier.backingIdentity
            currentCanonicalViewIdentity = ObjectIdentifier(carrier.ciImage)
        }
    }

    package func recordCanonicalizer(_ canonicalizer: BeautyStillImageCanonicalizer) {
        withLock {
            canonicalizerIdentities.append(ObjectIdentifier(canonicalizer))
            if let contextIdentity = canonicalizer.contextIdentity {
                canonicalizerContextIdentities.append(contextIdentity)
            }
        }
    }

    package func recordCanonicalizerConstruction() {
        withLock {
            canonicalizerConstructionCountValue += 1
        }
    }

    package func recordCanonicalRasterize(
        carrier: BeautyCanonicalStillImage,
        colorSpace: CGColorSpace
    ) {
        withLock {
            rendererBackingIdentity = carrier.backingIdentity
            rendererUsesExplicitSRGB = colorSpace.name == CGColorSpace.sRGB
        }
    }

    package func record(_ event: SDKTestingLocalRetouchEvent) {
        withLock {
            eventsValue.append(event)
            switch event {
            case .canonicalize:
                canonicalizeCountValue += 1
            case .detectAndMap:
                detectAndMapCountValue += 1
            case .makeRequestContext:
                makeRequestContextCountValue += 1
            case .compose:
                break
            case .render:
                renderCountValue += 1
            }
        }
    }

    package func makeOpaqueCompositionUnits(
        using owner: BeautyLocalRetouchCompositionOwner,
        source: BeautyCanonicalStillImage,
        expectedSource: BeautyCanonicalStillImage
    ) -> [BeautyLocalRetouchUnit] {
        let scenario = withLock {
            currentCompositionSourceBindingMatched =
                source.pixelSourceBinding == expectedSource.pixelSourceBinding
            return currentCompositionScenario
        }
        guard let scenario else {
            return []
        }

        func proposal(_ pixelIndex: Int, _ red: UInt8, _ green: UInt8, _ blue: UInt8)
            -> BeautyLocalPixelProposal
        {
            BeautyLocalPixelProposal(
                pixelIndex: pixelIndex,
                isInsideHardEnvelope: true,
                softWeightQ16: 65_536,
                targetRed: red,
                targetGreen: green,
                targetBlue: blue
            )
        }

        func unit(_ proposal: BeautyLocalPixelProposal) -> BeautyLocalRetouchUnit? {
            owner.makeUnit(proposals: [proposal])
        }

        let first = { unit(proposal(0, 201, 41, 11)) }
        let second = { unit(proposal(1, 21, 211, 61)) }
        let third = { unit(proposal(2, 71, 31, 221)) }

        switch scenario {
        case .disjoint:
            return [first(), second(), third()].compactMap { $0 }
        case .collision:
            return [
                unit(proposal(0, 201, 41, 11)),
                unit(proposal(0, 21, 211, 61)),
                unit(proposal(1, 71, 31, 221)),
            ].compactMap { $0 }
        case .invalidUnit:
            return [first(), unit(proposal(Int.max, 1, 2, 3)), third()].compactMap { $0 }
        case .empty:
            return []
        case .firstUnitAbsent:
            return [second(), third()].compactMap { $0 }
        case .pairedUnitsAbsent:
            return [first()].compactMap { $0 }
        case .secondUnitAbsent:
            return [first(), third()].compactMap { $0 }
        case .thirdUnitAbsent:
            return [first(), second()].compactMap { $0 }
        }
    }

    package func recordComposition(
        _ result: BeautyLocalRetouchCompositionResult
    ) {
        withLock {
            let summary = result.summary
            lastCompositionObservationValue = SDKTestingLocalCompositionObservation(
                width: result.canonicalImage.width,
                height: result.canonicalImage.height,
                compositionInvocationCount: 1,
                sourceBindingMatched: currentCompositionSourceBindingMatched,
                acceptedUnitCount: summary.acceptedUnitCount,
                rejectedUnitCount: summary.rejectedUnitCount,
                ownedPixelCount: summary.ownedPixelCount,
                changedPixelCount: summary.changedPixelCount,
                changedOutsideUnionPixelCount: summary.changedOutsideUnionPixelCount,
                collisionPixelCount: summary.collisionPixelCount
            )
        }
    }

    package func recordRequestContext(_ context: BeautyStillImageRequestContext) {
        withLock {
            activeRequestContextCountValue = 1
            let hasMappedSupport = context.selectedFaceObservation?.observedLipSupport != nil
            lastAggregateSupportValueIDValue = hasMappedSupport
                ? currentAggregateSupportValueID
                : nil
            _ = context.redactedSummary.description
        }
    }

    package func consumeMalformedRequest() -> Bool {
        withLock { currentRequestIsMalformed }
    }

    package func makeObservationProvider() -> VisionFaceDetector.ObservationProvider {
        { [self] input in
            if let stillImage = input.stillImage {
                withLock {
                    detectorViewIdentity = ObjectIdentifier(stillImage)
                }
            }
            return nextObservations()
        }
    }

    package func makeMappingObserver() -> VisionFaceDetector.MappingObserver {
        { [self] event in
            withLock {
                switch event {
                case .requestStarted:
                    activeMappingInvocationCountValue = 0
                    activeMappedPointCountValue = 0
                    lastMappingInvocationCountValue = 0
                    lastMappedPointCountValue = 0
                case .lipRegionMapped(_, let pointCount):
                    activeMappingInvocationCountValue += 1
                    activeMappedPointCountValue += pointCount
                case .requestFinished:
                    lastMappingInvocationCountValue = activeMappingInvocationCountValue
                    lastMappedPointCountValue = activeMappedPointCountValue
                    activeMappingInvocationCountValue = 0
                    activeMappedPointCountValue = 0
                }
            }
        }
    }

    private func nextObservations() -> [VisionDetectionObservation] {
        let fixture: Fixture = withLock {
            let index = min(fixtureIndex, fixtures.count - 1)
            fixtureIndex += 1
            let fixture = fixtures[index]
            switch fixture {
            case .available(let valueID),
                 .availableMissingUnrelatedGeometry(let valueID, _):
                currentAggregateSupportValueID = valueID
                currentRequestIsMalformed = false
            case .malformed:
                currentAggregateSupportValueID = nil
                currentRequestIsMalformed = true
            case .noFace, .missingSupport:
                currentAggregateSupportValueID = nil
                currentRequestIsMalformed = false
            }
            return fixture
        }

        switch fixture {
        case .noFace:
            return []
        case .missingSupport:
            return [Self.observation(observedLipSupport: nil)]
        case .available:
            return [Self.observation(observedLipSupport: Self.validLipSupport)]
        case .availableMissingUnrelatedGeometry(_, let omissionIndex):
            return [Self.observation(
                observedLipSupport: Self.validLipSupport,
                landmarks: Self.landmarksOmittingUnrelatedGeometry(at: omissionIndex)
            )]
        case .malformed:
            return [Self.observation(observedLipSupport: Self.malformedLipSupport)]
        }
    }

    private static func observation(
        observedLipSupport: BeautyObservedLipSupport?,
        landmarks: BeautyFaceLandmarks = .complete
    ) -> VisionDetectionObservation {
        VisionDetectionObservation(
            stableID: "phase-53-opaque-fixture",
            confidence: 0.96,
            normalizedArea: 0.24,
            visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
            landmarks: landmarks,
            observedLipSupport: observedLipSupport
        )
    }

    private static func landmarksOmittingUnrelatedGeometry(
        at index: Int
    ) -> BeautyFaceLandmarks {
        let unrelatedGroups: [BeautyLandmarkGroup] = [
            .faceContour,
            .leftEye,
            .rightEye,
            .nose,
        ]
        guard unrelatedGroups.indices.contains(index) else {
            return .complete
        }
        return BeautyFaceLandmarks(
            availableGroups: Set(BeautyLandmarkGroup.allCases)
                .subtracting([unrelatedGroups[index]])
        )
    }

    private static let validLipSupport = BeautyObservedLipSupport(
        outer: [
            CoordinatePoint(x: 0.20, y: 0.50),
            CoordinatePoint(x: 0.50, y: 0.20),
            CoordinatePoint(x: 0.80, y: 0.50),
            CoordinatePoint(x: 0.50, y: 0.80),
        ],
        inner: [
            CoordinatePoint(x: 0.35, y: 0.50),
            CoordinatePoint(x: 0.50, y: 0.38),
            CoordinatePoint(x: 0.65, y: 0.50),
        ]
    )

    private static let malformedLipSupport = BeautyObservedLipSupport(
        outer: [CoordinatePoint(x: -1, y: 0.5)],
        inner: [CoordinatePoint(x: 2, y: 0.5)]
    )

    @discardableResult
    private func withLock<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}

@_spi(Testing) public final class SDKTestingLocalRetouchFoundationHarness: @unchecked Sendable {
    private let invocationLock = NSLock()
    private let hooks: BeautyLocalRetouchTestingHooks
    private let engine: BeautyEngine
    private var pixelBufferSummaryAvailabilityValue = "notRun"

    public static var productionAdmissionCount: Int {
        BeautyEffectResolver.localRetouchAdmission(parameters: .init()).isEmpty ? 0 : 1
    }

    public static let productionAdmissionNames: [String] = []
    public static let unrelatedGeometryOmissionFixtureCount = 4

    public var canonicalizeCount: Int { withInvocationLock { hooks.canonicalizeCount } }
    public var detectAndMapCount: Int { withInvocationLock { hooks.detectAndMapCount } }
    public var requestOwnerCreationCount: Int {
        withInvocationLock { hooks.makeRequestContextCount }
    }
    public var renderCount: Int { withInvocationLock { hooks.renderCount } }
    public var localProviderCount: Int { 0 }
    public var retainedRequestOwnerCount: Int {
        withInvocationLock { hooks.activeRequestContextCount }
    }
    public var events: [SDKTestingLocalRetouchEvent] { withInvocationLock { hooks.events } }
    public var pixelBufferSummaryAvailability: String {
        withInvocationLock { pixelBufferSummaryAvailabilityValue }
    }
    public var canonicalConsumerIdentityMatched: Bool {
        withInvocationLock { hooks.canonicalConsumerIdentityMatched }
    }
    public var usedExplicitSRGBRender: Bool {
        withInvocationLock { hooks.usedExplicitSRGBRender }
    }
    public var canonicalizerConstructionCount: Int {
        withInvocationLock { hooks.canonicalizerConstructionCount }
    }
    public var lastMappingInvocationCount: Int {
        withInvocationLock { hooks.lastMappingInvocationCount }
    }
    public var lastMappedCoordinateCount: Int {
        withInvocationLock { hooks.lastMappedPointCount }
    }
    public var retainedMappedCoordinateCount: Int {
        withInvocationLock { hooks.retainedMappedPointCount }
    }
    public var reusedNormalizationOwnerAcrossRequests: Bool {
        withInvocationLock { hooks.reusedCanonicalizerAndContextAcrossRequests }
    }
    public var compositionObservation: SDKTestingLocalCompositionObservation {
        withInvocationLock { hooks.compositionObservation }
    }

    public convenience init(
        admittedPrivateDemandCount: Int,
        compositionScenario: SDKTestingLocalCompositionScenario? = nil
    ) throws {
        try self.init(
            admittedPrivateDemandCount: admittedPrivateDemandCount,
            fixtures: [.available(valueID: 1)],
            compositionScenarios: [compositionScenario]
        )
    }

    public convenience init(
        admittedPrivateDemandCount: Int,
        supportFixture: SDKTestingLocalSupportFixture,
        compositionScenario: SDKTestingLocalCompositionScenario? = nil
    ) throws {
        let fixture: BeautyLocalRetouchTestingHooks.Fixture = switch supportFixture {
        case .noFace: .noFace
        case .missingSupport: .missingSupport
        }
        try self.init(
            admittedPrivateDemandCount: admittedPrivateDemandCount,
            fixtures: [fixture],
            compositionScenarios: [compositionScenario]
        )
    }

    public convenience init(
        admittedPrivateDemandCount: Int,
        supportSequence: [SDKTestingLocalSupportSequence],
        compositionScenarios: [SDKTestingLocalCompositionScenario?] = [nil]
    ) throws {
        let fixtures = supportSequence.map { fixture in
            switch fixture {
            case .available(let valueID):
                BeautyLocalRetouchTestingHooks.Fixture.available(valueID: valueID)
            case .malformed:
                BeautyLocalRetouchTestingHooks.Fixture.malformed
            }
        }
        try self.init(
            admittedPrivateDemandCount: admittedPrivateDemandCount,
            fixtures: fixtures,
            compositionScenarios: compositionScenarios
        )
    }

    public convenience init(
        admittedPrivateDemandCount: Int,
        unrelatedGeometryOmissionIndex: Int
    ) throws {
        try self.init(
            admittedPrivateDemandCount: admittedPrivateDemandCount,
            fixtures: [
                .availableMissingUnrelatedGeometry(
                    valueID: unrelatedGeometryOmissionIndex + 1,
                    omissionIndex: unrelatedGeometryOmissionIndex
                ),
            ],
            compositionScenarios: [nil]
        )
    }

    private init(
        admittedPrivateDemandCount: Int,
        fixtures: [BeautyLocalRetouchTestingHooks.Fixture],
        compositionScenarios: [SDKTestingLocalCompositionScenario?]
    ) throws {
        let hooks = BeautyLocalRetouchTestingHooks(
            admittedPrivateDemandCount: admittedPrivateDemandCount,
            fixtures: fixtures,
            compositionScenarios: compositionScenarios
        )
        self.hooks = hooks
        self.engine = try BeautyEngine(
            configuration: .default,
            faceDetector: VisionFaceDetector(
                observationProvider: hooks.makeObservationProvider(),
                mappingObserver: hooks.makeMappingObserver()
            ),
            localRetouchTestingHooks: hooks
        )
    }

    public func invoke(
        entry: SDKTestingStillImageFacadeEntry,
        image: CIImage,
        parameters: BeautyParameters
    ) throws -> SDKTestingLocalResult {
        invocationLock.lock()
        defer { invocationLock.unlock() }

        let output: CIImage
        let detectionSummary: BeautyDetectionSummary?
        switch entry {
        case .process:
            output = try engine.process(image: image, orientation: .up, parameters: parameters)
            detectionSummary = nil
        case .processResult:
            let result = try engine.processResult(
                image: image,
                metadata: BeautyInputMetadata(
                    orientation: .up,
                    isInputMirrored: false,
                    isPreviewMirrored: false,
                    source: .photo
                ),
                parameters: parameters
            )
            output = result.output
            detectionSummary = result.detectionSummary
        }
        return SDKTestingLocalResult(
            output: output,
            width: Int(output.extent.width),
            height: Int(output.extent.height),
            aggregateSupportValueID: hooks.lastAggregateSupportValueID,
            detectionAvailability: detectionSummary?.availability.rawValue,
            detectionReasons: detectionSummary?.reasons.map(\.rawValue) ?? []
        )
    }

    public func invokePixelBuffer(parameters: BeautyParameters) throws {
        invocationLock.lock()
        defer { invocationLock.unlock() }

        let pixelBuffer = try Self.makePixelBuffer()
        let result = try engine.processResult(
            pixelBuffer: pixelBuffer,
            metadata: BeautyInputMetadata(
                orientation: .up,
                isInputMirrored: false,
                isPreviewMirrored: false,
                source: .camera
            ),
            parameters: parameters
        )
        pixelBufferSummaryAvailabilityValue =
            result.detectionSummary?.availability.rawValue ?? "notRun"
    }

    public func reset() {
        withInvocationLock { engine.reset() }
    }

    public static func runIndependent(valueID: Int) async throws -> Int {
        let harness = try SDKTestingLocalRetouchFoundationHarness(
            admittedPrivateDemandCount: 1,
            supportSequence: [.available(valueID: valueID)]
        )
        let image = try makeOpaqueSRGBImage()
        let result = try harness.invoke(entry: .processResult, image: image, parameters: .init())
        guard let aggregateSupportValueID = result.aggregateSupportValueID else {
            throw BeautyError.invalidInput
        }
        return aggregateSupportValueID
    }

    @discardableResult
    private func withInvocationLock<T>(_ body: () throws -> T) rethrows -> T {
        invocationLock.lock()
        defer { invocationLock.unlock() }
        return try body()
    }

    private static func makeOpaqueSRGBImage() throws -> CIImage {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.unsupportedPixelFormat
        }
        return CIImage(
            bitmapData: Data([
                51, 102, 153, 255, 51, 102, 153, 255,
                51, 102, 153, 255, 51, 102, 153, 255,
            ]),
            bytesPerRow: 8,
            size: CGSize(width: 2, height: 2),
            format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    private static func makePixelBuffer() throws -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            2,
            2,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.invalidInput
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw BeautyError.invalidInput
        }
        memset(baseAddress, 255, CVPixelBufferGetDataSize(pixelBuffer))
        return pixelBuffer
    }
}
