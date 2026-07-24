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

/// Frame-scoped, image-normalized face-contour evidence from one request.
///
/// Contour and median-line absence are independent. This immutable package
/// value has no Codable representation and exposes only aggregate counts
/// through its explicitly redacted diagnostic representation.
package struct BeautyObservedFaceSupport: Equatable, Sendable {
    package let contour: [CoordinatePoint]?
    package let medianLine: [CoordinatePoint]?

    package init(
        contour: [CoordinatePoint]? = nil,
        medianLine: [CoordinatePoint]? = nil
    ) {
        self.contour = contour
        self.medianLine = medianLine
    }
}

extension BeautyObservedFaceSupport: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyObservedFaceSupport(contourCount: \(contour?.count ?? 0), medianLineCount: \(medianLine?.count ?? 0))"
    }

    package var debugDescription: String {
        description
    }

    package var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "contourCount": contour?.count ?? 0,
                "medianLineCount": medianLine?.count ?? 0,
            ],
            displayStyle: .struct
        )
    }
}

package enum BeautyObservedEyebrowSide: Equatable, Sendable {
    case left
    case right
}

/// Request-scoped mapped evidence copied from actual Vision eyebrow regions.
/// Left and right absence remain independent and diagnostics expose counts only.
package struct BeautyObservedEyebrowSupport: Equatable, Sendable {
    package let left: [CoordinatePoint]?
    package let right: [CoordinatePoint]?

    package init(left: [CoordinatePoint]? = nil, right: [CoordinatePoint]? = nil) {
        self.left = left
        self.right = right
    }
}

extension BeautyObservedEyebrowSupport: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyObservedEyebrowSupport(leftCount: \(left?.count ?? 0), rightCount: \(right?.count ?? 0))"
    }

    package var debugDescription: String { description }

    package var customMirror: Mirror {
        Mirror(
            self,
            children: ["leftCount": left?.count ?? 0, "rightCount": right?.count ?? 0],
            displayStyle: .struct
        )
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
    package let observedFaceSupport: BeautyObservedFaceSupport?
    package let observedEyebrowSupport: BeautyObservedEyebrowSupport?

    package init(
        stableID: String? = nil,
        confidence: Double = 1,
        normalizedArea: Double = 0,
        imageBounds: CoordinateRect? = nil,
        landmarks: BeautyFaceLandmarks = .complete,
        observedEyeSupport: [BeautyObservedEyeSupport]? = nil,
        observedEyeOrder: BeautyObservedEyeOrder? = nil,
        observedFaceSupport: BeautyObservedFaceSupport? = nil,
        observedEyebrowSupport: BeautyObservedEyebrowSupport? = nil
    ) {
        self.stableID = stableID
        self.confidence = confidence
        self.normalizedArea = imageBounds?.area ?? max(0, normalizedArea)
        self.imageBounds = imageBounds
        self.landmarks = landmarks
        self.observedEyeSupport = observedEyeSupport
        self.observedEyeOrder = observedEyeOrder
        self.observedFaceSupport = observedFaceSupport
        self.observedEyebrowSupport = observedEyebrowSupport
    }
}

extension BeautyFaceObservation: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyFaceObservation("
            + "landmarkGroupCount: \(landmarks.availableGroups.count), "
            + "observedEyeSupportCount: \(observedEyeSupport?.count ?? 0), "
            + "observedFaceSupportAvailable: \(observedFaceSupport != nil), "
            + "observedFaceContourCount: \(observedFaceSupport?.contour?.count ?? 0), "
            + "observedFaceMedianLineCount: \(observedFaceSupport?.medianLine?.count ?? 0), "
            + "observedEyebrowSupportAvailable: \(observedEyebrowSupport != nil), "
            + "observedLeftEyebrowCount: \(observedEyebrowSupport?.left?.count ?? 0), "
            + "observedRightEyebrowCount: \(observedEyebrowSupport?.right?.count ?? 0))"
    }

    package var debugDescription: String {
        description
    }

    package var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "landmarkGroupCount": landmarks.availableGroups.count,
                "observedEyeSupportCount": observedEyeSupport?.count ?? 0,
                "observedFaceSupportAvailable": observedFaceSupport != nil,
                "observedFaceContourCount": observedFaceSupport?.contour?.count ?? 0,
                "observedFaceMedianLineCount": observedFaceSupport?.medianLine?.count ?? 0,
                "observedEyebrowSupportAvailable": observedEyebrowSupport != nil,
                "observedLeftEyebrowCount": observedEyebrowSupport?.left?.count ?? 0,
                "observedRightEyebrowCount": observedEyebrowSupport?.right?.count ?? 0,
            ],
            displayStyle: .struct
        )
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
