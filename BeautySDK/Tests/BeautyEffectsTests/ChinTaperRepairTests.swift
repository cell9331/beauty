import CoreGraphics
import CoreImage
import Foundation
import XCTest
import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

final class ChinTaperRepairTests: XCTestCase {
    private let target = PPMRegion(minX: 330_000, maxX: 700_000, minY: 520_000, maxY: 620_000)
    private let upperFace = PPMRegion(minX: 250_000, maxX: 750_000, minY: 240_000, maxY: 400_000)
    private let mouth = PPMRegion(minX: 350_000, maxX: 650_000, minY: 400_000, maxY: 520_000)
    private let backgrounds = [
        PPMRegion(minX: 0, maxX: 200_000, minY: 80_000, maxY: 820_000),
        PPMRegion(minX: 800_000, maxX: 1_000_000, minY: 80_000, maxY: 820_000),
    ]
    private let watermark = PPMRegion(minX: 820_000, maxX: 980_000, minY: 920_000, maxY: 985_000)

    func testFACE02GeneratedGeometryEmitsPairedLowerChinBandAtExactCapAndHalfStrength() throws {
        XCTAssertEqual(BeautySafetyCaps.chinTaper, 0.25)
        let face = Self.face()
        let full = emission(face: face, strength: 0.25)
        let half = emission(face: face, strength: 0.125)
        let support = try XCTUnwrap(face.observedFaceSupport)
        let apexIndex = try XCTUnwrap(support.apexIndex)

        XCTAssertEqual(full.count, 6, "The two immediate apex neighbors are too weak for FACE-02.")
        XCTAssertEqual(half.map(\.source), full.map(\.source))
        XCTAssertEqual(full, emission(face: face, strength: 0.25))
        XCTAssertFalse(full.contains { $0.source == support.contour[apexIndex] })
        XCTAssertTrue(full.allSatisfy { $0.source.y == $0.target.y })

        let fullBySource = Dictionary(uniqueKeysWithValues: full.map { ($0.source, $0) })
        for halfPoint in half {
            let fullPoint = try XCTUnwrap(fullBySource[halfPoint.source])
            let axisX = try XCTUnwrap(Self.medianX(at: halfPoint.source.y, line: support.medianLine!))
            let fullDistance = abs(fullPoint.target.x - fullPoint.source.x)
            let halfDistance = abs(halfPoint.target.x - halfPoint.source.x)
            XCTAssertEqual(halfDistance, fullDistance / 2, accuracy: 0.000_001)
            XCTAssertLessThan(abs(fullPoint.target.x - axisX), abs(fullPoint.source.x - axisX))
            XCTAssertLessThan(abs(halfPoint.target.x - axisX), abs(halfPoint.source.x - axisX))
            XCTAssertLessThanOrEqual(fullDistance, 0.016 * face.bounds.width + 0.000_001)
            XCTAssertEqual(fullPoint.strength, 0.25)
            XCTAssertEqual(fullPoint.radius, face.bounds.width * 0.12, accuracy: 0.000_001)
            XCTAssertEqual(fullPoint.falloff, 2)
        }

        let reversedFace = Self.face(reversingContour: true)
        XCTAssertEqual(
            Set(emission(face: reversedFace, strength: 0.25).map(\.source)),
            Set(full.map(\.source))
        )
    }

    func testFACE02GeneratedCPURasterPassesFrozenSignalDirectionAndProtection() throws {
        let width = 512
        let height = 512
        let source = Self.fixtureBytes(width: width, height: height)
        let image = Self.image(bytes: source, width: width, height: height)
        let face = Self.face()
        let active = try render(image: image, face: face, parameters: BeautyParameters(chinTaper: 0.25))
        let repeated = try render(image: image, face: face, parameters: BeautyParameters(chinTaper: 0.25))
        let neutral = try render(image: image, face: face, parameters: BeautyParameters())

        XCTAssertEqual(neutral, source)
        XCTAssertEqual(active, repeated)

        let targetSignal = signal(source, active, width: width, height: height, regions: [target])
        XCTAssertGreaterThanOrEqual(targetSignal.changedPixels, 500)
        XCTAssertGreaterThanOrEqual(targetSignal.absoluteRGBDelta, 1_500)
        XCTAssertGreaterThanOrEqual(
            centerlineTaperQ16(active, width: width, height: height, regions: [target])
                - centerlineTaperQ16(source, width: width, height: height, regions: [target]),
            16
        )

        let outside = signal(source, active, width: width, height: height) { x, y in
            !target.contains(x: x, y: y, width: width, height: height)
        }
        XCTAssertLessThanOrEqual(outside.changedPixels, 256)
        XCTAssertLessThanOrEqual(outside.absoluteRGBDelta, 1_024)
        assertSignal(source, active, width: width, height: height, regions: [upperFace], maxChanged: 64, maxDelta: 256)
        assertSignal(source, active, width: width, height: height, regions: [mouth], maxChanged: 64, maxDelta: 256)
        assertSignal(source, active, width: width, height: height, regions: backgrounds, maxChanged: 0, maxDelta: 0)
        assertSignal(source, active, width: width, height: height, regions: [watermark], maxChanged: 0, maxDelta: 0)
        XCTAssertTrue(stride(from: 3, to: active.count, by: 4).allSatisfy { active[$0] == 255 })
    }

