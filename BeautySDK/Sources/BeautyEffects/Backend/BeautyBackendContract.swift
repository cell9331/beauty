import BeautyCore
import BeautyDetection
import CoreImage
import CoreVideo

/// The execution policy understood by the Phase-70 contract.
///
/// Backend choice is intentionally kept out of `BeautyParameters`, presets, and
/// the public configuration surface. Later policies can be added behind this
/// package-only boundary after their own availability and parity contracts land.
package enum BeautyBackendExecutionPolicy: Equatable, Sendable {
    case cpu
    case metal
}

package enum BeautyBackendInputKind: Equatable, Sendable {
    case pixelBuffer
    case stillImage
}

/// Request-local input admitted to a backend. Neither case has a persistent or
/// diagnostic representation; support and raster lifetimes end with the request.
package enum BeautyBackendInput: @unchecked Sendable {
    case pixelBuffer(CVPixelBuffer)
    case stillImage(CIImage)

    package var kind: BeautyBackendInputKind {
        switch self {
        case .pixelBuffer:
            .pixelBuffer
        case .stillImage:
            .stillImage
        }
    }
}

package enum BeautyBackendOutput: @unchecked Sendable {
    case pixelBuffer(CVPixelBuffer)
    case stillImage(CIImage)

    package var kind: BeautyBackendInputKind {
        switch self {
        case .pixelBuffer:
            .pixelBuffer
        case .stillImage:
            .stillImage
        }
    }
}

/// Fixed, bounded counters allowed to cross the backend result boundary.
///
/// Raw support, pixel data, masks, geometry, paths, and framework diagnostics
/// are deliberately absent. Values are validated against the request before a
/// result is accepted.
package struct BeautyBackendDiagnostics: Equatable, Sendable {
    package let width: Int
    package let height: Int
    package let preservesAlpha: Bool
    package let preservesExtent: Bool
    package let unitCount: Int
    package let failureCount: Int
    package let collisionCount: Int
    package let changedPixelCount: Int

    package init(
        width: Int,
        height: Int,
        preservesAlpha: Bool,
        preservesExtent: Bool,
        unitCount: Int = 0,
        failureCount: Int = 0,
        collisionCount: Int = 0,
        changedPixelCount: Int = 0
    ) {
        self.width = width
        self.height = height
        self.preservesAlpha = preservesAlpha
        self.preservesExtent = preservesExtent
        self.unitCount = unitCount
        self.failureCount = failureCount
        self.collisionCount = collisionCount
        self.changedPixelCount = changedPixelCount
    }
}

