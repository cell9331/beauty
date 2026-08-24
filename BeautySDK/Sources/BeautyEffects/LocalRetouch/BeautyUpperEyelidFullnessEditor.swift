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
    package static let neighborhoodRadius = 2
    package static let lowFrequencyFlatteningGain = 1.5

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
            guard let pixels = validatedPixels(outcome.pixels, sourceLayout: sourceLayout) else {
                rejectedEyeCount += 1
                continue
            }

            let lowFrequencySamples = pixels.compactMap { pixel in
                sourceLayout.lowFrequency(at: pixel.pixelIndex)
            }
            guard lowFrequencySamples.count == pixels.count,
                  let regionalReferenceLuminance = weightedReferenceLuminance(
                    pixels: pixels,
                    lowFrequencySamples: lowFrequencySamples
                  )
            else {
                rejectedEyeCount += 1
                continue
            }

            var proposals: [BeautyLocalPixelProposal] = []
            proposals.reserveCapacity(pixels.count)
            for (pixel, lowFrequency) in zip(pixels, lowFrequencySamples) {
                let pixelIndex = pixel.pixelIndex
                guard let sample = sourceLayout.sample(pixelIndex: pixelIndex) else {
                    continue
                }
                let residual = (
                    red: Int(sample.red) - lowFrequency.red,
                    green: Int(sample.green) - lowFrequency.green,
                    blue: Int(sample.blue) - lowFrequency.blue
                )
                let correction = lowFrequencyCorrection(
                    lowFrequency: lowFrequency,
                    regionalReferenceLuminance: regionalReferenceLuminance,
                    source: sample,
                    strength: request.strength
                )
                let target = (
                    red: safeTarget(source: sample.red, correction: correction),
                    green: safeTarget(source: sample.green, correction: correction),
                    blue: safeTarget(source: sample.blue, correction: correction)
                )

                // Keep this equation explicit: output = corrected low frequency
                // component + the exact source high-frequency residual.
                let reconstructedRed = lowFrequency.red + correction + residual.red
                let reconstructedGreen = lowFrequency.green + correction + residual.green
                let reconstructedBlue = lowFrequency.blue + correction + residual.blue
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
        sourceLayout: SourceLayout
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

    private static func weightedReferenceLuminance(
        pixels: [BeautyUpperEyelidSupportPixel],
        lowFrequencySamples: [RGB]
    ) -> Int? {
        guard pixels.count == lowFrequencySamples.count, !pixels.isEmpty else { return nil }
        var weightedLuminance: UInt64 = 0
        var totalWeight: UInt64 = 0
        for (pixel, sample) in zip(pixels, lowFrequencySamples) {
            let weight = UInt64(pixel.softWeightQ16)
            let luminance = UInt64(sample.luminance)
            let (term, termOverflow) = luminance.multipliedReportingOverflow(by: weight)
            let (nextLuminance, sumOverflow) = weightedLuminance.addingReportingOverflow(term)
            let (nextWeight, weightOverflow) = totalWeight.addingReportingOverflow(weight)
            guard !termOverflow, !sumOverflow, !weightOverflow else { return nil }
            weightedLuminance = nextLuminance
            totalWeight = nextWeight
        }
        guard totalWeight > 0 else { return nil }
        return Int((weightedLuminance + totalWeight / 2) / totalWeight)
    }

    private static func lowFrequencyCorrection(
        lowFrequency: RGB,
        regionalReferenceLuminance: Int,
        source: (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8),
        strength: Double
    ) -> Int {
        let raw = Int((
            Double(regionalReferenceLuminance - lowFrequency.luminance)
                * strength
                * lowFrequencyFlatteningGain
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

private struct RGB: Sendable {
    let red: Int
    let green: Int
    let blue: Int

    var luminance: Int {
        // Integer Rec. 709 approximation. One scalar correction is then
        // applied to every RGB channel so source chroma remains unchanged.
        (54 * red + 183 * green + 19 * blue + 128) >> 8
    }
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
