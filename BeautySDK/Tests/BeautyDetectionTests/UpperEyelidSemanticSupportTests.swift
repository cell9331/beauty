import Foundation
import XCTest
@testable import BeautyDetection

final class UpperEyelidSemanticSupportTests: XCTestCase {
    func testApprovedEyeIsIndependentFromPeerNoOp() {
        let observation = observation()

        let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation,
            imageWidth: 100,
            imageHeight: 100
        ) { requests in
            [BeautyUpperEyelidSemanticApproval(
                side: requests[0].side,
                approved: true,
                confidence: 0.9,
                reason: .approved,
                pixels: Array(requests[0].maximumFeatheredPixels().prefix(1)),
                hardEnvelope: requests[0].permittedEnvelope
            )]
        }

        guard case let .supported(side, confidence, _, pixels, _) = resolution.left,
              case .sourceExactNoOp(.right, _, .semanticApprovalMissing) = resolution.right
        else {
            return XCTFail("expected independent supported/no-op outcomes")
        }
        XCTAssertEqual(side, .left)
        XCTAssertEqual(confidence, 0.9)
        XCTAssertEqual(pixels.count, 1)
        XCTAssertGreaterThan(pixels[0].softWeightQ16, 0)
    }

    func testMissingSemanticOwnerReturnsBothSourceExactNoOps() {
        let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(),
            imageWidth: 100,
            imageHeight: 100
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
            imageWidth: 100,
            imageHeight: 100,
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
            imageWidth: 100,
            imageHeight: 100,
            semanticOwner: approveFirstPixel
        )
        guard case .supported = missing.left else {
            return XCTFail("present left landmark must remain independently usable")
        }
        assertNoOp(missing.right, side: .right, reason: .missingEyeEnvelope)
    }

    func testMissingEyebrowAndCrossedBrowEyeGapFailClosedPerEye() {
        let missing = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(includeEyebrows: false),
            imageWidth: 100,
            imageHeight: 100,
            semanticOwner: approveFirstPixel
        )
        assertNoOp(missing.left, side: .left, reason: .missingEyebrowEnvelope)
        assertNoOp(missing.right, side: .right, reason: .missingEyebrowEnvelope)

        let base = observation()
        let crossed = BeautyFaceObservation(
            stableID: base.stableID,
            imageBounds: base.imageBounds,
            landmarks: base.landmarks,
            observedEyeSupport: base.observedEyeSupport,
            observedEyeOrder: base.observedEyeOrder,
            observedEyebrowSupport: BeautyObservedEyebrowSupport(
                left: [
                    CoordinatePoint(x: 0.18, y: 0.29),
                    CoordinatePoint(x: 0.30, y: 0.32),
                    CoordinatePoint(x: 0.42, y: 0.29),
                ],
                right: base.observedEyebrowSupport?.right
            )
        )
        let crossedResolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: crossed,
            imageWidth: 100,
            imageHeight: 100,
            semanticOwner: { requests in requests.map { Self.approval(for: $0) } }
        )
        assertNoOp(crossedResolution.left, side: .left, reason: .implausibleBrowEyeGap)
        guard case .supported = crossedResolution.right else {
            return XCTFail("a crossed left brow/eye gap must not suppress the valid right eye")
        }
    }

    func testPermittedBandStaysBetweenBrowAndEyeAndUsesEllipticalFeathering() throws {
        let capture = RequestCapture()
        _ = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(),
            imageWidth: 100,
            imageHeight: 100,
            semanticOwner: { requests in
                capture.store(requests)
                return []
            }
        )

        let request = try XCTUnwrap(capture.requests.first(where: { $0.side == .left }))
        XCTAssertGreaterThan(request.permittedEnvelope.minY, 0.20)
        XCTAssertLessThan(request.permittedEnvelope.maxY, 0.30)
        XCTAssertGreaterThan(request.permittedEnvelope.width, request.eyeEnvelope.width)

        let pixels = request.maximumFeatheredPixels()
        XCTAssertGreaterThan(pixels.count, 10)
        let weights = pixels.map(\.softWeightQ16)
        let minimumWeight = try XCTUnwrap(weights.min())
        let maximumWeight = try XCTUnwrap(weights.max())
        XCTAssertGreaterThan(minimumWeight, 0)
        XCTAssertLessThan(minimumWeight, maximumWeight)
        XCTAssertLessThanOrEqual(maximumWeight, 65_536)

        for pixel in pixels {
            let row = pixel.pixelIndex / request.imageWidth
            let y = (Double(row) + 0.5) / Double(request.imageHeight)
            XCTAssertGreaterThan(y, 0.20, "brow must remain protected")
            XCTAssertLessThan(y, 0.30, "eye and lash line must remain protected")
        }
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
                imageWidth: 100,
                imageHeight: 100,
                semanticOwner: { requests in
                    [Self.approval(for: requests[0], approved: false, confidence: 0.9, reason: reason)]
                }
            )
            assertNoOp(resolution.left, side: .left, reason: reason)
            assertNoOp(resolution.right, side: .right, reason: .semanticApprovalMissing)
        }
    }

    func testNonFiniteConfidenceAndMaskDataFailClosed() {
        for reason in [BeautyUpperEyelidSemanticReason.lowConfidence, .nonFiniteMask] {
            let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
                observation: observation(),
                imageWidth: 100,
                imageHeight: 100,
                semanticOwner: { requests in
                    guard let request = requests.first else { return [] }
                    return [BeautyUpperEyelidSemanticApproval(
                        side: .left,
                        approved: true,
                        confidence: reason == .lowConfidence ? .nan : 0.9,
                        reason: .approved,
                        pixels: Array(request.maximumFeatheredPixels().prefix(1)),
                        hardEnvelope: reason == .nonFiniteMask
                            ? CoordinateRect(x: .infinity, y: 0.2, width: 0.2, height: 0.2)
                            : request.permittedEnvelope
                    )]
                }
            )
            assertNoOp(resolution.left, side: .left, reason: reason)
        }
    }

    func testDuplicateOutOfBoundsAndOutOfEnvelopePixelsFailClosed() {
        for reason in [
            BeautyUpperEyelidSemanticReason.duplicatePixel,
            .outOfBoundsMask,
            .outsideHardEnvelope,
            .invalidSoftWeight,
        ] {
            let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
                observation: observation(),
                imageWidth: 100,
                imageHeight: 100,
                semanticOwner: { requests in
                    guard let request = requests.first,
                          let validPixel = request.maximumFeatheredPixels().first
                    else { return [] }
                    let pixels: [BeautyUpperEyelidSupportPixel]
                    switch reason {
                    case .duplicatePixel:
                        pixels = [validPixel, validPixel]
                    case .outOfBoundsMask:
                        pixels = [BeautyUpperEyelidSupportPixel(pixelIndex: 10_000, softWeightQ16: 1)]
                    case .invalidSoftWeight:
                        pixels = [BeautyUpperEyelidSupportPixel(pixelIndex: validPixel.pixelIndex, softWeightQ16: 65_537)]
                    default:
                        pixels = [BeautyUpperEyelidSupportPixel(pixelIndex: 0, softWeightQ16: 1)]
                    }
                    return [BeautyUpperEyelidSemanticApproval(
                        side: .left,
                        approved: true,
                        confidence: 0.9,
                        reason: .approved,
                        pixels: pixels,
                        hardEnvelope: request.permittedEnvelope
                    )]
                }
            )
            assertNoOp(resolution.left, side: .left, reason: reason)
        }
    }

    func testHardEnvelopeOutsideRequestedEyeIsRejected() {
        let resolution = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(),
            imageWidth: 100,
            imageHeight: 100,
            semanticOwner: { requests in
                let request = requests[0]
                let outside = CoordinateRect(
                    x: max(0, request.permittedEnvelope.minX - 0.02),
                    y: request.permittedEnvelope.minY,
                    width: request.permittedEnvelope.width,
                    height: request.permittedEnvelope.height
                )
                return [BeautyUpperEyelidSemanticApproval(
                    side: .left,
                    approved: true,
                    confidence: 0.9,
                    reason: .approved,
                    pixels: request.maximumFeatheredPixels(),
                    hardEnvelope: outside
                )]
            }
        )
        assertNoOp(resolution.left, side: .left, reason: .outsideHardEnvelope)
    }

    func testDuplicateApprovalsAndWrongSideApprovalCannotAuthorizeAnEye() {
        let duplicate = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(),
            imageWidth: 100,
            imageHeight: 100,
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
            imageWidth: 100,
            imageHeight: 100,
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
            observation: observation(), imageWidth: 100, imageHeight: 100, semanticOwner: owner
        )
        let second = BeautyUpperEyelidSemanticSupportOwner.resolve(
            observation: observation(), imageWidth: 100, imageHeight: 100, semanticOwner: owner
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
            imageWidth: 100,
            imageHeight: 100,
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
        supports: [BeautyObservedEyeSupport]? = nil,
        includeEyebrows: Bool = true
    ) -> BeautyFaceObservation {
        BeautyFaceObservation(
            stableID: "face-1",
            imageBounds: CoordinateRect(x: 0, y: 0, width: 1, height: 1),
            landmarks: landmarks,
            observedEyeSupport: supports ?? [
                BeautyObservedEyeSupport(
                    side: .left,
                    contour: [
                        CoordinatePoint(x: 0.20, y: 0.30),
                        CoordinatePoint(x: 0.40, y: 0.30),
                        CoordinatePoint(x: 0.40, y: 0.40),
                        CoordinatePoint(x: 0.20, y: 0.40),
                    ]
                ),
                BeautyObservedEyeSupport(
                    side: .right,
                    contour: [
                        CoordinatePoint(x: 0.60, y: 0.30),
                        CoordinatePoint(x: 0.80, y: 0.30),
                        CoordinatePoint(x: 0.80, y: 0.40),
                        CoordinatePoint(x: 0.60, y: 0.40),
                    ]
                ),
            ],
            observedEyeOrder: .canonical,
            observedEyebrowSupport: includeEyebrows ? BeautyObservedEyebrowSupport(
                left: [
                    CoordinatePoint(x: 0.18, y: 0.16),
                    CoordinatePoint(x: 0.30, y: 0.20),
                    CoordinatePoint(x: 0.42, y: 0.16),
                ],
                right: [
                    CoordinatePoint(x: 0.58, y: 0.16),
                    CoordinatePoint(x: 0.70, y: 0.20),
                    CoordinatePoint(x: 0.82, y: 0.16),
                ]
            ) : nil
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
            pixels: Array(request.maximumFeatheredPixels().prefix(1)),
            hardEnvelope: request.permittedEnvelope
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

private final class RequestCapture: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: [BeautyUpperEyelidSemanticRequest] = []

    func store(_ requests: [BeautyUpperEyelidSemanticRequest]) {
        lock.withLock { stored = requests }
    }

    var requests: [BeautyUpperEyelidSemanticRequest] {
        lock.withLock { stored }
    }
}
