public struct BeautyResult<Output> {
    public let output: Output
    public let warnings: [BeautyValidationWarning]
    public let metrics: [String: Double]
    public let detectionSummary: BeautyDetectionSummary?
    /// Request-local, content-free events gated by `BeautyConfiguration.logLevel`.
    public let diagnostics: [BeautyDiagnosticEvent]

    public init(
        output: Output,
        warnings: [BeautyValidationWarning] = [],
        metrics: [String: Double] = [:],
        detectionSummary: BeautyDetectionSummary? = nil,
        diagnostics: [BeautyDiagnosticEvent] = []
    ) {
        self.output = output
        self.warnings = warnings
        self.metrics = metrics
        self.detectionSummary = detectionSummary
        self.diagnostics = diagnostics
    }
}

extension BeautyResult: Sendable where Output: Sendable {}
