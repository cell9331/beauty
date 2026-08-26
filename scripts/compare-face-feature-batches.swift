import CoreGraphics
import CoreImage
import CryptoKit
import Darwin
import Foundation

enum SemanticMetricKind: String, Codable, CaseIterable {
    case contourContinuityGain
    case centerlineTaper
    case pupilToOwnEyeCenter
    case innerBrowHeadGap
    case bridgeDefinitionGain
    case rootWidthContraction
    case mouthWidthContraction
}

enum ExpectedSign: String, Codable, CaseIterable {
    case positive
    case negative
}

struct NormalizedRegion: Codable, Equatable {
    let id: String?
    let minXPPM: Int
    let maxXPPM: Int
    let minYPPM: Int
    let maxYPPM: Int
}

struct ProtectedRegionContract: Codable, Equatable {
    let id: String
    let regions: [NormalizedRegion]
    let maximumChangedPixels: Int
    let maximumAbsoluteRGBDelta: Int
}

struct SemanticThresholds: Codable, Equatable {
    let minimumChangedPixels: Int
    let minimumAbsoluteRGBDelta: Int
    let minimumSignedMarginQ16: Int
    let maximumOutsideChangedPixels: Int
    let maximumOutsideAbsoluteRGBDelta: Int
}

struct SemanticContract: Codable, Equatable {
    let caseID: String
    let metric: SemanticMetricKind
    let expectedSign: ExpectedSign
    let comparisonCaseIDs: [String]
    let targetRegions: [NormalizedRegion]
    let thresholds: SemanticThresholds
    let protectedRegions: [ProtectedRegionContract]
}

struct BatchManifest: Codable, Equatable {
    let schemaVersion: String
    let control: Control
    let batches: [Batch]
    let semanticContracts: [SemanticContract]?

    struct Control: Codable, Equatable {
        let id: String
        let label: String
    }

    struct Batch: Codable, Equatable {
        let id: String
        let label: String
        let cases: [String]
    }
}

struct MechanicalCaseSummary: Codable, Equatable {
    let batchID: String
    let caseID: String
    let fixtureCount: Int
    let outputCount: Int
    let missingOutputCount: Int
    let sourceChangedPixels: Int
    let sourceComparedPixels: Int
    let sourceAbsoluteRGBDelta: Int64
    let sourceMaxRGBDelta: Int
    let neutralChangedPixels: Int
    let neutralComparedPixels: Int
    let neutralAbsoluteRGBDelta: Int64
    let neutralMaxRGBDelta: Int
    let descriptiveStatus: String
}

struct BatchSummary: Codable, Equatable {
    let id: String
    let caseCount: Int
    let completeCaseCount: Int
    let missingOutputCount: Int
}

struct ProtectedRegionSummary: Codable, Equatable {
    let id: String
    let changedPixels: Int64
    let absoluteRGBDelta: Int64
}

struct SemanticDirectionSummary: Codable, Equatable {
    let caseID: String
    let metric: SemanticMetricKind
    let fixtureCount: Int
    let sourceTargetChangedPixels: Int64
    let sourceTargetAbsoluteRGBDelta: Int64
    let neutralTargetChangedPixels: Int64
    let neutralTargetAbsoluteRGBDelta: Int64
    let sourceSignedMarginQ16: Int64
    let neutralSignedMarginQ16: Int64
    let signedMarginQ16: Int64
    let siblingDistinctMarginQ16: Int64
    let outsideChangedPixels: Int64
    let outsideAbsoluteRGBDelta: Int64
    let protectedRegions: [ProtectedRegionSummary]
    let failureReasonCodes: [String]
    let verdict: String
}

struct StableSemanticPayload: Codable, Equatable {
    let schemaVersion: String
    let contractID: String
    let cpuReferenceToken: String
    let fixtureCount: Int
    let fixtureIDs: [String]
    let watermarkExcludedRowCount: Int
    let batches: [BatchSummary]
    let mechanicalCases: [MechanicalCaseSummary]
    let semanticDirections: [SemanticDirectionSummary]
    let verdict: String
}

struct SemanticReportEnvelope: Codable, Equatable {
    struct VolatileRunMetadata: Codable, Equatable {
        let generatedAtUTC: String
        let attemptID: String
    }

    let volatile: VolatileRunMetadata
    let stablePayloadDigest: String
    let stablePayload: StableSemanticPayload
}

enum SemanticExitCode: Int32 {
    case success = 0
    case semanticFailure = 2
    case infrastructureFailure = 3
}

struct CanonicalImage {
    let width: Int
    let height: Int
    let rgba: [UInt8]
}

struct ComparisonMetrics {
    let comparedPixels: Int
    let changedPixels: Int
    let absoluteRGBDelta: Int64
    let meanAbsoluteRGBDelta: Double
    let maxRGBDelta: Int
}

enum CompareError: Error, CustomStringConvertible {
    case invalidArguments(String)
    case invalidManifest(String)
    case imageDecodeFailed(String)
    case dimensionMismatch(String)
    case outputMissing(String)

    var description: String {
        switch self {
        case .invalidArguments: return "invalid_arguments"
        case .invalidManifest: return "invalid_manifest"
        case .imageDecodeFailed: return "image_decode"
        case .dimensionMismatch: return "dimension_mismatch"
        case .outputMissing: return "output_missing"
        }
    }
}

enum SemanticContractError: String, Error, CustomStringConvertible {
    case decode = "decode"
    case schema = "schema"
    case inventory = "inventory"
    case contracts = "contracts"
    case order = "order"
    case identifier = "identifier"
    case reference = "reference"
    case region = "region"
    case overlap = "overlap"
    case threshold = "threshold"
    case admission = "admission"
    case unsupportedMetric = "unsupported_metric"
    case arithmetic = "arithmetic"
    case verdict = "verdict"

    var description: String { rawValue }
}

private let expectedBatchInventory: [(String, [String])] = [
    ("face-shape", [
        "faceShapeCombo_0p35", "faceSlim_0p35", "faceSmall_0p35",
        "chinLength_plus0p30", "chinLength_minus0p30", "faceVShape_0p35",
        "jawSlim_0p35", "faceContourSmooth_0p25", "templeFullness_0p25",
        "cheekboneSlim_0p25", "chinTaper_0p25"
    ]),
    ("eyes", [
        "eyeSize_0p35", "eyeDistance_plus0p25", "eyeDistance_minus0p25",
        "eyeYPosition_plus0p20", "eyeYPosition_minus0p20", "eyeTailLift_0p25",
        "eyeHeight_0p25", "eyeLength_0p25", "upperEyelidLift_0p25",
        "pupilSize_0p25", "gazeCorrection_0p25", "lowerEyelidDrop_0p25",
        "eyeTilt_plus0p25", "eyeTilt_minus0p25", "innerCornerOpen_0p25",
        "outerCornerOpen_0p25", "eyeSymmetry_0p25", "scleraRednessReduction_1p00",
        "upperEyelidFullnessReduction_1p00"
    ]),
    ("eyebrows", [
        "eyebrowYPosition_plus0p25", "eyebrowYPosition_minus0p25",
        "eyebrowThickness_plus0p25", "eyebrowThickness_minus0p25",
        "eyebrowLength_plus0p25", "eyebrowLength_minus0p25",
        "eyebrowSpacing_plus0p25", "eyebrowSpacing_minus0p25",
        "eyebrowHeadSpacing_plus0p25", "eyebrowHeadSpacing_minus0p25",
        "eyebrowTilt_plus0p25", "eyebrowTilt_minus0p25",
        "eyebrowPeakDefinition_0p25"
    ]),
    ("nose", [
        "noseSlim_0p35", "noseWingSlim_0p35", "noseTipSize_plus0p30",
        "noseTipSize_minus0p30", "noseBridge_0p30", "noseRootNarrowing_0p25",
        "noseTipLift_0p25"
    ]),
    ("mouth", [
        "mouthSize_plus0p35", "mouthSize_minus0p35", "mouthWidth_plus0p35",
        "mouthWidth_minus0p35", "smile_0p50", "lipColor_0p50",
        "mouthYPosition_plus0p25", "mouthYPosition_minus0p25",
        "mouthTilt_plus0p25", "mouthTilt_minus0p25", "mouthXPosition_plus0p25",
        "mouthXPosition_minus0p25", "lipPeakDefinition_0p25", "lipPlump_0p25",
        "teethWhitening_1p00"
    ])
]

private struct ExpectedSemanticContract {
    let caseID: String
    let metric: SemanticMetricKind
    let sign: ExpectedSign
    let comparisons: [String]
}

private let expectedSemanticContracts: [ExpectedSemanticContract] = [
    .init(caseID: "faceContourSmooth_0p25", metric: .contourContinuityGain, sign: .positive,
          comparisons: ["source", "geometryBaseline_noop", "faceSmall_0p35", "faceSlim_0p35"]),
    .init(caseID: "chinTaper_0p25", metric: .centerlineTaper, sign: .positive,
          comparisons: ["source", "geometryBaseline_noop", "chinLength_plus0p30", "chinLength_minus0p30", "faceVShape_0p35", "jawSlim_0p35"]),
    .init(caseID: "gazeCorrection_0p25", metric: .pupilToOwnEyeCenter, sign: .positive,
          comparisons: ["source", "geometryBaseline_noop", "pupilSize_0p25", "eyeSize_0p35", "eyeDistance_plus0p25"]),
    .init(caseID: "eyebrowHeadSpacing_plus0p25", metric: .innerBrowHeadGap, sign: .positive,
          comparisons: ["source", "geometryBaseline_noop", "eyebrowHeadSpacing_minus0p25", "eyebrowSpacing_plus0p25", "eyebrowSpacing_minus0p25"]),
    .init(caseID: "eyebrowHeadSpacing_minus0p25", metric: .innerBrowHeadGap, sign: .negative,
          comparisons: ["source", "geometryBaseline_noop", "eyebrowHeadSpacing_plus0p25", "eyebrowSpacing_plus0p25", "eyebrowSpacing_minus0p25"]),
    .init(caseID: "noseBridge_0p30", metric: .bridgeDefinitionGain, sign: .positive,
          comparisons: ["source", "geometryBaseline_noop", "noseRootNarrowing_0p25", "noseSlim_0p35", "noseTipSize_plus0p30", "noseTipSize_minus0p30"]),
    .init(caseID: "noseRootNarrowing_0p25", metric: .rootWidthContraction, sign: .positive,
          comparisons: ["source", "geometryBaseline_noop", "noseBridge_0p30", "noseSlim_0p35", "noseTipLift_0p25"]),
    .init(caseID: "mouthWidth_minus0p35", metric: .mouthWidthContraction, sign: .negative,
          comparisons: ["source", "geometryBaseline_noop", "mouthWidth_plus0p35", "mouthSize_plus0p35", "mouthSize_minus0p35"])
]

// Independent authority for every value in the eight semantic contracts. The
// digest is over the compact, sorted-key JSON encoding of semanticContracts,
// so manifest edits cannot redefine the regions or acceptance boundaries that
// the executable and its generated probes enforce.
private let expectedSemanticContractsDigest = "7da6662ec2d13c4caf1d9f74b23fae186b8330aa545bead503700d061e4a8298"

private func semanticContractsDigest(_ contracts: [SemanticContract]) throws -> String {
    let encoded = try JSONEncoder().encode(contracts)
    let object = try JSONSerialization.jsonObject(with: encoded)
    let canonical = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
    return sha256Hex(canonical)
}

private struct RasterizedRegion: Equatable {
    let minX: Int64
    let maxX: Int64
    let minY: Int64
    let maxY: Int64
}

private func isStableIdentifier(_ value: String) -> Bool {
    !value.isEmpty && value.unicodeScalars.allSatisfy {
        ($0.value >= 48 && $0.value <= 57) ||
        ($0.value >= 65 && $0.value <= 90) ||
        ($0.value >= 97 && $0.value <= 122) || $0.value == 95
    }
}

private func checkedScale(_ ppm: Int, by extent: Int64) throws -> Int64 {
    let (product, overflow) = Int64(ppm).multipliedReportingOverflow(by: extent)
    guard !overflow else { throw SemanticContractError.arithmetic }
    return product / 1_000_000
}

private func rasterize(_ region: NormalizedRegion, width: Int64, height: Int64) throws -> RasterizedRegion {
    guard width > 0, height > 0 else { throw SemanticContractError.region }
    let values = [region.minXPPM, region.maxXPPM, region.minYPPM, region.maxYPPM]
    guard values.allSatisfy({ 0...1_000_000 ~= $0 }),
          region.minXPPM < region.maxXPPM,
          region.minYPPM < region.maxYPPM else {
        throw SemanticContractError.region
    }
    let result = RasterizedRegion(
        minX: try checkedScale(region.minXPPM, by: width),
        maxX: try checkedScale(region.maxXPPM, by: width),
        minY: try checkedScale(region.minYPPM, by: height),
        maxY: try checkedScale(region.maxYPPM, by: height)
    )
    guard result.minX < result.maxX, result.minY < result.maxY else {
        throw SemanticContractError.region
    }
    return result
}

private func overlaps(_ lhs: RasterizedRegion, _ rhs: RasterizedRegion) -> Bool {
    lhs.minX < rhs.maxX && rhs.minX < lhs.maxX && lhs.minY < rhs.maxY && rhs.minY < lhs.maxY
}

private func validateOwnership(_ contract: SemanticContract, width: Int64, height: Int64) throws {
    let allRegions = contract.targetRegions + contract.protectedRegions.flatMap { $0.regions }
    let rasterized = try allRegions.map { try rasterize($0, width: width, height: height) }
    for first in rasterized.indices {
        for second in rasterized.indices where second > first {
            if overlaps(rasterized[first], rasterized[second]) {
                throw SemanticContractError.overlap
            }
        }
    }
}

private func validateManifestData(_ data: Data) throws -> BatchManifest {
    let manifest: BatchManifest
    do {
        manifest = try JSONDecoder().decode(BatchManifest.self, from: data)
    } catch {
        throw SemanticContractError.decode
    }
    try validateManifest(manifest)
    return manifest
}

private func validateManifest(_ manifest: BatchManifest) throws {
    guard manifest.schemaVersion == "beauty.face-feature-batch-manifest.semantic.1",
          manifest.control.id == "geometryBaseline_noop" else {
        throw SemanticContractError.schema
    }
    guard manifest.batches.count == expectedBatchInventory.count else {
        throw SemanticContractError.inventory
    }
    for (batch, expected) in zip(manifest.batches, expectedBatchInventory) {
        guard batch.id == expected.0, batch.cases == expected.1 else {
            throw SemanticContractError.inventory
        }
    }
    let allCases = manifest.batches.flatMap { $0.cases }
    guard allCases.count == 65, Set(allCases).count == 65,
          !allCases.contains(manifest.control.id) else {
        throw SemanticContractError.inventory
    }
    guard let contracts = manifest.semanticContracts, !contracts.isEmpty,
          contracts.count == expectedSemanticContracts.count else {
        throw SemanticContractError.contracts
    }
    guard contracts.map({ $0.caseID }) == expectedSemanticContracts.map({ $0.caseID }) else {
        throw SemanticContractError.order
    }
    let caseSet = Set(allCases)
    for (contract, expected) in zip(contracts, expectedSemanticContracts) {
        guard isStableIdentifier(contract.caseID), caseSet.contains(contract.caseID),
              contract.metric == expected.metric, contract.expectedSign == expected.sign else {
            throw SemanticContractError.identifier
        }
        guard contract.comparisonCaseIDs == expected.comparisons,
              Set(contract.comparisonCaseIDs).count == contract.comparisonCaseIDs.count,
              contract.comparisonCaseIDs.dropFirst().allSatisfy({ $0 == manifest.control.id || caseSet.contains($0) }) else {
            throw SemanticContractError.reference
        }
        guard !contract.targetRegions.isEmpty, !contract.protectedRegions.isEmpty else {
            throw SemanticContractError.region
        }
        let targetIDs = contract.targetRegions.compactMap { $0.id }
        guard targetIDs.count == contract.targetRegions.count,
              Set(targetIDs).count == targetIDs.count,
              targetIDs.allSatisfy(isStableIdentifier) else {
            throw SemanticContractError.identifier
        }
        let protectedIDs = contract.protectedRegions.map { $0.id }
        guard Set(protectedIDs).count == protectedIDs.count,
              protectedIDs.allSatisfy(isStableIdentifier) else {
            throw SemanticContractError.identifier
        }
        guard contract.protectedRegions.allSatisfy({ !$0.regions.isEmpty }) else {
            throw SemanticContractError.region
        }
        for region in contract.targetRegions + contract.protectedRegions.flatMap({ $0.regions }) {
            _ = try rasterize(region, width: 1_000_000, height: 1_000_000)
        }
        try validateOwnership(contract, width: 1_000_000, height: 1_000_000)

        let thresholds = contract.thresholds
        guard thresholds.minimumChangedPixels > 0,
              thresholds.minimumAbsoluteRGBDelta > 0,
              thresholds.minimumSignedMarginQ16 > 0,
              thresholds.maximumOutsideChangedPixels >= 0,
              thresholds.maximumOutsideAbsoluteRGBDelta >= 0,
              contract.protectedRegions.allSatisfy({
                  $0.maximumChangedPixels >= 0 && $0.maximumAbsoluteRGBDelta >= 0
              }) else {
            throw SemanticContractError.threshold
        }
        for protected in contract.protectedRegions where protected.id == "background" || protected.id == "watermark" {
            guard protected.maximumChangedPixels == 0,
                  protected.maximumAbsoluteRGBDelta == 0 else {
                throw SemanticContractError.threshold
            }
        }
    }
    guard try semanticContractsDigest(contracts) == expectedSemanticContractsDigest else {
        throw SemanticContractError.contracts
    }
}

