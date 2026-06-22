import BeautySDK
import Foundation

struct ParameterJSONEnvelope: Codable, Equatable, Sendable {
    let schemaVersion: Int
    let parameters: BeautyParameters
}

enum ParameterJSONImportError: Equatable, Sendable {
    case invalidJSON
    case unsupportedSchema
    case oversized
    case validationFailed
    case unknownFilter

    var message: String {
        switch self {
        case .invalidJSON:
            "Parameter JSON could not be read. Fix the pasted payload and preview again. Current settings stay unchanged."
        case .unsupportedSchema:
            "Unsupported parameter JSON version. Export a fresh payload from this build and try again."
        case .oversized:
            "Parameter JSON is too large. Paste a smaller parameter payload."
        case .validationFailed:
            "Parameter JSON could not be read. Fix the pasted payload and preview again. Current settings stay unchanged."
        case .unknownFilter:
            "Filter is unavailable in this build. Current settings stay unchanged."
        }
    }
}

enum ParameterJSONImportState: Equatable, Sendable {
    case empty
    case preview(BeautyParameters)
    case failed(ParameterJSONImportError)

    var candidate: BeautyParameters? {
        if case .preview(let parameters) = self {
            return parameters
        }
        return nil
    }

    var errorMessage: String? {
        if case .failed(let error) = self {
            return error.message
        }
        return nil
    }
}

enum ParameterJSONCoding {
    static let supportedSchemaVersion = 1
    static let maxPayloadBytes = 65_536

    static func export(parameters: BeautyParameters) throws -> String {
        let envelope = ParameterJSONEnvelope(
            schemaVersion: supportedSchemaVersion,
            parameters: parameters.normalized()
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(envelope)
        return String(decoding: data, as: UTF8.self)
    }

    static func previewImport(_ text: String) -> ParameterJSONImportState {
        guard text.lengthOfBytes(using: .utf8) <= maxPayloadBytes else {
            return .failed(.oversized)
        }
        guard let data = text.data(using: .utf8) else {
            return .failed(.invalidJSON)
        }

        do {
            let decoder = JSONDecoder()
            let probe = try decoder.decode(ParameterJSONSchemaProbe.self, from: data)
            guard probe.schemaVersion == supportedSchemaVersion else {
                return .failed(.unsupportedSchema)
            }

            let envelope = try decoder.decode(ParameterJSONEnvelope.self, from: data)
            let validated = try BeautySDKResources.validate(parameters: envelope.parameters)
            return .preview(validated)
        } catch let error as BeautyError {
            return .failed(importError(for: error))
        } catch {
            return .failed(.invalidJSON)
        }
    }

    private static func importError(for error: BeautyError) -> ParameterJSONImportError {
        switch error {
        case .resourceNotFound:
            .unknownFilter
        default:
            .validationFailed
        }
    }
}

private struct ParameterJSONSchemaProbe: Decodable {
    let schemaVersion: Int
}
