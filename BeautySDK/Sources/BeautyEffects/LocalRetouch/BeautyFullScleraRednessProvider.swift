import BeautyCore
import BeautyDetection
import Foundation

/// Full visible-sclera strategy.
///
/// Unlike `BeautyFocalScleraRednessProvider`, this provider uses material red
/// pixels only to admit an eye. Once admitted, it builds a low-strength mask
/// over the complete geometry-qualified sclera and raises the mask around
/// stronger redness. The medial caruncle is removed from the hard envelope
/// before any color score or feathering.
package enum BeautyFullScleraRednessProvider {
    fileprivate static let minimumContourArea = 0.000_02
    fileprivate static let maximumContourArea = 0.20
    fileprivate static let minimumPixelWidth = 8.0
    fileprivate static let minimumPixelHeight = 4.0
    fileprivate static let minimumAspect = 0.12
    fileprivate static let maximumAspect = 1.20
    fileprivate static let maximumNormalizedWidth = 0.50
    fileprivate static let maximumNormalizedHeight = 0.40
    fileprivate static let maximumPupilCenterOffsetFraction = 0.035

    private static let minimumMaterialRednessScore: Float = 0.50
    private static let minimumBroadMaskWeight: Float = 0.08
    private static let broadScleraWeight: Float = 0.56
    private static let medialCoreFraction = 0.07
    private static let medialCandidateFraction = 0.17

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

        var units: [BeautyLocalRetouchUnit] = []
        var leftOutcome: BeautyScleraEyeOutcome = .missingSupport
        var rightOutcome: BeautyScleraEyeOutcome = .missingSupport
        var proposalPixelIndices: [Int] = []
        for side in [BeautyObservedEyeSide.left, .right] {
            let support = side == .left ? leftSupport : rightSupport
            guard let support else { continue }
            let result = makeEyeUnit(
                source: source,
                support: support,
                strength: strength,
                owner: owner
            )
            if side == .left {
                leftOutcome = result.outcome
            } else {
                rightOutcome = result.outcome
            }
            proposalPixelIndices.append(contentsOf: result.proposalPixelIndices)
            if let unit = result.unit { units.append(unit) }
        }

        return BeautyScleraRednessProviderResult(
            units: units,
            summary: BeautyScleraRednessProviderSummary(
                leftOutcome: leftOutcome,
                rightOutcome: rightOutcome,
                acceptedEyeCount: units.count,
                proposalPixelCount: proposalPixelIndices.count
            ),
            proposalPixelIndices: proposalPixelIndices
        )
    }

    private static func makeEyeUnit(
        source: BeautyCanonicalStillImage,
        support: BeautyObservedEyeSupport,
        strength: Float,
        owner: BeautyLocalRetouchCompositionOwner
    ) -> FullScleraEyeUnitResult {
        guard let polygon = FullScleraValidatedEyePolygon(
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
              let grid = FullScleraMaskGrid(polygon: polygon, source: source)
        else {
            return FullScleraEyeUnitResult(outcome: .invalidSupport)
        }

        let aperture = grid.rasterize(polygon)
        // Full-sclera coverage needs a narrow lid guard rather than the focal
        // strategy's large erosion. Dark lashes remain protected separately.
        let baseContourMargin = 1
        let pupilUncertaintyMargin = polygon.pupilHorizontalOffsetFraction(pupilPoint) > 0.025
            ? 1
            : 0
        let erodedAperture = erode(
            aperture,
            width: grid.width,
            height: grid.height,
            radius: baseContourMargin + pupilUncertaintyMargin
        )

        let sourceBytes = source.rgba8Data
        let irisExclusion = guardedIrisExclusion(
            pupil: pupilPoint,
            polygon: polygon,
            grid: grid,
            sourceBytes: sourceBytes,
            aperture: aperture
        )
        let nativeDarkIrisExclusion = expandedNativeDarkIrisExclusion(
            pupil: pupilPoint,
            polygon: polygon,
            grid: grid,
            sourceBytes: sourceBytes,
            aperture: aperture
        )
        let highlightExclusion = expandedColorExclusion(
            sourceBytes: sourceBytes,
            aperture: aperture,
            grid: grid,
            sourceWidth: source.width,
            predicate: { $0.luminance >= 0.92 && $0.saturation <= 0.10 }
        )
        let lashExclusion = guardedLashExclusion(
            sourceBytes: sourceBytes,
            aperture: aperture,
            polygon: polygon,
            grid: grid,
            sourceWidth: source.width
        )
        let caruncleExclusion = guardedCaruncleExclusion(
            side: support.side,
            sourceBytes: sourceBytes,
            aperture: aperture,
            polygon: polygon,
            grid: grid,
            sourceWidth: source.width
        )

        let hardEnvelope = erodedAperture.indices.map { index in
            erodedAperture[index]
                && !irisExclusion[index]
                && !nativeDarkIrisExclusion[index]
                && !highlightExclusion[index]
                && !lashExclusion[index]
                && !caruncleExclusion[index]
        }
        guard hardEnvelope.contains(true) else {
            return FullScleraEyeUnitResult(outcome: .emptyEnvelope)
        }

        var scleraLikelihood = [Float](repeating: 0, count: grid.pixelCount)
        var rednessScore = [Float](repeating: 0, count: grid.pixelCount)
        for index in hardEnvelope.indices where hardEnvelope[index] {
            let globalIndex = grid.globalPixelIndex(index, sourceWidth: source.width)
            let features = FullScleraPixelFeatures(
                sourceBytes: sourceBytes,
                pixelIndex: globalIndex
            )
            let light = smoothstep(0.20, 0.62, features.luminance)
            let lowSaturation = 1 - smoothstep(0.58, 0.88, features.saturation)
            scleraLikelihood[index] = clamp(light * lowSaturation)
            rednessScore[index] = smoothstep(0.035, 0.14, features.redExcess)
        }

        // Redness admits the eye; it no longer defines the entire edit extent.
        // This prevents a natural negative from becoming broadly whiter while
        // allowing the accepted eye's full visible sclera to participate.
        let materialCount = rednessScore.indices.lazy.filter {
            hardEnvelope[$0]
                && scleraLikelihood[$0] >= 0.20
                && rednessScore[$0] >= minimumMaterialRednessScore
        }.count
        guard materialCount >= 2 else {
            return FullScleraEyeUnitResult(outcome: .noMaterialRedness)
        }

        var layeredMask = [Float](repeating: 0, count: grid.pixelCount)
        for index in layeredMask.indices where hardEnvelope[index] {
            let vesselBoost = (1 - broadScleraWeight) * rednessScore[index]
            layeredMask[index] = clamp(broadScleraWeight + vesselBoost)
        }
        let finalMask = constrainToHardEnvelope(
            boxBlur(layeredMask, width: grid.width, height: grid.height),
            hardEnvelope: hardEnvelope
        )

        var proposals: [BeautyLocalPixelProposal] = []
        proposals.reserveCapacity(hardEnvelope.lazy.filter { $0 }.count)
        for index in finalMask.indices {
            let softWeight = finalMask[index]
            guard hardEnvelope[index], softWeight >= minimumBroadMaskWeight else { continue }
            let globalIndex = grid.globalPixelIndex(index, sourceWidth: source.width)
            let offset = globalIndex * 4
            guard let target = BeautyFullScleraRednessTransform.target(
                red: sourceBytes[offset],
                green: sourceBytes[offset + 1],
                blue: sourceBytes[offset + 2],
                strength: strength
            ) else { continue }
            let weightQ16 = UInt32(
                (Double(softWeight) * 65_536).rounded(.toNearestOrAwayFromZero)
            )
            guard weightQ16 > 0 else { continue }
            proposals.append(BeautyLocalPixelProposal(
                pixelIndex: globalIndex,
                isInsideHardEnvelope: true,
                softWeightQ16: min(65_536, weightQ16),
                targetRed: target.red,
                targetGreen: target.green,
                targetBlue: target.blue
            ))
        }
        guard !proposals.isEmpty else {
            return FullScleraEyeUnitResult(outcome: .noMaterialRedness)
        }
        guard let unit = owner.makeUnit(proposals: proposals) else {
            return FullScleraEyeUnitResult(outcome: .unitRejected)
        }
        return FullScleraEyeUnitResult(
            unit: unit,
            outcome: .accepted,
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

    private static func guardedIrisExclusion(
        pupil: CoordinatePoint,
        polygon: FullScleraValidatedEyePolygon,
        grid: FullScleraMaskGrid,
        sourceBytes: Data,
        aperture: [Bool]
    ) -> [Bool] {
        let eyeWidth = polygon.bounds.width * Double(grid.sourceWidth)
        let eyeHeight = polygon.bounds.height * Double(grid.sourceHeight)
        // The focal strategy's +14% eye-width uncertainty erased most visible
        // sclera. Full Sclera uses an aperture/iris proportion plus bounded
        // detection uncertainty. Unioning pupil- and aperture-centered guards
        // protects both pupil jitter and small contour-center drift.
        let fallbackRadius = max(eyeHeight * 0.38, eyeWidth * 0.11)
            + max(4.8, eyeWidth * 0.025)
        let irisRadius = fallbackRadius
        let apertureCenterX = (polygon.bounds.minX + polygon.bounds.maxX)
            * 0.5 * Double(grid.sourceWidth)
        let apertureCenterY = (polygon.bounds.minY + polygon.bounds.maxY)
            * 0.5 * Double(grid.sourceHeight)
        let pupilX = pupil.x * Double(grid.sourceWidth)
        let pupilY = pupil.y * Double(grid.sourceHeight)
        let squaredRadius = irisRadius * irisRadius
        let verticalRadius = nativeIrisContrastConfirmed(
            pupilX: pupilX,
            pupilY: pupilY,
            fallbackRadius: fallbackRadius,
            eyeHeight: eyeHeight,
            grid: grid,
            sourceBytes: sourceBytes,
            aperture: aperture
        ) ? irisRadius * 0.80 : irisRadius
        let squaredVerticalRadius = verticalRadius * verticalRadius
        return (0..<grid.pixelCount).map { index in
            let x = grid.pixelCenterX(index)
            let y = grid.pixelCenterY(index)
            let pupilDX = x - pupilX
            let pupilDY = y - pupilY
            let apertureDX = x - apertureCenterX
            let apertureDY = y - apertureCenterY
            return pupilDX * pupilDX / squaredRadius
                    + pupilDY * pupilDY / squaredVerticalRadius <= 1
                || apertureDX * apertureDX / squaredRadius
                    + apertureDY * apertureDY / squaredVerticalRadius <= 1
        }
    }

    private static func nativeIrisContrastConfirmed(
        pupilX: Double,
        pupilY: Double,
        fallbackRadius: Double,
        eyeHeight: Double,
        grid: FullScleraMaskGrid,
        sourceBytes: Data,
        aperture: [Bool]
    ) -> Bool {
        let innerRadius = min(fallbackRadius * 0.42, eyeHeight * 0.24)
        var inner: [Float] = []
        for index in aperture.indices where aperture[index] {
            let dx = grid.pixelCenterX(index) - pupilX
            let dy = grid.pixelCenterY(index) - pupilY
            let distance = hypot(dx, dy)
            let features = FullScleraPixelFeatures(
                sourceBytes: sourceBytes,
                pixelIndex: grid.globalPixelIndex(index, sourceWidth: grid.sourceWidth)
            )
            guard features.luminance < 0.92 else { continue }
            if distance <= innerRadius {
                inner.append(features.luminance)
            }
        }
        guard inner.count >= 8 else { return false }
        let innerMean = inner.reduce(0, +) / Float(inner.count)
        return innerMean <= 0.62
    }

    private static func guardedCaruncleExclusion(
        side: BeautyObservedEyeSide,
        sourceBytes: Data,
        aperture: [Bool],
        polygon: FullScleraValidatedEyePolygon,
        grid: FullScleraMaskGrid,
        sourceWidth: Int
    ) -> [Bool] {
        let eyeWidth = polygon.bounds.width * Double(grid.sourceWidth)
        let coreWidth = max(1.5, eyeWidth * medialCoreFraction)
        let candidateWidth = max(coreWidth + 1, eyeWidth * medialCandidateFraction)
        let medialX = (side == .left ? polygon.bounds.maxX : polygon.bounds.minX)
            * Double(grid.sourceWidth)

        var guarded = [Bool](repeating: false, count: grid.pixelCount)
        for index in guarded.indices where aperture[index] {
            let inwardDistance = side == .left
                ? medialX - grid.pixelCenterX(index)
                : grid.pixelCenterX(index) - medialX
            guard inwardDistance >= 0, inwardDistance <= candidateWidth else { continue }
            if inwardDistance <= coreWidth {
                guarded[index] = true
                continue
            }
            let globalIndex = grid.globalPixelIndex(index, sourceWidth: sourceWidth)
            let features = FullScleraPixelFeatures(
                sourceBytes: sourceBytes,
                pixelIndex: globalIndex
            )
            // The location prior prevents red scleral vessels elsewhere from
            // being mislabeled as caruncle. The core remains color-independent.
            guarded[index] = features.redExcess >= 0.04
                && features.saturation >= 0.12
                && features.luminance >= 0.18
                && features.luminance <= 0.90
        }
        return dilate(guarded, width: grid.width, height: grid.height, radius: 1)
    }

    private static func expandedNativeDarkIrisExclusion(
        pupil: CoordinatePoint,
        polygon: FullScleraValidatedEyePolygon,
        grid: FullScleraMaskGrid,
        sourceBytes: Data,
        aperture: [Bool]
    ) -> [Bool] {
        let eyeWidth = polygon.bounds.width * Double(grid.sourceWidth)
        let eyeHeight = polygon.bounds.height * Double(grid.sourceHeight)
        let radius = max(eyeHeight * 0.38, eyeWidth * 0.11)
            + max(4.8, eyeWidth * 0.025)
        let pupilX = pupil.x * Double(grid.sourceWidth)
        let pupilY = pupil.y * Double(grid.sourceHeight)
        let apertureX = (polygon.bounds.minX + polygon.bounds.maxX)
            * 0.5 * Double(grid.sourceWidth)
        let apertureY = (polygon.bounds.minY + polygon.bounds.maxY)
            * 0.5 * Double(grid.sourceHeight)
        let squaredRadius = radius * radius
        var raw = [Bool](repeating: false, count: grid.pixelCount)
        for index in raw.indices where aperture[index] {
            let x = grid.pixelCenterX(index)
            let y = grid.pixelCenterY(index)
            let pupilDistance = pow(x - pupilX, 2) + pow(y - pupilY, 2)
            let apertureDistance = pow(x - apertureX, 2) + pow(y - apertureY, 2)
            guard pupilDistance <= squaredRadius || apertureDistance <= squaredRadius else {
                continue
            }
            let features = FullScleraPixelFeatures(
                sourceBytes: sourceBytes,
                pixelIndex: grid.globalPixelIndex(index, sourceWidth: grid.sourceWidth)
            )
            raw[index] = features.luminance <= 0.48
        }
        return dilate(raw, width: grid.width, height: grid.height, radius: 1)
    }

    private static func guardedLashExclusion(
        sourceBytes: Data,
        aperture: [Bool],
        polygon: FullScleraValidatedEyePolygon,
        grid: FullScleraMaskGrid,
        sourceWidth: Int
    ) -> [Bool] {
        let eyeHeight = polygon.bounds.height * Double(grid.sourceHeight)
        let boundaryRadius = max(2, min(5, Int((eyeHeight * 0.05).rounded())))
        let interior = erode(
            aperture,
            width: grid.width,
            height: grid.height,
            radius: boundaryRadius
        )
        var raw = [Bool](repeating: false, count: grid.pixelCount)
        for index in raw.indices where aperture[index] && !interior[index] {
            let features = FullScleraPixelFeatures(
                sourceBytes: sourceBytes,
                pixelIndex: grid.globalPixelIndex(index, sourceWidth: sourceWidth)
            )
            raw[index] = features.luminance <= 0.22
        }
        return dilate(raw, width: grid.width, height: grid.height, radius: 1)
    }

    private static func expandedColorExclusion(
        sourceBytes: Data,
        aperture: [Bool],
        grid: FullScleraMaskGrid,
        sourceWidth: Int,
        predicate: (FullScleraPixelFeatures) -> Bool
    ) -> [Bool] {
        var raw = [Bool](repeating: false, count: grid.pixelCount)
        for index in raw.indices where aperture[index] {
            let globalIndex = grid.globalPixelIndex(index, sourceWidth: sourceWidth)
            raw[index] = predicate(FullScleraPixelFeatures(
                sourceBytes: sourceBytes,
                pixelIndex: globalIndex
            ))
        }
        return dilate(raw, width: grid.width, height: grid.height, radius: 1)
    }

    private static func erode(
        _ mask: [Bool],
        width: Int,
        height: Int,
        radius: Int
    ) -> [Bool] {
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

    private static func dilate(
        _ mask: [Bool],
        width: Int,
        height: Int,
        radius: Int
    ) -> [Bool] {
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
                for nextY in max(0, y - 1)...min(height - 1, y + 1) {
                    for nextX in max(0, x - 1)...min(width - 1, x + 1) {
                        total += values[nextY * width + nextX]
                        count += 1
                    }
                }
                result[y * width + x] = total / count
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

private struct FullScleraEyeUnitResult {
    let unit: BeautyLocalRetouchUnit?
    let outcome: BeautyScleraEyeOutcome
    let proposalPixelIndices: [Int]

    init(
        unit: BeautyLocalRetouchUnit? = nil,
        outcome: BeautyScleraEyeOutcome,
        proposalPixelIndices: [Int] = []
    ) {
        self.unit = unit
        self.outcome = outcome
        self.proposalPixelIndices = proposalPixelIndices
    }
}

private struct FullScleraEyeBounds {
    let minX: Double
    let minY: Double
    let maxX: Double
    let maxY: Double
    var width: Double { maxX - minX }
    var height: Double { maxY - minY }
}

private struct FullScleraValidatedEyePolygon {
    let points: [CoordinatePoint]
    let bounds: FullScleraEyeBounds

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
        let bounds = FullScleraEyeBounds(
            minX: minX,
            minY: minY,
            maxX: maxX,
            maxY: maxY
        )
        var doubledArea = 0.0
        for index in points.indices {
            let next = points[(index + 1) % points.count]
            doubledArea += points[index].x * next.y - next.x * points[index].y
        }
        let area = abs(doubledArea) * 0.5
        let pixelWidth = bounds.width * Double(sourceWidth)
        let pixelHeight = bounds.height * Double(sourceHeight)
        let aspect = pixelHeight / max(pixelWidth, 0.000_001)
        guard area >= BeautyFullScleraRednessProvider.minimumContourArea,
              area <= BeautyFullScleraRednessProvider.maximumContourArea,
              bounds.width <= BeautyFullScleraRednessProvider.maximumNormalizedWidth,
              bounds.height <= BeautyFullScleraRednessProvider.maximumNormalizedHeight,
              pixelWidth >= BeautyFullScleraRednessProvider.minimumPixelWidth,
              pixelHeight >= BeautyFullScleraRednessProvider.minimumPixelHeight,
              aspect >= BeautyFullScleraRednessProvider.minimumAspect,
              aspect <= BeautyFullScleraRednessProvider.maximumAspect,
              !FullScleraSelfIntersections.hasIntersection(points)
        else { return nil }
        self.points = points
        self.bounds = bounds
    }

    func contains(_ point: CoordinatePoint) -> Bool {
        var inside = false
        var previous = points.count - 1
        for current in points.indices {
            let lhs = points[current]
            let rhs = points[previous]
            if (lhs.y > point.y) != (rhs.y > point.y) {
                let crossingX = (rhs.x - lhs.x) * (point.y - lhs.y)
                    / (rhs.y - lhs.y) + lhs.x
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
        return normalizedX <= BeautyFullScleraRednessProvider.maximumPupilCenterOffsetFraction
            && normalizedY <= 0.42
    }

    func pupilHorizontalOffsetFraction(_ point: CoordinatePoint) -> Double {
        let centerX = (bounds.minX + bounds.maxX) * 0.5
        return abs(point.x - centerX) / max(bounds.width, 0.000_001)
    }
}

private enum FullScleraSelfIntersections {
    private struct Tolerance {
        let linear: Double
        let orientation: Double
    }

    static func hasIntersection(_ points: [CoordinatePoint]) -> Bool {
        let tolerance = tolerance(for: points)
        for index in points.indices {
            let next = (index + 1) % points.count
            if squaredDistance(points[index], points[next]) <= tolerance.linear * tolerance.linear {
                return true
            }
        }
        for first in points.indices {
            let firstNext = (first + 1) % points.count
            for second in points.indices where second > first {
                let secondNext = (second + 1) % points.count
                if firstNext == second {
                    if adjacentEdgesOverlap(
                        firstOther: points[first],
                        shared: points[firstNext],
                        secondOther: points[secondNext],
                        tolerance: tolerance
                    ) { return true }
                    continue
                }
                if secondNext == first {
                    if adjacentEdgesOverlap(
                        firstOther: points[firstNext],
                        shared: points[first],
                        secondOther: points[second],
                        tolerance: tolerance
                    ) { return true }
                    continue
                }
                if segmentsIntersect(
                    points[first],
                    points[firstNext],
                    points[second],
                    points[secondNext],
                    tolerance: tolerance
                ) { return true }
            }
        }
        return false
    }

    private static func tolerance(for points: [CoordinatePoint]) -> Tolerance {
        let minX = points.map(\.x).min() ?? 0
        let maxX = points.map(\.x).max() ?? 0
        let minY = points.map(\.y).min() ?? 0
        let maxY = points.map(\.y).max() ?? 0
        let extent = max(maxX - minX, maxY - minY)
        let linear = min(1e-8, max(64 * Double.ulpOfOne, extent * 1e-10))
        return Tolerance(
            linear: linear,
            orientation: min(1e-8, max(128 * Double.ulpOfOne, extent * linear))
        )
    }

    private static func adjacentEdgesOverlap(
        firstOther: CoordinatePoint,
        shared: CoordinatePoint,
        secondOther: CoordinatePoint,
        tolerance: Tolerance
    ) -> Bool {
        onSegment(shared, secondOther, firstOther, tolerance: tolerance)
            || onSegment(firstOther, shared, secondOther, tolerance: tolerance)
    }

    private static func segmentsIntersect(
        _ a: CoordinatePoint,
        _ b: CoordinatePoint,
        _ c: CoordinatePoint,
        _ d: CoordinatePoint,
        tolerance: Tolerance
    ) -> Bool {
        let s1 = sign(orientation(a, b, c), tolerance: tolerance.orientation)
        let s2 = sign(orientation(a, b, d), tolerance: tolerance.orientation)
        let s3 = sign(orientation(c, d, a), tolerance: tolerance.orientation)
        let s4 = sign(orientation(c, d, b), tolerance: tolerance.orientation)
        if s1 * s2 < 0, s3 * s4 < 0 { return true }
        return (s1 == 0 && onSegment(a, b, c, tolerance: tolerance))
            || (s2 == 0 && onSegment(a, b, d, tolerance: tolerance))
            || (s3 == 0 && onSegment(c, d, a, tolerance: tolerance))
            || (s4 == 0 && onSegment(c, d, b, tolerance: tolerance))
    }

    private static func orientation(
        _ a: CoordinatePoint,
        _ b: CoordinatePoint,
        _ c: CoordinatePoint
    ) -> Double {
        (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    }

    private static func onSegment(
        _ a: CoordinatePoint,
        _ b: CoordinatePoint,
        _ point: CoordinatePoint,
        tolerance: Tolerance
    ) -> Bool {
        guard abs(orientation(a, b, point)) <= tolerance.orientation else { return false }
        return point.x >= min(a.x, b.x) - tolerance.linear
            && point.x <= max(a.x, b.x) + tolerance.linear
            && point.y >= min(a.y, b.y) - tolerance.linear
            && point.y <= max(a.y, b.y) + tolerance.linear
    }

    private static func sign(_ value: Double, tolerance: Double) -> Int {
        if value > tolerance { return 1 }
        if value < -tolerance { return -1 }
        return 0
    }

    private static func squaredDistance(_ lhs: CoordinatePoint, _ rhs: CoordinatePoint) -> Double {
        let dx = lhs.x - rhs.x
        let dy = lhs.y - rhs.y
        return dx * dx + dy * dy
    }
}

private struct FullScleraMaskGrid {
    let originX: Int
    let originY: Int
    let width: Int
    let height: Int
    let sourceWidth: Int
    let sourceHeight: Int
    let pixelCount: Int

    init?(polygon: FullScleraValidatedEyePolygon, source: BeautyCanonicalStillImage) {
        let minimumX = max(0, Int(floor(polygon.bounds.minX * Double(source.width))) - 1)
        let maximumX = min(
            source.width,
            Int(ceil(polygon.bounds.maxX * Double(source.width))) + 1
        )
        let minimumY = max(0, Int(floor(polygon.bounds.minY * Double(source.height))) - 1)
        let maximumY = min(
            source.height,
            Int(ceil(polygon.bounds.maxY * Double(source.height))) + 1
        )
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

    func rasterize(_ polygon: FullScleraValidatedEyePolygon) -> [Bool] {
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

    func localIndex(sourceX: Int, sourceY: Int) -> Int? {
        let x = sourceX - originX
        let y = sourceY - originY
        guard x >= 0, y >= 0, x < width, y < height else { return nil }
        return y * width + x
    }
}

private struct FullScleraPixelFeatures {
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
        redExcess = max(0, red - 0.83 * green - 0.17 * blue)
    }
}
