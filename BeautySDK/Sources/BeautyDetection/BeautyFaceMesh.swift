import Foundation

/// Validated MediaPipe image-space evidence. No persistence or raw diagnostics.
package struct BeautyFaceMesh: Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package let points: [SIMD3<Float>]
    /// Row-major canonical-face-to-detected-face transform, in the upright
    /// inference raster's coordinate convention. It is not a pixel warp.
    package let facialTransformation: [Float]?

    package init?(points: [SIMD3<Float>], facialTransformation: [Float]? = nil) {
        guard points.count == 478, points.allSatisfy({
            $0.x.isFinite && $0.y.isFinite && $0.z.isFinite
                && (0...1).contains($0.x) && (0...1).contains($0.y)
        }) else { return nil }
        self.points = points
        self.facialTransformation = Self.validatedTransformation(facialTransformation)
    }

    static func validatedTransformation(_ values: [Float]?) -> [Float]? {
        guard let values, values.count == 16, values.allSatisfy(\.isFinite),
              abs(values[12]) < 0.0001, abs(values[13]) < 0.0001,
              abs(values[14]) < 0.0001, abs(values[15] - 1) < 0.0001 else { return nil }
        let determinant = Double(values[0]) * (Double(values[5]) * Double(values[10]) - Double(values[6]) * Double(values[9]))
            - Double(values[1]) * (Double(values[4]) * Double(values[10]) - Double(values[6]) * Double(values[8]))
            + Double(values[2]) * (Double(values[4]) * Double(values[9]) - Double(values[5]) * Double(values[8]))
        return abs(determinant) > 0.0001 ? values : nil
    }

    package func path(_ indices: [Int]) -> [CoordinatePoint] {
        guard indices.allSatisfy({ points.indices.contains($0) }) else { return [] }
        return indices.map { CoordinatePoint(x: Double(points[$0].x), y: Double(points[$0].y)) }
    }

    package var description: String {
        "BeautyFaceMesh(pointCount: \(points.count), transformationAvailable: \(facialTransformation != nil))"
    }
    package var debugDescription: String { description }
    package var customMirror: Mirror {
        Mirror(self, children: ["pointCount": points.count, "transformationAvailable": facialTransformation != nil])
    }
}

/// Ordered paths from the pinned MediaPipe topology. Left/right here match
/// Beauty's upright image-side convention, rather than MediaPipe's anatomical
/// LEFT_EYE name. No inferred points or face-box templates are inserted.
package enum MediaPipeFaceTopology {
    package static let lowerContour = [234, 93, 132, 58, 172, 136, 150, 149, 176, 148, 152, 377, 400, 378, 379, 365, 397, 288, 361, 323, 454]
    package static let oval = [10, 338, 297, 332, 284, 251, 389, 356, 454, 323, 361, 288, 397, 365, 379, 378, 400, 377, 152, 148, 176, 149, 150, 136, 172, 58, 132, 93, 234, 127, 162, 21, 54, 103, 67, 109]
    package static let leftEye = [33, 7, 163, 144, 145, 153, 154, 155, 133, 173, 157, 158, 159, 160, 161, 246]
    package static let rightEye = [263, 249, 390, 373, 374, 380, 381, 382, 362, 398, 384, 385, 386, 387, 388, 466]
    package static let leftIris = [469, 470, 471, 472]
    package static let rightIris = [474, 475, 476, 477]
    package static let leftBrowEnvelope = [107, 66, 105, 63, 70, 46, 53, 52, 65, 55]
    package static let rightBrowEnvelope = [336, 296, 334, 293, 300, 276, 283, 282, 295, 285]
    package static let leftBrow = [107, 66, 105, 63, 70]
    package static let rightBrow = [336, 296, 334, 293, 300]
    package static let median = [10, 151, 9, 8, 168, 6, 197, 195, 5, 4, 1, 2, 164, 17, 18, 152]
    package static let noseCrest = [168, 6, 197, 195, 5, 4, 1]
    package static let noseContour = [98, 97, 2, 326, 327, 294, 278, 344, 440, 275, 4, 45, 220, 115, 48, 64]
    package static let noseRoot = [168, 193, 417]
    package static let noseTip = [98, 1, 327]
    package static let upperLip = [61, 185, 40, 39, 37, 0, 267, 269, 270, 409, 291]
    package static let lowerLip = [291, 375, 321, 405, 314, 17, 84, 181, 91, 146, 61]
    package static let outerLip = Array(upperLip.dropLast()) + Array(lowerLip.dropLast())
    package static let innerLip = [78, 191, 80, 81, 82, 13, 312, 311, 310, 415, 308, 324, 318, 402, 317, 14, 87, 178, 88, 95]

    package static func observation(from mesh: BeautyFaceMesh) -> BeautyFaceObservation? {
        let bounds = CoordinateRect.bounding(mesh.path(oval))
        guard bounds.isFinite, bounds.width > 0, bounds.height > 0 else { return nil }
        let left = mesh.path(leftEye)
        let right = mesh.path(rightEye)
        let leftCenter = left.reduce(0.0) { $0 + $1.x } / Double(left.count)
        let rightCenter = right.reduce(0.0) { $0 + $1.x } / Double(right.count)
        return BeautyFaceObservation(
            // The task exposes no face confidence score; 1 denotes admission
            // by its configured detection/presence thresholds, not certainty.
            confidence: 1, imageBounds: bounds, landmarks: .complete,
            observedEyeSupport: [
                BeautyObservedEyeSupport(side: .left, contour: left, pupil: mesh.path([468])),
                BeautyObservedEyeSupport(side: .right, contour: right, pupil: mesh.path([473]))
            ],
            observedEyeOrder: leftCenter < rightCenter ? .canonical : .invalid,
            observedFaceSupport: BeautyObservedFaceSupport(contour: mesh.path(lowerContour), medianLine: mesh.path(median)),
            observedEyebrowSupport: BeautyObservedEyebrowSupport(left: mesh.path(leftBrow), right: mesh.path(rightBrow)),
            observedLipSupport: BeautyObservedLipSupport(outer: mesh.path(outerLip), inner: mesh.path(innerLip)),
            observedNoseSupport: BeautyObservedNoseSupport(crest: mesh.path(noseCrest), contour: mesh.path(noseContour)),
            mesh: mesh
        )
    }
}
