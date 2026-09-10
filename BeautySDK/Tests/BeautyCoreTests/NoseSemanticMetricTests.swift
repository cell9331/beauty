import Foundation
import XCTest

/// Test-owned copy of the two frozen comparator contracts. No provider geometry
/// or generated-output selection participates in admission or measurement.
enum NoseSemanticOracle {
    enum Admission: Error { case dimensions, region, denominator, overflow, comparisons }

    struct Image {
        let bytes: [UInt8]
        let width: Int64
        let height: Int64

        init(_ bytes: [UInt8], width: Int64, height: Int64) throws {
            guard width > 0, height > 0 else { throw Admission.dimensions }
            let pixels = try multiply(width, height)
            let count = try multiply(pixels, 4)
            guard pixels <= 50_000_000, count == bytes.count else { throw Admission.dimensions }
            self.bytes = bytes
            self.width = width
            self.height = height
        }
    }

    struct Region {
        let minX: Int64
        let maxX: Int64
        let minY: Int64
        let maxY: Int64

        init(_ minX: Int64, _ maxX: Int64, _ minY: Int64, _ maxY: Int64) {
            self.minX = minX; self.maxX = maxX; self.minY = minY; self.maxY = maxY
        }

        func contains(_ x: Int64, _ y: Int64) -> Bool {
            minX <= x && x < maxX && minY <= y && y < maxY
        }

        func thirds() throws -> [Region] {
            let width = try subtract(maxX, minX)
            guard width >= 3 else { throw Admission.denominator }
            let a = try add(minX, width / 3)
            let b = try add(minX, multiply(width, 2) / 3)
            return [Region(minX, a, minY, maxY), Region(a, b, minY, maxY), Region(b, maxX, minY, maxY)]
        }

        func halves() throws -> [Region] {
            let split = try add(minX, maxX) / 2
            guard minX < split, split < maxX else { throw Admission.denominator }
            return [Region(minX, split, minY, maxY), Region(split, maxX, minY, maxY)]
        }
    }

    static let bridge = Region(420_000, 580_000, 360_000, 550_000)
    static let root = Region(400_000, 600_000, 200_000, 360_000)
    static let tip = Region(350_000, 650_000, 550_000, 700_000)
    static let background = [Region(0, 240_000, 80_000, 820_000), Region(760_000, 1_000_000, 80_000, 820_000)]
    static let watermark = Region(820_000, 980_000, 920_000, 985_000)

    enum CaseID: String, CaseIterable {
        case bridge = "noseBridge_0p30"
        case root = "noseRootNarrowing_0p25"

        var target: Region { self == .bridge ? NoseSemanticOracle.bridge : NoseSemanticOracle.root }
        var protectedNose: [Region] {
            [self == .bridge ? NoseSemanticOracle.root : NoseSemanticOracle.bridge, tip]
        }
        var siblingIDs: [String] {
            self == .bridge
                ? ["noseRootNarrowing_0p25", "noseSlim_0p35", "noseTipSize_plus0p30", "noseTipSize_minus0p30"]
                : ["noseBridge_0p30", "noseSlim_0p35", "noseTipLift_0p25"]
        }
    }

    struct Signal {
        var changed: Int64 = 0
        var rgb: Int64 = 0
        static func maximum(_ a: Signal, _ b: Signal) -> Signal {
            Signal(changed: max(a.changed, b.changed), rgb: max(a.rgb, b.rgb))
        }
    }

    struct Evaluation {
        var source: Signal
        var neutral: Signal
        var sourceMargin: Int64
        var neutralMargin: Int64
        var siblingMargins: [Int64]
        var outside: Signal
        var protectedNose: [Signal]
        var background: Signal
        var watermark: Signal

        var protectionPass: Bool {
            outside.changed <= 128 && outside.rgb <= 512 && protectedNose.count == 2
                && protectedNose.allSatisfy { $0.changed <= 64 && $0.rgb <= 256 }
                && background.changed == 0 && background.rgb == 0
                && watermark.changed == 0 && watermark.rgb == 0
        }

