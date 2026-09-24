import BeautyCore
import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import Vision

enum EyebrowPreflight {
    static let maximumPointCount = 16
    static let minimumPointCount = 1

    static func accepts(pointCount: Int, isOpenPath: Bool) -> Bool {
        isOpenPath && (minimumPointCount...maximumPointCount).contains(pointCount)
    }
}

package enum LipRegionPreflight {
    package static let maximumPointCount = 32
    package static let minimumPointCount = 1

    package static func accepts(pointCount: Int) -> Bool {
        (minimumPointCount...maximumPointCount).contains(pointCount)
    }
}

package struct VisionDetectionObservation: Equatable, Sendable {
    package let stableID: String?
    package let confidence: Double
    package let normalizedArea: Double
    package let visionBounds: CoordinateRect?
    package let landmarks: BeautyFaceLandmarks
    package let observedEyeSupport: [BeautyObservedEyeSupport]?
    package let observedFaceSupport: BeautyObservedFaceSupport?
    package let observedEyebrowSupport: BeautyObservedEyebrowSupport?
    package let observedLipSupport: BeautyObservedLipSupport?
    package let observedNoseSupport: BeautyObservedNoseSupport?

    package init(
        stableID: String? = nil,
        confidence: Double = 1,
        normalizedArea: Double = 0,
        visionBounds: CoordinateRect? = nil,
        landmarks: BeautyFaceLandmarks = .complete,
        observedEyeSupport: [BeautyObservedEyeSupport]? = nil,
        observedFaceSupport: BeautyObservedFaceSupport? = nil,
        observedEyebrowSupport: BeautyObservedEyebrowSupport? = nil,
        observedLipSupport: BeautyObservedLipSupport? = nil,
        observedNoseSupport: BeautyObservedNoseSupport? = nil
    ) {
        self.stableID = stableID
        self.confidence = confidence
        self.normalizedArea = visionBounds?.area ?? max(0, normalizedArea)
        self.visionBounds = visionBounds
        self.landmarks = landmarks
        self.observedEyeSupport = observedEyeSupport
        self.observedFaceSupport = observedFaceSupport
        self.observedEyebrowSupport = observedEyebrowSupport
        self.observedLipSupport = observedLipSupport
        self.observedNoseSupport = observedNoseSupport
    }
}

extension VisionDetectionObservation: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "VisionDetectionObservation("
            + "landmarkGroupCount: \(landmarks.availableGroups.count), "
            + "observedEyeSupportCount: \(observedEyeSupport?.count ?? 0), "
            + "observedFaceSupportAvailable: \(observedFaceSupport != nil), "
            + "observedFaceContourCount: \(observedFaceSupport?.contour?.count ?? 0), "
            + "observedFaceMedianLineCount: \(observedFaceSupport?.medianLine?.count ?? 0), "
            + "observedEyebrowSupportAvailable: \(observedEyebrowSupport != nil), "
            + "observedLeftEyebrowCount: \(observedEyebrowSupport?.left?.count ?? 0), "
            + "observedRightEyebrowCount: \(observedEyebrowSupport?.right?.count ?? 0), "
            + "observedOuterLipCount: \(observedLipSupport?.outer?.count ?? 0), "
            + "observedInnerLipCount: \(observedLipSupport?.inner?.count ?? 0))"
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
                "observedOuterLipCount": observedLipSupport?.outer?.count ?? 0,
                "observedInnerLipCount": observedLipSupport?.inner?.count ?? 0,
            ],
            displayStyle: .struct
        )
    }
}

package struct VisionFaceDetectionResult: Equatable, Sendable {
    package let observations: [BeautyFaceObservation]
    package let summary: BeautyDetectionSummary
}

