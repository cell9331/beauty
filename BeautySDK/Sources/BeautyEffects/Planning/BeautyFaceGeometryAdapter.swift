import BeautyDetection
import Foundation

enum BeautyFaceGeometryAdapter {
    static func makeGeometry(from observation: BeautyFaceObservation) -> FaceGeometry {
        let bounds = makeBounds(from: observation)
        let landmarks = observation.landmarks.availableGroups

        return FaceGeometry(
            bounds: bounds,
            faceContour: landmarks.contains(.faceContour) ? faceContour(in: bounds) : [],
            leftEye: landmarks.contains(.leftEye) ? leftEye(in: bounds) : [],
            rightEye: landmarks.contains(.rightEye) ? rightEye(in: bounds) : [],
            nose: landmarks.contains(.nose) ? nose(in: bounds) : [],
            noseRoot: landmarks.contains(.nose) ? noseRoot(in: bounds) : [],
            noseTip: landmarks.contains(.nose) ? noseTip(in: bounds) : [],
            outerLips: landmarks.contains(.outerLips) ? outerLips(in: bounds) : [],
            upperLips: landmarks.contains(.outerLips) ? upperLips(in: bounds) : [],
            lowerLips: landmarks.contains(.outerLips) ? lowerLips(in: bounds) : [],
            innerLips: landmarks.contains(.innerLips) ? innerLips(in: bounds) : []
        )
    }

    private static func makeBounds(from observation: BeautyFaceObservation) -> FaceBounds {
        if let rect = observation.imageBounds,
           rect.isFinite,
           rect.width > 0,
           rect.height > 0 {
            return FaceBounds(
                x: clamped(Float(rect.x)),
                y: clamped(Float(rect.y)),
                width: clampedSize(Float(rect.width)),
                height: clampedSize(Float(rect.height))
            )
        }

        let fallbackArea = clampedArea(Float(observation.normalizedArea))
        let width = sqrt(fallbackArea * 2 / 3)
        let height = fallbackArea / width
        return FaceBounds(
            x: (1 - width) / 2,
            y: (1 - height) / 2,
            width: width,
            height: height
        )
    }

    private static func faceContour(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.05, y: 0.30),
            point(bounds, x: 0.12, y: 0.58),
            point(bounds, x: 0.28, y: 0.84),
            point(bounds, x: 0.50, y: 0.94),
            point(bounds, x: 0.72, y: 0.84),
            point(bounds, x: 0.88, y: 0.58),
            point(bounds, x: 0.95, y: 0.30)
        ]
    }

    private static func leftEye(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.25, y: 0.34),
            point(bounds, x: 0.34, y: 0.31),
            point(bounds, x: 0.42, y: 0.34)
        ]
    }

    private static func rightEye(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.58, y: 0.34),
            point(bounds, x: 0.66, y: 0.31),
            point(bounds, x: 0.75, y: 0.34)
        ]
    }

    private static func nose(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.46, y: 0.43),
            point(bounds, x: 0.50, y: 0.55),
            point(bounds, x: 0.40, y: 0.64),
            point(bounds, x: 0.60, y: 0.64)
        ]
    }

    private static func noseRoot(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.44, y: 0.48),
            point(bounds, x: 0.56, y: 0.48)
        ]
    }

    private static func noseTip(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.44, y: 0.62),
            point(bounds, x: 0.50, y: 0.66),
            point(bounds, x: 0.56, y: 0.62)
        ]
    }

    private static func outerLips(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.30, y: 0.76),
            point(bounds, x: 0.40, y: 0.70),
            point(bounds, x: 0.50, y: 0.68),
            point(bounds, x: 0.60, y: 0.70),
            point(bounds, x: 0.70, y: 0.76),
            point(bounds, x: 0.60, y: 0.82),
            point(bounds, x: 0.50, y: 0.84),
            point(bounds, x: 0.40, y: 0.82)
        ]
    }

    private static func upperLips(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.40, y: 0.70),
            point(bounds, x: 0.50, y: 0.68),
            point(bounds, x: 0.60, y: 0.70)
        ]
    }

    private static func lowerLips(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.40, y: 0.82),
            point(bounds, x: 0.50, y: 0.84),
            point(bounds, x: 0.60, y: 0.82)
        ]
    }

    private static func innerLips(in bounds: FaceBounds) -> [SIMD2<Float>] {
        [
            point(bounds, x: 0.40, y: 0.76),
            point(bounds, x: 0.45, y: 0.73),
            point(bounds, x: 0.55, y: 0.73),
            point(bounds, x: 0.60, y: 0.76),
            point(bounds, x: 0.55, y: 0.79),
            point(bounds, x: 0.45, y: 0.79)
        ]
    }

    private static func point(_ bounds: FaceBounds, x: Float, y: Float) -> SIMD2<Float> {
        SIMD2<Float>(
            clamped(bounds.x + bounds.width * x),
            clamped(bounds.y + bounds.height * y)
        )
    }

    private static func clamped(_ value: Float) -> Float {
        min(max(value, 0), 1)
    }

    private static func clampedSize(_ value: Float) -> Float {
        min(max(value, 0.05), 1)
    }

    private static func clampedArea(_ value: Float) -> Float {
        guard value.isFinite, value > 0 else {
            return 0.24
        }
        return min(max(value, 0.04), 0.64)
    }
}
