import BeautyCore
import BeautyDetection
import Foundation

// The owner accepted the bounded v4 mechanics as the current provisional
// owner-local implementation on 2026-08-25. The explicit experimental names
// remain to preserve provenance and to signal that visual strength is weak and
// expected to improve later; the public facade exposes only a scalar parameter.

package enum BeautyExperimentalUpperEyelidReliefEditReason: String, Equatable, Sendable {
    case edited
    case neutral
    case noApprovedSupport
    case invalidStrength
    case invalidSource
    case invalidSupport
}

package struct BeautyExperimentalUpperEyelidReliefEditSummary: Equatable, Sendable {
    package let acceptedEyeCount: Int
    package let rejectedEyeCount: Int
    package let proposalPixelCount: Int
    package let changedPixelCount: Int
    package let maximumAbsoluteChannelDelta: Int
    package let reason: BeautyExperimentalUpperEyelidReliefEditReason

    package init(
        acceptedEyeCount: Int = 0,
        rejectedEyeCount: Int = 0,
        proposalPixelCount: Int = 0,
        changedPixelCount: Int = 0,
        maximumAbsoluteChannelDelta: Int = 0,
        reason: BeautyExperimentalUpperEyelidReliefEditReason = .noApprovedSupport
    ) {
        self.acceptedEyeCount = acceptedEyeCount
        self.rejectedEyeCount = rejectedEyeCount
        self.proposalPixelCount = proposalPixelCount
        self.changedPixelCount = changedPixelCount
        self.maximumAbsoluteChannelDelta = maximumAbsoluteChannelDelta
        self.reason = reason
    }
}

extension BeautyExperimentalUpperEyelidReliefEditSummary: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyExperimentalUpperEyelidReliefEditSummary(acceptedEyeCount: \(acceptedEyeCount), rejectedEyeCount: \(rejectedEyeCount), proposalPixelCount: \(proposalPixelCount), changedPixelCount: \(changedPixelCount), maximumAbsoluteChannelDelta: \(maximumAbsoluteChannelDelta), reason: \(reason.rawValue))"
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