package struct VisionFaceDetectionWithUpperEyelidSupportResult: Equatable, Sendable {
    package let detectionSummary: BeautyDetectionSummary
    package let selectedObservationID: String?
    package let supportResolution: BeautyUpperEyelidSupportResolution

    package init(
        detectionSummary: BeautyDetectionSummary,
        selectedObservationID: String?,
        supportResolution: BeautyUpperEyelidSupportResolution
    ) {
        self.detectionSummary = detectionSummary
        self.selectedObservationID = selectedObservationID
        self.supportResolution = supportResolution
    }

    package var summary: BeautyDetectionSummary { detectionSummary }
    package var resolution: BeautyUpperEyelidSupportResolution { supportResolution }
}

extension VisionFaceDetectionWithUpperEyelidSupportResult: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "VisionFaceDetectionWithUpperEyelidSupportResult("
            + "availability: \(detectionSummary.availability.rawValue), "
            + "faceCount: \(detectionSummary.faceCount), "
            + "usedFaceCount: \(detectionSummary.usedFaceCount), "
            + "selectedObservationAvailable: \(selectedObservationID != nil), "
            + "supportedEyeCount: \(supportResolution.supportedEyeCount))"
    }

    package var debugDescription: String { description }

    package var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "availability": detectionSummary.availability.rawValue,
                "faceCount": detectionSummary.faceCount,
                "usedFaceCount": detectionSummary.usedFaceCount,
                "selectedObservationAvailable": selectedObservationID != nil,
                "supportedEyeCount": supportResolution.supportedEyeCount,
            ],
            displayStyle: .struct
        )
    }
}

package struct VisionFaceDetectionInput: @unchecked Sendable {
    package let metadata: BeautyInputMetadata
    package let imageExtent: CGSize
    package let previewExtent: CGSize?
    package let stillImage: CIImage?
    package let maximumPixelCount: Int

    package init(
        metadata: BeautyInputMetadata,
        imageExtent: CGSize,
        previewExtent: CGSize? = nil,
        stillImage: CIImage? = nil,
        maximumPixelCount: Int = BeautyConfiguration.default.maximumInputPixelCount
    ) {
        self.metadata = metadata
        self.imageExtent = imageExtent
        self.previewExtent = previewExtent
        self.stillImage = stillImage
        self.maximumPixelCount = maximumPixelCount
    }
}

