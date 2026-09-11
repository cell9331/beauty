import Foundation
import XCTest

final class MouthNegativeOracleTests: XCTestCase {
    private typealias B = MouthBaselineOracle
    private typealias N = MouthNegativeOracle

    func testNegativeIntegerMetricMatchesFrozenContract() {
        safe {
            let fractional = try B.Rect([100001,900001,200001,800001], width: 13, height: 17)
            XCTAssertTrue(fractional.minX == 1 && fractional.maxX == 11
                          && fractional.minY == 3 && fractional.maxY == 13, "P94N_STAGE_METRIC")
            XCTAssertTrue(fractional.contains(1,3) && fractional.contains(10,12)
                          && !fractional.contains(0,3) && !fractional.contains(1,2)
                          && !fractional.contains(11,3) && !fractional.contains(1,13), "P94N_STAGE_METRIC")
            let twoPixels = try B.Rect([0,1000000,0,1000000], width: 2, height: 1)
            let white = try B.Image([255,255,255,255,255,255,255,255], width: 2, height: 1)
            let delta2 = try B.Image([253,255,255,255,255,255,255,255], width: 2, height: 1)
            let delta3 = try B.Image([252,255,255,255,255,255,255,255], width: 2, height: 1)
            let signal2 = try B.signal(white, delta2, regions: [twoPixels])
            let signal3 = try B.signal(white, delta3, regions: [twoPixels])
            XCTAssertTrue(signal2.changed == 0 && signal2.rgb == 2, "P94N_STAGE_METRIC")
            XCTAssertTrue(signal3.changed == 1 && signal3.rgb == 3, "P94N_STAGE_METRIC")
            let contract = try B.Contract.load(width: 640, height: 800)
            XCTAssertTrue(contract.targets.count == 2, "P94N_STAGE_METRIC")
            XCTAssertTrue(contract.targets[0].minX == 128 && contract.targets[0].maxX == 256,
                          "P94N_STAGE_METRIC")
            XCTAssertTrue(contract.targets[1].minX == 384 && contract.targets[1].maxX == 512,
                          "P94N_STAGE_METRIC")
            XCTAssertTrue(contract.targets[0].minY == 480 && contract.targets[0].maxY == 608,
                          "P94N_STAGE_METRIC")
            let excluded = try B.excludedRows(width: 640)
            XCTAssertTrue(excluded == 108, "P94N_STAGE_METRIC")
            let fixture = try arrays()
            let orderedSpan = try B.span(fixture.inward, targets: fixture.contract.targets)
            let swappedSpan = try B.span(fixture.inward, targets: Array(fixture.contract.targets.reversed()))
            XCTAssertTrue(orderedSpan == swappedSpan && orderedSpan > 0, "P94N_STAGE_METRIC")
            let measured = try measure(fixture, negative: fixture.inward)
            // Two rectangles each move eight pixels toward the center. The
            // Q16 span difference is exactly -16*65536/256, without floats.
            XCTAssertTrue(measured.values["source_margin"] == -4096, "P94N_STAGE_METRIC")
            XCTAssertTrue(measured.values["neutral_margin"] == -4096, "P94N_STAGE_METRIC")
            XCTAssertTrue(measured.values["source_changed"] == 1280, "P94N_STAGE_METRIC")
            XCTAssertTrue(measured.values["source_rgb"] == 979200, "P94N_STAGE_METRIC")
            XCTAssertTrue(measured.predicates.count == 17 && N.admitted(measured), "P94N_STAGE_METRIC")
            rejects { _ = try B.Image([], width: 0, height: 1) }
            rejects { _ = try B.Image([255], width: 1, height: 1) }
            rejects { _ = try B.multiply(.max, 2) }
            rejects { _ = try B.absolute(.min) }
            let small = try B.Image([255,255,255,255], width: 1, height: 1)
            rejects {
                _ = try N.measure(source: fixture.source, neutral: small, negative: fixture.inward,
                                  positive: fixture.outward, sizePlus: fixture.plus, sizeMinus: fixture.minus,
                                  contract: fixture.contract)
            }
            let empty = try B.Image([UInt8](repeating: 255, count: 256 * 256 * 4), width: 256, height: 256)
            rejects { _ = try measure(fixture, negative: empty) }
        }
    }

