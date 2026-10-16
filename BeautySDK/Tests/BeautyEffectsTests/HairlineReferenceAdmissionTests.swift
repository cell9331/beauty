import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import ImageIO
import XCTest
@testable import BeautyEffects

final class HairlineReferenceAdmissionTests: XCTestCase {
    private let size = 512

    private func anatomy() -> FaceGeometry {
        let contour = (0...10).map { i -> SIMD2<Float> in
            let a = Float(i) / 10 * .pi
            return SIMD2(0.5 - 0.3 * cos(a), 0.35 + 0.45 * sin(a))
        }
        let left = BeautyEyebrowSemanticTrace(side: .left,
            points: [SIMD2(0.3, 0.45), SIMD2(0.4, 0.45)], innerEndpoint: SIMD2(0.4, 0.45),
            outerEndpoint: SIMD2(0.3, 0.45), center: SIMD2(0.35, 0.45), apexIndex: 0)
        let right = BeautyEyebrowSemanticTrace(side: .right,
            points: [SIMD2(0.6, 0.45), SIMD2(0.7, 0.45)], innerEndpoint: SIMD2(0.6, 0.45),
            outerEndpoint: SIMD2(0.7, 0.45), center: SIMD2(0.65, 0.45), apexIndex: 0)
        return FaceGeometry(bounds: FaceBounds(x: 0.2, y: 0.15, width: 0.6, height: 0.7),
            faceContour: contour, observedEyebrowSupport: BeautyEyebrowSemanticSupport(left: left, right: right))
    }

    private func boundary(x: Int, bangs: Bool = false) -> Double {
        let u = (Double(x) - 256) / 154
        return 105 + (bangs ? 65 * (1 - u * u) : 70 * u * u)
    }