private struct RegionSignal: Codable, Equatable {
    let comparedPixels: Int64
    let changedPixels: Int64
    let absoluteRGBDelta: Int64
}

private struct ProtectedMeasurement: Codable, Equatable {
    let id: String
    let changedPixels: Int64
    let absoluteRGBDelta: Int64
}

private enum SemanticFailureReason: String, Codable, CaseIterable {
    case sourceTargetSignal = "source_target_signal"
    case neutralTargetSignal = "neutral_target_signal"
    case sourceDirection = "source_direction"
    case neutralDirection = "neutral_direction"
    case outsideLocality = "outside_locality"
    case protectedRegion = "protected_region"
    case siblingAlias = "sibling_alias"
}

private struct SemanticMeasurement: Equatable {
    let sourceTarget: RegionSignal
    let neutralTarget: RegionSignal
    let sourceSignedMarginQ16: Int64
    let neutralSignedMarginQ16: Int64
    let signedMarginQ16: Int64
    let siblingDistinctMarginQ16: Int64
    let outsideChangedPixels: Int64
    let outsideAbsoluteRGBDelta: Int64
    let protected: [ProtectedMeasurement]
    let failureReasons: [SemanticFailureReason]

    var semanticPass: Bool { failureReasons.isEmpty }
}

private struct WeightedMoment {
    var weight: Int64 = 0
    var weightedX: Int64 = 0
    var weightedY: Int64 = 0
    var pixelCount: Int64 = 0
}

private func checkedMultiply(_ lhs: Int64, _ rhs: Int64) throws -> Int64 {
    let (value, overflow) = lhs.multipliedReportingOverflow(by: rhs)
    guard !overflow else { throw SemanticContractError.arithmetic }
    return value
}

private func checkedAbsolute(_ value: Int64) throws -> Int64 {
    guard value != Int64.min else { throw SemanticContractError.arithmetic }
    return Swift.abs(value)
}

private func watermarkExcludedRows(width: Int) -> Int {
    let fontSize = max(34.0, min(72.0, Double(width) / 30.0))
    let padding = max(24.0, Double(width) / 70.0)
    return Int(ceil(padding * 2.0 + fontSize * 1.75))
}

private func validateCanonicalPair(_ lhs: CanonicalImage, _ rhs: CanonicalImage) throws {
    guard lhs.width > 0, lhs.height > 0,
          lhs.width == rhs.width, lhs.height == rhs.height else {
        throw SemanticContractError.admission
    }
    let pixels = try checkedMultiply(Int64(lhs.width), Int64(lhs.height))
    let byteCount = try checkedMultiply(pixels, 4)
    guard byteCount == Int64(lhs.rgba.count), byteCount == Int64(rhs.rgba.count) else {
        throw SemanticContractError.admission
    }
}

private func watermarkSafeRegions(
    _ regions: [NormalizedRegion], image: CanonicalImage, excludedRows: Int,
    allowEmpty: Bool = false
) throws -> [RasterizedRegion] {
    let comparableMaxY = Int64(max(0, image.height - excludedRows))
    let rasterized = try regions.map {
        try rasterize($0, width: Int64(image.width), height: Int64(image.height))
    }.compactMap { region -> RasterizedRegion? in
        let clippedMaxY = min(region.maxY, comparableMaxY)
        guard region.minY < clippedMaxY else { return nil }
        return RasterizedRegion(
            minX: region.minX, maxX: region.maxX,
            minY: region.minY, maxY: clippedMaxY
        )
    }
    guard allowEmpty || !rasterized.isEmpty else { throw SemanticContractError.admission }
    return rasterized
}

private func contains(_ regions: [RasterizedRegion], x: Int64, y: Int64) -> Bool {
    regions.contains { $0.minX <= x && x < $0.maxX && $0.minY <= y && y < $0.maxY }
}

private func lumaQ8(_ image: CanonicalImage, x: Int, y: Int) -> Int64 {
    let index = (y * image.width + x) * 4
    return Int64(image.rgba[index]) * 77 +
        Int64(image.rgba[index + 1]) * 150 +
        Int64(image.rgba[index + 2]) * 29
}

private func darknessMoment(
    _ image: CanonicalImage,
    regions: [RasterizedRegion]
) throws -> WeightedMoment {
    var result = WeightedMoment()
    for region in regions {
        for y in Int(region.minY)..<Int(region.maxY) {
            for x in Int(region.minX)..<Int(region.maxX) {
                let luma = lumaQ8(image, x: x, y: y)
                let weight = max(0, Int64(255 * 256) - luma)
                if weight == 0 { continue }
                result.weight = try checkedAdd(result.weight, weight)
                result.weightedX = try checkedAdd(result.weightedX, try checkedMultiply(weight, Int64(x) * 2 + 1))
                result.weightedY = try checkedAdd(result.weightedY, try checkedMultiply(weight, Int64(y) * 2 + 1))
                result.pixelCount = try checkedAdd(result.pixelCount, 1)
            }
        }
    }
    guard result.weight > 0, result.pixelCount > 0 else { throw SemanticContractError.admission }
    return result
}

private func normalizedCentroidQ16(
    weightedCoordinate: Int64, weight: Int64, extent: Int
) throws -> Int64 {
    guard weight > 0, extent > 0 else { throw SemanticContractError.admission }
    let denominator = try checkedMultiply(weight, Int64(extent) * 2)
    return try checkedMultiply(weightedCoordinate, 65_536) / denominator
}

private func contourContinuityGain(
    _ image: CanonicalImage, regions: [RasterizedRegion]
) throws -> Int64 {
    var totalRoughness: Int64 = 0
    var secondDifferences: Int64 = 0
    for region in regions {
        var rowCentroids: [Int64] = []
        for y in Int(region.minY)..<Int(region.maxY) {
            let row = RasterizedRegion(minX: region.minX, maxX: region.maxX, minY: Int64(y), maxY: Int64(y + 1))
            let moment = try darknessMoment(image, regions: [row])
            rowCentroids.append(try normalizedCentroidQ16(
                weightedCoordinate: moment.weightedX, weight: moment.weight, extent: image.width
            ))
        }
        guard rowCentroids.count >= 3 else { throw SemanticContractError.admission }
        for index in 1..<(rowCentroids.count - 1) {
            let doubled = try checkedMultiply(rowCentroids[index], 2)
            let difference = try checkedAdd(try checkedAdd(rowCentroids[index - 1], rowCentroids[index + 1]), -doubled)
            totalRoughness = try checkedAdd(totalRoughness, try checkedAbsolute(difference))
            secondDifferences = try checkedAdd(secondDifferences, 1)
        }
    }
    guard secondDifferences > 0 else { throw SemanticContractError.admission }
    return -(totalRoughness / secondDifferences)
}

private func centerlineTaper(
    _ image: CanonicalImage, regions: [RasterizedRegion]
) throws -> Int64 {
    let moment = try darknessMoment(image, regions: regions)
    var weightedDistance: Int64 = 0
    for region in regions {
        for y in Int(region.minY)..<Int(region.maxY) {
            for x in Int(region.minX)..<Int(region.maxX) {
                let weight = max(0, Int64(255 * 256) - lumaQ8(image, x: x, y: y))
                if weight == 0 { continue }
                let distance = try checkedAbsolute(Int64(x) * 2 + 1 - Int64(image.width))
                weightedDistance = try checkedAdd(weightedDistance, try checkedMultiply(weight, distance))
            }
        }
    }
    let denominator = try checkedMultiply(moment.weight, Int64(image.width))
    return -(try checkedMultiply(weightedDistance, 65_536) / denominator)
}

private func innerBrowHeadGap(
    _ image: CanonicalImage, regions: [RasterizedRegion]
) throws -> Int64 {
    guard regions.count == 2 else { throw SemanticContractError.admission }
    let centroids = try regions.map { region -> Int64 in
        let moment = try darknessMoment(image, regions: [region])
        return try normalizedCentroidQ16(
            weightedCoordinate: moment.weightedX, weight: moment.weight, extent: image.width
        )
    }.sorted()
    return centroids[1] - centroids[0]
}

private func bridgeDefinitionGain(
    _ image: CanonicalImage, regions: [RasterizedRegion]
) throws -> Int64 {
    guard regions.count == 1 else { throw SemanticContractError.admission }
    let region = regions[0]
    let width = region.maxX - region.minX
    guard width >= 3 else { throw SemanticContractError.admission }
    let centerMin = region.minX + width / 3
    let centerMax = region.minX + width * 2 / 3
    var centerDarkness: Int64 = 0
    var centerCount: Int64 = 0
    var outerDarkness: Int64 = 0
    var outerCount: Int64 = 0
    for y in Int(region.minY)..<Int(region.maxY) {
        for x in Int(region.minX)..<Int(region.maxX) {
            let darkness = max(0, Int64(255 * 256) - lumaQ8(image, x: x, y: y))
            if Int64(x) >= centerMin && Int64(x) < centerMax {
                centerDarkness = try checkedAdd(centerDarkness, darkness)
                centerCount = try checkedAdd(centerCount, 1)
            } else {
                outerDarkness = try checkedAdd(outerDarkness, darkness)
                outerCount = try checkedAdd(outerCount, 1)
            }
        }
    }
    guard centerCount > 0, outerCount > 0 else { throw SemanticContractError.admission }
    return centerDarkness / centerCount - outerDarkness / outerCount
}

private func darkHalfCentroidSpanQ16(
    _ image: CanonicalImage, region: RasterizedRegion
) throws -> Int64 {
    let split = (region.minX + region.maxX) / 2
    guard region.minX < split, split < region.maxX else { throw SemanticContractError.admission }
    let halves = [
        RasterizedRegion(minX: region.minX, maxX: split, minY: region.minY, maxY: region.maxY),
        RasterizedRegion(minX: split, maxX: region.maxX, minY: region.minY, maxY: region.maxY)
    ]
    let centroids = try halves.map { half -> Int64 in
        let moment = try darknessMoment(image, regions: [half])
        return try normalizedCentroidQ16(
            weightedCoordinate: moment.weightedX, weight: moment.weight, extent: image.width
        )
    }
    return centroids[1] - centroids[0]
}

private func rootWidthContraction(
    _ image: CanonicalImage, regions: [RasterizedRegion]
) throws -> Int64 {
    guard regions.count == 1 else { throw SemanticContractError.admission }
    return -(try darkHalfCentroidSpanQ16(image, region: regions[0]))
}

private func mouthWidthContraction(
    _ image: CanonicalImage, regions: [RasterizedRegion]
) throws -> Int64 {
    guard regions.count == 2 else { throw SemanticContractError.admission }
    let centroids = try regions.map { region -> Int64 in
        let moment = try darknessMoment(image, regions: [region])
        return try normalizedCentroidQ16(
            weightedCoordinate: moment.weightedX, weight: moment.weight, extent: image.width
        )
    }.sorted()
    return centroids[1] - centroids[0]
}

private func semanticMetricValue(
    kind: SemanticMetricKind,
    image: CanonicalImage,
    regions: [RasterizedRegion]
) throws -> Int64 {
    switch kind {
    case .contourContinuityGain: return try contourContinuityGain(image, regions: regions)
    case .centerlineTaper: return try centerlineTaper(image, regions: regions)
    case .pupilToOwnEyeCenter:
        // A target-box dark-pixel centroid is not anatomical pupil/eye support.
        // No approved request-local anatomy source exists in this milestone, so
        // the direction is non-creditable instead of falling back to a proxy.
        throw SemanticContractError.unsupportedMetric
    case .innerBrowHeadGap: return try innerBrowHeadGap(image, regions: regions)
    case .bridgeDefinitionGain: return try bridgeDefinitionGain(image, regions: regions)
    case .rootWidthContraction: return try rootWidthContraction(image, regions: regions)
    case .mouthWidthContraction: return try mouthWidthContraction(image, regions: regions)
    }
}

private func regionSignal(
    _ lhs: CanonicalImage,
    _ rhs: CanonicalImage,
    include: (Int64, Int64) -> Bool,
    watermarkRows: Int,
    tolerance: Int = 2
) throws -> RegionSignal {
    try validateCanonicalPair(lhs, rhs)
    let comparableRows = max(0, lhs.height - watermarkRows)
    var result = RegionSignal(comparedPixels: 0, changedPixels: 0, absoluteRGBDelta: 0)
    for y in 0..<comparableRows {
        for x in 0..<lhs.width where include(Int64(x), Int64(y)) {
            let index = (y * lhs.width + x) * 4
            let red = Swift.abs(Int(lhs.rgba[index]) - Int(rhs.rgba[index]))
            let green = Swift.abs(Int(lhs.rgba[index + 1]) - Int(rhs.rgba[index + 1]))
            let blue = Swift.abs(Int(lhs.rgba[index + 2]) - Int(rhs.rgba[index + 2]))
            result = RegionSignal(
                comparedPixels: try checkedAdd(result.comparedPixels, 1),
                changedPixels: try checkedAdd(result.changedPixels, max(red, green, blue) > tolerance ? 1 : 0),
                absoluteRGBDelta: try checkedAdd(result.absoluteRGBDelta, Int64(red + green + blue))
            )
        }
    }
    guard result.comparedPixels > 0 else { throw SemanticContractError.admission }
    return result
}

private func conservativeSignal(_ lhs: RegionSignal, _ rhs: RegionSignal) -> RegionSignal {
    RegionSignal(
        comparedPixels: min(lhs.comparedPixels, rhs.comparedPixels),
        changedPixels: max(lhs.changedPixels, rhs.changedPixels),
        absoluteRGBDelta: max(lhs.absoluteRGBDelta, rhs.absoluteRGBDelta)
    )
}