    func testEveryNegativePredicateIsNecessary() {
        safe {
            // A passing boundary control, then independently violate every
            // metric threshold, including both halves of each signal predicate.
            var values = Dictionary(uniqueKeysWithValues: N.metricKeys.map { ($0, Int64(0)) })
            values.merge(["source_changed":500, "neutral_changed":500,
                          "source_rgb":2000, "neutral_rgb":2000,
                          "source_margin":-16, "neutral_margin":-16,
                          "positive_margin":16, "size_plus_margin":16, "size_minus_margin":16]) { _, new in new }
            // Literal inclusive upper bounds must pass; the mutations below
            // exceed each bound by exactly one while all others stay legal.
            values.merge(["outside_changed":128, "outside_rgb":512,
                          "height_changed":64, "height_rgb":256,
                          "face_changed":64, "face_rgb":256]) { _, new in new }
            let good = try N.Metrics(values)
            XCTAssertTrue(N.admitted(good), "P94N_STAGE_METRIC")
            var mutations: [(String, Int64, String)] = []
            for reference in ["source", "neutral"] {
                mutations.append((reference + "_changed", 499, "P94N_NEG_" + reference.uppercased() + "_SIGNAL"))
                mutations.append((reference + "_rgb", 1999, "P94N_NEG_" + reference.uppercased() + "_SIGNAL"))
                mutations.append((reference + "_margin", -15, "P94N_NEG_" + reference.uppercased() + "_SIGN"))
            }
            for (name, marker) in [("positive", "POS"), ("size_plus", "SIZE_PLUS"), ("size_minus", "SIZE_MINUS")] {
                mutations.append((name + "_margin", 15, "P94N_NEG_" + marker + "_DISTINCT"))
            }
            for (group, changed, rgb) in N.limits {
                mutations.append((group + "_changed", changed + 1, "P94N_NEG_" + group.uppercased() + "_CHANGED"))
                mutations.append((group + "_rgb", rgb + 1, "P94N_NEG_" + group.uppercased() + "_RGB"))
            }
            XCTAssertTrue(mutations.count == 19, "P94N_STAGE_METRIC")
            for (key, value, marker) in mutations {
                var changed = values
                changed[key] = value
                let bad = try N.Metrics(changed)
                let failed = Set(bad.predicates.filter { !$0.value }.map { $0.key })
                XCTAssertTrue(failed == Set([marker]) && !N.admitted(bad), "P94N_STAGE_METRIC")
            }
            var missing = values
            missing.removeValue(forKey: "positive_margin")
            rejects { _ = try N.Metrics(missing) }
            var extra = values
            extra["unapproved"] = 0
            rejects { _ = try N.Metrics(extra) }
            var negativeCount = values
            negativeCount["source_changed"] = -1
            rejects { _ = try N.Metrics(negativeCount) }
        }
    }

    func testArrayCounterexamplesCannotMasqueradeAsContraction() {
        safe {
            let f = try arrays()
            let inward = try measure(f, negative: f.inward)
            let identity = try measure(f, negative: f.source)
            let outward = try measure(f, negative: f.outward)
            XCTAssertTrue(N.admitted(inward), "P94N_STAGE_METRIC")
            XCTAssertFalse(N.admitted(identity), "P94N_STAGE_METRIC")
            XCTAssertFalse(N.admitted(outward), "P94N_STAGE_METRIC")
            for sibling in 0..<3 {
                let m = try N.measure(source: f.source, neutral: f.source, negative: f.inward,
                                      positive: sibling == 0 ? f.inward : f.outward,
                                      sizePlus: sibling == 1 ? f.inward : f.plus,
                                      sizeMinus: sibling == 2 ? f.inward : f.minus, contract: f.contract)
                XCTAssertFalse(N.admitted(m), "P94N_STAGE_METRIC")
                let marker = ["P94N_NEG_POS_DISTINCT", "P94N_NEG_SIZE_PLUS_DISTINCT", "P94N_NEG_SIZE_MINUS_DISTINCT"][sibling]
                XCTAssertTrue(m.predicates[marker] == false, "P94N_STAGE_METRIC")
            }
            let heightOnly = try painted(f.source, x: 112..<144, y: 80..<112, value: 0)
            let heightMeasurement = try measure(f, negative: heightOnly)
            XCTAssertFalse(N.admitted(heightMeasurement), "P94N_STAGE_METRIC")
            // Sub-threshold per-pixel drift still violates the RGB sum. It
            // cannot disappear by counting only pixels whose delta exceeds 2.
            let leaked = try painted(f.inward, x: 112..<144, y: 80..<112, value: 254)
            let leakage = try measure(f, negative: leaked)
            XCTAssertTrue(leakage.values["height_changed"] == 0, "P94N_STAGE_METRIC")
            XCTAssertTrue(leakage.predicates["P94N_NEG_HEIGHT_RGB"] == false, "P94N_STAGE_METRIC")
            XCTAssertFalse(N.admitted(leakage), "P94N_STAGE_METRIC")
            // This defect is below comparator clipping and is found only by
            // the independent full-image protection pass.
            let bottom = try painted(f.inward, x: 220..<224, y: 232..<236, value: 0)
            let watermark = try measure(f, negative: bottom)
            XCTAssertTrue(watermark.predicates["P94N_NEG_WATERMARK_CHANGED"] == false, "P94N_STAGE_METRIC")
            XCTAssertFalse(N.admitted(watermark), "P94N_STAGE_METRIC")
            let neutralLeak = try painted(f.source, x: 0..<4, y: 64..<68, value: 0)
            let twoReferences = try N.measure(source: f.source, neutral: neutralLeak, negative: f.inward,
                                              positive: f.outward, sizePlus: f.plus, sizeMinus: f.minus,
                                              contract: f.contract)
            XCTAssertTrue(twoReferences.predicates["P94N_NEG_BACKGROUND_RGB"] == false, "P94N_STAGE_METRIC")
            XCTAssertFalse(N.admitted(twoReferences), "P94N_STAGE_METRIC")
        }
    }

