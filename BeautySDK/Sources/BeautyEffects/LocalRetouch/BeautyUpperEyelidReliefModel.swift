import BeautyCore
import BeautyDetection
import Foundation

/// Source-derived relief model used by the provisional owner-local `去脂`
/// route. Its bounded safety mechanics are retained.
package struct BeautyExperimentalUpperEyelidReliefModel: Sendable {
    package struct Sample: Equatable, Sendable {
        package let pixelIndex: Int
        package let lowFrequencyLuminance: Double
        package let referenceLuminance: Double

        package var convexityResidual: Double {
            lowFrequencyLuminance - referenceLuminance
        }
    }

    package static let minimumConvexityScore = 3.5
    package static let minimumLocalizedConvexityScore = 8.0
    package static let minimumLocalizedPositiveFraction = 0.35
    package static let maximumAnalysisRadius = 24
    package static let boundaryAnchorMaximumWeightQ16: UInt32 = 32_768
    package static let centralMinimumWeightQ16: UInt32 = 57_344

    package let samples: [Sample]
    package let centralConvexityScore: Double
    package let localizedConvexityScore: Double
    package let localizedPositiveFraction: Double

    package var isFullnessSupported: Bool {
        guard centralConvexityScore.isFinite else { return false }
        if centralConvexityScore >= Self.minimumConvexityScore { return true }
        return centralConvexityScore >= 0
            && localizedConvexityScore.isFinite
            && localizedConvexityScore >= Self.minimumLocalizedConvexityScore
            && localizedPositiveFraction >= Self.minimumLocalizedPositiveFraction
    }

    package static func analyze(
        source: BeautyCanonicalStillImage,
        pixels: [BeautyUpperEyelidSupportPixel]
    ) -> BeautyExperimentalUpperEyelidReliefModel? {
        guard let layout = ReliefSourceLayout(source),
              !pixels.isEmpty,
              Set(pixels.map(\.pixelIndex)).count == pixels.count,
              pixels.allSatisfy({
                  (0..<layout.pixelCount).contains($0.pixelIndex)
                      && $0.softWeightQ16 > 0
                      && $0.softWeightQ16 <= 65_536
              }),
              let patch = ReliefPatch(layout: layout, pixels: pixels)
        else {
            return nil
        }

        let radius = max(
            2,
            min(
                maximumAnalysisRadius,
                max(2, min(patch.width, patch.height) / 5)
            )
        )
        let lowFrequency = pixels.map { pixel in
            patch.lowFrequencyLuminance(
                pixelIndex: pixel.pixelIndex,
                radius: radius
            )
        }
        guard lowFrequency.allSatisfy(\.isFinite),
              let plane = illuminationPlane(
                pixels: pixels,
                lowFrequency: lowFrequency,
                patch: patch
              )
        else {
            return nil
        }

        var samples: [Sample] = []
        samples.reserveCapacity(pixels.count)
        var centralWeightedResidual = 0.0
        var centralWeight = 0.0
        var centralResiduals: [Double] = []
        for (pixel, luminance) in zip(pixels, lowFrequency) {
            let point = patch.normalizedPoint(pixelIndex: pixel.pixelIndex)
            let reference = plane.evaluate(x: point.x, y: point.y)
            let sample = Sample(
                pixelIndex: pixel.pixelIndex,
                lowFrequencyLuminance: luminance,
                referenceLuminance: reference
            )
            samples.append(sample)
            if pixel.softWeightQ16 >= centralMinimumWeightQ16 {
                let weight = Double(pixel.softWeightQ16)
                centralWeightedResidual += sample.convexityResidual * weight
                centralWeight += weight
                centralResiduals.append(sample.convexityResidual)
            }
        }
        guard centralWeight > 0, !centralResiduals.isEmpty else { return nil }
        centralResiduals.sort()
        let positiveCount = centralResiduals.reduce(0) {
            $0 + ($1 >= minimumConvexityScore ? 1 : 0)
        }
        return BeautyExperimentalUpperEyelidReliefModel(
            samples: samples,
            centralConvexityScore: centralWeightedResidual / centralWeight,
            localizedConvexityScore: centralResiduals[centralResiduals.count * 3 / 4],
            localizedPositiveFraction: Double(positiveCount) / Double(centralResiduals.count)
        )
    }

    private static func illuminationPlane(
        pixels: [BeautyUpperEyelidSupportPixel],
        lowFrequency: [Double],
        patch: ReliefPatch
    ) -> ReliefPlane? {
        var anchors: [(x: Double, y: Double, luminance: Double, weight: Double)] = []
        anchors.reserveCapacity(pixels.count)
        for (pixel, luminance) in zip(pixels, lowFrequency)
        where pixel.softWeightQ16 <= boundaryAnchorMaximumWeightQ16 {
            let point = patch.normalizedPoint(pixelIndex: pixel.pixelIndex)
            anchors.append((
                x: point.x,
                y: point.y,
                luminance: luminance,
                weight: Double(65_537 - pixel.softWeightQ16)
            ))
        }
        guard anchors.count >= 6 else { return nil }

        var normal = Array(repeating: Array(repeating: 0.0, count: 3), count: 3)
        var rhs = Array(repeating: 0.0, count: 3)
        for anchor in anchors {
            let vector = [1.0, anchor.x, anchor.y]
            for row in 0..<3 {
                rhs[row] += anchor.weight * vector[row] * anchor.luminance
                for column in 0..<3 {
                    normal[row][column] += anchor.weight * vector[row] * vector[column]
                }
            }
        }
        guard let coefficients = solve3x3(normal, rhs) else { return nil }
        return ReliefPlane(
            intercept: coefficients[0],
            horizontalSlope: coefficients[1],
            verticalSlope: coefficients[2]
        )
    }

    private static func solve3x3(
        _ matrix: [[Double]],
        _ vector: [Double]
    ) -> [Double]? {
        guard matrix.count == 3,
              matrix.allSatisfy({ $0.count == 3 }),
              vector.count == 3
        else {
            return nil
        }
        var augmented = zip(matrix, vector).map { row, value in row + [value] }
        for pivot in 0..<3 {
            var pivotRow = pivot
            for candidate in (pivot + 1)..<3
            where abs(augmented[candidate][pivot]) > abs(augmented[pivotRow][pivot]) {
                pivotRow = candidate
            }
            guard abs(augmented[pivotRow][pivot]) > 1e-9 else { return nil }
            if pivotRow != pivot {
                augmented.swapAt(pivotRow, pivot)
            }
            let divisor = augmented[pivot][pivot]
            for column in pivot..<4 {
                augmented[pivot][column] /= divisor
            }
            for row in 0..<3 where row != pivot {
                let factor = augmented[row][pivot]
                for column in pivot..<4 {
                    augmented[row][column] -= factor * augmented[pivot][column]
                }
            }
        }
        let solution = augmented.map { $0[3] }
        return solution.allSatisfy(\.isFinite) ? solution : nil
    }
}

