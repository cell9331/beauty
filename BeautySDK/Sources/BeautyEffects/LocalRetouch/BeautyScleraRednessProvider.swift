import BeautyCore
import BeautyDetection
import Foundation

package enum BeautyScleraEyeOutcome: Equatable, Sendable {
    case accepted
    case missingSupport
    case invalidOrder
    case invalidSupport
    case emptyEnvelope
    case noMaterialRedness
    case unitRejected
}

package struct BeautyScleraRednessProviderSummary: Equatable, Sendable {
    package let leftOutcome: BeautyScleraEyeOutcome
    package let rightOutcome: BeautyScleraEyeOutcome
    package let acceptedEyeCount: Int
    package let proposalPixelCount: Int

    package init(
        leftOutcome: BeautyScleraEyeOutcome = .missingSupport,
        rightOutcome: BeautyScleraEyeOutcome = .missingSupport,
        acceptedEyeCount: Int = 0,
        proposalPixelCount: Int = 0
    ) {
        self.leftOutcome = leftOutcome
        self.rightOutcome = rightOutcome
        self.acceptedEyeCount = acceptedEyeCount
        self.proposalPixelCount = proposalPixelCount
    }
}

package struct BeautyScleraRednessProviderResult: Sendable {
    package let units: [BeautyLocalRetouchUnit]
    package let summary: BeautyScleraRednessProviderSummary
    internal let proposalPixelIndices: [Int]
}

