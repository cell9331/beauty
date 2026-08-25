import BeautyCore
import BeautyDetection
import Foundation
import XCTest
@testable import BeautyEffects

final class BeautyUpperEyelidFullnessPredictionTests: XCTestCase {
    func testNoRegisteredModelFailsClosedWithoutPredictionOrPixels() throws {
        let request = try validRequest(side: .left)
        let result = try XCTUnwrap(
            BeautyUpperEyelidFullnessPredictionOwner.resolve(requests: [request]).first
        )

        XCTAssertEqual(result.summary.reason, .modelUnavailable)
        XCTAssertEqual(result.summary.acceptedSampleCount, 0)
        XCTAssertNil(result.prediction)

        let diagnostics = [
            String(describing: request),
            request.debugDescription,
            String(describing: result),
            result.debugDescription,
            String(describing: Mirror(reflecting: result)),
        ].joined(separator: " ").lowercased()
        for forbidden in [
            "pixelindex", "coordinatepoint", "rgba8data", "flow", "mask=[",
            "pixels=[", "file://", "/private/",
        ] {
            XCTAssertFalse(diagnostics.contains(forbidden), forbidden)
        }
    }

    func testValidBoundedPredictionIsAcceptedAndRetainedRequestLocally() throws {
        let request = try validRequest(side: .right)
        let prediction = validPrediction(for: request)
        let result = BeautyUpperEyelidFullnessPredictionValidator.validate(
            prediction,
            for: request
        )

        XCTAssertEqual(result.summary.reason, .accepted)
        XCTAssertEqual(result.summary.acceptedSampleCount, request.supportPixels.count)
        XCTAssertEqual(result.prediction, prediction)
    }

    func testInvalidRequestIsRejectedBeforePredictorInvocation() throws {
        let source = try canonical()
        let duplicate = [
            BeautyUpperEyelidSupportPixel(pixelIndex: 18, softWeightQ16: 65_536),
            BeautyUpperEyelidSupportPixel(pixelIndex: 18, softWeightQ16: 65_536),
        ]
        let request = BeautyUpperEyelidFullnessPredictionRequest(
            source: source,
            side: .left,
            supportPixels: duplicate,
            hardEnvelope: CoordinateRect(x: 0, y: 0, width: 1, height: 1)
        )
        let predictor = TestUpperEyelidPredictor { request in
            XCTFail("invalid request reached predictor")
            return self.validPrediction(for: request)
        }

        let result = try XCTUnwrap(
            BeautyUpperEyelidFullnessPredictionOwner.resolve(
                requests: [request],
                predictor: predictor
            ).first
        )

        XCTAssertEqual(result.summary.reason, .invalidRequest)
        XCTAssertEqual(predictor.callCount, 0)
        XCTAssertNil(result.prediction)
    }

    func testProtectedOverlapAndOutsideEnvelopeAreInvalidRequests() throws {
        let source = try canonical()
        let support = supportPixels()
        let protectedOverlap = BeautyUpperEyelidFullnessPredictionRequest(
            source: source,
            side: .left,
            supportPixels: support,
            hardEnvelope: CoordinateRect(x: 0, y: 0, width: 1, height: 1),
            protectedPixelIndices: [support[0].pixelIndex]
        )
        XCTAssertEqual(
            BeautyUpperEyelidFullnessPredictionValidator.validateRequest(protectedOverlap),
            .invalidRequest
        )

        let outsideEnvelope = BeautyUpperEyelidFullnessPredictionRequest(
            source: source,
            side: .left,
            supportPixels: support,
            hardEnvelope: CoordinateRect(x: 0.45, y: 0.45, width: 0.10, height: 0.10)
        )
        XCTAssertEqual(
            BeautyUpperEyelidFullnessPredictionValidator.validateRequest(outsideEnvelope),
            .invalidRequest
        )
    }

    func testApplicabilityConfidenceAndUncertaintyFailClosedIndependently() throws {
        let request = try validRequest(side: .left)
        let samples = validPrediction(for: request).samples
        let cases: [(BeautyUpperEyelidFullnessPrediction, BeautyUpperEyelidFullnessPredictionReason)] = [
            (
                BeautyUpperEyelidFullnessPrediction(
                    side: .left,
                    isApplicable: false,
                    confidence: 0.99,
                    uncertainty: 0.01,
                    samples: []
                ),
                .notApplicable
            ),
            (
                BeautyUpperEyelidFullnessPrediction(
                    side: .left,
                    isApplicable: true,
                    confidence: 0.79,
                    uncertainty: 0.01,
                    samples: samples
                ),
                .lowConfidence
            ),
            (
                BeautyUpperEyelidFullnessPrediction(
                    side: .left,
                    isApplicable: true,
                    confidence: 0.99,
                    uncertainty: 0.21,
                    samples: samples
                ),
                .highUncertainty
            ),
            (
                BeautyUpperEyelidFullnessPrediction(
                    side: .right,
                    isApplicable: true,
                    confidence: 0.99,
                    uncertainty: 0.01,
                    samples: samples
                ),
                .invalidOutput
            ),
            (
                BeautyUpperEyelidFullnessPrediction(
                    side: .left,
                    isApplicable: true,
                    confidence: .nan,
                    uncertainty: 0.01,
                    samples: samples
                ),
                .invalidOutput
            ),
            (
                BeautyUpperEyelidFullnessPrediction(
                    side: .left,
                    isApplicable: true,
                    confidence: 0.99,
                    uncertainty: .infinity,
                    samples: samples
                ),
                .invalidOutput
            ),
        ]

        for (prediction, expected) in cases {
            let result = BeautyUpperEyelidFullnessPredictionValidator.validate(
                prediction,
                for: request
            )
            XCTAssertEqual(result.summary.reason, expected)
            XCTAssertNil(result.prediction)
        }
    }

