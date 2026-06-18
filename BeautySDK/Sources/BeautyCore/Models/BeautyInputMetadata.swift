import Foundation
import ImageIO

public enum BeautyInputSource: String, Codable, Equatable, Sendable {
    case camera
    case photo
    case video
    case export
    case testFixture
}

public struct BeautyInputMetadata: Codable, Equatable, Sendable {
    public let orientation: CGImagePropertyOrientation
    public let isInputMirrored: Bool
    public let isPreviewMirrored: Bool
    public let source: BeautyInputSource
    public let timestamp: TimeInterval?

    public init(
        orientation: CGImagePropertyOrientation,
        isInputMirrored: Bool = false,
        isPreviewMirrored: Bool = false,
        source: BeautyInputSource,
        timestamp: TimeInterval? = nil
    ) {
        self.orientation = orientation
        self.isInputMirrored = isInputMirrored
        self.isPreviewMirrored = isPreviewMirrored
        self.source = source
        self.timestamp = timestamp
    }

    private enum CodingKeys: String, CodingKey {
        case orientation
        case isInputMirrored
        case isPreviewMirrored
        case source
        case timestamp
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let orientationRawValue = try container.decode(UInt32.self, forKey: .orientation)
        self.orientation = CGImagePropertyOrientation(rawValue: orientationRawValue) ?? .up
        self.isInputMirrored = try container.decode(Bool.self, forKey: .isInputMirrored)
        self.isPreviewMirrored = try container.decode(Bool.self, forKey: .isPreviewMirrored)
        self.source = try container.decode(BeautyInputSource.self, forKey: .source)
        self.timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(orientation.rawValue, forKey: .orientation)
        try container.encode(isInputMirrored, forKey: .isInputMirrored)
        try container.encode(isPreviewMirrored, forKey: .isPreviewMirrored)
        try container.encode(source, forKey: .source)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
    }
}
