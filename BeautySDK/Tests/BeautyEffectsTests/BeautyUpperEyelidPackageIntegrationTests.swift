import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

/// Package-only integration coverage for the still-image candidate. This suite
/// deliberately starts at the detector route and never constructs a support
/// resolution in the test: the detector-owned result is handed directly to the
/// editor, then to the immutable-source composition owner.
final class BeautyUpperEyelidPackageIntegrationTests: XCTestCase {
    func testOneObservationFlowsThroughIndependentEyeResolutionEditorAndComposition() throws {
        let source = try canonical()
        let provider = UpperEyelidIntegrationObservationProvider(support: standardSupport)
        let semanticOwner = UpperEyelidIntegrationSemanticOwner(mode: .acceptLeftRejectRight)
        var detector = VisionFaceDetector(observationProvider: provider.call)

        let detected = detector.detectWithUpperEyelidSupport(
            image: source.ciImage,
            metadata: source.metadata,
            imageExtent: CGSize(width: source.width, height: source.height),
            semanticOwner: semanticOwner.call
        )

        XCTAssertEqual(provider.callCount, 1)
        XCTAssertEqual(semanticOwner.callCount, 1)
        XCTAssertEqual(semanticOwner.observationIDs, ["integration-face", "integration-face"])
        XCTAssertEqual(detected.summary.faceCount, 1)
        XCTAssertEqual(detected.supportResolution.supportedEyeCount, 1)
        guard case .supported(.left, _, .approved, let acceptedPixels, _) = detected.supportResolution.left,
              case .sourceExactNoOp(.right, _, .semanticApprovalRejected) = detected.supportResolution.right
        else {
            return XCTFail("expected one accepted eye and one typed source-exact peer no-op")
        }

        // F-03 provenance: consume the detector-returned resolution directly.
        let edit = BeautyUpperEyelidFullnessEditor.edit(
            source: source,
            support: detected.supportResolution,
            strength: 0.75
        )
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let units = edit.makeUnits(using: owner)
        let composed = try owner.compose(units)

        XCTAssertEqual(acceptedPixels, [try XCTUnwrap(semanticOwner.leftCandidatePixel)])
        XCTAssertEqual(units.count, 1)
        XCTAssertEqual(edit.summary.acceptedEyeCount, 1)
        XCTAssertEqual(edit.summary.rejectedEyeCount, 1)
        XCTAssertEqual(edit.summary.changedPixelCount, 1)
        XCTAssertGreaterThan(edit.summary.maximumAbsoluteChannelDelta, 0)
        XCTAssertLessThanOrEqual(
            edit.summary.maximumAbsoluteChannelDelta,
            BeautyUpperEyelidFullnessEditor.maximumAbsoluteChannelDelta
        )
        XCTAssertEqual(composed.summary.acceptedUnitCount, 1)
        XCTAssertEqual(composed.summary.rejectedUnitCount, 0)
        XCTAssertEqual(composed.summary.ownedPixelCount, 1)
        XCTAssertEqual(composed.summary.changedPixelCount, 1)
        XCTAssertEqual(composed.summary.changedOutsideUnionPixelCount, 0)
        XCTAssertEqual(composed.summary.collisionPixelCount, 0)

        XCTAssertEqual(composed.canonicalImage.width, source.width)
        XCTAssertEqual(composed.canonicalImage.height, source.height)
        XCTAssertEqual(composed.canonicalImage.rowBytes, source.rowBytes)
        XCTAssertEqual(composed.canonicalImage.metadata, source.metadata)
        assertOnlyPixels(acceptedPixels, mayDifferBetween: source, and: composed.canonicalImage)
        assertPixel(
            try XCTUnwrap(semanticOwner.rightCandidatePixel),
            isSourceExactBetween: source,
            and: composed.canonicalImage,
            message: "rejected peer"
        )
        for protectedPixel in [0, 7, 27, 28, 35, 63] {
            assertPixel(
                protectedPixel,
                isSourceExactBetween: source,
                and: composed.canonicalImage,
                message: "exterior/protected"
            )
        }

        let repeatedProvider = UpperEyelidIntegrationObservationProvider(support: standardSupport)
        let repeatedSemanticOwner = UpperEyelidIntegrationSemanticOwner(mode: .acceptLeftRejectRight)
        var repeatedDetector = VisionFaceDetector(observationProvider: repeatedProvider.call)
        let repeatedDetection = repeatedDetector.detectWithUpperEyelidSupport(
            image: source.ciImage,
            metadata: source.metadata,
            imageExtent: CGSize(width: source.width, height: source.height),
            semanticOwner: repeatedSemanticOwner.call
        )
        let repeatedEdit = BeautyUpperEyelidFullnessEditor.edit(
            source: source,
            support: repeatedDetection.supportResolution,
            strength: 0.75
        )
        let repeatedOwner = BeautyLocalRetouchCompositionOwner(source: source)
        let repeated = try repeatedOwner.compose(repeatedEdit.makeUnits(using: repeatedOwner))

        XCTAssertEqual(repeatedProvider.callCount, 1)
        XCTAssertEqual(repeatedSemanticOwner.callCount, 1)
        XCTAssertEqual(repeatedDetection.supportResolution, detected.supportResolution)
        XCTAssertEqual(repeatedEdit.summary, edit.summary)
        XCTAssertEqual(repeatedEdit.proposalsByEye, edit.proposalsByEye)
        XCTAssertEqual(repeated.summary, composed.summary)
        XCTAssertEqual(repeated.canonicalImage.rgba8Data, composed.canonicalImage.rgba8Data)

        let diagnostics = [
            String(describing: detected),
            detected.debugDescription,
            String(describing: detected.supportResolution),
            detected.supportResolution.debugDescription,
            String(describing: edit),
            edit.debugDescription,
            String(describing: composed.summary),
        ].joined(separator: " ").lowercased()
        for forbidden in [
            "integration-face", "pixelindices", "coordinatepoint", "landmark",
            "rgba8data", "file://", "/private/", "mask=[", "pixels=[",
        ] {
            XCTAssertFalse(diagnostics.contains(forbidden), "diagnostic leaked \(forbidden)")
        }
    }