package enum BeautyScleraRednessProvider {
    fileprivate static let minimumContourArea = 0.000_02
    fileprivate static let maximumContourArea = 0.20
    fileprivate static let minimumPixelWidth = 8.0
    fileprivate static let minimumPixelHeight = 4.0
    fileprivate static let minimumAspect = 0.12
    fileprivate static let maximumAspect = 1.20
    fileprivate static let maximumNormalizedWidth = 0.50
    fileprivate static let maximumNormalizedHeight = 0.40
    private static let minimumStrongScore: Float = 0.08

    package static func makeResult(
        source: BeautyCanonicalStillImage,
        eyeSupport: [BeautyObservedEyeSupport]?,
        eyeOrder: BeautyObservedEyeOrder?,
        strength: Float,
        owner: BeautyLocalRetouchCompositionOwner
    ) -> BeautyScleraRednessProviderResult {
        guard strength.isFinite, strength > 0 else { return emptyResult() }
        guard eyeOrder == .canonical else {
            return emptyResult(left: .invalidOrder, right: .invalidOrder)
        }
        guard let eyeSupport, eyeSupport.count <= 2 else {
            return emptyResult(left: .invalidSupport, right: .invalidSupport)
        }

        var duplicateSide = false
        var leftSupport: BeautyObservedEyeSupport?
        var rightSupport: BeautyObservedEyeSupport?
        for support in eyeSupport {
            switch support.side {
            case .left:
                if leftSupport != nil { duplicateSide = true }
                leftSupport = support
            case .right:
                if rightSupport != nil { duplicateSide = true }
                rightSupport = support
            }
        }
        guard !duplicateSide else {
            return emptyResult(left: .invalidSupport, right: .invalidSupport)
        }

        let sorted: [BeautyObservedEyeSide] = [.left, .right]
        var units: [BeautyLocalRetouchUnit] = []
        var leftOutcome: BeautyScleraEyeOutcome = .missingSupport
        var rightOutcome: BeautyScleraEyeOutcome = .missingSupport
        var proposalPixelCount = 0
        var proposalPixelIndices: [Int] = []
        for side in sorted {
            let support = switch side {
            case .left: leftSupport
            case .right: rightSupport
            }
            guard let support else {
                continue
            }
            let processed = makeEyeUnit(
                source: source,
                support: support,
                strength: strength,
                owner: owner
            )
            switch side {
            case .left: leftOutcome = processed.outcome
            case .right: rightOutcome = processed.outcome
            }
            proposalPixelCount += processed.proposalPixelCount
            proposalPixelIndices.append(contentsOf: processed.proposalPixelIndices)
            if let unit = processed.unit { units.append(unit) }
        }
        return BeautyScleraRednessProviderResult(
            units: units,
            summary: BeautyScleraRednessProviderSummary(
                leftOutcome: leftOutcome,
                rightOutcome: rightOutcome,
                acceptedEyeCount: units.count,
                proposalPixelCount: proposalPixelCount
            ),
            proposalPixelIndices: proposalPixelIndices
        )
    }

    private static func makeEyeUnit(
        source: BeautyCanonicalStillImage,
        support: BeautyObservedEyeSupport,
        strength: Float,
        owner: BeautyLocalRetouchCompositionOwner
    ) -> EyeUnitResult {
        guard let polygon = ValidatedEyePolygon(
            points: support.contour,
            sourceWidth: source.width,
            sourceHeight: source.height
        ),
              let pupil = support.pupil,
              pupil.count == 1,
              let pupilPoint = pupil.first,
              pupilPoint.x.isFinite,
              pupilPoint.y.isFinite,
              (0...1).contains(pupilPoint.x),
              (0...1).contains(pupilPoint.y),
              polygon.contains(pupilPoint),
              polygon.pupilIsPlausible(pupilPoint),
              let grid = EyeMaskGrid(polygon: polygon, source: source)
        else {
            return EyeUnitResult(outcome: .invalidSupport)
        }

        let aperture = grid.rasterize(polygon)
        let contourMargin = max(1, Int((Double(min(grid.width, grid.height)) * 0.12).rounded()))
        let erodedAperture = erode(aperture, width: grid.width, height: grid.height, radius: contourMargin)
        let pupilExclusion = expandedPupilExclusion(
            pupil: pupilPoint,
            polygon: polygon,
            grid: grid
        )
        let sourceBytes = source.rgba8Data
        let highlightExclusion = expandedColorExclusion(
            sourceBytes: sourceBytes,
            aperture: aperture,
            grid: grid,
            sourceWidth: source.width,
            predicate: { features in features.luminance >= 0.92 && features.saturation <= 0.10 }
        )
        let lashExclusion = expandedColorExclusion(
            sourceBytes: sourceBytes,
            aperture: aperture,
            grid: grid,
            sourceWidth: source.width,
            predicate: { features in features.luminance <= 0.22 }
        )
        // beforeRednessScore: geometry and protected colors own the hard guard.
        let hardEnvelope = erodedAperture.indices.map { index in
            erodedAperture[index]
                && !pupilExclusion[index]
                && !highlightExclusion[index]
                && !lashExclusion[index]
        }
        guard hardEnvelope.contains(true) else {
            return EyeUnitResult(outcome: .emptyEnvelope)
        }

        var rednessScore = [Float](repeating: 0, count: grid.pixelCount)
        for index in rednessScore.indices where hardEnvelope[index] {
            let globalIndex = grid.globalPixelIndex(index, sourceWidth: source.width)
            let features = PixelFeatures(sourceBytes: sourceBytes, pixelIndex: globalIndex)
            let scleraLikelihood = smoothstep(0.34, 0.62, features.luminance)
                * (1 - smoothstep(0.48, 0.74, features.saturation))
            let materialRedness = smoothstep(0.030, 0.115, features.redExcess)
            rednessScore[index] = clamp(scleraLikelihood * materialRedness)
        }
        let strongCount = rednessScore.lazy.filter { $0 >= minimumStrongScore }.count
        let envelopeCount = hardEnvelope.lazy.filter { $0 }.count
        guard strongCount >= 2, strongCount <= envelopeCount else {
            return EyeUnitResult(outcome: .noMaterialRedness)
        }

        let softened = boxBlur(rednessScore, width: grid.width, height: grid.height)
        let finalMask = constrainToHardEnvelope(softened, hardEnvelope: hardEnvelope)
        var proposals: [BeautyLocalPixelProposal] = []
        proposals.reserveCapacity(strongCount)
        for index in finalMask.indices {
            let softWeight = finalMask[index]
            guard hardEnvelope[index], softWeight > 0.001 else { continue }
            let globalIndex = grid.globalPixelIndex(index, sourceWidth: source.width)
            let offset = globalIndex * 4
            guard let target = BeautyScleraRednessTransform.target(
                red: sourceBytes[offset],
                green: sourceBytes[offset + 1],
                blue: sourceBytes[offset + 2],
                strength: strength
            ) else { continue }
            let softWeightQ16 = UInt32(
                (Double(softWeight) * 65_536).rounded(.toNearestOrAwayFromZero)
            )
            guard softWeightQ16 > 0 else { continue }
            proposals.append(BeautyLocalPixelProposal(
                pixelIndex: globalIndex,
                isInsideHardEnvelope: true,
                softWeightQ16: min(65_536, softWeightQ16),
                targetRed: target.red,
                targetGreen: target.green,
                targetBlue: target.blue
            ))
        }
        guard !proposals.isEmpty else {
            return EyeUnitResult(outcome: .noMaterialRedness)
        }
        guard let unit = owner.makeUnit(proposals: proposals) else {
            return EyeUnitResult(outcome: .unitRejected)
        }
        return EyeUnitResult(
            unit: unit,
            outcome: .accepted,
            proposalPixelCount: proposals.count,
            proposalPixelIndices: proposals.map(\.pixelIndex)
        )
    }

    private static func emptyResult(
        left: BeautyScleraEyeOutcome = .missingSupport,
        right: BeautyScleraEyeOutcome = .missingSupport
    ) -> BeautyScleraRednessProviderResult {
        BeautyScleraRednessProviderResult(
            units: [],
            summary: BeautyScleraRednessProviderSummary(
                leftOutcome: left,
                rightOutcome: right
            ),
            proposalPixelIndices: []
        )
    }

    private static func expandedPupilExclusion(
        pupil: CoordinatePoint,
        polygon: ValidatedEyePolygon,
        grid: EyeMaskGrid
    ) -> [Bool] {
        let eyeWidth = polygon.bounds.width * Double(grid.sourceWidth)
        let eyeHeight = polygon.bounds.height * Double(grid.sourceHeight)
        // Keep the actual-pupil exclusion at least as conservative as the
        // reviewed guard before applying the additional contour/color guards.
        let radius = max(2.5, max(eyeHeight * 0.58, eyeWidth * 0.16) + eyeWidth * 0.14)
        return (0..<grid.pixelCount).map { index in
            let dx = grid.pixelCenterX(index) - pupil.x * Double(grid.sourceWidth)
            let dy = grid.pixelCenterY(index) - pupil.y * Double(grid.sourceHeight)
            return dx * dx + dy * dy <= radius * radius
        }
    }

    private static func expandedColorExclusion(
        sourceBytes: Data,
        aperture: [Bool],
        grid: EyeMaskGrid,
        sourceWidth: Int,
        predicate: (PixelFeatures) -> Bool
    ) -> [Bool] {
        var raw = [Bool](repeating: false, count: grid.pixelCount)
        for index in raw.indices where aperture[index] {
            let global = grid.globalPixelIndex(index, sourceWidth: sourceWidth)
            raw[index] = predicate(PixelFeatures(sourceBytes: sourceBytes, pixelIndex: global))
        }
        return dilate(raw, width: grid.width, height: grid.height, radius: 1)
    }

    private static func erode(_ mask: [Bool], width: Int, height: Int, radius: Int) -> [Bool] {
        var result = [Bool](repeating: false, count: mask.count)
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                guard mask[index] else { continue }
                var survives = true
                for dy in -radius...radius where survives {
                    for dx in -radius...radius {
                        let nextX = x + dx
                        let nextY = y + dy
                        if nextX < 0 || nextY < 0 || nextX >= width || nextY >= height
                            || !mask[nextY * width + nextX]
                        {
                            survives = false
                            break
                        }
                    }
                }
                result[index] = survives
            }
        }
        return result
    }

    private static func dilate(_ mask: [Bool], width: Int, height: Int, radius: Int) -> [Bool] {
        var result = mask
        for index in mask.indices where mask[index] {
            let x = index % width
            let y = index / width
            for dy in -radius...radius {
                for dx in -radius...radius {
                    let nextX = x + dx
                    let nextY = y + dy
                    if nextX >= 0, nextY >= 0, nextX < width, nextY < height {
                        result[nextY * width + nextX] = true
                    }
                }
            }
        }
        return result
    }

    private static func boxBlur(_ values: [Float], width: Int, height: Int) -> [Float] {
        var result = [Float](repeating: 0, count: values.count)
        for y in 0..<height {
            for x in 0..<width {
                var total: Float = 0
                var count: Float = 0
                for dy in -1...1 {
                    for dx in -1...1 {
                        let nextX = x + dx
                        let nextY = y + dy
                        if nextX >= 0, nextY >= 0, nextX < width, nextY < height {
                            total += values[nextY * width + nextX]
                            count += 1
                        }
                    }
                }
                result[y * width + x] = count > 0 ? total / count : 0
            }
        }
        return result
    }

    private static func constrainToHardEnvelope(
        _ values: [Float],
        hardEnvelope: [Bool]
    ) -> [Float] {
        zip(values, hardEnvelope).map { $0.1 ? clamp($0.0) : 0 }
    }

    private static func smoothstep(_ lower: Float, _ upper: Float, _ value: Float) -> Float {
        guard upper > lower else { return value >= upper ? 1 : 0 }
        let t = clamp((value - lower) / (upper - lower))
        return t * t * (3 - 2 * t)
    }

    private static func clamp(_ value: Float) -> Float { min(1, max(0, value)) }
}

