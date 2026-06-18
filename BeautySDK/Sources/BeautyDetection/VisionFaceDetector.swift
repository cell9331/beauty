import BeautyCore
import Foundation
import Vision

struct VisionDetectionObservation: Equatable, Sendable {
    let stableID: String?
    let confidence: Double
    let normalizedArea: Double
    let landmarks: BeautyFaceLandmarks

    init(
        stableID: String? = nil,
        confidence: Double = 1,
        normalizedArea: Double,
        landmarks: BeautyFaceLandmarks = .complete
    ) {
        self.stableID = stableID
        self.confidence = confidence
        self.normalizedArea = max(0, normalizedArea)
        self.landmarks = landmarks
    }
}

struct VisionFaceDetectionResult: Equatable, Sendable {
    let observations: [BeautyFaceObservation]
    let summary: BeautyDetectionSummary
}

struct VisionFaceDetector: Sendable {
    enum Failure: Error, Equatable, Sendable {
        case detectorUnavailable
        case detectionTimedOut
    }

    typealias ObservationProvider = @Sendable (BeautyInputMetadata) throws -> [VisionDetectionObservation]

    private let minimumConfidence: Double
    private let observationProvider: ObservationProvider
    private var selectionPolicy: FaceSelectionPolicy

    init(
        minimumConfidence: Double = 0.5,
        observationProvider: @escaping ObservationProvider = VisionFaceDetector.defaultObservationProvider
    ) {
        self.minimumConfidence = minimumConfidence
        self.observationProvider = observationProvider
        self.selectionPolicy = FaceSelectionPolicy()
    }

    mutating func detect(
        metadata: BeautyInputMetadata,
        configuration: BeautyConfiguration = .default
    ) -> VisionFaceDetectionResult {
        guard configuration.enableFaceTracking else {
            selectionPolicy.reset()
            return VisionFaceDetectionResult(observations: [], summary: .disabled)
        }

        do {
            let observations = try observationProvider(metadata)
            return summarize(observations, configuration: configuration)
        } catch let failure as Failure {
            selectionPolicy.reset()
            return VisionFaceDetectionResult(observations: [], summary: summary(for: failure))
        } catch {
            selectionPolicy.reset()
            return VisionFaceDetectionResult(
                observations: [],
                summary: BeautyDetectionSummary(
                    availability: .skipped,
                    reasons: [.detectorUnavailable]
                )
            )
        }
    }

    mutating func resetTracking() {
        selectionPolicy.reset()
    }

    private mutating func summarize(
        _ detections: [VisionDetectionObservation],
        configuration: BeautyConfiguration
    ) -> VisionFaceDetectionResult {
        guard !detections.isEmpty else {
            selectionPolicy.reset()
            return VisionFaceDetectionResult(
                observations: [],
                summary: BeautyDetectionSummary(
                    availability: .noFace,
                    reasons: [.noFaceDetected]
                )
            )
        }

        let usableDetections = detections.filter { detection in
            detection.confidence >= minimumConfidence && detection.landmarks.hasRequiredGeometry
        }

        guard !usableDetections.isEmpty else {
            selectionPolicy.reset()
            return VisionFaceDetectionResult(
                observations: [],
                summary: degradedSummary(for: detections)
            )
        }

        let observations = usableDetections.map { detection in
            BeautyFaceObservation(
                stableID: detection.stableID,
                confidence: detection.confidence,
                normalizedArea: detection.normalizedArea,
                landmarks: detection.landmarks
            )
        }
        let selection = selectionPolicy.select(from: observations, configuration: configuration)
        return VisionFaceDetectionResult(
            observations: selection.selectedFaces,
            summary: selection.summary
        )
    }

    private func degradedSummary(for detections: [VisionDetectionObservation]) -> BeautyDetectionSummary {
        let hasRequiredGeometry = detections.contains { $0.landmarks.hasRequiredGeometry }
        if hasRequiredGeometry {
            return BeautyDetectionSummary(
                availability: .lowConfidence,
                reasons: [.lowConfidenceFace],
                faceCount: detections.count,
                usedFaceCount: 0
            )
        }

        return BeautyDetectionSummary(
            availability: .partial,
            reasons: [.missingLandmarks],
            faceCount: detections.count,
            usedFaceCount: 0
        )
    }

    private func summary(for failure: Failure) -> BeautyDetectionSummary {
        switch failure {
        case .detectorUnavailable:
            BeautyDetectionSummary(
                availability: .skipped,
                reasons: [.detectorUnavailable]
            )
        case .detectionTimedOut:
            BeautyDetectionSummary(
                availability: .skipped,
                reasons: [.detectionTimedOut]
            )
        }
    }

    private static func defaultObservationProvider(
        metadata: BeautyInputMetadata
    ) throws -> [VisionDetectionObservation] {
        _ = metadata
        _ = VNDetectFaceLandmarksRequest()
        throw Failure.detectorUnavailable
    }
}