        func passes(_ id: CaseID) -> Bool {
            source.changed >= 500 && neutral.changed >= 500
                && source.rgb >= 2_000 && neutral.rgb >= 2_000
                && sourceMargin >= 16 && neutralMargin >= 16
                && siblingMargins.count == id.siblingIDs.count
                && siblingMargins.allSatisfy { $0 >= 16 } && protectionPass
        }
    }

    static func add(_ a: Int64, _ b: Int64) throws -> Int64 {
        let (value, overflow) = a.addingReportingOverflow(b)
        guard !overflow else { throw Admission.overflow }
        return value
    }

    static func subtract(_ a: Int64, _ b: Int64) throws -> Int64 {
        let (value, overflow) = a.subtractingReportingOverflow(b)
        guard !overflow else { throw Admission.overflow }
        return value
    }

    static func multiply(_ a: Int64, _ b: Int64) throws -> Int64 {
        let (value, overflow) = a.multipliedReportingOverflow(by: b)
        guard !overflow else { throw Admission.overflow }
        return value
    }

    static func absolute(_ value: Int64) throws -> Int64 {
        guard value != .min else { throw Admission.overflow }
        return abs(value)
    }

    static func rasterize(_ region: Region, width: Int64, height: Int64) throws -> Region {
        guard width > 0, height > 0 else { throw Admission.dimensions }
        guard [region.minX, region.maxX, region.minY, region.maxY].allSatisfy({ (0...1_000_000).contains($0) }),
              region.minX < region.maxX, region.minY < region.maxY else { throw Admission.region }
        let result = try Region(multiply(region.minX, width) / 1_000_000,
                                multiply(region.maxX, width) / 1_000_000,
                                multiply(region.minY, height) / 1_000_000,
                                multiply(region.maxY, height) / 1_000_000)
        guard result.minX < result.maxX, result.minY < result.maxY else { throw Admission.region }
        return result
    }

    static func admit(_ region: Region, image: Image) throws {
        guard region.minX >= 0, region.minY >= 0, region.maxX <= image.width,
              region.maxY <= image.height, region.minX < region.maxX,
              region.minY < region.maxY else { throw Admission.region }
    }

    static func pair(_ a: Image, _ b: Image) throws {
        guard a.width == b.width, a.height == b.height else { throw Admission.dimensions }
    }

    static func darkness(_ image: Image, _ x: Int64, _ y: Int64) -> Int64 {
        let index = Int((y * image.width + x) * 4)
        let luma = Int64(image.bytes[index]) * 77 + Int64(image.bytes[index + 1]) * 150
            + Int64(image.bytes[index + 2]) * 29
        return max(0, 255 * 256 - luma)
    }

    static func normalizedCentroidQ16(weightedX: Int64, weight: Int64, width: Int64) throws -> Int64 {
        guard weight > 0, width > 0, weightedX >= 0 else { throw Admission.denominator }
        let denominator = try multiply(weight, multiply(width, 2))
        return try multiply(weightedX, 65_536) / denominator
    }

    static func bridgeDefinitionGain(_ image: Image, region: Region) throws -> Int64 {
        try admit(region, image: image)
        let center = try region.thirds()[1]
        var centerSum: Int64 = 0, outerSum: Int64 = 0
        var centerCount: Int64 = 0, outerCount: Int64 = 0
        for y in region.minY..<region.maxY {
            for x in region.minX..<region.maxX {
                if center.contains(x, y) {
                    centerSum = try add(centerSum, darkness(image, x, y))
                    centerCount = try add(centerCount, 1)
                } else {
                    outerSum = try add(outerSum, darkness(image, x, y))
                    outerCount = try add(outerCount, 1)
                }
            }
        }
        guard centerCount > 0, outerCount > 0 else { throw Admission.denominator }
        // Literal Q8 mean difference: the comparator's report label is Q16.
        return try subtract(centerSum / centerCount, outerSum / outerCount)
    }