    func testFACE02InvalidCenterlineAndNamedSiblingIsolationFailClosed() {
        let valid = Self.face()
        let contour = valid.observedFaceSupport!.contour
        let invalidSupports: [BeautyFaceSemanticSupport?] = [
            nil,
            BeautyFaceSemanticSupport(contour: contour, medianLine: nil, apexIndex: 5),
            BeautyFaceSemanticSupport(contour: contour, medianLine: [.init(.nan, 0.5), .init(0.5, 0.7)], apexIndex: 5),
            BeautyFaceSemanticSupport(contour: contour, medianLine: [.init(0.5, 0.5)], apexIndex: 5),
            BeautyFaceSemanticSupport(contour: contour, medianLine: [.init(0.5, 0.5), .init(0.5, 0.7)], apexIndex: 0),
            BeautyFaceSemanticSupport(contour: contour, medianLine: [.init(0.5, 0.5), .init(0.5, 0.7)], apexIndex: contour.endIndex),
        ]

        for support in invalidSupports {
            let face = Self.replacingSupport(in: valid, with: support)
            XCTAssertTrue(emission(face: face, strength: 0.25).isEmpty)
        }
        for invalidStrength in [
            Float.zero, -0.25, Float.ulpOfOne, Float.ulpOfOne.nextDown,
            .leastNonzeroMagnitude, .nan, .infinity, -.infinity,
        ] {
            XCTAssertTrue(emission(face: valid, strength: invalidStrength).isEmpty)
        }

        XCTAssertEqual(
            emission(face: valid, strength: 1),
            emission(face: valid, strength: BeautySafetyCaps.chinTaper),
            "Provider-local callers cannot bypass the exact 0.25 cap."
        )

        var combined = BeautyEffectiveStrengths()
        combined.chinLength = -BeautySafetyCaps.chinLength
        combined.chinTaper = BeautySafetyCaps.chinTaper
        let provider = ChinWarpProvider()
        let emissions = provider.fieldEmissions(face: valid, strengths: combined)
        XCTAssertFalse(emissions.chinLength.isEmpty)
        XCTAssertFalse(emissions.chinTaper.isEmpty)
        XCTAssertTrue(emissions.chinTaper.allSatisfy { taper in
            emissions.chinLength.allSatisfy { $0.source != taper.source }
        })
        XCTAssertEqual(provider.fieldEmissions(face: valid, strengths: combined), emissions)
    }

    func testFACE02NarrowAndWideLowerChinBandsRemainPairedBoundedAndTraversalStable() throws {
        for scale: Float in [0.35, 1, 1.35] {
            let face = Self.face(bandScale: scale)
            let points = emission(face: face, strength: BeautySafetyCaps.chinTaper)
            let support = try XCTUnwrap(face.observedFaceSupport)

            XCTAssertEqual(points.count, 6, "band scale \(scale)")
            XCTAssertEqual(Set(points.map(\.source)).count, points.count, "band scale \(scale)")
            XCTAssertTrue(points.allSatisfy { point in
                guard let axis = Self.medianX(at: point.source.y, line: support.medianLine!) else {
                    return false
                }
                return point.source.y == point.target.y &&
                    abs(point.target.x - axis) < abs(point.source.x - axis) &&
                    abs(point.target.x - point.source.x) <= 0.016 * face.bounds.width + 0.000_001
            }, "band scale \(scale)")

            let reversed = Self.face(reversingContour: true, bandScale: scale)
            XCTAssertEqual(Set(emission(face: reversed, strength: 0.25).map(\.source)), Set(points.map(\.source)))
        }
    }

