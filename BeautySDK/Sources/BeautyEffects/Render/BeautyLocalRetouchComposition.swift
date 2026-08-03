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
                  isStructurallyValid(unit, pixelCount: pixelCount)
            else {
                rejectedUnitCount += 1
                continue
            }
            acceptedUnitCount += 1
        }

        return BeautyLocalRetouchCompositionResult(
            canonicalImage: source,
            summary: BeautyLocalRetouchCompositionSummary(
                acceptedUnitCount: acceptedUnitCount,
                rejectedUnitCount: rejectedUnitCount
            )
        )
    }

    private func isStructurallyValid(
        _ unit: BeautyLocalRetouchUnit,
        pixelCount: Int
    ) -> Bool {
        var rawIndices = Set<Int>()
        var hasEffectiveClaim = false

        for proposal in unit.proposals {
            guard proposal.pixelIndex >= 0,
                  proposal.pixelIndex < pixelCount,
                  rawIndices.insert(proposal.pixelIndex).inserted
            else {
                return false
            }

            let (pixelOffset, offsetOverflow) = proposal.pixelIndex.multipliedReportingOverflow(by: 4)
            let (alphaOffset, channelOverflow) = pixelOffset.addingReportingOverflow(3)
            guard !offsetOverflow,
                  !channelOverflow,
                  alphaOffset < source.byteCount
            else {
                return false
            }

            if proposal.isInsideHardEnvelope, proposal.softWeightQ16 > 0 {
                hasEffectiveClaim = true
            }
        }

        return hasEffectiveClaim
    }
}
