import Foundation
import XCTest

/// Independent integer measurement of the fixed positive prerequisite policy.
/// No production geometry, provider, sampler or metric helper is used.
enum MouthBaselineOracle {
    enum Failure: Error { case admission, arithmetic, contract }

    static func add(_ a: Int64, _ b: Int64) throws -> Int64 {
        let r = a.addingReportingOverflow(b)
        guard !r.overflow else { throw Failure.arithmetic }
        return r.partialValue
    }
    static func subtract(_ a: Int64, _ b: Int64) throws -> Int64 {
        let r = a.subtractingReportingOverflow(b)
        guard !r.overflow else { throw Failure.arithmetic }
        return r.partialValue
    }
    static func multiply(_ a: Int64, _ b: Int64) throws -> Int64 {
        let r = a.multipliedReportingOverflow(by: b)
        guard !r.overflow else { throw Failure.arithmetic }
        return r.partialValue
    }
    static func absolute(_ a: Int64) throws -> Int64 {
        guard a != .min else { throw Failure.arithmetic }
        return abs(a)
    }

    struct Image {
        let bytes: [UInt8]
        let width: Int
        let height: Int
        init(_ bytes: [UInt8], width: Int, height: Int) throws {
            guard width > 0, height > 0 else { throw Failure.admission }
            let count = try multiply(multiply(Int64(width), Int64(height)), 4)
            guard count == Int64(bytes.count) else { throw Failure.admission }
            self.bytes = bytes
            self.width = width
            self.height = height
        }
    }

    struct Rect {
        let minX: Int
        let maxX: Int
        let minY: Int
        let maxY: Int
        let width: Int
        let height: Int
        init(_ ppm: [Int64], width: Int, height: Int) throws {
            guard ppm.count == 4, width > 0, height > 0,
                  ppm.allSatisfy({ (0...1_000_000).contains($0) }) else { throw Failure.admission }
            let edges = try zip(ppm, [width, width, height, height]).map { edge, extent -> Int in
                let v = try multiply(edge, Int64(extent)) / 1_000_000
                guard let value = Int(exactly: v) else { throw Failure.arithmetic }
                return value
            }
            guard edges[0] < edges[1], edges[2] < edges[3] else { throw Failure.admission }
            (minX, maxX, minY, maxY) = (edges[0], edges[1], edges[2], edges[3])
            self.width = width
            self.height = height
        }
        func contains(_ x: Int, _ y: Int) -> Bool {
            x >= minX && x < maxX && y >= minY && y < maxY
        }
    }

    struct Contract {
        let targets: [Rect]
        let protection: [String: [Rect]]

        static func load(width: Int, height: Int) throws -> Contract {
            let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
                .deletingLastPathComponent().deletingLastPathComponent()
            let data = try Data(contentsOf: root.appendingPathComponent("scripts/face-feature-batch-manifest.json"))
            guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let rows = object["semanticContracts"] as? [[String: Any]] else { throw Failure.contract }
            let mouth = rows.filter { $0["caseID"] as? String == "mouthWidth_minus0p35" }
            guard mouth.count == 1, let row = mouth.first else { throw Failure.contract }
            return try decode(row, width: width, height: height)
        }

