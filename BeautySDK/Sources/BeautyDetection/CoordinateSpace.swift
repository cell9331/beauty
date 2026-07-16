import Foundation

enum CoordinateSpace: String, CaseIterable, Equatable, Sendable {
    case visionNormalized
    case imageNormalized
    case imagePixel
    case textureUV
    case preview
    case mirroredPreview
}

package struct CoordinatePoint: Equatable, Sendable {
    package let x: Double
    package let y: Double

    package init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    package var isFinite: Bool {
        x.isFinite && y.isFinite
    }
}

package struct CoordinateRect: Equatable, Sendable {
    package let x: Double
    package let y: Double
    package let width: Double
    package let height: Double

    package init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    package var minX: Double { x }
    package var minY: Double { y }
    package var maxX: Double { x + width }
    package var maxY: Double { y + height }
    package var area: Double { max(0, width) * max(0, height) }

    package var isFinite: Bool {
        x.isFinite && y.isFinite && width.isFinite && height.isFinite
    }

    var corners: [CoordinatePoint] {
        [
            CoordinatePoint(x: minX, y: minY),
            CoordinatePoint(x: maxX, y: minY),
            CoordinatePoint(x: minX, y: maxY),
            CoordinatePoint(x: maxX, y: maxY)
        ]
    }

    static func bounding(_ points: [CoordinatePoint]) -> CoordinateRect {
        let minX = points.map(\.x).min() ?? 0
        let minY = points.map(\.y).min() ?? 0
        let maxX = points.map(\.x).max() ?? minX
        let maxY = points.map(\.y).max() ?? minY
        return CoordinateRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }
}
