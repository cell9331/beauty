import Foundation

package enum BeautyUpperEyelidSemanticReason: String, Equatable, Sendable {
    case approved
    case semanticOwnerUnavailable
    case semanticApprovalMissing
    case semanticApprovalRejected
    case missingEyeEnvelope
    case malformedEyeEnvelope
    case ambiguous
    case lowConfidence
    case closed
    case blinking
    case occluded
    case nonFiniteMask
    case outOfBoundsMask
    case duplicatePixel
    case outsideHardEnvelope
    case emptyMask
    case invalidImageDimensions
}

package struct BeautyUpperEyelidPoseOcclusionGuard: Equatable, Sendable {
    package let isClosed: Bool
    package let isBlinking: Bool
    package let isOccluded: Bool
    package let isAmbiguous: Bool

    package init(
        isClosed: Bool = false,
        isBlinking: Bool = false,
        isOccluded: Bool = false,
        isAmbiguous: Bool = false
    ) {
        self.isClosed = isClosed
        self.isBlinking = isBlinking
        self.isOccluded = isOccluded
        self.isAmbiguous = isAmbiguous
    }

    package var rejectionReason: BeautyUpperEyelidSemanticReason? {
        if isAmbiguous { return .ambiguous }
        if isOccluded { return .occluded }
        if isBlinking { return .blinking }
        if isClosed { return .closed }
        return nil
    }
}

/// Request-local semantic input. Coordinates are already image-normalized by
/// `CoordinateMapper`; this type deliberately has no conversion helpers.
package struct BeautyUpperEyelidSemanticRequest: Equatable, Sendable {
    package let side: BeautyObservedEyeSide
    package let observation: BeautyFaceObservation
    package let eyeEnvelope: CoordinateRect
    package let imageWidth: Int
    package let imageHeight: Int
    package let guardState: BeautyUpperEyelidPoseOcclusionGuard

    package init(
        side: BeautyObservedEyeSide,
        observation: BeautyFaceObservation,
        eyeEnvelope: CoordinateRect,
        imageWidth: Int,
        imageHeight: Int,
        guardState: BeautyUpperEyelidPoseOcclusionGuard = .init()
    ) {
        self.side = side
        self.observation = observation
        self.eyeEnvelope = eyeEnvelope
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.guardState = guardState
    }
}

/// Provider-owned authorization. Landmarks and guards can constrain this
/// value, but cannot create approval without `approved == true`.
package struct BeautyUpperEyelidSemanticApproval: Equatable, Sendable {
    package let side: BeautyObservedEyeSide
    package let approved: Bool
    package let confidence: Double
    package let reason: BeautyUpperEyelidSemanticReason
    package let pixelIndices: [Int]
    package let hardEnvelope: CoordinateRect

    package init(
        side: BeautyObservedEyeSide,
        approved: Bool,
        confidence: Double,
        reason: BeautyUpperEyelidSemanticReason,
        pixelIndices: [Int],
        hardEnvelope: CoordinateRect
    ) {
        self.side = side
        self.approved = approved
        self.confidence = confidence
        self.reason = reason
        self.pixelIndices = pixelIndices
        self.hardEnvelope = hardEnvelope
    }
}

package enum BeautyUpperEyelidEyeOutcome: Equatable, Sendable {
    case supported(
        side: BeautyObservedEyeSide,
        confidence: Double,
        reason: BeautyUpperEyelidSemanticReason,
        pixelIndices: [Int],
        hardEnvelope: CoordinateRect
    )
    case sourceExactNoOp(
        side: BeautyObservedEyeSide,
        confidence: Double,
        reason: BeautyUpperEyelidSemanticReason
    )

    package var side: BeautyObservedEyeSide {
        switch self {
        case .supported(let side, _, _, _, _), .sourceExactNoOp(let side, _, _):
            return side
        }
    }

    package var confidence: Double {
        switch self {
        case .supported(_, let confidence, _, _, _), .sourceExactNoOp(_, let confidence, _):
            return confidence
        }
    }

    package var reason: BeautyUpperEyelidSemanticReason {
        switch self {
        case .supported(_, _, let reason, _, _), .sourceExactNoOp(_, _, let reason):
            return reason
        }
    }

    package var pixelIndices: [Int] {
        switch self {
        case .supported(_, _, _, let pixelIndices, _):
            return pixelIndices
        case .sourceExactNoOp:
            return []
        }
    }

    package var hardEnvelope: CoordinateRect? {
        switch self {
        case .supported(_, _, _, _, let hardEnvelope):
            return hardEnvelope
        case .sourceExactNoOp:
            return nil
        }
    }

    package var isSupported: Bool {
        if case .supported = self { return true }
        return false
    }

    package var isSourceExactNoOp: Bool { !isSupported }
}

