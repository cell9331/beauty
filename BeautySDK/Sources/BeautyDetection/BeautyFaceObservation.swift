import Foundation

struct BeautyFaceObservation: Equatable, Sendable {
    let stableID: String?
    let confidence: Double
    let normalizedArea: Double
    let imageBounds: CoordinateRect?
    let landmarks: BeautyFaceLandmarks

    init(
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

enum BeautyLandmarkGroup: String, CaseIterable, Equatable, Sendable {
    case faceContour
    case leftEye
    case rightEye
    case nose
    case outerLips
}

struct BeautyFaceLandmarks: Equatable, Sendable {
    private static let requiredGeometryGroups: Set<BeautyLandmarkGroup> = [
        .faceContour,
        .leftEye,
        .rightEye,
        .nose,
        .outerLips
    ]

    let availableGroups: Set<BeautyLandmarkGroup>

    init(availableGroups: Set<BeautyLandmarkGroup>) {
        self.availableGroups = availableGroups
    }

    static let complete = BeautyFaceLandmarks(
        availableGroups: Set(BeautyLandmarkGroup.allCases)
    )

    static let missingRequiredGeometry = BeautyFaceLandmarks(
        availableGroups: [.faceContour, .leftEye, .rightEye]
    )

    var hasRequiredGeometry: Bool {
        Self.requiredGeometryGroups.isSubset(of: availableGroups)
    }
}
