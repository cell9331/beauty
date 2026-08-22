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
    package static let neighborhoodRadius = 1

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
        guard let sourceLayout = SourceLayout(request.source) else {
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
            guard let pixels = validatedPixels(outcome.pixelIndices, sourceLayout: sourceLayout) else {
                rejectedEyeCount += 1
                continue
            }

            var proposals: [BeautyLocalPixelProposal] = []
            proposals.reserveCapacity(pixels.count)
            for pixelIndex in pixels {
                guard let sample = sourceLayout.sample(pixelIndex: pixelIndex) else {
                    continue
                }
                let lowFrequency = sourceLayout.lowFrequency(at: pixelIndex)
                let residual = (
                    red: Int(sample.red) - lowFrequency.red,
                    green: Int(sample.green) - lowFrequency.green,
                    blue: Int(sample.blue) - lowFrequency.blue
                )
                let correction = lowFrequencyCorrection(
                    lowFrequency: lowFrequency,
                    strength: request.strength
                )
                let target = (
                    red: safeTarget(source: sample.red, correction: correction.red),
                    green: safeTarget(source: sample.green, correction: correction.green),
                    blue: safeTarget(source: sample.blue, correction: correction.blue)
                )

                // Keep this equation explicit: output = corrected low frequency
                // component + the exact source high-frequency residual.
                let reconstructedRed = lowFrequency.red + correction.red + residual.red
                let reconstructedGreen = lowFrequency.green + correction.green + residual.green
                let reconstructedBlue = lowFrequency.blue + correction.blue + residual.blue
                guard Int(target.red) == reconstructedRed,
                      Int(target.green) == reconstructedGreen,
                      Int(target.blue) == reconstructedBlue
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
                    softWeightQ16: UInt32.max,
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
        _ pixels: [Int],
        sourceLayout: SourceLayout
    ) -> [Int]? {
        guard !pixels.isEmpty,
              Set(pixels).count == pixels.count,
              pixels.allSatisfy({ (0..<sourceLayout.pixelCount).contains($0) })
        else {
            return nil
        }
        return pixels
    }

    private static func lowFrequencyCorrection(
        lowFrequency: RGB,
        strength: Double
    ) -> RGBInt {
        func correction(_ channel: Int) -> Int {
            let raw = Int((Double(128 - channel) * strength * 0.125).rounded(.toNearestOrAwayFromZero))
            return min(max(raw, -maximumAbsoluteChannelDelta), maximumAbsoluteChannelDelta)
        }
        return RGBInt(
            red: correction(lowFrequency.red),
            green: correction(lowFrequency.green),
            blue: correction(lowFrequency.blue)
        )
    }

    private static func safeTarget(source: UInt8, correction: Int) -> UInt8 {
        let sourceValue = Int(source)
        let bounded = min(max(correction, -sourceValue), 255 - sourceValue)
        return UInt8(sourceValue + bounded)
    }
}

private struct RGB: Sendable {
    let red: Int
    let green: Int
    let blue: Int
}

private struct RGBInt: Sendable {
    let red: Int
    let green: Int
    let blue: Int
}

private struct SourceLayout: Sendable {
    let bytes: Data
    let width: Int
    let height: Int
    let rowBytes: Int
    let pixelCount: Int

    init?(_ source: BeautyCanonicalStillImage) {
        let (expectedRowBytes, rowOverflow) = source.width.multipliedReportingOverflow(by: 4)
        let (expectedByteCount, byteOverflow) = source.rowBytes.multipliedReportingOverflow(by: source.height)
        guard source.width > 0,
              source.height > 0,
              !rowOverflow,
              !byteOverflow,
              source.rowBytes == expectedRowBytes,
              source.byteCount == expectedByteCount,
              source.rgba8Data.count == source.byteCount
        else {
            return nil
        }
        let (pixelCount, overflow) = source.width.multipliedReportingOverflow(by: source.height)
        guard !overflow, pixelCount > 0 else { return nil }
        self.bytes = source.rgba8Data
        self.width = source.width
        self.height = source.height
        self.rowBytes = source.rowBytes
        self.pixelCount = pixelCount
    }

    func sample(pixelIndex: Int) -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8)? {
        guard (0..<pixelCount).contains(pixelIndex) else { return nil }
        let offset = pixelIndex * 4
        guard offset >= 0, offset + 3 < bytes.count else { return nil }
        return (bytes[offset], bytes[offset + 1], bytes[offset + 2], bytes[offset + 3])
    }

    func lowFrequency(at pixelIndex: Int) -> RGB {
        let x = pixelIndex % width
        let y = pixelIndex / width
        var red = 0
        var green = 0
        var blue = 0
        var count = 0
        for sampleY in max(0, y - BeautyUpperEyelidFullnessEditor.neighborhoodRadius)...min(height - 1, y + BeautyUpperEyelidFullnessEditor.neighborhoodRadius) {
            for sampleX in max(0, x - BeautyUpperEyelidFullnessEditor.neighborhoodRadius)...min(width - 1, x + BeautyUpperEyelidFullnessEditor.neighborhoodRadius) {
                let index = sampleY * width + sampleX
                guard let sample = sample(pixelIndex: index) else { continue }
                red += Int(sample.red)
                green += Int(sample.green)
                blue += Int(sample.blue)
                count += 1
            }
        }
        guard count > 0 else { return RGB(red: 0, green: 0, blue: 0) }
        return RGB(
            red: (red + count / 2) / count,
            green: (green + count / 2) / count,
            blue: (blue + count / 2) / count
        )
    }
}
