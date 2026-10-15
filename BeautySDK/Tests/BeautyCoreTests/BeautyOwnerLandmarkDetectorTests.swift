import BeautyCore
import BeautyDetection
import CoreGraphics
import Foundation
import XCTest
@_spi(OwnerDiagnostics) @testable import BeautySDK

final class BeautyOwnerLandmarkDetectorTests: XCTestCase {
    func testMeshIndexOrderCoordinatesAndDiagnosticsRedaction() throws {
        let probe = Probe()
        let detector = BeautyOwnerLandmarkDetector(detector: probe.detector())
        let result = try detector.detect(image())
        XCTAssertEqual(result.detectorName, "MediaPipe 478")
        XCTAssertEqual(result.points.count, 478)
        XCTAssertTrue(result.points.indices.allSatisfy { index in
            result.points[index] == CGPoint(x: CGFloat(Float(index % 23 + 1) / 25),
                                             y: CGFloat(Float(index / 23 + 1) / 23))
        })
        XCTAssertEqual(result.summary.usedFaceCount, 1)
        XCTAssertTrue(probe.sawCanonicalInput)
        var output = ""
        dump(result, to: &output)
        XCTAssertFalse(output.contains("CGPoint"))
        XCTAssertFalse(output.contains("points:"))
        XCTAssertTrue(output.contains("pointCount"))
        XCTAssertFalse(String(reflecting: result).contains("0.04"))
    }

    func testNoFaceFailureRecoveryAndResetDoNotReusePoints() throws {
        let probe = Probe(sequence: [.face, .empty, .failure, .face])
        let detector = BeautyOwnerLandmarkDetector(detector: probe.detector())
        XCTAssertEqual(try detector.detect(image()).points.count, 478)
        let empty = try detector.detect(image())
        XCTAssertTrue(empty.points.isEmpty)
        XCTAssertEqual(empty.summary.availability, .noFace)
        let failed = try detector.detect(image())
        XCTAssertTrue(failed.points.isEmpty)
        XCTAssertTrue(failed.summary.reasons.contains(.detectorUnavailable))
        detector.reset()
        XCTAssertEqual(probe.resetCount, 1)
        XCTAssertEqual(try detector.detect(image()).points.count, 478)
        XCTAssertEqual(probe.callCount, 4)
    }

    func testInvalidInputNeverInvokesProviderAndFollowingImageRecovers() throws {
        let probe = Probe()
        let detector = BeautyOwnerLandmarkDetector(detector: probe.detector())
        XCTAssertThrowsError(try detector.detect(image(alpha: 0))) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
        XCTAssertEqual(probe.callCount, 0)
        XCTAssertEqual(try detector.detect(image()).points.count, 478)
    }

    private func image(alpha: UInt8 = 255) -> CGImage {
        let pixel: [UInt8] = [90, 120, 150, alpha]
        let rgba: [UInt8] = Array(repeating: pixel, count: 16 * 12).flatMap { $0 }
        return CGImage(width: 16, height: 12, bitsPerComponent: 8, bitsPerPixel: 32,
            bytesPerRow: 16 * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
            provider: CGDataProvider(data: Data(rgba) as CFData)!, decode: nil,
            shouldInterpolate: false, intent: .defaultIntent)!
    }

    private final class Probe: @unchecked Sendable {
        enum Response { case face, empty, failure }
        private let lock = NSLock()
        private let sequence: [Response]
        private(set) var callCount = 0
        private(set) var resetCount = 0
        private(set) var sawCanonicalInput = false
        init(sequence: [Response] = [.face]) { self.sequence = sequence }
        func detector() -> BeautyFaceDetector {
            BeautyFaceDetector(mappedObservationProvider: { input in
                try self.lock.withLock {
                    self.sawCanonicalInput = input.metadata.orientation == .up
                        && !input.metadata.isInputMirrored && input.stillImage != nil
                        && input.imageExtent == CGSize(width: 16, height: 12)
                    let response = self.sequence[min(self.callCount, self.sequence.count - 1)]
                    self.callCount += 1
                    switch response {
                    case .empty: return BeautyMappedFaceObservations(observations: [])
                    case .failure: throw BeautyFaceDetector.Failure.detectorUnavailable
                    case .face:
                        let points: [SIMD3<Float>] = (0..<478).map { index in
                            let x = Float(index % 23 + 1) / 25
                            let y = Float(index / 23 + 1) / 23
                            return SIMD3<Float>(x, y, 0)
                        }
                        let mesh = BeautyFaceMesh(points: points)!
                        return BeautyMappedFaceObservations(observations: [
                            BeautyFaceObservation(imageBounds: CoordinateRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8), mesh: mesh)
                        ])
                    }
                }
            }, resetProvider: { self.lock.withLock { self.resetCount += 1 } })
        }
    }
}