    private struct Arrays {
        let source: B.Image
        let inward: B.Image
        let outward: B.Image
        let plus: B.Image
        let minus: B.Image
        let contract: B.Contract
    }

    private func arrays() throws -> Arrays {
        func rect(_ bounds: [Int64]) throws -> B.Rect {
            try B.Rect(bounds, width: 256, height: 256)
        }
        let contract = try B.Contract(
            targets: [rect([78125,390625,250000,500000]), rect([609375,921875,250000,500000])],
            protection: ["mouthHeight":[rect([429688,570313,250000,500000])],
                         "surroundingFace":[rect([78125,921875,62500,187500])],
                         "background":[rect([0,39063,250000,500000])],
                         "watermark":[rect([820313,960938,898438,960938])]])
        func bands(_ shift: Int) throws -> B.Image {
            var bytes = [UInt8](repeating: 255, count: 256 * 256 * 4)
            for y in 80..<120 {
                for x in Array((40 + shift)..<(60 + shift)) + Array((196 - shift)..<(216 - shift)) {
                    let i = (y * 256 + x) * 4
                    bytes[i] = 0; bytes[i + 1] = 0; bytes[i + 2] = 0
                }
            }
            return try B.Image(bytes, width: 256, height: 256)
        }
        return try Arrays(source: bands(0), inward: bands(8), outward: bands(-8),
                          plus: bands(-2), minus: bands(2), contract: contract)
    }

    private func painted(_ source: B.Image, x: Range<Int>, y: Range<Int>, value: UInt8) throws -> B.Image {
        var bytes = source.bytes
        for row in y {
            for column in x {
                let i = (row * source.width + column) * 4
                bytes[i] = value; bytes[i + 1] = value; bytes[i + 2] = value
            }
        }
        return try B.Image(bytes, width: source.width, height: source.height)
    }

    private func measure(_ f: Arrays, negative: B.Image) throws -> N.Metrics {
        try N.measure(source: f.source, neutral: f.source, negative: negative,
                      positive: f.outward, sizePlus: f.plus, sizeMinus: f.minus, contract: f.contract)
    }

    private func safe(_ action: () throws -> Void) {
        do { try action() } catch { XCTFail("P94N_STAGE_METRIC") }
    }
    private func rejects(_ action: () throws -> Void) {
        do { try action(); XCTFail("P94N_STAGE_METRIC") }
        catch is MouthBaselineOracle.Failure { /* Expected typed failure; never print it. */ }
        catch { XCTFail("P94N_STAGE_METRIC") }
    }
}

/// Six explicitly named images, using only immutable integer raster primitives.
/// Production geometry and the positive oracle's policy are not dependencies.
enum MouthNegativeOracle {
    private typealias B = MouthBaselineOracle
    static let comparisons = ["source", "geometryBaseline_noop", "mouthWidth_plus0p35",
                              "mouthSize_plus0p35", "mouthSize_minus0p35"]
    static let limits: [(String, Int64, Int64)] = [
        ("outside",128,512), ("height",64,256), ("face",64,256), ("background",0,0), ("watermark",0,0)
    ]
    static let metricKeys: Set<String> = [
        "source_changed", "source_rgb", "neutral_changed", "neutral_rgb", "source_margin", "neutral_margin",
        "positive_margin", "size_plus_margin", "size_minus_margin", "outside_changed", "outside_rgb",
        "height_changed", "height_rgb", "face_changed", "face_rgb", "background_changed", "background_rgb",
        "watermark_changed", "watermark_rgb"
    ]

