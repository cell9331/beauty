public struct BeautyResult<Output: Sendable>: Sendable {
    public let output: Output
    public let warnings: [BeautyValidationWarning]
    public let metrics: [String: Double]

    public init(
        output: Output,
        warnings: [BeautyValidationWarning] = [],
        metrics: [String: Double] = [:]
    ) {
        self.output = output
        self.warnings = warnings
        self.metrics = metrics
    }
}
