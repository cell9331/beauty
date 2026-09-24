import BeautyDetection

/// The observed open contour owns two outer sides. The middle chin arc is not
/// part of FACE-01's lateral correction.
enum FaceContourLateralRuns {
    struct Run {
        let indices: [Int]
        let ordered: [SIMD2<Float>]
    }

    static func make(
        from contour: [SIMD2<Float>],
        centralExclusionFraction: Float = 1 / 6
    ) -> [Run]? {
        guard contour.count >= 10,
              centralExclusionFraction.isFinite,
              centralExclusionFraction > 0,
              centralExclusionFraction < 0.5,
              contour.allSatisfy({
                  $0.x.isFinite && $0.y.isFinite &&
                      (0...1).contains($0.x) && (0...1).contains($0.y)
              }),
              let minimumX = contour.map(\.x).min(),
              let maximumX = contour.map(\.x).max()
        else { return nil }

        let span = maximumX - minimumX
        guard span.isFinite, span > 0 else { return nil }
        let center = (minimumX + maximumX) / 2
        let leftLimit = center - span * centralExclusionFraction
        let rightLimit = center + span * centralExclusionFraction
        let left = contour.indices.filter { contour[$0].x <= leftLimit }
        let right = contour.indices.filter { contour[$0].x >= rightLimit }
        guard let leftRun = makeRun(left, contour: contour),
              let rightRun = makeRun(right, contour: contour),
              Set(left).isDisjoint(with: right)
        else { return nil }
        return [leftRun, rightRun]
    }

    private static func makeRun(_ indices: [Int], contour: [SIMD2<Float>]) -> Run? {
        guard indices.count >= 4,
              let first = indices.first,
              let last = indices.last,
              last - first + 1 == indices.count
        else { return nil }
        let values = indices.map { contour[$0] }
        let increasing = values[1].y > values[0].y
        guard zip(values, values.dropFirst()).allSatisfy({ pair in
            increasing ? pair.1.y > pair.0.y : pair.1.y < pair.0.y
        }) else { return nil }
        return Run(indices: indices, ordered: increasing ? values : Array(values.reversed()))
    }
}
