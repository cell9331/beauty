import CoreGraphics

public struct BeautyConfiguration: Codable, Equatable, Sendable {
    public static let defaultMaximumInputByteCount = 33_554_432
    public static let defaultMaximumInputPixelCount = 50_000_000

    public var preferredProcessingSize: CGSize?
    public var maximumFaceCount: Int
    public var enableFaceTracking: Bool
    public var detectionFrameInterval: Int
    public var renderQuality: BeautyRenderQuality
    public var enablePerformanceLog: Bool
    public var enableDebugMode: Bool
    public var logLevel: BeautyLogLevel
    public var maximumInputByteCount: Int
    public var maximumInputPixelCount: Int

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
        maximumInputPixelCount: Int = Self.defaultMaximumInputPixelCount
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
            ? maximumInputPixelCount
            : Self.defaultMaximumInputPixelCount
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
            ) ?? Self.defaultMaximumInputPixelCount
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
