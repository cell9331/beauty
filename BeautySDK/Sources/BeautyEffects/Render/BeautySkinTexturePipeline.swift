import CoreGraphics
import CoreImage
import BeautyCore
import BeautyDetection

/// The current texture implementation owns up to three RGBA8 rasters on the
/// still-image path. Keep their aggregate byte count at or below 96 MiB.
package enum BeautyTextureResourceBudget {
    package static let maximumPixelCount = 8_388_608

    package static func admits(
        parameters: BeautyParameters, width: Int, height: Int
    ) -> Bool {
        let normalized = parameters.normalized()
        guard normalized.skinSmoothing > 0 || normalized.skinSharpen > 0 else {
            return true
        }
        guard width > 0, height > 0,
              width <= maximumPixelCount / height
        else { return false }
        return width * height <= maximumPixelCount
    }
}

/// One request-local spatial transform shared by CPU and Metal-selected paths.
/// The immutable source owns every neighborhood sample; only luminance detail
/// moves, so the operation cannot act as a saturation or global contrast proxy.
enum BeautySkinTexturePipeline {
    static func isActive(_ plan: BeautyEffectPlan) -> Bool {
        let strengths = plan.effectiveStrengths
        return strengths.skinSmoothing > 0 || strengths.skinSharpen > 0
    }

    static func admits(faceBounds: CoordinateRect?) -> Bool {
        guard let faceBounds else { return false }
        return faceBounds.isFinite && faceBounds.width > 0 && faceBounds.height > 0
            && faceBounds.minX >= 0 && faceBounds.minY >= 0
            && faceBounds.maxX <= 1 && faceBounds.maxY <= 1
    }

