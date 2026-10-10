import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation

/// Opaque handle for the one immutable photo currently prepared by an engine.
/// Replacement or reset invalidates the handle. Serialize access to its engine.
/// This is an editing optimization, not a video-frame or tracking contract.
public struct BeautyPreparedStillImage: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    let identifier: UUID
    public let width: Int
    public let height: Int

    public var description: String { "BeautyPreparedStillImage(width: \(width), height: \(height))" }
    public var debugDescription: String { description }
    public var customMirror: Mirror {
        Mirror(self, children: ["width": width, "height": height])
    }
}

/// Only this engine-owned state retains pixels and validated observations.
/// At most six entries: three detection purposes on two raster routes.
final class BeautyPreparedStillImageState: CustomReflectable {
    let handle: BeautyPreparedStillImage
    let image: CIImage
    let metadata: BeautyInputMetadata
    private var detections: [Int: VisionFaceDetectionResult] = [:]

    init(image: CGImage, metadata: BeautyInputMetadata, maximumPixelCount: Int) throws {
        guard metadata.source == .photo, image.width > 0, image.height > 0,
              maximumPixelCount > 0, image.width <= maximumPixelCount / image.height else {
            throw BeautyError.invalidInput
        }
        guard image.colorSpace?.model == .rgb, image.bitsPerComponent == 8,
              image.bitsPerPixel == 24 || image.bitsPerPixel == 32,
              let colorSpace = image.colorSpace else { throw BeautyError.unsupportedPixelFormat }
        let (rowMinimum, rowOverflow) = image.width.multipliedReportingOverflow(by: image.bitsPerPixel / 8)
        let (byteCount, byteOverflow) = image.bytesPerRow.multipliedReportingOverflow(by: image.height)
        let (byteLimit, limitOverflow) = maximumPixelCount.multipliedReportingOverflow(by: 4)
        guard !rowOverflow, !byteOverflow, !limitOverflow,
              image.bytesPerRow >= rowMinimum, byteCount > 0, byteCount <= byteLimit,
              let source = image.dataProvider?.data, CFDataGetLength(source) >= byteCount,
              let bytes = CFDataGetBytePtr(source) else { throw BeautyError.invalidInput }
        // Copy bytes rather than retain a caller's mutable provider or lazy graph.
        let snapshot = Data(bytes: bytes, count: byteCount)
        guard let provider = CGDataProvider(data: snapshot as CFData),
              let frozen = CGImage(width: image.width, height: image.height,
                  bitsPerComponent: image.bitsPerComponent, bitsPerPixel: image.bitsPerPixel,
                  bytesPerRow: image.bytesPerRow, space: colorSpace,
                  bitmapInfo: image.bitmapInfo, provider: provider, decode: image.decode,
                  shouldInterpolate: image.shouldInterpolate, intent: image.renderingIntent)
        else { throw BeautyError.invalidInput }
        self.handle = BeautyPreparedStillImage(identifier: UUID(), width: image.width, height: image.height)
        self.image = CIImage(cgImage: frozen, options: [.colorSpace: colorSpace])
        self.metadata = metadata
    }

    func detection(purpose: VisionFaceDetector.DetectionPurpose, canonical: Bool,
                   produce: () -> VisionFaceDetectionResult) -> (VisionFaceDetectionResult, Bool) {
        let purposeIndex: Int
        switch purpose {
        case .geometry: purposeIndex = 0
        case .localSupport: purposeIndex = 1
        case .geometryAndLocalSupport: purposeIndex = 2
        }
        let key = purposeIndex + (canonical ? 3 : 0)
        if let cached = detections[key] { return (cached, true) }
        let fresh = produce()
        if fresh.summary.availability == .usable || fresh.summary.availability == .noFace {
            detections[key] = fresh
        }
        return (fresh, false)
    }

    var customMirror: Mirror {
        Mirror(self, children: ["width": handle.width, "height": handle.height,
                               "detectionEntryCount": detections.count])
    }
}