        static func decode(_ row: [String: Any], width: Int, height: Int) throws -> Contract {
            let keys: Set<String> = ["caseID", "metric", "expectedSign", "comparisonCaseIDs", "targetRegions", "thresholds", "protectedRegions"]
            guard Set(row.keys) == keys, row["caseID"] as? String == "mouthWidth_minus0p35",
                  row["metric"] as? String == "mouthWidthContraction", row["expectedSign"] as? String == "negative",
                  row["comparisonCaseIDs"] as? [String] == ["source", "geometryBaseline_noop", "mouthWidth_plus0p35",
                                                            "mouthSize_plus0p35", "mouthSize_minus0p35"],
                  let threshold = row["thresholds"] as? [String: Int64], threshold == [
                    "minimumChangedPixels": 500, "minimumAbsoluteRGBDelta": 2000, "minimumSignedMarginQ16": 16,
                    "maximumOutsideChangedPixels": 128, "maximumOutsideAbsoluteRGBDelta": 512],
                  let targets = row["targetRegions"] as? [[String: Any]], targets.count == 2,
                  let groups = row["protectedRegions"] as? [[String: Any]], groups.count == 4 else { throw Failure.contract }
            let targetNames = ["leftCorner", "rightCorner"]
            let targetPPM: [[Int64]] = [[200000, 400000, 600000, 760000], [600000, 800000, 600000, 760000]]
            var targetRects: [Rect] = []
            for i in 0..<2 {
                guard targets[i]["id"] as? String == targetNames[i] else { throw Failure.contract }
                targetRects.append(try region(targets[i], expected: targetPPM[i], hasID: true, width: width, height: height))
            }
            let names = ["mouthHeight", "surroundingFace", "background", "watermark"]
            let bounds: [[[Int64]]] = [
                [[400000, 600000, 580000, 780000]],
                [[100000, 900000, 400000, 580000], [100000, 900000, 780000, 820000]],
                [[0, 90000, 80000, 820000], [910000, 1000000, 80000, 820000]],
                [[820000, 980000, 920000, 985000]]
            ]
            var protected: [String: [Rect]] = [:]
            for i in 0..<4 {
                let group = groups[i]
                guard Set(group.keys) == Set(["id", "regions", "maximumChangedPixels", "maximumAbsoluteRGBDelta"]),
                      group["id"] as? String == names[i], group["maximumChangedPixels"] as? Int64 == (i < 2 ? 64 : 0),
                      group["maximumAbsoluteRGBDelta"] as? Int64 == (i < 2 ? 256 : 0),
                      let regions = group["regions"] as? [[String: Any]], regions.count == bounds[i].count else { throw Failure.contract }
                protected[names[i]] = try regions.enumerated().map { index, regionRow in
                    try region(regionRow, expected: bounds[i][index], hasID: false, width: width, height: height)
                }
            }
            return Contract(targets: targetRects, protection: protected)
        }

        private static func region(_ row: [String: Any], expected: [Int64], hasID: Bool,
                                   width: Int, height: Int) throws -> Rect {
            let names = ["minXPPM", "maxXPPM", "minYPPM", "maxYPPM"]
            guard Set(row.keys) == Set(names + (hasID ? ["id"] : [])) else { throw Failure.contract }
            let ppm = try names.map { key -> Int64 in
                guard let value = row[key] as? Int64 else { throw Failure.contract }
                return value
            }
            guard ppm == expected else { throw Failure.contract }
            return try Rect(ppm, width: width, height: height)
        }
    }

    static func centroid(moment: Int64, weight: Int64, width: Int) throws -> Int64 {
        guard moment >= 0, weight > 0, width > 0 else { throw Failure.admission }
        let numerator = try multiply(moment, 65536)
        let denominator = try multiply(multiply(weight, 2), Int64(width))
        guard denominator > 0 else { throw Failure.admission }
        return numerator / denominator
    }

    static func span(_ image: Image, targets: [Rect], maxY: Int? = nil) throws -> Int64 {
        guard targets.count == 2 else { throw Failure.admission }
        var centers: [Int64] = []
        for r in targets {
            guard r.width == image.width, r.height == image.height else { throw Failure.admission }
            let end = min(r.maxY, maxY ?? image.height)
            guard end > r.minY else { throw Failure.admission }
            var weight: Int64 = 0
            var moment: Int64 = 0
            for y in r.minY..<end {
                for x in r.minX..<r.maxX {
                    let i = (y * image.width + x) * 4
                    let red = try multiply(77, Int64(image.bytes[i]))
                    let green = try multiply(150, Int64(image.bytes[i + 1]))
                    let blue = try multiply(29, Int64(image.bytes[i + 2]))
                    let luma = try add(add(red, green), blue)
                    let w = max(0, try subtract(65280, luma))
                    weight = try add(weight, w)
                    let center = try add(multiply(2, Int64(x)), 1)
                    moment = try add(moment, multiply(w, center))
                }
            }
            centers.append(try centroid(moment: moment, weight: weight, width: image.width))
        }
        centers.sort()
        return try subtract(centers[1], centers[0])
    }

