import CoreGraphics
import CoreImage
import Foundation
import ImageIO
@testable import BeautyCore

enum BeautyReviewedMaskValidation {
    static func validate(_ image: CIImage, width: Int, height: Int) throws {
        try validate(
            extent: image.extent,
            orientationProperty: image.properties[kCGImagePropertyOrientation as String],
            width: width,
            height: height
        )
    }

    static func validate(
        extent: CGRect,
        orientationProperty: Any?,
        width: Int,
        height: Int
    ) throws {
        guard width > 0,
              height > 0,
              extent.origin.x.isFinite,
              extent.origin.y.isFinite,
              extent.width.isFinite,
              extent.height.isFinite,
              extent.origin == .zero,
              extent.width == CGFloat(width),
              extent.height == CGFloat(height)
        else {
            throw BeautyError.invalidInput
        }

        // Reviewed masks are consumed in canonical up orientation. Missing
        // orientation metadata means up; any explicit value must be EXIF 1.
        if let orientationProperty {
            guard let number = orientationProperty as? NSNumber,
                  number.intValue == CGImagePropertyOrientation.up.rawValue
            else {
                throw BeautyError.invalidInput
            }
        }
    }
}