    func testFACE02QuantizationHostileBandFailsClosedWhenPairOwnershipIsIncomplete() {
        let valid = Self.face()
        let contour = valid.observedFaceSupport!.contour
        let apex = valid.observedFaceSupport!.apexIndex!

        var oneSided = contour
        oneSided[apex + 2].x = 0.49
        let oneSidedSupport = BeautyFaceSemanticSupport(
            contour: oneSided,
            medianLine: valid.observedFaceSupport!.medianLine,
            apexIndex: apex
        )
        XCTAssertTrue(emission(face: Self.replacingSupport(in: valid, with: oneSidedSupport), strength: 0.25).isEmpty)

        let uncoveredMedian = BeautyFaceSemanticSupport(
            contour: contour,
            medianLine: [.init(0.50, 0.50), .init(0.50, 0.58)],
            apexIndex: apex
        )
        XCTAssertTrue(emission(face: Self.replacingSupport(in: valid, with: uncoveredMedian), strength: 0.25).isEmpty)

        let shortContour = Array(contour[(apex - 2)...(apex + 2)])
        let shortSupport = BeautyFaceSemanticSupport(
            contour: shortContour,
            medianLine: valid.observedFaceSupport!.medianLine,
            apexIndex: 2
        )
        XCTAssertTrue(emission(face: Self.replacingSupport(in: valid, with: shortSupport), strength: 0.25).isEmpty)

        let contourOnly = FaceGeometry(
            bounds: valid.bounds,
            faceContour: contour,
            observedFaceSupport: nil
        )
        XCTAssertTrue(emission(face: contourOnly, strength: 0.25).isEmpty)
    }

    private func emission(face: FaceGeometry, strength: Float) -> [WarpControlPoint] {
        var strengths = BeautyEffectiveStrengths()
        strengths.chinTaper = strength
        return ChinWarpProvider().fieldEmissions(face: face, strengths: strengths).chinTaper
    }