    /// The true arch is smooth and source-fixed. Sparse warm glints in the cap
    /// supply misleading first crossings; they do not form a second full curve.
    private func pixels(kind: Int = 0) -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: size * size * 4)
        for y in 0..<size { for x in 0..<size {
            let edge = boundary(x: x, bangs: kind == 2)
            let t = min(1, max(0, (Double(y) - edge) / 16)), v = t * t * (3 - 2 * t)
            let hair = [100.0, 65.0, 40.0], skin = [220.0, 170.0, 130.0]
            for c in 0..<3 {
                bytes[(y * size + x) * 4 + c] = UInt8((hair[c] + (skin[c] - hair[c]) * v).rounded())
            }
            if kind == 0 && x % 19 < 3 && Double(y) >= edge - 35 && Double(y) < edge - 13 {
                bytes[(y * size + x) * 4] = 200
                bytes[(y * size + x) * 4 + 1] = 145
                bytes[(y * size + x) * 4 + 2] = 100
            }
            if kind == 1 && (248...252).contains(x) {
                for c in 0..<3 { bytes[(y * size + x) * 4 + c] = UInt8(skin[c]) }
            }
            if kind == 3 { for c in 0..<3 { bytes[(y * size + x) * 4 + c] = UInt8(skin[c]) } }
            if kind == 4 && (248...252).contains(x) && (60...190).contains(y) {
                bytes[(y * size + x) * 4 + 3] = 0
            }
            if kind == 5 {
                // Two equally credible complete transitions, plus sparse
                // earlier warm crossings that break the old first-hit path.
                // A coherent fallback must reject the competing full curve.
                if Double(y) >= edge - 45 && Double(y) < edge - 23 {
                    let q = min(1, max(0, (Double(y) - (edge - 45)) / 16))
                    let blend = q * q * (3 - 2 * q)
                    for c in 0..<3 {
                        bytes[(y * size + x) * 4 + c] = UInt8((hair[c] + (skin[c] - hair[c]) * blend).rounded())
                    }
                }
                if x % 19 < 3 && Double(y) >= edge - 87 && Double(y) < edge - 65 {
                    bytes[(y * size + x) * 4] = 140
                    bytes[(y * size + x) * 4 + 1] = 100
                    bytes[(y * size + x) * 4 + 2] = 70
                }
            }
        } }
        return bytes
    }

    private func edgeMeasure(_ bytes: [UInt8]) -> Double {
        var sum = 0.0, total = 0.0
        for x in 230...282 { for y in 70..<190 {
            let value = max(0, Int(bytes[(y * size + x) * 4]) - Int(bytes[((y - 1) * size + x) * 4]))
            sum += Double(value * y); total += Double(value)
        } }
        return sum / total
    }

    func testWarmCurvedBoundaryWithSparseFalseCrossingsMovesBothDirectionsAndKeepsSourceExteriorExact() {
        let source = pixels(), face = anatomy(), baseline = edgeMeasure(source)
        XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: size, height: size,
            face: face, strength: 0) == source, "neutral source identity")
        XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: size, height: size, face: face),
            "new curved admission cannot authorize head wrap")
        for sign: Float in [-1, 1] {
            var previous = 0.0
            for fraction: Float in [0.25, 0.5, 0.75, 1] {
                let output = HairlineBoundaryRefiner.apply(source, width: size, height: size,
                    face: face, strength: sign * 0.25 * fraction)
                let movement = (edgeMeasure(output) - baseline) * Double(sign)
                XCTAssertGreaterThan(movement, previous + 0.1)
                if fraction == 1 { XCTAssertGreaterThan(movement, 1) }
                previous = movement
                var exterior = 0, alpha = 0
                for y in 0..<size { for x in 0..<size {
                    let i = (y * size + x) * 4
                    if abs(Double(y) - boundary(x: x)) > 24 || y >= 210 {
                        if (0..<4).contains(where: { source[i + $0] != output[i + $0] }) { exterior += 1 }
                    }
                    if output[i + 3] != source[i + 3] { alpha += 1 }
                } }
                XCTAssertEqual(exterior, 0); XCTAssertEqual(alpha, 0)
                XCTAssertTrue(output == HairlineBoundaryRefiner.apply(source, width: size, height: size,
                    face: face, strength: sign * 0.25 * fraction), "determinism")
            }
        }
    }

    func testMissingColumnsBangsHairlessAndTransparentBoundariesRemainSourceExact() {
        for kind in [1, 2, 3, 4] {
            let source = pixels(kind: kind)
            for sign: Float in [-1, 1] {
                XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: size, height: size,
                    face: anatomy(), strength: sign * 0.25) == source, "kind=\(kind)")
                XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: size,
                    height: size, face: anatomy()))
            }
        }
    }

    func testTwoCompleteCompetingCurvesWithSparseEarlierCrossingsRemainSourceExact() {
        let source = pixels(kind: 5)
        for sign: Float in [-1, 1] {
            XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: size, height: size,
                face: anatomy(), strength: sign * 0.25) == source, "competing source curves abstain exactly")
            XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: size,
                height: size, face: anatomy()))
        }
    }

    /// Both rasters describe the same source scene in 512-unit coordinates.
    /// The larger raster crosses the bounded-analysis threshold without
    /// changing any color, curve, protection or displacement criterion.
    private func equivalentPixels(length: Int, kind: Int = 0) -> [UInt8] {
        let scale = Double(length) / Double(size)
        var bytes = [UInt8](repeating: 255, count: length * length * 4)
        for y in 0..<length { for x in 0..<length {
            let sx = (Double(x) + 0.5) / scale - 0.5
            let sy = (Double(y) + 0.5) / scale - 0.5
            let u = (sx - 256) / 154
            let edge = 105 + (kind == 2 ? 65 * (1 - u * u) : 70 * u * u)
            let hair = [100.0, 65.0, 40.0], skin = [220.0, 170.0, 130.0]
            let t = min(1, max(0, (sy - edge) / 16)), v = t * t * (3 - 2 * t)
            let i = (y * length + x) * 4
            for c in 0..<3 { bytes[i + c] = UInt8((hair[c] + (skin[c] - hair[c]) * v).rounded()) }
            let glint = Int(floor(max(0, sx))) % 19 < 3
            if (kind == 0 || kind == 6) && glint && sy >= edge - 35 && sy < edge - 13 {
                bytes[i] = 200; bytes[i + 1] = 145; bytes[i + 2] = 100
            }
            if kind == 1 && (248...252).contains(sx) || kind == 3 {
                for c in 0..<3 { bytes[i + c] = UInt8(skin[c]) }
            }
            if kind == 4 && (248...252).contains(sx) && (60...190).contains(sy) {
                bytes[i + 3] = 0
            }
            if kind == 5 {
                if sy >= edge - 45 && sy < edge - 23 {
                    let q = min(1, max(0, (sy - (edge - 45)) / 16)), blend = q * q * (3 - 2 * q)
                    for c in 0..<3 { bytes[i + c] = UInt8((hair[c] + (skin[c] - hair[c]) * blend).rounded()) }
                }
                if glint && sy >= edge - 87 && sy < edge - 65 {
                    bytes[i] = 140; bytes[i + 1] = 100; bytes[i + 2] = 70
                }
            }
            // At native size this is narrower than one analysis texel. Any
            // nonopaque source contribution must still veto that column.
            if kind == 6 && x == length / 2 && (60...190).contains(sy) { bytes[i + 3] = 254 }
        } }
        return bytes
    }

    private func equivalentEdge(_ bytes: [UInt8], length: Int) -> Double {
        let scale = Double(length) / Double(size)
        var sum = 0.0, total = 0.0
        for x in Int(ceil(230 * scale))...Int(floor(282 * scale)) {
            for y in Int(ceil(70 * scale))..<Int(floor(190 * scale)) {
                let value = max(0, Int(bytes[(y * length + x) * 4]) - Int(bytes[((y - 1) * length + x) * 4]))
                sum += Double(value) * Double(y) / scale; total += Double(value)
            }
        }
        return sum / total
    }

    func testBoundedCoherentCurveHasEquivalentNativeAndPreviewDirectionsAndSourceBandProtection() {
        let face = anatomy()
        var previewMovements = [Double]()
        for length in [512, 1280] {
            let source = equivalentPixels(length: length), baseline = equivalentEdge(source, length: length)
            let scale = Double(length) / Double(size)
            XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: length, height: length,
                face: face, strength: 0) == source, "neutral")
            XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length, height: length, face: face))
            var ordinal = 0
            for sign: Float in [-1, 1] {
                var previous = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    let strength = sign * BeautySafetyCaps.hairlineHeight * fraction
                    let output = HairlineBoundaryRefiner.apply(source, width: length, height: length,
                        face: face, strength: strength)
                    let movement = (equivalentEdge(output, length: length) - baseline) * Double(sign)
                    XCTAssertGreaterThan(movement, previous + 0.1)
                    if fraction == 1 { XCTAssertGreaterThan(movement, 1) }
                    previous = movement
                    if length == 512 { previewMovements.append(movement) }
                    else { XCTAssertEqual(movement, previewMovements[ordinal], accuracy: 0.75,
                        "same physical source and original field bounds") }
                    ordinal += 1
                    var exterior = 0, alpha = 0
                    for y in 0..<length { for x in 0..<length {
                        let sx = (Double(x) + 0.5) / scale - 0.5
                        let sy = (Double(y) + 0.5) / scale - 0.5
                        let u = (sx - 256) / 154, edge = 105 + 70 * u * u
                        let i = (y * length + x) * 4
                        if abs(sy - edge) > 24 || sy >= 210 {
                            if (0..<4).contains(where: { source[i + $0] != output[i + $0] }) { exterior += 1 }
                        }
                        if source[i + 3] != output[i + 3] { alpha += 1 }
                    } }
                    XCTAssertEqual(exterior, 0); XCTAssertEqual(alpha, 0)
                    XCTAssertTrue(output == HairlineBoundaryRefiner.apply(source, width: length,
                        height: length, face: face, strength: strength), "repeat")
                }
            }
        }
    }

    func testBoundedAnalysisRejectsPhysicalMissingEdgesBangsCompetitionAndSubpixelTransparency() {
        for length in [512, 1280] { for kind in [1, 2, 3, 4, 5, 6] {
            let source = equivalentPixels(length: length, kind: kind)
            for sign: Float in [-1, 1] {
                XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: length, height: length,
                    face: anatomy(), strength: sign * BeautySafetyCaps.hairlineHeight) == source,
                    "same physical negative; length=\(length), kind=\(kind)")
                XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length,
                    height: length, face: anatomy()))
            }
        } }
    }

    private func foreheadBranchChallenge(length: Int, orientation: Int) -> ([UInt8], [Bool]) {
        var source = equivalentPixels(length: length)
        var core = [Bool](repeating: false, count: length * length)
        let scale = Double(length) / Double(size)
        for y in 0..<length { for x in 0..<length {
            let sx = (Double(x) + 0.5) / scale - 0.5
            let sy = (Double(y) + 0.5) / scale - 0.5
            let branch: Bool
            if orientation == 3 {
                let u = (sx - 256) / 154
                branch = (230...282).contains(sx) && abs(sy - (128 + 70 * u * u)) < 1
            } else {
                let slope = orientation == 1 ? 0.8 : orientation == 2 ? -0.8 : 0
                branch = (128...176).contains(sy) && abs(sx - (256 + slope * (sy - 128))) < 1
            }
            let i = (y * length + x) * 4
            if branch {
                source[i] = 22; source[i + 1] = 20; source[i + 2] = 18
                core[y * length + x] = true
            }
            if x < length / 10 && y < length / 10 { for c in 0..<4 { source[i + c] = 0 } }
        } }
        return (source, core)
    }

    /// Independent reachability oracle on the unchanged source photometric
    /// predicates. It uses every pixel row, no protected mask, path score or
    /// production proposal. A disconnected graph cannot authorize a curve.
    private func sourcePathProof(_ bytes: [UInt8]) -> (columns: Int, connected: Int, missing: Int, gap: Int) {
        let face = anatomy(), b = face.bounds
        let left = max(16, Int((b.midX - b.width * 0.25) * Float(size)))
        let right = min(size - 17, Int((b.midX + b.width * 0.25) * Float(size)))
        let first = max(40, Int((b.minY - b.height * 0.28) * Float(size)))
        let browPoints = (face.observedEyebrowSupport?.left?.points ?? []) +
            (face.observedEyebrowSupport?.right?.points ?? [])
        let browTop = browPoints.map { Int($0.y * Float(size)) }.min() ?? size
        let last = min(size - 40, browTop - max(30, Int(b.height * Float(size) * 0.10)))
        var columns = [[Int]](), missing = 0
        for x in left...right {
            var prefix = [[Int]](repeating: [Int](repeating: 0, count: size + 1), count: 3)
            var nonopaque = [Int](repeating: 0, count: size + 1)
            for y in 0..<size {
                let i = (y * size + x) * 4
                for c in 0..<3 { prefix[c][y + 1] = prefix[c][y] + Int(bytes[i + c]) }
                nonopaque[y + 1] = nonopaque[y] + (bytes[i + 3] == 255 ? 0 : 1)
            }
            func mean(_ a: Int, _ z: Int, _ c: Int) -> Double {
                Double(prefix[c][z] - prefix[c][a]) / Double(z - a)
            }
            func gradient(_ y: Int) -> Double { mean(y + 1, y + 5, 0) - mean(y - 4, y, 0) }
            var candidates = [Int]()
            for y in first...last {
                let dark = mean(y - 20, y - 5, 0), light = mean(y + 5, y + 20, 0)
                guard dark < 150, light - dark >= 32, mean(y - 36, y - 20, 0) < light - 26,
                      light > 90, light - mean(y + 5, y + 20, 2) >= 10,
                      mean(y + 5, y + 20, 1) >= mean(y + 5, y + 20, 2),
                      nonopaque[y + 28] == nonopaque[y - 36],
                      mean(y - 20, y - 5, 2) < dark + 12,
                      mean(y - 20, y - 5, 1) < dark + 12 else { continue }
                let g = gradient(y)
                let peak = ((y - 2)...(y + 2)).map(gradient).max() ?? 0
                if g >= max(1, (light - dark) * 0.05), g >= peak * 0.75 { candidates.append(y) }
            }
            if candidates.isEmpty { missing += 1 }
            columns.append(candidates)
        }
        var reachable = [Int](), connected = 0, gap = 0
        for (i, candidates) in columns.enumerated() {
            let next = i == 0 ? candidates : candidates.filter { y in reachable.contains { abs($0 - y) <= 4 } }
            if next.isEmpty {
                if !reachable.isEmpty, !candidates.isEmpty {
                    gap = candidates.flatMap { y in reachable.map { abs($0 - y) } }.min() ?? 0
                }
                break
            }
            reachable = next; connected = i + 1
        }
        return (columns.count, connected, missing, gap)
    }

    func testTwoPixelAndObliqueForeheadBranchesKeepExactCoreWhileCoherentEdgeMoves() {
        for length in [512, 1280] { for orientation in 0..<4 {
            let (source, core) = foreheadBranchChallenge(length: length, orientation: orientation)
            let baseline = equivalentEdge(source, length: length), face = anatomy()
            let scale = Double(length) / Double(size)
            XCTAssertTrue(core.contains(true), "challenge must contain a source branch")
            let qualification = HairlineBoundaryRefiner.coherentSourceQualificationCounts(
                source, width: length, height: length, face: face)
            let counts = qualification.keys.sorted().map { "\($0)=\(qualification[$0] ?? 0)" }.joined(separator: ",")
            if orientation == 3 { print("generated-hairline-qualification:size=\(length),orientation=\(orientation);\(counts)") }
            let unsafeHorizontal = length == size && orientation == 3
            if unsafeHorizontal {
                let proof = sourcePathProof(source)
                XCTAssertEqual(proof.missing, 0)
                XCTAssertLessThan(proof.connected, proof.columns)
                XCTAssertGreaterThan(proof.gap, 4)
                print("source-only-horizontal-path-proof:columns=\(proof.columns),connected=\(proof.connected),missing=\(proof.missing),minimumGap=\(proof.gap)")
            }
            for sign: Float in [-1, 1] {
                let strength = sign * BeautySafetyCaps.hairlineHeight
                let output = HairlineBoundaryRefiner.apply(source, width: length, height: length, face: face, strength: strength)
                if unsafeHorizontal {
                    // The immutable 512 carrier's unprotected source graph
                    // has a >4-row break. Keep the historical positive failure
                    // receipt; this carrier must now fail closed exactly.
                    XCTAssertTrue(output == source, "source-qualified graph is disconnected")
                } else {
                    XCTAssertGreaterThan((equivalentEdge(output, length: length) - baseline) * Double(sign), 1,
                        "qualified source edge must act; size=\(length), orientation=\(orientation), sign=\(sign);\(counts)")
                }
                var changedCore = 0, exterior = 0, alpha = 0
                for y in 0..<length { for x in 0..<length {
                    let i = (y * length + x) * 4
                    let changed = (0..<4).contains { source[i + $0] != output[i + $0] }
                    if changed && core[y * length + x] { changedCore += 1 }
                    let sx = (Double(x) + 0.5) / scale - 0.5
                    let sy = (Double(y) + 0.5) / scale - 0.5
                    let u = (sx - 256) / 154
                    if changed && (abs(sy - (105 + 70 * u * u)) > 24 || sy >= 210) { exterior += 1 }
                    if source[i + 3] != output[i + 3] { alpha += 1 }
                } }
                XCTAssertEqual(changedCore, 0); XCTAssertEqual(exterior, 0); XCTAssertEqual(alpha, 0)
                XCTAssertTrue(output == HairlineBoundaryRefiner.apply(source, width: length, height: length,
                    face: face, strength: strength), "repeat")
                XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length,
                    height: length, face: face), "a protected soft edge still cannot authorize head wrap")
            }
        } }
    }

    func testBranchProtectionCannotCreateWorkFromAmbiguousOrNonopaqueSource() {
        for length in [512, 1280] {
            let scale = Double(length) / Double(size)
            var transparent = foreheadBranchChallenge(length: length, orientation: 1).0
            for y in Int(ceil(100 * scale))..<Int(floor(125 * scale)) {
                transparent[(y * length + length / 2) * 4 + 3] = 254
            }
            for source in [transparent, equivalentPixels(length: length, kind: 3), equivalentPixels(length: length, kind: 5)] {
                for sign: Float in [-1, 1] {
                    XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: length, height: length,
                        face: anatomy(), strength: sign * BeautySafetyCaps.hairlineHeight) == source,
                        "new branch protection cannot infer a missing or competing boundary")
                }
            }
        }
    }

    /// Diagnostic only: both native and preview source layers use production
    /// detection and the real adapter. No source geometry or pixels are logged.
    func testProductionSourceSoftGateDiagnostics() throws {
        guard let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_INPUT"] else {
            let source = pixels(), face = anatomy(), baseline = edgeMeasure(source)
            for sign: Float in [-1, 1] {
                let output = HairlineBoundaryRefiner.apply(source, width: size, height: size,
                    face: face, strength: sign * BeautySafetyCaps.hairlineHeight)
                XCTAssertGreaterThan((edgeMeasure(output) - baseline) * Double(sign), 1,
                    "generated source qualification must meaningfully act")
                XCTAssertTrue((210..<size).allSatisfy { y in
                    let first = y * size * 4, last = first + size * 4
                    return output[first..<last] == source[first..<last]
                }, "source-fixed brow/core protection")
                let hairless = pixels(kind: 3)
                XCTAssertTrue(HairlineBoundaryRefiner.apply(hairless, width: size, height: size,
                    face: face, strength: sign * BeautySafetyCaps.hairlineHeight) == hairless,
                    "source qualification cannot invent hair")
            }
            XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: size,
                height: size, face: face), "soft source cannot authorize head wrap")
            return
        }
        let url = URL(fileURLWithPath: path).standardizedFileURL
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
        guard values.isRegularFile == true, values.isSymbolicLink != true,
              let size = values.fileSize, size > 0, size <= BeautyConfiguration.defaultMaximumInputByteCount,
              let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true])
        else { XCTFail("invalid local input"); return }
        let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
        guard image.extent.width.isFinite, image.extent.height.isFinite,
              image.extent.width >= 2, image.extent.height >= 2,
              image.extent.width * image.extent.height <= CGFloat(BeautyConfiguration.defaultMaximumInputPixelCount)
        else { XCTFail("invalid source extent"); return }
        let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        let normalized = image.transformed(by: CGAffineTransform(
            translationX: -image.extent.minX, y: -image.extent.minY))
        func raster(_ image: CIImage, width: Int, height: Int) -> ([UInt8], CIImage) {
            let extent = CGRect(x: 0, y: 0, width: Double(width), height: Double(height))
            var bytes = [UInt8](repeating: 0, count: width * height * 4)
            context.render(image, toBitmap: &bytes, rowBytes: width * 4, bounds: extent,
                format: .RGBA8, colorSpace: colorSpace)
            let canonical = CIImage(bitmapData: Data(bytes), bytesPerRow: width * 4,
                size: extent.size, format: .RGBA8, colorSpace: colorSpace)
            return (bytes, canonical)
        }
        let fullWidth = Int(image.extent.width), fullHeight = Int(image.extent.height)
        let (fullBytes, fullImage) = raster(normalized, width: fullWidth, height: fullHeight)
        let scale = min(1, 960 / Double(max(fullWidth, fullHeight)))
        let width = Int(floor(Double(fullWidth) * scale)), height = Int(floor(Double(fullHeight) * scale))
        let (previewBytes, previewImage) = raster(fullImage.transformed(by: CGAffineTransform(
            scaleX: scale, y: scale)), width: width, height: height)
        for (label, bytes, canonical, width, height) in [
            ("full", fullBytes, fullImage, fullWidth, fullHeight),
            ("preview960", previewBytes, previewImage, width, height)
        ] {
            var detector = BeautyFaceDetector.production()
            let detected = detector.detect(image: canonical, metadata: metadata,
                imageExtent: canonical.extent.size, purpose: .geometryAndLocalSupport)
            XCTAssertEqual(detected.summary.availability, .usable)
            XCTAssertEqual(detected.observations.count, 1)
            let observation = try XCTUnwrap(detected.observations.first)
            let face = BeautyFaceGeometryAdapter.makeGeometry(from: observation)
            let frozenBand = try frozenSourceHairlineBand(width: width, height: height, context: context, colorSpace: colorSpace)
            let sourceOnlySupport = HairlineBoundaryRefiner.sourceBandPlanningAggregates(
                bytes, width: width, height: height, face: face, frozenSourceBand: frozenBand)
            var aggregate = try sourceGateAggregate(bytes, width: width, height: height,
                face: face, observation: observation, layer: label)
            aggregate["sourceOnlyFrozenBandPlanning"] = sourceOnlySupport
            let audit = try sourceCandidateAudit(bytes, width: width, height: height, face: face,
                frozenBand: frozenBand, overlayLabel: label)
            aggregate["sourceOnlyFrozenBandCandidateRejections"] = audit.counts
            let data = try JSONSerialization.data(withJSONObject: aggregate, options: [.sortedKeys])
            print(String(decoding: data, as: UTF8.self))
        }
    }

    private func frozenSourceHairlineBand(
        width: Int, height: Int, context: CIContext, colorSpace: CGColorSpace
    ) throws -> [Bool] {
        let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let path = ProcessInfo.processInfo.environment["BEAUTY_FACE_REFERENCE_HAIRLINE_TARGET"]
            ?? package.appendingPathComponent(".build/face-reference/protection-masks/legal_hairline_band.png").path
        let invalid = NSError(domain: "HairlineSourceBandDiagnostic", code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Invalid frozen source-only hairline annotation"])
        let url = URL(fileURLWithPath: path).standardizedFileURL
        guard let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey]),
              values.isRegularFile == true, values.isSymbolicLink != true,
              let size = values.fileSize, size > 0, size <= BeautyConfiguration.defaultMaximumInputByteCount,
              let data = try? Data(contentsOf: url),
              SHA256.hash(data: data).map({ String(format: "%02x", $0) }).joined() ==
                "30a906016807a686f1f2a5f626051cc27d3c56fc95b4c693dfc1be27821e7443",
              let image = CIImage(data: data, options: [.applyOrientationProperty: false]),
              image.extent.origin == .zero, image.extent.width.isFinite, image.extent.height.isFinite,
              image.extent.width >= 2, image.extent.height >= 2,
              image.extent.width * image.extent.height <= CGFloat(BeautyConfiguration.defaultMaximumInputPixelCount),
              abs(Double(image.extent.width / image.extent.height) - Double(width) / Double(height)) < 0.002
        else { throw invalid }
        let w = Int(image.extent.width), h = Int(image.extent.height)
        var bytes = [UInt8](repeating: 0, count: w * h * 4)
        context.render(image, toBitmap: &bytes, rowBytes: w * 4, bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else { throw invalid }
        return (0..<(width * height)).map { p in
            let x = p % width, y = p / width
            let sx = min(w - 1, Int((Double(x) + 0.5) * Double(w) / Double(width)))
            let sy = min(h - 1, Int((Double(y) + 0.5) * Double(h) / Double(height)))
            return bytes[(sy * w + sx) * 4] >= 128
        }
    }

    func testSourceBandPlanningDiagnosticCountsUseOnlyPredeclaredSourceMask() {
        let source = pixels(), face = anatomy()
        var band = [Bool](repeating: false, count: size * size)
        for y in 0..<size { for x in 0..<size {
            band[y * size + x] = abs(Double(y) - boundary(x: x)) <= 36
        } }
        let counts = HairlineBoundaryRefiner.sourceBandPlanningAggregates(source,
            width: size, height: size, face: face, frozenSourceBand: band)
        XCTAssertEqual(counts["sourceCurveFound"] ?? 0, 1)
        XCTAssertGreaterThan(counts["sourceCurveColumnCount"] ?? 0, 40)
        XCTAssertEqual(counts["sourceCurveInsideFrozenBandFraction"] ?? 0, 1)
        XCTAssertEqual(counts["sourcePlanningSupportOutsideFrozenBandPixels"] ?? -1, 0)
        let empty = HairlineBoundaryRefiner.sourceBandPlanningAggregates(source,
            width: size, height: size, face: face,
            frozenSourceBand: [Bool](repeating: false, count: size * size))
        XCTAssertEqual(empty["sourceCurveInsideFrozenBandFraction"] ?? -1, 0)
        XCTAssertEqual(empty["sourcePlanningSupportOutsideFrozenBandPixels"], empty["sourcePlanningSupportPixelCount"])
    }

    /// Golden hair supplies an earlier warm transition in a central source
    /// strip. It is never labelled as skin to production. A second complete
    /// curve is intentionally absent; the old competition oracle stays exact.
    private func goldenSource(length: Int, onlyFalseEdge: Bool = false) -> [UInt8] {
        var source = equivalentPixels(length: length)
        let scale = Double(length) / Double(size)
        for y in 0..<length { for x in 0..<length {
            let sx = (Double(x) + 0.5) / scale - 0.5
            let sy = (Double(y) + 0.5) / scale - 0.5
            let u = (sx - 256) / 154, edge = 105 + 70 * u * u
            let i = (y * length + x) * 4
            if onlyFalseEdge, sy < 200 {
                let t = min(1, max(0, (sy - edge) / 16)), v = t * t * (3 - 2 * t)
                let hair = [100.0, 65.0, 40.0], gold = [215.0, 170.0, 72.0]
                for c in 0..<3 { source[i + c] = UInt8((hair[c] + (gold[c] - hair[c]) * v).rounded()) }
                if Int(floor(max(0, sx))) % 19 < 3 && sy >= edge - 35 && sy < edge - 13 {
                    source[i] = 200; source[i + 1] = 145; source[i + 2] = 100
                }
            } else if !onlyFalseEdge, abs(sx - 256) < 65, sy >= edge - 50, sy < edge - 24 {
                let t = min(1, max(0, (sy - (edge - 50)) / 16)), v = t * t * (3 - 2 * t)
                let hair = [100.0, 65.0, 40.0], gold = [215.0, 170.0, 72.0]
                for c in 0..<3 { source[i + c] = UInt8((hair[c] + (gold[c] - hair[c]) * v).rounded()) }
            }
        } }
        return source
    }

    func testFaceSkinPrototypeRejectsGoldenFalseCrossingWhileTrueConnectedCurveMoves() {
        for length in [512, 1280] {
            let source = goldenSource(length: length), face = anatomy()
            let scale = Double(length) / Double(size)
            let baseline = equivalentEdge(source, length: length)
            let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
                width: length, height: length, face: face)
            XCTAssertEqual(counts["faceSkinPrototype"], 1)
            XCTAssertGreaterThan(counts["faceSkinFamilyRejectedCandidates"] ?? 0, 0)
            XCTAssertEqual(counts["admittedCurve"], 1)
            XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length, height: length, face: face))
            for sign: Float in [-1, 1] {
                let output = HairlineBoundaryRefiner.apply(source, width: length, height: length,
                    face: face, strength: sign * BeautySafetyCaps.hairlineHeight)
                XCTAssertGreaterThan((equivalentEdge(output, length: length) - baseline) * Double(sign), 1)
                var changedFalseCrossing = 0, changedExterior = 0
                for y in 0..<length { for x in 0..<length {
                    let sx = (Double(x) + 0.5) / scale - 0.5
                    let sy = (Double(y) + 0.5) / scale - 0.5
                    let u = (sx - 256) / 154, edge = 105 + 70 * u * u
                    let i = (y * length + x) * 4
                    let changed = (0..<4).contains { source[i + $0] != output[i + $0] }
                    if changed && abs(sx - 256) < 65 && sy >= edge - 50 && sy < edge - 24 { changedFalseCrossing += 1 }
                    if changed && (abs(sy - edge) > 24 || sy >= 210) { changedExterior += 1 }
                } }
                XCTAssertEqual(changedFalseCrossing, 0); XCTAssertEqual(changedExterior, 0)
                XCTAssertTrue(output == HairlineBoundaryRefiner.apply(source, width: length,
                    height: length, face: face, strength: sign * BeautySafetyCaps.hairlineHeight))
            }
        }
    }

    func testGoldenOnlyFalseEdgeAndDisconnectedSkinDoNotAuthorizeCoherentWork() {
        for length in [512, 1280] {
            let scale = Double(length) / Double(size), face = anatomy()
            var disconnected = equivalentPixels(length: length)
            for y in 0..<length { for x in 0..<length {
                let sy = (Double(y) + 0.5) / scale - 0.5
                if sy >= 180 && sy < 210 {
                    let t = min(1, max(0, (sy - 194) / 16)), v = t * t * (3 - 2 * t)
                    let hair = [100.0, 65.0, 40.0], skin = [220.0, 170.0, 130.0]
                    for c in 0..<3 {
                        disconnected[(y * length + x) * 4 + c] = UInt8((hair[c] + (skin[c] - hair[c]) * v).rounded())
                    }
                }
            } }
            for source in [goldenSource(length: length, onlyFalseEdge: true), disconnected] {
                let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
                    width: length, height: length, face: face)
                XCTAssertEqual(counts["admittedCurve"], 0)
                for sign: Float in [-1, 1] {
                    XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: length, height: length,
                        face: face, strength: sign * BeautySafetyCaps.hairlineHeight) == source)
                    XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length, height: length, face: face))
                }
            }
        }
    }

    func testCoherentFaceSkinPrototypeRequiresFreshOpaqueConsistentSourceSeeds() {
        let face = anatomy(), source = pixels()
        let stale = FaceGeometry(bounds: face.bounds, faceContour: face.faceContour,
            freshness: .stale, observedEyebrowSupport: face.observedEyebrowSupport)
        var transparent = source
        transparent[(213 * size + 256) * 4 + 3] = 254
        let nasal = BeautyObservedNoseSupport(
            crest: [CoordinatePoint(x: 0.49, y: 0.56), CoordinatePoint(x: 0.5, y: 0.57), CoordinatePoint(x: 0.51, y: 0.58)],
            contour: [CoordinatePoint(x: 0.47, y: 0.6), CoordinatePoint(x: 0.5, y: 0.61), CoordinatePoint(x: 0.53, y: 0.6)])
        let withNasal = FaceGeometry(bounds: face.bounds, faceContour: face.faceContour,
            observedEyebrowSupport: face.observedEyebrowSupport, observedNoseSupport: nasal)
        var incompatibleNasal = source
        for y in 285...301 { for x in 248...264 {
            let i = (y * size + x) * 4
            incompatibleNasal[i] = 215; incompatibleNasal[i + 1] = 170; incompatibleNasal[i + 2] = 72
        } }
        for (bytes, geometry) in [(source, stale), (transparent, face), (incompatibleNasal, withNasal)] {
            let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(bytes,
                width: size, height: size, face: geometry)
            XCTAssertEqual(counts["faceSkinPrototype"], 0)
            for sign: Float in [-1, 1] {
                XCTAssertTrue(HairlineBoundaryRefiner.apply(bytes, width: size, height: size,
                    face: geometry, strength: sign * BeautySafetyCaps.hairlineHeight) == bytes)
            }
        }
        XCTAssertEqual(HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
            width: size, height: size, face: withNasal)["faceSkinPrototype"], 1,
            "valid fresh nasal corroboration must retain the connected positive")
    }

    private func bridgeCorroboratedAnatomy(nasalAvailable: Bool = true) -> FaceGeometry {
        let face = anatomy()
        let nasal = BeautyObservedNoseSupport(
            crest: nasalAvailable ? [CoordinatePoint(x: 0.49, y: 0.56), CoordinatePoint(x: 0.5, y: 0.57),
                                     CoordinatePoint(x: 0.51, y: 0.58)] : [],
            contour: [CoordinatePoint(x: 0.47, y: 0.6), CoordinatePoint(x: 0.5, y: 0.61),
                      CoordinatePoint(x: 0.53, y: 0.6)])
        return FaceGeometry(bounds: face.bounds, faceContour: face.faceContour,
            observedEyebrowSupport: face.observedEyebrowSupport, observedNoseSupport: nasal)
    }

    func testThreeIndependentSkinPatchesRetainWorkBesideNasalShadowAndHighlight() {
        for length in [512, 1280] { for kind in 0..<3 {
            var source = equivalentPixels(length: length)
            let scale = Double(length) / Double(size), face = bridgeCorroboratedAnatomy()
            for y in 0..<length { for x in 0..<length {
                let sx = (Double(x) + 0.5) / scale - 0.5
                let sy = (Double(y) + 0.5) / scale - 0.5
                if (248...264).contains(sx), (291...301).contains(sy) {
                    let tone = kind == 0 ? [35, 24, 18] : kind == 1 ? [255, 254, 245] : [215, 145, 96]
                    let i = (y * length + x) * 4
                    for c in 0..<3 { source[i + c] = UInt8(tone[c]) }
                }
            } }
            let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
                width: length, height: length, face: face)
            XCTAssertEqual(counts["faceSkinKnownBridgeCompatiblePatchCount"], 3)
            XCTAssertEqual(counts["faceSkinLegacySingleNasalPatchConflict"], 1)
            XCTAssertEqual(counts["faceSkinPrototype"], 1)
            XCTAssertEqual(counts["admittedCurve"], 1)
            let baseline = equivalentEdge(source, length: length)
            for sign: Float in [-1, 1] {
                let output = HairlineBoundaryRefiner.apply(source, width: length, height: length,
                    face: face, strength: sign * BeautySafetyCaps.hairlineHeight)
                XCTAssertGreaterThan((equivalentEdge(output, length: length) - baseline) * Double(sign), 1)
                var changedCore = 0
                for y in Int(ceil(210 * scale))..<length {
                    let i = y * length * 4, end = i + length * 4
                    if source[i..<end] != output[i..<end] { changedCore += 1 }
                }
                XCTAssertEqual(changedCore, 0, "all original nasal, brow and lower source rows remain exact")
                XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length,
                    height: length, face: face))
            }
        } }
    }

    func testAnyMissingNonopaqueOrContradictoryBridgeBlockAbstainsExactly() {
        for length in [512, 1280] {
            let scale = Double(length) / Double(size)
            for kind in 0..<5 {
                var source = equivalentPixels(length: length)
                let face = bridgeCorroboratedAnatomy(nasalAvailable: kind != 4)
                for y in 0..<length { for x in 0..<length {
                    let sx = (Double(x) + 0.5) / scale - 0.5
                    let sy = (Double(y) + 0.5) / scale - 0.5
                    guard (248...264).contains(sx), (280...291).contains(sy) else { continue }
                    let i = (y * length + x) * 4
                    if kind == 0 || kind == 1 {
                        let tone = kind == 0 ? [215, 170, 72] : [33, 110, 130]
                        for c in 0..<3 { source[i + c] = UInt8(tone[c]) }
                    } else if kind == 2 { source[i + 3] = 254 }
                    else if kind == 3 {
                        let tile = Int(floor(sx / 2)) + Int(floor(sy / 2))
                        let tone = tile % 2 == 0 ? [245, 170, 70] : [160, 155, 148]
                        for c in 0..<3 { source[i + c] = UInt8(tone[c]) }
                    }
                } }
                let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
                    width: length, height: length, face: face)
                XCTAssertEqual(counts["faceSkinPrototype"], 0)
                for sign: Float in [-1, 1] {
                    XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: length, height: length,
                        face: face, strength: sign * BeautySafetyCaps.hairlineHeight) == source)
                }
            }
        }
    }

    private func sourceCandidateAudit(
        _ source: [UInt8], width: Int, height: Int, face: FaceGeometry,
        frozenBand: [Bool], overlayLabel: String? = nil
    ) throws -> (counts: [String: Int], admission: [String: Int]) {
        XCTAssertEqual(frozenBand.count, width * height)
        var overlay = source
        var counts = ["originalCredibleCandidates": 0, "insideFrozenBandCandidates": 0,
            "insideFrozenBandBranchRejected": 0, "insideFrozenBandFamilyRejected": 0,
            "insideFrozenBandConnectionRejected": 0, "insideFrozenBandRetained": 0,
            "insideFrozenBandIndependentFamilyConflict": 0, "insideFrozenBandIndependentConnectionConflict": 0]
        if overlayLabel != nil {
            for y in 1..<(height - 1) { for x in 0..<width {
                let p = y * width + x
                if frozenBand[p], !frozenBand[p - width] || !frozenBand[p + width] {
                    let i = p * 4
                    overlay[i] = UInt8((Int(source[i]) * 3 + 255) / 4)
                    overlay[i + 1] = UInt8((Int(source[i + 1]) * 3 + 230) / 4)
                    overlay[i + 2] = UInt8(Int(source[i + 2]) * 3 / 4)
                }
            } }
        }
        let admission = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
            width: width, height: height, face: face,
            onSourceCandidate: { x, y, branch, family, connection in
                counts["originalCredibleCandidates", default: 0] += 1
                let within = frozenBand[y * width + x]
                let reason: String, color: [Int]
                if branch { reason = "BranchRejected"; color = [255, 155, 30] }
                else if !family { reason = "FamilyRejected"; color = [255, 40, 40] }
                else if !connection { reason = "ConnectionRejected"; color = [200, 40, 255] }
                else { reason = "Retained"; color = [20, 230, 80] }
                if within {
                    counts["insideFrozenBandCandidates", default: 0] += 1
                    counts["insideFrozenBand" + reason, default: 0] += 1
                    if !family { counts["insideFrozenBandIndependentFamilyConflict", default: 0] += 1 }
                    if !connection { counts["insideFrozenBandIndependentConnectionConflict", default: 0] += 1 }
                }
                guard overlayLabel != nil else { return }
                let i = (y * width + x) * 4
                for c in 0..<3 { overlay[i + c] = UInt8((Int(source[i + c]) * 2 + color[c]) / 3) }
            })
        if let label = overlayLabel {
            XCTAssertTrue(["full", "preview960"].contains(label))
            let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            let folder = package.appendingPathComponent(".build/face-reference/analysis", isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            for (name, values) in [("h6-source-palette", source), ("h6-source-rejection-overlay", overlay)] {
                let url = folder.appendingPathComponent(name + "-" + label + ".png").standardizedFileURL
                guard url.path.hasPrefix(folder.standardizedFileURL.path + "/"),
                      (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) != true else {
                    XCTFail("invalid ignored source diagnostic destination"); continue
                }
                let colorSpace = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
                let provider = try XCTUnwrap(CGDataProvider(data: Data(values) as CFData))
                let image = try XCTUnwrap(CGImage(width: width, height: height, bitsPerComponent: 8,
                    bitsPerPixel: 32, bytesPerRow: width * 4, space: colorSpace,
                    bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                    provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent))
                let destination = try XCTUnwrap(CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil))
                CGImageDestinationAddImage(destination, image, nil)
                XCTAssertTrue(CGImageDestinationFinalize(destination))
            }
        }
        return (counts, admission)
    }

    func testSourceCandidateRejectionAuditPartitionsFrozenBandWithoutChangingAdmission() throws {
        let source = pixels(), face = anatomy()
        let band = (0..<(size * size)).map { p in abs(Double(p / size) - boundary(x: p % size)) <= 36 }
        let audit = try sourceCandidateAudit(source, width: size, height: size, face: face, frozenBand: band)
        XCTAssertGreaterThan(audit.counts["insideFrozenBandCandidates"] ?? 0, 0)
        let reasons = ["BranchRejected", "FamilyRejected", "ConnectionRejected", "Retained"]
        let sum = reasons.reduce(0) { $0 + (audit.counts["insideFrozenBand" + $1] ?? 0) }
        XCTAssertEqual(sum, audit.counts["insideFrozenBandCandidates"])
        XCTAssertTrue(audit.admission == HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
            width: size, height: size, face: face), "diagnostic callback must not alter production admission")
        let empty = try sourceCandidateAudit(source, width: size, height: size, face: face,
            frozenBand: [Bool](repeating: false, count: size * size))
        XCTAssertEqual(empty.counts["insideFrozenBandCandidates"], 0)
        XCTAssertTrue(empty.admission == audit.admission, "frozen diagnostic mask cannot decide admission")
    }

    /// The cap and registered anatomy are unchanged. Source skin gradually
    /// changes illumination between the inner forehead and the same edge;
    /// the warm shadow exceeds the single original chromaticity box. A slow
    /// golden drift is a distinct negative, rather than an allowed skin tint.
    private func spatialForeheadPixels(length: Int, kind: Int = 0) -> [UInt8] {
        let scale = Double(length) / Double(size)
        var source = [UInt8](repeating: 255, count: length * length * 4)
        for y in 0..<length { for x in 0..<length {
            let sx = (Double(x) + 0.5) / scale - 0.5
            let sy = (Double(y) + 0.5) / scale - 0.5
            let u = (sx - 256) / 154, edge = 105 + 70 * u * u
            let hair = [100.0, 65.0, 40.0], skin = [220.0, 170.0, 130.0]
            let tint = kind == 1 ? [215.0, 170.0, 72.0] : kind == 2 ? [100.0, 130.0, 180.0] : [160.0, 112.0, 76.0]
            let q = min(1, max(0, (sy - 140) / 70))
            let local = (0..<3).map { tint[$0] + (skin[$0] - tint[$0]) * q }
            let t = min(1, max(0, (sy - edge) / 16)), v = t * t * (3 - 2 * t)
            let i = (y * length + x) * 4
            for c in 0..<3 { source[i + c] = UInt8((hair[c] + (local[c] - hair[c]) * v).rounded()) }
            if Int(floor(max(0, sx))) % 19 < 3 && sy >= edge - 35 && sy < edge - 13 {
                // Kind 0 preserves the C27 bright-glint challenge exactly.
                // Kind 4 is an independent shaded-skin positive: its glint
                // can supply a sparse old first crossing but remains darker
                // than the actual connected skin under the original predicates.
                source[i] = kind >= 4 ? 135 : 200
                source[i + 1] = kind >= 4 ? 100 : 145
                source[i + 2] = kind >= 4 ? 70 : 100
            }
            if kind == 5 || kind == 6 {
                // Source-only continuous material probes. The known seeds
                // and every original edge pixel stay unchanged. A transverse
                // shelf separates the edge from the brow-registered seeds.
                let up = min(1, max(0, (sy - 180) / 4))
                let down = min(1, max(0, (188 - sy) / 4))
                let level = min(up * up * (3 - 2 * up), down * down * (3 - 2 * down))
                for c in 0..<3 {
                    let value = kind == 5
                        ? Double(source[i + c]) * (1 - level * [0.15, 0.25, 0.38][c])
                        : Double(source[i + c]) + level * [12.0, -6.0, 0.0][c]
                    source[i + c] = UInt8(min(255, max(0, value.rounded())))
                }
            }
            if kind == 3 && sy >= 180 && sy < 210 {
                let t = min(1, max(0, (sy - 194) / 16)), v = t * t * (3 - 2 * t)
                for c in 0..<3 { source[i + c] = UInt8((hair[c] + (skin[c] - hair[c]) * v).rounded()) }
            }
        } }
        return source
    }

    func testSourceRegisteredPaletteRetainsWarmShadowEdgeWithPhysicalDirectionAndExactExterior() {
        for length in [512, 1280] {
            let source = spatialForeheadPixels(length: length, kind: 4), face = anatomy()
            let scale = Double(length) / Double(size)
            let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
                width: length, height: length, face: face)
            XCTAssertGreaterThan(counts["faceSkinRegisteredPaletteColorCount"] ?? 0, 1)
            XCTAssertEqual(counts["admittedCurve"], 1, "source scale \(length)")
            let baseline = equivalentEdge(source, length: length)
            XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: length, height: length,
                face: face, strength: 0) == source)
            for sign: Float in [-1, 1] {
                let output = HairlineBoundaryRefiner.apply(source, width: length, height: length,
                    face: face, strength: sign * BeautySafetyCaps.hairlineHeight)
                XCTAssertGreaterThan((equivalentEdge(output, length: length) - baseline) * Double(sign), 1)
                var exterior = 0, outsideSourceBand = 0, lowerSourceCore = 0
                for y in 0..<length { for x in 0..<length {
                    let sx = (Double(x) + 0.5) / scale - 0.5
                    let sy = (Double(y) + 0.5) / scale - 0.5
                    let u = (sx - 256) / 154, edge = 105 + 70 * u * u
                    let i = (y * length + x) * 4
                    let changed = (0..<4).contains(where: { source[i + $0] != output[i + $0] })
                    if changed {
                        if abs(sy - edge) > 24 { outsideSourceBand += 1 }
                        if sy >= 210 { lowerSourceCore += 1 }
                        if abs(sy - edge) > 24 || sy >= 210 { exterior += 1 }
                    }
                } }
                XCTAssertEqual(exterior, 0, "combined original exterior at source scale \(length)")
                XCTAssertEqual(outsideSourceBand, 0, "original source transition boundary at scale \(length)")
                XCTAssertEqual(lowerSourceCore, 0, "original lower source core at scale \(length)")
                XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length,
                    height: length, face: face), "local skin colors never authorize head wrap")
                XCTAssertTrue(output == HairlineBoundaryRefiner.apply(source, width: length,
                    height: length, face: face, strength: sign * BeautySafetyCaps.hairlineHeight))
            }
        }
    }

    func testRegisteredPaletteCannotFollowSlowGoldenDriftColdSkinOrDisconnectedWarmIsland() {
        for length in [512, 1280] { for kind in [1, 2, 3] {
            let source = spatialForeheadPixels(length: length, kind: kind), face = anatomy()
            let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
                width: length, height: length, face: face)
            XCTAssertEqual(counts["admittedCurve"], 0, "source-only adverse illumination kind \(kind) at scale \(length)")
            for sign: Float in [-1, 1] {
                XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: length, height: length,
                    face: face, strength: sign * BeautySafetyCaps.hairlineHeight) == source,
                    "source connectivity cannot grant a golden/cold/disconnected edge")
                XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length,
                    height: length, face: face))
            }
        } }
    }

    func testBrightGlintsAboveShadowRemainAnUnsupportedOriginalScaleChallenge() {
        // C27's original positive claim was not supported by its source:
        // brighter glints occupy the unchanged far-above color window. Keep
        // that exact input as a challenge instead of relaxing the old gates.
        let source = spatialForeheadPixels(length: size), face = anatomy()
        let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
            width: size, height: size, face: face)
        XCTAssertGreaterThan(counts["missingUnprotectedPeakColumns"] ?? 0, 0)
        XCTAssertEqual(counts["admittedCurve"], 0)
        for sign: Float in [-1, 1] {
            XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: size, height: size,
                face: face, strength: sign * BeautySafetyCaps.hairlineHeight) == source)
        }
    }

    func testLocallyCoupledSourceShadeKeepsEdgeDirectionAndOriginalSourceExterior() {
        for length in [512, 1280] {
            let source = spatialForeheadPixels(length: length, kind: 5), face = anatomy()
            let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
                width: length, height: length, face: face)
            XCTAssertEqual(counts["faceSkinPrototype"], 1)
            XCTAssertEqual(counts["faceSkinCumulativeSamplingCoverageGapCount"], 0,
                "registered source core coverage must have no gap at either existing physical scale")
            XCTAssertGreaterThan(counts["faceSkinLocallyCoupledShadeEdgeCount"] ?? 0, 0,
                "the independent continuous shade must use the new signed RGB proof")
            XCTAssertEqual(counts["admittedCurve"], 1, "source scale \(length)")
            let baseline = equivalentEdge(source, length: length), scale = Double(length) / Double(size)
            for sign: Float in [-1, 1] {
                let output = HairlineBoundaryRefiner.apply(source, width: length, height: length,
                    face: face, strength: sign * BeautySafetyCaps.hairlineHeight)
                XCTAssertGreaterThan((equivalentEdge(output, length: length) - baseline) * Double(sign), 1)
                var exterior = 0
                for y in 0..<length { for x in 0..<length {
                    let sx = (Double(x) + 0.5) / scale - 0.5, sy = (Double(y) + 0.5) / scale - 0.5
                    let edge = 105 + 70 * pow((sx - 256) / 154, 2), i = (y * length + x) * 4
                    if abs(sy - edge) > 24 || sy >= 210 {
                        if (0..<4).contains(where: { source[i + $0] != output[i + $0] }) { exterior += 1 }
                    }
                } }
                XCTAssertEqual(exterior, 0, "illumination evidence cannot become another edit target")
                XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length,
                    height: length, face: face))
            }
        }
    }

    func testEqualLuminanceOpposedChannelShelfCannotGrantSourceConnectivity() {
        for length in [512, 1280] {
            let source = spatialForeheadPixels(length: length, kind: 6), face = anatomy()
            let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
                width: length, height: length, face: face)
            XCTAssertEqual(counts["faceSkinPrototype"], 1, "original registered skin seeds remain valid")
            XCTAssertGreaterThan(counts["faceSkinSourceMaterialPixelCount"] ?? 0,
                counts["faceSkinConnectedMaterialPixelCount"] ?? 0,
                "locally contradictory eligible source material cannot be globally joined")
            XCTAssertEqual(counts["admittedCurve"], 0, "source scale \(length)")
            for sign: Float in [-1, 1] {
                XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: length, height: length,
                    face: face, strength: sign * BeautySafetyCaps.hairlineHeight) == source)
                XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length,
                    height: length, face: face))
            }
        }
    }

    private func connectedWarmBrownFalseCurve(length: Int) -> [UInt8] {
        let scale = Double(length) / Double(size)
        var source = [UInt8](repeating: 255, count: length * length * 4)
        for y in 0..<length { for x in 0..<length {
            let sx = (Double(x) + 0.5) / scale - 0.5, sy = (Double(y) + 0.5) / scale - 0.5
            let edge = 105 + 70 * pow((sx - 256) / 154, 2)
            let hair = [100.0, 65.0, 40.0], brown = [174.0, 120.0, 69.0], skin = [220.0, 170.0, 130.0]
            let q = min(1, max(0, (sy - 160) / 10))
            let material = (0..<3).map { brown[$0] + (skin[$0] - brown[$0]) * q }
            let t = min(1, max(0, (sy - edge) / 16)), v = t * t * (3 - 2 * t)
            let i = (y * length + x) * 4
            for c in 0..<3 { source[i + c] = UInt8((hair[c] + (material[c] - hair[c]) * v).rounded()) }
            if Int(floor(max(0, sx))) % 19 < 3 && sy >= edge - 35 && sy < edge - 13 {
                source[i] = 135; source[i + 1] = 100; source[i + 2] = 70
            }
        } }
        return source
    }

    func testConnectedWarmBrownMaterialDriftCannotOwnAnUnsupportedFullCurve() {
        for length in [512, 1280] {
            let source = connectedWarmBrownFalseCurve(length: length), face = anatomy()
            let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
                width: length, height: length, face: face)
            XCTAssertEqual(counts["faceSkinPrototype"], 1)
            XCTAssertEqual(counts["admittedCurve"], 0,
                "a complete material curve is not seed-registered forehead skin at scale \(length)")
            for sign: Float in [-1, 1] {
                XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: length, height: length,
                    face: face, strength: sign * BeautySafetyCaps.hairlineHeight) == source)
                XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length,
                    height: length, face: face))
            }
        }
    }

    /// Independently registered colored illumination is affine in physical
    /// source coordinates. Its upper skin leaves the original global family;
    /// the fixed lower-forehead cores, not that upper edge, predict its color.
    private func independentIlluminationPixels(length: Int, upperMaterial: Bool = false) -> [UInt8] {
        let scale = Double(length) / Double(size)
        var source = [UInt8](repeating: 255, count: length * length * 4)
        for y in 0..<length { for x in 0..<length {
            let sx = (Double(x) + 0.5) / scale - 0.5, sy = (Double(y) + 0.5) / scale - 0.5
            let u = (sx - 256) / 154, edge = 105 + 70 * u * u
            let offset = min(0, sy - 210)
            var skin = [220 + offset * 0.10 + u * 3,
                        170 + offset * 0.35 + u,
                        130 + offset * 0.40 - u]
            if upperMaterial {
                // Preserve every lower support core. A separate upper brown
                // material must not inherit the extrapolated skin ownership.
                let q = min(1, max(0, (sy - 160) / 10))
                skin = (0..<3).map { [174.0, 120.0, 69.0][$0] +
                    (skin[$0] - [174.0, 120.0, 69.0][$0]) * q }
            }
            let hair = [100.0, 65.0, 40.0]
            let t = min(1, max(0, (sy - edge) / 16)), blend = t * t * (3 - 2 * t)
            let i = (y * length + x) * 4
            for c in 0..<3 {
                source[i + c] = UInt8(min(255, max(0, (hair[c] + (skin[c] - hair[c]) * blend).rounded())))
            }
            if Int(floor(max(0, sx))) % 19 < 3, sy >= edge - 35, sy < edge - 13 {
                source[i] = 135; source[i + 1] = 100; source[i + 2] = 70
            }
        } }
        return source
    }

    func testIndependentLowerForeheadIlluminationPredictsColoredSkinWithoutMovingSourceExterior() {
        for length in [512, 1280] {
            let source = independentIlluminationPixels(length: length), face = anatomy()
            let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
                width: length, height: length, face: face)
            XCTAssertEqual(counts["faceSkinIndependentIlluminationQualified"], 1)
            XCTAssertGreaterThan(counts["faceSkinIndependentIlluminationCandidateCount"] ?? 0, 0,
                "positive must exercise the independent proof rather than become another old-family no-op")
            XCTAssertEqual(counts["admittedCurve"], 1)
            let baseline = equivalentEdge(source, length: length), scale = Double(length) / Double(size)
            for sign: Float in [-1, 1] {
                var previous = 0.0
                for fraction: Float in [0.25, 0.5, 0.75, 1] {
                    let output = HairlineBoundaryRefiner.apply(source, width: length, height: length,
                        face: face, strength: sign * BeautySafetyCaps.hairlineHeight * fraction)
                    let movement = (equivalentEdge(output, length: length) - baseline) * Double(sign)
                    XCTAssertGreaterThan(movement, previous + 0.1)
                    if fraction == 1 { XCTAssertGreaterThan(movement, 1) }
                    previous = movement
                    var exteriorChanges = 0, alphaChanges = 0
                    for y in 0..<length { for x in 0..<length {
                        let sx = (Double(x) + 0.5) / scale - 0.5, sy = (Double(y) + 0.5) / scale - 0.5
                        let edge = 105 + 70 * pow((sx - 256) / 154, 2), i = (y * length + x) * 4
                        let changed = (0..<4).contains { source[i + $0] != output[i + $0] }
                        if changed, abs(sy - edge) > 24 || sy >= 210 { exteriorChanges += 1 }
                        if source[i + 3] != output[i + 3] { alphaChanges += 1 }
                    } }
                    XCTAssertEqual(exteriorChanges, 0); XCTAssertEqual(alphaChanges, 0)
                }
            }
            XCTAssertFalse(HairlineBoundaryRefiner.hasCoherentHairCap(source, width: length,
                height: length, face: face), "a local illumination proof never owns head wrap")
        }
    }

    func testIndependentLowerForeheadPlaneCannotBecomeAnUpperBrownMaterialPalette() {
        for length in [512, 1280] {
            let source = independentIlluminationPixels(length: length, upperMaterial: true), face = anatomy()
            let counts = HairlineBoundaryRefiner.coherentSourceQualificationCounts(source,
                width: length, height: length, face: face)
            XCTAssertEqual(counts["faceSkinIndependentIlluminationQualified"], 1,
                "lower support is the identical physical source plane")
            XCTAssertEqual(counts["admittedCurve"], 0,
                "a different connected upper material cannot update the fixed prediction")
            for sign: Float in [-1, 1] {
                XCTAssertTrue(HairlineBoundaryRefiner.apply(source, width: length, height: length,
                    face: face, strength: sign * BeautySafetyCaps.hairlineHeight) == source)
            }
        }
    }

    private func sourceGateAggregate(
        _ bytes: [UInt8], width: Int, height: Int, face: FaceGeometry,
        observation: BeautyFaceObservation, layer: String
    ) throws -> [String: Any] {
        let b = face.bounds
        let brows = (face.observedEyebrowSupport?.left?.points ?? []) + (face.observedEyebrowSupport?.right?.points ?? [])
        let browTop = try XCTUnwrap(brows.map { Int($0.y * Float(height)) }.min())
        let left = max(16, Int((b.midX - b.width * 0.25) * Float(width)))
        let right = min(width - 17, Int((b.midX + b.width * 0.25) * Float(width)))
        let first = max(40, Int((b.minY - b.height * 0.28) * Float(height)))
        let last = min(height - 40, browTop - max(30, Int(b.height * Float(height) * 0.10)))
        XCTAssertGreaterThan(last, first)
        let rowCount = last - first + 1
        guard rowCount > 0 else { return ["layer": layer, "sourceSearchUsable": false] }
        var rows = [Int?](), gateMissing = [Int](repeating: 0, count: 8)
        var scores = [[Double]](), missingPeaks = 0
        for x in left...right {
            var sums = [[Double]](repeating: [Double](repeating: 0, count: height + 1), count: 3)
            var nonopaque = [Int](repeating: 0, count: height + 1)
            for y in 0..<height {
                let i = (y * width + x) * 4
                for c in 0..<3 { sums[c][y + 1] = sums[c][y] + Double(bytes[i + c]) }
                nonopaque[y + 1] = nonopaque[y] + (bytes[i + 3] == 255 ? 0 : 1)
            }
            func mean(_ a: Int, _ z: Int, _ c: Int) -> Double {
                (sums[c][z] - sums[c][a]) / Double(z - a)
            }
            func gradient(_ y: Int) -> Double {
                mean(y + 1, y + 5, 0) - mean(y - 4, y, 0)
            }
            var found: Int?, ever = [Bool](repeating: false, count: 8)
            var column = [Double](repeating: -.infinity, count: rowCount)
            for y in first...last {
                let dark = mean(y - 20, y - 5, 0), light = mean(y + 5, y + 20, 0)
                let gates = [dark < 150, light - dark >= 32,
                    mean(y - 36, y - 20, 0) < light - 26, light > 90,
                    light - mean(y + 5, y + 20, 2) >= 10,
                    mean(y + 5, y + 20, 1) >= mean(y + 5, y + 20, 2),
                    nonopaque[y + 28] == nonopaque[y - 36],
                    mean(y - 20, y - 5, 2) < dark + 12 && mean(y - 20, y - 5, 1) < dark + 12]
                for i in gates.indices { ever[i] = ever[i] || gates[i] }
                if gates.allSatisfy({ $0 }) && found == nil {
                    found = (max(first, y - 4)...min(last, y + 12)).max { a, c in
                        gradient(a) < gradient(c)
                    }
                }
                if gates.allSatisfy({ $0 }) {
                    let g = gradient(y), localPeak = ((y - 2)...(y + 2)).map(gradient).max() ?? 0
                    if g >= max(1, (light - dark) * 0.05), g >= localPeak * 0.75 {
                        column[y - first] = g
                    }
                }
            }
            rows.append(found)
            for i in ever.indices where !ever[i] { gateMissing[i] += 1 }
            if let maximum = column.filter(\.isFinite).max(), maximum > 0 {
                scores.append(column.map { $0.isFinite ? $0 / maximum : -.infinity })
            } else {
                missingPeaks += 1
                scores.append(column)
            }
        }
        let valid = rows.compactMap { $0 }
        let jumps = zip(rows, rows.dropFirst()).compactMap { a, b -> Int? in
            guard let a, let b else { return nil }; return abs(a - b)
        }
        struct Path { let rows: [Int]; let score: Double }
        var connectedPrefix = 0
        let separation = max(10, Int(b.height * Float(height) * 0.025))
        func select(excluding: [Int]? = nil) -> Path? {
            var previous = [Double](repeating: -.infinity, count: rowCount)
            var predecessors = [[Int]](repeating: [Int](repeating: -1, count: rowCount), count: scores.count)
            for column in scores.indices {
                var next = [Double](repeating: -.infinity, count: rowCount)
                for row in 0..<rowCount where scores[column][row].isFinite {
                    if let excluding, abs(row + first - excluding[column]) <= separation { continue }
                    if column == 0 { next[row] = scores[column][row]; continue }
                    for before in max(0, row - 4)...min(rowCount - 1, row + 4) where previous[before].isFinite {
                        let candidate = previous[before] + scores[column][row] - Double(abs(row - before)) * 0.06
                        if candidate > next[row] {
                            next[row] = candidate; predecessors[column][row] = before
                        }
                    }
                }
                guard next.contains(where: \.isFinite) else { return nil }
                if excluding == nil { connectedPrefix = column + 1 }
                previous = next
            }
            guard let end = previous.indices.max(by: { previous[$0] < previous[$1] }),
                  previous[end].isFinite else { return nil }
            var selected = [Int](repeating: 0, count: scores.count), row = end
            for column in scores.indices.reversed() {
                selected[column] = row + first
                if column > 0 {
                    row = predecessors[column][row]
                    guard row >= 0 else { return nil }
                }
            }
            return Path(rows: selected, score: previous[end])
        }
        func shapeGates(_ rows: [Int]) -> [String: Bool] {
            guard let low = rows.min(), let high = rows.max(), rows.count >= 7 else { return [:] }
            let n = rows.count, margin = max(3, n / 8)
            let center = rows[(n / 2 - margin)...(n / 2 + margin)]
            let sides = Array(rows.prefix(margin)) + Array(rows.suffix(margin))
            let centerMean = Double(center.reduce(0, +)) / Double(center.count)
            let sideMean = Double(sides.reduce(0, +)) / Double(sides.count)
            return ["spreadPass": high - low <= Int(b.height * Float(height) * 0.22),
                "adjacentStepPass": zip(rows, rows.dropFirst()).allSatisfy { abs($0 - $1) <= 4 },
                "browClearancePass": high + 20 < browTop,
                "bangsDipPass": centerMean <= sideMean + Double(b.height * Float(height) * 0.01)]
        }
        let selected = select(), selectedGates = selected.map { shapeGates($0.rows) } ?? [:]
        let selectedScorePass = selected.map { $0.score >= Double(scores.count) * 0.55 } ?? false
        let selectedShapePass = selectedGates.count == 4 && selectedGates.values.allSatisfy { $0 }
        let selectedPreCompetitionPass = selectedScorePass &&
            ["spreadPass", "adjacentStepPass", "browClearancePass"].allSatisfy { selectedGates[$0] == true }
        let competitor = selectedPreCompetitionPass ? selected.flatMap { select(excluding: $0.rows) } : nil
        let competition = competitor.map { $0.score >= (selected?.score ?? .infinity) * 0.85 } ?? false
        let legacyGates = valid.count == rows.count ? shapeGates(valid) : [:]
        let legacyPass = legacyGates.count == 4 && legacyGates.values.allSatisfy { $0 }
        let coherentPass = selectedScorePass && selectedShapePass && !competition
        // Reproduce the existing source-fixed public hairline rectangle solely
        // to locate its mismatch. This does not authorize a new output domain.
        let sourceContour = try XCTUnwrap(observation.observedFaceSupport?.contour)
        let sourceBrow = try XCTUnwrap(observation.observedEyebrowSupport?.left)
        let sourceBounds = try XCTUnwrap(observation.imageBounds)
        let contourMaxX = try XCTUnwrap(sourceContour.map(\.x).max())
        let contourMinX = try XCTUnwrap(sourceContour.map(\.x).min())
        let span = (contourMaxX - contourMinX) * Double(width)
        let browMinimum = try XCTUnwrap(sourceBrow.map(\.y).min()) * Double(height) - max(2, span * 0.008)
        let minY = sourceBounds.y * Double(height)
        let hairDomain = CGRect(x: sourceBounds.x * Double(width) - span * 0.12,
            y: max(0, minY - span * 0.20), width: sourceBounds.width * Double(width) + span * 0.24,
            height: max(0, browMinimum - minY + span * 0.16))
        var endpointAggregates = [[String: Any]]()
        let endpoints: [(String, Float)] = [("negative", -0.25), ("positive", 0.25)]
        for (endpoint, strength) in endpoints {
            let output = HairlineBoundaryRefiner.apply(bytes, width: width, height: height, face: face, strength: strength)
            var changed = 0, outside = [Int](repeating: 0, count: 4), alpha = 0
            var maximumExteriorDistance = 0.0
            for y in 0..<height { for x in 0..<width {
                let i = (y * width + x) * 4
                if bytes[i + 3] != output[i + 3] { alpha += 1 }
                guard (0..<4).contains(where: { bytes[i + $0] != output[i + $0] }) else { continue }
                changed += 1
                let p = CGPoint(x: Double(x) + 0.5, y: Double(y) + 0.5)
                if !hairDomain.contains(p) {
                    if p.y < hairDomain.minY { outside[0] += 1 }
                    else if p.y >= hairDomain.maxY { outside[1] += 1 }
                    else if p.x < hairDomain.minX { outside[2] += 1 }
                    else { outside[3] += 1 }
                    maximumExteriorDistance = max(maximumExteriorDistance,
                        Double(max(0, hairDomain.minY - p.y, p.y - hairDomain.maxY,
                            hairDomain.minX - p.x, p.x - hairDomain.maxX)))
                }
            } }
            endpointAggregates.append(["endpoint": endpoint, "changedPixels": changed,
                "outsideFrozenSourceHairlineDomainTopBottomLeftRight": outside,
                "maximumExteriorDistanceFractionOfSourceSpan": maximumExteriorDistance / span,
                "alphaChangedPixels": alpha])
        }
        return ["kind": "production-source-hairline-gate-diagnostic", "layer": layer,
            "sourceSearchUsable": true,
            "columns": rows.count, "missingColumns": rows.count - valid.count,
            "gateNeverPassesColumnCounts": gateMissing,
            "adjacentJumpOverFourCount": jumps.filter { $0 > 4 }.count,
            "maximumAdjacentJump": jumps.max() ?? 0,
            "rowSpreadFractionOfFaceHeight": Double((valid.max() ?? 0) - (valid.min() ?? 0)) / Double(b.height * Float(height)),
            "oldSoftShapeGates": legacyGates, "oldSoftCompletePass": legacyPass,
            "coherentMissingCrediblePeakColumns": missingPeaks,
            "coherentConnectedPrefixColumnCount": connectedPrefix,
            "coherentCompletePath": selected != nil,
            "coherentMeanNormalizedScore": (selected?.score ?? 0) / Double(scores.count),
            "coherentSelectedScorePass": selectedScorePass,
            "coherentSelectedShapeGates": selectedGates,
            "coherentCompetingCompletePath": competitor != nil,
            "coherentCompetitionVeto": competition, "coherentCompletePass": coherentPass,
            "nativeResolutionGateDiagnostics": true,
            "coherentFallbackUsesBoundedAnalysis": max(width, height) > 960 && !legacyPass,
            "coherentFallbackMaximumAnalysisLongEdge": 960,
            "protectedCoherentSourceQualification": HairlineBoundaryRefiner.coherentSourceQualificationCounts(
                bytes, width: width, height: height, face: face),
            "refinementEndpointAggregates": endpointAggregates,
            "plannerSourceGeometryQualified": FaceShapeWarpProvider.hasSourceHairlineGeometry(face: face, strength: 0.25),
            "headWrapQualified": HairlineBoundaryRefiner.hasCoherentHairCap(bytes, width: width, height: height, face: face)]
    }
}