/// One validated, backend-neutral execution request.
///
/// `selectedFaceSupport`, `canonicalImage`, and `compositionSummary` are
/// request-local values. The contract admits them only so all backends consume
/// the same support and composition semantics; none is retained by a result.
package struct BeautyBackendRequest: @unchecked Sendable {
    package let policy: BeautyBackendExecutionPolicy
    package let input: BeautyBackendInput
    package let metadata: BeautyInputMetadata
    package let plan: BeautyEffectPlan
    package let selectedFaceSupport: BeautyFaceObservation?
    package let canonicalImage: BeautyCanonicalStillImage?
    package let compositionSummary: BeautyLocalRetouchCompositionSummary?

    package init(
        policy: BeautyBackendExecutionPolicy = .cpu,
        input: BeautyBackendInput,
        metadata: BeautyInputMetadata,
        plan: BeautyEffectPlan,
        selectedFaceSupport: BeautyFaceObservation? = nil,
        canonicalImage: BeautyCanonicalStillImage? = nil,
        compositionSummary: BeautyLocalRetouchCompositionSummary? = nil
    ) throws {
        guard policy == .cpu || policy == .metal else {
            throw BeautyError.invalidInput
        }

        try Self.validate(
            input: input,
            metadata: metadata,
            plan: plan,
            canonicalImage: canonicalImage,
            compositionSummary: compositionSummary
        )

        self.policy = policy
        self.input = input
        self.metadata = metadata
        self.plan = plan
        self.selectedFaceSupport = selectedFaceSupport
        self.canonicalImage = canonicalImage
        self.compositionSummary = compositionSummary
    }

    package var inputKind: BeautyBackendInputKind {
        input.kind
    }

    private static func validate(
        input: BeautyBackendInput,
        metadata: BeautyInputMetadata,
        plan: BeautyEffectPlan,
        canonicalImage: BeautyCanonicalStillImage?,
        compositionSummary: BeautyLocalRetouchCompositionSummary?
    ) throws {
        guard metadata.orientation == .up,
              metadata.isInputMirrored == false,
              normalized(plan)
        else {
            throw BeautyError.invalidInput
        }

        let dimensions: (width: Int, height: Int)
        switch input {
        case .pixelBuffer(let pixelBuffer):
            guard canonicalImage == nil,
                  compositionSummary == nil,
                  CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA
            else {
                throw BeautyError.unsupportedPixelFormat
            }
            dimensions = (
                width: CVPixelBufferGetWidth(pixelBuffer),
                height: CVPixelBufferGetHeight(pixelBuffer)
            )
        case .stillImage(let image):
            guard canonicalImage == nil || canonicalImage?.metadata == metadata else {
                throw BeautyError.invalidInput
            }
            guard let extentDimensions = checkedDimensions(for: image.extent) else {
                throw BeautyError.invalidInput
            }
            dimensions = extentDimensions

            if let canonicalImage {
                guard canonicalImage.width == extentDimensions.width,
                      canonicalImage.height == extentDimensions.height,
                      canonicalImage.rowBytes == canonicalImage.width * 4,
                      canonicalImage.metadata.orientation == .up,
                      canonicalImage.metadata.isInputMirrored == false,
                      image.extent.origin == .zero
                else {
                    throw BeautyError.invalidInput
                }
            }
        }

        guard dimensions.width > 0,
              dimensions.height > 0,
              dimensions.width <= BeautyConfiguration.defaultMaximumInputPixelCount,
              dimensions.height <= BeautyConfiguration.defaultMaximumInputPixelCount,
              let pixelCount = checkedProduct(dimensions.width, dimensions.height),
              pixelCount <= BeautyConfiguration.defaultMaximumInputPixelCount
        else {
            throw BeautyError.invalidInput
        }

        if let compositionSummary {
            guard canonicalImage != nil,
                  nonNegativeAndBounded(compositionSummary.acceptedUnitCount),
                  nonNegativeAndBounded(compositionSummary.rejectedUnitCount),
                  nonNegativeAndBounded(compositionSummary.ownedPixelCount),
                  nonNegativeAndBounded(compositionSummary.changedPixelCount),
                  nonNegativeAndBounded(compositionSummary.changedOutsideUnionPixelCount),
                  nonNegativeAndBounded(compositionSummary.collisionPixelCount),
                  compositionSummary.ownedPixelCount <= pixelCount,
                  compositionSummary.changedPixelCount <= pixelCount,
                  compositionSummary.changedOutsideUnionPixelCount <= pixelCount,
                  compositionSummary.collisionPixelCount <= pixelCount
            else {
                throw BeautyError.invalidInput
            }
        }
    }

    private static func normalized(_ plan: BeautyEffectPlan) -> Bool {
        let unitStrengths: [Float] = [
            plan.effectiveStrengths.skinSmoothing,
            plan.effectiveStrengths.skinWhitening,
            plan.effectiveStrengths.skinRosy,
            plan.effectiveStrengths.skinSharpen,
            plan.effectiveStrengths.filterIntensity,
            plan.effectiveStrengths.faceSlim,
            plan.effectiveStrengths.faceSmall,
            plan.effectiveStrengths.faceVShape,
            plan.effectiveStrengths.jawSlim,
            plan.effectiveStrengths.faceContourSmooth,
            plan.effectiveStrengths.templeFullness,
            plan.effectiveStrengths.cheekboneSlim,
            plan.effectiveStrengths.chinTaper,
            plan.effectiveStrengths.eyeSize,
            plan.effectiveStrengths.eyeTailLift,
            plan.effectiveStrengths.eyeHeight,
            plan.effectiveStrengths.eyeLength,
            plan.effectiveStrengths.upperEyelidLift,
            plan.effectiveStrengths.pupilSize,
            plan.effectiveStrengths.gazeCorrection,
            plan.effectiveStrengths.lowerEyelidDrop,
            plan.effectiveStrengths.innerCornerOpen,
            plan.effectiveStrengths.outerCornerOpen,
            plan.effectiveStrengths.eyeSymmetry,
            plan.effectiveStrengths.eyebrowPeakDefinition,
            plan.effectiveStrengths.noseSlim,
            plan.effectiveStrengths.noseWingSlim,
            plan.effectiveStrengths.noseBridge,
            plan.effectiveStrengths.noseRootNarrowing,
            plan.effectiveStrengths.noseTipLift,
            plan.effectiveStrengths.smile,
            plan.effectiveStrengths.lipPeakDefinition,
            plan.effectiveStrengths.lipPlump,
            plan.effectiveStrengths.lipColor,
        ]
        let signedStrengths: [Float] = [
            plan.effectiveStrengths.brightness,
            plan.effectiveStrengths.contrast,
            plan.effectiveStrengths.saturation,
            plan.effectiveStrengths.temperature,
            plan.effectiveStrengths.tint,
            plan.effectiveStrengths.exposure,
            plan.effectiveStrengths.highlight,
            plan.effectiveStrengths.shadow,
            plan.effectiveStrengths.chinLength,
            plan.effectiveStrengths.eyeDistance,
            plan.effectiveStrengths.eyeYPosition,
            plan.effectiveStrengths.eyeTilt,
            plan.effectiveStrengths.eyebrowYPosition,
            plan.effectiveStrengths.eyebrowThickness,
            plan.effectiveStrengths.eyebrowLength,
            plan.effectiveStrengths.eyebrowSpacing,
            plan.effectiveStrengths.eyebrowHeadSpacing,
            plan.effectiveStrengths.eyebrowTilt,
            plan.effectiveStrengths.noseTipSize,
            plan.effectiveStrengths.mouthSize,
            plan.effectiveStrengths.mouthWidth,
            plan.effectiveStrengths.mouthYPosition,
            plan.effectiveStrengths.mouthTilt,
            plan.effectiveStrengths.mouthXPosition,
        ]
        return unitStrengths.allSatisfy { $0.isFinite && (0...1).contains($0) }
            && signedStrengths.allSatisfy { $0.isFinite && abs($0) <= 1 }
    }

    package static func checkedDimensions(for extent: CGRect) -> (width: Int, height: Int)? {
        guard extent.origin.x.isFinite,
              extent.origin.y.isFinite,
              extent.width.isFinite,
              extent.height.isFinite,
              extent.width > 0,
              extent.height > 0,
              extent.width.rounded(.towardZero) == extent.width,
              extent.height.rounded(.towardZero) == extent.height,
              extent.width <= CGFloat(Int.max),
              extent.height <= CGFloat(Int.max)
        else {
            return nil
        }
        return (Int(extent.width), Int(extent.height))
    }

    fileprivate static func checkedProduct(_ lhs: Int, _ rhs: Int) -> Int? {
        let (value, overflow) = lhs.multipliedReportingOverflow(by: rhs)
        return overflow ? nil : value
    }

    private static func nonNegativeAndBounded(_ value: Int) -> Bool {
        value >= 0 && value <= BeautyConfiguration.defaultMaximumInputPixelCount
    }
}