package struct BeautyExperimentalUpperEyelidReliefEditRequest: Sendable {
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

extension BeautyExperimentalUpperEyelidReliefEditRequest: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyExperimentalUpperEyelidReliefEditRequest(strength: \(strength), supportedEyeCount: \(support.supportedEyeCount))"
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

package struct BeautyExperimentalUpperEyelidReliefEditResult: Sendable {
    package let summary: BeautyExperimentalUpperEyelidReliefEditSummary
    package let proposalsByEye: [[BeautyLocalPixelProposal]]

    package init(
        summary: BeautyExperimentalUpperEyelidReliefEditSummary,
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

extension BeautyExperimentalUpperEyelidReliefEditResult: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyExperimentalUpperEyelidReliefEditResult(proposalPixelCount: \(proposalPixelCount), changedPixelCount: \(summary.changedPixelCount), reason: \(summary.reason.rawValue))"
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

package enum BeautyExperimentalUpperEyelidReliefEditor {
    package static let maximumAbsoluteChannelDelta = 16

    package static func edit(
        source: BeautyCanonicalStillImage,
        support: BeautyUpperEyelidSupportResolution,
        strength: Double
    ) -> BeautyExperimentalUpperEyelidReliefEditResult {
        edit(BeautyExperimentalUpperEyelidReliefEditRequest(
            source: source,
            support: support,
            strength: strength
        ))
    }

    package static func edit(
        _ request: BeautyExperimentalUpperEyelidReliefEditRequest
    ) -> BeautyExperimentalUpperEyelidReliefEditResult {
        guard request.strength.isFinite,
              (0...1).contains(request.strength)
        else {
            return result(reason: .invalidStrength)
        }
        guard let sourceLayout = BeautyExperimentalUpperEyelidReliefSourceLayout(request.source) else {
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

            guard let reliefModel = BeautyExperimentalUpperEyelidReliefModel.analyze(
                source: request.source,
                pixels: pixels
            ), reliefModel.isFullnessSupported,
               reliefModel.samples.count == pixels.count,
               let corrections = reliefCorrections(
                   pixels: pixels,
                   samples: reliefModel.samples,
                   sourceLayout: sourceLayout,
                   strength: request.strength
               )
            else {
                rejectedEyeCount += 1
                continue
            }

            var proposals: [BeautyLocalPixelProposal] = []
            proposals.reserveCapacity(pixels.count)
            for ((pixel, reliefSample), correction) in zip(zip(pixels, reliefModel.samples), corrections) {
                let pixelIndex = pixel.pixelIndex
                guard reliefSample.pixelIndex == pixelIndex,
                      let sample = sourceLayout.sample(pixelIndex: pixelIndex)
                else {
                    continue
                }
                let target = (
                    red: safeTarget(source: sample.red, correction: correction),
                    green: safeTarget(source: sample.green, correction: correction),
                    blue: safeTarget(source: sample.blue, correction: correction)
                )

                // Shape the bounded correction field, never resample source RGB.
                // One scalar preserves source channel differences before Q16
                // feathering back to immutable source pixels.
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
            return BeautyExperimentalUpperEyelidReliefEditResult(
                summary: BeautyExperimentalUpperEyelidReliefEditSummary(
                    acceptedEyeCount: acceptedEyeCount,
                    rejectedEyeCount: rejectedEyeCount,
                    reason: .noApprovedSupport
                )
            )
        }
        return BeautyExperimentalUpperEyelidReliefEditResult(
            summary: BeautyExperimentalUpperEyelidReliefEditSummary(
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
        reason: BeautyExperimentalUpperEyelidReliefEditReason
    ) -> BeautyExperimentalUpperEyelidReliefEditResult {
        BeautyExperimentalUpperEyelidReliefEditResult(
            summary: BeautyExperimentalUpperEyelidReliefEditSummary(reason: reason)
        )
    }

    private static func validatedPixels(
        _ pixels: [BeautyUpperEyelidSupportPixel],
        sourceLayout: BeautyExperimentalUpperEyelidReliefSourceLayout
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

    private static func reliefCorrections(
        pixels: [BeautyUpperEyelidSupportPixel],
        samples: [BeautyExperimentalUpperEyelidReliefModel.Sample],
        sourceLayout: BeautyExperimentalUpperEyelidReliefSourceLayout,
        strength: Double
    ) -> [Int]? {
        // A blurred positive residual can spill onto a source pixel already
        // at or below its illumination plane. Bound darkening by BOTH fields
        // so neither gain nor blur spill can push it below its fitted reference.
        var limits: [Double] = []
        var residuals: [Double] = []
        var reconstructed: [Double] = []
        var offsets: [Int: Int] = [:]
        limits.reserveCapacity(samples.count)
        residuals.reserveCapacity(samples.count)
        reconstructed.reserveCapacity(samples.count)
        offsets.reserveCapacity(samples.count)
        for (offset, pair) in zip(pixels, samples).enumerated() {
            let (pixel, reliefSample) = pair
            guard pixel.pixelIndex == reliefSample.pixelIndex,
                  reliefSample.convexityResidual.isFinite,
                  reliefSample.referenceLuminance.isFinite,
                  let source = sourceLayout.sample(pixelIndex: pixel.pixelIndex),
                  let luminance = sourceLayout.luminance(pixelIndex: pixel.pixelIndex)
            else { return nil }
            // Admission retains its broad support-local box analysis. Editing
            // needs a shape guide that does not smear an interior peak into a
            // truncated support boundary, so read a small symmetric tent from
            // the complete source neighborhood, including protected neighbors.
            // Those neighbors guide the field only; proposals remain owned.
            let x = pixel.pixelIndex % sourceLayout.width
            let y = pixel.pixelIndex / sourceLayout.width
            guard x > 0, x + 1 < sourceLayout.width,
                  y > 0, y + 1 < sourceLayout.height
            else { return nil }
            var localLuminance = 0.0
            for dy in -1...1 {
                for dx in -1...1 {
                    let neighbor = (y + dy) * sourceLayout.width + x + dx
                    guard let value = sourceLayout.luminance(pixelIndex: neighbor) else { return nil }
                    let weight = (dx == 0 ? 2.0 : 1.0) * (dy == 0 ? 2.0 : 1.0)
                    localLuminance += Double(value) * weight / 16
                }
            }
            let residual = localLuminance - reliefSample.referenceLuminance
            let sourceHeadroom = max(0, Double(luminance) - reliefSample.referenceLuminance)
            let reliefHeadroom = max(0, residual)
            let channelHeadroom = Double(min(source.red, min(source.green, source.blue)))
            let limit = min(
                min(sourceHeadroom, reliefHeadroom),
                min(Double(maximumAbsoluteChannelDelta), channelHeadroom)
            )
            limits.append(limit)
            residuals.append(residual)
            offsets[pixel.pixelIndex] = offset
            // Full-strength marker includes the final feather exactly once.
            // Continuous values avoid quantizing before the strength slider.
            reconstructed.append(residual - limit * Double(pixel.softWeightQ16) / 65_536)
        }

        // Reconstruct the marker by geodesic dilation under the original
        // residual. Propagation only raises a corrected residual toward source,
        // filling edit-created troughs without crossing existing source valleys.
        // A descending priority flood finalizes each pixel once; there is no
        // convergence loop. Eight-neighbor ownership is local to this eye.
        var frontier = ReliefReconstructionFrontier(levels: reconstructed)
        var finalized = Array(repeating: false, count: samples.count)
        while let entry = frontier.pop() {
            let offset = entry.offset
            guard !finalized[offset], entry.level == reconstructed[offset] else { continue }
            finalized[offset] = true
            let index = samples[offset].pixelIndex
            let x = index % sourceLayout.width
            let y = index / sourceLayout.width
            for dy in -1...1 {
                for dx in -1...1 where dx != 0 || dy != 0 {
                    let neighborX = x + dx
                    let neighborY = y + dy
                    guard (0..<sourceLayout.width).contains(neighborX),
                          (0..<sourceLayout.height).contains(neighborY),
                          let neighbor = offsets[neighborY * sourceLayout.width + neighborX],
                          !finalized[neighbor]
                    else { continue }
                    let level = min(entry.level, residuals[neighbor])
                    if level > reconstructed[neighbor] {
                        reconstructed[neighbor] = level
                        frontier.insert(offset: neighbor, level: level)
                    }
                }
            }
        }

        return pixels.enumerated().map { offset, pixel in
            let fullFinalMagnitude = max(0, residuals[offset] - reconstructed[offset])
            let desiredFinalMagnitude = fullFinalMagnitude * strength
            let maximumRawMagnitude = Int(limits[offset].rounded(.down))
            var magnitude = 0
            var minimumError = desiredFinalMagnitude
            // Quantize the actual composed correction once, among at most 17
            // source-safe targets within the full reconstructed correction.
            // Do not floor a strength-scaled raw target
            // before quantizing the final feather: that biases weak edits down.
            // Ties keep the smaller target, including zero for no final change.
            for candidate in 0...maximumRawMagnitude {
                let actual = featheredMagnitude(candidate, weight: pixel.softWeightQ16)
                guard Double(actual) <= fullFinalMagnitude else { continue }
                let error = abs(Double(actual) - desiredFinalMagnitude)
                if error < minimumError {
                    minimumError = error
                    magnitude = candidate
                }
            }
            return -magnitude
        }
    }

    private static func featheredMagnitude(_ magnitude: Int, weight: UInt32) -> Int {
        // The compositor rounds RGB half-up. For a negative integer target
        // delta, exact half-byte ties therefore round toward the source.
        (magnitude * Int(weight) + 32_767) / 65_536
    }

    private struct ReliefReconstructionFrontier {
        struct Entry {
            let offset: Int
            let level: Double
        }

        private var entries: [Entry]

        init(levels: [Double]) {
            entries = levels.enumerated().map { Entry(offset: $0.offset, level: $0.element) }
            if entries.count > 1 {
                for parent in stride(from: entries.count / 2 - 1, through: 0, by: -1) {
                    siftDown(from: parent)
                }
            }
        }

        mutating func insert(offset: Int, level: Double) {
            entries.append(Entry(offset: offset, level: level))
            var child = entries.count - 1
            while child > 0 {
                let parent = (child - 1) / 2
                guard higher(entries[child], than: entries[parent]) else { break }
                entries.swapAt(child, parent)
                child = parent
            }
        }

        mutating func pop() -> Entry? {
            guard !entries.isEmpty else { return nil }
            let result = entries[0]
            let last = entries.removeLast()
            if !entries.isEmpty {
                entries[0] = last
                siftDown(from: 0)
            }
            return result
        }

        private mutating func siftDown(from start: Int) {
            var parent = start
            while parent * 2 + 1 < entries.count {
                var child = parent * 2 + 1
                if child + 1 < entries.count, higher(entries[child + 1], than: entries[child]) {
                    child += 1
                }
                guard higher(entries[child], than: entries[parent]) else { break }
                entries.swapAt(child, parent)
                parent = child
            }
        }

        private func higher(_ lhs: Entry, than rhs: Entry) -> Bool {
            lhs.level == rhs.level ? lhs.offset < rhs.offset : lhs.level > rhs.level
        }
    }

    private static func safeTarget(source: UInt8, correction: Int) -> UInt8 {
        let sourceValue = Int(source)
        let bounded = min(max(correction, -sourceValue), 255 - sourceValue)
        return UInt8(sourceValue + bounded)
    }
}
