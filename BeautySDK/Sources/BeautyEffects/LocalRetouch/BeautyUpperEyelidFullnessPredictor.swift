import BeautyCore
import BeautyDetection
import Foundation

/// Package-only request for the future rights-approved learned model. The
/// source pixels and priors are request-local and deliberately have no Codable
/// or public diagnostic representation.
package struct BeautyUpperEyelidFullnessPredictionRequest: Sendable {
    package let source: BeautyCanonicalStillImage
    package let side: BeautyObservedEyeSide
    package let supportPixels: [BeautyUpperEyelidSupportPixel]
    package let hardEnvelope: CoordinateRect
    package let protectedPixelIndices: Set<Int>

    package init(
        source: BeautyCanonicalStillImage,
        side: BeautyObservedEyeSide,
        supportPixels: [BeautyUpperEyelidSupportPixel],
        hardEnvelope: CoordinateRect,
        protectedPixelIndices: Set<Int> = []
    ) {
        self.source = source
        self.side = side
        self.supportPixels = supportPixels
        self.hardEnvelope = hardEnvelope
        self.protectedPixelIndices = protectedPixelIndices
    }
}

extension BeautyUpperEyelidFullnessPredictionRequest: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyUpperEyelidFullnessPredictionRequest(side: \(side.rawValue), width: \(source.width), height: \(source.height), supportPixelCount: \(supportPixels.count), protectedPixelCount: \(protectedPixelIndices.count))"
    }

    package var debugDescription: String { description }

    package var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "side": side.rawValue,
                "width": source.width,
                "height": source.height,
                "supportPixelCount": supportPixels.count,
                "protectedPixelCount": protectedPixelIndices.count,
            ],
            displayStyle: .struct
        )
    }
}

/// One dense output sample mapped to the canonical source image. Displacement
/// values are expressed in canonical source pixels. The tone value is a
/// multiplicative log-luminance residual, never replacement RGB.
package struct BeautyUpperEyelidFullnessPredictionSample: Equatable, Sendable {
    package let pixelIndex: Int
    package let alphaQ16: UInt32
    package let horizontalDisplacementPixels: Double
    package let verticalDisplacementPixels: Double
    package let logLuminanceDelta: Double

    package init(
        pixelIndex: Int,
        alphaQ16: UInt32,
        horizontalDisplacementPixels: Double,
        verticalDisplacementPixels: Double,
        logLuminanceDelta: Double
    ) {
        self.pixelIndex = pixelIndex
        self.alphaQ16 = alphaQ16
        self.horizontalDisplacementPixels = horizontalDisplacementPixels
        self.verticalDisplacementPixels = verticalDisplacementPixels
        self.logLuminanceDelta = logLuminanceDelta
    }
}

/// Raw request-local model output. `isApplicable == false` is an ordinary
/// source-exact abstention and must carry no dense samples.
package struct BeautyUpperEyelidFullnessPrediction: Equatable, Sendable {
    package let side: BeautyObservedEyeSide
    package let isApplicable: Bool
    package let confidence: Double
    package let uncertainty: Double
    package let samples: [BeautyUpperEyelidFullnessPredictionSample]

    package init(
        side: BeautyObservedEyeSide,
        isApplicable: Bool,
        confidence: Double,
        uncertainty: Double,
        samples: [BeautyUpperEyelidFullnessPredictionSample]
    ) {
        self.side = side
        self.isApplicable = isApplicable
        self.confidence = confidence
        self.uncertainty = uncertainty
        self.samples = samples
    }
}

/// Model implementations may wrap Core ML later. No implementation is
/// registered by default; Plan 80-20 deliberately creates no fake model.
package protocol BeautyUpperEyelidFullnessPredicting: Sendable {
    func predict(
        _ request: BeautyUpperEyelidFullnessPredictionRequest
    ) throws -> BeautyUpperEyelidFullnessPrediction
}

package enum BeautyUpperEyelidFullnessPredictionReason: String, Equatable, Sendable {
    case accepted
    case modelUnavailable
    case inferenceFailed
    case invalidRequest
    case notApplicable
    case lowConfidence
    case highUncertainty
    case invalidOutput
}

