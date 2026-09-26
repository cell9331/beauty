import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import XCTest
@_spi(Testing) import BeautySDK

final class GeneratedContourPublicOracleTests: XCTestCase {
    func testFACE01StylizedRoughBoundaryImprovesThroughPublicFacade() throws {
        let width = 1_000
        let height = 1_000
        let source = Self.portraitLikeFixture(width: width, height: height)
        let image = Self.image(source, width: width, height: height)
        let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
        let parameters = BeautyParameters(faceContourSmooth: 0.25)
        let engine = try BeautyEngine(faceDetectionProvider: SDKTestingFaceDetectionProvider([
            .usableFace, .usableFace,
        ]))
        let neutral = try BeautyEngine(faceDetectionProvider: SDKTestingFaceDetectionProvider([
            .usableFace,
        ])).processResult(image: image, metadata: metadata, parameters: .init())

        let first = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
        let repeated = try engine.processResult(image: image, metadata: metadata, parameters: parameters)
        let candidate = Self.bytes(first.output, width: width, height: height)
        let sourceRoughness = try Self.portraitBoundaryRoughness(source, width: width, height: height)
        let candidateRoughness = try Self.portraitBoundaryRoughness(candidate, width: width, height: height)

        XCTAssertGreaterThan(sourceRoughness, 0.5)
        XCTAssertLessThan(candidateRoughness, sourceRoughness / 2)
        XCTAssertEqual(Self.bytes(neutral.output, width: width, height: height), source)
        XCTAssertEqual(candidate, Self.bytes(repeated.output, width: width, height: height))
        XCTAssertEqual(first.output.extent, image.extent)
        // Geometry-only still images currently take the documented legacy CI path.
        XCTAssertEqual(first.output.colorSpace?.name, CGColorSpaceCreateDeviceRGB().name)
        XCTAssertEqual(Self.changedPixels(source, candidate, width: width, height: height) { x, _ in
            (0.46..<0.54).contains(Double(x) / Double(width)) || x < width / 5 || x >= width * 4 / 5
        }, 0)
        XCTAssertGreaterThan(Self.changedPixels(source, candidate, width: width, height: height) { x, y in
            (0.25..<0.75).contains(Double(x) / Double(width)) &&
                (0.30..<0.75).contains(Double(y) / Double(height))
        }, 0)
        XCTAssertEqual(Self.changedPixels(source, candidate, width: width, height: height) { x, y in
            !(0.25..<0.75).contains(Double(x) / Double(width)) ||
                !(0.30..<0.75).contains(Double(y) / Double(height))
        }, 0)
        XCTAssertTrue(stride(from: 3, to: candidate.count, by: 4).allSatisfy { candidate[$0] == 255 })
        assertRedacted(first)
    }

    func testFACE01StylizedSmoothFaceNegativeDoesNotWorsen() throws {
        let width = 1_000
        let height = 1_000
        let source = Self.portraitLikeFixture(
            width: width, height: height, contour: Self.smoothPortraitContour
        )
        let image = Self.image(source, width: width, height: height)
        let engine = try BeautyEngine(faceDetectionProvider: SDKTestingFaceDetectionProvider([
            .smoothObservedFaceContour,
        ]))
        let result = try engine.processResult(
            image: image,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: BeautyParameters(faceContourSmooth: 0.25)
        )
        let candidate = Self.bytes(result.output, width: width, height: height)
        let sourceRoughness = try Self.portraitBoundaryRoughness(
            source, width: width, height: height, contour: Self.smoothPortraitContour
        )
        let candidateRoughness = try Self.portraitBoundaryRoughness(
            candidate, width: width, height: height, contour: Self.smoothPortraitContour
        )
        XCTAssertLessThan(sourceRoughness, 0.1)
        XCTAssertLessThanOrEqual(candidateRoughness, sourceRoughness + 0.05)
        XCTAssertEqual(candidate, source)
        XCTAssertEqual(result.output.extent, image.extent)
    }

