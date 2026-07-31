import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import BeautyCore

/// Package-internal owner of the admitted still-image validation and one-render boundary.
package final class BeautyStillImageCanonicalizer: @unchecked Sendable {
    package enum InputColorSemantics {
        case image
        case missing
        case colorSpace(CGColorSpace)
    }

    private let context: CIContext?
    private let sRGB: CGColorSpace?

    package init() {
        let sRGB = CGColorSpace(name: CGColorSpace.sRGB)
        self.sRGB = sRGB
        self.context = sRGB.map { colorSpace in
            CIContext(options: [
                .workingColorSpace: colorSpace,
                .outputColorSpace: colorSpace,
            ])
        }
    }

    package func canonicalize(
        image: CIImage,
        metadata: BeautyInputMetadata,
        maximumPixelCount: Int
    ) throws -> BeautyCanonicalStillImage {
        try canonicalize(
            image: image,
            rawExifOrientation: Int(metadata.orientation.rawValue),
            isInputMirrored: metadata.isInputMirrored,
            isPreviewMirrored: metadata.isPreviewMirrored,
            source: metadata.source,
            timestamp: metadata.timestamp,
            maximumPixelCount: maximumPixelCount
        )
    }

    package func canonicalize(
        image: CIImage,
        rawExifOrientation: Int,
        isInputMirrored: Bool,
        isPreviewMirrored: Bool,
        source: BeautyInputSource,
        timestamp: TimeInterval?,
        maximumPixelCount: Int,
        inputColorSemantics: InputColorSemantics = .image,
        extentOverride: CGRect? = nil
    ) throws -> BeautyCanonicalStillImage {
        guard let context,
              let sRGB
        else {
            throw BeautyError.unsupportedPixelFormat
        }
        let inputExtent = extentOverride ?? image.extent
        try validateDecodedExtent(inputExtent, maximumPixelCount: maximumPixelCount)

        guard (1...8).contains(rawExifOrientation),
              let orientation = CGImagePropertyOrientation(rawValue: UInt32(rawExifOrientation))
        else {
            throw BeautyError.invalidInput
        }

        let inputColorSpace: CGColorSpace?
        switch inputColorSemantics {
        case .image:
            inputColorSpace = image.colorSpace
        case .missing:
            inputColorSpace = nil
        case .colorSpace(let colorSpace):
            inputColorSpace = colorSpace
        }
        guard let inputColorSpace,
              inputColorSpace.model == .rgb,
              inputColorSpace.supportsOutput,
              CGColorSpaceUsesExtendedRange(inputColorSpace) == false
        else {
            throw BeautyError.unsupportedPixelFormat
        }

        var normalized = image.oriented(forExifOrientation: Int32(orientation.rawValue))
        if isInputMirrored {
            let extent = normalized.extent
            normalized = normalized.transformed(by: CGAffineTransform(
                a: -1,
                b: 0,
                c: 0,
                d: 1,
                tx: extent.minX + extent.maxX,
                ty: 0
            ))
        }

        let orientedBounds = normalized.extent.integral
        try validateIntegralBounds(orientedBounds, maximumPixelCount: maximumPixelCount)
        guard orientedBounds.width <= CGFloat(Int.max),
              orientedBounds.height <= CGFloat(Int.max)
        else {
            throw BeautyError.invalidInput
        }

        let width = Int(orientedBounds.width)
        let height = Int(orientedBounds.height)
        let rowBytes = try checkedMultiply(width, 4)
        let totalByteCount = try checkedMultiply(rowBytes, height)
        var rgba8Data = Data(count: totalByteCount)

        let zeroOriginImage = normalized.transformed(by: CGAffineTransform(
            translationX: -orientedBounds.minX,
            y: -orientedBounds.minY
        ))
        let zeroOriginBounds = CGRect(x: 0, y: 0, width: width, height: height)
        try validateExactOpacity(
            zeroOriginImage,
            bounds: zeroOriginBounds,
            context: context,
            colorSpace: sRGB
        )
        rgba8Data.withUnsafeMutableBytes { storage in
            guard let baseAddress = storage.baseAddress else {
                return
            }
            context.render(
                zeroOriginImage,
                toBitmap: baseAddress,
                rowBytes: rowBytes,
                bounds: zeroOriginBounds,
                format: .RGBA8,
                colorSpace: sRGB
            )
        }

        let normalizedMetadata = BeautyInputMetadata(
            orientation: .up,
            isInputMirrored: false,
            isPreviewMirrored: isPreviewMirrored,
            source: source,
            timestamp: timestamp
        )
        return try BeautyCanonicalStillImage(
            rgba8Data: rgba8Data,
            width: width,
            height: height,
            rowBytes: rowBytes,
            metadata: normalizedMetadata
        )
    }

    private func validateExactOpacity(
        _ image: CIImage,
        bounds: CGRect,
        context: CIContext,
        colorSpace: CGColorSpace
    ) throws {
        let minimumAlphaImage = image.applyingFilter(
            "CIAreaMinimumAlpha",
            parameters: [kCIInputExtentKey: CIVector(cgRect: bounds)]
        )
        let reductionBounds = minimumAlphaImage.extent.integral
        guard reductionBounds.width == 1,
              reductionBounds.height == 1
        else {
            throw BeautyError.invalidInput
        }

        var minimumAlphaPixel = [Float](repeating: 0, count: 4)
        minimumAlphaPixel.withUnsafeMutableBytes { storage in
            guard let baseAddress = storage.baseAddress else {
                return
            }
            context.render(
                minimumAlphaImage,
                toBitmap: baseAddress,
                rowBytes: MemoryLayout<Float>.stride * 4,
                bounds: reductionBounds,
                format: .RGBAf,
                colorSpace: colorSpace
            )
        }
        guard minimumAlphaPixel[3] == 1 else {
            throw BeautyError.invalidInput
        }
    }

    private func validateDecodedExtent(_ extent: CGRect, maximumPixelCount: Int) throws {
        guard extent.origin.x.isFinite,
              extent.origin.y.isFinite,
              extent.width.isFinite,
              extent.height.isFinite,
              extent.width > 0,
              extent.height > 0,
              extent.width.rounded(.towardZero) == extent.width,
              extent.height.rounded(.towardZero) == extent.height,
              maximumPixelCount > 0,
              extent.width <= CGFloat(maximumPixelCount) / extent.height
        else {
            throw BeautyError.invalidInput
        }
    }

    private func validateIntegralBounds(_ bounds: CGRect, maximumPixelCount: Int) throws {
        guard bounds.origin.x.isFinite,
              bounds.origin.y.isFinite,
              bounds.width.isFinite,
              bounds.height.isFinite,
              bounds.width > 0,
              bounds.height > 0,
              bounds.width.rounded(.towardZero) == bounds.width,
              bounds.height.rounded(.towardZero) == bounds.height,
              maximumPixelCount > 0,
              bounds.width <= CGFloat(maximumPixelCount) / bounds.height
        else {
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
}