package struct BeautyUpperEyelidFullnessPredictionSummary: Equatable, Sendable {
    package let side: BeautyObservedEyeSide
    package let reason: BeautyUpperEyelidFullnessPredictionReason
    package let acceptedSampleCount: Int

    package init(
        side: BeautyObservedEyeSide,
        reason: BeautyUpperEyelidFullnessPredictionReason,
        acceptedSampleCount: Int = 0
    ) {
        self.side = side
        self.reason = reason
        self.acceptedSampleCount = acceptedSampleCount
    }

    package var isAccepted: Bool { reason == .accepted }
}

extension BeautyUpperEyelidFullnessPredictionSummary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyUpperEyelidFullnessPredictionSummary(side: \(side.rawValue), reason: \(reason.rawValue), acceptedSampleCount: \(acceptedSampleCount))"
    }

    package var debugDescription: String { description }

    package var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "side": side.rawValue,
                "reason": reason.rawValue,
                "acceptedSampleCount": acceptedSampleCount,
            ],
            displayStyle: .struct
        )
    }
}

package struct BeautyUpperEyelidFullnessValidatedPrediction: Sendable {
    package let summary: BeautyUpperEyelidFullnessPredictionSummary
    package let prediction: BeautyUpperEyelidFullnessPrediction?

    package init(
        summary: BeautyUpperEyelidFullnessPredictionSummary,
        prediction: BeautyUpperEyelidFullnessPrediction? = nil
    ) {
        self.summary = summary
        self.prediction = prediction
    }
}

extension BeautyUpperEyelidFullnessValidatedPrediction: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String { summary.description }
    package var debugDescription: String { description }
    package var customMirror: Mirror { summary.customMirror }
}