private func semanticMeasurement(
    contract: SemanticContract,
    source: CanonicalImage,
    neutral: CanonicalImage,
    candidate: CanonicalImage,
    siblings: [CanonicalImage],
    watermarkRows: Int
) throws -> SemanticMeasurement {
    try validateCanonicalPair(source, neutral)
    try validateCanonicalPair(source, candidate)
    guard siblings.count == contract.comparisonCaseIDs.count - 2 else {
        throw SemanticContractError.admission
    }
    for sibling in siblings { try validateCanonicalPair(source, sibling) }
    let target = try watermarkSafeRegions(contract.targetRegions, image: source, excludedRows: watermarkRows)
    let sourceTarget = try regionSignal(source, candidate, include: { contains(target, x: $0, y: $1) }, watermarkRows: watermarkRows)
    let neutralTarget = try regionSignal(neutral, candidate, include: { contains(target, x: $0, y: $1) }, watermarkRows: watermarkRows)
    let sourceValue = try semanticMetricValue(kind: contract.metric, image: source, regions: target)
    let neutralValue = try semanticMetricValue(kind: contract.metric, image: neutral, regions: target)
    let candidateValue = try semanticMetricValue(kind: contract.metric, image: candidate, regions: target)
    let sourceMargin = try checkedAdd(candidateValue, -sourceValue)
    let neutralMargin = try checkedAdd(candidateValue, -neutralValue)
    let signedMargin = contract.expectedSign == .positive
        ? min(sourceMargin, neutralMargin)
        : max(sourceMargin, neutralMargin)

    var siblingMargin = Int64.max
    for sibling in siblings {
        let siblingValue = try semanticMetricValue(kind: contract.metric, image: sibling, regions: target)
        siblingMargin = min(siblingMargin, try checkedAbsolute(try checkedAdd(candidateValue, -siblingValue)))
    }
    guard siblingMargin != Int64.max else { throw SemanticContractError.admission }

    let sourceOutside = try regionSignal(source, candidate, include: { !contains(target, x: $0, y: $1) }, watermarkRows: watermarkRows)
    let neutralOutside = try regionSignal(neutral, candidate, include: { !contains(target, x: $0, y: $1) }, watermarkRows: watermarkRows)
    let outside = conservativeSignal(sourceOutside, neutralOutside)

    var protectedRows: [ProtectedMeasurement] = []
    for protection in contract.protectedRegions {
        let regions = try watermarkSafeRegions(
            protection.regions, image: source, excludedRows: watermarkRows, allowEmpty: true
        )
        if regions.isEmpty {
            protectedRows.append(.init(id: protection.id, changedPixels: 0, absoluteRGBDelta: 0))
        } else {
            let sourceProtected = try regionSignal(source, candidate, include: { contains(regions, x: $0, y: $1) }, watermarkRows: watermarkRows)
            let neutralProtected = try regionSignal(neutral, candidate, include: { contains(regions, x: $0, y: $1) }, watermarkRows: watermarkRows)
            let value = conservativeSignal(sourceProtected, neutralProtected)
            protectedRows.append(.init(id: protection.id, changedPixels: value.changedPixels, absoluteRGBDelta: value.absoluteRGBDelta))
        }
    }

    let thresholds = contract.thresholds
    var reasons: [SemanticFailureReason] = []
    if sourceTarget.changedPixels < thresholds.minimumChangedPixels || sourceTarget.absoluteRGBDelta < thresholds.minimumAbsoluteRGBDelta {
        reasons.append(.sourceTargetSignal)
    }
    if neutralTarget.changedPixels < thresholds.minimumChangedPixels || neutralTarget.absoluteRGBDelta < thresholds.minimumAbsoluteRGBDelta {
        reasons.append(.neutralTargetSignal)
    }
    let floor = Int64(thresholds.minimumSignedMarginQ16)
    if contract.expectedSign == .positive {
        if sourceMargin < floor { reasons.append(.sourceDirection) }
        if neutralMargin < floor { reasons.append(.neutralDirection) }
    } else {
        if sourceMargin > -floor { reasons.append(.sourceDirection) }
        if neutralMargin > -floor { reasons.append(.neutralDirection) }
    }
    if outside.changedPixels > thresholds.maximumOutsideChangedPixels || outside.absoluteRGBDelta > thresholds.maximumOutsideAbsoluteRGBDelta {
        reasons.append(.outsideLocality)
    }
    if zip(protectedRows, contract.protectedRegions).contains(where: {
        $0.0.changedPixels > $0.1.maximumChangedPixels || $0.0.absoluteRGBDelta > $0.1.maximumAbsoluteRGBDelta
    }) {
        reasons.append(.protectedRegion)
    }
    if siblingMargin < floor { reasons.append(.siblingAlias) }

    return SemanticMeasurement(
        sourceTarget: sourceTarget, neutralTarget: neutralTarget,
        sourceSignedMarginQ16: sourceMargin, neutralSignedMarginQ16: neutralMargin,
        signedMarginQ16: signedMargin, siblingDistinctMarginQ16: siblingMargin,
        outsideChangedPixels: outside.changedPixels,
        outsideAbsoluteRGBDelta: outside.absoluteRGBDelta,
        protected: protectedRows,
        failureReasons: reasons
    )
}

private struct SemanticObservation: Equatable {
    let fixtureCount: Int64
    let changedPixels: Int64
    let absoluteRGBDelta: Int64
    let signedMarginQ16: Int64
    let outsideChangedPixels: Int64
    let outsideAbsoluteRGBDelta: Int64
    let protectedChangedPixels: [String: Int64]
    let protectedAbsoluteRGBDelta: [String: Int64]
}

private func checkedAdd(_ lhs: Int64, _ rhs: Int64) throws -> Int64 {
    let (value, overflow) = lhs.addingReportingOverflow(rhs)
    guard !overflow else { throw SemanticContractError.arithmetic }
    return value
}

private func aggregateSemanticObservations(_ values: [SemanticObservation]) throws -> SemanticObservation {
    guard !values.isEmpty else { throw SemanticContractError.admission }
    var result = SemanticObservation(
        fixtureCount: 0, changedPixels: 0, absoluteRGBDelta: 0, signedMarginQ16: 0,
        outsideChangedPixels: 0, outsideAbsoluteRGBDelta: 0,
        protectedChangedPixels: [:], protectedAbsoluteRGBDelta: [:]
    )
    for value in values {
        guard value.fixtureCount == 1 else { throw SemanticContractError.admission }
        var changed = result.protectedChangedPixels
        var delta = result.protectedAbsoluteRGBDelta
        for (key, count) in value.protectedChangedPixels {
            changed[key] = try checkedAdd(changed[key, default: 0], count)
        }
        for (key, count) in value.protectedAbsoluteRGBDelta {
            delta[key] = try checkedAdd(delta[key, default: 0], count)
        }
        result = SemanticObservation(
            fixtureCount: try checkedAdd(result.fixtureCount, value.fixtureCount),
            changedPixels: try checkedAdd(result.changedPixels, value.changedPixels),
            absoluteRGBDelta: try checkedAdd(result.absoluteRGBDelta, value.absoluteRGBDelta),
            signedMarginQ16: try checkedAdd(result.signedMarginQ16, value.signedMarginQ16),
            outsideChangedPixels: try checkedAdd(result.outsideChangedPixels, value.outsideChangedPixels),
            outsideAbsoluteRGBDelta: try checkedAdd(result.outsideAbsoluteRGBDelta, value.outsideAbsoluteRGBDelta),
            protectedChangedPixels: changed,
            protectedAbsoluteRGBDelta: delta
        )
    }
    return result
}

private func requireSemanticAdmission(fixtureCount: Int, hasSource: Bool, hasNeutral: Bool, hasCandidate: Bool) throws {
    guard fixtureCount > 0, hasSource, hasNeutral, hasCandidate else {
        throw SemanticContractError.admission
    }
}

private func semanticEffective(_ observation: SemanticObservation, for contract: SemanticContract) throws -> Bool {
    guard observation.fixtureCount > 0 else { throw SemanticContractError.admission }
    let thresholds = contract.thresholds
    guard observation.changedPixels >= thresholds.minimumChangedPixels,
          observation.absoluteRGBDelta >= thresholds.minimumAbsoluteRGBDelta,
          observation.outsideChangedPixels <= thresholds.maximumOutsideChangedPixels,
          observation.outsideAbsoluteRGBDelta <= thresholds.maximumOutsideAbsoluteRGBDelta else {
        return false
    }
    let signedFloor = Int64(thresholds.minimumSignedMarginQ16)
    switch contract.expectedSign {
    case .positive:
        guard observation.signedMarginQ16 >= signedFloor else { return false }
    case .negative:
        guard observation.signedMarginQ16 <= -signedFloor else { return false }
    }
    for protected in contract.protectedRegions {
        guard let changed = observation.protectedChangedPixels[protected.id],
              let delta = observation.protectedAbsoluteRGBDelta[protected.id],
              changed <= protected.maximumChangedPixels,
              delta <= protected.maximumAbsoluteRGBDelta else {
            return false
        }
    }
    return true
}

private struct SemanticMetricRow: Equatable {
    let caseID: String
    let regionID: String
    let valueQ16: Int64
    let insertionOrder: Int
}

private func canonicalSemanticRows(_ rows: [SemanticMetricRow]) -> [SemanticMetricRow] {
    let caseOrder = Dictionary(uniqueKeysWithValues: expectedSemanticContracts.enumerated().map { ($1.caseID, $0) })
    return rows.sorted {
        let lhsCase = caseOrder[$0.caseID] ?? Int.max
        let rhsCase = caseOrder[$1.caseID] ?? Int.max
        if lhsCase != rhsCase { return lhsCase < rhsCase }
        if $0.regionID != $1.regionID { return $0.regionID < $1.regionID }
        return $0.insertionOrder < $1.insertionOrder
    }
}

func argument(_ name: String, in arguments: [String]) throws -> String {
    guard let index = arguments.firstIndex(of: name), index + 1 < arguments.count else {
        throw CompareError.invalidArguments("missing \(name) value")
    }
    let value = arguments[index + 1]
    guard !value.isEmpty, !value.hasPrefix("--") else {
        throw CompareError.invalidArguments("missing \(name) value")
    }
    return value
}

func canonicalImage(at url: URL, context: CIContext) throws -> CanonicalImage {
    guard let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]) else {
        throw CompareError.imageDecodeFailed(url.path)
    }
    let extent = image.extent.integral
    let width = Int(extent.width.rounded(.toNearestOrAwayFromZero))
    let height = Int(extent.height.rounded(.toNearestOrAwayFromZero))
    guard width > 0, height > 0, width <= 8_192, height <= 8_192,
          let cgImage = context.createCGImage(image, from: extent) else {
        throw CompareError.imageDecodeFailed(url.path)
    }

    let pixels = try checkedMultiply(Int64(width), Int64(height))
    let byteCount = try checkedMultiply(pixels, 4)
    guard byteCount <= 256 * 1_024 * 1_024, byteCount <= Int64(Int.max) else {
        throw CompareError.imageDecodeFailed(url.path)
    }
    var rgba = Array(repeating: UInt8(0), count: Int(byteCount))
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    let drawn = rgba.withUnsafeMutableBytes { bytes in
        guard let baseAddress = bytes.baseAddress,
              let bitmap = CGContext(
                  data: baseAddress,
                  width: width,
                  height: height,
                  bitsPerComponent: 8,
                  bytesPerRow: width * 4,
                  space: colorSpace,
                  bitmapInfo: bitmapInfo
              ) else {
            return false
        }
        bitmap.interpolationQuality = .none
        bitmap.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return true
    }
    guard drawn else {
        throw CompareError.imageDecodeFailed(url.path)
    }
    return CanonicalImage(width: width, height: height, rgba: rgba)
}

func metrics(
    _ lhs: CanonicalImage,
    _ rhs: CanonicalImage,
    excludedRowsPerEdge: Int,
    tolerance: Int
) throws -> ComparisonMetrics {
    guard lhs.width == rhs.width, lhs.height == rhs.height else {
        throw CompareError.dimensionMismatch("\(lhs.width)x\(lhs.height) vs \(rhs.width)x\(rhs.height)")
    }
    try validateCanonicalPair(lhs, rhs)
    let startRow = 0
    let endRow = max(0, lhs.height - excludedRowsPerEdge)
    var comparedPixels = 0
    var changedPixels = 0
    var totalDelta: Int64 = 0
    var maxDelta = 0

    for y in startRow..<endRow {
        for x in 0..<lhs.width {
            let index = (y * lhs.width + x) * 4
            let redDelta = abs(Int(lhs.rgba[index]) - Int(rhs.rgba[index]))
            let greenDelta = abs(Int(lhs.rgba[index + 1]) - Int(rhs.rgba[index + 1]))
            let blueDelta = abs(Int(lhs.rgba[index + 2]) - Int(rhs.rgba[index + 2]))
            let pixelDelta = max(redDelta, greenDelta, blueDelta)
            comparedPixels += 1
            totalDelta = try checkedAdd(totalDelta, Int64(redDelta + greenDelta + blueDelta))
            maxDelta = max(maxDelta, pixelDelta)
            if pixelDelta > tolerance {
                changedPixels += 1
            }
        }
    }

    let mean = comparedPixels == 0 ? 0 : Double(totalDelta) / Double(comparedPixels * 3)
    return ComparisonMetrics(
        comparedPixels: comparedPixels,
        changedPixels: changedPixels,
        absoluteRGBDelta: totalDelta,
        meanAbsoluteRGBDelta: mean,
        maxRGBDelta: maxDelta
    )
}

func outputURL(runRoot: URL, batchID: String, stem: String, caseID: String) -> URL {
    runRoot
        .appendingPathComponent(batchID, isDirectory: true)
        .appendingPathComponent(caseID, isDirectory: true)
        .appendingPathComponent("\(stem)__\(caseID).png")
}

func aggregate(_ values: [ComparisonMetrics]) -> ComparisonMetrics {
    guard !values.isEmpty else {
        return ComparisonMetrics(
            comparedPixels: 0, changedPixels: 0, absoluteRGBDelta: 0,
            meanAbsoluteRGBDelta: 0, maxRGBDelta: 0
        )
    }
    let compared = values.reduce(0) { $0 + $1.comparedPixels }
    let changed = values.reduce(0) { $0 + $1.changedPixels }
    let weightedMean = values.reduce(0.0) {
        $0 + $1.meanAbsoluteRGBDelta * Double($1.comparedPixels)
    }
    return ComparisonMetrics(
        comparedPixels: compared,
        changedPixels: changed,
        absoluteRGBDelta: values.reduce(0) { $0 + $1.absoluteRGBDelta },
        meanAbsoluteRGBDelta: compared == 0 ? 0 : weightedMean / Double(compared),
        maxRGBDelta: values.map { $0.maxRGBDelta }.max() ?? 0
    )
}

private func sha256Hex(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

private func pathIsWithin(_ child: URL, root: URL) -> Bool {
    let childParts = child.standardizedFileURL.pathComponents
    let rootParts = root.standardizedFileURL.pathComponents
    return childParts.count > rootParts.count && childParts.prefix(rootParts.count) == rootParts[...]
}

private func requireAdmittedDirectory(_ url: URL) throws {
    let standardized = url.standardizedFileURL
    let resolved = standardized.resolvingSymlinksInPath()
    let values = try standardized.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
    guard standardized.path == resolved.path,
          values.isDirectory == true, values.isSymbolicLink != true else {
        throw SemanticContractError.admission
    }
}

private func requireAdmittedRegularFile(_ url: URL, beneath root: URL) throws {
    let standardized = url.standardizedFileURL
    let resolved = standardized.resolvingSymlinksInPath()
    guard pathIsWithin(standardized, root: root), standardized.path == resolved.path else {
        throw SemanticContractError.admission
    }
    let values = try standardized.resourceValues(forKeys: [
        .isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey
    ])
    guard values.isRegularFile == true, values.isSymbolicLink != true,
          let size = values.fileSize, size > 0, size <= 64 * 1_024 * 1_024 else {
        throw SemanticContractError.admission
    }
}

private func admittedFixtureURLs(in inputRoot: URL) throws -> [URL] {
    try requireAdmittedDirectory(inputRoot)
    let portraitRoot = inputRoot.appendingPathComponent("portraits", isDirectory: true)
    try requireAdmittedDirectory(portraitRoot)
    guard let enumerator = FileManager.default.enumerator(
        at: portraitRoot,
        includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey, .isSymbolicLinkKey],
        options: []
    ) else {
        throw SemanticContractError.admission
    }
    var fixtures: [URL] = []
    for case let url as URL in enumerator {
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey, .isSymbolicLinkKey])
        guard values.isSymbolicLink != true else { throw SemanticContractError.admission }
        if values.isDirectory == true { continue }
        guard values.isRegularFile == true,
              ["jpg", "jpeg", "png"].contains(url.pathExtension.lowercased()) else {
            throw SemanticContractError.admission
        }
        try requireAdmittedRegularFile(url, beneath: inputRoot)
        let prefix = try Data(contentsOf: url, options: .mappedIfSafe).prefix(8)
        let extensionName = url.pathExtension.lowercased()
        let signatureMatches = extensionName == "png"
            ? prefix.elementsEqual([137, 80, 78, 71, 13, 10, 26, 10])
            : prefix.count >= 3 && prefix[prefix.startIndex] == 0xFF &&
                prefix[prefix.index(after: prefix.startIndex)] == 0xD8 &&
                prefix[prefix.index(prefix.startIndex, offsetBy: 2)] == 0xFF
        guard signatureMatches else { throw SemanticContractError.admission }
        fixtures.append(url)
    }
    fixtures.sort {
        $0.lastPathComponent.utf8.lexicographicallyPrecedes($1.lastPathComponent.utf8)
    }
    guard !fixtures.isEmpty else { throw SemanticContractError.admission }
    let foldedStems = fixtures.map { $0.deletingPathExtension().lastPathComponent.lowercased() }
    guard Set(foldedStems).count == foldedStems.count,
          foldedStems.allSatisfy(isStableIdentifier) else {
        throw SemanticContractError.admission
    }
    return fixtures
}

