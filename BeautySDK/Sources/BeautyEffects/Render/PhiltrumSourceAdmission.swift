import Foundation
import BeautyDetection

/// Admits a still-image philtrum warp only when a coherent visible upper lip
/// is registered with the observation. Ambiguous color or placement exits
/// without moving otherwise unqualified skin.
enum PhiltrumSourceAdmission {
    static func hasRegisteredUpperLip(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry
    ) -> Bool {
        let pixels = width.multipliedReportingOverflow(by: height)
        let byteCount = pixels.partialValue.multipliedReportingOverflow(by: 4)
        let lips = face.upperLips.isEmpty ? face.outerLips : face.upperLips
        guard width >= 128, height >= 128,
              !pixels.overflow, !byteCount.overflow,
              source.count == byteCount.partialValue,
              let center = LandmarkGeometryHelper.center(of: lips),
              center.x.isFinite, center.y.isFinite,
              (0...1).contains(center.x), (0...1).contains(center.y),
              face.bounds.width.isFinite, face.bounds.height.isFinite,
              face.bounds.width > 0, face.bounds.height > 0
        else { return false }

        let x = Int((center.x * Float(width)).rounded())
        let expected = Int((center.y * Float(height)).rounded())
        let halfSpan = max(12, Int(face.bounds.width * Float(width) * 0.20))
        let requiredRun = max(8, Int(face.bounds.width * Float(width) * 0.13))
        let search = max(8, Int(face.bounds.height * Float(height) * 0.04))
        guard x - halfSpan >= 1, x + halfSpan < width - 1,
              expected - search >= 1, expected + search < height - 1
        else { return false }

        var firstLipRow: Int?
        for row in (expected - search)...(expected + search) {
            var run = 0
            for column in (x - halfSpan)...(x + halfSpan) {
                let offset = (row * width + column) * 4
                let red = Int(source[offset])
                let green = Int(source[offset + 1])
                let blue = Int(source[offset + 2])
                let isLip = source[offset + 3] == 255 &&
                    red >= 110 && red - green >= 40 &&
                    red - blue >= 25 && green <= 120
                run = isLip ? run + 1 : 0
                if run >= requiredRun {
                    firstLipRow = row
                    break
                }
            }
            if firstLipRow != nil { break }
        }
        guard let firstLipRow else { return false }
        let tolerance = max(2, Int(face.bounds.height * Float(height) * 0.013))
        return abs(firstLipRow - expected) <= tolerance
    }
}