package enum BeautyUpperEyelidFullnessPredictionValidator {
    package static let minimumConfidence = 0.80
    package static let maximumUncertainty = 0.20
    package static let boundaryZeroMaximumWeightQ16: UInt32 = 4_096
    package static let maximumDisplacementToMinimumImageDimension = 0.02
    package static let maximumNeighborDisplacementDeltaPixels = 0.75
    package static let maximumAbsoluteLogLuminanceDelta = 0.08
    package static let maximumNeighborLogLuminanceDelta = 0.04
    package static let minimumLocalJacobianDeterminant = 0.25

    package static func validateRequest(
        _ request: BeautyUpperEyelidFullnessPredictionRequest
    ) -> BeautyUpperEyelidFullnessPredictionReason? {
        let source = request.source
        let (expectedRowBytes, rowOverflow) = source.width.multipliedReportingOverflow(by: 4)
        let (expectedByteCount, byteOverflow) = source.rowBytes.multipliedReportingOverflow(by: source.height)
        let (pixelCount, pixelOverflow) = source.width.multipliedReportingOverflow(by: source.height)
        guard source.width > 0,
              source.height > 0,
              !rowOverflow,
              !byteOverflow,
              !pixelOverflow,
              source.rowBytes == expectedRowBytes,
              source.byteCount == expectedByteCount,
              source.rgba8Data.count == source.byteCount,
              pixelCount > 0,
              request.hardEnvelope.isFinite,
              request.hardEnvelope.width > 0,
              request.hardEnvelope.height > 0,
              request.hardEnvelope.minX >= 0,
              request.hardEnvelope.minY >= 0,
              request.hardEnvelope.maxX <= 1,
              request.hardEnvelope.maxY <= 1,
              !request.supportPixels.isEmpty,
              Set(request.supportPixels.map(\.pixelIndex)).count == request.supportPixels.count,
              request.supportPixels.allSatisfy({ pixel in
                  guard (0..<pixelCount).contains(pixel.pixelIndex),
                        pixel.softWeightQ16 > 0,
                        pixel.softWeightQ16 <= 65_536
                  else {
                      return false
                  }
                  let x = pixel.pixelIndex % source.width
                  let y = pixel.pixelIndex / source.width
                  let normalizedX = (Double(x) + 0.5) / Double(source.width)
                  let normalizedY = (Double(y) + 0.5) / Double(source.height)
                  return normalizedX >= request.hardEnvelope.minX
                      && normalizedX <= request.hardEnvelope.maxX
                      && normalizedY >= request.hardEnvelope.minY
                      && normalizedY <= request.hardEnvelope.maxY
              }),
              request.protectedPixelIndices.allSatisfy({ (0..<pixelCount).contains($0) }),
              request.protectedPixelIndices.isDisjoint(with: request.supportPixels.map(\.pixelIndex))
        else {
            return .invalidRequest
        }
        return nil
    }

    package static func validate(
        _ prediction: BeautyUpperEyelidFullnessPrediction,
        for request: BeautyUpperEyelidFullnessPredictionRequest
    ) -> BeautyUpperEyelidFullnessValidatedPrediction {
        if let reason = validateRequest(request) {
            return rejected(side: request.side, reason: reason)
        }
        guard prediction.side == request.side,
              prediction.confidence.isFinite,
              prediction.uncertainty.isFinite,
              (0...1).contains(prediction.confidence),
              (0...1).contains(prediction.uncertainty)
        else {
            return rejected(side: request.side, reason: .invalidOutput)
        }
        guard prediction.isApplicable else {
            return prediction.samples.isEmpty
                ? rejected(side: request.side, reason: .notApplicable)
                : rejected(side: request.side, reason: .invalidOutput)
        }
        guard prediction.confidence >= minimumConfidence else {
            return rejected(side: request.side, reason: .lowConfidence)
        }
        guard prediction.uncertainty <= maximumUncertainty else {
            return rejected(side: request.side, reason: .highUncertainty)
        }

        let supportByIndex = Dictionary(
            uniqueKeysWithValues: request.supportPixels.map { ($0.pixelIndex, $0) }
        )
        guard prediction.samples.count == request.supportPixels.count,
              Set(prediction.samples.map(\.pixelIndex)).count == prediction.samples.count,
              Set(prediction.samples.map(\.pixelIndex)) == Set(supportByIndex.keys)
        else {
            return rejected(side: request.side, reason: .invalidOutput)
        }

        let displacementLimit = Double(min(request.source.width, request.source.height))
            * maximumDisplacementToMinimumImageDimension
        var sampleByIndex: [Int: BeautyUpperEyelidFullnessPredictionSample] = [:]
        sampleByIndex.reserveCapacity(prediction.samples.count)
        var hasActiveOutput = false
        for sample in prediction.samples {
            guard let support = supportByIndex[sample.pixelIndex],
                  sample.horizontalDisplacementPixels.isFinite,
                  sample.verticalDisplacementPixels.isFinite,
                  sample.logLuminanceDelta.isFinite,
                  sample.alphaQ16 <= support.softWeightQ16,
                  abs(sample.logLuminanceDelta) <= maximumAbsoluteLogLuminanceDelta,
                  hypot(
                      sample.horizontalDisplacementPixels,
                      sample.verticalDisplacementPixels
                  ) <= displacementLimit
            else {
                return rejected(side: request.side, reason: .invalidOutput)
            }

            let isZero = sample.horizontalDisplacementPixels == 0
                && sample.verticalDisplacementPixels == 0
                && sample.logLuminanceDelta == 0
            if sample.alphaQ16 == 0 || support.softWeightQ16 <= boundaryZeroMaximumWeightQ16 {
                guard sample.alphaQ16 == 0, isZero else {
                    return rejected(side: request.side, reason: .invalidOutput)
                }
            } else if !isZero {
                hasActiveOutput = true
            }
            sampleByIndex[sample.pixelIndex] = sample
        }
        guard hasActiveOutput,
              neighborsAreSafe(
                  sampleByIndex,
                  supportByIndex: supportByIndex,
                  width: request.source.width
              )
        else {
            return rejected(side: request.side, reason: .invalidOutput)
        }

        return BeautyUpperEyelidFullnessValidatedPrediction(
            summary: BeautyUpperEyelidFullnessPredictionSummary(
                side: request.side,
                reason: .accepted,
                acceptedSampleCount: prediction.samples.count
            ),
            prediction: prediction
        )
    }

    private static func neighborsAreSafe(
        _ samples: [Int: BeautyUpperEyelidFullnessPredictionSample],
        supportByIndex: [Int: BeautyUpperEyelidSupportPixel],
        width: Int
    ) -> Bool {
        for (pixelIndex, sample) in samples {
            let column = pixelIndex % width
            let rightIndex = pixelIndex + 1
            let downIndex = pixelIndex + width
            if column < width - 1, let right = samples[rightIndex] {
                guard neighborDeltaIsSafe(sample, right) else { return false }
            }
            if let down = samples[downIndex] {
                guard neighborDeltaIsSafe(sample, down) else { return false }
            }
            guard column < width - 1,
                  let right = samples[rightIndex],
                  let down = samples[downIndex],
                  supportByIndex[pixelIndex]?.softWeightQ16 ?? 0 > boundaryZeroMaximumWeightQ16,
                  supportByIndex[rightIndex]?.softWeightQ16 ?? 0 > boundaryZeroMaximumWeightQ16,
                  supportByIndex[downIndex]?.softWeightQ16 ?? 0 > boundaryZeroMaximumWeightQ16
            else {
                continue
            }
            let dFlowXDX = right.horizontalDisplacementPixels - sample.horizontalDisplacementPixels
            let dFlowYDX = right.verticalDisplacementPixels - sample.verticalDisplacementPixels
            let dFlowXDY = down.horizontalDisplacementPixels - sample.horizontalDisplacementPixels
            let dFlowYDY = down.verticalDisplacementPixels - sample.verticalDisplacementPixels
            let determinant = (1 + dFlowXDX) * (1 + dFlowYDY) - dFlowXDY * dFlowYDX
            guard determinant.isFinite,
                  determinant >= minimumLocalJacobianDeterminant
            else {
                return false
            }
        }
        return true
    }

    private static func neighborDeltaIsSafe(
        _ first: BeautyUpperEyelidFullnessPredictionSample,
        _ second: BeautyUpperEyelidFullnessPredictionSample
    ) -> Bool {
        hypot(
            second.horizontalDisplacementPixels - first.horizontalDisplacementPixels,
            second.verticalDisplacementPixels - first.verticalDisplacementPixels
        ) <= maximumNeighborDisplacementDeltaPixels
            && abs(second.logLuminanceDelta - first.logLuminanceDelta)
                <= maximumNeighborLogLuminanceDelta
    }

    private static func rejected(
        side: BeautyObservedEyeSide,
        reason: BeautyUpperEyelidFullnessPredictionReason
    ) -> BeautyUpperEyelidFullnessValidatedPrediction {
        BeautyUpperEyelidFullnessValidatedPrediction(
            summary: BeautyUpperEyelidFullnessPredictionSummary(
                side: side,
                reason: reason
            )
        )
    }
}