private struct ReliefPlane: Sendable {
    let intercept: Double
    let horizontalSlope: Double
    let verticalSlope: Double

    func evaluate(x: Double, y: Double) -> Double {
        intercept + horizontalSlope * x + verticalSlope * y
    }
}

package struct BeautyExperimentalUpperEyelidReliefSourceLayout: Sendable {
    package let bytes: Data
    package let width: Int
    package let height: Int
    package let rowBytes: Int
    package let pixelCount: Int

    package init?(_ source: BeautyCanonicalStillImage) {
        let (expectedRowBytes, rowOverflow) = source.width.multipliedReportingOverflow(by: 4)
        let (expectedByteCount, byteOverflow) = source.rowBytes.multipliedReportingOverflow(by: source.height)
        guard source.width > 0,
              source.height > 0,
              !rowOverflow,
              !byteOverflow,
              source.rowBytes == expectedRowBytes,
              source.byteCount == expectedByteCount,
              source.rgba8Data.count == source.byteCount
        else {
            return nil
        }
        let (pixelCount, overflow) = source.width.multipliedReportingOverflow(by: source.height)
        guard !overflow, pixelCount > 0 else { return nil }
        self.bytes = source.rgba8Data
        self.width = source.width
        self.height = source.height
        self.rowBytes = source.rowBytes
        self.pixelCount = pixelCount
    }

    package func sample(
        pixelIndex: Int
    ) -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8)? {
        guard (0..<pixelCount).contains(pixelIndex) else { return nil }
        let offset = pixelIndex * 4
        guard offset >= 0, offset + 3 < bytes.count else { return nil }
        return (bytes[offset], bytes[offset + 1], bytes[offset + 2], bytes[offset + 3])
    }

    package func luminance(pixelIndex: Int) -> Int? {
        guard let sample = sample(pixelIndex: pixelIndex) else { return nil }
        return (54 * Int(sample.red) + 183 * Int(sample.green) + 19 * Int(sample.blue) + 128) >> 8
    }
}

private typealias ReliefSourceLayout = BeautyExperimentalUpperEyelidReliefSourceLayout

private struct ReliefPatch: Sendable {
    let minimumX: Int
    let minimumY: Int
    let width: Int
    let height: Int
    let sourceWidth: Int
    let luminanceIntegral: [Int64]
    let countIntegral: [Int64]

