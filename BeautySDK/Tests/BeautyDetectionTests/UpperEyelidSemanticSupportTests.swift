import Foundation
import XCTest
@testable import BeautyDetection

final class UpperEyelidSemanticSupportTests: XCTestCase {
    func testApprovedEyeIsIndependentFromPeerNoOp() {
        let observation = BeautyFaceObservation(
            stableID: "face-1",
            imageBounds: CoordinateRect(x: 0, y: 0, width: 1, height: 1),
            observedEyeSupport: [
                BeautyObservedEyeSupport(
                    side: .left,
                    contour: [
                        CoordinatePoint(x: 0.20, y: 0.20),
                        CoordinatePoint(x: 0.40, y: 0.20),
                        CoordinatePoint(x: 0.40, y: 0.40),
                        CoordinatePoint(x: 0.20, y: 0.40),
                    ]
                ),
                BeautyObservedEyeSupport(
                    side: .right,
                    contour: [
                        CoordinatePoint(x: 0.60, y: 0.20),
                        CoordinatePoint(x: 0.80, y: 0.20),
                        CoordinatePoint(x: 0.80, y: 0.40),
                        CoordinatePoint(x: 0.60, y: 0.40),
                    ]
                ),
            ],
            observedEyeOrder: .canonical
        )

        let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation,
            imageWidth: 10,
            imageHeight: 10
        ) { requests in
            [BeautyUpperEyelidSemanticApproval(
                side: requests[0].side,
                approved: true,
                confidence: 0.9,
                reason: .approved,
                pixelIndices: [22],
                hardEnvelope: requests[0].eyeEnvelope
            )]
        }