/// Request-local orchestration. Nil means no admitted model, which is the only
/// production state until the data/license/model gates pass.
package enum BeautyUpperEyelidFullnessPredictionOwner {
    package static func resolve(
        requests: [BeautyUpperEyelidFullnessPredictionRequest],
        predictor: (any BeautyUpperEyelidFullnessPredicting)? = nil
    ) -> [BeautyUpperEyelidFullnessValidatedPrediction] {
        requests.map { request in
            if let requestReason = BeautyUpperEyelidFullnessPredictionValidator.validateRequest(request) {
                return BeautyUpperEyelidFullnessValidatedPrediction(
                    summary: BeautyUpperEyelidFullnessPredictionSummary(
                        side: request.side,
                        reason: requestReason
                    )
                )
            }
            guard let predictor else {
                return BeautyUpperEyelidFullnessValidatedPrediction(
                    summary: BeautyUpperEyelidFullnessPredictionSummary(
                        side: request.side,
                        reason: .modelUnavailable
                    )
                )
            }
            do {
                return BeautyUpperEyelidFullnessPredictionValidator.validate(
                    try predictor.predict(request),
                    for: request
                )
            } catch {
                return BeautyUpperEyelidFullnessValidatedPrediction(
                    summary: BeautyUpperEyelidFullnessPredictionSummary(
                        side: request.side,
                        reason: .inferenceFailed
                    )
                )
            }
        }
    }
}