package struct VisionFaceDetector: Sendable {
    package enum DetectionPurpose: Sendable {
        case geometry
        case localSupport
        case geometryAndLocalSupport
    }

    package enum Failure: Error, Equatable, Sendable {
        case detectorUnavailable
        case detectionTimedOut
    }

    package enum MappingEvent: Sendable {
        case requestStarted
        case lipRegionMapped(slot: Int, pointCount: Int)
        case requestFinished
    }

    package typealias ObservationProvider = @Sendable (VisionFaceDetectionInput) throws -> [VisionDetectionObservation]
    package typealias MappingObserver = @Sendable (MappingEvent) -> Void

    private let minimumConfidence: Double
    private let observationProvider: ObservationProvider
    private let mappingObserver: MappingObserver?
    private var selectionPolicy: FaceSelectionPolicy

    package init(
        minimumConfidence: Double = 0.5,
        observationProvider: @escaping ObservationProvider = VisionFaceDetector.defaultObservationProvider,
        mappingObserver: MappingObserver? = nil
    ) {
        self.minimumConfidence = minimumConfidence
        self.observationProvider = observationProvider
        self.mappingObserver = mappingObserver
        self.selectionPolicy = FaceSelectionPolicy()
    }

    package mutating func detect(
        metadata: BeautyInputMetadata,
        imageExtent: CGSize = CGSize(width: 1, height: 1),
        previewExtent: CGSize? = nil,
        configuration: BeautyConfiguration = .default,
        purpose: DetectionPurpose = .geometry
    ) -> VisionFaceDetectionResult {
        detect(
            image: nil,
            metadata: metadata,
            imageExtent: imageExtent,
            previewExtent: previewExtent,
            configuration: configuration,
            purpose: purpose
        )
    }

    package mutating func detect(
        image: CIImage?,
        metadata: BeautyInputMetadata,
        imageExtent: CGSize = CGSize(width: 1, height: 1),
        previewExtent: CGSize? = nil,
        configuration: BeautyConfiguration = .default,
        purpose: DetectionPurpose = .geometry
    ) -> VisionFaceDetectionResult {
        mappingObserver?(.requestStarted)
        defer { mappingObserver?(.requestFinished) }

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
                    stillImage: image,
                    maximumPixelCount: configuration.maximumInputPixelCount
                )
            )
            return summarize(
                observations,
                metadata: metadata,
                imageExtent: imageExtent,
                previewExtent: previewExtent,
                configuration: configuration,
                purpose: purpose
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

    package mutating func detectWithUpperEyelidSupport(
        image: CIImage?,
        metadata: BeautyInputMetadata,
        imageExtent: CGSize = CGSize(width: 1, height: 1),
        previewExtent: CGSize? = nil,
        configuration: BeautyConfiguration = .default,
        semanticOwner: BeautyUpperEyelidSemanticSupportOwner.SemanticOwner? = nil
    ) -> VisionFaceDetectionWithUpperEyelidSupportResult {
        let detection = detect(
            image: image,
            metadata: metadata,
            imageExtent: imageExtent,
            previewExtent: previewExtent,
            configuration: configuration,
            purpose: .localSupport
        )
        guard let observation = detection.observations.first,
              let dimensions = imageDimensions(imageExtent)
        else {
            return VisionFaceDetectionWithUpperEyelidSupportResult(
                detectionSummary: detection.summary,
                selectedObservationID: nil,
                supportResolution: BeautyUpperEyelidSupportResolution(
                    left: .sourceExactNoOp(side: .left, confidence: 0, reason: .missingEyeEnvelope),
                    right: .sourceExactNoOp(side: .right, confidence: 0, reason: .missingEyeEnvelope)
                )
            )
        }

        let supportResolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation,
            imageWidth: dimensions.width,
            imageHeight: dimensions.height,
            semanticOwner: semanticOwner
        )
        return VisionFaceDetectionWithUpperEyelidSupportResult(
            detectionSummary: detection.summary,
            selectedObservationID: observation.stableID,
            supportResolution: supportResolution
        )
    }

    package mutating func resetTracking() {
        selectionPolicy.reset()
    }

    private mutating func summarize(
        _ detections: [VisionDetectionObservation],
        metadata: BeautyInputMetadata,
        imageExtent: CGSize,
        previewExtent: CGSize?,
        configuration: BeautyConfiguration,
        purpose: DetectionPurpose
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

        let confidenceEligible = detections.filter { detection in
            detection.confidence >= minimumConfidence
        }
        let usableDetections = confidenceEligible.filter { detection in
            switch purpose {
            case .geometry:
                detection.landmarks.hasRequiredGeometry
            case .localSupport, .geometryAndLocalSupport:
                true
            }
        }

        guard !usableDetections.isEmpty else {
            selectionPolicy.reset()
            return VisionFaceDetectionResult(
                observations: [],
                summary: degradedSummary(for: detections, purpose: purpose)
            )
        }

        let mapper = CoordinateMapper(
            metadata: metadata,
            imageExtent: imageExtent,
            previewExtent: previewExtent
        )
        var observations: [BeautyFaceObservation] = []
        observations.reserveCapacity(usableDetections.count)
        var mappingFailed = false
        for detection in usableDetections {
            do {
                observations.append(try mapObservation(detection, mapper: mapper))
            } catch {
                // A rejected observation cannot invalidate a separately
                // mapped face. Keep support and selection request-local.
                mappingFailed = true
            }
        }
        guard !observations.isEmpty else {
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
        let selectedSummary = purposeAwareSummary(
            selection.summary,
            selectedFaces: selection.selectedFaces,
            purpose: purpose
        )
        guard mappingFailed else {
            return VisionFaceDetectionResult(
                observations: selection.selectedFaces,
                summary: selectedSummary
            )
        }
        var reasons = selectedSummary.reasons
        if !reasons.contains(.mappingFailed) {
            reasons.append(.mappingFailed)
        }
        return VisionFaceDetectionResult(
            observations: selection.selectedFaces,
            summary: BeautyDetectionSummary(
                availability: .partial,
                reasons: reasons,
                faceCount: usableDetections.count,
                usedFaceCount: selectedSummary.usedFaceCount,
                detectionDurationMs: selectedSummary.detectionDurationMs,
                mappingDurationMs: selectedSummary.mappingDurationMs
            )
        )
    }

    private func purposeAwareSummary(
        _ summary: BeautyDetectionSummary,
        selectedFaces: [BeautyFaceObservation],
        purpose: DetectionPurpose
    ) -> BeautyDetectionSummary {
        guard purpose == .geometryAndLocalSupport,
              selectedFaces.contains(where: { $0.landmarks.hasRequiredGeometry == false })
        else {
            return summary
        }

        var reasons = summary.reasons
        if reasons.contains(.missingLandmarks) == false {
            reasons.append(.missingLandmarks)
        }
        return BeautyDetectionSummary(
            availability: .partial,
            reasons: reasons,
            faceCount: summary.faceCount,
            usedFaceCount: summary.usedFaceCount,
            detectionDurationMs: summary.detectionDurationMs,
            mappingDurationMs: summary.mappingDurationMs
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

            let hasUnambiguousDeclaredSides = (1...2).contains(supports.count)
                && Set(supports.map(\.side)).count == supports.count
            observedEyeSupport = supports.compactMap { support in
                do {
                    return BeautyObservedEyeSupport(
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
                } catch is CoordinateMapper.MappingError {
                    // Eye support is region-local. A malformed side must not
                    // discard a valid peer eye or unrelated mapped lip work.
                    return nil
                } catch {
                    return nil
                }
            }
            observedEyeOrder = hasUnambiguousDeclaredSides
                ? deriveEyeOrder(
                    observedEyeSupport ?? [],
                    visionBounds: visionBounds,
                    mapper: mapper
                )
                : .invalid
        } else {
            observedEyeSupport = nil
            observedEyeOrder = nil
        }

        let observedFaceSupport: BeautyObservedFaceSupport?
        if let support = detection.observedFaceSupport {
            guard let visionBounds = detection.visionBounds,
                  visionBounds.isFinite,
                  visionBounds.width > 0,
                  visionBounds.height > 0
            else {
                throw CoordinateMapper.MappingError.invalidCoordinate
            }

            let axes = try mappedFaceAxes(
                in: visionBounds,
                with: mapper
            )
            let contour = mapFaceRegion(
                support.contour,
                maximumPointCount: 32,
                canonicalAxis: axes.right,
                in: visionBounds,
                with: mapper
            )
            let medianLine = mapFaceRegion(
                support.medianLine,
                maximumPointCount: 16,
                canonicalAxis: axes.down,
                in: visionBounds,
                with: mapper
            )
            observedFaceSupport = contour != nil || medianLine != nil
                ? BeautyObservedFaceSupport(contour: contour, medianLine: medianLine)
                : nil
        } else {
            observedFaceSupport = nil
        }

        let observedEyebrowSupport: BeautyObservedEyebrowSupport?
        if let support = detection.observedEyebrowSupport {
            guard let visionBounds = detection.visionBounds,
                  visionBounds.isFinite,
                  visionBounds.width > 0,
                  visionBounds.height > 0
            else {
                throw CoordinateMapper.MappingError.invalidCoordinate
            }

            let axes = try mappedFaceCenterAndAxes(
                in: visionBounds,
                with: mapper
            )
            observedEyebrowSupport = try mapEyebrowSupport(
                support,
                faceCenter: axes.center,
                rightAxis: axes.right,
                in: visionBounds,
                with: mapper
            )
        } else {
            observedEyebrowSupport = nil
        }

        let observedLipSupport: BeautyObservedLipSupport?
        if let support = detection.observedLipSupport,
           let visionBounds = detection.visionBounds,
           visionBounds.isFinite,
           visionBounds.width > 0,
           visionBounds.height > 0 {
            let outer = mapLipRegion(
                support.outer,
                slot: 0,
                in: visionBounds,
                with: mapper
            )
            let inner = mapLipRegion(
                support.inner,
                slot: 1,
                in: visionBounds,
                with: mapper
            )
            observedLipSupport = BeautyObservedLipSupport(outer: outer ?? [], inner: inner ?? [])
        } else {
            observedLipSupport = nil
        }

        let observedNoseSupport: BeautyObservedNoseSupport?
        if let raw = detection.observedNoseSupport, let bounds = detection.visionBounds {
            let crest = raw.crest.count <= 32 ? (try? mapPoints(raw.crest, in: bounds, with: mapper)) : nil
            let contour = raw.contour.count <= 32 ? (try? mapPoints(raw.contour, in: bounds, with: mapper)) : nil
            observedNoseSupport = BeautyObservedNoseSupport(crest: crest ?? [], contour: contour ?? [])
        } else { observedNoseSupport = nil }

        return BeautyFaceObservation(
                stableID: detection.stableID,
                confidence: detection.confidence,
                normalizedArea: detection.normalizedArea,
                imageBounds: imageBounds,
                landmarks: detection.landmarks,
                observedEyeSupport: observedEyeSupport,
                observedEyeOrder: observedEyeOrder,
                observedFaceSupport: observedFaceSupport,
                observedEyebrowSupport: observedEyebrowSupport,
                observedLipSupport: observedLipSupport,
                observedNoseSupport: observedNoseSupport
            )
    }

    private func deriveEyeOrder(
        _ supports: [BeautyObservedEyeSupport],
        visionBounds: CoordinateRect,
        mapper: CoordinateMapper
    ) -> BeautyObservedEyeOrder {
        guard (1...2).contains(supports.count),
              Set(supports.map(\.side)).count == supports.count,
              let axes = try? mappedFaceCenterAndAxes(
                  in: visionBounds,
                  with: mapper
              )
        else {
            return .invalid
        }

        for support in supports {
            guard let center = centroid(support.contour) else {
                return .invalid
            }
            let offset = SIMD2<Double>(
                center.x - axes.center.x,
                center.y - axes.center.y
            )
            let projection = offset.x * axes.right.x + offset.y * axes.right.y
            let expectedSign: Double = support.side == .left ? -1 : 1
            guard projection.isFinite,
                  abs(projection) > 0.000_001,
                  (projection > 0) == (expectedSign > 0)
            else {
                return .invalid
            }
        }

        return .canonical
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

    private func mapFaceRegion(
        _ points: [CoordinatePoint]?,
        maximumPointCount: Int,
        canonicalAxis: SIMD2<Double>,
        in visionBounds: CoordinateRect,
        with mapper: CoordinateMapper
    ) -> [CoordinatePoint]? {
        guard let points,
              !points.isEmpty,
              points.count <= maximumPointCount,
              points.allSatisfy({
                  $0.isFinite
                      && (0...1).contains($0.x)
                      && (0...1).contains($0.y)
              })
        else {
            return nil
        }

        guard let mapped = try? mapPoints(points, in: visionBounds, with: mapper),
              let first = mapped.first,
              let last = mapped.last
        else {
            return nil
        }
        let direction = SIMD2<Double>(
            last.x - first.x,
            last.y - first.y
        )
        let projection = direction.x * canonicalAxis.x + direction.y * canonicalAxis.y
        guard projection.isFinite, abs(projection) > 0.000_001 else {
            return nil
        }
        return projection > 0 ? mapped : Array(mapped.reversed())
    }

    private func mapLipRegion(
        _ points: [CoordinatePoint]?,
        slot: Int,
        in visionBounds: CoordinateRect,
        with mapper: CoordinateMapper
    ) -> [CoordinatePoint]? {
        guard let points,
              LipRegionPreflight.accepts(pointCount: points.count),
              points.allSatisfy({
                  $0.isFinite
                      && (0...1).contains($0.x)
                      && (0...1).contains($0.y)
              })
        else {
            return nil
        }

        guard let mapped = try? mapPoints(points, in: visionBounds, with: mapper) else {
            return nil
        }
        mappingObserver?(.lipRegionMapped(slot: slot, pointCount: mapped.count))
        return mapped
    }

    private func mappedFaceAxes(
        in visionBounds: CoordinateRect,
        with mapper: CoordinateMapper
    ) throws -> (right: SIMD2<Double>, down: SIMD2<Double>) {
        let bottomLeft = try mapper.map(
            point: CoordinatePoint(x: visionBounds.minX, y: visionBounds.minY),
            from: .visionNormalized,
            to: .imageNormalized
        )
        let bottomRight = try mapper.map(
            point: CoordinatePoint(x: visionBounds.maxX, y: visionBounds.minY),
            from: .visionNormalized,
            to: .imageNormalized
        )
        let topLeft = try mapper.map(
            point: CoordinatePoint(x: visionBounds.minX, y: visionBounds.maxY),
            from: .visionNormalized,
            to: .imageNormalized
        )

        let right = try normalizedAxis(
            from: bottomLeft,
            to: bottomRight
        )
        let down = try normalizedAxis(
            from: topLeft,
            to: bottomLeft
        )
        return (right, down)
    }

    private func mappedFaceCenterAndAxes(
        in visionBounds: CoordinateRect,
        with mapper: CoordinateMapper
    ) throws -> (center: CoordinatePoint, right: SIMD2<Double>, down: SIMD2<Double>) {
        let bottomLeft = try mapper.map(
            point: CoordinatePoint(x: visionBounds.minX, y: visionBounds.minY),
            from: .visionNormalized,
            to: .imageNormalized
        )
        let bottomRight = try mapper.map(
            point: CoordinatePoint(x: visionBounds.maxX, y: visionBounds.minY),
            from: .visionNormalized,
            to: .imageNormalized
        )
        let topLeft = try mapper.map(
            point: CoordinatePoint(x: visionBounds.minX, y: visionBounds.maxY),
            from: .visionNormalized,
            to: .imageNormalized
        )
        let topRight = try mapper.map(
            point: CoordinatePoint(x: visionBounds.maxX, y: visionBounds.maxY),
            from: .visionNormalized,
            to: .imageNormalized
        )

        let right = try normalizedAxis(
            from: bottomLeft,
            to: bottomRight
        )
        let down = try normalizedAxis(
            from: topLeft,
            to: bottomLeft
        )
        let center = CoordinatePoint(
            x: (bottomLeft.x + bottomRight.x + topLeft.x + topRight.x) / 4,
            y: (bottomLeft.y + bottomRight.y + topLeft.y + topRight.y) / 4
        )
        return (center, right, down)
    }

    private func mapEyebrowSupport(
        _ support: BeautyObservedEyebrowSupport,
        faceCenter: CoordinatePoint,
        rightAxis: SIMD2<Double>,
        in visionBounds: CoordinateRect,
        with mapper: CoordinateMapper
    ) throws -> BeautyObservedEyebrowSupport {
        let left = try mapEyebrowSide(
            support.left,
            declaredSide: .left,
            faceCenter: faceCenter,
            rightAxis: rightAxis,
            in: visionBounds,
            with: mapper
        )
        let right = try mapEyebrowSide(
            support.right,
            declaredSide: .right,
            faceCenter: faceCenter,
            rightAxis: rightAxis,
            in: visionBounds,
            with: mapper
        )
        return BeautyObservedEyebrowSupport(left: left, right: right)
    }

    private func mapEyebrowSide(
        _ points: [CoordinatePoint]?,
        declaredSide: BeautyObservedEyebrowSide,
        faceCenter: CoordinatePoint,
        rightAxis: SIMD2<Double>,
        in visionBounds: CoordinateRect,
        with mapper: CoordinateMapper
    ) throws -> [CoordinatePoint]? {
        guard let points, !points.isEmpty else { return nil }

        let mapped = try mapPoints(points, in: visionBounds, with: mapper)

        let centroidX = mapped.reduce(0.0) { $0 + $1.x } / Double(mapped.count)
        let centroidY = mapped.reduce(0.0) { $0 + $1.y } / Double(mapped.count)
        let centroidOffset = SIMD2<Double>(
            centroidX - faceCenter.x,
            centroidY - faceCenter.y
        )
        let centroidProjection = centroidOffset.x * rightAxis.x + centroidOffset.y * rightAxis.y
        guard centroidProjection.isFinite, abs(centroidProjection) > 0.000_001 else {
            return nil
        }

        let expectedSign: Double = declaredSide == .left ? -1 : 1
        let sideMatches = (centroidProjection > 0) == (expectedSign > 0)

        if mapped.count < 2 {
            return sideMatches ? mapped : nil
        }
        guard sideMatches else { return nil }

        // Vision eyebrow regions are open, but their first and last samples
        // can be adjacent points at the same anatomical end of a thick brow
        // outline. Canonicalize every accepted sample by its projection onto
        // the mapped face-right axis instead of treating provider endpoint
        // order as an inner-to-outer centerline contract.
        let projected = mapped.enumerated().map { index, point in
            (
                index: index,
                point: point,
                projection: point.x * rightAxis.x + point.y * rightAxis.y
            )
        }
        guard projected.allSatisfy({ $0.projection.isFinite }) else {
            return nil
        }
        guard let minimumProjection = projected.map(\.projection).min(),
              let maximumProjection = projected.map(\.projection).max(),
              maximumProjection - minimumProjection > 0.000_001
        else {
            return nil
        }
        return projected.sorted { lhs, rhs in
            if lhs.projection != rhs.projection {
                return declaredSide == .left
                    ? lhs.projection > rhs.projection
                    : lhs.projection < rhs.projection
            }
            return lhs.index < rhs.index
        }.map(\.point)
    }

    private func normalizedAxis(
        from start: CoordinatePoint,
        to end: CoordinatePoint
    ) throws -> SIMD2<Double> {
        let axis = SIMD2<Double>(
            end.x - start.x,
            end.y - start.y
        )
        let length = hypot(axis.x, axis.y)
        guard axis.x.isFinite,
              axis.y.isFinite,
              length.isFinite,
              length > 0.000_001
        else {
            throw CoordinateMapper.MappingError.invalidCoordinate
        }
        return axis / length
    }

    private func imageDimensions(_ extent: CGSize) -> (width: Int, height: Int)? {
        guard extent.width.isFinite,
              extent.height.isFinite,
              extent.width >= 1,
              extent.height >= 1,
              extent.width <= Double(Int.max),
              extent.height <= Double(Int.max)
        else {
            return nil
        }
        let width = Int(extent.width)
        let height = Int(extent.height)
        guard Double(width) == extent.width,
              Double(height) == extent.height
        else {
            return nil
        }
        return (width, height)
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

    private static func makeEyebrowTrace(
        from region: VNFaceLandmarkRegion2D?
    ) -> [CoordinatePoint]? {
        guard let region else { return nil }
        guard EyebrowPreflight.accepts(
            pointCount: region.pointCount,
            isOpenPath: region.pointsClassification == .openPath
        ) else {
            return nil
        }
        return region.normalizedPoints.map {
            CoordinatePoint(x: Double($0.x), y: Double($0.y))
        }
    }

    private static func landmarks(
        from landmarks: VNFaceLandmarks2D?
    ) -> (
        landmarks: BeautyFaceLandmarks,
        observedEyeSupport: [BeautyObservedEyeSupport]?,
        observedFaceSupport: BeautyObservedFaceSupport?,
        observedEyebrowSupport: BeautyObservedEyebrowSupport?,
        observedLipSupport: BeautyObservedLipSupport?,
        observedNoseSupport: BeautyObservedNoseSupport?
    ) {
        guard let landmarks else {
            return (BeautyFaceLandmarks(availableGroups: []), nil, nil, nil, nil, nil)
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
        let contour = makePoints(from: landmarks.faceContour)
        let medianLine = makePoints(from: landmarks.medianLine)
        let faceSupport = contour != nil || medianLine != nil
            ? BeautyObservedFaceSupport(contour: contour, medianLine: medianLine)
            : nil
        let leftBrow = makeEyebrowTrace(from: landmarks.leftEyebrow)
        let rightBrow = makeEyebrowTrace(from: landmarks.rightEyebrow)
        let eyebrowSupport = leftBrow != nil || rightBrow != nil
            ? BeautyObservedEyebrowSupport(left: leftBrow, right: rightBrow)
            : nil
        let outerLips = makePoints(from: landmarks.outerLips)
        let innerLips = makePoints(from: landmarks.innerLips)
        let lipSupport = BeautyObservedLipSupport(outer: outerLips ?? [], inner: innerLips ?? [])
        return (
            BeautyFaceLandmarks(availableGroups: groups),
            supports.isEmpty ? nil : supports,
            faceSupport,
            eyebrowSupport,
            lipSupport,
            BeautyObservedNoseSupport(crest: makePoints(from: landmarks.noseCrest) ?? [],
                                      contour: makePoints(from: landmarks.nose) ?? [])
        )
    }

    private static func makePoints(from region: VNFaceLandmarkRegion2D?) -> [CoordinatePoint]? {
        guard let region, !region.normalizedPoints.isEmpty else {
            return nil
        }
        return region.normalizedPoints.map {
            CoordinatePoint(x: Double($0.x), y: Double($0.y))
        }
    }

    private func degradedSummary(
        for detections: [VisionDetectionObservation],
        purpose: DetectionPurpose
    ) -> BeautyDetectionSummary {
        if purpose != .geometry {
            return BeautyDetectionSummary(
                availability: .lowConfidence,
                reasons: [.lowConfidenceFace],
                faceCount: detections.count,
                usedFaceCount: 0
            )
        }

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

    // Detection and source-only image validation must inspect the same rendered
    // RGB image. Letting Vision render the lazy CIImage chooses a different
    // color-conversion path and can move an anatomical ownership boundary.
    // This is only the Vision input: the raw facade's output and metadata policy
    // remain unchanged, including orientation handling in CoordinateMapper.
    static func canonicalStillImageInput(
        _ input: VisionFaceDetectionInput
    ) throws -> (image: CGImage, orientation: CGImagePropertyOrientation) {
        guard let image = input.stillImage,
              image.extent.origin.x.isFinite, image.extent.origin.y.isFinite,
              image.extent.width.isFinite, image.extent.height.isFinite,
              image.extent.width > 0, image.extent.height > 0,
              image.extent == image.extent.integral,
              input.imageExtent == image.extent.size,
              input.maximumPixelCount > 0,
              image.extent.width <= CGFloat(input.maximumPixelCount) / image.extent.height,
              let sRGB = CGColorSpace(name: CGColorSpace.sRGB)
        else {
            throw Failure.detectorUnavailable
        }
        let context = CIContext(options: [
            .workingColorSpace: sRGB,
            .outputColorSpace: sRGB,
        ])
        guard let raster = context.createCGImage(image, from: image.extent) else {
            throw Failure.detectorUnavailable
        }
        // Do not orient or mirror pixels here: Vision and the existing mapper
        // still receive the caller's original orientation and mirror metadata.
        return (raster, input.metadata.orientation)
    }

    private static func defaultObservationProvider(_ input: VisionFaceDetectionInput) throws -> [VisionDetectionObservation] {
        let raster = try canonicalStillImageInput(input)
        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(
            cgImage: raster.image,
            orientation: raster.orientation,
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
                landmarks: payload.landmarks,
                observedEyeSupport: payload.observedEyeSupport,
                observedFaceSupport: payload.observedFaceSupport,
                observedEyebrowSupport: payload.observedEyebrowSupport,
                observedLipSupport: payload.observedLipSupport,
                observedNoseSupport: payload.observedNoseSupport
            )
        }
    }
}
