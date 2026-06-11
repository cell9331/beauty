import Foundation

public enum BeautyError: Error, Equatable, CustomStringConvertible, LocalizedError, Sendable {
    case metalUnavailable
    case commandQueueCreationFailed
    case textureCreationFailed
    case pixelBufferCreationFailed
    case shaderFunctionNotFound(String)
    case invalidInput
    case unsupportedPixelFormat
    case resourceNotFound(String)
    case presetDecodeFailed(String)
    case lutDecodeFailed(String)
    case renderFailed(String)
    case detectionFailed(String)

    public var description: String {
        switch self {
        case .metalUnavailable:
            "metalUnavailable"
        case .commandQueueCreationFailed:
            "commandQueueCreationFailed"
        case .textureCreationFailed:
            "textureCreationFailed"
        case .pixelBufferCreationFailed:
            "pixelBufferCreationFailed"
        case .shaderFunctionNotFound(let name):
            "shaderFunctionNotFound(\(Self.redacted(name)))"
        case .invalidInput:
            "invalidInput"
        case .unsupportedPixelFormat:
            "unsupportedPixelFormat"
        case .resourceNotFound(let id):
            "resourceNotFound(\(Self.redacted(id)))"
        case .presetDecodeFailed(let reason):
            "presetDecodeFailed(\(Self.redacted(reason)))"
        case .lutDecodeFailed(let reason):
            "lutDecodeFailed(\(Self.redacted(reason)))"
        case .renderFailed(let reason):
            "renderFailed(\(Self.redacted(reason)))"
        case .detectionFailed(let reason):
            "detectionFailed(\(Self.redacted(reason)))"
        }
    }

    public var errorDescription: String? {
        description
    }

    public var code: String {
        switch self {
        case .metalUnavailable:
            "metal_unavailable"
        case .commandQueueCreationFailed:
            "command_queue_creation_failed"
        case .textureCreationFailed:
            "texture_creation_failed"
        case .pixelBufferCreationFailed:
            "pixel_buffer_creation_failed"
        case .shaderFunctionNotFound:
            "shader_function_not_found"
        case .invalidInput:
            "invalid_input"
        case .unsupportedPixelFormat:
            "unsupported_pixel_format"
        case .resourceNotFound:
            "resource_not_found"
        case .presetDecodeFailed:
            "preset_decode_failed"
        case .lutDecodeFailed:
            "lut_decode_failed"
        case .renderFailed:
            "render_failed"
        case .detectionFailed:
            "detection_failed"
        }
    }

    private static func redacted(_ value: String) -> String {
        let allowed = value.unicodeScalars.filter { scalar in
            CharacterSet.alphanumerics.contains(scalar) ||
                scalar == "." || scalar == "_" || scalar == "-"
        }
        let sanitized = String(String.UnicodeScalarView(allowed))
        if sanitized.isEmpty {
            return "redacted"
        }
        return String(sanitized.prefix(48))
    }
}