        guard case let .supported(side, confidence, _, pixels, _) = resolution.left,
              case .sourceExactNoOp(.right, _, .semanticApprovalMissing) = resolution.right
        else {
            return XCTFail("expected independent supported/no-op outcomes")
        }
        XCTAssertEqual(side, .left)
        XCTAssertEqual(confidence, 0.9)
        XCTAssertEqual(pixels, [22])
    }

    func testMissingSemanticOwnerReturnsBothSourceExactNoOps() {
        let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(),
            imageWidth: 10,
            imageHeight: 10
        )

        assertNoOp(resolution.left, side: .left, reason: .semanticOwnerUnavailable)
        assertNoOp(resolution.right, side: .right, reason: .semanticOwnerUnavailable)
    }

    func testMissingEyeAndMalformedEyeLandmarksDegradeIndependently() {
        let malformedRight = BeautyObservedEyeSupport(
            side: .right,
            contour: [
                CoordinatePoint(x: .nan, y: 0.2),
                CoordinatePoint(x: 0.8, y: 0.4),
            ]
        )
        let leftOnly = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(supports: [
                try! XCTUnwrap(observation().observedEyeSupport?.first),
                malformedRight,
            ]),
            imageWidth: 10,
            imageHeight: 10,
            semanticOwner: approveFirstPixel
        )
        guard case .supported = leftOnly.left else {
            return XCTFail("malformed right eye must not suppress valid left support")
        }
        assertNoOp(leftOnly.right, side: .right, reason: .missingEyeEnvelope)

        let missingRightLandmark = observation(
            landmarks: BeautyFaceLandmarks(availableGroups: [.leftEye]),
            supports: observation().observedEyeSupport
        )
        let missing = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: missingRightLandmark,
            imageWidth: 10,
            imageHeight: 10,
            semanticOwner: approveFirstPixel
        )
        guard case .supported = missing.left else {
            return XCTFail("present left landmark must remain independently usable")
        }
        assertNoOp(missing.right, side: .right, reason: .missingEyeEnvelope)
    }

    func testRejectedReasonsAlwaysProduceTypedSourceExactNoOp() {
        for reason in [
            BeautyUpperEyelidSemanticReason.semanticApprovalRejected,
            .closed,
            .blinking,
            .occluded,
            .ambiguous,
            .lowConfidence,
        ] {
            let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
                observation: observation(),
                imageWidth: 10,
                imageHeight: 10,
                semanticOwner: { requests in
                    [Self.approval(for: requests[0], approved: false, confidence: 0.9, reason: reason)]
                }
            )
            assertNoOp(resolution.left, side: .left, reason: reason)
            assertNoOp(resolution.right, side: .right, reason: .semanticApprovalMissing)
        }
    }

    func testNonFiniteConfidenceAndMaskDataFailClosed() {
        let cases: [(BeautyUpperEyelidSemanticReason, BeautyUpperEyelidSemanticApproval)] = [
            (
                .lowConfidence,
                BeautyUpperEyelidSemanticApproval(
                    side: .left,
                    approved: true,
                    confidence: .nan,
                    reason: .approved,
                    pixelIndices: [22],
                    hardEnvelope: CoordinateRect(x: 0.2, y: 0.2, width: 0.2, height: 0.2)
                )
            ),
            (
                .nonFiniteMask,
                BeautyUpperEyelidSemanticApproval(
                    side: .left,
                    approved: true,
                    confidence: 0.9,
                    reason: .approved,
                    pixelIndices: [22],
                    hardEnvelope: CoordinateRect(x: .infinity, y: 0.2, width: 0.2, height: 0.2)
                )
            ),
        ]

        for (reason, expectedApproval) in cases {
            let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
                observation: observation(),
                imageWidth: 10,
                imageHeight: 10,
                semanticOwner: { _ in [expectedApproval] }
            )
            assertNoOp(resolution.left, side: .left, reason: reason)
        }
    }

    func testDuplicateOutOfBoundsAndOutOfEnvelopePixelsFailClosed() {
        let cases: [(BeautyUpperEyelidSemanticReason, [Int], CoordinateRect)] = [
            (.duplicatePixel, [22, 22], CoordinateRect(x: 0.2, y: 0.2, width: 0.2, height: 0.2)),
            (.outOfBoundsMask, [100], CoordinateRect(x: 0.2, y: 0.2, width: 0.2, height: 0.2)),
            (.outsideHardEnvelope, [11], CoordinateRect(x: 0.2, y: 0.2, width: 0.2, height: 0.2)),
        ]

        for (reason, pixels, envelope) in cases {
            let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
                observation: observation(),
                imageWidth: 10,
                imageHeight: 10,
                semanticOwner: { requests in
                    [BeautyUpperEyelidSemanticApproval(
                        side: .left,
                        approved: true,
                        confidence: 0.9,
                        reason: .approved,
                        pixelIndices: pixels,
                        hardEnvelope: envelope
                    )]
                }
            )
            assertNoOp(resolution.left, side: .left, reason: reason)
        }
    }

    func testHardEnvelopeOutsideRequestedEyeIsRejected() {
        let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(),
            imageWidth: 10,
            imageHeight: 10,
            semanticOwner: { requests in
                [BeautyUpperEyelidSemanticApproval(
                    side: .left,
                    approved: true,
                    confidence: 0.9,
                    reason: .approved,
                    pixelIndices: [22],
                    hardEnvelope: CoordinateRect(x: 0.1, y: 0.2, width: 0.2, height: 0.2)
                )]
            }
        )
        assertNoOp(resolution.left, side: .left, reason: .outsideHardEnvelope)
    }

    func testDuplicateApprovalsAndWrongSideApprovalCannotAuthorizeAnEye() {
        let duplicate = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(),
            imageWidth: 10,
            imageHeight: 10,
            semanticOwner: { requests in
                [
                    Self.approval(for: requests[0]),
                    Self.approval(for: requests[0]),
                ]
            }
        )
        assertNoOp(duplicate.left, side: .left, reason: .semanticApprovalMissing)

        let wrongSide = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(),
            imageWidth: 10,
            imageHeight: 10,
            semanticOwner: { requests in
                [Self.approval(for: requests[1])]
            }
        )
        assertNoOp(wrongSide.left, side: .left, reason: .semanticApprovalMissing)
        guard case .supported = wrongSide.right else {
            return XCTFail("an approved peer must remain supported")
        }
    }

    func testResolutionIsDeterministicAndRequestsCarryOneSelectedObservation() {
        let capture = ObservationCapture()
        let owner: BeautyUpperEyelidSemanticSupportOwner.SemanticOwner = { requests in
            capture.append(requests.map(\.observation))
            return requests.map { Self.approval(for: $0) }
        }

        let first = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(), imageWidth: 10, imageHeight: 10, semanticOwner: owner
        )
        let second = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(), imageWidth: 10, imageHeight: 10, semanticOwner: owner
        )

        XCTAssertEqual(first, second)
        let requestedObservations = capture.values
        XCTAssertEqual(requestedObservations.count, 2)
        XCTAssertEqual(requestedObservations[0].map(\.stableID), ["face-1", "face-1"])
        XCTAssertEqual(requestedObservations[1].map(\.stableID), ["face-1", "face-1"])
    }

    func testResolutionDiagnosticsExposeAggregatesOnly() {
        let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(),
            imageWidth: 10,
            imageHeight: 10,
            semanticOwner: approveFirstPixel
        )
        let rendered = [
            resolution.description,
            resolution.debugDescription,
            String(describing: Mirror(reflecting: resolution)),
        ].joined(separator: " ").lowercased()
        XCTAssertTrue(rendered.contains("supportedeyecount"))
        XCTAssertTrue(rendered.contains("pixelcount"))
        for forbidden in ["coordinatepoint", "point(", "mask(", "22", "/private/", "file://", "fixture"] {
            XCTAssertFalse(rendered.contains(forbidden), forbidden)
        }
    }

    private var approveFirstPixel: BeautyUpperEyelidSemanticSupportOwner.SemanticOwner {
        { requests in
            guard let request = requests.first else { return [] }
            return [Self.approval(for: request)]
        }
    }

    private func observation(
        landmarks: BeautyFaceLandmarks = .complete,
        supports: [BeautyObservedEyeSupport]? = nil
    ) -> BeautyFaceObservation {
        BeautyFaceObservation(
            stableID: "face-1",
            imageBounds: CoordinateRect(x: 0, y: 0, width: 1, height: 1),
            landmarks: landmarks,
            observedEyeSupport: supports ?? [
                BeautyObservedEyeSupport(
                    side: .left,
                    contour: [
                        CoordinatePoint(x: 0.20, y: 0.20),
                        CoordinatePoint(x: 0.40, y: 0.20),
                        CoordinatePoint(x: 0.40, y: 0.40),
                        CoordinatePoint(x: 0.20, y: 0.40),
                    ]
                ),
                BeautyObservedEyeSupport(
                    side: .right,
                    contour: [
                        CoordinatePoint(x: 0.60, y: 0.20),
                        CoordinatePoint(x: 0.80, y: 0.20),
                        CoordinatePoint(x: 0.80, y: 0.40),
                        CoordinatePoint(x: 0.60, y: 0.40),
                    ]
                ),
            ],
            observedEyeOrder: .canonical
        )
    }

    private func assertNoOp(
        _ outcome: BeautyUpperEyelidEyeOutcome,
        side: BeautyObservedEyeSide,
        reason: BeautyUpperEyelidSemanticReason,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case let .sourceExactNoOp(actualSide, _, actualReason) = outcome else {
            return XCTFail("expected source-exact no-op", file: file, line: line)
        }
        XCTAssertEqual(actualSide, side, file: file, line: line)
        XCTAssertEqual(actualReason, reason, file: file, line: line)
        XCTAssertTrue(outcome.pixelIndices.isEmpty, file: file, line: line)
    }

    private static func approval(
        for request: BeautyUpperEyelidSemanticRequest,
        approved: Bool = true,
        confidence: Double = 0.9,
        reason: BeautyUpperEyelidSemanticReason = .approved
    ) -> BeautyUpperEyelidSemanticApproval {
        BeautyUpperEyelidSemanticApproval(
            side: request.side,
            approved: approved,
            confidence: confidence,
            reason: reason,
            pixelIndices: request.side == .left ? [22] : [27],
            hardEnvelope: request.eyeEnvelope
        )
    }
}

private final class ObservationCapture: @unchecked Sendable {
    private let lock = NSLock()
    private var storedValues: [[BeautyFaceObservation]] = []

    func append(_ observations: [BeautyFaceObservation]) {
        lock.lock()
        storedValues.append(observations)
        lock.unlock()
    }

    var values: [[BeautyFaceObservation]] {
        lock.lock()
        defer { lock.unlock() }
        return storedValues
    }
}