    struct Signal: Equatable {
        var changed: Int64 = 0
        var rgb: Int64 = 0
    }

    static func signal(_ a: Image, _ b: Image, regions: [Rect], outside: Bool = false,
                       maxY: Int? = nil) throws -> Signal {
        guard a.width == b.width, a.height == b.height,
              regions.allSatisfy({ $0.width == a.width && $0.height == a.height }) else { throw Failure.admission }
        let end = maxY ?? a.height
        guard end >= 0, end <= a.height else { throw Failure.admission }
        var result = Signal()
        for y in 0..<end {
            for x in 0..<a.width {
                let member = regions.contains { $0.contains(x, y) }
                if outside ? member : !member { continue }
                let i = (y * a.width + x) * 4
                var maximum: Int64 = 0
                for channel in 0..<3 {
                    let delta = try absolute(subtract(Int64(a.bytes[i + channel]), Int64(b.bytes[i + channel])))
                    maximum = max(maximum, delta)
                    result.rgb = try add(result.rgb, delta)
                }
                if maximum > 2 { result.changed = try add(result.changed, 1) }
            }
        }
        return result
    }

    static func excludedRows(width: Int) throws -> Int {
        guard width > 0 else { throw Failure.admission }
        // Exact rational form of ceil(2*max(24,w/70)+1.75*max(34,min(72,w/30))).
        let padding = max(40320, try multiply(Int64(width), 24))
        let font = max(49980, min(105840, try multiply(Int64(width), 49)))
        return Int(try add(add(padding, font), 839) / 840)
    }

    static let metricKeys: Set<String> = [
        "source_changed", "neutral_changed", "source_rgb", "neutral_rgb", "source_margin", "neutral_margin",
        "size_plus_margin", "size_minus_margin", "outside_changed", "outside_rgb", "height_changed", "height_rgb",
        "face_changed", "face_rgb", "background_changed", "background_rgb", "watermark_changed", "watermark_rgb"
    ]

    static func admitted(_ values: [String: Int64]) -> Bool {
        guard Set(values.keys) == metricKeys, values.values.allSatisfy({ $0 >= 0 }) else { return false }
        for key in ["source_changed", "neutral_changed"] where values[key, default: 0] < 500 { return false }
        for key in ["source_rgb", "neutral_rgb"] where values[key, default: 0] < 2000 { return false }
        for key in ["source_margin", "neutral_margin", "size_plus_margin", "size_minus_margin"]
            where values[key, default: 0] < 16 { return false }
        for (group, c, d): (String, Int64, Int64) in [("outside",128,512), ("height",64,256),
                                                     ("face",64,256), ("background",0,0), ("watermark",0,0)] {
            if values[group + "_changed", default: .max] > c || values[group + "_rgb", default: .max] > d { return false }
        }
        return true
    }