private func expectedRunOutputs(
    manifest: BatchManifest, fixtures: [URL], runRoot: URL
) -> [URL] {
    let stems = fixtures.map { $0.deletingPathExtension().lastPathComponent }
    var outputs = stems.map {
        outputURL(runRoot: runRoot, batchID: "control", stem: $0, caseID: manifest.control.id)
    }
    for batch in manifest.batches {
        for caseID in batch.cases {
            outputs.append(contentsOf: stems.map {
                outputURL(runRoot: runRoot, batchID: batch.id, stem: $0, caseID: caseID)
            })
        }
    }
    return outputs
}

private func admitRunInventory(
    manifest: BatchManifest,
    fixtures: [URL],
    runRoot: URL,
    attemptID: String
) throws -> [String: URL] {
    try requireAdmittedDirectory(runRoot)
    guard isStableIdentifier(attemptID), runRoot.lastPathComponent == attemptID else {
        throw SemanticContractError.admission
    }
    let expected = expectedRunOutputs(manifest: manifest, fixtures: fixtures, runRoot: runRoot)
    let expectedPaths = Set(expected.map { $0.standardizedFileURL.path })
    var expectedDirectoryPaths: Set<String> = []
    for output in expected {
        var parent = output.deletingLastPathComponent().standardizedFileURL
        while parent.path != runRoot.standardizedFileURL.path {
            guard pathIsWithin(parent, root: runRoot) else {
                throw SemanticContractError.admission
            }
            expectedDirectoryPaths.insert(parent.path)
            parent.deleteLastPathComponent()
        }
    }
    guard let enumerator = FileManager.default.enumerator(
        at: runRoot,
        includingPropertiesForKeys: [
            .isRegularFileKey, .isDirectoryKey, .isSymbolicLinkKey,
            .contentModificationDateKey, .creationDateKey
        ],
        options: []
    ) else {
        throw SemanticContractError.admission
    }
    let rootValues = try runRoot.resourceValues(forKeys: [.creationDateKey])
    guard let rootCreated = rootValues.creationDate else { throw SemanticContractError.admission }
    var discovered: Set<String> = []
    for case let url as URL in enumerator {
        let values = try url.resourceValues(forKeys: [
            .isRegularFileKey, .isDirectoryKey, .isSymbolicLinkKey,
            .contentModificationDateKey
        ])
        guard values.isSymbolicLink != true else { throw SemanticContractError.admission }
        if values.isDirectory == true {
            guard expectedDirectoryPaths.contains(url.standardizedFileURL.path) else {
                throw SemanticContractError.admission
            }
            continue
        }
        guard values.isRegularFile == true else { throw SemanticContractError.admission }
        try requireAdmittedRegularFile(url, beneath: runRoot)
        let path = url.standardizedFileURL.path
        guard expectedPaths.contains(path), url.pathExtension.lowercased() == "png",
              let modified = values.contentModificationDate,
              modified >= rootCreated.addingTimeInterval(-1.0) else {
            throw SemanticContractError.admission
        }
        let signature = try Data(contentsOf: url, options: .mappedIfSafe).prefix(8)
        guard signature.elementsEqual([137, 80, 78, 71, 13, 10, 26, 10]) else {
            throw SemanticContractError.admission
        }
        guard discovered.insert(path).inserted else { throw SemanticContractError.admission }
    }
    guard discovered == expectedPaths else { throw SemanticContractError.admission }
    return Dictionary(uniqueKeysWithValues: expected.map { ($0.standardizedFileURL.path, $0) })
}

private func prepareReportDestination(_ reportURL: URL) throws {
    let parent = reportURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
    try requireAdmittedDirectory(parent)
    if FileManager.default.fileExists(atPath: reportURL.path) {
        let values = try reportURL.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
        guard values.isRegularFile == true, values.isSymbolicLink != true else {
            throw SemanticContractError.admission
        }
        try FileManager.default.removeItem(at: reportURL)
    }
}

private func canonicalPayload(_ payload: StableSemanticPayload) -> StableSemanticPayload {
    let batchOrder = Dictionary(uniqueKeysWithValues: expectedBatchInventory.enumerated().map { ($1.0, $0) })
    let caseOrder = Dictionary(uniqueKeysWithValues: expectedBatchInventory.flatMap { $0.1 }.enumerated().map { ($1, $0) })
    let directionOrder = Dictionary(uniqueKeysWithValues: expectedSemanticContracts.enumerated().map { ($1.caseID, $0) })
    let protectedOrder: [String: [String]] = [
        "faceContourSmooth_0p25": ["centralAnatomy", "background", "watermark"],
        "chinTaper_0p25": ["upperFace", "mouth", "background", "watermark"],
        "gazeCorrection_0p25": ["eyeContours", "eyebrows", "background", "watermark"],
        "eyebrowHeadSpacing_plus0p25": ["outerAnchors", "eyes", "background", "watermark"],
        "eyebrowHeadSpacing_minus0p25": ["outerAnchors", "eyes", "background", "watermark"],
        "noseBridge_0p30": ["root", "tip", "background", "watermark"],
        "noseRootNarrowing_0p25": ["bridge", "tip", "background", "watermark"],
        "mouthWidth_minus0p35": ["mouthHeight", "surroundingFace", "background", "watermark"]
    ]
    return StableSemanticPayload(
        schemaVersion: payload.schemaVersion,
        contractID: payload.contractID,
        cpuReferenceToken: payload.cpuReferenceToken,
        fixtureCount: payload.fixtureCount,
        fixtureIDs: payload.fixtureIDs.sorted(),
        watermarkExcludedRowCount: payload.watermarkExcludedRowCount,
        batches: payload.batches.sorted { batchOrder[$0.id, default: Int.max] < batchOrder[$1.id, default: Int.max] },
        mechanicalCases: payload.mechanicalCases.sorted { caseOrder[$0.caseID, default: Int.max] < caseOrder[$1.caseID, default: Int.max] },
        semanticDirections: payload.semanticDirections.sorted {
            directionOrder[$0.caseID, default: Int.max] < directionOrder[$1.caseID, default: Int.max]
        }.map { direction in
            SemanticDirectionSummary(
                caseID: direction.caseID, metric: direction.metric,
                fixtureCount: direction.fixtureCount,
                sourceTargetChangedPixels: direction.sourceTargetChangedPixels,
                sourceTargetAbsoluteRGBDelta: direction.sourceTargetAbsoluteRGBDelta,
                neutralTargetChangedPixels: direction.neutralTargetChangedPixels,
                neutralTargetAbsoluteRGBDelta: direction.neutralTargetAbsoluteRGBDelta,
                sourceSignedMarginQ16: direction.sourceSignedMarginQ16,
                neutralSignedMarginQ16: direction.neutralSignedMarginQ16,
                signedMarginQ16: direction.signedMarginQ16,
                siblingDistinctMarginQ16: direction.siblingDistinctMarginQ16,
                outsideChangedPixels: direction.outsideChangedPixels,
                outsideAbsoluteRGBDelta: direction.outsideAbsoluteRGBDelta,
                protectedRegions: direction.protectedRegions.sorted {
                    let order = protectedOrder[direction.caseID] ?? []
                    return (order.firstIndex(of: $0.id) ?? Int.max) <
                        (order.firstIndex(of: $1.id) ?? Int.max)
                },
                failureReasonCodes: direction.failureReasonCodes.sorted(),
                verdict: direction.verdict
            )
        },
        verdict: payload.verdict
    )
}

private func stablePayloadData(_ payload: StableSemanticPayload) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    return try encoder.encode(canonicalPayload(payload))
}

private func privacySafeJSON(_ data: Data) -> Bool {
    guard let object = try? JSONSerialization.jsonObject(with: data) else { return false }
    let forbiddenKeyFragments = [
        "filepath", "filename", "rgba", "mask", "landmark", "geometry",
        "coordinate", "childoutput", "transcript", "freetext"
    ]
    let forbiddenValues = ["/users/", "../", "\\\\", ".jpg", ".jpeg", ".png", "file://"]
    func scan(_ value: Any) -> Bool {
        if let dictionary = value as? [String: Any] {
            for (key, child) in dictionary {
                let folded = key.lowercased().replacingOccurrences(of: "_", with: "")
                if folded == "path" || folded.hasSuffix("path") ||
                    forbiddenKeyFragments.contains(where: folded.contains) { return false }
                if !scan(child) { return false }
            }
        } else if let array = value as? [Any] {
            return array.allSatisfy(scan)
        } else if let string = value as? String {
            let folded = string.lowercased()
            return !forbiddenValues.contains(where: folded.contains)
        }
        return true
    }
    return scan(object)
}

private func validateStablePayload(
    _ payload: StableSemanticPayload,
    contracts: [SemanticContract]
) throws {
    let canonical = canonicalPayload(payload)
    guard canonical.schemaVersion == "beauty.face-feature-batch-report.semantic.1",
          isStableIdentifier(canonical.contractID),
          canonical.cpuReferenceToken == "beauty_cpu_reference_v1",
          canonical.fixtureCount > 0,
          canonical.fixtureIDs.count == canonical.fixtureCount,
          Set(canonical.fixtureIDs).count == canonical.fixtureIDs.count,
          canonical.fixtureIDs.allSatisfy(isStableIdentifier),
          canonical.batches.map(\ .id) == expectedBatchInventory.map(\ .0),
          canonical.mechanicalCases.count == 65,
          canonical.mechanicalCases.map(\ .caseID) == expectedBatchInventory.flatMap(\ .1),
          canonical.semanticDirections.count == 8,
          canonical.semanticDirections.map(\ .caseID) == expectedSemanticContracts.map(\ .caseID) else {
        throw SemanticContractError.inventory
    }
    guard zip(canonical.batches, expectedBatchInventory).allSatisfy({ batch, expected in
        batch.id == expected.0 && batch.caseCount == expected.1.count &&
            batch.completeCaseCount == expected.1.count && batch.missingOutputCount == 0
    }), canonical.mechanicalCases.allSatisfy({ row in
        row.fixtureCount == canonical.fixtureCount && row.outputCount == canonical.fixtureCount &&
            row.missingOutputCount == 0 && row.sourceComparedPixels > 0 &&
            row.neutralComparedPixels > 0 && row.sourceChangedPixels >= 0 &&
            row.neutralChangedPixels >= 0 && row.sourceAbsoluteRGBDelta >= 0 &&
            row.neutralAbsoluteRGBDelta >= 0 &&
            row.descriptiveStatus == "complete_mechanical_summary"
    }) else {
        throw SemanticContractError.inventory
    }
    let allowlistedReasons = Set(SemanticFailureReason.allCases.map(\ .rawValue))
    guard contracts.map(\ .caseID) == expectedSemanticContracts.map(\ .caseID) else {
        throw SemanticContractError.contracts
    }
    guard canonical.semanticDirections.allSatisfy({ direction in
        direction.fixtureCount == canonical.fixtureCount &&
            Set(direction.failureReasonCodes).isSubset(of: allowlistedReasons) &&
            (direction.failureReasonCodes.isEmpty ? direction.verdict == "semantic_pass" : direction.verdict == "semantic_fail")
    }) else {
        throw SemanticContractError.verdict
    }
    for (direction, contract) in zip(canonical.semanticDirections, contracts) {
        let fixtureCount = Int64(canonical.fixtureCount)
        let minimumChanged = try checkedMultiply(Int64(contract.thresholds.minimumChangedPixels), fixtureCount)
        let minimumDelta = try checkedMultiply(Int64(contract.thresholds.minimumAbsoluteRGBDelta), fixtureCount)
        let minimumMargin = try checkedMultiply(Int64(contract.thresholds.minimumSignedMarginQ16), fixtureCount)
        let maximumOutsideChanged = try checkedMultiply(Int64(contract.thresholds.maximumOutsideChangedPixels), fixtureCount)
        let maximumOutsideDelta = try checkedMultiply(Int64(contract.thresholds.maximumOutsideAbsoluteRGBDelta), fixtureCount)
        let signedPass: Bool
        switch contract.expectedSign {
        case .positive:
            signedPass = direction.sourceSignedMarginQ16 >= minimumMargin &&
                direction.neutralSignedMarginQ16 >= minimumMargin &&
                direction.signedMarginQ16 >= minimumMargin
        case .negative:
            signedPass = direction.sourceSignedMarginQ16 <= -minimumMargin &&
                direction.neutralSignedMarginQ16 <= -minimumMargin &&
                direction.signedMarginQ16 <= -minimumMargin
        }
        let protectionByID = Dictionary(uniqueKeysWithValues: direction.protectedRegions.map { ($0.id, $0) })
        let protectedPass = direction.protectedRegions.count == contract.protectedRegions.count &&
            contract.protectedRegions.allSatisfy { protection in
                guard let row = protectionByID[protection.id],
                      let changedCeiling = try? checkedMultiply(Int64(protection.maximumChangedPixels), fixtureCount),
                      let deltaCeiling = try? checkedMultiply(Int64(protection.maximumAbsoluteRGBDelta), fixtureCount) else {
                    return false
                }
                return row.changedPixels <= changedCeiling && row.absoluteRGBDelta <= deltaCeiling
            }
        let aggregateGatesPass = direction.sourceTargetChangedPixels >= minimumChanged &&
            direction.sourceTargetAbsoluteRGBDelta >= minimumDelta &&
            direction.neutralTargetChangedPixels >= minimumChanged &&
            direction.neutralTargetAbsoluteRGBDelta >= minimumDelta &&
            signedPass &&
            direction.siblingDistinctMarginQ16 >= Int64(contract.thresholds.minimumSignedMarginQ16) &&
            direction.outsideChangedPixels <= maximumOutsideChanged &&
            direction.outsideAbsoluteRGBDelta <= maximumOutsideDelta &&
            protectedPass
        if direction.verdict == "semantic_pass" && !aggregateGatesPass {
            throw SemanticContractError.verdict
        }
    }
    let allPass = canonical.semanticDirections.allSatisfy { $0.verdict == "semantic_pass" }
    guard canonical.verdict == (allPass ? "semantic_pass" : "semantic_fail") else {
        throw SemanticContractError.verdict
    }
    guard privacySafeJSON(try stablePayloadData(canonical)) else {
        throw SemanticContractError.admission
    }
}