    func testOverlappingAcceptedEyesReturnCollisionPixelToImmutableSource() throws {
        let source = try canonical()
        let provider = UpperEyelidIntegrationObservationProvider(support: [
            BeautyObservedEyeSupport(side: .left, contour: eyeContour(minX: 0.20, maxX: 0.60)),
            BeautyObservedEyeSupport(side: .right, contour: eyeContour(minX: 0.40, maxX: 0.80)),
        ])
        let semanticOwner = UpperEyelidIntegrationSemanticOwner(mode: .acceptBothAtSamePixel)
        var detector = VisionFaceDetector(observationProvider: provider.call)

        let detected = detector.detectWithUpperEyelidSupport(
            image: source.ciImage,
            metadata: source.metadata,
            imageExtent: CGSize(width: source.width, height: source.height),
            semanticOwner: semanticOwner.call
        )
        let edit = BeautyUpperEyelidFullnessEditor.edit(
            source: source,
            support: detected.supportResolution,
            strength: 1
        )
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let composed = try owner.compose(edit.makeUnits(using: owner))

        XCTAssertEqual(provider.callCount, 1)
        XCTAssertEqual(semanticOwner.callCount, 1)
        XCTAssertEqual(detected.supportResolution.supportedEyeCount, 2)
        XCTAssertEqual(edit.summary.acceptedEyeCount, 2)
        XCTAssertEqual(composed.summary.acceptedUnitCount, 2)
        XCTAssertEqual(composed.summary.collisionPixelCount, 1)
        XCTAssertEqual(composed.summary.ownedPixelCount, 0)
        XCTAssertEqual(composed.summary.changedPixelCount, 0)
        XCTAssertEqual(composed.canonicalImage.rgba8Data, source.rgba8Data)
        XCTAssertEqual(composed.canonicalImage.metadata, source.metadata)
    }

