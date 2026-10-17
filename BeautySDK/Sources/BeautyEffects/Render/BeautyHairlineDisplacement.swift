import BeautyCore
import BeautyDetection
import Foundation

/// Source-qualified, two-dimensional still-image hairline candidate. A broad
/// dark-cap/forehead transition locates the source support; it is not a hair
/// segmentation or a claim that every hair/skin boundary was recovered.
/// The three tangent windows share one eye-frame radial anchor. Their shape
/// and symmetric endpoint response are engineering choices checked against
/// independent material correspondences, not identified reference-app internals.
enum BeautyHairlineDisplacement {
    private typealias Model = BeautyFaceDisplacementModel

    struct Support: Sendable {
        /// Request-local source coordinate, retained for scoped diagnostics.
        let sourceBoundaryY: Double
        fileprivate let windows: [BeautyFaceDisplacementModel.Window]
        fileprivate let protections: [BeautyFaceDisplacementModel.Protection]
    }

    static func prepare(sourceRGBA: [UInt8], width: Int, height: Int,
                        face: FaceGeometry,
                        geometry: BeautyFaceDisplacementGeometry) -> Support? {
        guard width > 4, height > 4,
              width <= BeautyConfiguration.defaultMaximumInputPixelCount / height,
              sourceRGBA.count == width * height * 4,
              stride(from: 3, to: sourceRGBA.count, by: 4).allSatisfy({ sourceRGBA[$0] == 255 }),
              face.freshness == .fresh,
              let brows = face.observedEyebrowSupport,
              let leftBrow = brows.left, let rightBrow = brows.right,
              leftBrow.side == .left, rightBrow.side == .right,
              let leftEye = face.leftEyeSupport, let rightEye = face.rightEyeSupport
        else { return nil }

        func local(_ p: SIMD2<Float>) -> SIMD2<Double>? {
            guard p.x.isFinite, p.y.isFinite, (0...1).contains(p.x), (0...1).contains(p.y) else { return nil }
            return geometry.local(SIMD2(Double(p.x) * Double(width) - 0.5,
                                        Double(p.y) * Double(height) - 0.5))
        }
        let left = leftBrow.points.compactMap(local), right = rightBrow.points.compactMap(local)
        guard (3...32).contains(left.count), (3...32).contains(right.count),
              left.count == leftBrow.points.count, right.count == rightBrow.points.count,
              Set(leftBrow.points).count >= 3, Set(rightBrow.points).count >= 3,
              left.allSatisfy({ $0.x < -0.05 && $0.x > -1.5 && $0.y > -0.85 && $0.y < -0.04 }),
              right.allSatisfy({ $0.x > 0.05 && $0.x < 1.5 && $0.y > -0.85 && $0.y < -0.04 }),
              let browTop = (left + right).map(\.y).min()
        else { return nil }

        func luminance(_ p: SIMD2<Double>) -> Double? {
            let image = geometry.image(p)
            guard image.x.isFinite, image.y.isFinite,
                  image.x >= 1, image.y >= 1,
                  image.x <= Double(width - 2), image.y <= Double(height - 2) else { return nil }
            let i = (Int(image.y.rounded()) * width + Int(image.x.rounded())) * 4
            return (0.2126 * Double(sourceRGBA[i]) + 0.7152 * Double(sourceRGBA[i + 1]) +
                    0.0722 * Double(sourceRGBA[i + 2])) / 255
        }
        func row(_ y: Double) -> Double? {
            var samples = [Double]()
            for column in 0...30 {
                guard let value = luminance(SIMD2(-0.45 + Double(column) * 0.03, y)) else { return nil }
                samples.append(value)
            }
            return median(samples)
        }
        // Skin-side colour is learned from the registered upper forehead,
        // above the observed brows. No fixed RGB skin class is used.
        var skinRows = [Double]()
        for index in 0...6 {
            guard let value = row(browTop - 0.28 + Double(index) * 0.02) else { return nil }
            skinRows.append(value)
        }
        let skin = median(skinRows)
        guard skin > 0.15, (skinRows.max()! - skinRows.min()!) < skin * 0.25 else { return nil }
        let lowY = browTop - 2.05, highY = browTop - 0.22
        let count = Int(floor((highY - lowY) / 0.02)) + 1
        var rows = [Double]()
        for index in 0..<count {
            guard let value = row(lowY + Double(index) * 0.02) else { return nil }
            rows.append(value)
        }
        let threshold = skin * 0.62
        var candidates = [Int]()
        for index in 6..<(count - 6) {
            guard rows[index] >= threshold,
                  median(Array(rows[(index - 6)..<index])) < threshold,
                  median(Array(rows[index..<(index + 6)])) > threshold else { continue }
            if candidates.last.map({ index - $0 > 6 }) ?? true { candidates.append(index) }
        }
        // A second separated, sustained transition is ambiguous. Rejection
        // disables this component and never revives the former point/narrow-band warp.
        guard candidates.count == 1, let crossing = candidates.first else { return nil }
        let boundary = lowY + Double(crossing) * 0.02
        guard boundary > -1.80, boundary < -0.65,
              boundary + 0.30 < browTop - 0.08 else { return nil }
        var dark = [Double](), light = [Double]()
        for index in 0...6 {
            guard let upper = row(boundary - 0.25 + Double(index) * 0.025),
                  let lower = row(boundary + 0.10 + Double(index) * 0.025) else { return nil }
            dark.append(upper); light.append(lower)
        }
        guard median(dark) < skin * 0.70, median(light) > skin * 0.80,
              median(light) - median(dark) > max(0.06, skin * 0.25) else { return nil }

        // The measured material field has an arched peak, not an axis-aligned
        // vertical strip. Three overlapping tangent windows are the fixed,
        // low-dimensional approximation used for this initial implementation.
        let radius = -boundary + 0.10
        var windows = [Model.Window]()
        for sign in [-1.0, 0.0, 1.0] {
            let angle = sign * 0.71
            let tangent = SIMD2(cos(angle), sin(angle))
            let normal = SIMD2(-sin(angle), cos(angle))
            let support = Model.Window(center: SIMD2(radius * sin(angle), -radius * cos(angle)),
                axisX: tangent, axisY: normal, radius: SIMD2(1.00, 0.59))
            guard contained(support, geometry: geometry, width: width, height: height) else { return nil }
            windows.append(support)
        }
        var protections = [Model.Protection]()
        for points in [left, right, leftEye.contour.compactMap(local), rightEye.contour.compactMap(local)] {
            guard let protection = coreProtection(points) else { return nil }
            protections.append(protection)
        }
        guard let lateral = lateralProtections(contour: geometry.normalizedContour, windows: windows) else { return nil }
        protections.append(contentsOf: lateral)
        return Support(sourceBoundaryY: boundary, windows: windows, protections: protections)
    }

