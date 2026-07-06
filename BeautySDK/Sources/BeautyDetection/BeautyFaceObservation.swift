import Foundation

package struct BeautyFaceObservation: Equatable, Sendable {
    package let stableID: String?
    package let confidence: Double
    package let normalizedArea: Double
    package let imageBounds: CoordinateRect?
    package let landmarks: BeautyFaceLandmarks

    package init(
        stableID: String? = nil,
        confidence: Double = 1,
        normalizedArea: Double = 0,
        imageBounds: CoordinateRect? = nil,
        landmarks: BeautyFaceLandmarks = .complete
    ) {
        self.stableID = stableID
        self.confidence = confidence
        self.normalizedArea = imageBounds?.area ?? max(0, normalizedArea)
        self.imageBounds = imageBounds
        self.landmarks = landmarks
    }
}

package enum BeautyLandmarkGroup: String, CaseIterable, Equatable, Sendable {
    case faceContour
    case leftEye
    case rightEye
    case nose
    case outerLips
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