private func writeSemanticReport(
    payload: StableSemanticPayload,
    contracts: [SemanticContract],
    attemptID: String,
    generatedAtUTC: String,
    to reportURL: URL
) throws -> String {
    let stable = canonicalPayload(payload)
    try validateStablePayload(stable, contracts: contracts)
    let stableData = try stablePayloadData(stable)
    let digest = sha256Hex(stableData)
    let envelope = SemanticReportEnvelope(
        volatile: .init(generatedAtUTC: generatedAtUTC, attemptID: attemptID),
        stablePayloadDigest: digest,
        stablePayload: stable
    )
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    let data = try encoder.encode(envelope)
    guard privacySafeJSON(data) else { throw SemanticContractError.admission }
    try data.write(to: reportURL, options: .atomic)
    return digest
}

private func semanticDirectionSummary(
    contract: SemanticContract,
    sources: [CanonicalImage],
    neutrals: [CanonicalImage],
    candidates: [CanonicalImage],
    siblingImages: [[CanonicalImage]]
) throws -> SemanticDirectionSummary {
    guard !sources.isEmpty, sources.count == neutrals.count,
          sources.count == candidates.count,
          siblingImages.allSatisfy({ $0.count == sources.count }) else {
        throw SemanticContractError.admission
    }
    var sourceChanged: Int64 = 0
    var sourceDelta: Int64 = 0
    var neutralChanged: Int64 = 0
    var neutralDelta: Int64 = 0
    var sourceMargin: Int64 = 0
    var neutralMargin: Int64 = 0
    var signedMargin: Int64 = 0
    var siblingMargin = Int64.max
    var outsideChanged: Int64 = 0
    var outsideDelta: Int64 = 0
    var protected = Dictionary(uniqueKeysWithValues: contract.protectedRegions.map {
        ($0.id, ProtectedRegionSummary(id: $0.id, changedPixels: 0, absoluteRGBDelta: 0))
    })
    var failures: Set<SemanticFailureReason> = []

    for index in sources.indices {
        let measurement = try semanticMeasurement(
            contract: contract,
            source: sources[index], neutral: neutrals[index], candidate: candidates[index],
            siblings: siblingImages.map { $0[index] },
            watermarkRows: watermarkExcludedRows(width: sources[index].width)
        )
        sourceChanged = try checkedAdd(sourceChanged, measurement.sourceTarget.changedPixels)
        sourceDelta = try checkedAdd(sourceDelta, measurement.sourceTarget.absoluteRGBDelta)
        neutralChanged = try checkedAdd(neutralChanged, measurement.neutralTarget.changedPixels)
        neutralDelta = try checkedAdd(neutralDelta, measurement.neutralTarget.absoluteRGBDelta)
        sourceMargin = try checkedAdd(sourceMargin, measurement.sourceSignedMarginQ16)
        neutralMargin = try checkedAdd(neutralMargin, measurement.neutralSignedMarginQ16)
        signedMargin = try checkedAdd(signedMargin, measurement.signedMarginQ16)
        siblingMargin = min(siblingMargin, measurement.siblingDistinctMarginQ16)
        outsideChanged = try checkedAdd(outsideChanged, measurement.outsideChangedPixels)
        outsideDelta = try checkedAdd(outsideDelta, measurement.outsideAbsoluteRGBDelta)
        failures.formUnion(measurement.failureReasons)
        for row in measurement.protected {
            guard let existing = protected[row.id] else { throw SemanticContractError.verdict }
            protected[row.id] = ProtectedRegionSummary(
                id: row.id,
                changedPixels: try checkedAdd(existing.changedPixels, row.changedPixels),
                absoluteRGBDelta: try checkedAdd(existing.absoluteRGBDelta, row.absoluteRGBDelta)
            )
        }
    }
    if siblingMargin == Int64.max { siblingMargin = 0 }
    let reasonCodes = failures.map(\ .rawValue).sorted()
    let protectedRows = contract.protectedRegions.compactMap { protected[$0.id] }
    return SemanticDirectionSummary(
        caseID: contract.caseID,
        metric: contract.metric,
        fixtureCount: sources.count,
        sourceTargetChangedPixels: sourceChanged,
        sourceTargetAbsoluteRGBDelta: sourceDelta,
        neutralTargetChangedPixels: neutralChanged,
        neutralTargetAbsoluteRGBDelta: neutralDelta,
        sourceSignedMarginQ16: sourceMargin,
        neutralSignedMarginQ16: neutralMargin,
        signedMarginQ16: signedMargin,
        siblingDistinctMarginQ16: siblingMargin,
        outsideChangedPixels: outsideChanged,
        outsideAbsoluteRGBDelta: outsideDelta,
        protectedRegions: protectedRows,
        failureReasonCodes: reasonCodes,
        verdict: reasonCodes.isEmpty ? "semantic_pass" : "semantic_fail"
    )
}

private func replacing(
    _ contract: SemanticContract,
    caseID: String? = nil,
    comparisonCaseIDs: [String]? = nil,
    targetRegions: [NormalizedRegion]? = nil,
    thresholds: SemanticThresholds? = nil,
    protectedRegions: [ProtectedRegionContract]? = nil
) -> SemanticContract {
    SemanticContract(
        caseID: caseID ?? contract.caseID,
        metric: contract.metric,
        expectedSign: contract.expectedSign,
        comparisonCaseIDs: comparisonCaseIDs ?? contract.comparisonCaseIDs,
        targetRegions: targetRegions ?? contract.targetRegions,
        thresholds: thresholds ?? contract.thresholds,
        protectedRegions: protectedRegions ?? contract.protectedRegions
    )
}

private func replacing(
    _ manifest: BatchManifest,
    batches: [BatchManifest.Batch]? = nil,
    semanticContracts: [SemanticContract]?
) -> BatchManifest {
    BatchManifest(
        schemaVersion: manifest.schemaVersion,
        control: manifest.control,
        batches: batches ?? manifest.batches,
        semanticContracts: semanticContracts
    )
}

private func exactObservation(for contract: SemanticContract) -> SemanticObservation {
    let changed = Dictionary(uniqueKeysWithValues: contract.protectedRegions.map {
        ($0.id, Int64($0.maximumChangedPixels))
    })
    let delta = Dictionary(uniqueKeysWithValues: contract.protectedRegions.map {
        ($0.id, Int64($0.maximumAbsoluteRGBDelta))
    })
    let signed = Int64(contract.thresholds.minimumSignedMarginQ16) *
        (contract.expectedSign == .positive ? 1 : -1)
    return SemanticObservation(
        fixtureCount: 1,
        changedPixels: Int64(contract.thresholds.minimumChangedPixels),
        absoluteRGBDelta: Int64(contract.thresholds.minimumAbsoluteRGBDelta),
        signedMarginQ16: signed,
        outsideChangedPixels: Int64(contract.thresholds.maximumOutsideChangedPixels),
        outsideAbsoluteRGBDelta: Int64(contract.thresholds.maximumOutsideAbsoluteRGBDelta),
        protectedChangedPixels: changed,
        protectedAbsoluteRGBDelta: delta
    )
}

private func replacing(
    _ observation: SemanticObservation,
    changedPixels: Int64? = nil,
    absoluteRGBDelta: Int64? = nil,
    signedMarginQ16: Int64? = nil,
    outsideChangedPixels: Int64? = nil,
    outsideAbsoluteRGBDelta: Int64? = nil,
    protectedChangedPixels: [String: Int64]? = nil,
    protectedAbsoluteRGBDelta: [String: Int64]? = nil
) -> SemanticObservation {
    SemanticObservation(
        fixtureCount: observation.fixtureCount,
        changedPixels: changedPixels ?? observation.changedPixels,
        absoluteRGBDelta: absoluteRGBDelta ?? observation.absoluteRGBDelta,
        signedMarginQ16: signedMarginQ16 ?? observation.signedMarginQ16,
        outsideChangedPixels: outsideChangedPixels ?? observation.outsideChangedPixels,
        outsideAbsoluteRGBDelta: outsideAbsoluteRGBDelta ?? observation.outsideAbsoluteRGBDelta,
        protectedChangedPixels: protectedChangedPixels ?? observation.protectedChangedPixels,
        protectedAbsoluteRGBDelta: protectedAbsoluteRGBDelta ?? observation.protectedAbsoluteRGBDelta
    )
}

private func generatedImage(
    width: Int = 80,
    height: Int = 80,
    rectangles: [(Int, Int, Int, Int)]
) -> CanonicalImage {
    var rgba = Array(repeating: UInt8(255), count: width * height * 4)
    for pixel in 0..<(width * height) { rgba[pixel * 4 + 3] = 255 }
    for rectangle in rectangles {
        for y in max(0, rectangle.1)..<min(height, rectangle.3) {
            for x in max(0, rectangle.0)..<min(width, rectangle.2) {
                let index = (y * width + x) * 4
                rgba[index] = 0
                rgba[index + 1] = 0
                rgba[index + 2] = 0
            }
        }
    }
    return CanonicalImage(width: width, height: height, rgba: rgba)
}

private func runDirectionMetricSelfTests(contracts: [SemanticContract]) throws -> Int {
    guard Set(contracts.map(\ .metric)) == Set(SemanticMetricKind.allCases) else {
        throw SemanticContractError.verdict
    }
    var probes = 0
    func expectIncrease(_ source: Int64, _ candidate: Int64) throws {
        guard candidate > source else { throw SemanticContractError.verdict }
        probes += 1
    }
    func expectDecrease(_ source: Int64, _ candidate: Int64) throws {
        guard candidate < source else { throw SemanticContractError.verdict }
        probes += 1
    }

    let contourRegions = [
        RasterizedRegion(minX: 4, maxX: 24, minY: 8, maxY: 40),
        RasterizedRegion(minX: 56, maxX: 76, minY: 8, maxY: 40)
    ]
    var jagged: [(Int, Int, Int, Int)] = []
    var smooth: [(Int, Int, Int, Int)] = []
    for y in 8..<40 {
        let offset = y.isMultiple(of: 2) ? 4 : 12
        jagged.append((offset, y, offset + 2, y + 1))
        jagged.append((80 - offset - 2, y, 80 - offset, y + 1))
        smooth.append((8, y, 10, y + 1))
        smooth.append((70, y, 72, y + 1))
    }
    try expectIncrease(
        try contourContinuityGain(generatedImage(rectangles: jagged), regions: contourRegions),
        try contourContinuityGain(generatedImage(rectangles: smooth), regions: contourRegions)
    )

    let chinRegion = [RasterizedRegion(minX: 20, maxX: 60, minY: 45, maxY: 60)]
    let wideChin = generatedImage(rectangles: [(22, 48, 28, 56), (52, 48, 58, 56)])
    let taperedChin = generatedImage(rectangles: [(31, 48, 37, 56), (43, 48, 49, 56)])
    try expectIncrease(try centerlineTaper(wideChin, regions: chinRegion), try centerlineTaper(taperedChin, regions: chinRegion))

    let eyeRegions = [
        RasterizedRegion(minX: 8, maxX: 32, minY: 20, maxY: 40),
        RasterizedRegion(minX: 48, maxX: 72, minY: 20, maxY: 40)
    ]
    let gazeAdversaries = [
        generatedImage(rectangles: [(9, 21, 12, 24), (49, 21, 52, 24)]),
        generatedImage(rectangles: [(18, 28, 22, 32), (58, 28, 62, 32)]),
        generatedImage(rectangles: [(8, 20, 32, 22), (48, 20, 72, 22)]), // lash/shadow change
        generatedImage(rectangles: [(10, 35, 18, 39), (62, 35, 70, 39)]) // foreign dark patches
    ]
    for adversary in gazeAdversaries {
        do {
            _ = try semanticMetricValue(
                kind: .pupilToOwnEyeCenter, image: adversary, regions: eyeRegions
            )
            throw SemanticContractError.verdict
        } catch SemanticContractError.unsupportedMetric {
            probes += 1
        }
    }
    guard let gazeContract = contracts.first(where: { $0.metric == .pupilToOwnEyeCenter }) else {
        throw SemanticContractError.contracts
    }
    let admittedGaze = generatedImage(
        width: 80, height: 300,
        rectangles: [(27, 170, 31, 174), (49, 170, 53, 174)]
    )
    let abstainedGaze = generatedImage(
        width: 80, height: 300, rectangles: [(27, 170, 31, 174)]
    )
    do {
        _ = try semanticDirectionSummary(
            contract: gazeContract,
            sources: [admittedGaze], neutrals: [admittedGaze], candidates: [abstainedGaze],
            siblingImages: Array(repeating: [admittedGaze], count: gazeContract.comparisonCaseIDs.count - 2)
        )
        throw SemanticContractError.verdict
    } catch SemanticContractError.unsupportedMetric {
        probes += 1 // No incomplete direction can be published as a measured semantic failure.
    }

    let browRegions = [
        RasterizedRegion(minX: 24, maxX: 40, minY: 12, maxY: 24),
        RasterizedRegion(minX: 40, maxX: 56, minY: 12, maxY: 24)
    ]
    let browNarrow = generatedImage(rectangles: [(35, 15, 39, 20), (41, 15, 45, 20)])
    let browWide = generatedImage(rectangles: [(27, 15, 31, 20), (49, 15, 53, 20)])
    try expectIncrease(try innerBrowHeadGap(browNarrow, regions: browRegions), try innerBrowHeadGap(browWide, regions: browRegions))
    try expectDecrease(try innerBrowHeadGap(browWide, regions: browRegions), try innerBrowHeadGap(browNarrow, regions: browRegions))

    let bridgeRegion = [RasterizedRegion(minX: 28, maxX: 52, minY: 24, maxY: 48)]
    let flatBridge = generatedImage(rectangles: [(28, 24, 52, 48)])
    let definedBridge = generatedImage(rectangles: [(36, 24, 44, 48)])
    try expectIncrease(
        try bridgeDefinitionGain(flatBridge, regions: bridgeRegion),
        try bridgeDefinitionGain(definedBridge, regions: bridgeRegion)
    )

    let rootRegion = [RasterizedRegion(minX: 24, maxX: 56, minY: 8, maxY: 24)]
    let wideRoot = generatedImage(rectangles: [(25, 12, 29, 20), (51, 12, 55, 20)])
    let narrowRoot = generatedImage(rectangles: [(33, 12, 37, 20), (43, 12, 47, 20)])
    try expectIncrease(try rootWidthContraction(wideRoot, regions: rootRegion), try rootWidthContraction(narrowRoot, regions: rootRegion))

    let mouthRegions = [
        RasterizedRegion(minX: 8, maxX: 32, minY: 52, maxY: 70),
        RasterizedRegion(minX: 48, maxX: 72, minY: 52, maxY: 70)
    ]
    let wideMouth = generatedImage(rectangles: [(10, 58, 16, 64), (64, 58, 70, 64)])
    let narrowMouth = generatedImage(rectangles: [(24, 58, 30, 64), (50, 58, 56, 64)])
    try expectDecrease(try mouthWidthContraction(wideMouth, regions: mouthRegions), try mouthWidthContraction(narrowMouth, regions: mouthRegions))

    // Arbitrary uniform target change has no bridge-definition polarity.
    let white = generatedImage(rectangles: [])
    var gray = white.rgba
    for y in 24..<48 {
        for x in 28..<52 {
            let index = (y * white.width + x) * 4
            gray[index] = 128; gray[index + 1] = 128; gray[index + 2] = 128
        }
    }
    let uniformTargetChange = CanonicalImage(width: white.width, height: white.height, rgba: gray)
    guard try bridgeDefinitionGain(white, regions: bridgeRegion) == bridgeDefinitionGain(uniformTargetChange, regions: bridgeRegion) else {
        throw SemanticContractError.verdict
    }
    probes += 1

    // Bottom watermark rows are excluded from every region iterator.
    var watermarkBytes = white.rgba
    for y in 70..<80 {
        for x in 0..<80 { watermarkBytes[(y * 80 + x) * 4] = 0 }
    }
    let watermarkOnly = CanonicalImage(width: 80, height: 80, rgba: watermarkBytes)
    let excluded = try regionSignal(white, watermarkOnly, include: { _, _ in true }, watermarkRows: 10, tolerance: 0)
    guard excluded.changedPixels == 0, excluded.absoluteRGBDelta == 0 else {
        throw SemanticContractError.verdict
    }
    probes += 1

    let generatedContract = SemanticContract(
        caseID: "generatedBridge",
        metric: .bridgeDefinitionGain,
        expectedSign: .positive,
        comparisonCaseIDs: ["source", "geometryBaseline_noop", "generatedSibling"],
        targetRegions: [NormalizedRegion(
            id: "bridge", minXPPM: 350_000, maxXPPM: 650_000,
            minYPPM: 300_000, maxYPPM: 600_000
        )],
        thresholds: SemanticThresholds(
            minimumChangedPixels: 10, minimumAbsoluteRGBDelta: 10,
            minimumSignedMarginQ16: 16, maximumOutsideChangedPixels: 0,
            maximumOutsideAbsoluteRGBDelta: 0
        ),
        protectedRegions: [ProtectedRegionContract(
            id: "upper", regions: [NormalizedRegion(
                id: nil, minXPPM: 0, maxXPPM: 1_000_000,
                minYPPM: 0, maxYPPM: 200_000
            )], maximumChangedPixels: 0, maximumAbsoluteRGBDelta: 0
        )]
    )
    let complete = try semanticMeasurement(
        contract: generatedContract,
        source: flatBridge, neutral: flatBridge, candidate: definedBridge,
        siblings: [white], watermarkRows: 0
    )
    guard complete.semanticPass,
          complete.sourceTarget.changedPixels >= 10,
          complete.neutralTarget.changedPixels >= 10,
          complete.sourceSignedMarginQ16 >= 16,
          complete.neutralSignedMarginQ16 >= 16 else {
        throw SemanticContractError.verdict
    }
    probes += 1
    let reversed = try semanticMeasurement(
        contract: generatedContract,
        source: definedBridge, neutral: definedBridge, candidate: flatBridge,
        siblings: [white], watermarkRows: 0
    )
    guard reversed.failureReasons.contains(.sourceDirection),
          reversed.failureReasons.contains(.neutralDirection) else {
        throw SemanticContractError.verdict
    }
    probes += 1
    let aliased = try semanticMeasurement(
        contract: generatedContract,
        source: flatBridge, neutral: flatBridge, candidate: definedBridge,
        siblings: [definedBridge], watermarkRows: 0
    )
    guard aliased.failureReasons.contains(.siblingAlias) else {
        throw SemanticContractError.verdict
    }
    probes += 1

    return probes
}