    static func component(support: Support, amount: Double) -> BeautyFaceDisplacementModel.Component? {
        guard amount.isFinite, (-1...1).contains(amount), support.windows.count == 3 else { return nil }
        // Endpoint-pair material fitting seeds these rounded coefficients.
        // ±amount is a deliberate symmetric SDK response; no reference zero
        // or intermediate response was available to measure that symmetry.
        let radial = 0.046 * amount
        let modes = support.windows.enumerated().map { index, window in
            let coefficient = -radial * (index == 1 ? 1 : 0.76)
            return Model.Mode.affine(weight: window, anchor: .zero,
                scale: SIMD2(repeating: coefficient), translation: .zero)
        }
        return Model.Component(modes: modes, protections: support.protections)
    }

    private static func coreProtection(_ points: [SIMD2<Double>]) -> Model.Protection? {
        guard points.count >= 3,
              points.allSatisfy({ $0.x.isFinite && $0.y.isFinite }),
              let minX = points.map(\.x).min(), let maxX = points.map(\.x).max(),
              let minY = points.map(\.y).min(), let maxY = points.map(\.y).max(),
              maxX - minX > 0.04 else { return nil }
        let center = SIMD2((minX + maxX) * 0.5, (minY + maxY) * 0.5)
        let radius = SIMD2(max(0.06, (maxX - minX) * 0.5) + 0.025,
                           max(0.025, (maxY - minY) * 0.5) + 0.02)
        let window = Model.Window(center: center, axisX: SIMD2(1, 0), axisY: SIMD2(0, 1), radius: radius)
        return Model.Protection(window: window, innerFraction: 0.60)
    }

    /// Source anatomy owns the lateral release independently of the three
    /// material-motion peaks. A contour-relative 0.15...0.40 eye-distance
    /// transition preserves the central/side peaks while returning the outer
    /// weak tails to exact identity. These margins are engineering defaults,
    /// not inferred hair segmentation or source-image pixel coordinates.
    private static func lateralProtections(contour: [SIMD2<Double>],
                                            windows: [Model.Window]) -> [Model.Protection]? {
        guard let left = contour.map(\.x).min(), let right = contour.map(\.x).max(),
              left.isFinite, right.isFinite, left < 0, right > 0,
              let minX = windows.map({ $0.bounds.minimum.x }).min(),
              let maxX = windows.map({ $0.bounds.maximum.x }).max(),
              let minY = windows.map({ $0.bounds.minimum.y }).min(),
              let maxY = windows.map({ $0.bounds.maximum.y }).max() else { return nil }
        let fraction = 0.75
        let radiusX = (0.40 - 0.15) / (1 - fraction)
        let centerY = (minY + maxY) * 0.5
        // The vertical plateau contains every original mode, so this factor
        // is purely lateral wherever the component can move source material.
        let radiusY = ((maxY - minY) * 0.5 + 0.05) / fraction
        var result = [Model.Protection]()
        for side in [-1.0, 1.0] {
            let edge = side < 0 ? left : right
            let fixedEdge = edge + side * 0.40
            let centerX = fixedEdge + side * fraction * radiusX
            // An outer plateau must cover the complete original support;
            // otherwise a finite protection could release a distant tail.
            let coversOuterSupport = side < 0 ? centerX - fraction * radiusX <= minX
                                             : centerX + fraction * radiusX >= maxX
            guard coversOuterSupport else { return nil }
            let window = Model.Window(center: SIMD2(centerX, centerY),
                axisX: SIMD2(1, 0), axisY: SIMD2(0, 1), radius: SIMD2(radiusX, radiusY))
            result.append(Model.Protection(window: window, innerFraction: fraction))
        }
        // These mathematical protection supports may extend beyond the image;
        // only the original, image-contained motion windows are sampled. All
        // product derivatives remain part of the model's existing certificate.
        return result
    }

    private static func contained(_ support: Model.Window,
                                  geometry: BeautyFaceDisplacementGeometry,
                                  width: Int, height: Int) -> Bool {
        for x in [-1.0, 1.0] { for y in [-1.0, 1.0] {
            let point = geometry.image(support.center + support.axisX * (support.radius.x * x) +
                                       support.axisY * (support.radius.y * y))
            guard point.x >= 1, point.x <= Double(width - 2),
                  point.y >= 1, point.y <= Double(height - 2) else { return false }
        } }
        return true
    }

    private static func median(_ values: [Double]) -> Double {
        let ordered = values.sorted(), middle = values.count / 2
        return values.count % 2 == 0 ? (ordered[middle - 1] + ordered[middle]) * 0.5 : ordered[middle]
    }
}
