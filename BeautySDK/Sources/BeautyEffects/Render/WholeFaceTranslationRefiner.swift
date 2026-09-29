import Foundation
import BeautyDetection

/// Moves one isolated, coherent portrait silhouette over a uniform backdrop.
/// Source qualification is deliberately strict: an ambiguous background,
/// detached foreground object, or clipped silhouette leaves the image exact.
enum WholeFaceTranslationRefiner {
    static func apply(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry,
        xStrength: Float, yStrength: Float
    ) -> [UInt8] {
        let pixels = width.multipliedReportingOverflow(by: height)
        let byteCount = pixels.partialValue.multipliedReportingOverflow(by: 4)
        guard width >= 128, height >= 128,
              !pixels.overflow, !byteCount.overflow,
              source.count == byteCount.partialValue,
              xStrength.isFinite, yStrength.isFinite,
              abs(xStrength) <= BeautySafetyCaps.wholeFaceXPosition,
              abs(yStrength) <= BeautySafetyCaps.wholeFaceYPosition,
              xStrength != 0 || yStrength != 0,
              face.bounds.minX.isFinite, face.bounds.minY.isFinite,
              face.bounds.maxX.isFinite, face.bounds.maxY.isFinite,
              (0...1).contains(face.bounds.minX),
              (0...1).contains(face.bounds.minY),
              (0...1).contains(face.bounds.maxX),
              (0...1).contains(face.bounds.maxY),
              face.bounds.width > 0, face.bounds.height > 0,
              !face.faceContour.isEmpty
        else { return source }

        let dx = Int((face.bounds.width * Float(width) * 0.035 * xStrength /
                      BeautySafetyCaps.wholeFaceXPosition).rounded())
        let dy = Int((face.bounds.height * Float(height) * 0.035 * yStrength /
                      BeautySafetyCaps.wholeFaceYPosition).rounded())
        guard dx != 0 || dy != 0 else { return source }
        let background = (source[0], source[1], source[2])
        func isBackground(_ offset: Int) -> Bool {
            source[offset + 3] == 255 &&
                abs(Int(source[offset]) - Int(background.0)) <= 3 &&
                abs(Int(source[offset + 1]) - Int(background.1)) <= 3 &&
                abs(Int(source[offset + 2]) - Int(background.2)) <= 3
        }
        for x in 0..<width {
            guard isBackground(x * 4),
                  isBackground(((height - 1) * width + x) * 4)
            else { return source }
        }
        for y in 0..<height {
            guard isBackground(y * width * 4),
                  isBackground((y * width + width - 1) * 4)
            else { return source }
        }

        var foreground = [Bool](repeating: false, count: pixels.partialValue)
        for index in 0..<pixels.partialValue {
            let offset = index * 4
            guard source[offset + 3] == 255 else { return source }
            let distance = abs(Int(source[offset]) - Int(background.0)) +
                abs(Int(source[offset + 1]) - Int(background.1)) +
                abs(Int(source[offset + 2]) - Int(background.2))
            foreground[index] = distance > 35
        }

        let centerX = Int((face.bounds.midX * Float(width)).rounded())
        let centerY = Int((face.bounds.midY * Float(height)).rounded())
        guard (1..<(width - 1)).contains(centerX),
              (1..<(height - 1)).contains(centerY)
        else { return source }
        let seed = centerY * width + centerX
        guard foreground[seed] else { return source }
        var visited = [Bool](repeating: false, count: pixels.partialValue)
        var queue = [seed]
        visited[seed] = true
        var cursor = 0
        var minX = width, maxX = 0, minY = height, maxY = 0
        while cursor < queue.count {
            let index = queue[cursor]
            cursor += 1
            let x = index % width
            let y = index / width
            minX = min(minX, x); maxX = max(maxX, x)
            minY = min(minY, y); maxY = max(maxY, y)
            for next in [index - 1, index + 1, index - width, index + width] {
                guard next >= 0, next < foreground.count,
                      !visited[next], foreground[next],
                      abs(next % width - x) + abs(next / width - y) == 1
                else { continue }
                visited[next] = true
                queue.append(next)
            }
        }
        guard queue.count >= pixels.partialValue / 20,
              !foreground.indices.contains(where: { foreground[$0] && !visited[$0] }),
              minX + dx > 1, maxX + dx < width - 2,
              minY + dy > 1, maxY + dy < height - 2
        else { return source }

        let xTolerance = max(6, Int(face.bounds.width * Float(width) * 0.09))
        let yTolerance = max(6, Int(face.bounds.height * Float(height) * 0.09))
        guard abs(minX - Int(face.bounds.minX * Float(width))) <= xTolerance,
              abs(maxX - Int(face.bounds.maxX * Float(width))) <= xTolerance,
              abs(minY - Int(face.bounds.minY * Float(height))) <= yTolerance,
              abs(maxY - Int(face.bounds.maxY * Float(height))) <= yTolerance
        else { return source }

        var output = source
        for index in queue {
            let offset = index * 4
            output[offset] = background.0
            output[offset + 1] = background.1
            output[offset + 2] = background.2
        }
        for index in queue {
            let destination = index + dy * width + dx
            let sourceOffset = index * 4
            let targetOffset = destination * 4
            output[targetOffset] = source[sourceOffset]
            output[targetOffset + 1] = source[sourceOffset + 1]
            output[targetOffset + 2] = source[sourceOffset + 2]
        }
        return output
    }
}
