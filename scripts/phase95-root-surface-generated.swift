// Generated-only sampler calibration fragment. Appended to the comparator
// prefix and RootSurfaceNative by the bounded parent; never a standalone CLI.
// All raster/point payloads are ephemeral pipes consumed by that parent.
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

private enum RootSurfaceGenerated {
    private static func face() -> FaceGeometry {
        let crest = [0.30, 0.35, 0.40, 0.45, 0.50].map { CoordinatePoint(x: 0.50, y: $0) }
        let contour = [CoordinatePoint(x: 0.44, y: 0.51), .init(x: 0.46, y: 0.55),
                       .init(x: 0.50, y: 0.56), .init(x: 0.54, y: 0.55), .init(x: 0.56, y: 0.51)]
        let base = BeautyFaceGeometryAdapter.makeGeometry(from: BeautyFaceObservation(
            imageBounds: .init(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
            landmarks: .complete, observedNoseSupport: .init(crest: crest, contour: contour)))
        func eye(_ side: BeautyObservedEyeSide, _ x: Float) -> BeautyEyeSemanticSupport {
            let trace: [SIMD2<Float>] = [.init(x - 0.04, 0.28), .init(x, 0.26),
                                       .init(x + 0.04, 0.28), .init(x, 0.30)]
            return .init(side: side, contour: trace, upper: Array(trace.prefix(3)),
                lower: [trace[0], trace[3], trace[2]], inner: [side == .left ? trace[2] : trace[0]],
                outer: [side == .left ? trace[0] : trace[2]], corners: [trace[0], trace[2]],
                center: .init(x, 0.28), pupil: nil, span: .init(0.08, 0.04), tilt: 0)
        }
        return FaceGeometry(bounds: base.bounds, faceContour: base.faceContour, nose: base.nose,
            leftEyeSupport: eye(.left, 0.38), rightEyeSupport: eye(.right, 0.62),
            observedNoseSupport: base.observedNoseSupport)
    }

    private static func texture(size: Int) -> [UInt8] {
        // Fixed integer hash noise, then a separable [1,4,6,4,1]/16 low pass.
        // No model, image asset, fixture locator, or system random state.
        let taps = [1, 4, 6, 4, 1]
        var noise = [UInt8](repeating: 0, count: size * size * 3)
        for y in 0..<size { for x in 0..<size { for c in 0..<3 {
            var v = UInt64(x + size * y + 1 + (c + 1) * 1_000_003)
            v = (v ^ (v >> 16)) &* 0x45d9f3b
            v = (v ^ (v >> 16)) &* 0x45d9f3b
            noise[(y * size + x) * 3 + c] = UInt8(32 + ((v ^ (v >> 16)) % 192))
        } } }
        var horizontal = [Int](repeating: 0, count: noise.count)
        for y in 0..<size { for x in 0..<size { for c in 0..<3 {
            var sum = 0
            for k in 0..<5 {
                let sx = max(0, min(size - 1, x + k - 2))
                sum += Int(noise[(y * size + sx) * 3 + c]) * taps[k]
            }
            horizontal[(y * size + x) * 3 + c] = sum
        } } }
        var rgba = [UInt8](repeating: 255, count: size * size * 4)
        for y in 0..<size { for x in 0..<size { for c in 0..<3 {
            var sum = 0
            for k in 0..<5 {
                let sy = max(0, min(size - 1, y + k - 2))
                sum += horizontal[(sy * size + x) * 3 + c] * taps[k]
            }
            rgba[(y * size + x) * 4 + c] = UInt8((sum + 128) / 256)
        } } }
        return rgba
    }

    private static func raster(_ image: CIImage, size: Int, context: CIContext,
                               color: CGColorSpace) throws -> CanonicalImage {
        guard image.extent == CGRect(x: 0, y: 0, width: size, height: size) else {
            throw SemanticContractError.admission
        }
        var bytes = [UInt8](repeating: 0, count: size * size * 4)
        context.render(image, toBitmap: &bytes, rowBytes: size * 4, bounds: image.extent,
                       format: .RGBA8, colorSpace: color)
        guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else {
            throw SemanticContractError.admission
        }
        let transported = try RootSurfaceNative.image(image, context: context)
        guard transported.width == size, transported.height == size, transported.rgba == bytes else {
            throw SemanticContractError.admission
        }
        return transported
    }

    // Independent Double evaluation of the admitted continuous inverse map.
    // Provider fields are allowed HERE as generated image-formation truth only.
    // Real-photo scores must never use this intended displacement as evidence.
    private static func inverseX(_ x: Double, _ y: Double, size: Int,
                                  points: [WarpControlPoint]) -> Double {
        let nx = (x + 0.5) / Double(size), ny = (y + 0.5) / Double(size)
        var displacement = 0.0
        for p in points {
            if let maximumY=p.exclusiveMaximumY,y>=floor(Double(maximumY)*Double(size)) { continue }
            let dx = nx - Double(p.target.x), dy = ny - Double(p.target.y)
            let weight = max(0, 1 - sqrt(dx * dx + dy * dy) / Double(p.radius))
            displacement += (Double(p.target.x) - Double(p.source.x)) * weight * Double(size)
        }
        return x - displacement
    }

    private static func forward(_ x: Double, _ y: Double, size: Int,
                                 points: [WarpControlPoint]) throws -> [Double] {
        if points.isEmpty { return [x, y] }
        var low = 0.0, high = Double(size - 1)
        guard inverseX(low, y, size: size, points: points) <= x,
              inverseX(high, y, size: size, points: points) >= x else {
            throw SemanticContractError.admission
        }
        for _ in 0..<60 {
            let mid = (low + high) * 0.5
            if inverseX(mid, y, size: size, points: points) < x { low = mid } else { high = mid }
        }
        let position = (low + high) * 0.5
        guard abs(inverseX(position, y, size: size, points: points) - x) < 0.0000001 else {
            throw SemanticContractError.admission
        }
        return [position, y]
    }

    private static func checkSampler(source: CanonicalImage, output: CanonicalImage,
                                     points: [WarpControlPoint], crop: [Int]) throws -> Double {
        let size = source.width
        var maximum = 0.0
        for y in crop[1]..<crop[3] { for x in crop[0]..<crop[2] {
            let q = max(0, min(Double(size - 1), inverseX(Double(x), Double(y), size: size, points: points)))
            let lo = Int(floor(q)), hi = min(size - 1, lo + 1), fraction = q - Double(lo)
            for c in 0..<3 {
                let expected = Double(source.rgba[(y * size + lo) * 4 + c]) * (1 - fraction)
                    + Double(source.rgba[(y * size + hi) * 4 + c]) * fraction
                maximum = max(maximum, abs(Double(output.rgba[(y * size + x) * 4 + c]) - expected))
            }
        } }
        guard maximum <= 1 else { throw SemanticContractError.admission }
        return maximum
    }

    static func run() throws -> [String: Any] {
        guard let color = CGColorSpace(name: CGColorSpace.sRGB) else { throw SemanticContractError.admission }
        let context = CIContext(options: [.workingColorSpace: color, .outputColorSpace: color])
        let geometry = face()
        var cases: [[String: Any]] = []
        for size in [512, 1024] {
            let original = texture(size: size)
            let canonical = try BeautyCanonicalStillImage(rgba8Data: Data(original), width: size,
                height: size, rowBytes: size * 4, metadata: .init(orientation: .up, source: .testFixture))
            let source = try raster(canonical.ciImage, size: size, context: context, color: color)
            guard source.rgba == original else { throw SemanticContractError.admission }
            let crop = [Int(Double(size) * 0.30), Int(Double(size) * 0.16),
                        Int(Double(size) * 0.70), Int(Double(size) * 0.43)]
            // One predeclared source grid for all strengths. Includes unchanged
            // protected locations, cone slopes/cusps, and multiple nasal bands.
            var fullPairs: [[[Double]]] = []
            for y in [0.241, 0.248, 0.255, 0.267, 0.280, 0.293, 0.307, 0.325, 0.342] {
                // Source-defined discrete scanline. Never infer a continuous-Y
                // material position from neighboring raster rows or output fit.
                let row = (y * Double(size) - 0.5).rounded(.toNearestOrAwayFromZero)
                for x in [0.400, 0.435, 0.450, 0.475] {
                    fullPairs.append([[x * Double(size) - 0.5, row],
                                      [(1 - x) * Double(size) - 0.5, row]])
                }
            }
            let pairs = fullPairs.map { $0.map { [$0[0] - Double(crop[0]), $0[1] - Double(crop[1])] } }
            for strength: Float in [0, 0.125, 0.25] {
                let plan = BeautyEffectResolver.resolve(parameters: .init(noseRootNarrowing: strength),
                                                        faceGeometry: geometry)
                let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: geometry)
                guard points.count == (strength == 0 ? 0 : 6),
                      points.allSatisfy({ $0.pixelCenterSampling && $0.falloff == 1 && $0.source.y == $0.target.y })
                else { throw SemanticContractError.admission }
                // Every disjoint row pair independently satisfies the strict
                // ordered-cone secant admission that makes bisection unique.
                for row in stride(from: 0, to: points.count, by: 2) {
                    guard HorizontalInwardWarpSafety.accepts(Array(points[row..<row+2]), maximumSlope: 0.8) else {
                        throw SemanticContractError.admission
                    }
                    if row > 0 {
                        guard points[row].target.y - points[row].radius > points[row-2].target.y + points[row-2].radius else {
                            throw SemanticContractError.admission
                        }
                    }
                }
                let rendered = BeautyGeometryEffectPipeline.applyMVPProxy(to: canonical.ciImage,
                    canonicalImage: canonical, plan: plan, face: geometry)
                let output = try raster(rendered, size: size, context: context, color: color)
                if strength == 0, output.rgba != source.rgba { throw SemanticContractError.admission }
                let truth = try fullPairs.map { pair in try pair.map { p in
                    let moved = try forward(p[0], p[1], size: size, points: points)
                    return [moved[0] - Double(crop[0]), moved[1] - Double(crop[1])]
                } }
                var contraction = 0.0
                for (before, after) in zip(pairs, truth) {
                    contraction += (before[1][0] - before[0][0]) - (after[1][0] - after[0][0])
                }
                cases.append([
                    "width": crop[2] - crop[0], "height": crop[3] - crop[1], "full_image_width": size,
                    "crop": crop, "strength": Double(strength), "source": try RootSurfaceNative.rgb(source, box: crop),
                    "output": try RootSurfaceNative.rgb(output, box: crop), "pairs": pairs, "truth": truth,
                    "truth_mean_contraction_q16": contraction / Double(pairs.count) * 65536 / Double(size),
                    "truth_coordinate_tolerance": 0.001,
                    "pixel_model_max_error": try checkSampler(source: source, output: output, points: points, crop: crop),
                    "extent_preserved": true, "alpha_preserved": true, "named_srgb": true,
                    "neutral_identity": strength == 0 ? source.rgba == output.rgba : false
                ])
            }
        }
        return ["schema": "phase95-root-surface-generated-v1", "case_count": cases.count,
                "cases": cases, "private_source_accessed": false, "measurement_admitted": false]
    }
}
