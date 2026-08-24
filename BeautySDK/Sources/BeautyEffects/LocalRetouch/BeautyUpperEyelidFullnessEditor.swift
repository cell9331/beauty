import BeautyCore
import BeautyDetection
import Foundation

package enum BeautyUpperEyelidFullnessEditReason: String, Equatable, Sendable {
    case edited
    case neutral
    case noApprovedSupport
    case invalidStrength
    case invalidSource
    case invalidSupport
}

package struct BeautyUpperEyelidFullnessEditSummary: Equatable, Sendable {
    package let acceptedEyeCount: Int
    package let rejectedEyeCount: Int
    package let proposalPixelCount: Int
    package let changedPixelCount: Int
    package let maximumAbsoluteChannelDelta: Int
    package let reason: BeautyUpperEyelidFullnessEditReason

    package init(
        acceptedEyeCount: Int = 0,
        rejectedEyeCount: Int = 0,
        proposalPixelCount: Int = 0,
        changedPixelCount: Int = 0,
        maximumAbsoluteChannelDelta: Int = 0,
        reason: BeautyUpperEyelidFullnessEditReason = .noApprovedSupport
    ) {
        self.acceptedEyeCount = acceptedEyeCount
        self.rejectedEyeCount = rejectedEyeCount
        self.proposalPixelCount = proposalPixelCount
        self.changedPixelCount = changedPixelCount
        self.maximumAbsoluteChannelDelta = maximumAbsoluteChannelDelta
        self.reason = reason
    }
}

extension BeautyUpperEyelidFullnessEditSummary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyUpperEyelidFullnessEditSummary(acceptedEyeCount: \(acceptedEyeCount), rejectedEyeCount: \(rejectedEyeCount), proposalPixelCount: \(proposalPixelCount), changedPixelCount: \(changedPixelCount), maximumAbsoluteChannelDelta: \(maximumAbsoluteChannelDelta), reason: \(reason.rawValue))"
    }

    package var debugDescription: String { description }

    package var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "acceptedEyeCount": acceptedEyeCount,
                "rejectedEyeCount": rejectedEyeCount,
                "proposalPixelCount": proposalPixelCount,
                "changedPixelCount": changedPixelCount,
                "maximumAbsoluteChannelDelta": maximumAbsoluteChannelDelta,
                "reason": reason.rawValue,
            ],
            displayStyle: .struct
        )
    }
}

package struct BeautyUpperEyelidFullnessEditRequest: Sendable {
    package let source: BeautyCanonicalStillImage
    package let support: BeautyUpperEyelidSupportResolution
    package let strength: Double

    package init(
        source: BeautyCanonicalStillImage,
        support: BeautyUpperEyelidSupportResolution,
        strength: Double
    ) {
        self.source = source
        self.support = support
        self.strength = strength
    }
}

extension BeautyUpperEyelidFullnessEditRequest: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyUpperEyelidFullnessEditRequest(strength: \(strength), supportedEyeCount: \(support.supportedEyeCount))"
    }

    package var debugDescription: String { description }

    package var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "strength": strength,
                "supportedEyeCount": support.supportedEyeCount,
            ],
            displayStyle: .struct
        )
    }
}

package struct BeautyUpperEyelidFullnessEditResult: Sendable {
    package let summary: BeautyUpperEyelidFullnessEditSummary
    package let proposalsByEye: [[BeautyLocalPixelProposal]]

    package init(
        summary: BeautyUpperEyelidFullnessEditSummary,
        proposalsByEye: [[BeautyLocalPixelProposal]] = []
    ) {
        self.summary = summary
        self.proposalsByEye = proposalsByEye
    }

    package var proposalPixelCount: Int {
        proposalsByEye.reduce(0) { $0 + $1.count }
    }

    package func makeUnits(using owner: BeautyLocalRetouchCompositionOwner) -> [BeautyLocalRetouchUnit] {
        proposalsByEye.compactMap { proposals in
            guard !proposals.isEmpty else { return nil }
            return owner.makeUnit(proposals: proposals)
        }
    }
}

extension BeautyUpperEyelidFullnessEditResult: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyUpperEyelidFullnessEditResult(proposalPixelCount: \(proposalPixelCount), changedPixelCount: \(summary.changedPixelCount), reason: \(summary.reason.rawValue))"
    }

    package var debugDescription: String { description }

    package var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "proposalPixelCount": proposalPixelCount,
                "changedPixelCount": summary.changedPixelCount,
                "reason": summary.reason.rawValue,
            ],
            displayStyle: .struct
        )
    }
}