package struct BeautyBackendResult: @unchecked Sendable {
    package let output: BeautyBackendOutput
    package let diagnostics: BeautyBackendDiagnostics

    package init(
        output: BeautyBackendOutput,
        diagnostics: BeautyBackendDiagnostics,
        for request: BeautyBackendRequest
    ) throws {
        guard output.kind == request.inputKind,
              Self.valid(diagnostics: diagnostics, for: request, output: output)
        else {
            throw BeautyError.invalidInput
        }
        self.output = output
        self.diagnostics = diagnostics
    }

    private static func valid(
        diagnostics: BeautyBackendDiagnostics,
        for request: BeautyBackendRequest,
        output: BeautyBackendOutput
    ) -> Bool {
        guard diagnostics.width > 0,
              diagnostics.height > 0,
              diagnostics.width <= BeautyConfiguration.defaultMaximumInputPixelCount,
              diagnostics.height <= BeautyConfiguration.defaultMaximumInputPixelCount,
              diagnostics.unitCount >= 0,
              diagnostics.failureCount >= 0,
              diagnostics.collisionCount >= 0,
              diagnostics.changedPixelCount >= 0,
              diagnostics.unitCount <= BeautyConfiguration.defaultMaximumInputPixelCount,
              diagnostics.failureCount <= BeautyConfiguration.defaultMaximumInputPixelCount,
              diagnostics.collisionCount <= BeautyConfiguration.defaultMaximumInputPixelCount,
              diagnostics.changedPixelCount <= BeautyConfiguration.defaultMaximumInputPixelCount,
              let pixelCount = BeautyBackendRequest.checkedProduct(diagnostics.width, diagnostics.height),
              pixelCount <= BeautyConfiguration.defaultMaximumInputPixelCount,
              diagnostics.unitCount <= pixelCount,
              diagnostics.failureCount <= pixelCount,
              diagnostics.collisionCount <= pixelCount,
              diagnostics.changedPixelCount <= pixelCount
        else {
            return false
        }

        let outputDimensions: (width: Int, height: Int)?
        switch output {
        case .pixelBuffer(let pixelBuffer):
            guard CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA else {
                return false
            }
            outputDimensions = (CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))
        case .stillImage(let image):
            outputDimensions = BeautyBackendRequest.checkedDimensions(for: image.extent)
        }
        guard outputDimensions?.width == diagnostics.width,
              outputDimensions?.height == diagnostics.height
        else {
            return false
        }

        let inputDimensions: (width: Int, height: Int)
        switch request.input {
        case .pixelBuffer(let pixelBuffer):
            inputDimensions = (CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))
        case .stillImage(let image):
            guard let dimensions = BeautyBackendRequest.checkedDimensions(for: image.extent) else {
                return false
            }
            inputDimensions = dimensions
        }
        return inputDimensions.width == diagnostics.width
            && inputDimensions.height == diagnostics.height
    }
}

/// Synchronous backend seam. Implementations propagate typed terminal errors;
/// fallback and retry policy do not belong to this protocol.
package protocol BeautyBackendExecutor {
    func execute(_ request: BeautyBackendRequest) throws -> BeautyBackendResult
}
