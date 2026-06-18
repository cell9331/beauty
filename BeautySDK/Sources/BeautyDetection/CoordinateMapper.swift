import BeautyCore
import CoreGraphics
import Foundation
import ImageIO

struct CoordinateMapper: Equatable, Sendable {
    enum MappingError: Error, Equatable, Sendable {
        case invalidImageExtent
        case invalidPreviewExtent
        case invalidCoordinate
        case unsupportedConversion
    }

    let metadata: BeautyInputMetadata
    let imageExtent: CGSize
    let previewExtent: CGSize?

    init(
        metadata: BeautyInputMetadata,
        imageExtent: CGSize,
        previewExtent: CGSize? = nil
    ) {
        self.metadata = metadata
        self.imageExtent = imageExtent
        self.previewExtent = previewExtent
    }

    func map(
        point: CoordinatePoint,
        from source: CoordinateSpace,
        to destination: CoordinateSpace
    ) throws -> CoordinatePoint {
        try validateImageExtent()
        guard point.isFinite else {
            throw MappingError.invalidCoordinate
        }

        let imageNormalized = try toImageNormalized(point, from: source)
        return try fromImageNormalized(imageNormalized, to: destination)
    }

    func map(
        rect: CoordinateRect,
        from source: CoordinateSpace,
        to destination: CoordinateSpace
    ) throws -> CoordinateRect {
        try validateImageExtent()
        guard rect.isFinite else {
            throw MappingError.invalidCoordinate
        }

        let mappedCorners = try rect.corners.map { corner in
            try map(point: corner, from: source, to: destination)
        }
        return CoordinateRect.bounding(mappedCorners)
    }

    private func toImageNormalized(
        _ point: CoordinatePoint,
        from source: CoordinateSpace
    ) throws -> CoordinatePoint {
        switch source {
        case .visionNormalized:
            let topLeft = CoordinatePoint(x: point.x, y: 1 - point.y)
            return applyInputMirror(to: applyOrientation(to: topLeft))
        case .imageNormalized, .textureUV:
            return point
        case .imagePixel:
            return CoordinatePoint(
                x: point.x / Double(imageExtent.width),
                y: point.y / Double(imageExtent.height)
            )
        case .preview:
            let extent = try validPreviewExtent()
            return CoordinatePoint(
                x: point.x / Double(extent.width),
                y: point.y / Double(extent.height)
            )
        case .mirroredPreview:
            let extent = try validPreviewExtent()
            let previewX = point.x / Double(extent.width)
            let normalizedX = metadata.isPreviewMirrored ? 1 - previewX : previewX
            return CoordinatePoint(
                x: normalizedX,
                y: point.y / Double(extent.height)
            )
        }
    }

    private func fromImageNormalized(
        _ point: CoordinatePoint,
        to destination: CoordinateSpace
    ) throws -> CoordinatePoint {
        switch destination {
        case .visionNormalized:
            throw MappingError.unsupportedConversion
        case .imageNormalized, .textureUV:
            return point
        case .imagePixel:
            return CoordinatePoint(
                x: point.x * Double(imageExtent.width),
                y: point.y * Double(imageExtent.height)
            )
        case .preview:
            let extent = try validPreviewExtent()
            return CoordinatePoint(
                x: point.x * Double(extent.width),
                y: point.y * Double(extent.height)
            )
        case .mirroredPreview:
            let extent = try validPreviewExtent()
            let previewX = metadata.isPreviewMirrored ? 1 - point.x : point.x
            return CoordinatePoint(
                x: previewX * Double(extent.width),
                y: point.y * Double(extent.height)
            )
        }
    }

    private func applyOrientation(to point: CoordinatePoint) -> CoordinatePoint {
        switch metadata.orientation {
        case .up, .upMirrored:
            point
        case .right, .rightMirrored:
            CoordinatePoint(x: 1 - point.y, y: point.x)
        case .left, .leftMirrored:
            CoordinatePoint(x: point.y, y: 1 - point.x)
        case .down, .downMirrored:
            CoordinatePoint(x: 1 - point.x, y: 1 - point.y)
        @unknown default:
            point
        }
    }

    private func applyInputMirror(to point: CoordinatePoint) -> CoordinatePoint {
        guard metadata.isInputMirrored else {
            return point
        }

        return CoordinatePoint(x: 1 - point.x, y: point.y)
    }

    private func validateImageExtent() throws {
        guard imageExtent.width.isFinite,
              imageExtent.height.isFinite,
              imageExtent.width > 0,
              imageExtent.height > 0
        else {
            throw MappingError.invalidImageExtent
        }
    }

    private func validPreviewExtent() throws -> CGSize {
        guard let previewExtent,
              previewExtent.width.isFinite,
              previewExtent.height.isFinite,
              previewExtent.width > 0,
              previewExtent.height > 0
        else {
            throw MappingError.invalidPreviewExtent
        }

        return previewExtent
    }
}
