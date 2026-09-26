import Foundation
import XCTest
@testable import BeautyEffects

final class ObservedCheekBoundaryRefinementTests: XCTestCase {
    private let width = 800
    private let height = 800
    private let face = FaceGeometry.phase46AsymmetricComplete

    func testOffsetRoughCheekBoundaryImprovesWithoutTouchingEarCenterOrAlpha() throws {
        let source = try image(wavy: true)
        let neutral = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0
        )
        let candidate = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )
        let repeated = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )

        XCTAssertTrue(neutral == source, "neutral output differs from source")
        XCTAssertTrue(candidate == repeated, "repeated output differs")
        for left in [true, false] {
            let before = try roughness(source, left: left)
            let after = try roughness(candidate, left: left)
            XCTAssertGreaterThan(before, 0.5)
            XCTAssertLessThan(after, before * 0.90)
        }
        XCTAssertGreaterThan(changed(source, candidate) { _, _ in true }, 0)
        XCTAssertEqual(changed(source, candidate) { x, y in
            y < Int(0.50 * Double(height)) ||
                (0.44..<0.56).contains(Double(x) / Double(width)) ||
                x < width / 8 || x >= width * 7 / 8
        }, 0)
        XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy {
            source[$0] == candidate[$0]
        })
    }

    func testSmoothCheekNegativeDoesNotGainRoughness() throws {
        let source = try image(wavy: false)
        let candidate = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )
        for left in [true, false] {
            XCTAssertLessThanOrEqual(
                try roughness(candidate, left: left),
                try roughness(source, left: left) * 1.10
            )
        }
        XCTAssertEqual(changed(source, candidate) { x, y in
            y < Int(0.50 * Double(height)) ||
                (0.44..<0.56).contains(Double(x) / Double(width))
        }, 0)
    }

    func testCompetingOuterEdgesFailClosedAndKeepOriginalPixels() throws {
        let source = try image(wavy: true, competingEdges: true)
        let candidate = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )
        let changes = changed(source, candidate) { _, _ in true }
        XCTAssertEqual(changes, 0, "ambiguous source changed pixels=\(changes)")
    }

    func testTransparentCheekRowsRemainUntouched() throws {
        var source = try image(wavy: true)
        for row in 456..<528 {
            for column in 0..<width {
                source[(row * width + column) * 4 + 3] = 0
            }
        }
        let candidate = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )
        XCTAssertEqual(changed(source, candidate) { _, y in (456..<528).contains(y) }, 0)
        XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy {
            source[$0] == candidate[$0]
        })
    }

    func testDarkBackgroundRoughCheeksImproveOnBothSides() throws {
        let source = try image(wavy: true, background: (40, 40, 40))
        let candidate = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )
        for left in [true, false] {
            let before = try redRoughness(source, left: left, backgroundRed: 40)
            let after = try redRoughness(candidate, left: left, backgroundRed: 40)
            XCTAssertGreaterThan(before, 0.5)
            XCTAssertLessThan(after, before * 0.90)
        }
        XCTAssertEqual(changed(source, candidate) { x, y in
            y < Int(0.50 * Double(height)) ||
                (0.44..<0.56).contains(Double(x) / Double(width)) ||
                x < width / 8 || x >= width * 7 / 8
        }, 0)
        XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy {
            source[$0] == candidate[$0]
        })
    }

    func testWeakContrastDoesNotRoughenOrEscapeProtectedRegions() throws {
        let source = try image(wavy: true, background: (165, 125, 110))
        let candidate = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )
        let repeated = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )
        XCTAssertTrue(candidate == repeated, "weak-contrast output is not repeatable")
        for left in [true, false] {
            let before = try redRoughness(source, left: left, backgroundRed: 165)
            let after = try redRoughness(candidate, left: left, backgroundRed: 165)
            XCTAssertGreaterThan(before, 0.5)
            XCTAssertLessThanOrEqual(after, before * 1.10)
        }
        XCTAssertEqual(changed(source, candidate) { x, y in
            y < Int(0.50 * Double(height)) ||
                (0.44..<0.56).contains(Double(x) / Double(width)) ||
                x < width / 8 || x >= width * 7 / 8
        }, 0)
        XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy {
            source[$0] == candidate[$0]
        })
    }

    func testLocalOpaqueOcclusionKeepsAmbiguousRowsSourceExact() throws {
        let occludedRows = 456..<472
        let source = try image(wavy: true, competingRows: occludedRows)
        let candidate = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )
        XCTAssertEqual(changed(source, candidate) { _, y in occludedRows.contains(y) }, 0)
        XCTAssertGreaterThan(changed(source, candidate) { _, y in
            (472..<528).contains(y)
        }, 0)
        XCTAssertEqual(changed(source, candidate) { x, y in
            (0.44..<0.56).contains(Double(x) / Double(width)) ||
                x < width / 8 || x >= width * 7 / 8 || y < Int(0.50 * Double(height))
        }, 0)
    }

    func testConflictingLightingDirectionsFailClosedForEachSide() throws {
        let source = try image(wavy: true, alternatingLighting: true)
        let candidate = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )
        XCTAssertEqual(changed(source, candidate) { _, _ in true }, 0)
    }

    func testGeneratedSkinTonesImproveRoughCheeksAndProtectSmoothNegatives() throws {
        let cases: [(String, (UInt8, UInt8, UInt8), (UInt8, UInt8, UInt8))] = [
            ("deep", (112, 78, 65), (242, 242, 242)),
            ("medium", (146, 117, 87), (25, 25, 25)),
            ("light", (222, 184, 158), (50, 50, 50)),
        ]
        for (name, skin, background) in cases {
            let rough = try image(wavy: true, background: background, skin: skin)
            let smooth = try image(wavy: false, background: background, skin: skin)
            let roughOutput = FaceContourSubpixelRefiner.refine(
                rough, width: width, height: height, face: face, strength: 0.25
            )
            let smoothOutput = FaceContourSubpixelRefiner.refine(
                smooth, width: width, height: height, face: face, strength: 0.25
            )
            for left in [true, false] {
                let roughBefore = try redRoughness(
                    rough, left: left, backgroundRed: Int(background.0), skinRed: Int(skin.0)
                )
                let roughAfter = try redRoughness(
                    roughOutput, left: left, backgroundRed: Int(background.0), skinRed: Int(skin.0)
                )
                XCTAssertGreaterThan(roughBefore, 0.5, name)
                XCTAssertLessThan(roughAfter, roughBefore * 0.90, name)
                let smoothBefore = try redRoughness(
                    smooth, left: left, backgroundRed: Int(background.0), skinRed: Int(skin.0)
                )
                let smoothAfter = try redRoughness(
                    smoothOutput, left: left, backgroundRed: Int(background.0), skinRed: Int(skin.0)
                )
                XCTAssertLessThanOrEqual(smoothAfter, smoothBefore * 1.10, name)
            }
            for (source, output) in [(rough, roughOutput), (smooth, smoothOutput)] {
                XCTAssertEqual(changed(source, output) { x, y in
                    y < Int(0.50 * Double(height)) ||
                        (0.44..<0.56).contains(Double(x) / Double(width)) ||
                        x < width / 8 || x >= width * 7 / 8
                }, 0, name)
                XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy {
                    source[$0] == output[$0]
                }, name)
            }
            XCTAssertEqual(
                roughOutput,
                FaceContourSubpixelRefiner.refine(
                    rough, width: width, height: height, face: face, strength: 0.25
                ), name
            )
        }
    }

    func testOppositeSideLightingKeepsBothCheeksDirectionalAndUpperEarProtected() throws {
        let source = try image(
            wavy: true,
            background: (240, 240, 240),
            skin: (112, 78, 65),
            rightBackground: (35, 35, 35),
            rightSkin: (212, 174, 146)
        )
        let output = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )
        let sides = [(true, 240, 112), (false, 35, 212)]
        for (left, backgroundRed, skinRed) in sides {
            let before = try redRoughness(
                source, left: left, backgroundRed: backgroundRed, skinRed: skinRed
            )
            let after = try redRoughness(
                output, left: left, backgroundRed: backgroundRed, skinRed: skinRed
            )
            XCTAssertGreaterThan(before, 0.5)
            XCTAssertLessThan(after, before * 0.90)
        }
        XCTAssertEqual(changed(source, output) { x, y in
            y < Int(0.50 * Double(height)) ||
                (0.44..<0.56).contains(Double(x) / Double(width)) ||
                x < width / 8 || x >= width * 7 / 8
        }, 0)
        XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy {
            source[$0] == output[$0]
        })
    }

    func testDarkHairCrossingShortCheekRowsIsProtectedWithoutBlockingNeighboringRows() throws {
        let hairRows = 456..<472
        let source = try image(wavy: true, hairRows: hairRows)
        let output = FaceContourSubpixelRefiner.refine(
            source, width: width, height: height, face: face, strength: 0.25
        )
        XCTAssertEqual(changed(source, output) { _, y in hairRows.contains(y) }, 0)
        XCTAssertGreaterThan(changed(source, output) { _, y in (472..<528).contains(y) }, 0)
        XCTAssertEqual(changed(source, output) { x, y in
            y < Int(0.50 * Double(height)) ||
                (0.44..<0.56).contains(Double(x) / Double(width)) ||
                x < width / 8 || x >= width * 7 / 8
        }, 0)
        XCTAssertTrue(stride(from: 3, to: source.count, by: 4).allSatisfy {
            source[$0] == output[$0]
        })
    }

    private func image(
        wavy: Bool,
        competingEdges: Bool = false,
        competingRows: Range<Int>? = nil,
        background: (UInt8, UInt8, UInt8) = (220, 220, 220),
        alternatingLighting: Bool = false,
        skin: (UInt8, UInt8, UInt8) = (170, 120, 105),
        rightBackground: (UInt8, UInt8, UInt8)? = nil,
        rightSkin: (UInt8, UInt8, UInt8)? = nil,
        hairRows: Range<Int>? = nil
    ) throws -> [UInt8] {
        let runs = try XCTUnwrap(FaceContourLateralRuns.make(
            from: try XCTUnwrap(face.observedFaceSupport?.contour)
        ))
        var pixels = [UInt8](repeating: 255, count: width * height * 4)
        for row in 0..<height {
            let y = (Float(row) + 0.5) / Float(height)
            let left = centerX(runs[0], at: y).map { $0 * Float(width) - 12 }
            let right = centerX(runs[1], at: y).map { $0 * Float(width) + 12 }
            let wave = wavy ? Float(4 * sin(Double(row) * 2 * .pi / 28)) : 0
            for column in 0..<width {
                let x = Float(column)
                let inside = left.map { x >= $0 + wave } == true &&
                    right.map { x <= $0 - wave } == true
                let competing = (competingEdges || competingRows?.contains(row) == true) && (
                    left.map { x >= $0 - 20 && x < $0 - 14 } == true ||
                    right.map { x > $0 + 14 && x <= $0 + 20 } == true
                )
                let hair = hairRows?.contains(row) == true && (
                    left.map { x >= $0 - 10 && x <= $0 + 12 } == true ||
                    right.map { x >= $0 - 12 && x <= $0 + 10 } == true
                )
                let i = (row * width + column) * 4
                if hair {
                    pixels[i] = 22
                    pixels[i + 1] = 20
                    pixels[i + 2] = 18
                } else if inside || competing {
                    let color = column >= width / 2 ? rightSkin ?? skin : skin
                    pixels[i] = color.0
                    pixels[i + 1] = color.1
                    pixels[i + 2] = color.2
                } else {
                    let rowBackground: (UInt8, UInt8, UInt8) =
                        alternatingLighting && (row / 8).isMultiple(of: 2)
                            ? (40, 40, 40) :
                            (column >= width / 2 ? rightBackground ?? background : background)
                    pixels[i] = rowBackground.0
                    pixels[i + 1] = rowBackground.1
                    pixels[i + 2] = rowBackground.2
                }
            }
        }
        return pixels
    }

    private func centerX(_ run: FaceContourLateralRuns.Run, at y: Float) -> Float? {
        guard let first = run.ordered.first, let last = run.ordered.last,
              y >= first.y && y < last.y else { return nil }
        for (a, b) in zip(run.ordered, run.ordered.dropFirst()) where y >= a.y && y <= b.y {
            let t = (y - a.y) / (b.y - a.y)
            return a.x + t * (b.x - a.x)
        }
        return nil
    }

    private func edge(_ bytes: [UInt8], row: Int, left: Bool) -> Int? {
        for column in left ? Array(100..<400) : Array((400..<700).reversed()) {
            let i = (row * width + column) * 4
            if Int(bytes[i]) - Int(bytes[i + 2]) > 20 { return column }
        }
        return nil
    }

    private func roughness(_ bytes: [UInt8], left: Bool) throws -> Double {
        let edges = try (456..<528).map { row in
            try XCTUnwrap(edge(bytes, row: row, left: left))
        }
        let offset = 10
        var roughness = 0
        for index in offset..<(edges.count - offset) {
            roughness += abs(edges[index - offset] - 2 * edges[index] + edges[index + offset])
        }
        return Double(roughness) / Double(edges.count - 2 * offset)
    }

    private func redRoughness(
        _ bytes: [UInt8], left: Bool, backgroundRed: Int, skinRed: Int = 170
    ) throws -> Double {
        let threshold = (skinRed + backgroundRed) / 2
        let edges = try (456..<528).map { row -> Int in
            let columns = left ? Array(100..<400) : Array((400..<700).reversed())
            return try XCTUnwrap(columns.first { column in
                let red = Int(bytes[(row * width + column) * 4])
                return backgroundRed < skinRed ? red > threshold : red < threshold
            })
        }
        let offset = 10
        let total = (offset..<(edges.count - offset)).reduce(0) { sum, index in
            sum + abs(edges[index - offset] - 2 * edges[index] + edges[index + offset])
        }
        return Double(total) / Double(edges.count - 2 * offset)
    }

    private func changed(
        _ source: [UInt8], _ candidate: [UInt8],
        include: (Int, Int) -> Bool
    ) -> Int {
        var count = 0
        for row in 0..<height {
            for column in 0..<width where include(column, row) {
                let i = (row * width + column) * 4
                if (0..<3).contains(where: { source[i + $0] != candidate[i + $0] }) {
                    count += 1
                }
            }
        }
        return count
    }
}