    static func rootWidthContraction(_ image: Image, region: Region) throws -> Int64 {
        try admit(region, image: image)
        let centroids = try region.halves().map { half -> Int64 in
            var weight: Int64 = 0, weightedX: Int64 = 0
            for y in half.minY..<half.maxY {
                for x in half.minX..<half.maxX {
                    let value = darkness(image, x, y)
                    weight = try add(weight, value)
                    weightedX = try add(weightedX, multiply(value, add(multiply(x, 2), 1)))
                }
            }
            return try normalizedCentroidQ16(weightedX: weightedX, weight: weight, width: image.width)
        }
        return try subtract(centroids[0], centroids[1])
    }

    static func signal(_ a: Image, _ b: Image, include: (Int64, Int64) -> Bool) throws -> Signal {
        try pair(a, b)
        var value = Signal()
        var compared: Int64 = 0
        for y in 0..<a.height {
            for x in 0..<a.width where include(x, y) {
                let index = Int((y * a.width + x) * 4)
                let r = abs(Int64(a.bytes[index]) - Int64(b.bytes[index]))
                let g = abs(Int64(a.bytes[index + 1]) - Int64(b.bytes[index + 1]))
                let blue = abs(Int64(a.bytes[index + 2]) - Int64(b.bytes[index + 2]))
                value.changed = try add(value.changed, max(r, g, blue) > 2 ? 1 : 0)
                value.rgb = try add(value.rgb, add(add(r, g), blue))
                compared = try add(compared, 1)
            }
        }
        guard compared > 0 else { throw Admission.region }
        return value
    }

    static func protection(_ source: Image, _ neutral: Image, _ candidate: Image,
                           regions: [Region], outside: Bool = false) throws -> Signal {
        let raster = try regions.map { try rasterize($0, width: source.width, height: source.height) }
        let include: (Int64, Int64) -> Bool = { x, y in
            raster.contains { $0.contains(x, y) } != outside
        }
        return try .maximum(signal(source, candidate, include: include), signal(neutral, candidate, include: include))
    }

    static func evaluate(caseID: CaseID, source: Image, neutral: Image, candidate: Image,
                         siblings: [String: Image]) throws -> Evaluation {
        try pair(source, neutral); try pair(source, candidate)
        guard Set(siblings.keys) == Set(caseID.siblingIDs) else { throw Admission.comparisons }
        for sibling in siblings.values { try pair(source, sibling) }
        let region = try rasterize(caseID.target, width: source.width, height: source.height)
        func metric(_ image: Image) throws -> Int64 {
            try caseID == .bridge ? bridgeDefinitionGain(image, region: region) : rootWidthContraction(image, region: region)
        }
        let candidateValue = try metric(candidate)
        return try Evaluation(
            source: signal(source, candidate, include: region.contains),
            neutral: signal(neutral, candidate, include: region.contains),
            sourceMargin: subtract(candidateValue, metric(source)),
            neutralMargin: subtract(candidateValue, metric(neutral)),
            siblingMargins: caseID.siblingIDs.map { try absolute(subtract(candidateValue, metric(siblings[$0]!))) },
            outside: protection(source, neutral, candidate, regions: [caseID.target], outside: true),
            protectedNose: caseID.protectedNose.map { try protection(source, neutral, candidate, regions: [$0]) },
            background: protection(source, neutral, candidate, regions: background),
            watermark: protection(source, neutral, candidate, regions: [watermark]))
    }
}

final class NoseSemanticMetricTests: XCTestCase {
    private typealias O = NoseSemanticOracle

    private func image(_ values: [UInt8], width: Int64, height: Int64) throws -> O.Image {
        try O.Image(values.flatMap { [$0, $0, $0, 255] }, width: width, height: height)
    }

