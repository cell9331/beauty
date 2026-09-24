import Foundation
import BeautyDetection

/// Request-local raster alignment of the observed lateral contour. It reads
/// every sample from the immutable input and never retains pixels or support.
enum FaceContourSubpixelRefiner {
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
