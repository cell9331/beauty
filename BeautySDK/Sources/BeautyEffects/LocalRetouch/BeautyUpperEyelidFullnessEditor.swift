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
    package static let maximumCenterContourDelta = 10

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

            let samples = pixels.compactMap { pixel in
                sourceLayout.sample(pixelIndex: pixel.pixelIndex)
            }
            guard samples.count == pixels.count,
                  let contourCorrection = contourCorrection(
                    samples: samples,
                    strength: request.strength
                  )
            else {
                rejectedEyeCount += 1
                continue
            }

            var proposals: [BeautyLocalPixelProposal] = []
            proposals.reserveCapacity(pixels.count)
            for (pixel, sample) in zip(pixels, samples) {
                let pixelIndex = pixel.pixelIndex
                let target = (
                    red: safeTarget(source: sample.red, correction: contourCorrection),
                    green: safeTarget(source: sample.green, correction: contourCorrection),
                    blue: safeTarget(source: sample.blue, correction: contourCorrection)
                )

                // One request-local scalar is applied to every source RGB
                // sample. Spatial detail and channel differences therefore
                // remain exact before the existing Q16 feather blends the
                // contour smoothly back to immutable source pixels.
                guard Int(target.red) - Int(sample.red) == contourCorrection,
                      Int(target.green) - Int(sample.green) == contourCorrection,
                      Int(target.blue) - Int(sample.blue) == contourCorrection
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

    private static func contourCorrection(
        samples: [(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8)],
        strength: Double
    ) -> Int? {
        guard !samples.isEmpty else { return nil }
        let requestedMagnitude = Int(
            (Double(maximumCenterContourDelta) * strength).rounded(.toNearestOrAwayFromZero)
        )
        let clippingMagnitude = samples.reduce(maximumAbsoluteChannelDelta) { bound, sample in
            min(bound, min(Int(sample.red), min(Int(sample.green), Int(sample.blue))))
        }
        return -min(requestedMagnitude, min(maximumAbsoluteChannelDelta, clippingMagnitude))
    }

    private static func safeTarget(source: UInt8, correction: Int) -> UInt8 {
        let sourceValue = Int(source)
        let bounded = min(max(correction, -sourceValue), 255 - sourceValue)
        return UInt8(sourceValue + bounded)
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
}
