import CoreGraphics

public struct BeautyConfiguration: Codable, Equatable, Sendable {
    public var preferredProcessingSize: CGSize?
    public var maximumFaceCount: Int
    public var enableFaceTracking: Bool
    public var detectionFrameInterval: Int
    public var renderQuality: BeautyRenderQuality
    public var enablePerformanceLog: Bool
    public var enableDebugMode: Bool
    public var logLevel: BeautyLogLevel

    public static let `default` = BeautyConfiguration()

    public init(
        preferredProcessingSize: CGSize? = nil,
        maximumFaceCount: Int = 1,
        enableFaceTracking: Bool = true,
        detectionFrameInterval: Int = 3,
        renderQuality: BeautyRenderQuality = .balanced,
        enablePerformanceLog: Bool = false,
        enableDebugMode: Bool = false,
        logLevel: BeautyLogLevel = .error
    ) {
        self.preferredProcessingSize = Self.validProcessingSize(preferredProcessingSize)
        self.maximumFaceCount = max(1, maximumFaceCount)
        self.enableFaceTracking = enableFaceTracking
        self.detectionFrameInterval = max(1, detectionFrameInterval)
        self.renderQuality = renderQuality
        self.enablePerformanceLog = enablePerformanceLog
        self.enableDebugMode = enableDebugMode
        self.logLevel = logLevel
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