private func runSemanticReportSelfTests(manifest: BatchManifest) throws -> Int {
    guard let contracts = manifest.semanticContracts else { throw SemanticContractError.contracts }
    var probes = 0
    func expect(_ error: SemanticContractError, _ body: () throws -> Void) throws {
        do {
            try body()
        } catch let caught as SemanticContractError where caught == error {
            probes += 1
            return
        } catch {
            throw SemanticContractError.verdict
        }
        throw SemanticContractError.verdict
    }

    let fixtureCount = 1
    let batches = expectedBatchInventory.map {
        BatchSummary(id: $0.0, caseCount: $0.1.count, completeCaseCount: $0.1.count, missingOutputCount: 0)
    }
    let mechanical = expectedBatchInventory.flatMap { batch in
        batch.1.map {
            MechanicalCaseSummary(
                batchID: batch.0, caseID: $0, fixtureCount: fixtureCount,
                outputCount: fixtureCount, missingOutputCount: 0,
                sourceChangedPixels: 0, sourceComparedPixels: 1,
                sourceAbsoluteRGBDelta: 0, sourceMaxRGBDelta: 0,
                neutralChangedPixels: 0, neutralComparedPixels: 1,
                neutralAbsoluteRGBDelta: 0, neutralMaxRGBDelta: 0,
                descriptiveStatus: "complete_mechanical_summary"
            )
        }
    }
    let directions = contracts.map { contract -> SemanticDirectionSummary in
        let signed = Int64(contract.thresholds.minimumSignedMarginQ16) *
            (contract.expectedSign == .positive ? 1 : -1)
        return SemanticDirectionSummary(
            caseID: contract.caseID, metric: contract.metric, fixtureCount: fixtureCount,
            sourceTargetChangedPixels: Int64(contract.thresholds.minimumChangedPixels),
            sourceTargetAbsoluteRGBDelta: Int64(contract.thresholds.minimumAbsoluteRGBDelta),
            neutralTargetChangedPixels: Int64(contract.thresholds.minimumChangedPixels),
            neutralTargetAbsoluteRGBDelta: Int64(contract.thresholds.minimumAbsoluteRGBDelta),
            sourceSignedMarginQ16: signed, neutralSignedMarginQ16: signed,
            signedMarginQ16: signed,
            siblingDistinctMarginQ16: Int64(contract.thresholds.minimumSignedMarginQ16),
            outsideChangedPixels: Int64(contract.thresholds.maximumOutsideChangedPixels),
            outsideAbsoluteRGBDelta: Int64(contract.thresholds.maximumOutsideAbsoluteRGBDelta),
            protectedRegions: contract.protectedRegions.map {
                ProtectedRegionSummary(
                    id: $0.id, changedPixels: Int64($0.maximumChangedPixels),
                    absoluteRGBDelta: Int64($0.maximumAbsoluteRGBDelta)
                )
            },
            failureReasonCodes: [], verdict: "semantic_pass"
        )
    }
    let payload = StableSemanticPayload(
        schemaVersion: "beauty.face-feature-batch-report.semantic.1",
        contractID: "contract_001", cpuReferenceToken: "beauty_cpu_reference_v1",
        fixtureCount: fixtureCount, fixtureIDs: ["portrait_001"],
        watermarkExcludedRowCount: 10,
        batches: batches, mechanicalCases: mechanical,
        semanticDirections: directions, verdict: "semantic_pass"
    )
    try validateStablePayload(payload, contracts: contracts)

    let reordered = StableSemanticPayload(
        schemaVersion: payload.schemaVersion, contractID: payload.contractID,
        cpuReferenceToken: payload.cpuReferenceToken, fixtureCount: payload.fixtureCount,
        fixtureIDs: payload.fixtureIDs.reversed(),
        watermarkExcludedRowCount: payload.watermarkExcludedRowCount,
        batches: payload.batches.reversed(), mechanicalCases: payload.mechanicalCases.reversed(),
        semanticDirections: payload.semanticDirections.reversed(), verdict: payload.verdict
    )
    let firstData = try stablePayloadData(payload)
    let secondData = try stablePayloadData(reordered)
    guard firstData == secondData, sha256Hex(firstData) == sha256Hex(secondData) else {
        throw SemanticContractError.verdict
    }
    probes += 1

    var insufficientDirections = directions
    let first = insufficientDirections[0]
    insufficientDirections[0] = SemanticDirectionSummary(
        caseID: first.caseID, metric: first.metric, fixtureCount: first.fixtureCount,
        sourceTargetChangedPixels: first.sourceTargetChangedPixels - 1,
        sourceTargetAbsoluteRGBDelta: first.sourceTargetAbsoluteRGBDelta,
        neutralTargetChangedPixels: first.neutralTargetChangedPixels,
        neutralTargetAbsoluteRGBDelta: first.neutralTargetAbsoluteRGBDelta,
        sourceSignedMarginQ16: first.sourceSignedMarginQ16,
        neutralSignedMarginQ16: first.neutralSignedMarginQ16,
        signedMarginQ16: first.signedMarginQ16,
        siblingDistinctMarginQ16: first.siblingDistinctMarginQ16,
        outsideChangedPixels: first.outsideChangedPixels,
        outsideAbsoluteRGBDelta: first.outsideAbsoluteRGBDelta,
        protectedRegions: first.protectedRegions,
        failureReasonCodes: [], verdict: "semantic_pass"
    )
    try expect(.verdict) {
        try validateStablePayload(StableSemanticPayload(
            schemaVersion: payload.schemaVersion, contractID: payload.contractID,
            cpuReferenceToken: payload.cpuReferenceToken, fixtureCount: payload.fixtureCount,
            fixtureIDs: payload.fixtureIDs, watermarkExcludedRowCount: payload.watermarkExcludedRowCount,
            batches: payload.batches, mechanicalCases: payload.mechanicalCases,
            semanticDirections: insufficientDirections, verdict: payload.verdict
        ), contracts: contracts)
    }

    try expect(.inventory) {
        try validateStablePayload(StableSemanticPayload(
            schemaVersion: payload.schemaVersion, contractID: payload.contractID,
            cpuReferenceToken: payload.cpuReferenceToken, fixtureCount: payload.fixtureCount,
            fixtureIDs: payload.fixtureIDs, watermarkExcludedRowCount: payload.watermarkExcludedRowCount,
            batches: Array(payload.batches.dropLast()), mechanicalCases: payload.mechanicalCases,
            semanticDirections: payload.semanticDirections, verdict: payload.verdict
        ), contracts: contracts)
    }
    guard SemanticExitCode.success.rawValue == 0,
          Set([SemanticExitCode.success.rawValue, SemanticExitCode.semanticFailure.rawValue,
               SemanticExitCode.infrastructureFailure.rawValue]).count == 3 else {
        throw SemanticContractError.verdict
    }
    probes += 1

    let unsafe = try JSONSerialization.data(withJSONObject: [
        "stable": ["rawRGBA": [0, 1], "sourcePath": "/Users/private/portrait.png"]
    ])
    guard !privacySafeJSON(unsafe), privacySafeJSON(firstData) else {
        throw SemanticContractError.verdict
    }
    probes += 1

    let temporaryRoot = FileManager.default.temporaryDirectory
        .appendingPathComponent("beauty_semantic_report_\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: temporaryRoot, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: temporaryRoot) }
    let inputRoot = temporaryRoot.appendingPathComponent("input", isDirectory: true)
    let portraits = inputRoot.appendingPathComponent("portraits", isDirectory: true)
    try FileManager.default.createDirectory(at: portraits, withIntermediateDirectories: true)
    let fixture = portraits.appendingPathComponent("Portrait_A.jpg")
    try Data([0xFF, 0xD8, 0xFF, 0xD9]).write(to: fixture)
    let admitted = try admittedFixtureURLs(in: inputRoot)
    guard admitted.count == 1 else { throw SemanticContractError.verdict }
    probes += 1

    let duplicate = portraits.appendingPathComponent("portrait_a.PNG")
    try Data([137, 80, 78, 71, 13, 10, 26, 10]).write(to: duplicate)
    try expect(.admission) { _ = try admittedFixtureURLs(in: inputRoot) }
    try FileManager.default.removeItem(at: duplicate)
    let unsupported = portraits.appendingPathComponent("unsupported.gif")
    try Data([1]).write(to: unsupported)
    try expect(.admission) { _ = try admittedFixtureURLs(in: inputRoot) }
    try FileManager.default.removeItem(at: unsupported)
    let symlink = portraits.appendingPathComponent("linked.jpg")
    try FileManager.default.createSymbolicLink(at: symlink, withDestinationURL: fixture)
    try expect(.admission) { _ = try admittedFixtureURLs(in: inputRoot) }
    try FileManager.default.removeItem(at: symlink)
    let escaped = temporaryRoot.appendingPathComponent("escaped.jpg")
    try Data([1]).write(to: escaped)
    try expect(.admission) { try requireAdmittedRegularFile(escaped, beneath: inputRoot) }

    let runRoot = temporaryRoot.appendingPathComponent("attempt_001", isDirectory: true)
    try FileManager.default.createDirectory(at: runRoot, withIntermediateDirectories: true)
    let expectedOutputs = expectedRunOutputs(manifest: manifest, fixtures: admitted, runRoot: runRoot)
    let pngHeader = Data([137, 80, 78, 71, 13, 10, 26, 10])
    for output in expectedOutputs {
        try FileManager.default.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
        try pngHeader.write(to: output)
    }
    _ = try admitRunInventory(manifest: manifest, fixtures: admitted, runRoot: runRoot, attemptID: "attempt_001")
    probes += 1
    let extra = runRoot.appendingPathComponent("unexpected.png")
    try pngHeader.write(to: extra)
    try expect(.admission) {
        _ = try admitRunInventory(manifest: manifest, fixtures: admitted, runRoot: runRoot, attemptID: "attempt_001")
    }
    try FileManager.default.removeItem(at: extra)
    let missing = expectedOutputs[0]
    try FileManager.default.removeItem(at: missing)
    try expect(.admission) {
        _ = try admitRunInventory(manifest: manifest, fixtures: admitted, runRoot: runRoot, attemptID: "attempt_001")
    }
    try pngHeader.write(to: missing)
    let stale = expectedOutputs[1]
    try FileManager.default.setAttributes(
        [.modificationDate: Date(timeIntervalSince1970: 1)], ofItemAtPath: stale.path
    )
    try expect(.admission) {
        _ = try admitRunInventory(manifest: manifest, fixtures: admitted, runRoot: runRoot, attemptID: "attempt_001")
    }
    try FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: stale.path)
    let linkedOutput = expectedOutputs[2]
    try FileManager.default.removeItem(at: linkedOutput)
    try FileManager.default.createSymbolicLink(at: linkedOutput, withDestinationURL: expectedOutputs[3])
    try expect(.admission) {
        _ = try admitRunInventory(manifest: manifest, fixtures: admitted, runRoot: runRoot, attemptID: "attempt_001")
    }
    try FileManager.default.removeItem(at: linkedOutput)
    try pngHeader.write(to: linkedOutput)
    let hiddenFile = runRoot.appendingPathComponent(".hidden.png")
    try pngHeader.write(to: hiddenFile)
    try expect(.admission) {
        _ = try admitRunInventory(manifest: manifest, fixtures: admitted, runRoot: runRoot, attemptID: "attempt_001")
    }
    try FileManager.default.removeItem(at: hiddenFile)
    let hiddenDirectory = runRoot.appendingPathComponent(".hidden-directory", isDirectory: true)
    try FileManager.default.createDirectory(at: hiddenDirectory, withIntermediateDirectories: false)
    try expect(.admission) {
        _ = try admitRunInventory(manifest: manifest, fixtures: admitted, runRoot: runRoot, attemptID: "attempt_001")
    }
    try FileManager.default.removeItem(at: hiddenDirectory)
    let hiddenSymlink = runRoot.appendingPathComponent(".hidden-link")
    try FileManager.default.createSymbolicLink(at: hiddenSymlink, withDestinationURL: expectedOutputs[0])
    try expect(.admission) {
        _ = try admitRunInventory(manifest: manifest, fixtures: admitted, runRoot: runRoot, attemptID: "attempt_001")
    }
    try FileManager.default.removeItem(at: hiddenSymlink)
    let hiddenRendererReport = runRoot.appendingPathComponent(".beauty-example-renderer-report.json")
    try Data("{}".utf8).write(to: hiddenRendererReport)
    try expect(.admission) {
        _ = try admitRunInventory(manifest: manifest, fixtures: admitted, runRoot: runRoot, attemptID: "attempt_001")
    }
    try FileManager.default.removeItem(at: hiddenRendererReport)
    try expect(.admission) {
        _ = try admitRunInventory(manifest: manifest, fixtures: admitted, runRoot: runRoot, attemptID: "different_attempt")
    }

    let context = CIContext(options: nil)
    do {
        _ = try canonicalImage(at: fixture, context: context)
        throw SemanticContractError.verdict
    } catch is CompareError {
        probes += 1
    }
    try expect(.admission) {
        try validateCanonicalPair(generatedImage(rectangles: []), generatedImage(width: 81, rectangles: []))
    }

    let reportURL = temporaryRoot.appendingPathComponent("reports/report.json")
    try FileManager.default.createDirectory(
        at: reportURL.deletingLastPathComponent(), withIntermediateDirectories: true
    )
    try Data("prior_payload".utf8).write(to: reportURL)
    try prepareReportDestination(reportURL)
    guard !FileManager.default.fileExists(atPath: reportURL.path) else {
        throw SemanticContractError.verdict
    }
    let digest = try writeSemanticReport(
        payload: payload, contracts: contracts, attemptID: "attempt_001",
        generatedAtUTC: "2000-01-01T00:00:00Z", to: reportURL
    )
    let decoded = try JSONDecoder().decode(SemanticReportEnvelope.self, from: Data(contentsOf: reportURL))
    guard decoded.stablePayloadDigest == digest,
          decoded.stablePayload == canonicalPayload(payload) else {
        throw SemanticContractError.verdict
    }
    probes += 1
    let secondReportURL = temporaryRoot.appendingPathComponent("reports/report_second.json")
    let secondDigest = try writeSemanticReport(
        payload: payload, contracts: contracts, attemptID: "attempt_002",
        generatedAtUTC: "2099-12-31T23:59:59Z", to: secondReportURL
    )
    guard digest == secondDigest else { throw SemanticContractError.verdict }
    probes += 1

    return probes
}

