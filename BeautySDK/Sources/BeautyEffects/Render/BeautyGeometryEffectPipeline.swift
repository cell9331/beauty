import CoreGraphics
import CoreImage
import Foundation
import BeautyCore

enum BeautyGeometryEffectPipeline {
    static func controlPoints(for plan: BeautyEffectPlan, face: FaceGeometry) -> [WarpControlPoint] {
        guard !plan.activeDomains.isDisjoint(with: [.faceShape, .eyes, .eyebrows, .nose, .mouth]) else {
            return []
        }

        return controlPoints(for: plan.effectiveStrengths, face: face)
    }

    static func controlPoints(for strengths: BeautyEffectiveStrengths, face: FaceGeometry) -> [WarpControlPoint] {
        FaceShapeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
            ChinWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
            EyeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
            EyebrowWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
            NoseWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
            MouthWarpProvider().makeControlPoints(face: face, strengths: strengths).points
    }

    /// MVP fixture proxy until the production warp pass consumes control points directly.
    static func applyMVPProxy(toBGRA bytes: [UInt8], plan: BeautyEffectPlan, face: FaceGeometry) -> [UInt8] {
        let points = controlPoints(for: plan, face: face)
        guard !points.isEmpty else {
            return bytes
        }

        let lift = UInt8(min(12, max(1, points.count)))
        var output = bytes
        var offset = 0
        while offset + 3 < output.count {
            output[offset] = clampedByte(Int(output[offset]) + Int(lift))
            output[offset + 1] = clampedByte(Int(output[offset + 1]) + Int(lift / 2))
            offset += 4
        }
        return output
    }

    /// Deterministic still-image warp used until the production Metal FaceWarpPass consumes control points directly.
    static func applyMVPProxy(to image: CIImage, plan: BeautyEffectPlan, face: FaceGeometry) -> CIImage {
        applyMVPProxy(
            to: image,
            plan: plan,
            face: face,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
    }

    /// Admitted still-image geometry consumes the canonical carrier and names
    /// sRGB explicitly. The legacy overload above retains its shipped device-RGB
    /// behavior for exact inactive compatibility.
    package static func applyMVPProxy(
        to image: CIImage,
        canonicalImage: BeautyCanonicalStillImage,
        plan: BeautyEffectPlan,
        face: FaceGeometry,
        onRasterize: ((BeautyCanonicalStillImage, CGColorSpace) -> Void)? = nil
    ) -> CIImage {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return image.cropped(to: canonicalImage.ciImage.extent)
        }
        return applyMVPProxy(
            to: image,
            plan: plan,
            face: face,
            colorSpace: colorSpace,
            onRasterize: {
                onRasterize?(canonicalImage, colorSpace)
            }
        )
    }