    init?(
        layout: ReliefSourceLayout,
        pixels: [BeautyUpperEyelidSupportPixel]
    ) {
        let columns = pixels.map { $0.pixelIndex % layout.width }
        let rows = pixels.map { $0.pixelIndex / layout.width }
        guard let minimumX = columns.min(),
              let maximumX = columns.max(),
              let minimumY = rows.min(),
              let maximumY = rows.max()
        else {
            return nil
        }
        let width = maximumX - minimumX + 1
        let height = maximumY - minimumY + 1
        guard width >= 3, height >= 2 else { return nil }
        let stride = width + 1
        let integralCount = stride * (height + 1)
        var luminance = Array(repeating: Int64(0), count: width * height)
        var counts = Array(repeating: Int64(0), count: width * height)
        for pixel in pixels {
            let x = pixel.pixelIndex % layout.width - minimumX
            let y = pixel.pixelIndex / layout.width - minimumY
            guard let value = layout.luminance(pixelIndex: pixel.pixelIndex) else { return nil }
            luminance[y * width + x] = Int64(value)
            counts[y * width + x] = 1
        }
        var luminanceIntegral = Array(repeating: Int64(0), count: integralCount)
        var countIntegral = Array(repeating: Int64(0), count: integralCount)
        for y in 0..<height {
            var rowLuminance: Int64 = 0
            var rowCount: Int64 = 0
            for x in 0..<width {
                rowLuminance += luminance[y * width + x]
                rowCount += counts[y * width + x]
                let destination = (y + 1) * stride + x + 1
                luminanceIntegral[destination] = luminanceIntegral[destination - stride] + rowLuminance
                countIntegral[destination] = countIntegral[destination - stride] + rowCount
            }
        }
        self.minimumX = minimumX
        self.minimumY = minimumY
        self.width = width
        self.height = height
        self.sourceWidth = layout.width
        self.luminanceIntegral = luminanceIntegral
        self.countIntegral = countIntegral
    }

    func lowFrequencyLuminance(pixelIndex: Int, radius: Int) -> Double {
        let x = pixelIndex % sourceWidth - minimumX
        let y = pixelIndex / sourceWidth - minimumY
        let minimumColumn = max(0, x - radius)
        let maximumColumn = min(width - 1, x + radius)
        let minimumRow = max(0, y - radius)
        let maximumRow = min(height - 1, y + radius)
        let luminance = rectangleSum(
            luminanceIntegral,
            minimumColumn: minimumColumn,
            maximumColumn: maximumColumn,
            minimumRow: minimumRow,
            maximumRow: maximumRow
        )
        let count = rectangleSum(
            countIntegral,
            minimumColumn: minimumColumn,
            maximumColumn: maximumColumn,
            minimumRow: minimumRow,
            maximumRow: maximumRow
        )
        guard count > 0 else { return .nan }
        return Double(luminance) / Double(count)
    }

    func normalizedPoint(pixelIndex: Int) -> (x: Double, y: Double) {
        let x = pixelIndex % sourceWidth - minimumX
        let y = pixelIndex / sourceWidth - minimumY
        return (
            x: width > 1 ? (Double(x) / Double(width - 1)) * 2 - 1 : 0,
            y: height > 1 ? (Double(y) / Double(height - 1)) * 2 - 1 : 0
        )
    }

    private func rectangleSum(
        _ integral: [Int64],
        minimumColumn: Int,
        maximumColumn: Int,
        minimumRow: Int,
        maximumRow: Int
    ) -> Int64 {
        let stride = width + 1
        let x0 = minimumColumn
        let x1 = maximumColumn + 1
        let y0 = minimumRow
        let y1 = maximumRow + 1
        return integral[y1 * stride + x1]
            - integral[y0 * stride + x1]
            - integral[y1 * stride + x0]
            + integral[y0 * stride + x0]
    }
}

/// Conservative semantic adapter for the provisional owner-local route.
/// It authorizes only source-derived convex relief inside the existing
/// per-eye brow-to-lid envelope and otherwise fails closed.
package enum BeautyExperimentalUpperEyelidFullnessSemanticAnalyzer {
    package static func makeOwner(
        source: BeautyCanonicalStillImage
    ) -> BeautyUpperEyelidSemanticSupportOwner.SemanticOwner {
        { requests in
            requests.map { request in
                let pixels = request.maximumFeatheredPixels()
                guard source.width == request.imageWidth,
                      source.height == request.imageHeight,
                      let model = BeautyExperimentalUpperEyelidReliefModel.analyze(
                        source: source,
                        pixels: pixels
                      ),
                      model.isFullnessSupported
                else {
                    return BeautyUpperEyelidSemanticApproval(
                        side: request.side,
                        approved: false,
                        confidence: 0,
                        reason: .semanticApprovalRejected,
                        pixels: [],
                        hardEnvelope: request.permittedEnvelope
                    )
                }
                let confidence = min(
                    1,
                    max(
                        BeautyUpperEyelidSemanticSupportOwner.minimumConfidence,
                        model.centralConvexityScore
                            / (BeautyExperimentalUpperEyelidReliefModel.minimumConvexityScore * 2)
                    )
                )
                return BeautyUpperEyelidSemanticApproval(
                    side: request.side,
                    approved: true,
                    confidence: confidence,
                    reason: .approved,
                    pixels: pixels,
                    hardEnvelope: request.permittedEnvelope
                )
            }
        }
    }
}
