import CoreGraphics

public enum BeautyRenderBackend: String, Codable, Equatable, Sendable {
    case cpu

    /// Uses the Metal backend. Still-image input must be exact-opaque, finite,
    /// bounded RGB; unsupported alpha fails before detection, and successful
    /// still-image output is materialized in the named sRGB color space.
    case gpu
}

public struct BeautyConfiguration: Codable, Equatable, Sendable {
    public static let defaultMaximumInputByteCount = 33_554_432
    public static let defaultMaximumInputPixelCount = 50_000_000

    /// Maximum width and height of the optional Vision detection raster.
    /// The admitted source and final output keep their original dimensions.
    public var preferredProcessingSize: CGSize? {
        didSet {
            preferredProcessingSize = Self.validProcessingSize(preferredProcessingSize)
        }
    }
    public var maximumFaceCount: Int
    public var enableFaceTracking: Bool
    /// Detection cadence for the explicit indexed camera/video CIImage entry.
    /// Unindexed still-image calls always request face support when needed.
    public var detectionFrameInterval: Int {
        didSet {
            detectionFrameInterval = max(1, detectionFrameInterval)
        }
    }
    /// Selects the skin-texture footprint: 3×3, 5×5, or 7×7 when active.
    /// Other effects and neutral rendering do not depend on this field.
    public var renderQuality: BeautyRenderQuality
    /// Adds a bounded synchronous-facade duration to successful `processResult` metrics.
    /// No system or persistent log is emitted; deferred CIImage evaluation is excluded.
    public var enablePerformanceLog: Bool
    /// Enables bounded debug-level result diagnostics when `logLevel` is `.debug`.
    public var enableDebugMode: Bool
    /// Maximum verbosity for content-free events in successful `processResult` results.
    public var logLevel: BeautyLogLevel
    /// Maximum encoded bytes accepted by `BeautyEngine.processResult(encodedImageData:...)`.
    /// Decoded-image and pixel-buffer entries continue to use the pixel limit.
    public var maximumInputByteCount: Int {
        didSet {
            if maximumInputByteCount <= 0 {
                maximumInputByteCount = Self.defaultMaximumInputByteCount
            }
        }
    }
    public var maximumInputPixelCount: Int {
        didSet {
            maximumInputPixelCount = maximumInputPixelCount > 0
                ? min(maximumInputPixelCount, Self.defaultMaximumInputPixelCount)
                : Self.defaultMaximumInputPixelCount
        }
    }
    public var renderBackend: BeautyRenderBackend

    public static let `default` = BeautyConfiguration()

    public init(
        preferredProcessingSize: CGSize? = nil,
        maximumFaceCount: Int = 1,
        enableFaceTracking: Bool = true,
        detectionFrameInterval: Int = 3,
        renderQuality: BeautyRenderQuality = .balanced,
        enablePerformanceLog: Bool = false,
        enableDebugMode: Bool = false,
        logLevel: BeautyLogLevel = .error,
        maximumInputByteCount: Int = Self.defaultMaximumInputByteCount,
        maximumInputPixelCount: Int = Self.defaultMaximumInputPixelCount,
        renderBackend: BeautyRenderBackend = .cpu
    ) {
        self.preferredProcessingSize = Self.validProcessingSize(preferredProcessingSize)
        self.maximumFaceCount = max(1, maximumFaceCount)
        self.enableFaceTracking = enableFaceTracking
        self.detectionFrameInterval = max(1, detectionFrameInterval)
        self.renderQuality = renderQuality
        self.enablePerformanceLog = enablePerformanceLog
        self.enableDebugMode = enableDebugMode
        self.logLevel = logLevel
        self.maximumInputByteCount = maximumInputByteCount > 0
            ? maximumInputByteCount
            : Self.defaultMaximumInputByteCount
        self.maximumInputPixelCount = maximumInputPixelCount > 0
            ? min(maximumInputPixelCount, Self.defaultMaximumInputPixelCount)
            : Self.defaultMaximumInputPixelCount
        self.renderBackend = renderBackend
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            preferredProcessingSize: try container.decodeIfPresent(CGSize.self, forKey: .preferredProcessingSize),
            maximumFaceCount: try container.decode(Int.self, forKey: .maximumFaceCount),
            enableFaceTracking: try container.decode(Bool.self, forKey: .enableFaceTracking),
            detectionFrameInterval: try container.decode(Int.self, forKey: .detectionFrameInterval),
            renderQuality: try container.decode(BeautyRenderQuality.self, forKey: .renderQuality),
            enablePerformanceLog: try container.decode(Bool.self, forKey: .enablePerformanceLog),
            enableDebugMode: try container.decode(Bool.self, forKey: .enableDebugMode),
            logLevel: try container.decode(BeautyLogLevel.self, forKey: .logLevel),
            maximumInputByteCount: try container.decodeIfPresent(
                Int.self,
                forKey: .maximumInputByteCount
            ) ?? Self.defaultMaximumInputByteCount,
            maximumInputPixelCount: try container.decodeIfPresent(
                Int.self,
                forKey: .maximumInputPixelCount
            ) ?? Self.defaultMaximumInputPixelCount,
            renderBackend: try container.decodeIfPresent(
                BeautyRenderBackend.self,
                forKey: .renderBackend
            ) ?? .cpu
        )
    }

    private static func validProcessingSize(_ size: CGSize?) -> CGSize? {
        guard let size,
              size.width.isFinite,
              size.height.isFinite,
              size.width > 0,
              size.height > 0
        else {
            return nil
        }

        return size
    }
}