    static func measure(source: Image, neutral: Image, positive: Image, sizePlus: Image, sizeMinus: Image,
                        contract: Contract) throws -> [String: Int64] {
        let images = [source, neutral, positive, sizePlus, sizeMinus]
        guard images.allSatisfy({ $0.width == source.width && $0.height == source.height }),
              contract.targets.count == 2,
              Set(contract.protection.keys) == Set(["mouthHeight", "surroundingFace", "background", "watermark"])
        else { throw Failure.admission }
        let end = max(0, source.height - (try excludedRows(width: source.width)))
        var values = Dictionary(uniqueKeysWithValues: metricKeys.map { ($0, Int64(0)) })
        let positiveSpan = try span(positive, targets: contract.targets, maxY: end)
        for (name, reference) in [("source", source), ("neutral", neutral)] {
            let target = try signal(reference, positive, regions: contract.targets, maxY: end)
            values[name + "_changed"] = target.changed
            values[name + "_rgb"] = target.rgb
            values[name + "_margin"] = try subtract(positiveSpan, span(reference, targets: contract.targets, maxY: end))
            // Full and comparator-clipped bounds are independent requirements.
            // Maxima below retain every comparison and both region policies.
            for maximumY in [end, source.height] {
                let outer = try signal(reference, positive, regions: contract.targets, outside: true, maxY: maximumY)
                values["outside_changed"] = max(values["outside_changed", default: 0], outer.changed)
                values["outside_rgb"] = max(values["outside_rgb", default: 0], outer.rgb)
                for (group, field) in [("mouthHeight", "height"), ("surroundingFace", "face"),
                                       ("background", "background"), ("watermark", "watermark")] {
                    guard let regions = contract.protection[group] else { throw Failure.contract }
                    let protected = try signal(reference, positive, regions: regions, maxY: maximumY)
                    values[field + "_changed"] = max(values[field + "_changed", default: 0], protected.changed)
                    values[field + "_rgb"] = max(values[field + "_rgb", default: 0], protected.rgb)
                }
            }
        }
        values["size_plus_margin"] = try absolute(subtract(positiveSpan, span(sizePlus, targets: contract.targets, maxY: end)))
        values["size_minus_margin"] = try absolute(subtract(positiveSpan, span(sizeMinus, targets: contract.targets, maxY: end)))
        return values
    }
}

final class MouthBaselineOracleTests: XCTestCase {
    private typealias O = MouthBaselineOracle

    func testLiteralRasterSpanAndAdmission() throws {
        let r = try O.Rect([100001,900001,200001,800001], width: 13, height: 17)
        XCTAssertTrue(r.minX == 1 && r.maxX == 11 && r.minY == 3 && r.maxY == 13, "P94_ORACLE_FLOORS")
        XCTAssertTrue(r.contains(1,3) && r.contains(10,12) && !r.contains(11,3)
                      && !r.contains(1,13) && !r.contains(0,3), "P94_ORACLE_EXCLUSIVE")
        let contract = try O.Contract.load(width: 640, height: 800)
        XCTAssertTrue(contract.targets[0].minX == 128 && contract.targets[0].maxX == 256
                      && contract.targets[1].minX == 384 && contract.targets[1].maxX == 512
                      && contract.targets.allSatisfy({ $0.minY == 480 && $0.maxY == 608 }), "P94_ORACLE_LITERAL_REGIONS")
        XCTAssertTrue(try O.excludedRows(width: 640) == 108, "P94_ORACLE_CLIPPING")
        let left = try O.Rect([0,500000,0,1000000], width: 8, height: 4)
        let right = try O.Rect([500000,1000000,0,1000000], width: 8, height: 4)
        var bytes = [UInt8](repeating: 255, count: 8 * 4 * 4)
        for x in [1,6] { for c in 0..<3 { bytes[(8 + x) * 4 + c] = 0 } }
        let image = try O.Image(bytes, width: 8, height: 4)
        XCTAssertTrue(try O.span(image, targets: [left,right]) == 40960, "P94_ORACLE_INTEGER_SPAN")
        XCTAssertTrue(try O.span(image, targets: [right,left]) == 40960, "P94_ORACLE_SORTED_SPAN")
        XCTAssertTrue(try O.centroid(moment: 1, weight: 1, width: 3) == 10922, "P94_ORACLE_INTEGER_DIVISION")
        let white = try O.Image([UInt8](repeating: 255, count: 128), width: 8, height: 4)
        var tolerance = white.bytes
        tolerance[0] = 253
        tolerance[4] = 252
        let delta = try O.Image(tolerance, width: 8, height: 4)
        let full = try O.Rect([0,1000000,0,1000000], width: 8, height: 4)
        let signal = try O.signal(white, delta, regions: [full])
        XCTAssertTrue(signal.changed == 1 && signal.rgb == 5, "P94_ORACLE_TOLERANCE_ALL_RGB")
        XCTAssertTrue(try O.signal(white, delta, regions: [full], maxY: 0) == O.Signal(), "P94_ORACLE_EMPTY_PROTECTED")
        rejects { _ = try O.span(image, targets: [left,right], maxY: 0) }
        rejects { _ = try O.span(white, targets: [left,right]) }
        rejects { _ = try O.Image([], width: 0, height: 4) }
        rejects { _ = try O.Image([], width: 8, height: 4) }
        rejects { _ = try O.Image([0], width: Int.max, height: 4) }
        rejects { _ = try O.Rect([0,1000000,0,1000000], width: Int.max, height: 4) }
        rejects { _ = try O.centroid(moment: 1, weight: 0, width: 8) }
        rejects { _ = try O.centroid(moment: .max, weight: 1, width: 8) }
        rejects { _ = try O.centroid(moment: 1, weight: .max, width: 8) }
        rejects { _ = try O.add(.max, 1) }
        rejects { _ = try O.subtract(.min, 1) }
        rejects { _ = try O.absolute(.min) }
        rejects { _ = try O.excludedRows(width: Int.max) }
    }