func runSemanticSelfTests() throws -> Int {
    let manifestURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("face-feature-batch-manifest.json")
    let manifestData = try Data(contentsOf: manifestURL)
    let manifest = try validateManifestData(manifestData)
    guard let contracts = manifest.semanticContracts, contracts.count == 8 else {
        throw SemanticContractError.contracts
    }

    var mutationCount = 0
    func expectCategory(_ expected: SemanticContractError, _ body: () throws -> Void) throws {
        do {
            try body()
        } catch let error as SemanticContractError {
            guard error == expected else { throw SemanticContractError.verdict }
            mutationCount += 1
            return
        } catch {
            throw SemanticContractError.verdict
        }
        throw SemanticContractError.verdict
    }
    func expectContractRejection(_ body: () throws -> Void) throws {
        do {
            try body()
        } catch is SemanticContractError {
            mutationCount += 1
            return
        } catch {
            throw SemanticContractError.verdict
        }
        throw SemanticContractError.verdict
    }
    func expectIneffective(_ observation: SemanticObservation, _ contract: SemanticContract) throws {
        guard try !semanticEffective(observation, for: contract) else {
            throw SemanticContractError.verdict
        }
        mutationCount += 1
    }

    // Boundary and verdict probes: equality passes; one integer unit across each
    // frozen boundary, wrong polarity, exterior signal, and protected spill fail.
    for contract in contracts {
        let exact = exactObservation(for: contract)
        guard try semanticEffective(exact, for: contract) else {
            throw SemanticContractError.verdict
        }
        let aggregate = try aggregateSemanticObservations([exact])
        guard aggregate.fixtureCount == 1, aggregate == exact else {
            throw SemanticContractError.verdict
        }
        try expectIneffective(replacing(
            exact, changedPixels: Int64(contract.thresholds.minimumChangedPixels - 1)
        ), contract)
        try expectIneffective(replacing(
            exact, absoluteRGBDelta: Int64(contract.thresholds.minimumAbsoluteRGBDelta - 1)
        ), contract)
        let belowSigned = contract.expectedSign == .positive
            ? Int64(contract.thresholds.minimumSignedMarginQ16 - 1)
            : -Int64(contract.thresholds.minimumSignedMarginQ16 - 1)
        try expectIneffective(replacing(exact, signedMarginQ16: belowSigned), contract)
        try expectIneffective(replacing(
            exact, outsideChangedPixels: Int64(contract.thresholds.maximumOutsideChangedPixels + 1)
        ), contract)
        try expectIneffective(replacing(
            exact, outsideAbsoluteRGBDelta: Int64(contract.thresholds.maximumOutsideAbsoluteRGBDelta + 1)
        ), contract)
        let wrongSign = contract.expectedSign == .positive
            ? -Int64(contract.thresholds.minimumSignedMarginQ16)
            : Int64(contract.thresholds.minimumSignedMarginQ16)
        try expectIneffective(replacing(exact, signedMarginQ16: wrongSign), contract)
        for protected in contract.protectedRegions {
            var spilled = exact.protectedChangedPixels
            spilled[protected.id] = Int64(protected.maximumChangedPixels + 1)
            try expectIneffective(replacing(exact, protectedChangedPixels: spilled), contract)
            var deltaSpilled = exact.protectedAbsoluteRGBDelta
            deltaSpilled[protected.id] = Int64(protected.maximumAbsoluteRGBDelta + 1)
            try expectIneffective(replacing(exact, protectedAbsoluteRGBDelta: deltaSpilled), contract)
        }
        guard let watermark = contract.protectedRegions.first(where: { $0.id == "watermark" }) else {
            throw SemanticContractError.verdict
        }
        var watermarkOnly = exact.protectedChangedPixels
        watermarkOnly[watermark.id] = Int64(watermark.maximumChangedPixels + 1)
        try expectIneffective(replacing(exact, changedPixels: 0, protectedChangedPixels: watermarkOnly), contract)
    }

    // Contract mutation probes use category-only errors and never print payloads.
    try expectCategory(.contracts) {
        try validateManifest(replacing(manifest, semanticContracts: []))
    }
    try expectCategory(.order) {
        try validateManifest(replacing(manifest, semanticContracts: Array(contracts.reversed())))
    }
    var duplicateContracts = contracts
    duplicateContracts[1] = replacing(duplicateContracts[1], caseID: duplicateContracts[0].caseID)
    try expectCategory(.order) {
        try validateManifest(replacing(manifest, semanticContracts: duplicateContracts))
    }
    var missingSource = contracts
    missingSource[0] = replacing(missingSource[0], comparisonCaseIDs: Array(missingSource[0].comparisonCaseIDs.dropFirst()))
    try expectCategory(.reference) {
        try validateManifest(replacing(manifest, semanticContracts: missingSource))
    }
    var unknownSibling = contracts
    unknownSibling[0] = replacing(unknownSibling[0], comparisonCaseIDs: ["source", "geometryBaseline_noop", "unknownSibling"])
    try expectCategory(.reference) {
        try validateManifest(replacing(manifest, semanticContracts: unknownSibling))
    }
    var emptyTarget = contracts
    emptyTarget[0] = replacing(emptyTarget[0], targetRegions: [])
    try expectCategory(.region) {
        try validateManifest(replacing(manifest, semanticContracts: emptyTarget))
    }
    var emptyProtection = contracts
    let firstProtection = emptyProtection[0].protectedRegions[0]
    var emptyProtectionList = emptyProtection[0].protectedRegions
    emptyProtectionList[0] = ProtectedRegionContract(
        id: firstProtection.id, regions: [],
        maximumChangedPixels: firstProtection.maximumChangedPixels,
        maximumAbsoluteRGBDelta: firstProtection.maximumAbsoluteRGBDelta
    )
    emptyProtection[0] = replacing(emptyProtection[0], protectedRegions: emptyProtectionList)
    try expectCategory(.region) {
        try validateManifest(replacing(manifest, semanticContracts: emptyProtection))
    }
    var duplicateProtection = contracts
    var duplicateProtectionList = duplicateProtection[0].protectedRegions
    duplicateProtectionList[1] = ProtectedRegionContract(
        id: duplicateProtectionList[0].id,
        regions: duplicateProtectionList[1].regions,
        maximumChangedPixels: duplicateProtectionList[1].maximumChangedPixels,
        maximumAbsoluteRGBDelta: duplicateProtectionList[1].maximumAbsoluteRGBDelta
    )
    duplicateProtection[0] = replacing(duplicateProtection[0], protectedRegions: duplicateProtectionList)
    try expectCategory(.identifier) {
        try validateManifest(replacing(manifest, semanticContracts: duplicateProtection))
    }
    var missingTargetID = contracts
    let identifiedTarget = missingTargetID[0].targetRegions[0]
    var missingTargetIDList = missingTargetID[0].targetRegions
    missingTargetIDList[0] = NormalizedRegion(
        id: nil, minXPPM: identifiedTarget.minXPPM, maxXPPM: identifiedTarget.maxXPPM,
        minYPPM: identifiedTarget.minYPPM, maxYPPM: identifiedTarget.maxYPPM
    )
    missingTargetID[0] = replacing(missingTargetID[0], targetRegions: missingTargetIDList)
    try expectCategory(.identifier) {
        try validateManifest(replacing(manifest, semanticContracts: missingTargetID))
    }
    var outOfRange = contracts
    let target = outOfRange[0].targetRegions[0]
    var outOfRangeTargets = outOfRange[0].targetRegions
    outOfRangeTargets[0] = NormalizedRegion(
        id: target.id, minXPPM: -1, maxXPPM: target.maxXPPM,
        minYPPM: target.minYPPM, maxYPPM: target.maxYPPM
    )
    outOfRange[0] = replacing(outOfRange[0], targetRegions: outOfRangeTargets)
    try expectCategory(.region) {
        try validateManifest(replacing(manifest, semanticContracts: outOfRange))
    }
    var overlapped = contracts
    var overlappedProtection = overlapped[0].protectedRegions
    overlappedProtection[0] = ProtectedRegionContract(
        id: overlappedProtection[0].id,
        regions: [overlapped[0].targetRegions[0]],
        maximumChangedPixels: overlappedProtection[0].maximumChangedPixels,
        maximumAbsoluteRGBDelta: overlappedProtection[0].maximumAbsoluteRGBDelta
    )
    overlapped[0] = replacing(overlapped[0], protectedRegions: overlappedProtection)
    try expectCategory(.overlap) {
        try validateManifest(replacing(manifest, semanticContracts: overlapped))
    }
    var negativeThreshold = contracts
    let originalThreshold = negativeThreshold[0].thresholds
    negativeThreshold[0] = replacing(negativeThreshold[0], thresholds: SemanticThresholds(
        minimumChangedPixels: originalThreshold.minimumChangedPixels,
        minimumAbsoluteRGBDelta: originalThreshold.minimumAbsoluteRGBDelta,
        minimumSignedMarginQ16: originalThreshold.minimumSignedMarginQ16,
        maximumOutsideChangedPixels: -1,
        maximumOutsideAbsoluteRGBDelta: originalThreshold.maximumOutsideAbsoluteRGBDelta
    ))
    try expectCategory(.threshold) {
        try validateManifest(replacing(manifest, semanticContracts: negativeThreshold))
    }

    // The manifest cannot redefine any frozen scalar, region edge, membership,
    // or ordering and then teach the generated boundary probes the weaker value.
    for contractIndex in contracts.indices {
        let contract = contracts[contractIndex]
        let thresholdMutations = [
            SemanticThresholds(
                minimumChangedPixels: contract.thresholds.minimumChangedPixels + 1,
                minimumAbsoluteRGBDelta: contract.thresholds.minimumAbsoluteRGBDelta,
                minimumSignedMarginQ16: contract.thresholds.minimumSignedMarginQ16,
                maximumOutsideChangedPixels: contract.thresholds.maximumOutsideChangedPixels,
                maximumOutsideAbsoluteRGBDelta: contract.thresholds.maximumOutsideAbsoluteRGBDelta
            ),
            SemanticThresholds(
                minimumChangedPixels: contract.thresholds.minimumChangedPixels,
                minimumAbsoluteRGBDelta: contract.thresholds.minimumAbsoluteRGBDelta + 1,
                minimumSignedMarginQ16: contract.thresholds.minimumSignedMarginQ16,
                maximumOutsideChangedPixels: contract.thresholds.maximumOutsideChangedPixels,
                maximumOutsideAbsoluteRGBDelta: contract.thresholds.maximumOutsideAbsoluteRGBDelta
            ),
            SemanticThresholds(
                minimumChangedPixels: contract.thresholds.minimumChangedPixels,
                minimumAbsoluteRGBDelta: contract.thresholds.minimumAbsoluteRGBDelta,
                minimumSignedMarginQ16: contract.thresholds.minimumSignedMarginQ16 + 1,
                maximumOutsideChangedPixels: contract.thresholds.maximumOutsideChangedPixels,
                maximumOutsideAbsoluteRGBDelta: contract.thresholds.maximumOutsideAbsoluteRGBDelta
            ),
            SemanticThresholds(
                minimumChangedPixels: contract.thresholds.minimumChangedPixels,
                minimumAbsoluteRGBDelta: contract.thresholds.minimumAbsoluteRGBDelta,
                minimumSignedMarginQ16: contract.thresholds.minimumSignedMarginQ16,
                maximumOutsideChangedPixels: contract.thresholds.maximumOutsideChangedPixels + 1,
                maximumOutsideAbsoluteRGBDelta: contract.thresholds.maximumOutsideAbsoluteRGBDelta
            ),
            SemanticThresholds(
                minimumChangedPixels: contract.thresholds.minimumChangedPixels,
                minimumAbsoluteRGBDelta: contract.thresholds.minimumAbsoluteRGBDelta,
                minimumSignedMarginQ16: contract.thresholds.minimumSignedMarginQ16,
                maximumOutsideChangedPixels: contract.thresholds.maximumOutsideChangedPixels,
                maximumOutsideAbsoluteRGBDelta: contract.thresholds.maximumOutsideAbsoluteRGBDelta + 1
            )
        ]
        for thresholds in thresholdMutations {
            var mutated = contracts
            mutated[contractIndex] = replacing(contract, thresholds: thresholds)
            try expectContractRejection {
                try validateManifest(replacing(manifest, semanticContracts: mutated))
            }
        }

        for regionIndex in contract.targetRegions.indices {
            let region = contract.targetRegions[regionIndex]
            let edgeMutations = [
                NormalizedRegion(id: region.id, minXPPM: region.minXPPM + 1, maxXPPM: region.maxXPPM, minYPPM: region.minYPPM, maxYPPM: region.maxYPPM),
                NormalizedRegion(id: region.id, minXPPM: region.minXPPM, maxXPPM: region.maxXPPM + 1, minYPPM: region.minYPPM, maxYPPM: region.maxYPPM),
                NormalizedRegion(id: region.id, minXPPM: region.minXPPM, maxXPPM: region.maxXPPM, minYPPM: region.minYPPM + 1, maxYPPM: region.maxYPPM),
                NormalizedRegion(id: region.id, minXPPM: region.minXPPM, maxXPPM: region.maxXPPM, minYPPM: region.minYPPM, maxYPPM: region.maxYPPM + 1)
            ]
            for mutatedRegion in edgeMutations {
                var targets = contract.targetRegions
                targets[regionIndex] = mutatedRegion
                var mutated = contracts
                mutated[contractIndex] = replacing(contract, targetRegions: targets)
                try expectContractRejection {
                    try validateManifest(replacing(manifest, semanticContracts: mutated))
                }
            }
        }
        if contract.targetRegions.count > 1 {
            var mutated = contracts
            mutated[contractIndex] = replacing(contract, targetRegions: Array(contract.targetRegions.reversed()))
            try expectContractRejection {
                try validateManifest(replacing(manifest, semanticContracts: mutated))
            }
        }

        for protectionIndex in contract.protectedRegions.indices {
            let protection = contract.protectedRegions[protectionIndex]
            for ceiling in 0..<2 {
                var protections = contract.protectedRegions
                protections[protectionIndex] = ProtectedRegionContract(
                    id: protection.id,
                    regions: protection.regions,
                    maximumChangedPixels: protection.maximumChangedPixels + (ceiling == 0 ? 1 : 0),
                    maximumAbsoluteRGBDelta: protection.maximumAbsoluteRGBDelta + (ceiling == 1 ? 1 : 0)
                )
                var mutated = contracts
                mutated[contractIndex] = replacing(contract, protectedRegions: protections)
                try expectContractRejection {
                    try validateManifest(replacing(manifest, semanticContracts: mutated))
                }
            }
            for regionIndex in protection.regions.indices {
                let region = protection.regions[regionIndex]
                let edgeMutations = [
                    NormalizedRegion(id: region.id, minXPPM: region.minXPPM + 1, maxXPPM: region.maxXPPM, minYPPM: region.minYPPM, maxYPPM: region.maxYPPM),
                    NormalizedRegion(id: region.id, minXPPM: region.minXPPM, maxXPPM: region.maxXPPM + 1, minYPPM: region.minYPPM, maxYPPM: region.maxYPPM),
                    NormalizedRegion(id: region.id, minXPPM: region.minXPPM, maxXPPM: region.maxXPPM, minYPPM: region.minYPPM + 1, maxYPPM: region.maxYPPM),
                    NormalizedRegion(id: region.id, minXPPM: region.minXPPM, maxXPPM: region.maxXPPM, minYPPM: region.minYPPM, maxYPPM: region.maxYPPM + 1)
                ]
                for mutatedRegion in edgeMutations {
                    var regions = protection.regions
                    regions[regionIndex] = mutatedRegion
                    var protections = contract.protectedRegions
                    protections[protectionIndex] = ProtectedRegionContract(
                        id: protection.id, regions: regions,
                        maximumChangedPixels: protection.maximumChangedPixels,
                        maximumAbsoluteRGBDelta: protection.maximumAbsoluteRGBDelta
                    )
                    var mutated = contracts
                    mutated[contractIndex] = replacing(contract, protectedRegions: protections)
                    try expectContractRejection {
                        try validateManifest(replacing(manifest, semanticContracts: mutated))
                    }
                }
            }
            if protection.regions.count > 1 {
                var protections = contract.protectedRegions
                protections[protectionIndex] = ProtectedRegionContract(
                    id: protection.id, regions: Array(protection.regions.reversed()),
                    maximumChangedPixels: protection.maximumChangedPixels,
                    maximumAbsoluteRGBDelta: protection.maximumAbsoluteRGBDelta
                )
                var mutated = contracts
                mutated[contractIndex] = replacing(contract, protectedRegions: protections)
                try expectContractRejection {
                    try validateManifest(replacing(manifest, semanticContracts: mutated))
                }
            }
        }
        if contract.protectedRegions.count > 1 {
            var mutated = contracts
            mutated[contractIndex] = replacing(contract, protectedRegions: Array(contract.protectedRegions.reversed()))
            try expectContractRejection {
                try validateManifest(replacing(manifest, semanticContracts: mutated))
            }
        }
    }

    let jsonObject = try JSONSerialization.jsonObject(with: manifestData)
    guard var absentObject = jsonObject as? [String: Any] else {
        throw SemanticContractError.decode
    }
    absentObject.removeValue(forKey: "semanticContracts")
    try expectCategory(.contracts) {
        _ = try validateManifestData(JSONSerialization.data(withJSONObject: absentObject))
    }
    var nullObject = absentObject
    nullObject["semanticContracts"] = NSNull()
    try expectCategory(.contracts) {
        _ = try validateManifestData(JSONSerialization.data(withJSONObject: nullObject))
    }
    guard let manifestText = String(data: manifestData, encoding: .utf8) else {
        throw SemanticContractError.decode
    }
    let unknownMetricText = manifestText.replacingOccurrences(
        of: "\"contourContinuityGain\"", with: "\"unknownMetric\""
    )
    try expectCategory(.decode) {
        _ = try validateManifestData(Data(unknownMetricText.utf8))
    }
    let unknownSignText = manifestText.replacingOccurrences(
        of: "\"expectedSign\": \"positive\"", with: "\"expectedSign\": \"sideways\""
    )
    try expectCategory(.decode) {
        _ = try validateManifestData(Data(unknownSignText.utf8))
    }
    let nonIntegralText = manifestText.replacingOccurrences(
        of: "\"minXPPM\": 100000", with: "\"minXPPM\": 100000.5"
    )
    try expectCategory(.decode) {
        _ = try validateManifestData(Data(nonIntegralText.utf8))
    }
    let nonFiniteEquivalentText = manifestText.replacingOccurrences(
        of: "\"minXPPM\": 100000", with: "\"minXPPM\": 1e309"
    )
    try expectCategory(.decode) {
        _ = try validateManifestData(Data(nonFiniteEquivalentText.utf8))
    }

    // Half-open ownership: touching is disjoint; a one-raster-column intrusion fails.
    let touchingLeft = try rasterize(NormalizedRegion(
        id: "left", minXPPM: 0, maxXPPM: 500000, minYPPM: 0, maxYPPM: 1000000
    ), width: 100, height: 100)
    let touchingRight = try rasterize(NormalizedRegion(
        id: "right", minXPPM: 500000, maxXPPM: 1000000, minYPPM: 0, maxYPPM: 1000000
    ), width: 100, height: 100)
    guard !overlaps(touchingLeft, touchingRight) else { throw SemanticContractError.verdict }
    let oneColumnOverlap = try rasterize(NormalizedRegion(
        id: "right", minXPPM: 490000, maxXPPM: 1000000, minYPPM: 0, maxYPPM: 1000000
    ), width: 100, height: 100)
    guard overlaps(touchingLeft, oneColumnOverlap) else { throw SemanticContractError.verdict }
    mutationCount += 1

    // Admission, ordering, arithmetic, and generated-buffer probes.
    try expectCategory(.admission) {
        try requireSemanticAdmission(fixtureCount: 0, hasSource: true, hasNeutral: true, hasCandidate: true)
    }
    try expectCategory(.admission) {
        try requireSemanticAdmission(fixtureCount: 1, hasSource: false, hasNeutral: true, hasCandidate: true)
    }
    try expectCategory(.admission) {
        try requireSemanticAdmission(fixtureCount: 1, hasSource: true, hasNeutral: false, hasCandidate: true)
    }
    try requireSemanticAdmission(fixtureCount: 1, hasSource: true, hasNeutral: true, hasCandidate: true)

    let reversedManifestData = try JSONEncoder().encode(replacing(manifest, semanticContracts: Array(contracts.reversed())))
    let reordered = try JSONDecoder().decode(BatchManifest.self, from: reversedManifestData)
    guard let reorderedContracts = reordered.semanticContracts else { throw SemanticContractError.contracts }
    let reorderedRows = reorderedContracts.flatMap { contract in
        contract.targetRegions.enumerated().map {
            SemanticMetricRow(caseID: contract.caseID, regionID: $1.id ?? "", valueQ16: 7, insertionOrder: $0)
        }
    }
    let canonicalCases = canonicalSemanticRows(reorderedRows).map { $0.caseID }
    guard canonicalCases.first == expectedSemanticContracts.first?.caseID,
          canonicalCases.last == expectedSemanticContracts.last?.caseID else {
        throw SemanticContractError.verdict
    }
    let stableTieRows = canonicalSemanticRows([
        .init(caseID: contracts[0].caseID, regionID: "same", valueQ16: 4, insertionOrder: 1),
        .init(caseID: contracts[0].caseID, regionID: "same", valueQ16: 4, insertionOrder: 0)
    ])
    guard stableTieRows.map({ $0.insertionOrder }) == [0, 1] else {
        throw SemanticContractError.verdict
    }
    mutationCount += 2

    try expectCategory(.arithmetic) {
        _ = try rasterize(NormalizedRegion(
            id: "overflow", minXPPM: 0, maxXPPM: 1_000_000,
            minYPPM: 0, maxYPPM: 1_000_000
        ), width: Int64.max, height: 1)
    }
    let exact = exactObservation(for: contracts[0])
    try expectCategory(.arithmetic) {
        _ = try aggregateSemanticObservations([
            replacing(exact, absoluteRGBDelta: Int64.max),
            replacing(exact, absoluteRGBDelta: 1)
        ])
    }
    try expectCategory(.arithmetic) {
        _ = try aggregateSemanticObservations([
            replacing(exact, signedMarginQ16: Int64.max),
            replacing(exact, signedMarginQ16: 1)
        ])
    }

    let generatedSource = CanonicalImage(width: 4, height: 4, rgba: Array(repeating: 0, count: 64))
    var generatedBytes = generatedSource.rgba
    generatedBytes[0] = 1
    let generatedCandidate = CanonicalImage(width: 4, height: 4, rgba: generatedBytes)
    let generatedMetrics = try metrics(generatedSource, generatedCandidate, excludedRowsPerEdge: 0, tolerance: 0)
    guard generatedMetrics.comparedPixels == 16, generatedMetrics.changedPixels == 1 else {
        throw SemanticContractError.verdict
    }
    mutationCount += 1

    mutationCount += try runDirectionMetricSelfTests(contracts: contracts)
    mutationCount += try runSemanticReportSelfTests(manifest: manifest)

    return mutationCount
}