    func testBridgeMetricLiteralScaleAndPolarity() throws {
        let region = O.Region(0, 6, 0, 1)
        let flat = try image([200, 200, 200, 200, 200, 200], width: 6, height: 1)
        let defined = try image([200, 200, 100, 100, 200, 200], width: 6, height: 1)
        let inverse = try image([100, 100, 200, 200, 100, 100], width: 6, height: 1)
        XCTAssertEqual(try O.bridgeDefinitionGain(flat, region: region), 0)
        XCTAssertEqual(try O.bridgeDefinitionGain(defined, region: region), 25_600)
        XCTAssertEqual(try O.bridgeDefinitionGain(inverse, region: region), -25_600)
        // Colored pixels prove the literal luma coefficients and integer division.
        let colored = try O.Image([255, 0, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255], width: 3, height: 1)
        XCTAssertEqual(try O.bridgeDefinitionGain(colored, region: .init(0, 3, 0, 1)), -24_735)
        let rounded = try O.Image([254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255], width: 3, height: 1)
        XCTAssertEqual(try O.bridgeDefinitionGain(rounded, region: .init(0, 3, 0, 1)), -38)
    }

    func testRootMetricHalfCentroidPolarity() throws {
        let region = O.Region(0, 8, 0, 1)
        let wide = try image([0, 255, 255, 255, 255, 255, 255, 0], width: 8, height: 1)
        let narrow = try image([255, 255, 255, 0, 0, 255, 255, 255], width: 8, height: 1)
        let wideValue = try O.rootWidthContraction(wide, region: region)
        let narrowValue = try O.rootWidthContraction(narrow, region: region)
        XCTAssertEqual(wideValue, -57_344)
        XCTAssertEqual(narrowValue, -8_192)
        XCTAssertEqual(narrowValue - wideValue, 49_152)
        XCTAssertEqual(try O.normalizedCentroidQ16(weightedX: 3, weight: 2, width: 7), 7_021)
    }

    func testMetricAdmissionRejectsInvalidDenominatorsAndDimensions() throws {
        let region = try O.rasterize(.init(100_001, 900_001, 200_001, 800_001), width: 13, height: 17)
        XCTAssertEqual(region.minX, 1); XCTAssertEqual(region.maxX, 11)
        XCTAssertEqual(region.minY, 3); XCTAssertEqual(region.maxY, 13)
        for (x, y, expected) in [(1, 3, true), (0, 3, false), (1, 2, false), (10, 3, true),
                                  (11, 3, false), (1, 12, true), (1, 13, false), (10, 12, true)] {
            XCTAssertEqual(region.contains(Int64(x), Int64(y)), expected)
        }
        let thirds = try region.thirds(), halves = try region.halves()
        XCTAssertTrue(thirds.map { [$0.minX, $0.maxX] } == [[1, 4], [4, 7], [7, 11]])
        XCTAssertTrue(halves.map { [$0.minX, $0.maxX] } == [[1, 6], [6, 11]])
        for (parts, bounds) in [(thirds, [(1, 4), (4, 7), (7, 11)]), (halves, [(1, 6), (6, 11)])] {
            for (part, bound) in zip(parts, bounds) {
                XCTAssertFalse(part.contains(Int64(bound.0 - 1), 3))
                XCTAssertTrue(part.contains(Int64(bound.0), 3))
                XCTAssertTrue(part.contains(Int64(bound.1 - 1), 3))
                XCTAssertFalse(part.contains(Int64(bound.1), 3))
            }
        }
        for invalid in [O.Region(-1, 9, 0, 9), .init(0, 1_000_001, 0, 9), .init(5, 5, 0, 9), .init(0, 9, 9, 0), .init(1, 2, 1, 2)] {
            XCTAssertThrowsError(try O.rasterize(invalid, width: 13, height: 17))
        }
        XCTAssertThrowsError(try O.rasterize(O.bridge, width: 0, height: 17))
        XCTAssertThrowsError(try O.rasterize(O.bridge, width: .max, height: 17))
        XCTAssertThrowsError(try O.Image([], width: .max, height: 4))
        XCTAssertThrowsError(try O.Image([], width: 0, height: 4))
        XCTAssertThrowsError(try O.Image([0], width: 1, height: 1))
        let white = try image([255, 255, 255, 255], width: 4, height: 1)
        let halfEmpty = try image([0, 255, 255, 255], width: 4, height: 1)
        XCTAssertThrowsError(try O.rootWidthContraction(white, region: .init(0, 4, 0, 1)))
        XCTAssertThrowsError(try O.rootWidthContraction(halfEmpty, region: .init(0, 4, 0, 1)))
        XCTAssertThrowsError(try O.rootWidthContraction(white, region: .init(0, 1, 0, 1)))
        XCTAssertThrowsError(try O.bridgeDefinitionGain(white, region: .init(0, 2, 0, 1)))
        XCTAssertThrowsError(try O.bridgeDefinitionGain(white, region: .init(0, 5, 0, 1)))
        XCTAssertThrowsError(try O.signal(white, image([1, 1, 1, 1], width: 2, height: 2), include: { _, _ in true }))
        XCTAssertThrowsError(try O.signal(white, white, include: { _, _ in false }))
        XCTAssertThrowsError(try O.normalizedCentroidQ16(weightedX: 1, weight: 0, width: 4))
        XCTAssertThrowsError(try O.normalizedCentroidQ16(weightedX: 1, weight: 1, width: 0))
        XCTAssertThrowsError(try O.normalizedCentroidQ16(weightedX: .max, weight: 1, width: 4))
        XCTAssertThrowsError(try O.normalizedCentroidQ16(weightedX: 1, weight: .max, width: 4))
        XCTAssertThrowsError(try O.add(.max, 1))
        XCTAssertThrowsError(try O.subtract(.min, 1))
        XCTAssertThrowsError(try O.absolute(.min))
    }

