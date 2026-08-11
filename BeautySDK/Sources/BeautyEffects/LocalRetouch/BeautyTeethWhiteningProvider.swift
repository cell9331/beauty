import BeautyCore
import BeautyDetection
import Foundation

package struct BeautyTeethWhiteningProviderSummary: Equatable, Sendable {
    package let fixedStrongPixelCount: Int
    package let adaptiveStrongPixelCount: Int
    package let finalStrongPixelCount: Int
    package let droppedFixedStrongPixelCount: Int
    package let proposalPixelCount: Int

    package init(
        fixedStrongPixelCount: Int = 0,
        adaptiveStrongPixelCount: Int = 0,
        finalStrongPixelCount: Int = 0,
        droppedFixedStrongPixelCount: Int = 0,
        proposalPixelCount: Int = 0
    ) {
        self.fixedStrongPixelCount = fixedStrongPixelCount
        self.adaptiveStrongPixelCount = adaptiveStrongPixelCount
        self.finalStrongPixelCount = finalStrongPixelCount
        self.droppedFixedStrongPixelCount = droppedFixedStrongPixelCount
        self.proposalPixelCount = proposalPixelCount
    }
}

package struct BeautyTeethWhiteningProviderResult: Sendable {
    package let unit: BeautyLocalRetouchUnit
    package let summary: BeautyTeethWhiteningProviderSummary
}

