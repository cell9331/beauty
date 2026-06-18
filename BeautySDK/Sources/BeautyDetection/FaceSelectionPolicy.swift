import BeautyCore

struct FaceSelectionResult: Equatable, Sendable {
    let selectedFaces: [BeautyFaceObservation]
    let summary: BeautyDetectionSummary
}

struct FaceSelectionPolicy: Equatable, Sendable {
    static let areaTieThreshold = 0.05

    private(set) var previousPrimaryStableID: String?

    mutating func select(
        from observations: [BeautyFaceObservation],
        configuration: BeautyConfiguration
    ) -> FaceSelectionResult {
        guard !observations.isEmpty else {
            previousPrimaryStableID = nil
            return FaceSelectionResult(selectedFaces: [], summary: .noFace)
        }

        let faceBudget = max(1, configuration.maximumFaceCount)
        let orderedFaces = orderByAreaThenStableID(observations)
        let selectedFaces = Array(orderedFaces.prefix(faceBudget))
        previousPrimaryStableID = selectedFaces.first?.stableID

        var reasons: [DetectionDegradationReason] = []
        if observations.count > faceBudget {
            reasons.append(.faceLimitApplied)
        }

        return FaceSelectionResult(
            selectedFaces: selectedFaces,
            summary: BeautyDetectionSummary(
                availability: .usable,
                reasons: reasons,
                faceCount: observations.count,
                usedFaceCount: selectedFaces.count
            )
        )
    }

    mutating func reset() {
        previousPrimaryStableID = nil
    }

    private func orderByAreaThenStableID(_ observations: [BeautyFaceObservation]) -> [BeautyFaceObservation] {
        var orderedFaces = observations.sorted { lhs, rhs in
            if lhs.normalizedArea == rhs.normalizedArea {
                return (lhs.stableID ?? "") < (rhs.stableID ?? "")
            }
            return lhs.normalizedArea > rhs.normalizedArea
        }

        guard let previousPrimaryStableID,
              let currentPrimary = orderedFaces.first,
              let previousPrimaryIndex = orderedFaces.firstIndex(where: { $0.stableID == previousPrimaryStableID })
        else {
            return orderedFaces
        }

        let previousPrimary = orderedFaces[previousPrimaryIndex]
        let areaDelta = abs(currentPrimary.normalizedArea - previousPrimary.normalizedArea)
        guard areaDelta <= Self.areaTieThreshold else {
            return orderedFaces
        }

        orderedFaces.remove(at: previousPrimaryIndex)
        orderedFaces.insert(previousPrimary, at: 0)
        return orderedFaces
    }
}