    func testMissingMalformedAndLowConfidencePeerSupportFailClosedPerEye() throws {
        let cases: [(String, [BeautyObservedEyeSupport], UpperEyelidIntegrationSemanticOwner.Mode, BeautyUpperEyelidSemanticReason)] = [
            (
                "missing",
                [BeautyObservedEyeSupport(side: .left, contour: eyeContour(minX: 0.15, maxX: 0.35))],
                .approveEveryRequest,
                .missingEyeEnvelope
            ),
            (
                "malformed",
                [
                    BeautyObservedEyeSupport(side: .left, contour: eyeContour(minX: 0.15, maxX: 0.35)),
                    BeautyObservedEyeSupport(side: .right, contour: [CoordinatePoint(x: .nan, y: 0.25)]),
                ],
                .approveEveryRequest,
                .missingEyeEnvelope
            ),
            (
                "low-confidence",
                standardSupport,
                .acceptLeftLowConfidenceRight,
                .lowConfidence
            ),
        ]

        for (name, support, mode, expectedReason) in cases {
            let source = try canonical()
            let provider = UpperEyelidIntegrationObservationProvider(support: support)
            let semanticOwner = UpperEyelidIntegrationSemanticOwner(mode: mode)
            var detector = VisionFaceDetector(observationProvider: provider.call)
            let detected = detector.detectWithUpperEyelidSupport(
                image: source.ciImage,
                metadata: source.metadata,
                imageExtent: CGSize(width: source.width, height: source.height),
                semanticOwner: semanticOwner.call
            )

            XCTAssertEqual(provider.callCount, 1, name)
            XCTAssertEqual(semanticOwner.callCount, 1, name)
            guard case .supported(.left, _, .approved, let leftPixels, _) = detected.supportResolution.left,
                  case .sourceExactNoOp(.right, _, let actualReason) = detected.supportResolution.right
            else {
                XCTFail("\(name): expected accepted left eye and typed peer no-op")
                continue
            }
            XCTAssertEqual(actualReason, expectedReason, name)

            let edit = BeautyUpperEyelidFullnessEditor.edit(
                source: source,
                support: detected.supportResolution,
                strength: 0.75
            )
            let owner = BeautyLocalRetouchCompositionOwner(source: source)
            let composed = try owner.compose(edit.makeUnits(using: owner))
            XCTAssertEqual(edit.summary.acceptedEyeCount, 1, name)
            XCTAssertEqual(edit.summary.rejectedEyeCount, 1, name)
            XCTAssertEqual(composed.summary.changedOutsideUnionPixelCount, 0, name)
            assertOnlyPixels(leftPixels, mayDifferBetween: source, and: composed.canonicalImage, message: name)
        }
    }

    private var standardSupport: [BeautyObservedEyeSupport] {
        [
            BeautyObservedEyeSupport(side: .left, contour: eyeContour(minX: 0.15, maxX: 0.35)),
            BeautyObservedEyeSupport(side: .right, contour: eyeContour(minX: 0.65, maxX: 0.85)),
        ]
    }

    private func eyeContour(minX: Double, maxX: Double) -> [CoordinatePoint] {
        [
            CoordinatePoint(x: minX, y: 0.25),
            CoordinatePoint(x: maxX, y: 0.25),
            CoordinatePoint(x: maxX, y: 0.50),
            CoordinatePoint(x: minX, y: 0.50),
        ]
    }

    private func canonical() throws -> BeautyCanonicalStillImage {
        let width = 8
        let height = 8
        let bytes = (0..<(width * height)).flatMap { pixelIndex in
            let x = pixelIndex % width
            let y = pixelIndex / width
            return [
                UInt8(32 + x * 3 + y),
                UInt8(54 + x * 2 + y * 2),
                UInt8(76 + x + y * 3),
                255,
            ]
        }
        return try BeautyCanonicalStillImage(
            rgba8Data: Data(bytes),
            width: width,
            height: height,
            rowBytes: width * 4,
            metadata: BeautyInputMetadata(
                orientation: .up,
                isInputMirrored: false,
                isPreviewMirrored: false,
                source: .testFixture,
                timestamp: 42
            )
        )
    }

    private func assertOnlyPixels(
        _ allowedPixels: [Int],
        mayDifferBetween source: BeautyCanonicalStillImage,
        and output: BeautyCanonicalStillImage,
        message: String = ""
    ) {
        let allowed = Set(allowedPixels)
        let sourceBytes = Array(source.rgba8Data)
        let outputBytes = Array(output.rgba8Data)
        for pixelIndex in 0..<(source.width * source.height) {
            let offset = pixelIndex * 4
            XCTAssertEqual(outputBytes[offset + 3], sourceBytes[offset + 3], "\(message) alpha \(pixelIndex)")
            if !allowed.contains(pixelIndex) {
                XCTAssertEqual(
                    Array(outputBytes[offset..<(offset + 4)]),
                    Array(sourceBytes[offset..<(offset + 4)]),
                    "\(message) source-exact pixel \(pixelIndex)"
                )
            }
        }
    }

    private func assertPixel(
        _ pixelIndex: Int,
        isSourceExactBetween source: BeautyCanonicalStillImage,
        and output: BeautyCanonicalStillImage,
        message: String
    ) {
        let offset = pixelIndex * 4
        XCTAssertEqual(
            Array(output.rgba8Data[offset..<(offset + 4)]),
            Array(source.rgba8Data[offset..<(offset + 4)]),
            message
        )
    }
}

