import BeautyCore
import BeautyEffects

/// Package-only selection result for the public engine's immutable backend policy.
package struct BeautyBackendSelection {
    package let executor: BeautyBackendExecutor
    package let policy: BeautyBackendExecutionPolicy

    package init(
        executor: BeautyBackendExecutor,
        policy: BeautyBackendExecutionPolicy
    ) {
        self.executor = executor
        self.policy = policy
    }
}

/// Maps the closed public configuration choice to exactly one package executor.
///
/// Metal construction errors are intentionally not translated or retried. The
/// package-only factory seam exists only for deterministic tests of terminal
/// availability behavior.
package enum BeautyBackendFactory {
    package typealias MetalFactory = @Sendable (Int) throws -> BeautyBackendExecutor

    package static func select(
        configuration: BeautyConfiguration,
        metalFactory: MetalFactory = { maximumPixelCount in
            try BeautyMetalBackend(maximumPixelCount: maximumPixelCount)
        }
    ) throws -> BeautyBackendSelection {
        switch configuration.renderBackend {
        case .cpu:
            return BeautyBackendSelection(
                executor: BeautyCPUBackend(),
                policy: .cpu
            )
        case .gpu:
            return BeautyBackendSelection(
                executor: try metalFactory(configuration.maximumInputPixelCount),
                policy: .metal
            )
        }
    }
}