private struct EyeUnitResult {
    let unit: BeautyLocalRetouchUnit?
    let outcome: BeautyScleraEyeOutcome
    let proposalPixelCount: Int
    let proposalPixelIndices: [Int]

    init(
        unit: BeautyLocalRetouchUnit? = nil,
        outcome: BeautyScleraEyeOutcome,
        proposalPixelCount: Int = 0,
        proposalPixelIndices: [Int] = []
    ) {
        self.unit = unit
        self.outcome = outcome
        self.proposalPixelCount = proposalPixelCount
        self.proposalPixelIndices = proposalPixelIndices
    }
}

private struct EyeBounds {
    let minX: Double
    let minY: Double
    let maxX: Double
    let maxY: Double
    var width: Double { maxX - minX }
    var height: Double { maxY - minY }
}

private struct ValidatedEyePolygon {
    let points: [CoordinatePoint]
    let bounds: EyeBounds
    let area: Double

    init?(points: [CoordinatePoint], sourceWidth: Int, sourceHeight: Int) {
        guard points.count >= 4,
              points.count <= 64,
              points.allSatisfy({
                  $0.x.isFinite && $0.y.isFinite
                      && (0...1).contains($0.x) && (0...1).contains($0.y)
              }),
              Set(points.map { "\($0.x.bitPattern):\($0.y.bitPattern)" }).count == points.count
        else { return nil }
        let minX = points.map(\.x).min() ?? 0
        let maxX = points.map(\.x).max() ?? 0
        let minY = points.map(\.y).min() ?? 0
        let maxY = points.map(\.y).max() ?? 0
        let bounds = EyeBounds(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        var doubledArea = 0.0
        for index in points.indices {
            let next = points[(index + 1) % points.count]
            doubledArea += points[index].x * next.y - next.x * points[index].y
        }
        let area = abs(doubledArea) * 0.5
        let pixelWidth = bounds.width * Double(sourceWidth)
        let pixelHeight = bounds.height * Double(sourceHeight)
        let aspect = pixelHeight / max(pixelWidth, 0.000_001)
        guard area >= BeautyScleraRednessProvider.minimumContourArea,
              area <= BeautyScleraRednessProvider.maximumContourArea,
              bounds.width <= BeautyScleraRednessProvider.maximumNormalizedWidth,
              bounds.height <= BeautyScleraRednessProvider.maximumNormalizedHeight,
              pixelWidth >= BeautyScleraRednessProvider.minimumPixelWidth,
              pixelHeight >= BeautyScleraRednessProvider.minimumPixelHeight,
              aspect >= BeautyScleraRednessProvider.minimumAspect,
              aspect <= BeautyScleraRednessProvider.maximumAspect,
              !SelfIntersections.hasIntersection(points)
        else { return nil }
        self.points = points
        self.bounds = bounds
        self.area = area
    }

    func contains(_ point: CoordinatePoint) -> Bool {
        var inside = false
        var previous = points.count - 1
        for current in points.indices {
            let lhs = points[current]
            let rhs = points[previous]
            if (lhs.y > point.y) != (rhs.y > point.y) {
                let denominator = rhs.y - lhs.y
                let crossingX = (rhs.x - lhs.x) * (point.y - lhs.y) / denominator + lhs.x
                if point.x < crossingX { inside.toggle() }
            }
            previous = current
        }
        return inside
    }

    func pupilIsPlausible(_ point: CoordinatePoint) -> Bool {
        let centerX = (bounds.minX + bounds.maxX) * 0.5
        let centerY = (bounds.minY + bounds.maxY) * 0.5
        let normalizedX = abs(point.x - centerX) / max(bounds.width, 0.000_001)
        let normalizedY = abs(point.y - centerY) / max(bounds.height, 0.000_001)
        return normalizedX <= 0.42 && normalizedY <= 0.42
    }
}

private enum SelfIntersections {
    static func hasIntersection(_ points: [CoordinatePoint]) -> Bool {
        for first in points.indices {
            let firstNext = (first + 1) % points.count
            for second in points.indices where second > first {
                let secondNext = (second + 1) % points.count
                if first == second || firstNext == second || secondNext == first { continue }
                if segmentsIntersect(points[first], points[firstNext], points[second], points[secondNext]) {
                    return true
                }
            }
        }
        return false
    }

