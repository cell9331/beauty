import Foundation
import BeautyDetection

/// Request-local raster alignment of the observed lateral contour. It reads
/// every sample from the immutable input and never retains pixels or support.
enum FaceContourSubpixelRefiner {
    private enum BoundaryDetection {
        case found(Float, Int)
        case ambiguous
        case weak
        case unavailable
    }

    static func refine(
        _ source: [UInt8],
        width: Int,
        height: Int,
        face: FaceGeometry,
        strength: Float
    ) -> [UInt8] {
        guard width > 1, height > 1 else { return source }
        let pixels = width.multipliedReportingOverflow(by: height)
        guard !pixels.overflow else { return source }
        let byteCount = pixels.partialValue.multipliedReportingOverflow(by: 4)
        guard !byteCount.overflow,
              source.count == byteCount.partialValue,
              strength.isFinite, strength > 0,
              let contour = face.observedFaceSupport?.contour,
              let runs = FaceContourLateralRuns.make(from: contour)
        else { return source }

        let requested = min(1, strength / BeautySafetyCaps.faceContourSmooth)
        guard requested.isFinite, requested > 0 else { return source }
        var strengths = BeautyEffectiveStrengths()
        strengths.faceContourSmooth = strength
        guard !FaceShapeWarpProvider().fieldEmissions(
            face: face,
            strengths: strengths
        ).faceContourSmooth.isEmpty else { return source }
        var result = source
        let outerRadius = 14
        let feather = 6.0 as Float
        let endpointTaper = 20.0 as Float

        for (runIndex, run) in runs.enumerated() {
            guard let first = run.ordered.first, let last = run.ordered.last else { return source }
            let isLeftSide = runIndex == 0
            if refineObservedBoundary(
                source, result: &result, width: width, height: height,
                faceWidth: face.bounds.width, run: run,
                isLeftSide: isLeftSide, requested: requested
            ) {
                continue
            }
            var segment = 0
            for row in 0..<height {
                let y = (Float(row) + 0.5) / Float(height)
                guard y >= first.y, y < last.y else { continue }
                while segment + 1 < run.ordered.count - 1 && y > run.ordered[segment + 1].y {
                    segment += 1
                }
                let lower = run.ordered[segment]
                let upper = run.ordered[segment + 1]
                let progress = (y - lower.y) / (upper.y - lower.y)
                let continuousCenter = (lower.x + (upper.x - lower.x) * progress) * Float(width)
                guard continuousCenter.isFinite else { return source }
                let roundedCenter = Int(continuousCenter.rounded())
                let fractionalShift = strongBoundaryShift(
                    source,
                    width: width,
                    row: row,
                    center: roundedCenter,
                    continuousCenter: continuousCenter,
                    isLeftSide: isLeftSide
                ) ?? (continuousCenter - Float(roundedCenter))
                let yWeight = min(
                    1,
                    (y - first.y) * Float(height) / endpointTaper,
                    (last.y - y) * Float(height) / endpointTaper
                )
                guard yWeight > 0, abs(fractionalShift) > Float.ulpOfOne else { continue }
                let lowerColumn = max(0, roundedCenter - outerRadius)
                let upperColumn = min(width - 1, roundedCenter + outerRadius)
                guard lowerColumn <= upperColumn else { continue }

                for column in lowerColumn...upperColumn {
                    let distance = abs(Float(column - roundedCenter))
                    let xWeight = min(1, max(0, (Float(outerRadius) - distance) / feather))
                    let shift = fractionalShift * requested * yWeight * xWeight
                    guard abs(shift) > Float.ulpOfOne else { continue }
                    let sampleX = Float(column) - shift
                    guard sampleX >= 0, sampleX <= Float(width - 1) else { continue }
                    let x0 = Int(floor(sampleX))
                    let x1 = min(width - 1, x0 + 1)
                    let fraction = sampleX - Float(x0)
                    let destination = (row * width + column) * 4
                    let source0 = (row * width + x0) * 4
                    let source1 = (row * width + x1) * 4
                    guard source[destination + 3] == 255,
                          source[source0 + 3] == 255,
                          source[source1 + 3] == 255 else { continue }
                    for channel in 0..<3 {
                        let a = Float(source[source0 + channel])
                        let b = Float(source[source1 + channel])
                        result[destination + channel] = UInt8(
                            min(255, max(0, Int((a + (b - a) * fraction).rounded())))
                        )
                    }
                }
            }
        }
        return result
    }

