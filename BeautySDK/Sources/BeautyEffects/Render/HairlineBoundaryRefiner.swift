import Foundation
import BeautyDetection

/// Conservative source-pixel hair/skin boundary shift for still images.
/// A coherent dark cap above lighter forehead skin is required; ambiguous
/// inputs remain exact. The bytes and detected rows are request-local.
enum HairlineBoundaryRefiner {
    static func combinedStrength(hairline: Float, forehead: Float) -> Float {
        let value = hairline - forehead * BeautySafetyCaps.hairlineHeight /
            BeautySafetyCaps.foreheadHeight
        return min(BeautySafetyCaps.hairlineHeight,
                   max(-BeautySafetyCaps.hairlineHeight, value))
    }

    private struct Boundary {
        let left: Int
        let right: Int
        let rows: [Int]
        let high: Int
    }

    static func hasCoherentHairCap(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry
    ) -> Bool {
        detectBoundary(source, width: width, height: height, face: face) != nil
    }

    static func apply(
        _ source: [UInt8], width: Int, height: Int,
        face: FaceGeometry, strength: Float
    ) -> [UInt8] {
        guard strength.isFinite, abs(strength) > Float.ulpOfOne,
              abs(strength) <= BeautySafetyCaps.hairlineHeight,
              let detected = detectBoundary(
                  source, width: width, height: height, face: face
              )
        else { return source }

        let bounds = face.bounds
        let left = detected.left
        let right = detected.right
        let boundary = detected.rows
        let high = detected.high
        let shift = bounds.height * Float(height) * 0.018 *
            strength / BeautySafetyCaps.hairlineHeight
        let radius = max(6, min(11, Int(bounds.height * Float(height) * 0.032)))
        let lowerReach = high + Int(ceil(max(0, shift))) + radius
        if let brows = face.observedEyebrowSupport {
            let samples = (brows.left?.points ?? []) + (brows.right?.points ?? [])
            guard !samples.isEmpty,
                  samples.allSatisfy({ point in
                      point.x.isFinite && point.y.isFinite &&
                          (0...1).contains(point.x) && (0...1).contains(point.y)
                  }),
                  let browTop = samples.map({ Int($0.y * Float(height)) }).min(),
                  lowerReach < browTop - 2
            else { return source }
        }

        var output = source
        let taper = min(20, (right - left) / 4)
        for x in left...right {
            let xWeight = min(1, Float(x - left) / Float(taper),
                              Float(right - x) / Float(taper))
            guard xWeight > 0 else { continue }
            let edge = boundary[x - left]
            for y in max(1, edge - radius)..<min(height - 1, edge + radius + 1) {
                let distance = abs(y - edge)
                let yWeight: Float = distance <= radius / 2 ? 1 :
                    max(0, Float(radius - distance) / Float(radius - radius / 2))
                let sampleY = Float(y) - shift * xWeight * yWeight
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

    private static func detectBoundary(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry
    ) -> Boundary? {
        let pixels = width.multipliedReportingOverflow(by: height)
        let bytes = pixels.partialValue.multipliedReportingOverflow(by: 4)
        guard width >= 128, height >= 128,
              !pixels.overflow, !bytes.overflow,
              source.count == bytes.partialValue,
              face.bounds.minX.isFinite, face.bounds.minY.isFinite,
              face.bounds.maxX.isFinite, face.bounds.maxY.isFinite,
              (0...1).contains(face.bounds.minX),
              (0...1).contains(face.bounds.minY),
              (0...1).contains(face.bounds.maxX),
              (0...1).contains(face.bounds.maxY),
              face.bounds.width > 0, face.bounds.height > 0,
              !face.faceContour.isEmpty,
              face.faceContour.allSatisfy({ point in
                  point.x.isFinite && point.y.isFinite &&
                      (0...1).contains(point.x) && (0...1).contains(point.y)
              })
        else { return nil }

        let bounds = face.bounds
        let left = max(12, Int((bounds.midX - bounds.width * 0.25) * Float(width)))
        let right = min(width - 13, Int((bounds.midX + bounds.width * 0.25) * Float(width)))
        // A dark background-to-face edge at the crown is not a hairline.
        let firstRow = max(16, Int((bounds.minY + bounds.height * 0.02) * Float(height)))
        let lastRow = min(height - 17, Int((bounds.minY + bounds.height * 0.35) * Float(height)))
        guard right - left >= 40, lastRow - firstRow >= 20 else { return nil }

        var boundary = [Int]()
        boundary.reserveCapacity(right - left + 1)
        for x in left...right {
            guard let row = hairToSkinRow(
                source, width: width, x: x, from: firstRow, through: lastRow
            ) else { return nil }
            boundary.append(row)
        }
        guard let low = boundary.min(), let high = boundary.max(),
              high - low <= max(3, Int(bounds.height * Float(height) * 0.05))
        else { return nil }
        return Boundary(left: left, right: right, rows: boundary, high: high)
    }

    private static func hairToSkinRow(
        _ bytes: [UInt8], width: Int, x: Int, from first: Int, through last: Int
    ) -> Int? {
        for y in first...last {
            let before = red(bytes, width: width, x: x, y: y - 1)
            let after = red(bytes, width: width, x: x, y: y)
            guard after - before >= 35 else { continue }
            let darkRun = (y - 10)..<y
            let lightRun = y..<(y + 6)
            guard darkRun.allSatisfy({ red(bytes, width: width, x: x, y: $0) <= before + 16 }),
                  lightRun.allSatisfy({ red(bytes, width: width, x: x, y: $0) >= after - 16 }),
                  (y - 10..<(y + 6)).allSatisfy({
                      bytes[($0 * width + x) * 4 + 3] == 255
                  })
            else { continue }
            return y
        }
        return nil
    }

    private static func red(_ bytes: [UInt8], width: Int, x: Int, y: Int) -> Int {
        Int(bytes[(y * width + x) * 4])
    }
}
