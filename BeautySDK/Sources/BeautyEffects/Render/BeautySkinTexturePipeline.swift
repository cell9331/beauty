import CoreGraphics
import CoreImage
import BeautyCore

/// One request-local spatial transform shared by CPU and Metal-selected paths.
/// The immutable source owns every neighborhood sample; only luminance detail
/// moves, so the operation cannot act as a saturation or global contrast proxy.
enum BeautySkinTexturePipeline {
    static func isActive(_ plan: BeautyEffectPlan) -> Bool {
        let strengths = plan.effectiveStrengths
        return strengths.skinSmoothing > 0 || strengths.skinSharpen > 0
    }

    static func apply(to image: CIImage, plan: BeautyEffectPlan) -> CIImage {
        guard isActive(plan) else { return image }
        let extent = image.extent
        guard let dimensions = BeautyBackendRequest.checkedDimensions(for: extent),
              dimensions.width >= 5, dimensions.height >= 5 else { return image }
        let width = dimensions.width
        let height = dimensions.height
        let pixelCount = width.multipliedReportingOverflow(by: height)
        guard !pixelCount.overflow,
              pixelCount.partialValue <= BeautyConfiguration.defaultMaximumInputPixelCount
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
        let result = applyRGBA(source, width: width, height: height, plan: plan)
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
        _ source: [UInt8], width: Int, height: Int, plan: BeautyEffectPlan
    ) -> [UInt8] {
        guard isActive(plan), width >= 5, height >= 5 else { return source }
        let pixelCount = width.multipliedReportingOverflow(by: height)
        guard !pixelCount.overflow else { return source }
        let byteCount = pixelCount.partialValue.multipliedReportingOverflow(by: 4)
        guard !byteCount.overflow, source.count == byteCount.partialValue else { return source }
        let strengths = plan.effectiveStrengths
        let gain = Double(strengths.skinSharpen) * 2.5 -
            Double(strengths.skinSmoothing) * 1.5
        guard gain != 0 else { return source }
        let weights = [1, 2, 3, 2, 1]
        var result = source
        for y in 2..<(height - 2) {
            for x in 2..<(width - 2) {
                let offset = (y * width + x) * 4
                guard source[offset + 3] == 255 else { continue }
                let red = Int(source[offset])
                let green = Int(source[offset + 1])
                let blue = Int(source[offset + 2])
                var weightedLuminance = 0
                var protectedEdge = false
                for dy in -2...2 {
                    for dx in -2...2 {
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
                        let weight = weights[dy + 2] * weights[dx + 2]
                        let luminance = (77 * neighborRed + 150 * neighborGreen +
                            29 * neighborBlue + 128) / 256
                        weightedLuminance += weight * luminance
                    }
                    if protectedEdge { break }
                }
                guard !protectedEdge else { continue }
                let centerLuminance = (77 * red + 150 * green + 29 * blue + 128) / 256
                let localMean = Double(weightedLuminance) / 81.0
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
