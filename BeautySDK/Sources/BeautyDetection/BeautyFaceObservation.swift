import Foundation

package enum BeautyObservedEyeSide: String, Equatable, Sendable {
    case left
    case right
}

/// Result of the detector's anatomical side-order check. An explicit
/// observed payload never receives an implicit success value: the detector
/// must derive `.canonical` through the same coordinate metadata that mapped
/// the contour points.
package enum BeautyObservedEyeOrder: Equatable, Sendable {
    case canonical
    case invalid
}

/// Frame-scoped, image-normalized evidence captured by the Vision adapter.
///
/// This value intentionally has no Codable or diagnostic representation. It is
/// copied into an observation only after the detector has mapped and bounded
/// every point, and is released with that request's observation.
package struct BeautyObservedEyeSupport: Equatable, Sendable {
    package let side: BeautyObservedEyeSide
    package let contour: [CoordinatePoint]
    package let pupil: [CoordinatePoint]?

    package init(
        side: BeautyObservedEyeSide,
        contour: [CoordinatePoint],
        pupil: [CoordinatePoint]? = nil
    ) {
        self.side = side
        self.contour = contour
        self.pupil = pupil
    }
}

package struct BeautyFaceObservation: Equatable, Sendable {
    package let stableID: String?
    package let confidence: Double
    package let normalizedArea: Double
    package let imageBounds: CoordinateRect?
    package let landmarks: BeautyFaceLandmarks
    package let observedEyeSupport: [BeautyObservedEyeSupport]?
    package let observedEyeOrder: BeautyObservedEyeOrder?

    package init(
        stableID: String? = nil,
        confidence: Double = 1,
        normalizedArea: Double = 0,
        imageBounds: CoordinateRect? = nil,
        landmarks: BeautyFaceLandmarks = .complete,
        observedEyeSupport: [BeautyObservedEyeSupport]? = nil,
        observedEyeOrder: BeautyObservedEyeOrder? = nil
    ) {
        self.stableID = stableID
        self.confidence = confidence
        self.normalizedArea = imageBounds?.area ?? max(0, normalizedArea)
        self.imageBounds = imageBounds
        self.landmarks = landmarks
        self.observedEyeSupport = observedEyeSupport
        self.observedEyeOrder = observedEyeOrder
    }
}

package enum BeautyLandmarkGroup: String, CaseIterable, Equatable, Sendable {
    case faceContour
    case leftEye
    case rightEye
    case nose
    case outerLips
    case innerLips
}

package struct BeautyFaceLandmarks: Equatable, Sendable {
    private static let requiredGeometryGroups: Set<BeautyLandmarkGroup> = [
        .faceContour,
        .leftEye,
        .rightEye,
        .nose,
        .outerLips
    ]

    package let availableGroups: Set<BeautyLandmarkGroup>

    package init(availableGroups: Set<BeautyLandmarkGroup>) {
        self.availableGroups = availableGroups
    }

    package static let complete = BeautyFaceLandmarks(
        availableGroups: Set(BeautyLandmarkGroup.allCases)
    )

    package static let missingRequiredGeometry = BeautyFaceLandmarks(
        availableGroups: [.faceContour, .leftEye, .rightEye]
    )

    package var hasRequiredGeometry: Bool {
        Self.requiredGeometryGroups.isSubset(of: availableGroups)
    }
}