    /// Vision's sparse contour can sit well inside the visible cheek boundary.
    /// Admit a wider correction only when source pixels locate one coherent
    /// outer edge across the observed lateral run. Ambiguous rows remain local
    /// no-ops; an unqualified run keeps the former subpixel alignment.
    private static func refineObservedBoundary(
        _ source: [UInt8], result: inout [UInt8],
        width: Int, height: Int, faceWidth: Float,
        run: FaceContourLateralRuns.Run, isLeftSide: Bool,
        requested: Float
    ) -> Bool {
        guard let first = run.ordered.first, let last = run.ordered.last,
              faceWidth.isFinite, faceWidth > 0 else { return false }
        let start = max(0, Int(ceil(first.y * Float(height) - 0.5)))
        let end = min(height, Int(ceil(last.y * Float(height) - 0.5)))
        guard end - start >= 80 else { return false }
        let facePixels = faceWidth * Float(width)
        let searchRadius = min(48, max(8, Int((facePixels * 0.08).rounded())))
        let outerRadius = min(32, max(8, Int((facePixels * 0.05).rounded())))
        let maximumShift = min(6, max(0.5, facePixels * 0.01))
        let smoothingRadius = min(24, max(8, Int((facePixels * 0.035).rounded())))
        let inset = max(20, (end - start) / 12)
        // The upper run includes the ear/temple junction. Its silhouette can
        // be a stronger edge than the cheek. An admitted wide pass leaves
        // that upper portion untouched by this raster preprocessor.
        let activeStart = start + max(inset, Int(Float(end - start) * 0.48))
        let activeEnd = end - inset
        guard activeEnd - activeStart >= 40 else { return false }

        var centers = [Float?](repeating: nil, count: end - start)
        var edges = [Float?](repeating: nil, count: end - start)
        var directions = [Int?](repeating: nil, count: end - start)
        var ambiguousRows = 0
        var weakRows = 0
        var segment = 0
        for row in start..<end {
            let y = (Float(row) + 0.5) / Float(height)
            while segment + 1 < run.ordered.count - 1 && y > run.ordered[segment + 1].y {
                segment += 1
            }
            let lower = run.ordered[segment]
            let upper = run.ordered[segment + 1]
            let progress = (y - lower.y) / (upper.y - lower.y)
            let center = (lower.x + (upper.x - lower.x) * progress) * Float(width)
            guard center.isFinite else { return false }
            centers[row - start] = center
            let boundary = strongOuterBoundary(
                source, width: width, row: row,
                center: Int(center.rounded()), searchRadius: searchRadius,
                isLeftSide: isLeftSide
            )
            switch boundary {
            case .found(let location, let direction):
                edges[row - start] = location
                directions[row - start] = direction
            case .ambiguous:
                if row >= activeStart && row < activeEnd { ambiguousRows += 1 }
            case .weak:
                if row >= activeStart && row < activeEnd { weakRows += 1 }
            case .unavailable: break
            }
        }
        // Many competing edges make the entire side unsafe to infer. Do not
        // fall back to a point-center shift that could follow one of them.
        if ambiguousRows >= max(20, (activeEnd - activeStart) / 4) {
            return true
        }
        // A coherent but weak source edge cannot justify either the wider
        // shift or the old point-centered shift near the ear junction.
        if weakRows >= max(20, (activeEnd - activeStart) * 2 / 3) {
            return true
        }

        let activeDirections = (activeStart..<activeEnd).compactMap { directions[$0 - start] }
        let positive = activeDirections.filter { $0 > 0 }.count
        let negative = activeDirections.count - positive
        guard max(positive, negative) >= max(40, (activeEnd - activeStart) * 2 / 3)
        else {
            // A well-observed but contradictory edge is unsafe for either
            // wide correction or point-centered fallback.
            return activeDirections.count >= max(40, (activeEnd - activeStart) * 2 / 3)
        }
        let dominantDirection = positive >= negative ? 1 : -1
        for row in start..<end where directions[row - start] != dominantDirection {
            edges[row - start] = nil
        }

        let admitted = (activeStart..<activeEnd).compactMap { row -> Float? in
            guard let center = centers[row - start], let edge = edges[row - start] else { return nil }
            return abs(center - edge)
        }
        guard admitted.count >= max(40, (activeEnd - activeStart) * 2 / 3),
              admitted.reduce(0, +) / Float(admitted.count) >= 2.5
        else { return false }

        let feather = min(8, Float(outerRadius) / 2)
        for row in activeStart..<activeEnd {
            guard let boundary = edges[row - start] else { continue }
            var weightedSum: Float = 0
            var totalWeight: Float = 0
            var valid = 0
            for neighbor in max(start, row - smoothingRadius)...min(end - 1, row + smoothingRadius) {
                guard let value = edges[neighbor - start] else { continue }
                let weight = Float(smoothingRadius + 1 - abs(neighbor - row))
                weightedSum += value * weight
                totalWeight += weight
                valid += 1
            }
            guard valid >= smoothingRadius,
                  totalWeight > 0 else { continue }
            let target = weightedSum / totalWeight
            let endWeight = min(
                1, Float(row - activeStart + 1) / 20,
                Float(activeEnd - row) / 20
            )
            let shift = max(-maximumShift, min(maximumShift, target - boundary)) *
                requested * endWeight
            guard shift.isFinite, abs(shift) >= 0.05 else { continue }
            let edgeColumn = Int(boundary.rounded())
            for column in max(0, edgeColumn - outerRadius)...min(width - 1, edgeColumn + outerRadius) {
                let distance = abs(Float(column) - boundary)
                let xWeight = min(1, max(0, (Float(outerRadius) - distance) / feather))
                let sampleX = Float(column) - shift * xWeight
                guard xWeight > 0, sampleX >= 0,
                      sampleX <= Float(width - 1) else { continue }
                let x0 = Int(floor(sampleX))
                let x1 = min(width - 1, x0 + 1)
                let fraction = sampleX - Float(x0)
                let destination = (row * width + column) * 4
                let source0 = (row * width + x0) * 4
                let source1 = (row * width + x1) * 4
                guard source[destination + 3] == 255,
                      source[source0 + 3] == 255,
                      source[source1 + 3] == 255 else { continue }
                for channel in 0..<3 {
                    let a = Float(source[source0 + channel])
                    let b = Float(source[source1 + channel])
                    result[destination + channel] = UInt8(
                        min(255, max(0, Int((a + (b - a) * fraction).rounded())))
                    )
                }
            }
        }
        return true
    }

