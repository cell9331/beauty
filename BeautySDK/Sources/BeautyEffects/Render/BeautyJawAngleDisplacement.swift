import Foundation

/// Two source-fixed lower-side fields. Reference endpoint correspondences
/// support a near-constant inward/upward direction and a broad local envelope;
/// they do not identify the editor's neutral or a unique closed-source formula.
enum BeautyJawAngleDisplacement {
    private typealias Model = BeautyFaceDisplacementModel

    /// All positions use the admitted eye-distance frame (x right/y down).
    /// The caller owns observed geometry, exact facial cores, pose scaling and
    /// complete image-domain admission of each window. Hair is allowed to follow
    /// the same local field; no binary hair/skin mask truncates its transition.
    ///
    /// Shared shape/amplitude defaults were calibrated against existing source-
    /// material endpoint matches. A symmetric signed neutral split is an
    /// engineering choice. The complete Model certifies the sum and solves the
    /// true inverse; no local seed projection or q-d(q) approximation is added.
    static func component(
        contour: [SIMD2<Double>], chin: SIMD2<Double>, amount: Double,
        protections: [BeautyFaceDisplacementModel.Protection],
        supported: (BeautyFaceDisplacementModel.Window) -> Bool
    ) -> BeautyFaceDisplacementModel.Component? {
        guard amount.isFinite, abs(amount) <= 1,
              (7...32).contains(contour.count),
              contour.allSatisfy(finite), finite(chin),
              chin.y > 0.65, chin.y < 3.5,
              let apex = contour.indices.max(by: { contour[$0].y < contour[$1].y }),
              apex >= 2, apex <= contour.count - 3,
              hypot((contour[apex] - chin).x, (contour[apex] - chin).y) <= 1e-8
        else { return nil }

        let peakY = chin.y * 0.639
        var modes = [Model.Mode]()
        for side in [-1.0, 1.0] {
            guard var center = point(contour: contour, apex: apex, side: side, y: peakY)
            else { return nil }
            center.x -= side * 0.024
            let halfWidth = abs(center.x - chin.x) * 0.605
            guard halfWidth > 0.08, side * (center.x - chin.x) > halfWidth else { return nil }
            let support = Model.Window(center: center, axisX: SIMD2(1, 0), axisY: SIMD2(0, 1),
                                       radius: SIMD2(halfWidth, chin.y * 0.332))
            guard supported(support) else { return nil }
            modes.append(.vector(weight: support,
                displacement: SIMD2(-side * 0.023 * amount, -1.35 * 0.023 * amount)))
        }
        return Model.Component(modes: modes, protections: protections)
    }

    private static func point(contour: [SIMD2<Double>], apex: Int,
                              side: Double, y: Double) -> SIMD2<Double>? {
        let path = side < 0 ? Array(contour[...apex]) : Array(contour[apex...].reversed())
        for index in 0..<(path.count - 1) {
            let a = path[index], b = path[index + 1]
            if a.y <= y, b.y >= y, b.y - a.y > 1e-8 {
                return a + (b - a) * ((y - a.y) / (b.y - a.y))
            }
        }
        return nil
    }

    private static func finite(_ p: SIMD2<Double>) -> Bool { p.x.isFinite && p.y.isFinite }
}
