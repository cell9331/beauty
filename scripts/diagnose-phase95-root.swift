import Foundation
import CoreImage
import CoreGraphics
import Vision
import CryptoKit

// Read-only source diagnostic, not an acceptance evaluator. Never emit media,
// paths, coordinates, landmark arrays, or spatial pixel profiles.
enum DiagnosticError: Error { case admission }
func main() throws {
    let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let registration = try JSONSerialization.jsonObject(with: Data(contentsOf:
        root.appendingPathComponent(".planning/phases/95-compatibility-and-sdk-only-closeout/95-ROI-REGISTRATION.json"))) as? [String: Any]
    guard let expected = registration?["source_sha256"] as? String,
          let entries = FileManager.default.enumerator(at: root.appendingPathComponent("example-images/input/portraits"),
            includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey]) else { throw DiagnosticError.admission }
    var matches: [URL] = []
    for case let url as URL in entries {
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
        guard values.isSymbolicLink != true else { throw DiagnosticError.admission }
        if values.isRegularFile == true,
           ["jpg", "jpeg", "png", "heic", "tif", "tiff"].contains(url.pathExtension.lowercased()) {
            let data = try Data(contentsOf: url)
            guard data.count <= 64 * 1024 * 1024 else { throw DiagnosticError.admission }
            if SHA256.hash(data: data).map({ String(format: "%02x", $0) }).joined() == expected { matches.append(url) }
        }
    }
    guard matches.count == 1, let image = CIImage(contentsOf: matches[0], options: [.applyOrientationProperty: true]),
          let color = CGColorSpace(name: CGColorSpace.sRGB) else { throw DiagnosticError.admission }
    let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
    guard let cg = context.createCGImage(image, from: image.extent),
          cg.width <= 8192, cg.height <= 8192 else { throw DiagnosticError.admission }
    let request = VNDetectFaceLandmarksRequest()
    try VNImageRequestHandler(cgImage: cg, orientation: .up).perform([request])
    guard request.results?.count == 1, let face = request.results?.first,
          let landmarks = face.landmarks else { throw DiagnosticError.admission }
    let b = face.boundingBox, w = b.width
    func points(_ r: VNFaceLandmarkRegion2D?) throws -> [CGPoint] {
        guard let r, r.pointCount >= 3 else { throw DiagnosticError.admission }
        return r.normalizedPoints.map { CGPoint(x: b.minX + CGFloat($0.x) * w, y: 1 - b.minY - CGFloat($0.y) * b.height) }
    }
    func box(_ ps: [CGPoint]) -> CGRect {
        let xs = ps.map(\.x), ys = ps.map(\.y)
        return CGRect(x: xs.min()!, y: ys.min()!, width: xs.max()! - xs.min()!, height: ys.max()! - ys.min()!)
    }
    let eyes = try [points(landmarks.leftEye), points(landmarks.rightEye)].map(box).sorted { $0.midX < $1.midX }
    let crest = try points(landmarks.noseCrest).sorted { $0.y < $1.y }
    let center = crest.map(\.x).reduce(0, +) / CGFloat(crest.count)
    let upper = min(eyes.map(\.minY).min()!, crest[0].y) - w * 0.035
    let lower = (crest[0].y + crest[crest.count / 2].y) / 2
    let roi = CGRect(x: center - w * 0.14, y: upper, width: w * 0.28, height: lower - upper)
    let width = cg.width, height = cg.height
    var bytes = [UInt8](repeating: 0, count: width * height * 4)
    let drawn = bytes.withUnsafeMutableBytes { raw -> Bool in
        guard let bitmap = CGContext(data: raw.baseAddress, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4, space: color,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
        bitmap.interpolationQuality = .none
        bitmap.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
        return true
    }
    guard drawn else { throw DiagnosticError.admission }
    var direct = [UInt8](repeating: 0, count: bytes.count)
    context.render(image, toBitmap: &direct, rowBytes: width * 4, bounds: image.extent,
                   format: .RGBA8, colorSpace: color)
    var directRGB: Int64 = 0, reflectedRGB: Int64 = 0
    for y in 0..<height { for x in 0..<width { for c in 0..<3 {
        let i = (y * width + x) * 4 + c
        directRGB += Int64(abs(Int(bytes[i]) - Int(direct[i])))
        reflectedRGB += Int64(abs(Int(bytes[i]) - Int(direct[((height - 1 - y) * width + x) * 4 + c])))
    } } }
    func minimum(_ n: CGFloat, _ extent: Int) -> Int { Int(floor(n * 1e6)) * extent / 1_000_000 }
    func maximum(_ n: CGFloat, _ extent: Int) -> Int { Int(ceil(n * 1e6)) * extent / 1_000_000 }
    var count = 0, eyeCount = 0, betweenCount = 0
    var darkness: Int64 = 0, eyeDarkness: Int64 = 0, betweenDarkness: Int64 = 0
    var betweenGradient: Int64 = 0, outerQuarterGradient: Int64 = 0
    func lumaAt(_ x: Int, _ y: Int) -> Int {
        let i = (y * width + x) * 4
        return 77 * Int(bytes[i]) + 150 * Int(bytes[i+1]) + 29 * Int(bytes[i+2])
    }
    for y in minimum(roi.minY, height)..<maximum(roi.maxY, height) {
        for x in minimum(roi.minX, width)..<maximum(roi.maxX, width) {
            let p = CGPoint(x: (CGFloat(x) + 0.5) / CGFloat(width), y: (CGFloat(y) + 0.5) / CGFloat(height))
            let i = (y * width + x) * 4
            let luma = 77 * Int(bytes[i]) + 150 * Int(bytes[i+1]) + 29 * Int(bytes[i+2])
            let d = Int64(65_280 - luma)
            count += 1; darkness += d
            if eyes.contains(where: { $0.contains(p) }) { eyeCount += 1; eyeDarkness += d }
            if p.x > eyes[0].maxX && p.x < eyes[1].minX {
                betweenCount += 1; betweenDarkness += d
                let gradient = Int64(abs(lumaAt(min(width - 1, x + 1), y) - lumaAt(max(0, x - 1), y)))
                betweenGradient += gradient
                let room = p.x < center ? center - eyes[0].maxX : eyes[1].minX - center
                if abs(p.x - center) > room * 0.75 { outerQuarterGradient += gradient }
            }
        }
    }
    guard darkness > 0 else { throw DiagnosticError.admission }
    // A deliberately optimistic, source-only upper bound: each eligible pixel
    // may independently choose any horizontal sample within the physical cap.
    // This relaxes smoothness, monotonicity and inward direction, so it is NOT
    // an implementation, candidate, acceptance result, or suggested transform.
    let minX = minimum(roi.minX, width), maxX = maximum(roi.maxX, width), splitX = (minX + maxX) / 2
    let capPixels = Int(ceil(w * 0.04 * CGFloat(width))) + 1
    let room = min(center - eyes[0].maxX, eyes[1].minX - center)
    var ranges = [[(x: Double, low: Double, high: Double, original: Double)]](repeating: [], count: 2)
    for y in minimum(roi.minY, height)..<maximum(roi.maxY, height) { for x in minX..<maxX {
        let px = (CGFloat(x) + 0.5) / CGFloat(width)
        let original = 65_280 - lumaAt(x, y)
        var low = original, high = original
        if abs(px - center) < room {
            for sx in max(0, x - capPixels)...min(width - 1, x + capPixels) {
                let candidate = 65_280 - lumaAt(sx, y)
                low = min(low, candidate); high = max(high, candidate)
            }
        }
        ranges[x < splitX ? 0 : 1].append((Double(x * 2 + 1), Double(low), Double(high), Double(original)))
    } }
    func extreme(_ values: [(x: Double, low: Double, high: Double, original: Double)], maximize: Bool) -> Double {
        var lo = values.map(\.x).min()!, hi = values.map(\.x).max()!
        for _ in 0..<50 {
            let midpoint = (lo + hi) / 2
            let residual = values.reduce(0.0) { sum, v in
                let weight = (v.x > midpoint) == maximize ? v.high : v.low
                return sum + (v.x - midpoint) * weight
            }
            if residual > 0 { lo = midpoint } else { hi = midpoint }
        }
        return (lo + hi) / 2
    }
    let baseline = ranges.map { values in values.reduce(0.0) { $0 + $1.x * $1.original } / values.reduce(0.0) { $0 + $1.original } }
    let bestGap = extreme(ranges[1], maximize: false) - extreme(ranges[0], maximize: true)
    let upperMargin = Int(ceil(((baseline[1] - baseline[0]) - bestGap) * 65_536 / Double(width * 2))) + 2
    var result: [String: Any] = ["status": "source_diagnostic_only", "root_pixels": count,
        "eye_overlap_pixels": eyeCount, "between_canthi_pixels": betweenCount,
        "eye_darkness_fraction_bp": eyeDarkness * 10_000 / darkness,
        "between_canthi_darkness_fraction_bp": betweenDarkness * 10_000 / darkness,
        "ci_vs_cg_direct_rgb": directRGB, "ci_vs_cg_reflected_rgb": reflectedRGB,
        "outer_quarter_between_canthi_gradient_bp": outerQuarterGradient * 10_000 / max(1, betweenGradient),
        "relaxed_horizontal_margin_upper_bound_q16": upperMargin,
        "source_sha256": expected]
    if CommandLine.arguments.count == 3, CommandLine.arguments[1] == "--output-directory" {
        // A temporary single-case render is diagnostic only: it cannot grant
        // sibling distinctness, repeated-attempt or full-gate credit.
        let directory = URL(fileURLWithPath: CommandLine.arguments[2])
        let files = try FileManager.default.contentsOfDirectory(at: directory,
            includingPropertiesForKeys: [.isSymbolicLinkKey]).filter { $0.lastPathComponent.hasSuffix("__noseRootNarrowing_0p25.png") }
        guard files.count == 1, try files[0].resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink != true,
              let rendered = CIImage(contentsOf: files[0]), rendered.extent == image.extent else { throw DiagnosticError.admission }
        var output = [UInt8](repeating: 0, count: bytes.count)
        context.render(rendered, toBitmap: &output, rowBytes: width * 4, bounds: image.extent, format: .RGBA8, colorSpace: color)
        func span(_ pixels: [UInt8]) -> Int64 {
            let lo = minimum(roi.minX, width), hi = maximum(roi.maxX, width), split = (lo + hi) / 2
            var weights = [Int64](repeating: 0, count: 2), sums = weights
            for y in minimum(roi.minY, height)..<maximum(roi.maxY, height) { for x in lo..<hi {
                let i = (y * width + x) * 4
                let luma = 77 * Int(pixels[i]) + 150 * Int(pixels[i+1]) + 29 * Int(pixels[i+2])
                let d = Int64(65_280 - luma), side = x < split ? 0 : 1
                weights[side] += d; sums[side] += Int64(x * 2 + 1) * d
            } }
            return sums[1] * 65_536 / (weights[1] * Int64(width * 2)) - sums[0] * 65_536 / (weights[0] * Int64(width * 2))
        }
        result["status"] = "single_case_diagnostic_only"
        result["root_source_margin_q16"] = span(bytes) - span(output)
    } else if CommandLine.arguments.count != 1 { throw DiagnosticError.admission }
    print(String(decoding: try JSONSerialization.data(withJSONObject: result, options: [.sortedKeys]), as: UTF8.self))
}
do { try main() } catch { print("root_diagnostic_admission_failed"); exit(2) }