private final class UpperEyelidIntegrationObservationProvider: @unchecked Sendable {
    private let lock = NSLock()
    private let support: [BeautyObservedEyeSupport]
    private var calls = 0

    init(support: [BeautyObservedEyeSupport]) {
        self.support = support
    }

    var callCount: Int { lock.withLock { calls } }

    func call(_ input: VisionFaceDetectionInput) throws -> [VisionDetectionObservation] {
        lock.withLock { calls += 1 }
        return [VisionDetectionObservation(
            stableID: "integration-face",
            visionBounds: CoordinateRect(x: 0, y: 0, width: 1, height: 1),
            observedEyeSupport: support
        )]
    }
}

private final class UpperEyelidIntegrationSemanticOwner: @unchecked Sendable {
    enum Mode {
        case acceptLeftRejectRight
        case acceptBothAtSamePixel
        case approveEveryRequest
        case acceptLeftLowConfidenceRight
    }

    private let lock = NSLock()
    private let mode: Mode
    private var calls = 0
    private var ids: [String?] = []
    private var leftPixel: Int?
    private var rightPixel: Int?

    init(mode: Mode) {
        self.mode = mode
    }

    var callCount: Int { lock.withLock { calls } }
    var observationIDs: [String?] { lock.withLock { ids } }
    var leftCandidatePixel: Int? { lock.withLock { leftPixel } }
    var rightCandidatePixel: Int? { lock.withLock { rightPixel } }

    func call(_ requests: [BeautyUpperEyelidSemanticRequest]) -> [BeautyUpperEyelidSemanticApproval] {
        let sharedPixel = firstSharedPixel(in: requests)
        return lock.withLock {
            calls += 1
            ids = requests.map(\ .observation.stableID)
            var approvals: [BeautyUpperEyelidSemanticApproval] = []
            for request in requests {
                let candidate = mode == .acceptBothAtSamePixel
                    ? sharedPixel
                    : firstPixel(in: request)
                guard let candidate else { continue }
                if request.side == .left { leftPixel = candidate }
                if request.side == .right { rightPixel = candidate }

                let approved: Bool
                let confidence: Double
                switch mode {
                case .acceptLeftRejectRight:
                    approved = request.side == .left
                    confidence = 0.9
                case .acceptBothAtSamePixel, .approveEveryRequest:
                    approved = true
                    confidence = 0.9
                case .acceptLeftLowConfidenceRight:
                    approved = true
                    confidence = request.side == .left ? 0.9 : 0.49
                }
                approvals.append(BeautyUpperEyelidSemanticApproval(
                    side: request.side,
                    approved: approved,
                    confidence: confidence,
                    reason: approved ? .approved : .semanticApprovalRejected,
                    pixelIndices: approved ? [candidate] : [],
                    hardEnvelope: request.eyeEnvelope
                ))
            }
            return approvals
        }
    }

    private func firstPixel(in request: BeautyUpperEyelidSemanticRequest) -> Int? {
        for pixelIndex in 0..<(request.imageWidth * request.imageHeight) {
            let x = (Double(pixelIndex % request.imageWidth) + 0.5) / Double(request.imageWidth)
            let y = (Double(pixelIndex / request.imageWidth) + 0.5) / Double(request.imageHeight)
            if x >= request.eyeEnvelope.minX,
               x <= request.eyeEnvelope.maxX,
               y >= request.eyeEnvelope.minY,
               y <= request.eyeEnvelope.maxY {
                return pixelIndex
            }
        }
        return nil
    }

    private func firstSharedPixel(in requests: [BeautyUpperEyelidSemanticRequest]) -> Int? {
        guard let first = requests.first,
              requests.allSatisfy({
                  $0.imageWidth == first.imageWidth && $0.imageHeight == first.imageHeight
              })
        else {
            return nil
        }
        for pixelIndex in 0..<(first.imageWidth * first.imageHeight) {
            let x = (Double(pixelIndex % first.imageWidth) + 0.5) / Double(first.imageWidth)
            let y = (Double(pixelIndex / first.imageWidth) + 0.5) / Double(first.imageHeight)
            if requests.allSatisfy({ request in
                x >= request.eyeEnvelope.minX
                    && x <= request.eyeEnvelope.maxX
                    && y >= request.eyeEnvelope.minY
                    && y <= request.eyeEnvelope.maxY
            }) {
                return pixelIndex
            }
        }
        return nil
    }
}