package enum BeautyUpperEyelidFullnessEditor {
    package static let maximumAbsoluteChannelDelta = 16
    package static let reliefCompressionGain = 1.5

    package static func edit(
        source: BeautyCanonicalStillImage,
        support: BeautyUpperEyelidSupportResolution,
        strength: Double
    ) -> BeautyUpperEyelidFullnessEditResult {
        edit(BeautyUpperEyelidFullnessEditRequest(
            source: source,
            support: support,
            strength: strength
        ))
    }

    package static func edit(
        _ request: BeautyUpperEyelidFullnessEditRequest
    ) -> BeautyUpperEyelidFullnessEditResult {
        guard request.strength.isFinite,
              (0...1).contains(request.strength)
        else {
            return result(reason: .invalidStrength)
        }
        guard let sourceLayout = BeautyUpperEyelidReliefSourceLayout(request.source) else {
            return result(reason: .invalidSource)
        }
        guard request.strength > 0 else {
            return result(reason: .neutral)
        }

        var proposalsByEye: [[BeautyLocalPixelProposal]] = []
        proposalsByEye.reserveCapacity(2)
        var acceptedEyeCount = 0
        var rejectedEyeCount = 0
        var changedPixelCount = 0
        var maximumAbsoluteChannelDelta = 0

        for outcome in request.support.outcomes {
            guard outcome.isSupported else {
                rejectedEyeCount += 1
                continue
            }
            guard let pixels = validatedPixels(outcome.pixels, sourceLayout: sourceLayout) else {
                rejectedEyeCount += 1
                continue
            }

            guard let reliefModel = BeautyUpperEyelidReliefModel.analyze(
                source: request.source,
                pixels: pixels
            ), reliefModel.isFullnessSupported,
               reliefModel.samples.count == pixels.count
            else {
                rejectedEyeCount += 1
                continue
            }

            var proposals: [BeautyLocalPixelProposal] = []
            proposals.reserveCapacity(pixels.count)
            for (pixel, reliefSample) in zip(pixels, reliefModel.samples) {
                let pixelIndex = pixel.pixelIndex
                guard reliefSample.pixelIndex == pixelIndex,
                      let sample = sourceLayout.sample(pixelIndex: pixelIndex)
                else {
                    continue
                }
                let correction = reliefCorrection(
                    convexityResidual: reliefSample.convexityResidual,
                    source: sample,
                    strength: request.strength
                )
                let target = (
                    red: safeTarget(source: sample.red, correction: correction),
                    green: safeTarget(source: sample.green, correction: correction),
                    blue: safeTarget(source: sample.blue, correction: correction)
                )

                // The correction varies only with the smooth low-frequency
                // relief residual. One scalar is applied to all RGB channels,
                // so source chroma and high-frequency detail remain exact
                // before Q16 feathering back to immutable source pixels.
                guard Int(target.red) - Int(sample.red) == correction,
                      Int(target.green) - Int(sample.green) == correction,
                      Int(target.blue) - Int(sample.blue) == correction
                else {
                    continue
                }

                let deltaRed = Int(target.red) - Int(sample.red)
                let deltaGreen = Int(target.green) - Int(sample.green)
                let deltaBlue = Int(target.blue) - Int(sample.blue)
                let maximumDelta = max(abs(deltaRed), max(abs(deltaGreen), abs(deltaBlue)))
                maximumAbsoluteChannelDelta = max(maximumAbsoluteChannelDelta, maximumDelta)
                if maximumDelta > 0 {
                    changedPixelCount += 1
                }
                proposals.append(BeautyLocalPixelProposal(
                    pixelIndex: pixelIndex,
                    isInsideHardEnvelope: true,
                    softWeightQ16: pixel.softWeightQ16,
                    targetRed: target.red,
                    targetGreen: target.green,
                    targetBlue: target.blue
                ))
            }
            acceptedEyeCount += 1
            proposalsByEye.append(proposals)
        }

        let proposalPixelCount = proposalsByEye.reduce(0) { $0 + $1.count }
        guard proposalPixelCount > 0 else {
            return BeautyUpperEyelidFullnessEditResult(
                summary: BeautyUpperEyelidFullnessEditSummary(
                    acceptedEyeCount: acceptedEyeCount,
                    rejectedEyeCount: rejectedEyeCount,
                    reason: .noApprovedSupport
                )
            )
        }
        return BeautyUpperEyelidFullnessEditResult(
            summary: BeautyUpperEyelidFullnessEditSummary(
                acceptedEyeCount: acceptedEyeCount,
                rejectedEyeCount: rejectedEyeCount,
                proposalPixelCount: proposalPixelCount,
                changedPixelCount: changedPixelCount,
                maximumAbsoluteChannelDelta: maximumAbsoluteChannelDelta,
                reason: .edited
            ),
            proposalsByEye: proposalsByEye
        )
    }

    private static func result(
        reason: BeautyUpperEyelidFullnessEditReason
    ) -> BeautyUpperEyelidFullnessEditResult {
        BeautyUpperEyelidFullnessEditResult(
            summary: BeautyUpperEyelidFullnessEditSummary(reason: reason)
        )
    }

    private static func validatedPixels(
        _ pixels: [BeautyUpperEyelidSupportPixel],
        sourceLayout: BeautyUpperEyelidReliefSourceLayout
    ) -> [BeautyUpperEyelidSupportPixel]? {
        guard !pixels.isEmpty,
              Set(pixels.map(\.pixelIndex)).count == pixels.count,
              pixels.allSatisfy({
                  (0..<sourceLayout.pixelCount).contains($0.pixelIndex)
                      && $0.softWeightQ16 > 0
                      && $0.softWeightQ16 <= 65_536
              })
        else {
            return nil
        }
        return pixels
    }

    private static func reliefCorrection(
        convexityResidual: Double,
        source: (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8),
        strength: Double
    ) -> Int {
        guard convexityResidual.isFinite else { return 0 }
        let raw = Int((
            -convexityResidual * reliefCompressionGain * strength
        ).rounded(.toNearestOrAwayFromZero))
        let lowerClippingBound = -min(Int(source.red), min(Int(source.green), Int(source.blue)))
        let upperClippingBound = 255 - max(Int(source.red), max(Int(source.green), Int(source.blue)))
        return min(
            max(raw, max(-maximumAbsoluteChannelDelta, lowerClippingBound)),
            min(maximumAbsoluteChannelDelta, upperClippingBound)
        )
    }

    private static func safeTarget(source: UInt8, correction: Int) -> UInt8 {
        let sourceValue = Int(source)
        let bounded = min(max(correction, -sourceValue), 255 - sourceValue)
        return UInt8(sourceValue + bounded)
    }
}
