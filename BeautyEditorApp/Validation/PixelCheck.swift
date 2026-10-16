import BeautySDK
import CoreImage
import CryptoKit
import Foundation
import ImageIO

enum CheckFailure: Error { case invalid, check(String) }

@main struct BeautyEditorPixelCheck {
    private static let pixelContext = CIContext(options: [.cacheIntermediates: false])
    static func main() async {
        var stage = "input"
        var diagnostics: [String: Any] = [:]
        do {
            guard (2...3).contains(CommandLine.arguments.count) else { throw CheckFailure.invalid }
            let data = try ImageInput.readBoundedFile(URL(fileURLWithPath: CommandLine.arguments[1]))
            let renderer = PhotoRenderer()
            let source = try await renderer.load(data)
            if CommandLine.arguments.last == "--verify-controls" {
                try await verifyControls(renderer, source: source, data: data)
                return
            }
            if CommandLine.arguments.last == "--audit" {
                try await audit(renderer, source: source, data: data)
                return
            }
            let neutral = try await renderer.render(source, snapshot: EditorSnapshot(), fullResolution: false)
            let sourcePixels = pixels(source.preview)
            stage = "neutral_identity"
            guard pixels(neutral.image) == sourcePixels else { throw CheckFailure.invalid }

            var shape = EditorSnapshot()
            shape.parameters.faceSlim = 0.8
            let one = try await renderer.render(source, snapshot: shape, fullResolution: false)
            let two = try await renderer.render(source, snapshot: shape, fullResolution: false)
            let edited = pixels(one.image)
            let changed = changes(sourcePixels, edited)
            stage = "face_geometry"
            diagnostics = ["availability": one.detection?.availability.rawValue ?? "absent",
                           "reasons": one.detection?.reasons.map(\.rawValue) ?? [],
                           "used_faces": one.detection?.usedFaceCount ?? 0,
                           "changed_pixels": changed, "repeat": edited == pixels(two.image)]
            guard (one.detection?.usedFaceCount ?? 0) > 0, changed > 0,
                  edited == pixels(two.image), alphaEqual(sourcePixels, edited) else { throw CheckFailure.invalid }

            var tone = EditorSnapshot()
            tone.parameters.brightness = 0.2
            let unprotected = try await renderer.render(source, snapshot: tone, fullResolution: false)
            tone.protectBackground = true
            let protected = try await renderer.render(source, snapshot: tone, fullResolution: false)
            let protectedPixels = pixels(protected.image)
            let unprotectedPixels = pixels(unprotected.image)
            let originalAtCorner = cornerChanges(sourcePixels, protectedPixels,
                                                  width: protected.image.width, height: protected.image.height)
            let changedAtCorner = cornerChanges(sourcePixels, unprotectedPixels,
                                                 width: unprotected.image.width, height: unprotected.image.height)
            stage = "background_protection"
            diagnostics = ["protected_corner_changes": originalAtCorner,
                           "unprotected_corner_changes": changedAtCorner,
                           "foreground_changes": changes(sourcePixels, protectedPixels)]
            guard originalAtCorner == 0, changedAtCorner > 0,
                  changes(sourcePixels, protectedPixels) > 0,
                  alphaEqual(sourcePixels, protectedPixels) else { throw CheckFailure.invalid }

            let originalSize = try await renderer.render(source, snapshot: shape, fullResolution: true)
            let png = try await renderer.encodePNG(originalSize.image)
            stage = "export"
            diagnostics = [:]
            guard let encoded = CGImageSourceCreateWithData(png as CFData, nil),
                  let decoded = CGImageSourceCreateImageAtIndex(encoded, 0, nil),
                  decoded.width == Int(source.uprightSize.width),
                  decoded.height == Int(source.uprightSize.height),
                  decoded.colorSpace?.name == CGColorSpace.sRGB,
                  pixels(decoded) == pixels(originalSize.image)
            else { throw CheckFailure.invalid }
            let properties = CGImageSourceCopyPropertiesAtIndex(encoded, 0, nil) as! [CFString: Any]
            guard properties[kCGImagePropertyGPSDictionary] == nil else { throw CheckFailure.invalid }

            let receipt: [String: Any] = [
                "status": "passed", "source_sha256": SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined(),
                "preview_width": source.preview.width, "preview_height": source.preview.height,
                "export_width": decoded.width, "export_height": decoded.height,
                "used_faces": one.detection?.usedFaceCount ?? 0,
                "shape_changed_pixels": changed, "neutral_identity": true,
                "shape_repeat": true, "alpha_preserved": true,
                "background_region_changed_pixels": originalAtCorner,
                "unprotected_background_region_changed_pixels": changedAtCorner,
                "protected_foreground_changed_pixels": changes(sourcePixels, protectedPixels),
                "lossless_png_round_trip": true, "source_gps_absent": true,
                "environment": "macOS host using production PhotoRenderer; iOS UI validation is separate"
            ]
            let receiptData = try JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys, .prettyPrinted])
            print(String(decoding: receiptData, as: UTF8.self))
        } catch {
            if case let CheckFailure.check(reason) = error { diagnostics["check"] = reason }
            // No source path, source metadata, coordinates or image content in durable output.
            let receipt: [String: Any] = ["status": "failed", "stage": stage, "diagnostics": diagnostics]
            if let data = try? JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys]) {
                print(String(decoding: data, as: UTF8.self))
            }
            exit(1)
        }
    }
    static func verifyControls(_ renderer: PhotoRenderer, source: ImportedPhoto, data: Data) async throws {
        let original = pixels(source.preview)
        let neutral = try await renderer.render(source, snapshot: EditorSnapshot(), fullResolution: false)
        guard pixels(neutral.image) == original else { throw CheckFailure.check("neutral_identity") }
        let sourcePoints = try await renderer.landmarks(source.preview)
        guard !sourcePoints.isEmpty else { throw CheckFailure.check("source_landmarks") }
        let cpu = PhotoRenderer(preferredBackend: .cpu)
        let cpuSource = try await cpu.load(data)
        var noseChecks: [[String: Any]] = []
        for tool in ToolCatalog.tools(in: .nose) {
            var previous = original
            var final = neutral
            var distinct = 0
            for value: Float in [25, 50, 75, 100] {
                var edit = EditorSnapshot()
                tool.setValue(value, in: &edit.parameters)
                let result = try await renderer.render(source, snapshot: edit, fullResolution: false)
                let next = pixels(result.image)
                guard next != previous, alphaEqual(original, next),
                      result.detection?.usedFaceCount == 1,
                      !result.warningCodes.contains("nose_inputs_missing"),
                      !result.warningCodes.contains("beauty_strength_capped") else { throw CheckFailure.check("nose_step_\(tool.id)_\(Int(value))") }
                previous = next; final = result; distinct += 1
            }
            var full = EditorSnapshot()
            tool.setValue(100, in: &full.parameters)
            let repeatResult = try await renderer.render(source, snapshot: full, fullResolution: false)
            let cpuResult = try await cpu.render(cpuSource, snapshot: full, fullResolution: false)
            let reference = pixels(cpuResult.image)
            guard previous == pixels(repeatResult.image), reference.count == previous.count else { throw CheckFailure.invalid }
            let maxDifference = zip(previous, reference).map { abs(Int($0) - Int($1)) }.max() ?? 0
            guard maxDifference <= 1 else { throw CheckFailure.check("cpu_parity_\(tool.id)_max_\(maxDifference)") }
            noseChecks.append(["tool": tool.id, "distinct_nonzero_steps": distinct,
                               "changed_pixels": changes(original, previous),
                               "repeat_exact": true, "cpu_max_byte_difference": maxDifference,
                               "backend": final.backendName])
        }
        var combined = EditorSnapshot()
        for id in ["face.width", "eye.innerCorner", "nose.ala", "nose.root", "mouth.width"] {
            let tool = ToolCatalog.find(id)!
            let previous = combined.parameters
            tool.setValue(71, in: &combined.parameters)
            for other in ToolCatalog.canonicalTools where other.field != tool.field {
                guard other.sdkValue(in: previous) == other.sdkValue(in: combined.parameters) else { throw CheckFailure.invalid }
            }
            let output = try await renderer.render(source, snapshot: combined, fullResolution: false)
            let dense = output.metrics["beauty.effects.denseMapCombination"] == 1
            guard abs(tool.value(in: combined.parameters) - 71) < 0.0001,
                  !dense || !output.warningCodes.contains("combined_geometry_weakened") else {
                throw CheckFailure.check("combined_dense_admission")
            }
            // The macOS helper keeps legacy SDK composition; its attenuation
            // warning is valid even though requested host fields stay independent.
        }
        let edited = try await renderer.render(source, snapshot: combined, fullResolution: false)
        let points = try await renderer.landmarks(edited.image)
        guard !points.isEmpty, changes(original, pixels(edited.image)) > 0 else { throw CheckFailure.check("output_landmarks") }
        let afterDebug = try await renderer.render(source, snapshot: combined, fullResolution: false)
        guard pixels(afterDebug.image) == pixels(edited.image) else { throw CheckFailure.invalid }
        let originalSize = try await renderer.render(source, snapshot: combined, fullResolution: true)
        let png = try await renderer.encodePNG(originalSize.image)
        guard let encoded = CGImageSourceCreateWithData(png as CFData, nil),
              let decoded = CGImageSourceCreateImageAtIndex(encoded, 0, nil),
              decoded.width == Int(source.uprightSize.width), decoded.height == Int(source.uprightSize.height),
              decoded.colorSpace?.name == CGColorSpace.sRGB,
              pixels(decoded) == pixels(originalSize.image), alphaEqual(pixels(decoded), pixels(originalSize.image))
        else { throw CheckFailure.invalid }
        let properties = CGImageSourceCopyPropertiesAtIndex(encoded, 0, nil) as! [CFString: Any]
        guard properties[kCGImagePropertyGPSDictionary] == nil else { throw CheckFailure.invalid }
        var alphaBytes = [UInt8](repeating: 0, count: 64 * 96 * 4)
        for y in 24..<72 { for x in 12..<52 {
            let i = (y * 64 + x) * 4
            alphaBytes[i] = 70; alphaBytes[i + 1] = 45; alphaBytes[i + 2] = 25; alphaBytes[i + 3] = 128
        } }
        let provider = CGDataProvider(data: Data(alphaBytes) as CFData)!
        let alphaImage = CGImage(width: 64, height: 96, bitsPerComponent: 8, bitsPerPixel: 32,
            bytesPerRow: 256, space: CGColorSpace(name: CGColorSpace.displayP3)!,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
        let alphaData = try await renderer.encodePNG(alphaImage)
        let alphaSource = try await renderer.load(alphaData)
        let alphaCPU = try await cpu.load(alphaData)
        var tone = EditorSnapshot(); tone.parameters.brightness = 0.2
        let fallback = try await renderer.render(alphaSource, snapshot: tone, fullResolution: false)
        let reference = try await cpu.render(alphaCPU, snapshot: tone, fullResolution: false)
        guard fallback.backendName == "CPU fallback",
              pixels(fallback.image) == pixels(reference.image),
              alphaEqual(pixels(alphaSource.preview), pixels(fallback.image)) else { throw CheckFailure.check("alpha_cpu_fallback") }
        let receipt: [String: Any] = ["status": "passed", "source_sha256": SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined(),
            "nose_checks": noseChecks, "alpha_cpu_fallback_exact": true, "previous_scalars_preserved": true, "combined_strength_not_weakened": true,
            "source_landmark_count": sourcePoints.reduce(0) { $0 + $1.points.count },
            "output_landmark_count": points.reduce(0) { $0 + $1.points.count }, "debug_pixel_inert": true,
            "preview_width": source.preview.width, "preview_height": source.preview.height,
            "export_width": decoded.width, "export_height": decoded.height,
            "neutral_identity": true, "lossless_png_round_trip": true, "source_gps_absent": true,
            "scope": "macOS production host binding/range/composition/debug/export checks; not effect qualification or device performance"]
        let json = try JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys, .prettyPrinted])
        print(String(decoding: json, as: UTF8.self))
    }
    static func audit(_ renderer: PhotoRenderer, source: ImportedPhoto, data: Data) async throws {
        let original = pixels(source.preview)
        var rows: [[String: Any]] = []
        var snapshot = EditorSnapshot()
        // Each independent binding and then the reported cross-category sequence.
        for tool in ToolCatalog.all where tool.available {
            snapshot = EditorSnapshot()
            tool.setValue(100, in: &snapshot.parameters)
            let start = ContinuousClock.now
            let result = try await renderer.render(source, snapshot: snapshot, fullResolution: false)
            let elapsed = start.duration(to: .now)
            rows.append(["tool": tool.id, "field": tool.field!,
                         "changed_pixels": changes(original, pixels(result.image)),
                         "warning_codes": result.warningCodes,
                         "metrics": result.metrics,
                         "milliseconds": Double(elapsed.components.seconds) * 1000 + Double(elapsed.components.attoseconds) / 1e15,
                         "faces": result.detection?.usedFaceCount ?? 0])
        }
        snapshot = EditorSnapshot()
        for id in ["face.width", "eye.innerCorner", "nose.ala", "nose.root", "mouth.width"] {
            ToolCatalog.find(id)!.setValue(71, in: &snapshot.parameters)
            let result = try await renderer.render(source, snapshot: snapshot, fullResolution: false)
            rows.append(["sequence_added": id, "requested_slider": 71, "requested_geometry_total": ToolCatalog.geometryTotal(in: snapshot.parameters), "changed_pixels": changes(original, pixels(result.image)),
                         "warning_codes": result.warningCodes, "metrics": result.metrics])
        }
        let receipt: [String: Any] = ["source_sha256": SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined(),
                                     "width": source.preview.width, "height": source.preview.height, "rows": rows,
                                     "scope": "host binding diagnostic; changed pixel counts do not qualify effects"]
        let json = try JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys, .prettyPrinted])
        print(String(decoding: json, as: UTF8.self))
    }
    static func pixels(_ image: CGImage) -> Data {
        let context = pixelContext
        var data = Data(count: image.width * image.height * 4)
        data.withUnsafeMutableBytes { buffer in
            context.render(CIImage(cgImage: image), toBitmap: buffer.baseAddress!, rowBytes: image.width * 4,
                           bounds: CGRect(x: 0, y: 0, width: image.width, height: image.height),
                           format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
        }
        return data
    }
    static func changes(_ a: Data, _ b: Data) -> Int {
        guard a.count == b.count else { return -1 }
        var changed = 0
        for index in stride(from: 0, to: a.count, by: 4) {
            if a[index] != b[index] || a[index + 1] != b[index + 1] || a[index + 2] != b[index + 2] { changed += 1 }
        }
        return changed
    }
    static func alphaEqual(_ a: Data, _ b: Data) -> Bool {
        guard a.count == b.count else { return false }
        return stride(from: 3, to: a.count, by: 4).allSatisfy { a[$0] == b[$0] }
    }
    // This authorized portrait's side margins in the central half are background.
    // Its lower corners contain the person's shirt and must remain editable.
    static func cornerChanges(_ a: Data, _ b: Data, width: Int, height: Int) -> Int {
        var count = 0
        for y in (height / 4)..<(height * 3 / 4) {
            for x in [0, 1, width - 2, width - 1] {
                let i = (y * width + x) * 4
                if a[i] != b[i] || a[i + 1] != b[i + 1] || a[i + 2] != b[i + 2] { count += 1 }
            }
        }
        return count
    }
}
