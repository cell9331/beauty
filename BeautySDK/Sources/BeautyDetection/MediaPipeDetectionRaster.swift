import BeautyCore
import CoreGraphics
import CoreImage
import Foundation

enum MediaPipeDetectionRaster {
    /// Use the same EXIF + explicit input-mirror order as the rendering carrier.
    /// MPImage receives already upright pixels and no mirrored orientation.
    static func make(_ input: VisionFaceDetectionInput) throws -> CGImage {
        guard let source = input.stillImage,
              source.extent.origin.x.isFinite, source.extent.origin.y.isFinite,
              source.extent.width.isFinite, source.extent.height.isFinite,
              source.extent.width > 0, source.extent.height > 0,
              source.extent == source.extent.integral,
              source.extent.size == input.imageExtent, input.maximumPixelCount > 0,
              source.extent.width <= CGFloat(input.maximumPixelCount) / source.extent.height,
              let sRGB = CGColorSpace(name: CGColorSpace.sRGB)
        else { throw BeautyFaceDetector.Failure.detectorUnavailable }
        var image = source.oriented(forExifOrientation: Int32(input.metadata.orientation.rawValue))
        if input.metadata.isInputMirrored {
            image = image.transformed(by: CGAffineTransform(a: -1, b: 0, c: 0, d: 1,
                tx: image.extent.minX + image.extent.maxX, ty: 0))
        }
        let extent = image.extent.integral
        image = image.transformed(by: CGAffineTransform(translationX: -extent.minX, y: -extent.minY))
        var scale: CGFloat = 1
        if let preferred = input.preferredProcessingSize {
            guard preferred.width.isFinite, preferred.height.isFinite,
                  preferred.width > 0, preferred.height > 0 else {
                throw BeautyFaceDetector.Failure.detectorUnavailable
            }
            scale = min(1, preferred.width / extent.width, preferred.height / extent.height)
        }
        let width = max(1, Int((extent.width * scale).rounded(.down)))
        let height = max(1, Int((extent.height * scale).rounded(.down)))
        image = image.transformed(by: CGAffineTransform(scaleX: CGFloat(width) / extent.width, y: CGFloat(height) / extent.height))
        let context = BeautyImageContexts.context(for: sRGB)
        guard let raster = context.createCGImage(image, from: CGRect(x: 0, y: 0, width: width, height: height),
                                                 format: .RGBA8, colorSpace: sRGB) else {
            throw BeautyFaceDetector.Failure.detectorUnavailable
        }
        return raster
    }
}