    struct Metrics {
        let values: [String: Int64]
        var predicates: [String: Bool] {
            var result: [String: Bool] = [:]
            // Keys and domains have already been checked by the initializer.
            for reference in ["source", "neutral"] {
                result["P94N_NEG_" + reference.uppercased() + "_SIGNAL"] =
                    values[reference + "_changed"]! >= 500 && values[reference + "_rgb"]! >= 2000
                result["P94N_NEG_" + reference.uppercased() + "_SIGN"] = values[reference + "_margin"]! <= -16
            }
            for (name, marker) in [("positive", "POS"), ("size_plus", "SIZE_PLUS"), ("size_minus", "SIZE_MINUS")] {
                result["P94N_NEG_" + marker + "_DISTINCT"] = values[name + "_margin"]! >= 16
            }
            for (group, changed, rgb) in limits {
                result["P94N_NEG_" + group.uppercased() + "_CHANGED"] = values[group + "_changed"]! <= changed
                result["P94N_NEG_" + group.uppercased() + "_RGB"] = values[group + "_rgb"]! <= rgb
            }
            return result
        }
        init(_ values: [String: Int64]) throws {
            guard Set(values.keys) == metricKeys else { throw B.Failure.admission }
            for (key, value) in values where key != "source_margin" && key != "neutral_margin" {
                guard value >= 0 else { throw B.Failure.admission }
            }
            self.values = values
        }
    }

    static func admitted(_ metrics: Metrics) -> Bool {
        metrics.predicates.count == 17 && metrics.predicates.values.allSatisfy { $0 }
    }

    static func measure(source: MouthBaselineOracle.Image, neutral: MouthBaselineOracle.Image,
                        negative: MouthBaselineOracle.Image, positive: MouthBaselineOracle.Image,
                        sizePlus: MouthBaselineOracle.Image, sizeMinus: MouthBaselineOracle.Image,
                        contract: MouthBaselineOracle.Contract) throws -> Metrics {
        let images = [source, neutral, negative, positive, sizePlus, sizeMinus]
        guard images.allSatisfy({ $0.width == source.width && $0.height == source.height }),
              contract.targets.count == 2,
              Set(contract.protection.keys) == Set(["mouthHeight", "surroundingFace", "background", "watermark"])
        else { throw B.Failure.admission }
        let end = max(0, source.height - (try B.excludedRows(width: source.width)))
        var values = Dictionary(uniqueKeysWithValues: metricKeys.map { ($0, Int64(0)) })
        let span = try B.span(negative, targets: contract.targets, maxY: end)
        for (name, reference) in [("source", source), ("neutral", neutral)] {
            let target = try B.signal(reference, negative, regions: contract.targets, maxY: end)
            values[name + "_changed"] = target.changed
            values[name + "_rgb"] = target.rgb
            values[name + "_margin"] = try B.subtract(span, B.span(reference, targets: contract.targets, maxY: end))
            // Each bound must hold against both references in both full and
            // comparator-clipped coordinates. Componentwise maxima preserve
            // that conjunction without persisting individual pixels.
            for maximumY in [end, source.height] {
                let outer = try B.signal(reference, negative, regions: contract.targets, outside: true, maxY: maximumY)
                values["outside_changed"] = max(values["outside_changed"]!, outer.changed)
                values["outside_rgb"] = max(values["outside_rgb"]!, outer.rgb)
                for (group, field) in [("mouthHeight", "height"), ("surroundingFace", "face"),
                                       ("background", "background"), ("watermark", "watermark")] {
                    guard let regions = contract.protection[group], !regions.isEmpty else { throw B.Failure.contract }
                    let signal = try B.signal(reference, negative, regions: regions, maxY: maximumY)
                    values[field + "_changed"] = max(values[field + "_changed"]!, signal.changed)
                    values[field + "_rgb"] = max(values[field + "_rgb"]!, signal.rgb)
                }
            }
        }
        for (name, sibling) in [("positive", positive), ("size_plus", sizePlus), ("size_minus", sizeMinus)] {
            values[name + "_margin"] = try B.absolute(B.subtract(span, B.span(sibling, targets: contract.targets, maxY: end)))
        }
        return try Metrics(values)
    }
}