    func testSemanticConjunctionRejectsProxyOnlyChanges() throws {
        for id in O.CaseID.allCases {
            let edge = O.Evaluation(source: .init(changed: 500, rgb: 2_000), neutral: .init(changed: 500, rgb: 2_000),
                                    sourceMargin: 16, neutralMargin: 16,
                                    siblingMargins: Array(repeating: 16, count: id.siblingIDs.count),
                                    outside: .init(changed: 128, rgb: 512),
                                    protectedNose: [.init(changed: 64, rgb: 256), .init(changed: 64, rgb: 256)],
                                    background: .init(), watermark: .init())
            XCTAssertTrue(edge.passes(id))
            let mutations: [(inout O.Evaluation) -> Void] = [
                { $0.source.changed = 499 }, { $0.neutral.changed = 499 },
                { $0.source.rgb = 1_999 }, { $0.neutral.rgb = 1_999 },
                { $0.sourceMargin = 15 }, { $0.neutralMargin = 15 },
                { $0.outside.changed = 129 }, { $0.outside.rgb = 513 },
                { $0.background.changed = 1 }, { $0.background.rgb = 1 },
                { $0.watermark.changed = 1 }, { $0.watermark.rgb = 1 },
                { $0.siblingMargins.removeLast() }, { $0.protectedNose.removeLast() },
            ]
            for mutation in mutations { var value = edge; mutation(&value); XCTAssertFalse(value.passes(id)) }
            for index in edge.siblingMargins.indices {
                var value = edge; value.siblingMargins[index] = 15; XCTAssertFalse(value.passes(id))
            }
            for index in edge.protectedNose.indices {
                var value = edge; value.protectedNose[index].changed = 65; XCTAssertFalse(value.passes(id))
                value = edge; value.protectedNose[index].rgb = 257; XCTAssertFalse(value.passes(id))
            }
            // Handcrafted mutations prove the measurement conjunction, never provider credit.
            let source = try image(Array(repeating: 150, count: 100 * 100), width: 100, height: 100)
            let siblings = Dictionary(uniqueKeysWithValues: id.siblingIDs.map { ($0, source) })
            for region in [O.Region(0, 1_000_000, 0, 1_000_000), O.tip, O.watermark] {
                let raster = try O.rasterize(region, width: 100, height: 100)
                var bytes = source.bytes
                for y in 0..<100 { for x in 0..<100 where raster.contains(Int64(x), Int64(y)) {
                    for c in 0..<3 { bytes[(y * 100 + x) * 4 + c] = 140 }
                } }
                let changed = try O.Image(bytes, width: 100, height: 100)
                XCTAssertFalse(try O.evaluate(caseID: id, source: source, neutral: source, candidate: changed, siblings: siblings).passes(id))
            }
            XCTAssertFalse(try O.evaluate(caseID: id, source: source, neutral: source, candidate: source, siblings: siblings).passes(id))
            var missing = siblings; missing.removeValue(forKey: id.siblingIDs[0])
            XCTAssertThrowsError(try O.evaluate(caseID: id, source: source, neutral: source, candidate: source, siblings: missing))
            var extra = siblings; extra["unapproved"] = source
            XCTAssertThrowsError(try O.evaluate(caseID: id, source: source, neutral: source, candidate: source, siblings: extra))
            var mismatched = siblings; mismatched[id.siblingIDs[0]] = try image([150], width: 1, height: 1)
            XCTAssertThrowsError(try O.evaluate(caseID: id, source: source, neutral: source, candidate: source, siblings: mismatched))

            let full = try image(Array(repeating: 150, count: 512 * 512), width: 512, height: 512)
            let target = try O.rasterize(id.target, width: 512, height: 512)
            let center = try target.thirds()[1]
            let halves = try target.halves()
            var definedBytes = full.bytes
            for y in target.minY..<target.maxY { for x in target.minX..<target.maxX {
                let value: UInt8
                if id == .bridge {
                    value = center.contains(x, y) ? 50 : 150
                } else {
                    let leftMid = (halves[0].minX + halves[0].maxX) / 2
                    let rightMid = (halves[1].minX + halves[1].maxX) / 2
                    value = x >= leftMid && x < rightMid ? 120 : 180
                }
                let offset = Int((y * 512 + x) * 4)
                for channel in 0..<3 { definedBytes[offset + channel] = value }
            } }
            let defined = try O.Image(definedBytes, width: 512, height: 512)
            let controls = Dictionary(uniqueKeysWithValues: id.siblingIDs.map { ($0, full) })
            XCTAssertTrue(try O.evaluate(caseID: id, source: full, neutral: full, candidate: defined, siblings: controls).passes(id))
            for siblingID in id.siblingIDs {
                var aliased = controls; aliased[siblingID] = defined
                XCTAssertFalse(try O.evaluate(caseID: id, source: full, neutral: full, candidate: defined, siblings: aliased).passes(id))
            }
            XCTAssertFalse(try O.evaluate(caseID: id, source: full, neutral: defined, candidate: defined, siblings: controls).passes(id))
            for protectedRegion in id.protectedNose + O.background + [O.watermark] {
                let raster = try O.rasterize(protectedRegion, width: 512, height: 512)
                var leakedBytes = definedBytes
                for y in raster.minY..<raster.maxY { for x in raster.minX..<raster.maxX {
                    for channel in 0..<3 { leakedBytes[Int((y * 512 + x) * 4) + channel] = 50 }
                } }
                let leaked = try O.Image(leakedBytes, width: 512, height: 512)
                XCTAssertFalse(try O.evaluate(caseID: id, source: full, neutral: full, candidate: leaked, siblings: controls).passes(id))
            }
        }
        let source = try image([150, 150], width: 2, height: 1)
        let candidate = try image([148, 147], width: 2, height: 1)
        let tolerance = try O.signal(source, candidate, include: { _, _ in true })
        XCTAssertEqual(tolerance.changed, 1); XCTAssertEqual(tolerance.rgb, 15)
    }
}