    private static func segmentsIntersect(
        _ a: CoordinatePoint,
        _ b: CoordinatePoint,
        _ c: CoordinatePoint,
        _ d: CoordinatePoint
    ) -> Bool {
        let o1 = orientation(a, b, c)
        let o2 = orientation(a, b, d)
        let o3 = orientation(c, d, a)
        let o4 = orientation(c, d, b)
        return o1 * o2 < 0 && o3 * o4 < 0
    }

    private static func orientation(
        _ a: CoordinatePoint,
        _ b: CoordinatePoint,
        _ c: CoordinatePoint
    ) -> Double {
        (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    }
}

private struct EyeMaskGrid {
    let originX: Int
    let originY: Int
    let width: Int
    let height: Int
    let sourceWidth: Int
    let sourceHeight: Int
    let pixelCount: Int

    init?(polygon: ValidatedEyePolygon, source: BeautyCanonicalStillImage) {
        let minimumX = max(0, Int(floor(polygon.bounds.minX * Double(source.width))) - 1)
        let maximumX = min(source.width, Int(ceil(polygon.bounds.maxX * Double(source.width))) + 1)
        let minimumY = max(0, Int(floor(polygon.bounds.minY * Double(source.height))) - 1)
        let maximumY = min(source.height, Int(ceil(polygon.bounds.maxY * Double(source.height))) + 1)
        let width = maximumX - minimumX
        let height = maximumY - minimumY
        let (pixelCount, overflow) = width.multipliedReportingOverflow(by: height)
        guard !overflow, width > 0, height > 0, pixelCount > 0 else { return nil }
        originX = minimumX
        originY = minimumY
        self.width = width
        self.height = height
        sourceWidth = source.width
        sourceHeight = source.height
        self.pixelCount = pixelCount
    }