package enum BeautyTeethWhiteningProvider {
    static let minimumStrongAreaRatio = 0.015
    static let maximumStrongAreaRatio = 0.94
    static let strongThreshold: Float = 0.15

    fileprivate static let minimumPolygonArea = 0.000_001
    private static let maximumOuterWidth = 0.80
    private static let maximumOuterHeight = 0.60
    private static let maximumOuterArea = 0.35
    private static let minimumInnerPixelWidth = 4.0
    private static let minimumInnerPixelHeight = 2.0
    private static let minimumApertureAspect = 0.07

    package static func makeResult(
        source: BeautyCanonicalStillImage,
        lipSupport: BeautyObservedLipSupport?,
        strength: Float,
        owner: BeautyLocalRetouchCompositionOwner
    ) -> BeautyTeethWhiteningProviderResult? {
        guard strength.isFinite,
              strength > 0,
              let lipSupport,
              let outerPoints = lipSupport.outer,
              let innerPoints = lipSupport.inner,
              let outer = ValidatedPolygon(points: outerPoints),
              let inner = ValidatedPolygon(points: innerPoints),
              validatesRelationship(inner: inner, outer: outer, source: source),
              let grid = MaskGrid(outer: outer, source: source),
              let innerMask = grid.rasterize(inner)
        else {
            return nil
        }

        let sourceBytes = source.rgba8Data
        guard let fixedRaw = fixedBaseline(
            sourceBytes: sourceBytes,
            innerMask: innerMask,
            grid: grid,
            sourceWidth: source.width
        ) else {
            return nil
        }
        let fixedMask = constrainToHardEnvelope(
            boxBlur(fixedRaw, width: grid.width, height: grid.height),
            hardEnvelope: innerMask
        )
        let fixedStrongPixelCount = strongCount(fixedMask)
        guard fixedStrongPixelCount > 0 else {
            return nil
        }

        // Coarse Vision lips do not provide tooth-level semantics. Keep the
        // production owner on the conservative inner-aperture baseline; color-
        // qualified growth into the outer-lip region cannot distinguish an
        // enamel-colored gum, tongue, or brace and therefore fails closed.
        let hardEnvelope = innerMask
        let finalMask = fixedMask
        let adaptiveStrongPixelCount = 0
        let finalStrongPixelCount = strongCount(finalMask)
        let droppedFixedStrongPixelCount = zip(fixedMask, finalMask).reduce(into: 0) {
            if $1.0 > strongThreshold && $1.1 <= strongThreshold {
                $0 += 1
            }
        }
        guard droppedFixedStrongPixelCount == 0,
              finalStrongPixelCount >= fixedStrongPixelCount
        else {
            return nil
        }

        var proposals: [BeautyLocalPixelProposal] = []
        proposals.reserveCapacity(finalStrongPixelCount)
        for localIndex in finalMask.indices {
            let softWeight = clamp(finalMask[localIndex])
            guard softWeight > 0.001,
                  hardEnvelope[localIndex] > 0.5
            else {
                continue
            }
            let globalIndex = grid.globalPixelIndex(localIndex, sourceWidth: source.width)
            let offset = globalIndex * 4
            guard let target = BeautyTeethWhiteningTransform.target(
                red: sourceBytes[offset],
                green: sourceBytes[offset + 1],
                blue: sourceBytes[offset + 2],
                strength: strength
            ) else {
                continue
            }
            let weightQ16 = UInt32(
                (Double(softWeight) * 65_536).rounded(.toNearestOrAwayFromZero)
            )
            guard weightQ16 > 0 else { continue }
            proposals.append(BeautyLocalPixelProposal(
                pixelIndex: globalIndex,
                isInsideHardEnvelope: true,
                softWeightQ16: min(weightQ16, 65_536),
                targetRed: target.red,
                targetGreen: target.green,
                targetBlue: target.blue
            ))
        }
        guard !proposals.isEmpty,
              let unit = owner.makeUnit(proposals: proposals)
        else {
            return nil
        }

        return BeautyTeethWhiteningProviderResult(
            unit: unit,
            summary: BeautyTeethWhiteningProviderSummary(
                fixedStrongPixelCount: fixedStrongPixelCount,
                adaptiveStrongPixelCount: adaptiveStrongPixelCount,
                finalStrongPixelCount: finalStrongPixelCount,
                droppedFixedStrongPixelCount: droppedFixedStrongPixelCount,
                proposalPixelCount: proposals.count
            )
        )
    }

    private static func validatesRelationship(
        inner: ValidatedPolygon,
        outer: ValidatedPolygon,
        source: BeautyCanonicalStillImage
    ) -> Bool {
        let outerBounds = outer.bounds
        let innerBounds = inner.bounds
        let innerPixelWidth = innerBounds.width * Double(source.width)
        let innerPixelHeight = innerBounds.height * Double(source.height)
        guard outerBounds.width <= maximumOuterWidth,
              outerBounds.height <= maximumOuterHeight,
              outer.area <= maximumOuterArea,
              inner.area < outer.area,
              innerPixelWidth >= minimumInnerPixelWidth,
              innerPixelHeight >= minimumInnerPixelHeight,
              innerPixelHeight / innerPixelWidth >= minimumApertureAspect,
              outer.strictlyContains(inner),
              outerBounds.minX <= innerBounds.minX,
              outerBounds.maxX >= innerBounds.maxX,
              outerBounds.minY <= innerBounds.minY,
              outerBounds.maxY >= innerBounds.maxY
        else {
            return false
        }
        return true
    }

    private static func fixedBaseline(
        sourceBytes: Data,
        innerMask: [Float],
        grid: MaskGrid,
        sourceWidth: Int
    ) -> [Float]? {
        let regionCount = innerMask.lazy.filter { $0 > 0.5 }.count
        guard regionCount > 0 else { return nil }
        var fixed = [Float](repeating: 0, count: grid.pixelCount)
        for localIndex in innerMask.indices where innerMask[localIndex] > 0.5 {
            let globalIndex = grid.globalPixelIndex(localIndex, sourceWidth: sourceWidth)
            let features = PixelFeatures(sourceBytes: sourceBytes, pixelIndex: globalIndex)
            let brightness = smoothstep(0.32, 0.68, features.luminance)
            let neutrality = 1 - smoothstep(0.22, 0.58, features.saturation)
            let blueFloor = smoothstep(-0.18, 0.06, features.blue - features.red * 0.72)
            let redImbalance = 1 - smoothstep(0.12, 0.24, features.red - features.green)
            fixed[localIndex] = clamp(
                brightness * neutrality * blueFloor * redImbalance
            )
        }
        let candidateCount = strongCount(fixed)
        let ratio = Double(candidateCount) / Double(regionCount)
        guard ratio >= minimumStrongAreaRatio, ratio <= maximumStrongAreaRatio else {
            return nil
        }
        return fixed
    }

    private static func boxBlur(_ values: [Float], width: Int, height: Int) -> [Float] {
        guard values.count == width * height else { return [] }
        var blurred = [Float](repeating: 0, count: values.count)
        for y in 0..<height {
            for x in 0..<width {
                var total: Float = 0
                var count: Float = 0
                for sampleY in max(0, y - 1)...min(height - 1, y + 1) {
                    for sampleX in max(0, x - 1)...min(width - 1, x + 1) {
                        total += values[sampleY * width + sampleX]
                        count += 1
                    }
                }
                blurred[y * width + x] = total / count
            }
        }
        return blurred
    }

    private static func constrainToHardEnvelope(
        _ values: [Float],
        hardEnvelope: [Float]
    ) -> [Float] {
        guard values.count == hardEnvelope.count else { return [] }
        return zip(values, hardEnvelope).map { clamp($0 * $1) }
    }

    private static func strongCount(_ values: [Float]) -> Int {
        values.lazy.filter { $0 > strongThreshold }.count
    }

    private static func smoothstep(_ lower: Float, _ upper: Float, _ value: Float) -> Float {
        guard upper > lower else { return value >= upper ? 1 : 0 }
        let t = clamp((value - lower) / (upper - lower))
        return t * t * (3 - 2 * t)
    }

    private static func clamp(_ value: Float) -> Float {
        min(1, max(0, value))
    }

}

