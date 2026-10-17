import BeautyCore
import Foundation

/// The reference-derived face controls share one source-coordinate field
/// and one inverse sample. They do not reuse the legacy contour pull or the
/// RGB-boundary smoother. Amplitudes remain reviewable engineering parameters;
/// the endpoint comparison does not establish a reference-app neutral response.
struct BeautyFaceDisplacementMap: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    static var keys: [WritableKeyPath<BeautyEffectiveStrengths, Float>] {
        [\.faceSlim, \.faceSmall, \.faceContourSmooth, \.templeFullness,
         \.cheekboneSlim, \.chinLength, \.chinTaper, \.faceVShape, \.jawSlim, \.hairlineHeight]
    }

    private let width: Int
    private let height: Int
    let geometry: BeautyFaceDisplacementGeometry
    let model: BeautyFaceDisplacementModel
    private let columns: ClosedRange<Int>
    private let rows: ClosedRange<Int>

    var maximumGradient: Double { model.gradientBound }
    var amplitudeScale: Double { model.amplitudeScale }
    var maximumDisplacement: Double { model.maximumDisplacement * geometry.scale }

    init?(width: Int, height: Int, face: FaceGeometry, strengths: BeautyEffectiveStrengths,
          sourceRGBA: [UInt8]? = nil) {
        guard Self.keys.contains(where: { strengths[keyPath: $0] != 0 }),
              Self.keys.allSatisfy({ strengths[keyPath: $0].isFinite }),
              let geometry = BeautyFaceDisplacementGeometry(width: width, height: height, face: face) else { return nil }
        let hairlineSupport = strengths.hairlineHeight != 0 ? sourceRGBA.flatMap {
            BeautyHairlineDisplacement.prepare(sourceRGBA: $0, width: width, height: height,
                                              face: face, geometry: geometry)
        } : nil
        guard let model = geometry.model(strengths: strengths, hairlineSupport: hairlineSupport),
              !model.isIdentity else { return nil }
        let bounds = model.bounds
        let corners = [SIMD2(bounds.minimum.x, bounds.minimum.y),
                       SIMD2(bounds.minimum.x, bounds.maximum.y),
                       SIMD2(bounds.maximum.x, bounds.minimum.y),
                       SIMD2(bounds.maximum.x, bounds.maximum.y)].map(geometry.image)
        guard corners.allSatisfy({ $0.x.isFinite && $0.y.isFinite }) else { return nil }
        let x0 = max(0, Int(floor(corners.map(\.x).min()!)))
        let x1 = min(width - 1, Int(ceil(corners.map(\.x).max()!)))
        let y0 = max(0, Int(floor(corners.map(\.y).min()!)))
        let y1 = min(height - 1, Int(ceil(corners.map(\.y).max()!)))
        guard x0 <= x1, y0 <= y1 else { return nil }
        self.width = width; self.height = height
        self.geometry = geometry; self.model = model
        columns = x0...x1; rows = y0...y1
    }

    func forwardDisplacement(at sourcePixel: SIMD2<Double>) -> SIMD2<Double> {
        let d = model.sample(at: geometry.local(sourcePixel)).displacement
        return geometry.scale * (geometry.axisX * d.x + geometry.axisY * d.y)
    }

    func sourcePoint(for destinationPixel: SIMD2<Double>) -> SIMD2<Double>? {
        // A fixed pixel tolerance also has a declared normalized tolerance.
        guard let local = model.inverse(of: geometry.local(destinationPixel),
                                        tolerance: 1e-4 / geometry.scale) else { return nil }
        let source = geometry.image(local)
        guard source.x.isFinite, source.y.isFinite,
              source.x >= 0, source.y >= 0,
              source.x <= Double(width - 1), source.y <= Double(height - 1) else { return nil }
        return source
    }

    func applyRGBA(_ source: [UInt8]) -> [UInt8] {
        guard source.count == width * height * 4,
              stride(from: 3, to: source.count, by: 4).allSatisfy({ source[$0] == 255 }) else { return source }
        var output = source
        for y in rows { for x in columns {
            let target = SIMD2(Double(x), Double(y))
            let local = geometry.local(target)
            // Outside every compact source support the globally bijective map
            // is exactly identity. Keep original bytes, including exact cores.
            if model.sample(at: local).displacement == .zero { continue }
            guard let p = sourcePoint(for: target) else { return source }
            let x0 = Int(floor(p.x)), y0 = Int(floor(p.y))
            guard x0 >= 0, y0 >= 0, x0 + 1 < width, y0 + 1 < height else { return source }
            let tx = p.x - Double(x0), ty = p.y - Double(y0)
            let a = (y0 * width + x0) * 4, b = a + 4
            let c = a + width * 4, d = c + 4
            let index = (y * width + x) * 4
            for channel in 0..<3 {
                let upper = Double(source[a + channel]) * (1 - tx) + Double(source[b + channel]) * tx
                let lower = Double(source[c + channel]) * (1 - tx) + Double(source[d + channel]) * tx
                output[index + channel] = UInt8(clamping: Int((upper * (1 - ty) + lower * ty).rounded()))
            }
            // The admitted source and all interpolation taps are opaque.
            output[index + 3] = 255
        } }
        return output
    }

    var description: String { "BeautyFaceDisplacementMap(width: \(width), height: \(height))" }
    var debugDescription: String { description }
    var customMirror: Mirror {
        Mirror(self, children: ["width": width, "height": height], displayStyle: .struct)
    }
}