    private func render(image: CIImage, face: FaceGeometry, parameters: BeautyParameters) throws -> [UInt8] {
        let plan = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: face)
        let output = BeautyGeometryEffectPipeline.applyMVPProxy(to: image, plan: plan, face: face)
        return Self.bytes(from: output, width: Int(image.extent.width), height: Int(image.extent.height))
    }

    private func assertSignal(
        _ source: [UInt8], _ candidate: [UInt8], width: Int, height: Int,
        regions: [PPMRegion], maxChanged: Int, maxDelta: Int,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let value = signal(source, candidate, width: width, height: height, regions: regions)
        XCTAssertLessThanOrEqual(value.changedPixels, maxChanged, file: file, line: line)
        XCTAssertLessThanOrEqual(value.absoluteRGBDelta, maxDelta, file: file, line: line)
    }

    private func signal(
        _ source: [UInt8], _ candidate: [UInt8], width: Int, height: Int,
        regions: [PPMRegion]
    ) -> Signal {
        signal(source, candidate, width: width, height: height) { x, y in
            regions.contains { $0.contains(x: x, y: y, width: width, height: height) }
        }
    }

    private func signal(
        _ source: [UInt8], _ candidate: [UInt8], width: Int, height: Int,
        include: (Int, Int) -> Bool
    ) -> Signal {
        var result = Signal()
        for y in 0..<height {
            for x in 0..<width where include(x, y) {
                let offset = (y * width + x) * 4
                let red = abs(Int(source[offset]) - Int(candidate[offset]))
                let green = abs(Int(source[offset + 1]) - Int(candidate[offset + 1]))
                let blue = abs(Int(source[offset + 2]) - Int(candidate[offset + 2]))
                if max(red, green, blue) > 2 { result.changedPixels += 1 }
                result.absoluteRGBDelta += red + green + blue
            }
        }
        return result
    }

    private func centerlineTaperQ16(
        _ bytes: [UInt8], width: Int, height: Int, regions: [PPMRegion]
    ) -> Int64 {
        var weight: Int64 = 0
        var weightedDistance: Int64 = 0
        for y in 0..<height {
            for x in 0..<width where regions.contains(where: { $0.contains(x: x, y: y, width: width, height: height) }) {
                let offset = (y * width + x) * 4
                let lumaQ8 = Int64(bytes[offset]) * 77 + Int64(bytes[offset + 1]) * 150 + Int64(bytes[offset + 2]) * 29
                let darkness = max(0, Int64(255 * 256) - lumaQ8)
                weight += darkness
                weightedDistance += darkness * abs(Int64(x * 2 + 1 - width))
            }
        }
        XCTAssertGreaterThan(weight, 0)
        return -(weightedDistance * 65_536 / (weight * Int64(width)))
    }

    private struct Signal {
        var changedPixels = 0
        var absoluteRGBDelta = 0
    }

    private struct PPMRegion {
        let minX: Int
        let maxX: Int
        let minY: Int
        let maxY: Int

        func contains(x: Int, y: Int, width: Int, height: Int) -> Bool {
            let xPPM = (x * 1_000_000) / width
            let yPPM = (y * 1_000_000) / height
            return minX <= xPPM && xPPM < maxX && minY <= yPPM && yPPM < maxY
        }
    }

    private static func face(
        reversingContour: Bool = false,
        bandScale: Float = 1
    ) -> FaceGeometry {
        var contour: [SIMD2<Float>] = [
            .init(0.50 - 0.22 * bandScale, 0.42),
            .init(0.50 - 0.18 * bandScale, 0.50),
            .init(0.50 - 0.14 * bandScale, 0.57),
            .init(0.50 - 0.10 * bandScale, 0.585),
            .init(0.499_88, 0.600),
            .init(0.50, 0.620),
            .init(0.500_12, 0.600),
            .init(0.50 + 0.10 * bandScale, 0.585),
            .init(0.50 + 0.14 * bandScale, 0.57),
            .init(0.50 + 0.18 * bandScale, 0.50),
            .init(0.50 + 0.22 * bandScale, 0.42),
        ]
        if reversingContour { contour.reverse() }
        let apexIndex = contour.firstIndex(of: .init(0.50, 0.620))!
        let support = BeautyFaceSemanticSupport(
            contour: contour,
            medianLine: [.init(0.50, 0.50), .init(0.50, 0.64)],
            apexIndex: apexIndex
        )
        return FaceGeometry(
            bounds: FaceBounds(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
            faceContour: contour,
            observedFaceSupport: support
        )
    }

    private static func replacingSupport(
        in face: FaceGeometry, with support: BeautyFaceSemanticSupport?
    ) -> FaceGeometry {
        FaceGeometry(
            bounds: face.bounds,
            faceContour: face.faceContour,
            observedFaceSupport: support,
            freshness: face.freshness
        )
    }

    private static func medianX(at y: Float, line: [SIMD2<Float>]) -> Float? {
        for (first, second) in zip(line, line.dropFirst()) {
            let lower = min(first.y, second.y)
            let upper = max(first.y, second.y)
            if lower <= y, y <= upper, abs(second.y - first.y) > Float.ulpOfOne {
                let progress = (y - first.y) / (second.y - first.y)
                return first.x + (second.x - first.x) * progress
            }
        }
        return nil
    }

    private static func fixtureBytes(width: Int, height: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let xPPM = x * 1_000_000 / width
                let yPPM = y * 1_000_000 / height
                let inChinInk = yPPM >= 535_000 && yPPM < 610_000 &&
                    ((xPPM >= 355_000 && xPPM < 455_000) || (xPPM >= 545_000 && xPPM < 665_000))
                if inChinInk {
                    let spatial = UInt8((x * 17 + y * 29) % 41)
                    bytes[offset] = 55 + spatial
                    bytes[offset + 1] = 68 + spatial
                    bytes[offset + 2] = 82 + spatial
                } else {
                    bytes[offset] = 255
                    bytes[offset + 1] = 255
                    bytes[offset + 2] = 255
                }
                bytes[offset + 3] = 255
            }
        }
        return bytes
    }

    private static func image(bytes: [UInt8], width: Int, height: Int) -> CIImage {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        return CIImage(
            bitmapData: Data(bytes), bytesPerRow: width * 4,
            size: CGSize(width: width, height: height), format: .RGBA8,
            colorSpace: colorSpace
        )
    }

    private static func bytes(from image: CIImage, width: Int, height: Int) -> [UInt8] {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        var output = [UInt8](repeating: 0, count: width * height * 4)
        context.render(
            image, toBitmap: &output, rowBytes: width * 4,
            bounds: CGRect(x: 0, y: 0, width: width, height: height),
            format: .RGBA8, colorSpace: colorSpace
        )
        return output
    }
}