let commandArguments = Array(CommandLine.arguments.dropFirst())
if commandArguments == ["--self-test"] {
    do {
        let mutationCount = try runSemanticSelfTests()
        print("semantic_validation_self_test=PASS mutations=\(mutationCount) inventories=5/65/8 categories=metric,boundary,ownership,admission,ordering,arithmetic,report,privacy,verdict")
        exit(0)
    } catch {
        fputs("semantic contract self-test failed: \(error)\n", stderr)
        exit(1)
    }
}

if commandArguments.contains("--verify-run-inventory") {
    do {
        let inputURL = URL(
            fileURLWithPath: try argument("--input", in: commandArguments), isDirectory: true
        )
        let runRoot = URL(
            fileURLWithPath: try argument("--run-root", in: commandArguments), isDirectory: true
        )
        let manifestURL = URL(fileURLWithPath: try argument("--manifest", in: commandArguments))
        let attemptID = try argument("--attempt-id", in: commandArguments)
        try requireAdmittedRegularFile(manifestURL, beneath: manifestURL.deletingLastPathComponent())
        let manifest = try validateManifestData(Data(contentsOf: manifestURL))
        let fixtures = try admittedFixtureURLs(in: inputURL)
        _ = try admitRunInventory(
            manifest: manifest, fixtures: fixtures, runRoot: runRoot, attemptID: attemptID
        )
        print("run_inventory=PASS outputs=\(expectedRunOutputs(manifest: manifest, fixtures: fixtures, runRoot: runRoot).count)")
        exit(0)
    } catch {
        fputs("run_inventory=infrastructure_failure\n", stderr)
        exit(SemanticExitCode.infrastructureFailure.rawValue)
    }
}

do {
    let arguments = commandArguments
    let inputURL = URL(fileURLWithPath: try argument("--input", in: arguments), isDirectory: true)
    let runRoot = URL(fileURLWithPath: try argument("--run-root", in: arguments), isDirectory: true)
    let manifestURL = URL(fileURLWithPath: try argument("--manifest", in: arguments))
    let reportURL = URL(fileURLWithPath: try argument("--report", in: arguments))
    let attemptID = try argument("--attempt-id", in: arguments)

    try prepareReportDestination(reportURL)
    try requireAdmittedRegularFile(manifestURL, beneath: manifestURL.deletingLastPathComponent())

    let manifestData = try Data(contentsOf: manifestURL)
    let manifest = try validateManifestData(manifestData)
    let allCaseIDs = manifest.batches.flatMap { $0.cases }
    guard let contracts = manifest.semanticContracts else { throw SemanticContractError.contracts }
    let fixtures = try admittedFixtureURLs(in: inputURL)
    _ = try admitRunInventory(
        manifest: manifest, fixtures: fixtures, runRoot: runRoot, attemptID: attemptID
    )

    let context = CIContext(options: [
        .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
        .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
    ])
    let inputImages = try fixtures.map { try canonicalImage(at: $0, context: context) }
    let tolerance = 2

    for image in inputImages {
        for contract in contracts {
            try validateOwnership(contract, width: Int64(image.width), height: Int64(image.height))
            _ = try watermarkSafeRegions(
                contract.targetRegions, image: image,
                excludedRows: watermarkExcludedRows(width: image.width)
            )
        }
    }

    let controlImages = try fixtures.map { fixture -> CanonicalImage in
        let url = outputURL(
            runRoot: runRoot,
            batchID: "control",
            stem: fixture.deletingPathExtension().lastPathComponent,
            caseID: manifest.control.id
        )
        return try canonicalImage(at: url, context: context)
    }
    for (source, neutral) in zip(inputImages, controlImages) {
        try validateCanonicalPair(source, neutral)
    }

    var candidateImages: [String: [CanonicalImage]] = [:]
    for batch in manifest.batches {
        for caseID in batch.cases {
            let decoded = try fixtures.map { fixture -> CanonicalImage in
                try canonicalImage(at: outputURL(
                    runRoot: runRoot, batchID: batch.id,
                    stem: fixture.deletingPathExtension().lastPathComponent,
                    caseID: caseID
                ), context: context)
            }
            for (source, candidate) in zip(inputImages, decoded) {
                try validateCanonicalPair(source, candidate)
            }
            candidateImages[caseID] = decoded
        }
    }

    var caseSummaries: [MechanicalCaseSummary] = []
    var batchSummaries: [BatchSummary] = []

    for batch in manifest.batches {
        for caseID in batch.cases {
            guard let rendered = candidateImages[caseID], rendered.count == fixtures.count else {
                throw SemanticContractError.inventory
            }
            let inputMetric = aggregate(try inputImages.indices.map { index in
                try metrics(
                    inputImages[index], rendered[index],
                    excludedRowsPerEdge: watermarkExcludedRows(width: inputImages[index].width),
                    tolerance: tolerance
                )
            })
            let neutralMetric = aggregate(try inputImages.indices.map { index in
                try metrics(
                    controlImages[index], rendered[index],
                    excludedRowsPerEdge: watermarkExcludedRows(width: inputImages[index].width),
                    tolerance: tolerance
                )
            })

            caseSummaries.append(MechanicalCaseSummary(
                batchID: batch.id,
                caseID: caseID,
                fixtureCount: fixtures.count,
                outputCount: fixtures.count,
                missingOutputCount: 0,
                sourceChangedPixels: inputMetric.changedPixels,
                sourceComparedPixels: inputMetric.comparedPixels,
                sourceAbsoluteRGBDelta: inputMetric.absoluteRGBDelta,
                sourceMaxRGBDelta: inputMetric.maxRGBDelta,
                neutralChangedPixels: neutralMetric.changedPixels,
                neutralComparedPixels: neutralMetric.comparedPixels,
                neutralAbsoluteRGBDelta: neutralMetric.absoluteRGBDelta,
                neutralMaxRGBDelta: neutralMetric.maxRGBDelta,
                descriptiveStatus: "complete_mechanical_summary"
            ))
        }
        batchSummaries.append(BatchSummary(
            id: batch.id,
            caseCount: batch.cases.count,
            completeCaseCount: batch.cases.count,
            missingOutputCount: 0
        ))
    }

    let semanticDirections = try contracts.map { contract -> SemanticDirectionSummary in
        guard let candidate = candidateImages[contract.caseID] else {
            throw SemanticContractError.inventory
        }
        let siblings = try Array(contract.comparisonCaseIDs.dropFirst(2)).map { caseID -> [CanonicalImage] in
            guard let images = candidateImages[caseID] else { throw SemanticContractError.inventory }
            return images
        }
        return try semanticDirectionSummary(
            contract: contract, sources: inputImages, neutrals: controlImages,
            candidates: candidate, siblingImages: siblings
        )
    }
    let overallPass = semanticDirections.allSatisfy { $0.verdict == "semantic_pass" }
    let payload = StableSemanticPayload(
        schemaVersion: "beauty.face-feature-batch-report.semantic.1",
        contractID: sha256Hex(manifestData),
        cpuReferenceToken: "beauty_cpu_reference_v1",
        fixtureCount: fixtures.count,
        fixtureIDs: fixtures.indices.map { String(format: "portrait_%03d", $0 + 1) },
        watermarkExcludedRowCount: inputImages.reduce(0) {
            $0 + watermarkExcludedRows(width: $1.width)
        },
        batches: batchSummaries,
        mechanicalCases: caseSummaries,
        semanticDirections: semanticDirections,
        verdict: overallPass ? "semantic_pass" : "semantic_fail"
    )
    let digest = try writeSemanticReport(
        payload: payload, contracts: contracts, attemptID: attemptID,
        generatedAtUTC: ISO8601DateFormatter().string(from: Date()), to: reportURL
    )
    print("semantic_report=complete batches=5 cases=\(allCaseIDs.count) directions=8 fixtures=\(fixtures.count)")
    print("stable_payload_digest=\(digest) verdict=\(payload.verdict)")
    exit(overallPass ? SemanticExitCode.success.rawValue : SemanticExitCode.semanticFailure.rawValue)
} catch {
    fputs("semantic_report=infrastructure_failure\n", stderr)
    exit(SemanticExitCode.infrastructureFailure.rawValue)
}
