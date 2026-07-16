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
    package let observedEyeSupport: [BeautyObservedEyeSupport]?

    package init(
        stableID: String? = nil,
        confidence: Double = 1,
        normalizedArea: Double = 0,
        visionBounds: CoordinateRect? = nil,
        landmarks: BeautyFaceLandmarks = .complete,
        observedEyeSupport: [BeautyObservedEyeSupport]? = nil
    ) {
        self.stableID = stableID
        self.confidence = confidence
        self.normalizedArea = visionBounds?.area ?? max(0, normalizedArea)
        self.visionBounds = visionBounds
        self.landmarks = landmarks
        self.observedEyeSupport = observedEyeSupport
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
        let imageBounds: CoordinateRect?
        if let visionBounds = detection.visionBounds {
            imageBounds = try mapper.map(
                rect: visionBounds,
                from: .visionNormalized,
                to: .imageNormalized
            )
        } else {
            imageBounds = nil
        }

        let observedEyeSupport: [BeautyObservedEyeSupport]?
        let observedEyeOrder: BeautyObservedEyeOrder?
        if let supports = detection.observedEyeSupport {
            // Vision landmark points are normalized to the face bounding box,
            // not to the full image. Keep this as the sole conversion boundary:
            // compose the face-local point into Vision image space, then let the
            // mapper apply orientation/mirror handling exactly once.
            guard let visionBounds = detection.visionBounds,
                  visionBounds.isFinite,
                  visionBounds.width > 0,
                  visionBounds.height > 0
            else {
                throw CoordinateMapper.MappingError.invalidCoordinate
            }

            observedEyeSupport = try supports.map { support in
                BeautyObservedEyeSupport(
                    side: support.side,
                    contour: try mapPoints(
                        support.contour,
                        in: visionBounds,
                        with: mapper
                    ),
                    pupil: try support.pupil.map {
                        try mapPoints($0, in: visionBounds, with: mapper)
                    }
                )
            }
            observedEyeOrder = deriveEyeOrder(
                observedEyeSupport ?? [],
                visionBounds: visionBounds,
                mapper: mapper
            )
        } else {
            observedEyeSupport = nil
            observedEyeOrder = nil
        }

        return BeautyFaceObservation(
                stableID: detection.stableID,
                confidence: detection.confidence,
                normalizedArea: detection.normalizedArea,
                imageBounds: imageBounds,
                landmarks: detection.landmarks,
                observedEyeSupport: observedEyeSupport,
                observedEyeOrder: observedEyeOrder
            )
    }

    private func deriveEyeOrder(
        _ supports: [BeautyObservedEyeSupport],
        visionBounds: CoordinateRect,
        mapper: CoordinateMapper
    ) -> BeautyObservedEyeOrder {
        guard supports.count == 2,
              let left = supports.first(where: { $0.side == .left }),
              let right = supports.first(where: { $0.side == .right }),
              supports.filter({ $0.side == .left }).count == 1,
              supports.filter({ $0.side == .right }).count == 1,
              let leftCenter = centroid(left.contour),
              let rightCenter = centroid(right.contour)
        else {
            return .invalid
        }

        let localOrigin = CoordinatePoint(x: visionBounds.x, y: visionBounds.y)
        let localRight = CoordinatePoint(
            x: visionBounds.x + visionBounds.width,
            y: visionBounds.y
        )
        guard let mappedOrigin = try? mapper.map(
            point: localOrigin,
            from: .visionNormalized,
            to: .imageNormalized
        ), let mappedRight = try? mapper.map(
            point: localRight,
            from: .visionNormalized,
            to: .imageNormalized
        ) else {
            return .invalid
        }

        let axis = SIMD2<Float>(
            Float(mappedRight.x - mappedOrigin.x),
            Float(mappedRight.y - mappedOrigin.y)
        )
        let axisLength = hypot(axis.x, axis.y)
        let separation = SIMD2<Float>(
            Float(rightCenter.x - leftCenter.x),
            Float(rightCenter.y - leftCenter.y)
        )
        guard axis.x.isFinite, axis.y.isFinite,
              separation.x.isFinite, separation.y.isFinite,
              axisLength.isFinite, axisLength > 0
        else {
            return .invalid
        }

        let anatomicalAxis = axis / axisLength
        let projection = separation.x * anatomicalAxis.x + separation.y * anatomicalAxis.y
        return projection > 0.000001 ? .canonical : .invalid
    }

    private func centroid(_ points: [CoordinatePoint]) -> CoordinatePoint? {
        guard !points.isEmpty,
              points.allSatisfy({ $0.isFinite })
        else { return nil }
        let sum = points.reduce(CoordinatePoint(x: 0, y: 0)) { partial, point in
            CoordinatePoint(x: partial.x + point.x, y: partial.y + point.y)
        }
        let count = Double(points.count)
        let center = CoordinatePoint(x: sum.x / count, y: sum.y / count)
        return center.isFinite ? center : nil
    }

    private func mapPoints(
        _ points: [CoordinatePoint],
        in visionBounds: CoordinateRect,
        with mapper: CoordinateMapper
    ) throws -> [CoordinatePoint] {
        try points.map { point in
            guard point.isFinite,
                  (0...1).contains(point.x),
                  (0...1).contains(point.y)
            else {
                throw CoordinateMapper.MappingError.invalidCoordinate
            }

            let visionImagePoint = CoordinatePoint(
                x: visionBounds.x + point.x * visionBounds.width,
                y: visionBounds.y + point.y * visionBounds.height
            )
            let mapped = try mapper.map(
                point: visionImagePoint,
                from: .visionNormalized,
                to: .imageNormalized
            )
            guard mapped.isFinite,
                  (0...1).contains(mapped.x),
                  (0...1).contains(mapped.y)
            else {
                throw CoordinateMapper.MappingError.invalidCoordinate
            }
            return mapped
        }
    }

    private static func makeSupport(
        side: BeautyObservedEyeSide,
        region: VNFaceLandmarkRegion2D?,
        pupil: VNFaceLandmarkRegion2D?
    ) -> BeautyObservedEyeSupport? {
        guard let region, !region.normalizedPoints.isEmpty else {
            return nil
        }

        let contour = region.normalizedPoints.map {
            CoordinatePoint(x: Double($0.x), y: Double($0.y))
        }
        let pupilPoints = pupil?.normalizedPoints.map {
            CoordinatePoint(x: Double($0.x), y: Double($0.y))
        }
        return BeautyObservedEyeSupport(
            side: side,
            contour: contour,
            pupil: pupilPoints?.isEmpty == false ? pupilPoints : nil
        )
    }

    private static func landmarks(
        from landmarks: VNFaceLandmarks2D?
    ) -> (BeautyFaceLandmarks, [BeautyObservedEyeSupport]?) {
        guard let landmarks else {
            return (BeautyFaceLandmarks(availableGroups: []), nil)
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
        if landmarks.innerLips?.pointCount ?? 0 > 0 {
            groups.insert(.innerLips)
        }

        let supports = [
            makeSupport(side: .left, region: landmarks.leftEye, pupil: landmarks.leftPupil),
            makeSupport(side: .right, region: landmarks.rightEye, pupil: landmarks.rightPupil)
        ].compactMap { $0 }
        return (BeautyFaceLandmarks(availableGroups: groups), supports.isEmpty ? nil : supports)
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
            let payload = Self.landmarks(from: observation.landmarks)
            return VisionDetectionObservation(
                stableID: observation.uuid.uuidString,
                confidence: Double(observation.confidence),
                normalizedArea: Double(observation.boundingBox.width * observation.boundingBox.height),
                visionBounds: CoordinateRect(
                    x: Double(observation.boundingBox.origin.x),
                    y: Double(observation.boundingBox.origin.y),
                    width: Double(observation.boundingBox.width),
                    height: Double(observation.boundingBox.height)
                ),
                landmarks: payload.0,
                observedEyeSupport: payload.1
            )
        }
    }
}