    func testPositivePredicatesRejectEachFailure() throws {
        var good = Dictionary(uniqueKeysWithValues: O.metricKeys.map { ($0, Int64(0)) })
        for key in ["source_changed", "neutral_changed"] { good[key] = 500 }
        for key in ["source_rgb", "neutral_rgb"] { good[key] = 2000 }
        for key in ["source_margin", "neutral_margin", "size_plus_margin", "size_minus_margin"] { good[key] = 16 }
        for (group, c, rgb): (String, Int64, Int64) in [("outside",128,512),("height",64,256),("face",64,256)] {
            good[group + "_changed"] = c
            good[group + "_rgb"] = rgb
        }
        XCTAssertTrue(O.admitted(good), "P94_ORACLE_EXACT_BOUNDARIES")
        for key in ["source_changed", "neutral_changed", "source_rgb", "neutral_rgb", "source_margin",
                    "neutral_margin", "size_plus_margin", "size_minus_margin"] {
            var bad = good
            bad[key] = try O.subtract(good[key, default: 0], 1)
            XCTAssertTrue(!O.admitted(bad), "P94_ORACLE_SINGLE_SIGNAL_OR_MARGIN_REJECTED")
        }
        for group in ["outside", "height", "face", "background", "watermark"] {
            for suffix in ["_changed", "_rgb"] {
                var bad = good
                bad[group + suffix] = try O.add(good[group + suffix, default: 0], 1)
                XCTAssertTrue(!O.admitted(bad), "P94_ORACLE_SINGLE_PROTECTION_REJECTED")
            }
        }
        var alias = good
        alias["size_plus_margin"] = 0
        XCTAssertTrue(!O.admitted(alias), "P94_ORACLE_PLUS_SIZE_ALIAS_REJECTED")
        alias = good
        alias["size_minus_margin"] = 0
        XCTAssertTrue(!O.admitted(alias), "P94_ORACLE_MINUS_SIZE_ALIAS_REJECTED")
        var unknown = good
        unknown["unknown"] = 0
        XCTAssertTrue(!O.admitted(unknown), "P94_ORACLE_UNKNOWN_FIELD_REJECTED")
        var missing = good
        missing.removeValue(forKey: "source_rgb")
        XCTAssertTrue(!O.admitted(missing), "P94_ORACLE_MISSING_FIELD_REJECTED")
        var wrongSign = good
        wrongSign["neutral_margin"] = -16
        XCTAssertTrue(!O.admitted(wrongSign), "P94_ORACLE_WRONG_SIGN_REJECTED")
    }

    private func rejects(_ body: () throws -> Void) {
        do {
            try body()
            XCTFail("P94_ORACLE_EXPECTED_REJECTION")
        } catch MouthBaselineOracle.Failure.admission { }
        catch MouthBaselineOracle.Failure.arithmetic { }
        catch MouthBaselineOracle.Failure.contract { }
        catch { XCTFail("P94_ORACLE_UNEXPECTED_ERROR") }
    }
}
