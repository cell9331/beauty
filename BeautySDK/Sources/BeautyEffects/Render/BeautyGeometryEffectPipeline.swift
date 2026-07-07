import CoreImage

enum BeautyGeometryEffectPipeline {
    static func controlPoints(for plan: BeautyEffectPlan, face: FaceGeometry) -> [WarpControlPoint] {
        guard !plan.activeDomains.isDisjoint(with: [.faceShape, .eyes, .nose, .mouth]) else {
            return []
        }

        return controlPoints(for: plan.effectiveStrengths, face: face)
    }

    static func controlPoints(for strengths: BeautyEffectiveStrengths, face: FaceGeometry) -> [WarpControlPoint] {
        FaceShapeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
            ChinWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
            EyeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
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

    /// MVP CIImage proxy until the production warp pass consumes control points directly.
    static func applyMVPProxy(to image: CIImage, plan: BeautyEffectPlan, face: FaceGeometry) -> CIImage {
        let points = controlPoints(for: plan, face: face)
        guard !points.isEmpty else {
            return image.cropped(to: image.extent)
        }

        let lift = CGFloat(min(0.045, max(0.006, Double(points.count) * 0.0015)))
        return image.applyingFilter(
            "CIColorMatrix",
            parameters: [
                "inputRVector": CIVector(x: 1, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 1, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 1, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1),
                "inputBiasVector": CIVector(x: lift, y: lift / 2, z: -lift / 3, w: 0)
            ]
        ).cropped(to: image.extent)
    }

    private static func clampedByte(_ value: Int) -> UInt8 {
        UInt8(min(max(value, 0), 255))
    }
}