extension BeautyUpperEyelidEyeOutcome: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyUpperEyelidEyeOutcome(side: \(side.rawValue), status: \(isSupported ? "supported" : "sourceExactNoOp"), confidence: \(confidence), pixelCount: \(pixelIndices.count), reason: \(reason.rawValue))"
    }

    package var debugDescription: String { description }

    package var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "side": side.rawValue,
                "status": isSupported ? "supported" : "sourceExactNoOp",
                "confidence": confidence,
                "pixelCount": pixelIndices.count,
                "reason": reason.rawValue,
            ],
            displayStyle: .enum
        )
    }
}

package struct BeautyUpperEyelidSupportResolution: Equatable, Sendable {
    package let left: BeautyUpperEyelidEyeOutcome
    package let right: BeautyUpperEyelidEyeOutcome

    package init(
        left: BeautyUpperEyelidEyeOutcome,
        right: BeautyUpperEyelidEyeOutcome
    ) {
        self.left = left
        self.right = right
    }

    package var outcomes: [BeautyUpperEyelidEyeOutcome] { [left, right] }

    package var supportedEyeCount: Int {
        outcomes.reduce(into: 0) { count, outcome in
            if outcome.isSupported { count += 1 }
        }
    }
}

extension BeautyUpperEyelidSupportResolution: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyUpperEyelidSupportResolution(left: \(left.description), right: \(right.description), supportedEyeCount: \(supportedEyeCount))"
    }

    package var debugDescription: String { description }

    package var customMirror: Mirror {
        Mirror(
            self,
            children: [
                "left": left.description,
                "right": right.description,
                "supportedEyeCount": supportedEyeCount,
            ],
            displayStyle: .struct
        )
    }
}

