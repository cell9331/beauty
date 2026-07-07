import BeautyCore
import CoreGraphics
import CoreImage
import Foundation
import Vision

package struct VisionDetectionObservation: Equatable, Sendable {
    package let stableID: String?
    package let confidence: Double
    package let normalizedArea: Double
    package let visionBounds: CoordinateRect?
    package let landmarks: BeautyFaceLandmarks

    package init(
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

package struct VisionFaceDetectionResult: Equatable, Sendable {
    package let observations: [BeautyFaceObservation]
    package let summary: BeautyDetectionSummary
}

package struct VisionFaceDetectionInput: @unchecked Sendable {
    package let metadata: BeautyInputMetadata
    package let imageExtent: CGSize
    package let previewExtent: CGSize?
    package let stillImage: CIImage?

    package init(
        metadata: BeautyInputMetadata,
        imageExtent: CGSize,
        previewExtent: CGSize? = nil,
        stillImage: CIImage? = nil
    ) {
        self.metadata = metadata
        self.imageExtent = imageExtent
        self.previewExtent = previewExtent
        self.stillImage = stillImage
    }
}

package struct VisionFaceDetector: Sendable {
    package enum Failure: Error, Equatable, Sendable {
        case detectorUnavailable
        case detectionTimedOut
    }

    package typealias ObservationProvider = @Sendable (VisionFaceDetectionInput) throws -> [VisionDetectionObservation]

    private let minimumConfidence: Double
    private let observationProvider: ObservationProvider
    private var selectionPolicy: FaceSelectionPolicy

    package init(
        minimumConfidence: Double = 0.5,
        observationProvider: @escaping ObservationProvider = VisionFaceDetector.defaultObservationProvider
    ) {
        self.minimumConfidence = minimumConfidence
        self.observationProvider = observationProvider
        self.selectionPolicy = FaceSelectionPolicy()
    }

    package mutating func detect(
        metadata: BeautyInputMetadata,
        imageExtent: CGSize = CGSize(width: 1, height: 1),
        previewExtent: CGSize? = nil,
        configuration: BeautyConfiguration = .default
    ) -> VisionFaceDetectionResult {
        detect(
            image: nil,
            metadata: metadata,
            imageExtent: imageExtent,
            previewExtent: previewExtent,
            configuration: configuration
        )
    }

    package mutating func detect(
        image: CIImage?,
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
            let observations = try observationProvider(
                VisionFaceDetectionInput(
                    metadata: metadata,
                    imageExtent: imageExtent,
                    previewExtent: previewExtent,
                    stillImage: image
                )
            )
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

    package mutating func resetTracking() {
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

    private static func defaultObservationProvider(_ input: VisionFaceDetectionInput) throws -> [VisionDetectionObservation] {
        guard let image = input.stillImage else {
            throw Failure.detectorUnavailable
        }

        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(
            ciImage: image,
            orientation: input.metadata.orientation,
            options: [:]
        )
        try handler.perform([request])

        return (request.results ?? []).map { observation in
            VisionDetectionObservation(
                stableID: observation.uuid.uuidString,
                confidence: Double(observation.confidence),
                normalizedArea: Double(observation.boundingBox.width * observation.boundingBox.height),
                visionBounds: CoordinateRect(
                    x: Double(observation.boundingBox.origin.x),
                    y: Double(observation.boundingBox.origin.y),
                    width: Double(observation.boundingBox.width),
                    height: Double(observation.boundingBox.height)
                ),
                landmarks: landmarks(from: observation.landmarks)
            )
        }
    }

    private static func landmarks(from landmarks: VNFaceLandmarks2D?) -> BeautyFaceLandmarks {
        guard let landmarks else {
            return BeautyFaceLandmarks(availableGroups: [])
        }

        var groups: Set<BeautyLandmarkGroup> = []
        if landmarks.faceContour?.pointCount ?? 0 > 0 {
            groups.insert(.faceContour)
        }
        if landmarks.leftEye?.pointCount ?? 0 > 0 {
            groups.insert(.leftEye)
        }
        if landmarks.rightEye?.pointCount ?? 0 > 0 {
            groups.insert(.rightEye)
        }
        if landmarks.nose?.pointCount ?? 0 > 0 || landmarks.noseCrest?.pointCount ?? 0 > 0 {
            groups.insert(.nose)
        }
        if landmarks.outerLips?.pointCount ?? 0 > 0 {
            groups.insert(.outerLips)
        }
        return BeautyFaceLandmarks(availableGroups: groups)
    }
}
