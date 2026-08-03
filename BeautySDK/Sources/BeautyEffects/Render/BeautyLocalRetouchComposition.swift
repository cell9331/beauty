import BeautyCore
import Foundation

package struct BeautyLocalPixelProposal: Equatable, Sendable {
    package let pixelIndex: Int
    package let isInsideHardEnvelope: Bool
    package let softWeightQ16: UInt32
    package let targetRed: UInt8
    package let targetGreen: UInt8
    package let targetBlue: UInt8

    package init(
        pixelIndex: Int,
        isInsideHardEnvelope: Bool,
        softWeightQ16: UInt32,
        targetRed: UInt8,
        targetGreen: UInt8,
        targetBlue: UInt8
    ) {
        self.pixelIndex = pixelIndex
        self.isInsideHardEnvelope = isInsideHardEnvelope
        self.softWeightQ16 = softWeightQ16
        self.targetRed = targetRed
        self.targetGreen = targetGreen
        self.targetBlue = targetBlue
    }
}

private final class BeautyLocalRetouchOwnerIdentity {}

private struct BeautyLocalRetouchUnitTokenKey: Hashable {
    let ownerIdentity: ObjectIdentifier
    let token: UInt64
}

private struct BeautyPreflightedLocalRetouchClaim {
    let token: UInt64
    let proposal: BeautyLocalPixelProposal
    let effectiveWeightQ16: UInt64
}

package struct BeautyLocalRetouchUnit: Sendable {
    fileprivate let ownerIdentity: ObjectIdentifier
    fileprivate let sourceBinding: BeautyCanonicalPixelSourceBinding
    fileprivate let token: UInt64
    fileprivate let proposals: [BeautyLocalPixelProposal]
}

package struct BeautyLocalRetouchCompositionSummary: Equatable, Sendable {
    package let acceptedUnitCount: Int
    package let rejectedUnitCount: Int
    package let ownedPixelCount: Int
    package let changedPixelCount: Int
    package let changedOutsideUnionPixelCount: Int
    package let collisionPixelCount: Int

    package init(
        acceptedUnitCount: Int = 0,
        rejectedUnitCount: Int = 0,
        ownedPixelCount: Int = 0,
        changedPixelCount: Int = 0,
        changedOutsideUnionPixelCount: Int = 0,
        collisionPixelCount: Int = 0
    ) {
        self.acceptedUnitCount = acceptedUnitCount
        self.rejectedUnitCount = rejectedUnitCount
        self.ownedPixelCount = ownedPixelCount
        self.changedPixelCount = changedPixelCount
        self.changedOutsideUnionPixelCount = changedOutsideUnionPixelCount
        self.collisionPixelCount = collisionPixelCount
    }
}

package struct BeautyLocalRetouchCompositionResult: Sendable {
    package let canonicalImage: BeautyCanonicalStillImage
    package let summary: BeautyLocalRetouchCompositionSummary
}

