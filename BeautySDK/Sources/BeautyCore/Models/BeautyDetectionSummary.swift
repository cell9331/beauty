public enum DetectionAvailability: String, Codable, Equatable, Sendable {
    case notRun
    case disabled
    case noFace
    case usable
    case partial
    case lowConfidence
    case skipped
    case reused
    case stale
}

public enum DetectionDegradationReason: String, Codable, Equatable, Sendable {
    case noFaceDetected
    case lowConfidenceFace
    case missingLandmarks
    case staleDetection
    case faceLimitApplied
    case detectorUnavailable
    case detectionTimedOut
    case mappingFailed
    case orientationMetadataMissing
}

public struct BeautyDetectionSummary: Codable, Equatable, Sendable {
    public let availability: DetectionAvailability
    public let reasons: [DetectionDegradationReason]
    public let faceCount: Int
    public let usedFaceCount: Int
    public let detectionDurationMs: Double?
    public let mappingDurationMs: Double?

    public init(
        availability: DetectionAvailability,
        reasons: [DetectionDegradationReason] = [],
        faceCount: Int = 0,
        usedFaceCount: Int = 0,
        detectionDurationMs: Double? = nil,
        mappingDurationMs: Double? = nil
    ) {
        self.availability = availability
        self.reasons = reasons
        self.faceCount = max(0, faceCount)
        self.usedFaceCount = max(0, min(usedFaceCount, faceCount))
        self.detectionDurationMs = detectionDurationMs
        self.mappingDurationMs = mappingDurationMs
    }

    public static let notRun = BeautyDetectionSummary(availability: .notRun)
    public static let disabled = BeautyDetectionSummary(availability: .disabled)
    public static let noFace = BeautyDetectionSummary(
        availability: .noFace,
        reasons: [.noFaceDetected]
    )
}
