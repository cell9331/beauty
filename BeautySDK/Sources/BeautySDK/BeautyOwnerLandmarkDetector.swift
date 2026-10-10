import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation

/// Transient, owner-only overlay evidence. Never encode, log or export points.
/// Coordinates are upright image-normalized with a top-left origin; mesh index
/// order is preserved. These are re-detected observations, not warp controls.
@_spi(OwnerDiagnostics)
public struct BeautyOwnerLandmarks: Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public let detectorName: String
    public let points: [CGPoint]
    public let summary: BeautyDetectionSummary

    public var description: String {
        "BeautyOwnerLandmarks(detector: \(detectorName), pointCount: \(points.count))"
    }
    public var debugDescription: String { description }
    public var customMirror: Mirror {
        Mirror(self, children: ["detectorName": detectorName, "pointCount": points.count])
    }
}

/// Serialize calls on the owner's actor, independently of the render engine.
/// Reuses the SDK's production adapter, pinned model and input normalization;
/// retains the native task but never retains an image or an observation.
@_spi(OwnerDiagnostics)
public final class BeautyOwnerLandmarkDetector {
    private var detector: BeautyFaceDetector
    private let canonicalizer = BeautyStillImageCanonicalizer()
    private let configuration = BeautyConfiguration(
        preferredProcessingSize: CGSize(width: 960, height: 960), maximumFaceCount: 1
    )

    public init() { detector = .production() }

    package init(detector: BeautyFaceDetector) { self.detector = detector }

    /// Accepts the host's already upright preview/output, with no preview mirror.
    public func detect(_ image: CGImage) throws -> BeautyOwnerLandmarks {
        let canonical = try canonicalizer.canonicalize(
            image: CIImage(cgImage: image),
            metadata: BeautyInputMetadata(orientation: .up, source: .photo),
            maximumPixelCount: configuration.maximumInputPixelCount
        )
        let result = detector.detect(
            image: canonical.ciImage, metadata: canonical.metadata,
            imageExtent: CGSize(width: canonical.width, height: canonical.height),
            configuration: configuration, purpose: .geometryAndLocalSupport
        )
        let primary = result.observations.first
        let points: [CGPoint]
        if let mesh = primary?.mesh {
            points = mesh.points.map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) }
        } else {
            // macOS keeps the production Vision adapter. Never synthesize dense
            // points or silently fall back to Vision on iOS.
            #if os(iOS)
            points = []
            #else
            var mapped: [CoordinatePoint] = []
            if let primary {
                for eye in primary.observedEyeSupport ?? [] {
                    mapped += eye.contour + (eye.pupil ?? [])
                }
                mapped += primary.observedFaceSupport?.contour ?? []
                mapped += primary.observedFaceSupport?.medianLine ?? []
                mapped += primary.observedEyebrowSupport?.left ?? []
                mapped += primary.observedEyebrowSupport?.right ?? []
                mapped += primary.observedLipSupport?.outer ?? []
                mapped += primary.observedLipSupport?.inner ?? []
                mapped += primary.observedNoseSupport?.crest ?? []
                mapped += primary.observedNoseSupport?.contour ?? []
            }
            points = mapped.map { CGPoint(x: $0.x, y: $0.y) }
            #endif
        }
        #if os(iOS)
        let name = "MediaPipe 478"
        #else
        let name = primary?.mesh == nil ? "Vision" : "MediaPipe 478"
        #endif
        return BeautyOwnerLandmarks(detectorName: name, points: points, summary: result.summary)
    }

    public func reset() { detector.resetTracking() }
}