package final class BeautyLocalRetouchCompositionOwner {
    package static let maximumUnitCount = 8

    private let source: BeautyCanonicalStillImage
    private let sourceBinding: BeautyCanonicalPixelSourceBinding
    private let ownerIdentity: BeautyLocalRetouchOwnerIdentity
    private let pixelCount: Int?
    private let effectiveUnitLimit: Int
    private let maximumClaimsPerUnit: Int
    private var nextToken: UInt64 = 0
    private var issuedTokens = Set<UInt64>()

    package init(source: BeautyCanonicalStillImage) {
        self.source = source
        sourceBinding = source.pixelSourceBinding
        ownerIdentity = BeautyLocalRetouchOwnerIdentity()

        let (checkedPixelCount, pixelOverflow) = source.width.multipliedReportingOverflow(by: source.height)
        let (checkedRowBytes, rowOverflow) = source.width.multipliedReportingOverflow(by: 4)
        let (checkedByteCount, byteOverflow) = source.rowBytes.multipliedReportingOverflow(by: source.height)
        let isLayoutValid = !pixelOverflow
            && !rowOverflow
            && !byteOverflow
            && checkedPixelCount > 0
            && checkedRowBytes == source.rowBytes
            && checkedByteCount == source.byteCount

        if isLayoutValid {
            pixelCount = checkedPixelCount
            effectiveUnitLimit = min(Self.maximumUnitCount, checkedPixelCount)
            maximumClaimsPerUnit = max(1, checkedPixelCount / effectiveUnitLimit)
        } else {
            pixelCount = nil
            effectiveUnitLimit = 0
            maximumClaimsPerUnit = 0
        }
    }

    package func makeUnit(
        proposals: [BeautyLocalPixelProposal]
    ) -> BeautyLocalRetouchUnit? {
        guard pixelCount != nil,
              issuedTokens.count < effectiveUnitLimit,
              nextToken < UInt64.max
        else {
            return nil
        }

        nextToken += 1
        issuedTokens.insert(nextToken)
        return BeautyLocalRetouchUnit(
            ownerIdentity: ObjectIdentifier(ownerIdentity),
            sourceBinding: sourceBinding,
            token: nextToken,
            proposals: proposals
        )
    }

    package func compose(
        _ units: [BeautyLocalRetouchUnit]
    ) throws -> BeautyLocalRetouchCompositionResult {
        guard let pixelCount else {
            return BeautyLocalRetouchCompositionResult(
                canonicalImage: source,
                summary: BeautyLocalRetouchCompositionSummary(rejectedUnitCount: units.count)
            )
        }

        let tokenFrequency = Dictionary(grouping: units) { unit in
            BeautyLocalRetouchUnitTokenKey(
                ownerIdentity: unit.ownerIdentity,
                token: unit.token
            )
        }.mapValues(\.count)
        var acceptedUnitCount = 0
        var rejectedUnitCount = 0
        var acceptedClaims: [BeautyPreflightedLocalRetouchClaim] = []

        for unit in units {
            let tokenKey = BeautyLocalRetouchUnitTokenKey(
                ownerIdentity: unit.ownerIdentity,
                token: unit.token
            )
            guard tokenFrequency[tokenKey] == 1,
                  issuedTokens.contains(unit.token),
                  unit.ownerIdentity == ObjectIdentifier(ownerIdentity),
                  unit.sourceBinding == sourceBinding,
                  !unit.proposals.isEmpty,
                  unit.proposals.count <= maximumClaimsPerUnit,
                  let effectiveClaims = preflightedClaims(unit, pixelCount: pixelCount)
            else {
                rejectedUnitCount += 1
                continue
            }
            acceptedUnitCount += 1
            acceptedClaims.append(contentsOf: effectiveClaims)
        }

        acceptedClaims.sort(by: claimsAreInDeterministicOrder)

        let sourceData = source.rgba8Data
        var outputData = sourceData
        var ownedPixelCount = 0
        var changedPixelCount = 0
        var claimIndex = 0

        while claimIndex < acceptedClaims.count {
            let groupStart = claimIndex
            let pixelIndex = acceptedClaims[claimIndex].proposal.pixelIndex
            repeat {
                claimIndex += 1
            } while claimIndex < acceptedClaims.count
                && acceptedClaims[claimIndex].proposal.pixelIndex == pixelIndex

            // Plan 55-03-02 owns collision accounting. Task 55-03-01 only
            // composes a pixel when exactly one preflighted unit owns it.
            guard claimIndex - groupStart == 1 else {
                continue
            }

            let claim = acceptedClaims[groupStart]
            guard let pixelOffset = checkedPixelOffset(pixelIndex),
                  let greenOffset = checkedChannelOffset(pixelOffset, channel: 1),
                  let blueOffset = checkedChannelOffset(pixelOffset, channel: 2),
                  let red = blendedChannel(
                    source: sourceData[pixelOffset],
                    target: claim.proposal.targetRed,
                    weightQ16: claim.effectiveWeightQ16
                  ),
                  let green = blendedChannel(
                    source: sourceData[greenOffset],
                    target: claim.proposal.targetGreen,
                    weightQ16: claim.effectiveWeightQ16
                  ),
                  let blue = blendedChannel(
                    source: sourceData[blueOffset],
                    target: claim.proposal.targetBlue,
                    weightQ16: claim.effectiveWeightQ16
                  )
            else {
                throw BeautyError.invalidInput
            }

            ownedPixelCount += 1
            if red != sourceData[pixelOffset]
                || green != sourceData[greenOffset]
                || blue != sourceData[blueOffset]
            {
                changedPixelCount += 1
                outputData[pixelOffset] = red
                outputData[greenOffset] = green
                outputData[blueOffset] = blue
            }
        }

        let canonicalImage: BeautyCanonicalStillImage
        if changedPixelCount == 0 {
            canonicalImage = source
        } else {
            canonicalImage = try BeautyCanonicalStillImage(
                rgba8Data: outputData,
                width: source.width,
                height: source.height,
                rowBytes: source.rowBytes,
                metadata: source.metadata
            )
        }

        return BeautyLocalRetouchCompositionResult(
            canonicalImage: canonicalImage,
            summary: BeautyLocalRetouchCompositionSummary(
                acceptedUnitCount: acceptedUnitCount,
                rejectedUnitCount: rejectedUnitCount,
                ownedPixelCount: ownedPixelCount,
                changedPixelCount: changedPixelCount
            )
        )
    }

    private func preflightedClaims(
        _ unit: BeautyLocalRetouchUnit,
        pixelCount: Int
    ) -> [BeautyPreflightedLocalRetouchClaim]? {
        var rawIndices = Set<Int>()
        var effectiveClaims: [BeautyPreflightedLocalRetouchClaim] = []

        for proposal in unit.proposals {
            guard proposal.pixelIndex >= 0,
                  proposal.pixelIndex < pixelCount,
                  rawIndices.insert(proposal.pixelIndex).inserted
            else {
                return nil
            }

            guard let pixelOffset = checkedPixelOffset(proposal.pixelIndex),
                  let alphaOffset = checkedChannelOffset(pixelOffset, channel: 3),
                  alphaOffset < source.byteCount
            else {
                return nil
            }

            if proposal.isInsideHardEnvelope, proposal.softWeightQ16 > 0 {
                effectiveClaims.append(
                    BeautyPreflightedLocalRetouchClaim(
                        token: unit.token,
                        proposal: proposal,
                        effectiveWeightQ16: min(UInt64(proposal.softWeightQ16), 65_536)
                    )
                )
            }
        }

        guard !effectiveClaims.isEmpty else {
            return nil
        }
        return effectiveClaims.sorted(by: claimsAreInDeterministicOrder)
    }

    private func claimsAreInDeterministicOrder(
        _ lhs: BeautyPreflightedLocalRetouchClaim,
        _ rhs: BeautyPreflightedLocalRetouchClaim
    ) -> Bool {
        if lhs.proposal.pixelIndex != rhs.proposal.pixelIndex {
            return lhs.proposal.pixelIndex < rhs.proposal.pixelIndex
        }
        return lhs.token < rhs.token
    }

    private func checkedPixelOffset(_ pixelIndex: Int) -> Int? {
        let (pixelOffset, overflow) = pixelIndex.multipliedReportingOverflow(by: 4)
        return overflow ? nil : pixelOffset
    }

    private func checkedChannelOffset(_ pixelOffset: Int, channel: Int) -> Int? {
        let (channelOffset, overflow) = pixelOffset.addingReportingOverflow(channel)
        return overflow ? nil : channelOffset
    }

    private func blendedChannel(
        source: UInt8,
        target: UInt8,
        weightQ16: UInt64
    ) -> UInt8? {
        guard weightQ16 <= 65_536 else {
            return nil
        }
        let sourceWeight = 65_536 - weightQ16
        let (sourceTerm, sourceOverflow) = UInt64(source).multipliedReportingOverflow(by: sourceWeight)
        let (targetTerm, targetOverflow) = UInt64(target).multipliedReportingOverflow(by: weightQ16)
        let (terms, termOverflow) = sourceTerm.addingReportingOverflow(targetTerm)
        let (rounded, roundingOverflow) = terms.addingReportingOverflow(32_768)
        guard !sourceOverflow,
              !targetOverflow,
              !termOverflow,
              !roundingOverflow,
              rounded / 65_536 <= UInt8.max
        else {
            return nil
        }
        return UInt8(rounded / 65_536)
    }
}
