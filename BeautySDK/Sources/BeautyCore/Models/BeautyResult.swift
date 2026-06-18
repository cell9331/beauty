public struct BeautyResult<Output: Sendable>: Sendable {
    public let output: Output
    public let warnings: [BeautyValidationWarning]
    public let metrics: [String: Double]
    public let detectionSummary: BeautyDetectionSummary?

    public init(
        output: Output,
        warnings: [BeautyValidationWarning] = [],
        metrics: [String: Double] = [:],
        detectionSummary: BeautyDetectionSummary? = nil
    ) {
        self.output = output
        self.warnings = warnings
        self.metrics = metrics
        self.detectionSummary = detectionSummary
    }
}
