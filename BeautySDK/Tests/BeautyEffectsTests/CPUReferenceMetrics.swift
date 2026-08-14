import Foundation
import simd

/// Transient, aggregate-only measurements shared by CPU reference tests.
struct CPUReferenceMetrics {
    static func changedIndices(before: [UInt8], after: [UInt8]) -> Set<Int> {
        guard before.count == after.count else { return [] }
        return stride(from: 0, to: before.count, by: 4).compactMap { offset in
            let changed = (0..<4).contains { before[offset + $0] != after[offset + $0] }
            return changed ? offset / 4 : nil
        }.reduce(into: Set<Int>()) { $0.insert($1) }
    }

    static func alphaValues(in rgba8: [UInt8]) -> [UInt8] {
        stride(from: 3, to: rgba8.count, by: 4).map { rgba8[$0] }
    }

    static func alphaPreserved(before: [UInt8], after: [UInt8]) -> Bool {
        alphaValues(in: before) == alphaValues(in: after)
    }

    static func luminance(of rgba8: [UInt8], at pixel: Int) -> Double {
        let offset = pixel * 4
        guard rgba8.indices.contains(offset + 2) else { return .nan }
        return 0.2126 * Double(rgba8[offset])
            + 0.7152 * Double(rgba8[offset + 1])
            + 0.0722 * Double(rgba8[offset + 2])
    }

    static func meanLuminance(of rgba8: [UInt8], indices: Set<Int>? = nil) -> Double {
        let pixels = indices ?? Set(0..<(rgba8.count / 4))
        guard pixels.isEmpty == false else { return 0 }
        return pixels.map { luminance(of: rgba8, at: $0) }.reduce(0, +) / Double(pixels.count)
    }

    static func chroma(of rgba8: [UInt8], at pixel: Int) -> Double {
        let offset = pixel * 4
        guard rgba8.indices.contains(offset + 2) else { return .nan }
        let channels = [Double(rgba8[offset]), Double(rgba8[offset + 1]), Double(rgba8[offset + 2])]
        return (channels.max() ?? 0) - (channels.min() ?? 0)
    }

    static func redExcess(of rgba8: [UInt8], at pixel: Int) -> Double {
        let offset = pixel * 4
        guard rgba8.indices.contains(offset + 2) else { return .nan }
        return Double(rgba8[offset]) - 0.83 * Double(rgba8[offset + 1]) - 0.17 * Double(rgba8[offset + 2])
    }

    static func yellowExcess(of rgba8: [UInt8], at pixel: Int) -> Double {
        let offset = pixel * 4
        guard rgba8.indices.contains(offset + 2) else { return .nan }
        return 0.5 * (Double(rgba8[offset]) + Double(rgba8[offset + 1])) - Double(rgba8[offset + 2])
    }

    static func regionIntersection(_ lhs: Set<Int>, _ rhs: Set<Int>) -> Set<Int> {
        lhs.intersection(rhs)
    }

    static func direction(from source: SIMD2<Float>, to target: SIMD2<Float>) -> SIMD2<Float> {
        target - source
    }

    static func displacement(from source: SIMD2<Float>, to target: SIMD2<Float>) -> Float {
        simd_distance(source, target)
    }

    static func signedDirection(from source: SIMD2<Float>, to target: SIMD2<Float>, axis: SIMD2<Float>) -> Float {
        simd_dot(target - source, axis)
    }

    static func isFiniteNormalized(_ point: SIMD2<Float>) -> Bool {
        point.x.isFinite && point.y.isFinite && (0...1).contains(point.x) && (0...1).contains(point.y)
    }
}

struct CPUReference {
    static func pixelCount(_ rgba8: [UInt8]) -> Int { rgba8.count / 4 }
    static func extent(width: Int, height: Int) -> CGRect { CGRect(x: 0, y: 0, width: width, height: height) }
}