private struct PixelFeatures {
    let red: Float
    let green: Float
    let blue: Float
    let luminance: Float
    let saturation: Float

    init(sourceBytes: Data, pixelIndex: Int) {
        let offset = pixelIndex * 4
        red = Float(sourceBytes[offset]) / 255
        green = Float(sourceBytes[offset + 1]) / 255
        blue = Float(sourceBytes[offset + 2]) / 255
        luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        let maximum = max(red, max(green, blue))
        let minimum = min(red, min(green, blue))
        saturation = maximum > 0.001 ? (maximum - minimum) / maximum : 0
    }
}

private struct MaskGrid {
    let originX: Int
    let originY: Int
    let width: Int
    let height: Int
    let sourceWidth: Int
    let sourceHeight: Int
    let pixelCount: Int

    init?(outer: ValidatedPolygon, source: BeautyCanonicalStillImage) {
        let minimumX = max(0, Int(floor(outer.bounds.minX * Double(source.width))))
        let minimumY = max(0, Int(floor(outer.bounds.minY * Double(source.height))))
        let maximumX = min(source.width, Int(ceil(outer.bounds.maxX * Double(source.width))))
        let maximumY = min(source.height, Int(ceil(outer.bounds.maxY * Double(source.height))))
        let width = maximumX - minimumX
        let height = maximumY - minimumY
        let (pixelCount, overflow) = width.multipliedReportingOverflow(by: height)
        guard !overflow,
              width > 0,
              height > 0,
              pixelCount > 0,
              pixelCount <= source.width * source.height
        else {
            return nil
        }
        originX = minimumX
        originY = minimumY
        self.width = width
        self.height = height
        sourceWidth = source.width
        sourceHeight = source.height
        self.pixelCount = pixelCount
    }

    func rasterize(_ polygon: ValidatedPolygon) -> [Float]? {
        var values = [Float](repeating: 0, count: pixelCount)
        for localY in 0..<height {
            for localX in 0..<width {
                let point = CoordinatePoint(
                    x: (Double(originX + localX) + 0.5) / Double(sourceWidth),
                    y: (Double(originY + localY) + 0.5) / Double(sourceHeight)
                )
                if polygon.contains(point) {
                    values[localY * width + localX] = 1
                }
            }
        }
        return values.lazy.contains(1) ? values : nil
    }

    func globalPixelIndex(_ localIndex: Int, sourceWidth: Int) -> Int {
        let localX = localIndex % width
        let localY = localIndex / width
        return (originY + localY) * sourceWidth + originX + localX
    }

}

private struct PolygonBounds {
    let minX: Double
    let minY: Double
    let maxX: Double
    let maxY: Double

    var width: Double { maxX - minX }
    var height: Double { maxY - minY }
}

private struct ValidatedPolygon {
    let points: [CoordinatePoint]
    let bounds: PolygonBounds
    let area: Double

