import BeautyCore
import CoreGraphics
import Foundation
import Vision

struct VisionDetectionObservation: Equatable, Sendable {
    let stableID: String?
    let confidence: Double
    let normalizedArea: Double
    let visionBounds: CoordinateRect?
    let landmarks: BeautyFaceLandmarks

    init(
        stableID: String? = nil,
        confidence: Double = 1,
        normalizedArea: Double = 0,
        visionBounds: CoordinateRect? = nil,
        landmarks: BeautyFaceLandmarks = .complete
    ) {
        self.stableID = stableID
        self.confidence = confidence
        self.normalizedArea = visionBounds?.area ?? max(0, normalizedArea)
        self.visionBounds = visionBounds
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
        imageExtent: CGSize = CGSize(width: 1, height: 1),
        previewExtent: CGSize? = nil,
        configuration: BeautyConfiguration = .default
    ) -> VisionFaceDetectionResult {
        guard configuration.enableFaceTracking else {
            selectionPolicy.reset()
            return VisionFaceDetectionResult(observations: [], summary: .disabled)
        }

        do {
            let observations = try observationProvider(metadata)
            return summarize(
                observations,
                metadata: metadata,
                imageExtent: imageExtent,
                previewExtent: previewExtent,
                configuration: configuration
            )
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
        metadata: BeautyInputMetadata,
        imageExtent: CGSize,
        previewExtent: CGSize?,
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

        let mapper = CoordinateMapper(
            metadata: metadata,
            imageExtent: imageExtent,
            previewExtent: previewExtent
        )
        let observations: [BeautyFaceObservation]
        do {
            observations = try usableDetections.map { detection in
                try mapObservation(detection, mapper: mapper)
            }
        } catch is CoordinateMapper.MappingError {
            selectionPolicy.reset()
            return VisionFaceDetectionResult(
                observations: [],
                summary: BeautyDetectionSummary(
                    availability: .partial,
                    reasons: [.mappingFailed],
                    faceCount: detections.count,
                    usedFaceCount: 0
                )
            )
        } catch {
            selectionPolicy.reset()
            return VisionFaceDetectionResult(
                observations: [],
                summary: BeautyDetectionSummary(
                    availability: .partial,
                    reasons: [.mappingFailed],
                    faceCount: detections.count,
                    usedFaceCount: 0
                )
            )
        }
        let selection = selectionPolicy.select(from: observations, configuration: configuration)
        return VisionFaceDetectionResult(
            observations: selection.selectedFaces,
            summary: selection.summary
        )
    }

    private func mapObservation(
        _ detection: VisionDetectionObservation,
        mapper: CoordinateMapper
    ) throws -> BeautyFaceObservation {
        guard let visionBounds = detection.visionBounds else {
            return BeautyFaceObservation(
                stableID: detection.stableID,
                confidence: detection.confidence,
                normalizedArea: detection.normalizedArea,
                landmarks: detection.landmarks
            )
        }

        let imageBounds = try mapper.map(
            rect: visionBounds,
            from: .visionNormalized,
            to: .imageNormalized
        )
        return BeautyFaceObservation(
            stableID: detection.stableID,
            confidence: detection.confidence,
            normalizedArea: imageBounds.area,
            imageBounds: imageBounds,
            landmarks: detection.landmarks
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
