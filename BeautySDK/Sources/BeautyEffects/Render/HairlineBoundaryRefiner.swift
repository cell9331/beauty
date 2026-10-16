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
        var soft: Bool = false
    }

    static func hasCoherentHairCap(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry
    ) -> Bool {
        // Head-wrap keeps its existing hard-edge qualification; admitting a
        // soft forehead boundary does not qualify a whole-head point warp.
        detectBoundary(source, width: width, height: height, face: face).map { !$0.soft } ?? false
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
        let browSamples = (face.observedEyebrowSupport?.left?.points ?? []) +
            (face.observedEyebrowSupport?.right?.points ?? [])
        guard browSamples.allSatisfy({ point in
            point.x.isFinite && point.y.isFinite &&
                (0...1).contains(point.x) && (0...1).contains(point.y)
        }) else { return source }
        let browTop = browSamples.map { Int($0.y * Float(height)) }.min()
        let radius = detected.soft
            ? min(max(20, Int(bounds.height * Float(height) * 0.08)),
                  max(1, Int(Float((browTop ?? height) - high - 3) * 0.7)))
            : max(6, min(11, Int(bounds.height * Float(height) * 0.032)))
        guard !detected.soft || radius >= 20 else { return source }
        // Soft boundaries use a cap-shape bound for a continuously monotone
        // inverse map; increasing the slider never moves the kernel center.
        let admittedShift = detected.soft
            ? min(Float(radius) * 0.25, bounds.height * Float(height) * 0.018) *
                strength / BeautySafetyCaps.hairlineHeight : shift
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
                let yWeight: Float = detected.soft
                    ? pow(max(0, 1 - pow(Float(distance) / Float(radius), 2)), 2)
                    : (distance <= radius / 2 ? 1 :
                       max(0, Float(radius - distance) / Float(radius - radius / 2)))
                let sampleY = Float(y) - admittedShift * xWeight * yWeight
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
            ) else {
                return detectSoftBoundary(source, width: width, height: height, face: face)
            }
            boundary.append(row)
        }
        guard let low = boundary.min(), let high = boundary.max(),
              high - low <= max(3, Int(bounds.height * Float(height) * 0.05))
        else { return detectSoftBoundary(source, width: width, height: height, face: face) }
        return Boundary(left: left, right: right, rows: boundary, high: high)
    }

    /// Distributed hair/skin transitions on an exposed arched forehead. A
    /// bangs-like center dip, sparse decoration, chromatic background, opaque
    /// alpha failure or incompatible brows abstains. This does not synthesize
    /// missing hair/skin or infer a segmented hair mask.
    private static func detectSoftBoundary(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry
    ) -> Boundary? {
        let b = face.bounds
        let left = max(16, Int((b.midX - b.width * 0.25) * Float(width)))
        let right = min(width - 17, Int((b.midX + b.width * 0.25) * Float(width)))
        let brows = (face.observedEyebrowSupport?.left?.points ?? []) +
            (face.observedEyebrowSupport?.right?.points ?? [])
        guard brows.allSatisfy({ point in
            point.x.isFinite && point.y.isFinite &&
                (0...1).contains(point.x) && (0...1).contains(point.y)
        }), let browTop = brows.map({ Int($0.y * Float(height)) }).min(),
              right - left >= 40 else { return nil }
        let first = max(40, Int((b.minY - b.height * 0.28) * Float(height)))
        let last = min(height - 40, browTop - max(30, Int(b.height * Float(height) * 0.10)))
        guard last > first else { return nil }
        var rows = [Int]()
        for x in left...right {
            var found: Int?
            for y in first...last {
                func mean(_ range: Range<Int>, _ channel: Int) -> Double {
                    range.reduce(0.0) { $0 + Double(source[($1 * width + x) * 4 + channel]) } / Double(range.count)
                }
                let dark = mean((y-20)..<(y-5), 0)
                let light = mean((y+5)..<(y+20), 0)
                guard dark < 150, light - dark >= 32,
                      mean((y-36)..<(y-20), 0) < light - 26,
                      light > 90,
                      light - mean((y+5)..<(y+20), 2) >= 10,
                      mean((y+5)..<(y+20), 1) >= mean((y+5)..<(y+20), 2),
                      (y-36..<y+28).allSatisfy({ source[($0*width+x)*4+3] == 255 })
                else { continue }
                let upperBlue = mean((y-20)..<(y-5), 2)
                let upperGreen = mean((y-20)..<(y-5), 1)
                guard upperBlue < dark + 12, upperGreen < dark + 12 else { continue }
                // Select the maximum derivative of the distributed transition,
                // not its first threshold crossing. The source fixes this row.
                let candidates = max(first,y-4)...min(last,y+12)
                found = candidates.max { a,c in
                    mean((a+1)..<(a+5),0)-mean((a-4)..<a,0) <
                        mean((c+1)..<(c+5),0)-mean((c-4)..<c,0)
                }
                break
            }
            guard let found else { return nil }
            rows.append(found)
        }
        guard let low = rows.min(), let high = rows.max(),
              high-low <= Int(b.height * Float(height) * 0.22),
              zip(rows,rows.dropFirst()).allSatisfy({ abs($0-$1) <= 4 }) else { return nil }
        let n=rows.count, margin=max(3,n/8)
        let center=Array(rows[(n/2-margin)...(n/2+margin)])
        let sides=Array(rows.prefix(margin))+Array(rows.suffix(margin))
        let centerMean=Double(center.reduce(0,+))/Double(center.count)
        let sideMean=Double(sides.reduce(0,+))/Double(sides.count)
        guard centerMean <= sideMean + Double(b.height * Float(height) * 0.01),
              high+20 < browTop else { return nil }
        return Boundary(left:left,right:right,rows:rows,high:high,soft:true)
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