    private static func strongOuterBoundary(
        _ source: [UInt8], width: Int, row: Int,
        center: Int, searchRadius: Int, isLeftSide: Bool
    ) -> BoundaryDetection {
        let lower = max(4, center - searchRadius)
        let upper = min(width - 5, center + searchRadius)
        guard lower <= upper else { return .unavailable }
        var candidates: [(column: Int, contrast: Int)] = []
        for column in lower...upper {
            let left = (row * width + column - 4) * 4
            let right = (row * width + column + 1) * 4
            guard (0..<4).allSatisfy({ offset in
                source[left + offset * 4 + 3] == 255 &&
                    source[right + offset * 4 + 3] == 255
            }) else { continue }
            var contrast = 0
            for channel in 0..<3 {
                var before = 0
                var after = 0
                for offset in 0..<4 {
                    before += Int(source[left + offset * 4 + channel])
                    after += Int(source[right + offset * 4 + channel])
                }
                contrast += abs(before - after)
            }
            candidates.append((column, contrast / 12))
        }
        guard let strongest = candidates.max(by: { $0.contrast < $1.contrast })
        else { return .unavailable }
        guard strongest.contrast >= 24 else {
            return strongest.contrast >= 4 ? .weak : .unavailable
        }
        let competing = candidates.filter {
            abs($0.column - strongest.column) >= 8 &&
                $0.contrast * 5 >= strongest.contrast * 2
        }
        if !competing.isEmpty {
            // A dark hair band can put one very strong edge outside the
            // observed contour and a weaker return edge just inside it. Even
            // when that second edge is not strong enough to win the search,
            // moving the outer edge would move hair instead of the cheek.
            // Rows with a nearby competing edge cannot anchor the wide pass.
            let outward = { (column: Int) in
                isLeftSide ? column <= center - 4 : column >= center + 4
            }
            return outward(strongest.column) && competing.contains(where: { outward($0.column) })
                ? .ambiguous : .unavailable
        }
        guard isLeftSide ? strongest.column <= center + 8 : strongest.column >= center - 8 else {
            return .unavailable
        }
        // Either background can be lighter. The calling run admits only one
        // coherent contrast direction across its lower-cheek rows.
        let before = (row * width + strongest.column - 4) * 4
        let after = (row * width + strongest.column + 1) * 4
        let beforeLight = (0..<4).reduce(0) { sum, offset in
            sum + Int(source[before + offset * 4]) + Int(source[before + offset * 4 + 1]) +
                Int(source[before + offset * 4 + 2])
        }
        let afterLight = (0..<4).reduce(0) { sum, offset in
            sum + Int(source[after + offset * 4]) + Int(source[after + offset * 4 + 1]) +
                Int(source[after + offset * 4 + 2])
        }
        guard beforeLight != afterLight else { return .unavailable }
        return .found(Float(strongest.column) + 0.5, afterLight > beforeLight ? 1 : -1)
    }

    /// A single high-contrast edge near the observed contour reveals which
    /// pixel column owns that edge. Ambiguous or textured rows retain the
    /// existing bounded fractional alignment.
    private static func strongBoundaryShift(
        _ source: [UInt8],
        width: Int,
        row: Int,
        center: Int,
        continuousCenter: Float,
        isLeftSide: Bool
    ) -> Float? {
        let lower = max(0, center - 2)
        let upper = min(width - 2, center + 1)
        guard lower <= upper else { return nil }
        var largest = 0
        var second = 0
        var edgeColumn = lower
        for column in lower...upper {
            let first = (row * width + column) * 4
            let next = first + 4
            guard source[first + 3] == 255, source[next + 3] == 255 else { return nil }
            let contrast = (0..<3).reduce(0) {
                $0 + abs(Int(source[first + $1]) - Int(source[next + $1]))
            } / 3
            if contrast > largest {
                second = largest
                largest = contrast
                edgeColumn = column
            } else if contrast > second {
                second = contrast
            }
        }
        guard largest >= 64, second * 2 < largest else { return nil }
        let measuredCrossing = Float(edgeColumn) + 0.5
        let desiredCrossing = continuousCenter + (isLeftSide ? -0.5 : 0.5)
        let shift = desiredCrossing - measuredCrossing
        guard shift.isFinite, abs(shift) <= 1.5 else { return nil }
        return shift
    }
}