    func testMalformedSamplesBoundaryFlowAndMagnitudeAreRejected() throws {
        let request = try validRequest(side: .left)
        let valid = validPrediction(for: request)
        let boundaryIndex = try XCTUnwrap(
            request.supportPixels.first(where: {
                $0.softWeightQ16
                    <= BeautyUpperEyelidFullnessPredictionValidator.boundaryZeroMaximumWeightQ16
            })?.pixelIndex
        )

        let boundaryFlow = replacing(valid, pixelIndex: boundaryIndex) { sample in
            BeautyUpperEyelidFullnessPredictionSample(
                pixelIndex: sample.pixelIndex,
                alphaQ16: 1,
                horizontalDisplacementPixels: 0.01,
                verticalDisplacementPixels: 0,
                logLuminanceDelta: 0
            )
        }
        let excessiveFlow = replacing(valid, pixelIndex: 27) { sample in
            BeautyUpperEyelidFullnessPredictionSample(
                pixelIndex: sample.pixelIndex,
                alphaQ16: sample.alphaQ16,
                horizontalDisplacementPixels: 10,
                verticalDisplacementPixels: 0,
                logLuminanceDelta: sample.logLuminanceDelta
            )
        }
        let excessiveTone = replacing(valid, pixelIndex: 27) { sample in
            BeautyUpperEyelidFullnessPredictionSample(
                pixelIndex: sample.pixelIndex,
                alphaQ16: sample.alphaQ16,
                horizontalDisplacementPixels: sample.horizontalDisplacementPixels,
                verticalDisplacementPixels: sample.verticalDisplacementPixels,
                logLuminanceDelta: 0.081
            )
        }
        let excessiveAlpha = replacing(valid, pixelIndex: 27) { sample in
            BeautyUpperEyelidFullnessPredictionSample(
                pixelIndex: sample.pixelIndex,
                alphaQ16: 65_537,
                horizontalDisplacementPixels: sample.horizontalDisplacementPixels,
                verticalDisplacementPixels: sample.verticalDisplacementPixels,
                logLuminanceDelta: sample.logLuminanceDelta
            )
        }
        let missingSample = BeautyUpperEyelidFullnessPrediction(
            side: valid.side,
            isApplicable: true,
            confidence: valid.confidence,
            uncertainty: valid.uncertainty,
            samples: Array(valid.samples.dropLast())
        )

        for prediction in [
            boundaryFlow,
            excessiveFlow,
            excessiveTone,
            excessiveAlpha,
            missingSample,
        ] {
            let result = BeautyUpperEyelidFullnessPredictionValidator.validate(
                prediction,
                for: request
            )
            XCTAssertEqual(result.summary.reason, .invalidOutput)
            XCTAssertNil(result.prediction)
        }
    }

    func testFoldOverAndDiscontinuousNeighborsAreRejected() throws {
        let request = try validRequest(side: .left)
        let valid = validPrediction(for: request)

        let discontinuous = replacing(valid, pixelIndex: 27) { sample in
            BeautyUpperEyelidFullnessPredictionSample(
                pixelIndex: sample.pixelIndex,
                alphaQ16: sample.alphaQ16,
                horizontalDisplacementPixels: -0.16,
                verticalDisplacementPixels: 0,
                logLuminanceDelta: 0.08
            )
        }
        XCTAssertEqual(
            BeautyUpperEyelidFullnessPredictionValidator.validate(
                discontinuous,
                for: request
            ).summary.reason,
            .invalidOutput
        )

        // The source is enlarged so a displacement magnitude can remain in
        // bounds while a one-pixel horizontal derivative folds locally.
        let largeRequest = try validRequest(side: .left, width: 128, height: 128)
        let largeValid = validPrediction(for: largeRequest)
        let corner = 3 * 128 + 3
        let right = corner + 1
        let down = corner + 128
        let foldOver = BeautyUpperEyelidFullnessPrediction(
            side: largeValid.side,
            isApplicable: largeValid.isApplicable,
            confidence: largeValid.confidence,
            uncertainty: largeValid.uncertainty,
            samples: largeValid.samples.map { sample in
                let flow: (Double, Double)
                switch sample.pixelIndex {
                case corner: flow = (0, 0)
                case right: flow = (-0.75, 0)
                case down: flow = (0, -0.75)
                default:
                    flow = (
                        sample.horizontalDisplacementPixels,
                        sample.verticalDisplacementPixels
                    )
                }
                return BeautyUpperEyelidFullnessPredictionSample(
                    pixelIndex: sample.pixelIndex,
                    alphaQ16: sample.alphaQ16,
                    horizontalDisplacementPixels: flow.0,
                    verticalDisplacementPixels: flow.1,
                    logLuminanceDelta: sample.logLuminanceDelta
                )
            }
        )
        XCTAssertEqual(
            BeautyUpperEyelidFullnessPredictionValidator.validate(
                foldOver,
                for: largeRequest
            ).summary.reason,
            .invalidOutput
        )
    }