    func rasterize(_ polygon: ValidatedEyePolygon) -> [Bool] {
        (0..<pixelCount).map { index in
            polygon.contains(CoordinatePoint(
                x: pixelCenterX(index) / Double(sourceWidth),
                y: pixelCenterY(index) / Double(sourceHeight)
            ))
        }
    }

    func pixelCenterX(_ index: Int) -> Double { Double(originX + index % width) + 0.5 }
    func pixelCenterY(_ index: Int) -> Double { Double(originY + index / width) + 0.5 }
    func globalPixelIndex(_ index: Int, sourceWidth: Int) -> Int {
        (originY + index / width) * sourceWidth + originX + index % width
    }
}

private struct PixelFeatures {
    let luminance: Float
    let saturation: Float
    let redExcess: Float

    init(sourceBytes: Data, pixelIndex: Int) {
        let offset = pixelIndex * 4
        let red = Float(sourceBytes[offset]) / 255
        let green = Float(sourceBytes[offset + 1]) / 255
        let blue = Float(sourceBytes[offset + 2]) / 255
        let maximum = max(red, max(green, blue))
        let minimum = min(red, min(green, blue))
        luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        saturation = maximum > 0.001 ? (maximum - minimum) / maximum : 0
        redExcess = max(0, red - max(green, blue))
    }
}