    private func assertRedacted(_ result: BeautyResult<CIImage>) {
        let text = (
            result.warnings.map { "\($0.code) \($0.message)" } +
            Array(result.metrics.keys) +
            (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
        ).joined(separator: " ").lowercased()
        for forbidden in ["landmark", "coordinate", "controlpoint", "simd", "contour", "pixel", "/private/"] {
            XCTAssertFalse(text.contains(forbidden), forbidden)
        }
    }

    private static let portraitContour: [CGPoint] = [
        .init(x: 0.025, y: 0.733333333), .init(x: 0, y: 0.6),
        .init(x: 0.0625, y: 0.466666667), .init(x: 0.125, y: 0.3),
        .init(x: 0.2875, y: 0.116666667), .init(x: 0.5125, y: 0),
        .init(x: 0.7125, y: 0.15), .init(x: 0.85, y: 0.333333333),
        .init(x: 0.9375, y: 0.516666667), .init(x: 1, y: 0.65),
        .init(x: 0.95, y: 0.766666667),
    ]

    private static let smoothPortraitContour: [CGPoint] = [
        .init(x: 0.05, y: 0.733333333), .init(x: 0.05, y: 0.6),
        .init(x: 0.05, y: 0.466666667), .init(x: 0.05, y: 0.3),
        .init(x: 0.05, y: 0.116666667), .init(x: 0.5, y: 0),
        .init(x: 0.95, y: 0.15), .init(x: 0.95, y: 0.333333333),
        .init(x: 0.95, y: 0.516666667), .init(x: 0.95, y: 0.65),
        .init(x: 0.95, y: 0.766666667),
    ]

    private static func portraitEdge(
        y: Double, right: Bool, contour: [CGPoint] = portraitContour
    ) -> Double? {
        let side = right ? Array(contour[5...]) : Array(contour[...5])
        let points = side.map { point in
            CGPoint(x: 0.3 + 0.4 * point.x, y: 0.8 - 0.6 * point.y)
        }.sorted { $0.y < $1.y }
        guard let first = points.first, let last = points.last,
              y >= first.y, y <= last.y else { return nil }
        for (a, b) in zip(points, points.dropFirst()) where y >= a.y && y <= b.y {
            let t = (y - a.y) / (b.y - a.y)
            return a.x + t * (b.x - a.x)
        }
        return nil
    }

    private static func portraitLikeFixture(
        width: Int, height: Int, contour: [CGPoint] = portraitContour
    ) -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for row in 0..<height {
            let y = (Double(row) + 0.5) / Double(height)
            let left = portraitEdge(y: y, right: false, contour: contour)
            let right = portraitEdge(y: y, right: true, contour: contour)
            for column in 0..<width {
                let x = (Double(column) + 0.5) / Double(width)
                let inside = left.map { x >= $0 } == true && right.map { x <= $0 } == true
                let offset = (row * width + column) * 4
                if inside {
                    let eye = (pow((x - 0.42) / 0.022, 2) + pow((y - 0.43) / 0.012, 2) < 1)
                        || (pow((x - 0.58) / 0.022, 2) + pow((y - 0.43) / 0.012, 2) < 1)
                    let mouth = pow((x - 0.5) / 0.045, 2) + pow((y - 0.67) / 0.008, 2) < 1
                    let value: UInt8 = eye || mouth ? 40 : 80
                    bytes[offset] = value
                    bytes[offset + 1] = eye || mouth ? 40 : 115
                    bytes[offset + 2] = eye || mouth ? 40 : 140
                } else {
                    bytes[offset] = 220
                    bytes[offset + 1] = 220
                    bytes[offset + 2] = 220
                }
            }
        }
        return bytes
    }

    private static func portraitBoundaryRoughness(
        _ bytes: [UInt8], width: Int, height: Int,
        contour: [CGPoint] = portraitContour
    ) throws -> Double {
        var total = 0.0
        var count = 0
        for right in [false, true] {
            var edges: [Double] = []
            for row in Int(0.40 * Double(height))..<Int(0.68 * Double(height)) {
                let y = (Double(row) + 0.5) / Double(height)
                let reference = try XCTUnwrap(portraitEdge(y: y, right: right, contour: contour))
                let center = Int((reference * Double(width)).rounded())
                var edge: Double?
                for column in max(0, center - 12)..<min(width - 1, center + 12) {
                    let a = Double(bytes[(row * width + column) * 4])
                    let b = Double(bytes[(row * width + column + 1) * 4])
                    if right ? (a <= 150 && b > 150) : (a > 150 && b <= 150) {
                        edge = Double(column) + (150 - a) / (b - a)
                        break
                    }
                }
                edges.append(try XCTUnwrap(edge))
            }
            for index in 1..<(edges.count - 1) {
                total += abs(edges[index - 1] + edges[index + 1] - 2 * edges[index])
                count += 1
            }
        }
        return total / Double(count)
    }

    private static func image(_ bytes: [UInt8], width: Int, height: Int) -> CIImage {
        CIImage(
            bitmapData: Data(bytes),
            bytesPerRow: width * 4,
            size: CGSize(width: width, height: height),
            format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }

    private static func bytes(_ image: CIImage, width: Int, height: Int) -> [UInt8] {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        bytes.withUnsafeMutableBytes { raw in
            context.render(
                image,
                toBitmap: raw.baseAddress!,
                rowBytes: width * 4,
                bounds: image.extent,
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }
        return bytes
    }

    private static func changedPixels(
        _ lhs: [UInt8], _ rhs: [UInt8], width: Int, height: Int,
        include: (Int, Int) -> Bool
    ) -> Int {
        var count = 0
        for y in 0..<height {
            for x in 0..<width where include(x, y) {
                let i = (y * width + x) * 4
                if (0..<3).contains(where: { abs(Int(lhs[i + $0]) - Int(rhs[i + $0])) > 2 }) {
                    count += 1
                }
            }
        }
        return count
    }
}