    func testInferenceFailureDoesNotSuppressValidPeer() throws {
        let left = try validRequest(side: .left)
        let right = try validRequest(side: .right)
        let predictor = TestUpperEyelidPredictor { request in
            if request.side == .left { throw TestPredictionError.failed }
            return self.validPrediction(for: request)
        }

        let results = BeautyUpperEyelidFullnessPredictionOwner.resolve(
            requests: [left, right],
            predictor: predictor
        )

        XCTAssertEqual(results.map(\.summary.reason), [.inferenceFailed, .accepted])
        XCTAssertNil(results[0].prediction)
        XCTAssertNotNil(results[1].prediction)
        XCTAssertEqual(predictor.callCount, 2)
    }

    private func validRequest(
        side: BeautyObservedEyeSide,
        width: Int = 8,
        height: Int = 8
    ) throws -> BeautyUpperEyelidFullnessPredictionRequest {
        BeautyUpperEyelidFullnessPredictionRequest(
            source: try canonical(width: width, height: height),
            side: side,
            supportPixels: supportPixels(width: width),
            hardEnvelope: CoordinateRect(x: 0, y: 0, width: 1, height: 1),
            protectedPixelIndices: [0, 1]
        )
    }

    private func supportPixels(width: Int = 8) -> [BeautyUpperEyelidSupportPixel] {
        (2...5).flatMap { y in
            (2...5).map { x in
                let isBoundary = x == 2 || x == 5 || y == 2 || y == 5
                return BeautyUpperEyelidSupportPixel(
                    pixelIndex: y * width + x,
                    softWeightQ16: isBoundary ? 4_096 : 65_536
                )
            }
        }
    }

    private func validPrediction(
        for request: BeautyUpperEyelidFullnessPredictionRequest
    ) -> BeautyUpperEyelidFullnessPrediction {
        BeautyUpperEyelidFullnessPrediction(
            side: request.side,
            isApplicable: true,
            confidence: 0.95,
            uncertainty: 0.05,
            samples: request.supportPixels.map { support in
                let boundary = support.softWeightQ16
                    <= BeautyUpperEyelidFullnessPredictionValidator.boundaryZeroMaximumWeightQ16
                return BeautyUpperEyelidFullnessPredictionSample(
                    pixelIndex: support.pixelIndex,
                    alphaQ16: boundary ? 0 : support.softWeightQ16,
                    horizontalDisplacementPixels: boundary ? 0 : -0.10,
                    verticalDisplacementPixels: boundary ? 0 : 0.05,
                    logLuminanceDelta: boundary ? 0 : -0.02
                )
            }
        )
    }

    private func replacing(
        _ prediction: BeautyUpperEyelidFullnessPrediction,
        pixelIndex: Int,
        transform: (BeautyUpperEyelidFullnessPredictionSample)
            -> BeautyUpperEyelidFullnessPredictionSample
    ) -> BeautyUpperEyelidFullnessPrediction {
        BeautyUpperEyelidFullnessPrediction(
            side: prediction.side,
            isApplicable: prediction.isApplicable,
            confidence: prediction.confidence,
            uncertainty: prediction.uncertainty,
            samples: prediction.samples.map { sample in
                sample.pixelIndex == pixelIndex ? transform(sample) : sample
            }
        )
    }

    private func canonical(width: Int = 8, height: Int = 8) throws -> BeautyCanonicalStillImage {
        let bytes = (0..<(width * height)).flatMap { index -> [UInt8] in
            let value = UInt8(80 + (index % 32))
            return [value + 12, value + 4, value, 255]
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
                source: .testFixture
            )
        )
    }
}

private enum TestPredictionError: Error {
    case failed
}

private final class TestUpperEyelidPredictor: BeautyUpperEyelidFullnessPredicting, @unchecked Sendable {
    private let lock = NSLock()
    private let body: (BeautyUpperEyelidFullnessPredictionRequest) throws
        -> BeautyUpperEyelidFullnessPrediction
    private var calls = 0

    init(
        body: @escaping (BeautyUpperEyelidFullnessPredictionRequest) throws
            -> BeautyUpperEyelidFullnessPrediction
    ) {
        self.body = body
    }

    var callCount: Int { lock.withLock { calls } }

    func predict(
        _ request: BeautyUpperEyelidFullnessPredictionRequest
    ) throws -> BeautyUpperEyelidFullnessPrediction {
        lock.withLock { calls += 1 }
        return try body(request)
    }
}
