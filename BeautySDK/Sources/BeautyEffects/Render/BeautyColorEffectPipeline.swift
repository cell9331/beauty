import CoreGraphics
import CoreImage
import CoreVideo
import BeautyCore
import BeautyDetection

public enum BeautyColorEffectPipeline {
    public static func apply(to pixelBuffer: CVPixelBuffer, plan: BeautyEffectPlan) throws -> CVPixelBuffer {
        try apply(to: pixelBuffer, plan: plan, face: nil)
    }

    static func apply(to pixelBuffer: CVPixelBuffer, plan: BeautyEffectPlan, face: FaceGeometry?) throws -> CVPixelBuffer {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)

        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]

        var output: CVPixelBuffer?
        let createStatus = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            pixelFormat,
            attributes as CFDictionary,
            &output
        )

        guard createStatus == kCVReturnSuccess, let output else {
            throw BeautyError.pixelBufferCreationFailed
        }

        guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {
            throw BeautyError.invalidInput
        }
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }

        guard CVPixelBufferLockBaseAddress(output, []) == kCVReturnSuccess else {
            throw BeautyError.pixelBufferCreationFailed
        }
        defer {
            CVPixelBufferUnlockBaseAddress(output, [])
        }

        guard let sourceBase = CVPixelBufferGetBaseAddress(pixelBuffer),
              let outputBase = CVPixelBufferGetBaseAddress(output)
        else {
            throw BeautyError.invalidInput
        }

        let sourceBytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let outputBytesPerRow = CVPixelBufferGetBytesPerRow(output)
        let bytesPerPixel = 4

        for row in 0..<height {
            let sourceRow = sourceBase.advanced(by: row * sourceBytesPerRow).assumingMemoryBound(to: UInt8.self)
            let outputRow = outputBase.advanced(by: row * outputBytesPerRow).assumingMemoryBound(to: UInt8.self)
            for column in 0..<width {
                let offset = column * bytesPerPixel
                let pixel = transform(
                    blue: sourceRow[offset],
                    green: sourceRow[offset + 1],
                    red: sourceRow[offset + 2],
                    alpha: sourceRow[offset + 3],
                    plan: plan
                )
                let normalizedPoint = SIMD2<Float>(
                    (Float(column) + 0.5) / Float(width),
                    (Float(row) + 0.5) / Float(height)
                )
                let lipPixel = lipTransform(
                    blue: pixel.blue,
                    green: pixel.green,
                    red: pixel.red,
                    plan: plan,
                    face: face,
                    normalizedPoint: normalizedPoint
                )
                outputRow[offset] = lipPixel.blue
                outputRow[offset + 1] = lipPixel.green
                outputRow[offset + 2] = lipPixel.red
                outputRow[offset + 3] = pixel.alpha
            }
        }

        return output
    }

    public static func apply(to image: CIImage, plan: BeautyEffectPlan) -> CIImage {
        apply(to: image, plan: plan, face: nil)
    }

    package static func apply(
        to image: CIImage,
        plan: BeautyEffectPlan,
        selectedFaceObservation: BeautyFaceObservation?
    ) -> CIImage {
        let face = selectedFaceObservation.map(BeautyFaceGeometryAdapter.makeGeometry(from:))
        return apply(to: image, plan: plan, face: face)
    }

    package static func apply(
        to canonicalImage: BeautyCanonicalStillImage,
        plan: BeautyEffectPlan,
        selectedFaceObservation: BeautyFaceObservation?,
        onCanonicalRasterize: ((BeautyCanonicalStillImage, CGColorSpace) -> Void)? = nil
    ) -> CIImage {
        let face = selectedFaceObservation.map(BeautyFaceGeometryAdapter.makeGeometry(from:))
        var output = applyColorEffects(
            to: canonicalImage.ciImage,
            plan: plan,
            face: face
        )

        if let face {
            output = BeautyGeometryEffectPipeline.applyMVPProxy(
                to: output,
                canonicalImage: canonicalImage,
                plan: plan,
                face: face,
                onRasterize: onCanonicalRasterize
            )
        }

        return output.cropped(to: canonicalImage.ciImage.extent)
    }

    static func apply(to image: CIImage, plan: BeautyEffectPlan, face: FaceGeometry?) -> CIImage {
        var output = applyColorEffects(to: image, plan: plan, face: face)

        if let face {
            output = BeautyGeometryEffectPipeline.applyMVPProxy(to: output, plan: plan, face: face)
        }

        return output.cropped(to: image.extent)
    }

    private static func applyColorEffects(
        to image: CIImage,
        plan: BeautyEffectPlan,
        face: FaceGeometry?
    ) -> CIImage {
        var output = image

        if plan.hasVisibleColorOutput {
            let strengths = plan.effectiveStrengths
            let filter = filterContribution(for: plan)
            let brightness = CGFloat(
                strengths.brightness * 0.14 +
                    strengths.exposure * 0.10 +
                    strengths.skinWhitening * 0.16 +
                    filter.brightness
            )
            let contrast = CGFloat(1 + strengths.contrast * 0.20 + strengths.skinSharpen * 0.18)
            let saturation = CGFloat(max(0, 1 + strengths.saturation * 0.28 - strengths.skinSmoothing * 0.18 + filter.saturation))

            output = output.applyingFilter(
                "CIColorControls",
                parameters: [
                    kCIInputBrightnessKey: brightness,
                    kCIInputContrastKey: contrast,
                    kCIInputSaturationKey: saturation
                ]
            )

            let redBias = CGFloat(strengths.skinRosy * 0.08 + strengths.temperature * 0.04 + strengths.tint * 0.02 + filter.redBias)
            let greenBias = CGFloat(strengths.skinWhitening * 0.02 + strengths.tint * 0.03 + filter.greenBias)
            let blueBias = CGFloat(-strengths.temperature * 0.04 + filter.blueBias)

            output = output.applyingFilter(
                "CIColorMatrix",
                parameters: [
                    "inputRVector": CIVector(x: 1, y: 0, z: 0, w: 0),
                    "inputGVector": CIVector(x: 0, y: 1, z: 0, w: 0),
                    "inputBVector": CIVector(x: 0, y: 0, z: 1, w: 0),
                    "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
                    "inputBiasVector": CIVector(x: redBias, y: greenBias, z: blueBias, w: 0)
                ]
            )

            output = applyLipColor(to: output, plan: plan, face: face)
        }

        return output
    }

    private static func transform(
        blue: UInt8,
        green: UInt8,
        red: UInt8,
        alpha: UInt8,
        plan: BeautyEffectPlan
    ) -> (blue: UInt8, green: UInt8, red: UInt8, alpha: UInt8) {
        guard plan.hasVisibleColorOutput else {
            return (blue, green, red, alpha)
        }

        let strengths = plan.effectiveStrengths
        let filter = filterContribution(for: plan)

        var r = Float(red) / 255
        var g = Float(green) / 255
        var b = Float(blue) / 255
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b

        let saturationScale = max(0, 1 + strengths.saturation * 0.28 + filter.saturation)
        r = luminance + (r - luminance) * saturationScale
        g = luminance + (g - luminance) * saturationScale
        b = luminance + (b - luminance) * saturationScale

        let contrastScale = 1 + strengths.contrast * 0.22 + strengths.skinSharpen * 0.18
        r = (r - 0.5) * contrastScale + 0.5
        g = (g - 0.5) * contrastScale + 0.5
        b = (b - 0.5) * contrastScale + 0.5

        let lightLift = strengths.brightness * 0.16 +
            strengths.exposure * 0.10 +
            strengths.skinWhitening * 0.18 +
            filter.brightness
        r += lightLift
        g += lightLift
        b += lightLift

        r += strengths.skinRosy * 0.08 + strengths.temperature * 0.04 + strengths.tint * 0.02 + filter.redBias
        g += strengths.skinWhitening * 0.02 + strengths.tint * 0.03 + filter.greenBias
        b += -strengths.temperature * 0.04 + filter.blueBias

        if luminance > 0.5 {
            r += strengths.highlight * 0.08
            g += strengths.highlight * 0.08
            b += strengths.highlight * 0.08
        } else {
            r += strengths.shadow * 0.08
            g += strengths.shadow * 0.08
            b += strengths.shadow * 0.08
        }

        let smoothing = strengths.skinSmoothing * 0.16
        if smoothing > 0 {
            let skinLuminance = 0.299 * r + 0.587 * g + 0.114 * b
            r = r * (1 - smoothing) + skinLuminance * smoothing
            g = g * (1 - smoothing) + skinLuminance * smoothing
            b = b * (1 - smoothing) + skinLuminance * smoothing
        }

        return (
            blue: toByte(b),
            green: toByte(g),
            red: toByte(r),
            alpha: alpha
        )
    }

    private static func lipTransform(
        blue: UInt8,
        green: UInt8,
        red: UInt8,
        plan: BeautyEffectPlan,
        face: FaceGeometry?,
        normalizedPoint: SIMD2<Float>
    ) -> (blue: UInt8, green: UInt8, red: UInt8) {
        guard plan.activeDomains.contains(.lipColor),
              plan.effectiveStrengths.lipColor > 0,
              let face,
              lipMaskValue(at: normalizedPoint, face: face) > 0
        else {
            return (blue, green, red)
        }

        let mask = lipMaskValue(at: normalizedPoint, face: face)
        let blend = min(plan.effectiveStrengths.lipColor, BeautySafetyCaps.lipColor) * mask
        var r = Float(red) / 255
        var g = Float(green) / 255
        var b = Float(blue) / 255
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        let enhancedR = min(1, luminance * 0.45 + r * 0.55 + 0.20)
        let enhancedG = max(0, g * 0.94)
        let enhancedB = max(0, b * 0.90)

        r = r * (1 - blend) + enhancedR * blend
        g = g * (1 - blend) + enhancedG * blend
        b = b * (1 - blend) + enhancedB * blend

        return (blue: toByte(b), green: toByte(g), red: toByte(r))
    }

    private static func applyLipColor(to image: CIImage, plan: BeautyEffectPlan, face: FaceGeometry?) -> CIImage {
        guard plan.activeDomains.contains(.lipColor),
              plan.effectiveStrengths.lipColor > 0,
              let face,
              let center = LandmarkGeometryHelper.center(of: face.outerLips)
        else {
            return image
        }

        let extent = image.extent
        let radiusX = CGFloat(max(face.outerLips.map { abs($0.x - center.x) }.max() ?? 0, 0.03)) * extent.width
        let radiusY = CGFloat(max(face.outerLips.map { abs($0.y - center.y) }.max() ?? 0, 0.02)) * extent.height
        let centerX = extent.minX + CGFloat(center.x) * extent.width
        let centerY = extent.minY + CGFloat(1 - center.y) * extent.height
        let rect = CGRect(
            x: centerX - radiusX,
            y: centerY - radiusY,
            width: radiusX * 2,
            height: radiusY * 2
        ).insetBy(dx: -1, dy: -1)

        let strength = CGFloat(min(plan.effectiveStrengths.lipColor, BeautySafetyCaps.lipColor))
        let tinted = image.applyingFilter(
            "CIColorMatrix",
            parameters: [
                "inputRVector": CIVector(x: 1, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 0.94, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 0.90, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
                "inputBiasVector": CIVector(x: strength * 0.18, y: 0, z: 0, w: 0)
            ]
        )
        return tinted.cropped(to: rect).composited(over: image).cropped(to: extent)
    }

    private static func lipMaskValue(at point: SIMD2<Float>, face: FaceGeometry) -> Float {
        guard let center = LandmarkGeometryHelper.center(of: face.outerLips) else {
            return 0
        }
        let radiusX = max(face.outerLips.map { abs($0.x - center.x) }.max() ?? 0, 0.03)
        let radiusY = max(face.outerLips.map { abs($0.y - center.y) }.max() ?? 0, 0.02)
        let dx = (point.x - center.x) / radiusX
        let dy = (point.y - center.y) / radiusY
        let distance = dx * dx + dy * dy
        guard distance <= 1 else {
            return 0
        }
        return max(0, 1 - distance)
    }

    private static func filterContribution(for plan: BeautyEffectPlan) -> FilterContribution {
        guard plan.activeDomains.contains(.filter), plan.effectiveStrengths.filterIntensity > 0 else {
            return FilterContribution()
        }

        let intensity = plan.effectiveStrengths.filterIntensity
        switch plan.filterId {
        case "soft_clean":
            return FilterContribution(
                brightness: intensity * 0.05,
                saturation: -intensity * 0.04,
                redBias: intensity * 0.015,
                greenBias: intensity * 0.018,
                blueBias: intensity * 0.012
            )
        case "warm_light":
            return FilterContribution(
                brightness: intensity * 0.035,
                saturation: intensity * 0.025,
                redBias: intensity * 0.055,
                greenBias: intensity * 0.020,
                blueBias: -intensity * 0.025
            )
        default:
            return FilterContribution()
        }
    }

    private static func toByte(_ value: Float) -> UInt8 {
        UInt8((min(max(value, 0), 1) * 255).rounded())
    }
}

private struct FilterContribution {
    var brightness: Float = 0
    var saturation: Float = 0
    var redBias: Float = 0
    var greenBias: Float = 0
    var blueBias: Float = 0
}

private extension BeautyEffectPlan {
    var hasVisibleColorOutput: Bool {
        !activeDomains.isDisjoint(with: [.skin, .color, .filter, .lipColor])
    }

    var filterId: String? {
        metrics["beauty.effects.filter.softClean"] == 1 ? "soft_clean" :
            metrics["beauty.effects.filter.warmLight"] == 1 ? "warm_light" : nil
    }
}