    init?(points: [CoordinatePoint]) {
        guard (3...32).contains(points.count),
              points.allSatisfy({
                  $0.isFinite && (0...1).contains($0.x) && (0...1).contains($0.y)
              }),
              Set(points.map { "\($0.x.bitPattern):\($0.y.bitPattern)" }).count == points.count,
              Self.isSimple(points)
        else {
            return nil
        }
        let area = abs(Self.signedArea(points))
        guard area > BeautyTeethWhiteningProvider.minimumPolygonArea,
              let minX = points.map(\.x).min(),
              let minY = points.map(\.y).min(),
              let maxX = points.map(\.x).max(),
              let maxY = points.map(\.y).max(),
              maxX > minX,
              maxY > minY
        else {
            return nil
        }
        self.points = points
        bounds = PolygonBounds(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        self.area = area
    }

    func contains(_ point: CoordinatePoint) -> Bool {
        var inside = false
        var previous = points.count - 1
        for current in points.indices {
            let a = points[previous]
            let b = points[current]
            if Self.pointOnSegment(point, a, b) {
                return true
            }
            let crosses = (a.y > point.y) != (b.y > point.y)
            if crosses {
                let intersectionX = (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x
                if point.x < intersectionX {
                    inside.toggle()
                }
            }
            previous = current
        }
        return inside
    }

    func strictlyContains(_ polygon: ValidatedPolygon) -> Bool {
        guard polygon.points.allSatisfy({ contains($0) }) else {
            return false
        }
        for innerIndex in polygon.points.indices {
            let innerNext = (innerIndex + 1) % polygon.points.count
            for outerIndex in points.indices {
                let outerNext = (outerIndex + 1) % points.count
                if Self.segmentsIntersect(
                    polygon.points[innerIndex],
                    polygon.points[innerNext],
                    points[outerIndex],
                    points[outerNext]
                ) {
                    return false
                }
            }
        }
        return true
    }

    private static func signedArea(_ points: [CoordinatePoint]) -> Double {
        var doubled = 0.0
        for index in points.indices {
            let next = points[(index + 1) % points.count]
            doubled += points[index].x * next.y - next.x * points[index].y
        }
        return doubled * 0.5
    }

    private static func isSimple(_ points: [CoordinatePoint]) -> Bool {
        for first in points.indices {
            let firstNext = (first + 1) % points.count
            for second in points.indices {
                let secondNext = (second + 1) % points.count
                if first == second
                    || first == secondNext
                    || firstNext == second
                    || firstNext == secondNext
                {
                    continue
                }
                if segmentsIntersect(
                    points[first],
                    points[firstNext],
                    points[second],
                    points[secondNext]
                ) {
                    return false
                }
            }
        }
        return true
    }

    private static func segmentsIntersect(
        _ a: CoordinatePoint,
        _ b: CoordinatePoint,
        _ c: CoordinatePoint,
        _ d: CoordinatePoint
    ) -> Bool {
        let first = cross(a, b, c)
        let second = cross(a, b, d)
        let third = cross(c, d, a)
        let fourth = cross(c, d, b)
        if ((first > 0 && second < 0) || (first < 0 && second > 0))
            && ((third > 0 && fourth < 0) || (third < 0 && fourth > 0))
        {
            return true
        }
        return (abs(first) <= 0.000_000_001 && pointOnSegment(c, a, b))
            || (abs(second) <= 0.000_000_001 && pointOnSegment(d, a, b))
            || (abs(third) <= 0.000_000_001 && pointOnSegment(a, c, d))
            || (abs(fourth) <= 0.000_000_001 && pointOnSegment(b, c, d))
    }

    private static func cross(
        _ a: CoordinatePoint,
        _ b: CoordinatePoint,
        _ c: CoordinatePoint
    ) -> Double {
        (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    }

    private static func pointOnSegment(
        _ point: CoordinatePoint,
        _ a: CoordinatePoint,
        _ b: CoordinatePoint
    ) -> Bool {
        abs(cross(a, b, point)) <= 0.000_000_001
            && point.x >= min(a.x, b.x) - 0.000_000_001
            && point.x <= max(a.x, b.x) + 0.000_000_001
            && point.y >= min(a.y, b.y) - 0.000_000_001
            && point.y <= max(a.y, b.y) + 0.000_000_001
    }
}