package enum BeautyUpperEyelidSemanticSupportOwner {
    package typealias SemanticOwner = @Sendable ([BeautyUpperEyelidSemanticRequest]) -> [BeautyUpperEyelidSemanticApproval]

    package static let minimumConfidence = 0.5

    package static func resolve(
        observation: BeautyFaceObservation,
        imageWidth: Int,
        imageHeight: Int,
        semanticOwner: SemanticOwner? = nil
    ) -> BeautyUpperEyelidSupportResolution {
        let sides: [BeautyObservedEyeSide] = [.left, .right]
        guard imageWidth > 0, imageHeight > 0 else {
            return resolution(
                reason: .invalidImageDimensions,
                confidence: 0
            )
        }

        guard let semanticOwner else {
            return resolution(reason: .semanticOwnerUnavailable, confidence: 0)
        }

        let supports = observation.observedEyeSupport ?? []
        let sideCounts = Dictionary(grouping: supports, by: \ .side)
        let hasDuplicateSide = sideCounts.values.contains { $0.count != 1 }
        let hasExplicitAmbiguousOrder = supports.count == 2 && observation.observedEyeOrder != .canonical

        var requests: [BeautyUpperEyelidSemanticRequest] = []
        for side in sides {
            let requiredLandmark: BeautyLandmarkGroup = side == .left ? .leftEye : .rightEye
            guard !hasDuplicateSide,
                  !hasExplicitAmbiguousOrder,
                  observation.landmarks.availableGroups.contains(requiredLandmark),
                  let support = sideCounts[side]?.first,
                  let envelope = validEnvelope(for: support.contour)
            else {
                continue
            }
            requests.append(
                BeautyUpperEyelidSemanticRequest(
                    side: side,
                    observation: observation,
                    eyeEnvelope: envelope,
                    imageWidth: imageWidth,
                    imageHeight: imageHeight,
                    guardState: BeautyUpperEyelidPoseOcclusionGuard(
                        isAmbiguous: hasDuplicateSide || hasExplicitAmbiguousOrder
                    )
                )
            )
        }

        let approvals = requests.isEmpty ? [] : semanticOwner(requests)
        var approvalsBySide: [BeautyObservedEyeSide: [BeautyUpperEyelidSemanticApproval]] = [:]
        for approval in approvals {
            approvalsBySide[approval.side, default: []].append(approval)
        }

        return BeautyUpperEyelidSupportResolution(
            left: resolve(
                side: .left,
                request: requests.first(where: { $0.side == .left }),
                approvals: approvalsBySide[.left] ?? [],
                imageWidth: imageWidth,
                imageHeight: imageHeight,
                hasDuplicateSide: hasDuplicateSide,
                hasExplicitAmbiguousOrder: hasExplicitAmbiguousOrder
            ),
            right: resolve(
                side: .right,
                request: requests.first(where: { $0.side == .right }),
                approvals: approvalsBySide[.right] ?? [],
                imageWidth: imageWidth,
                imageHeight: imageHeight,
                hasDuplicateSide: hasDuplicateSide,
                hasExplicitAmbiguousOrder: hasExplicitAmbiguousOrder
            )
        )
    }

    private static func resolve(
        side: BeautyObservedEyeSide,
        request: BeautyUpperEyelidSemanticRequest?,
        approvals: [BeautyUpperEyelidSemanticApproval],
        imageWidth: Int,
        imageHeight: Int,
        hasDuplicateSide: Bool,
        hasExplicitAmbiguousOrder: Bool
    ) -> BeautyUpperEyelidEyeOutcome {
        guard !hasDuplicateSide, !hasExplicitAmbiguousOrder else {
            return .sourceExactNoOp(side: side, confidence: 0, reason: .ambiguous)
        }
        guard let request else {
            return .sourceExactNoOp(side: side, confidence: 0, reason: .missingEyeEnvelope)
        }
        guard approvals.count == 1, let approval = approvals.first else {
            return .sourceExactNoOp(side: side, confidence: 0, reason: .semanticApprovalMissing)
        }
        guard approval.side == side else {
            return .sourceExactNoOp(side: side, confidence: 0, reason: .semanticApprovalRejected)
        }

        if let guardReason = request.guardState.rejectionReason {
            return .sourceExactNoOp(side: side, confidence: 0, reason: guardReason)
        }
        guard approval.approved else {
            return .sourceExactNoOp(
                side: side,
                confidence: boundedConfidence(approval.confidence),
                reason: rejectionReason(approval.reason)
            )
        }
        guard approval.reason == .approved else {
            return .sourceExactNoOp(
                side: side,
                confidence: boundedConfidence(approval.confidence),
                reason: rejectionReason(approval.reason)
            )
        }
        guard approval.confidence.isFinite,
              (0...1).contains(approval.confidence)
        else {
            return .sourceExactNoOp(side: side, confidence: 0, reason: .lowConfidence)
        }
        guard approval.confidence >= minimumConfidence else {
            return .sourceExactNoOp(side: side, confidence: approval.confidence, reason: .lowConfidence)
        }
        guard validEnvelope(for: request.eyeEnvelope) else {
            return .sourceExactNoOp(side: side, confidence: approval.confidence, reason: .malformedEyeEnvelope)
        }
        guard validEnvelope(for: approval.hardEnvelope) else {
            return .sourceExactNoOp(side: side, confidence: approval.confidence, reason: .nonFiniteMask)
        }
        guard contains(request.eyeEnvelope, approval.hardEnvelope) else {
            return .sourceExactNoOp(side: side, confidence: approval.confidence, reason: .outsideHardEnvelope)
        }
        guard !approval.pixelIndices.isEmpty else {
            return .sourceExactNoOp(side: side, confidence: approval.confidence, reason: .emptyMask)
        }

        let (count, overflow) = imageWidth.multipliedReportingOverflow(by: imageHeight)
        guard !overflow, count > 0 else {
            return .sourceExactNoOp(side: side, confidence: approval.confidence, reason: .invalidImageDimensions)
        }
        let pixelCount = count
        var uniquePixels = Set<Int>()
        for pixelIndex in approval.pixelIndices {
            guard uniquePixels.insert(pixelIndex).inserted else {
                return .sourceExactNoOp(side: side, confidence: approval.confidence, reason: .duplicatePixel)
            }
            guard pixelIndex >= 0, pixelIndex < pixelCount else {
                return .sourceExactNoOp(side: side, confidence: approval.confidence, reason: .outOfBoundsMask)
            }
            guard let point = pixelCenter(
                for: pixelIndex,
                imageWidth: imageWidth,
                imageHeight: imageHeight
            ), contains(approval.hardEnvelope, point: point) else {
                return .sourceExactNoOp(side: side, confidence: approval.confidence, reason: .outsideHardEnvelope)
            }
        }

        return .supported(
            side: side,
            confidence: approval.confidence,
            reason: .approved,
            pixelIndices: approval.pixelIndices,
            hardEnvelope: approval.hardEnvelope
        )
    }

    private static func resolution(
        reason: BeautyUpperEyelidSemanticReason,
        confidence: Double
    ) -> BeautyUpperEyelidSupportResolution {
        BeautyUpperEyelidSupportResolution(
            left: .sourceExactNoOp(side: .left, confidence: confidence, reason: reason),
            right: .sourceExactNoOp(side: .right, confidence: confidence, reason: reason)
        )
    }

    private static func validEnvelope(for rect: CoordinateRect) -> Bool {
        rect.isFinite
            && rect.width > 0
            && rect.height > 0
            && rect.minX >= 0
            && rect.minY >= 0
            && rect.maxX <= 1
            && rect.maxY <= 1
    }

    private static func validEnvelope(for points: [CoordinatePoint]) -> CoordinateRect? {
        guard !points.isEmpty,
              points.allSatisfy({
                  $0.isFinite && (0...1).contains($0.x) && (0...1).contains($0.y)
              })
        else {
            return nil
        }
        let rect = CoordinateRect.bounding(points)
        return validEnvelope(for: rect) ? rect : nil
    }

    private static func contains(_ outer: CoordinateRect, _ inner: CoordinateRect) -> Bool {
        inner.minX >= outer.minX
            && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX
            && inner.maxY <= outer.maxY
    }

    private static func contains(_ rect: CoordinateRect, point: CoordinatePoint) -> Bool {
        point.isFinite
            && point.x >= rect.minX
            && point.x <= rect.maxX
            && point.y >= rect.minY
            && point.y <= rect.maxY
    }

    private static func pixelCenter(
        for pixelIndex: Int,
        imageWidth: Int,
        imageHeight: Int
    ) -> CoordinatePoint? {
        guard imageWidth > 0, imageHeight > 0 else { return nil }
        let column = pixelIndex % imageWidth
        let row = pixelIndex / imageWidth
        let point = CoordinatePoint(
            x: (Double(column) + 0.5) / Double(imageWidth),
            y: (Double(row) + 0.5) / Double(imageHeight)
        )
        return point.isFinite ? point : nil
    }

    private static func boundedConfidence(_ confidence: Double) -> Double {
        guard confidence.isFinite else { return 0 }
        return min(max(confidence, 0), 1)
    }

    private static func rejectionReason(_ reason: BeautyUpperEyelidSemanticReason) -> BeautyUpperEyelidSemanticReason {
        reason == .approved ? .semanticApprovalRejected : reason
    }
}