    static func apply(
        to image: CIImage, plan: BeautyEffectPlan,
        renderQuality: BeautyRenderQuality = .balanced,
        faceBounds: CoordinateRect? = nil
    ) -> CIImage {
        guard isActive(plan), admits(faceBounds: faceBounds) else { return image }
        let extent = image.extent
        guard let dimensions = BeautyBackendRequest.checkedDimensions(for: extent),
              dimensions.width >= 3, dimensions.height >= 3 else { return image }
        let width = dimensions.width
        let height = dimensions.height
        let pixelCount = width.multipliedReportingOverflow(by: height)
        guard !pixelCount.overflow,
              pixelCount.partialValue <= BeautyTextureResourceBudget.maximumPixelCount
        else { return image }
        let colorSpace = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace
        ])
        var source = [UInt8](repeating: 0, count: width * height * 4)
        context.render(
            image, toBitmap: &source, rowBytes: width * 4, bounds: extent,
            format: .RGBA8, colorSpace: colorSpace
        )
        let result = applyRGBA(
            source, width: width, height: height, plan: plan,
            renderQuality: renderQuality, faceBounds: faceBounds
        )
        let output = CIImage(
            bitmapData: Data(result), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8,
            colorSpace: colorSpace
        )
        return extent.origin == .zero ? output : output.transformed(
            by: CGAffineTransform(translationX: extent.minX, y: extent.minY)
        )
    }

    static func applyRGBA(
        _ source: [UInt8], width: Int, height: Int, plan: BeautyEffectPlan,
        renderQuality: BeautyRenderQuality = .balanced,
        faceBounds: CoordinateRect? = nil
    ) -> [UInt8] {
        let weights: [Int]
        switch renderQuality {
        case .performance: weights = [1, 2, 1]
        case .balanced: weights = [1, 2, 3, 2, 1]
        case .quality: weights = [1, 2, 3, 4, 3, 2, 1]
        }
        let radius = weights.count / 2
        guard isActive(plan), width >= weights.count, height >= weights.count,
              admits(faceBounds: faceBounds), let faceBounds
        else { return source }
        let pixelCount = width.multipliedReportingOverflow(by: height)
        guard !pixelCount.overflow,
              pixelCount.partialValue <= BeautyTextureResourceBudget.maximumPixelCount
        else { return source }
        let byteCount = pixelCount.partialValue.multipliedReportingOverflow(by: 4)
        guard !byteCount.overflow, source.count == byteCount.partialValue else { return source }
        let strengths = plan.effectiveStrengths
        let gain = Double(strengths.skinSharpen) * 2.5 -
            Double(strengths.skinSmoothing) * 1.5
        guard gain != 0 else { return source }
        let divisor = Double(weights.reduce(0, +) * weights.reduce(0, +))
        let centerX = (faceBounds.minX + faceBounds.width / 2) * Double(width) - 0.5
        let centerY = (faceBounds.minY + faceBounds.height / 2) * Double(height) - 0.5
        let radiusX = faceBounds.width * 0.43 * Double(width)
        let radiusY = faceBounds.height * 0.43 * Double(height)
        // Keep the coarse eye/lid and lip zones source-exact even when their
        // local color and edge texture would otherwise pass the skin guard.
        // The bounds are intentionally broad; they are not a feature mask.
        let eyeMinimumX = (faceBounds.minX + faceBounds.width * 0.13) * Double(width) - 0.5
        let eyeMaximumX = (faceBounds.minX + faceBounds.width * 0.87) * Double(width) - 0.5
        let eyeMinimumY = (faceBounds.minY + faceBounds.height * 0.21) * Double(height) - 0.5
        let eyeMaximumY = (faceBounds.minY + faceBounds.height * 0.44) * Double(height) - 0.5
        let mouthMinimumX = (faceBounds.minX + faceBounds.width * 0.18) * Double(width) - 0.5
        let mouthMaximumX = (faceBounds.minX + faceBounds.width * 0.82) * Double(width) - 0.5
        let mouthMinimumY = (faceBounds.minY + faceBounds.height * 0.66) * Double(height) - 0.5
        let mouthMaximumY = (faceBounds.minY + faceBounds.height * 0.90) * Double(height) - 0.5
        var result = source
        for y in radius..<(height - radius) {
            let localY = (Double(y) - centerY) / radiusY
            guard abs(localY) <= 1 else { continue }
            let halfRowWidth = radiusX * sqrt(max(0, 1 - localY * localY))
            let minimumColumn = max(radius, Int(ceil(centerX - halfRowWidth)))
            let maximumColumn = min(width - radius - 1, Int(floor(centerX + halfRowWidth)))
            guard minimumColumn <= maximumColumn else { continue }
            for x in minimumColumn...maximumColumn {
                let inEyeZone = Double(y) >= eyeMinimumY && Double(y) <= eyeMaximumY &&
                    Double(x) >= eyeMinimumX && Double(x) <= eyeMaximumX
                let inMouthZone = Double(y) >= mouthMinimumY && Double(y) <= mouthMaximumY &&
                    Double(x) >= mouthMinimumX && Double(x) <= mouthMaximumX
                guard !inEyeZone, !inMouthZone else { continue }
                let offset = (y * width + x) * 4
                guard source[offset + 3] == 255 else { continue }
                let red = Int(source[offset])
                let green = Int(source[offset + 1])
                let blue = Int(source[offset + 2])
                // Cool, low-contrast regions can satisfy the local edge gate
                // while being unrelated to skin. Keep them source-exact. This
                // is a narrow color guard, not anatomical segmentation.
                guard red + 8 >= green, red + 8 >= blue else { continue }
                var weightedLuminance = 0
                var protectedEdge = false
                for dy in -radius...radius {
                    for dx in -radius...radius {
                        let nearby = ((y + dy) * width + x + dx) * 4
                        let neighborRed = Int(source[nearby])
                        let neighborGreen = Int(source[nearby + 1])
                        let neighborBlue = Int(source[nearby + 2])
                        if source[nearby + 3] != 255 ||
                            abs(neighborRed - red) > 36 ||
                            abs(neighborGreen - green) > 36 ||
                            abs(neighborBlue - blue) > 36 {
                            protectedEdge = true
                            break
                        }
                        let weight = weights[dy + radius] * weights[dx + radius]
                        let luminance = (77 * neighborRed + 150 * neighborGreen +
                            29 * neighborBlue + 128) / 256
                        weightedLuminance += weight * luminance
                    }
                    if protectedEdge { break }
                }
                guard !protectedEdge else { continue }
                let centerLuminance = (77 * red + 150 * green + 29 * blue + 128) / 256
                let localMean = Double(weightedLuminance) / divisor
                let detail = Double(centerLuminance) - localMean
                let delta = max(-16.0, min(16.0, detail * gain))
                guard abs(delta) >= 0.5 else { continue }
                let rounded = Int(delta.rounded())
                result[offset] = UInt8(max(0, min(255, red + rounded)))
                result[offset + 1] = UInt8(max(0, min(255, green + rounded)))
                result[offset + 2] = UInt8(max(0, min(255, blue + rounded)))
            }
        }
        return result
    }
}
