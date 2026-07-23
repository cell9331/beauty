import Foundation
import BeautyCore
import BeautyDetection

private let phase46ObservedContour = [
    CoordinatePoint(x: 0.025, y: 0.733_333_333),
    CoordinatePoint(x: 0.000, y: 0.600_000_000),
    CoordinatePoint(x: 0.0625, y: 0.466_666_667),
    CoordinatePoint(x: 0.125, y: 0.300_000_000),
    CoordinatePoint(x: 0.2875, y: 0.116_666_667),
    CoordinatePoint(x: 0.5125, y: 0.000_000_000),
    CoordinatePoint(x: 0.7125, y: 0.150_000_000),
    CoordinatePoint(x: 0.8500, y: 0.333_333_333),
    CoordinatePoint(x: 0.9375, y: 0.516_666_667),
    CoordinatePoint(x: 1.0000, y: 0.650_000_000),
    CoordinatePoint(x: 0.9500, y: 0.766_666_667),
]

private let phase46ObservedMedianLine = [
    CoordinatePoint(x: 0.4500, y: 0.833_333_333),
    CoordinatePoint(x: 0.4875, y: 0.416_666_667),
    CoordinatePoint(x: 0.5250, y: 0.016_666_667),
]

private let phase47MalformedObservedContour = [
    CoordinatePoint(x: 0.10, y: 0.20),
    CoordinatePoint(x: 0.20, y: 0.35),
    CoordinatePoint(x: 0.30, y: 0.50),
    CoordinatePoint(x: 0.30, y: 0.50),
    CoordinatePoint(x: 0.60, y: 0.50),
    CoordinatePoint(x: 0.70, y: 0.35),
    CoordinatePoint(x: 0.80, y: 0.20),
]

@_spi(Testing) public enum SDKTestingFaceDetectionFixture: Sendable {
    case usableFace
    case missingObservedFaceContour
    case malformedObservedFaceContour
    case noFace
    case lowConfidence
    case missingLandmarks
    case detectorUnavailable
    case detectionTimedOut
}

@_spi(Testing) public final class SDKTestingFaceDetectionProvider: @unchecked Sendable {
    private let lock = NSLock()
    private let fixtures: [SDKTestingFaceDetectionFixture]
    private var invocationCountValue = 0

    public init(_ fixtures: [SDKTestingFaceDetectionFixture]) {
        self.fixtures = fixtures.isEmpty ? [.noFace] : fixtures
    }

    public var invocationCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return invocationCountValue
    }

    package func makeObservationProvider() -> VisionFaceDetector.ObservationProvider {
        { [self] _ in
            switch nextFixture() {
            case .usableFace:
                return [
                    VisionDetectionObservation(
                        stableID: "fixture",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete,
                        observedFaceSupport: BeautyObservedFaceSupport(
                            contour: phase46ObservedContour,
                            medianLine: phase46ObservedMedianLine
                        )
                    )
                ]
            case .missingObservedFaceContour:
                return [
                    VisionDetectionObservation(
                        stableID: "fixture-missing-observed-contour",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete
                    )
                ]
            case .malformedObservedFaceContour:
                return [
                    VisionDetectionObservation(
                        stableID: "fixture-malformed-observed-contour",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete,
                        observedFaceSupport: BeautyObservedFaceSupport(
                            contour: phase47MalformedObservedContour,
                            medianLine: phase46ObservedMedianLine
                        )
                    )
                ]
            case .noFace:
                return []
            case .lowConfidence:
                return [
                    VisionDetectionObservation(
                        stableID: "low",
                        confidence: 0.20,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .complete
                    )
                ]
            case .missingLandmarks:
                return [
                    VisionDetectionObservation(
                        stableID: "partial",
                        confidence: 0.96,
                        normalizedArea: 0.24,
                        visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
                        landmarks: .missingRequiredGeometry
                    )
                ]
            case .detectorUnavailable:
                throw VisionFaceDetector.Failure.detectorUnavailable
            case .detectionTimedOut:
                throw VisionFaceDetector.Failure.detectionTimedOut
            }
        }
    }

    private func nextFixture() -> SDKTestingFaceDetectionFixture {
        lock.lock()
        defer { lock.unlock() }

        let index = min(invocationCountValue, fixtures.count - 1)
        invocationCountValue += 1
        return fixtures[index]
    }
}

@_spi(Testing) public extension BeautyEngine {
    convenience init(
        configuration: BeautyConfiguration = .default,
        faceDetectionProvider: SDKTestingFaceDetectionProvider
    ) throws {
        try self.init(
            configuration: configuration,
            faceDetector: VisionFaceDetector(
                observationProvider: faceDetectionProvider.makeObservationProvider()
            )
        )
    }
}