    private static func applyMVPProxy(
        to image: CIImage,
        plan: BeautyEffectPlan,
        face: FaceGeometry,
        colorSpace: CGColorSpace,
        onRasterize: (() -> Void)? = nil
    ) -> CIImage {
        let points = controlPoints(for: plan, face: face).compactMap(RenderableWarpPoint.init)
        guard !points.isEmpty else {
            return image.cropped(to: image.extent)
        }

        let extent = image.extent
        let width = Int(extent.width.rounded(.toNearestOrAwayFromZero))
        let height = Int(extent.height.rounded(.toNearestOrAwayFromZero))
        guard width > 1,
              height > 1,
              CGFloat(width) == extent.width,
              CGFloat(height) == extent.height
        else {
            return image.cropped(to: extent)
        }

        let rowBytes = width * 4
        var source = [UInt8](repeating: 0, count: rowBytes * height)
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace
        ])
        onRasterize?()
        source.withUnsafeMutableBytes { rawBytes in
            guard let baseAddress = rawBytes.baseAddress else {
                return
            }
            context.render(
                image,
                toBitmap: baseAddress,
                rowBytes: rowBytes,
                bounds: extent,
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }

        let output = warpedRGBABytes(source, width: width, height: height, points: points)
        let data = Data(output)
        let warped = CIImage(
            bitmapData: data,
            bytesPerRow: rowBytes,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: colorSpace
        )

        guard extent.origin != .zero else {
            return warped.cropped(to: extent)
        }
        return warped
            .transformed(by: CGAffineTransform(translationX: extent.origin.x, y: extent.origin.y))
            .cropped(to: extent)
    }

    private static func clampedByte(_ value: Int) -> UInt8 {
        UInt8(min(max(value, 0), 255))
    }

    private static func warpedRGBABytes(
        _ source: [UInt8],
        width: Int,
        height: Int,
        points: [RenderableWarpPoint]
    ) -> [UInt8] {
        var output = source
        for row in 0..<height {
            // `FaceGeometry` and every `WarpControlPoint` use the SDK's
            // canonical ImageNormalized space: top-left origin, y growing
            // downward. The CPU bitmap row index follows that same contract.
            let normalizedY = (Float(row) + 0.5) / Float(height)
            let columnRange = affectedColumnRange(forNormalizedY: normalizedY, width: width, points: points)
            guard let columnRange else {
                continue
            }

            for column in columnRange {
                let normalized = SIMD2<Float>(
                    (Float(column) + 0.5) / Float(width),
                    normalizedY
                )
                var sample = normalized
                var hasInfluence = false

                for point in points {
                    let deltaX = normalized.x - point.target.x
                    let deltaY = normalized.y - point.target.y
                    let distanceSquared = deltaX * deltaX + deltaY * deltaY
                    let radiusSquared = point.radius * point.radius
                    guard distanceSquared < radiusSquared else {
                        continue
                    }

                    let distance = distanceSquared.squareRoot()
                    let normalizedDistance = max(0, min(1, 1 - distance / point.radius))
                    let weight = falloffWeight(normalizedDistance, falloff: point.falloff)
                    sample -= point.displacement * weight
                    hasInfluence = true
                }

                guard hasInfluence else {
                    continue
                }

                sample = clamp(sample)
                let sampleX = sample.x * Float(width - 1)
                let sampleY = sample.y * Float(height - 1)
                writeInterpolatedPixel(
                    source: source,
                    output: &output,
                    width: width,
                    height: height,
                    column: column,
                    row: row,
                    sampleX: sampleX,
                    sampleY: sampleY
                )
            }
        }
        return output
    }

    private static func affectedColumnRange(
        forNormalizedY normalizedY: Float,
        width: Int,
        points: [RenderableWarpPoint]
    ) -> ClosedRange<Int>? {
        var lower = width
        var upper = -1
        for point in points where abs(normalizedY - point.target.y) <= point.radius {
            lower = min(lower, max(0, Int(floor((point.target.x - point.radius) * Float(width)))))
            upper = max(upper, min(width - 1, Int(ceil((point.target.x + point.radius) * Float(width)))))
        }
        guard lower <= upper else {
            return nil
        }
        return lower...upper
    }

    private static func writeInterpolatedPixel(
        source: [UInt8],
        output: inout [UInt8],
        width: Int,
        height: Int,
        column: Int,
        row: Int,
        sampleX: Float,
        sampleY: Float
    ) {
        let x0 = min(max(Int(floor(sampleX)), 0), width - 1)
        let y0 = min(max(Int(floor(sampleY)), 0), height - 1)
        let x1 = min(x0 + 1, width - 1)
        let y1 = min(y0 + 1, height - 1)
        let xWeight = sampleX - Float(x0)
        let yWeight = sampleY - Float(y0)
        let destinationOffset = (row * width + column) * 4

        for channel in 0..<4 {
            let topLeft = Float(source[(y0 * width + x0) * 4 + channel])
            let topRight = Float(source[(y0 * width + x1) * 4 + channel])
            let bottomLeft = Float(source[(y1 * width + x0) * 4 + channel])
            let bottomRight = Float(source[(y1 * width + x1) * 4 + channel])
            let top = topLeft + (topRight - topLeft) * xWeight
            let bottom = bottomLeft + (bottomRight - bottomLeft) * xWeight
            let value = top + (bottom - top) * yWeight
            output[destinationOffset + channel] = clampedByte(Int(value.rounded()))
        }
    }

    private static func falloffWeight(_ value: Float, falloff: Float) -> Float {
        let clamped = max(0, min(1, value))
        switch Int(max(1, falloff).rounded()) {
        case 1:
            return clamped
        case 2:
            return clamped * clamped
        default:
            return clamped * clamped * clamped
        }
    }

    private static func clamp(_ point: SIMD2<Float>) -> SIMD2<Float> {
        SIMD2<Float>(
            min(max(point.x, 0), 1),
            min(max(point.y, 0), 1)
        )
    }

    private struct RenderableWarpPoint {
        let target: SIMD2<Float>
        let displacement: SIMD2<Float>
        let radius: Float
        let falloff: Float

        init?(_ point: WarpControlPoint) {
            let displacement = point.target - point.source
            guard point.radius > 0.0001,
                  abs(displacement.x) + abs(displacement.y) > 0.0001
            else {
                return nil
            }
            self.target = clamp(point.target)
            self.displacement = displacement
            self.radius = min(max(point.radius, 0.001), 1)
            self.falloff = max(point.falloff, 1)
        }
    }
}
