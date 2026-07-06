import Foundation
import BeautyCore
import BeautyDetection

@_spi(Testing) public enum SDKTestingFaceDetectionFixture: Sendable {
    case usableFace
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
                        landmarks: .complete
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
