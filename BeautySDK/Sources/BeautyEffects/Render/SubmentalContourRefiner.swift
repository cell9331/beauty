import Foundation
import BeautyDetection

/// Conservative still-image correction of a lower-center skin silhouette
/// protruding below the selected face box. Every sample is source-local.
enum SubmentalContourRefiner {
    static func apply(
        _ source: [UInt8], width: Int, height: Int,
        face: FaceGeometry, baseStrength: Float, proStrength: Float
    ) -> [UInt8] {
        let pixels = width.multipliedReportingOverflow(by: height)
        let bytes = pixels.partialValue.multipliedReportingOverflow(by: 4)
        guard !pixels.overflow, !bytes.overflow,
              source.count == bytes.partialValue,
              width >= 128, height >= 128,
              baseStrength.isFinite, proStrength.isFinite,
              baseStrength >= 0, proStrength >= 0,
              !face.faceContour.isEmpty,
              face.faceContour.allSatisfy({ point in
                  point.x.isFinite && point.y.isFinite &&
                      (0...1).contains(point.x) && (0...1).contains(point.y)
              }),
              face.bounds.minX.isFinite, face.bounds.minY.isFinite,
              face.bounds.maxX.isFinite, face.bounds.maxY.isFinite,
              (0...1).contains(face.bounds.minX),
              (0...1).contains(face.bounds.minY),
              (0...1).contains(face.bounds.maxX),
              (0...1).contains(face.bounds.maxY),
              face.bounds.width > 0, face.bounds.height > 0
        else { return source }
        let baseFraction = min(1, baseStrength / BeautySafetyCaps.doubleChinReduction)
        let proFraction = min(1, proStrength / BeautySafetyCaps.doubleChinReductionPro)
        let request = max(baseFraction, proFraction * 1.55)
        guard request > Float.ulpOfOne else { return source }

        let bounds = face.bounds
        let left = max(12, Int((bounds.midX - bounds.width * 0.15) * Float(width)))
        let right = min(width - 13, Int((bounds.midX + bounds.width * 0.15) * Float(width)))
        let firstRow = max(12, Int((bounds.maxY - bounds.height * 0.08) * Float(height)))
        let lastRow = min(height - 13,
                          Int((bounds.maxY + bounds.height * 0.16) * Float(height)))
        guard right - left >= 35, lastRow - firstRow >= 20 else { return source }

        var boundary = [Int]()
        boundary.reserveCapacity(right - left + 1)
        for x in left...right {
            guard let row = skinToBackgroundRow(
                source, width: width, x: x, from: firstRow, through: lastRow
            ) else { return source }
            boundary.append(row)
        }
        let central = boundary[(boundary.count / 2 - 5)...(boundary.count / 2 + 5)]
        let centerRow = central.sorted()[central.count / 2]
        let minimumBulge = (bounds.maxY + bounds.height * 0.045) * Float(height)
        guard Float(centerRow) >= minimumBulge,
              let low = boundary.min(), let high = boundary.max(),
              high - low <= max(10, Int(bounds.height * Float(height) * 0.045))
        else { return source }

        let shift = min(16, bounds.height * Float(height) * 0.026 * request)
        let radius = max(12, min(24, Int(bounds.height * Float(height) * 0.065)))
        let taper = min(20, (right - left) / 4)
        var output = source
        for x in left...right {
            let xWeight = min(1, Float(x - left) / Float(taper),
                              Float(right - x) / Float(taper))
            guard xWeight > 0 else { continue }
            let edge = boundary[x - left]
            for y in max(1, edge - radius)..<min(height - 1, edge + radius + 1) {
                let distance = abs(y - edge)
                let yWeight: Float = distance <= radius / 2 ? 1 :
                    max(0, Float(radius - distance) / Float(radius - radius / 2))
                let sampleY = Float(y) + shift * xWeight * yWeight
                guard sampleY >= 0, sampleY < Float(height - 1) else { continue }
                let y0 = Int(floor(sampleY))
                let fraction = sampleY - Float(y0)
                let dst = (y * width + x) * 4
                let src0 = (y0 * width + x) * 4
                let src1 = ((y0 + 1) * width + x) * 4
                guard source[dst + 3] == 255,
                      source[src0 + 3] == 255, source[src1 + 3] == 255
                else { continue }
                for channel in 0..<3 {
                    let a = Float(source[src0 + channel])
                    let b = Float(source[src1 + channel])
                    output[dst + channel] = UInt8(min(255, max(0,
                        Int((a + (b - a) * fraction).rounded()))))
                }
            }
        }
        return output
    }

    private static func skinToBackgroundRow(
        _ bytes: [UInt8], width: Int, x: Int, from first: Int, through last: Int
    ) -> Int? {
        var selected: Int?
        for y in first...last {
            let before = red(bytes, width: width, x: x, y: y - 1)
            let after = red(bytes, width: width, x: x, y: y)
            guard before - after >= 35,
                  before >= 70,
                  // A detached light collar below a dark neck gap is not
                  // the continuous outer skin silhouette of the chin.
                  (first..<y).allSatisfy({
                      red(bytes, width: width, x: x, y: $0) >= 70
                  }),
                  (y - 6..<y).allSatisfy({
                      red(bytes, width: width, x: x, y: $0) >= before - 16
                  }),
                  (y..<(y + 8)).allSatisfy({
                      red(bytes, width: width, x: x, y: $0) <= after + 16
                  }),
                  (y - 6..<(y + 8)).allSatisfy({
                      bytes[($0 * width + x) * 4 + 3] == 255
                  })
            else { continue }
            selected = y
        }
        return selected
    }

    private static func red(_ bytes: [UInt8], width: Int, x: Int, y: Int) -> Int {
        Int(bytes[(y * width + x) * 4])
    }
}
