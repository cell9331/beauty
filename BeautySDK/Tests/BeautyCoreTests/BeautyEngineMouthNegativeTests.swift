import BeautyCore
import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

final class BeautyEngineMouthNegativeTests: XCTestCase {
    private let extent = CGRect(x: 0, y: 0, width: 640, height: 800)
    private let rows: [(String, BeautyParameters)] = [
        ("geometryBaseline_noop", .init()),
        ("mouthWidth_minus0p35", .init(mouthWidth: -0.35)),
        ("mouthWidth_plus0p35", .init(mouthWidth: 0.35)),
        ("mouthSize_plus0p35", .init(mouthSize: 0.35)),
        ("mouthSize_minus0p35", .init(mouthSize: -0.35))
    ]
    private var diagnosticRow = "source"
    private var returnedImageCount = 0
    private enum Stage: String, Error {
        case source = "P94N_STAGE_SOURCE"
        case detect = "P94N_STAGE_DETECT"
        case result = "P94N_STAGE_RESULT"
        case legacy = "P94N_STAGE_LEGACY"
        case extract = "P94N_STAGE_EXTRACT"
        case metric = "P94N_STAGE_METRIC"
        case receipt = "P94N_STAGE_RECEIPT"
    }

    func testNegativeWidthAllFiveComparisons() {
        do {
            let image = try at(.source) { try MouthRepairFixture.image() }
            let source = MouthRepairFixture.source()
            let carrier = try at(.source) { try extract(image, active: false) }
            check(carrier == source, "P94N_STAGE_SOURCE")
            returnedImageCount = 0
            let sourceShape = try at(.metric) { try shape(source) }
            // The locator is admitted against the independently authored
            // source recipe, never fitted to a candidate's output or field.
            check(sourceShape.width == 228 && sourceShape.height == 114, "P94N_SOURCE_SHAPE")
            check(abs(sourceShape.centerX-320) < 0.2 && abs(sourceShape.centerY-560) < 0.2,
                  "P94N_SOURCE_REGISTRATION")
            var outputs: [[UInt8]] = []
            // Exactly twenty returned images: five rows, both real wrappers,
            // each twice. Fresh engines serialize the explicit CPU path.
            for row in rows {
                diagnosticRow = row.0
                let bytes = try render(row, image: image, source: source)
                outputs.append(bytes)
                checkProtected(source, bytes, isCoarseSize: row.1.mouthSize != 0)
            }
            diagnosticRow = "mouthWidth_minus0p35"
            guard outputs.count == 5 else { throw Stage.metric }
            check(returnedImageCount == 20, "P94N_TWENTY_WRAPPER_OUTPUTS")
            check(outputs[0] == source, "P94N_NEUTRAL_SOURCE_EXACT")
            let measured = try at(.metric) { try outputs.map(shape) }
            let neutral = measured[0], negative = measured[1], positive = measured[2]
            let sizePlus = measured[3], sizeMinus = measured[4]
            // Every direction is measured from source-defined dark mouth
            // material. These are response checks, without a frozen old digest
            // or a claim that a screenshot provides a common neutral state.
            check(negative.width < sourceShape.width && negative.horizontalSpan < sourceShape.horizontalSpan,
                  "P94N_NEGATIVE_WIDTH_CONTRACTS")
            check(positive.width > sourceShape.width && positive.horizontalSpan > sourceShape.horizontalSpan,
                  "P94N_POSITIVE_WIDTH_EXPANDS")
            check(sizePlus.width > sourceShape.width && sizePlus.height > sourceShape.height
                  && sizePlus.horizontalSpan > sourceShape.horizontalSpan
                  && sizePlus.verticalSpan > sourceShape.verticalSpan, "P94N_SIZE_PLUS_TWO_AXES")
            check(sizeMinus.width < sourceShape.width && sizeMinus.height < sourceShape.height
                  && sizeMinus.horizontalSpan < sourceShape.horizontalSpan
                  && sizeMinus.verticalSpan < sourceShape.verticalSpan, "P94N_SIZE_MINUS_TWO_AXES")
            check(abs(negative.height-sourceShape.height) <= 1 && abs(positive.height-sourceShape.height) <= 1,
                  "P94N_WIDTH_PRESERVES_HEIGHT")
            check(abs(negative.verticalSpan-sourceShape.verticalSpan) < 0.5
                  && abs(positive.verticalSpan-sourceShape.verticalSpan) < 0.5,
                  "P94N_WIDTH_PRESERVES_VERTICAL_MATERIAL")
            check(neutral == sourceShape, "P94N_NEUTRAL_MEASUREMENT_EXACT")
            check(outputs[1] != outputs[2] && outputs[1] != outputs[3] && outputs[1] != outputs[4],
                  "P94N_FIELDS_REMAIN_DISTINCT")
            try at(.receipt) { try emit(measured) }
        } catch let stage as Stage {
            fail(stage.rawValue)
        } catch {
            // Never interpolate a thrown object into XCTest output.
            fail("P94N_STAGE_METRIC")
        }
    }

    // Only fixed row IDs from the local manifest and a literal orientation
    // enter assertion diagnostics. Values, image objects and errors never do.
    private func check(_ condition: Bool, _ marker: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(condition, marker + " row=" + diagnosticRow + " orientation=up", file: file, line: line)
    }
    private func fail(_ marker: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTFail(marker + " row=" + diagnosticRow + " orientation=up", file: file, line: line)
    }

    private func render(_ row: (String, BeautyParameters), image: CIImage, source: [UInt8]) throws -> [UInt8] {
        let active = row.0 != "geometryBaseline_noop"
        var first: [UInt8]?
        var firstResult: BeautyResult<CIImage>?
        for _ in 0..<2 {
            let provider = SDKTestingFaceDetectionProvider([.phase94MouthPortrait])
            let engine = try at(.detect) {
                try BeautyEngine(configuration: BeautyConfiguration(renderBackend: .cpu), faceDetectionProvider: provider)
            }
            let result = try at(.result) {
                try engine.processResult(image: image, metadata: MouthRepairFixture.metadata(), parameters: row.1)
            }
            check(provider.invocationCount == (active ? 1 : 0), "P94N_STAGE_DETECT")
            checkMetadata(result, active: active)
            let bytes = try at(.extract) { try extract(result.output, active: active) }
            returnedImageCount += 1
            let legacyProvider = SDKTestingFaceDetectionProvider([.phase94MouthPortrait])
            let legacyEngine = try at(.detect) {
                try BeautyEngine(configuration: BeautyConfiguration(renderBackend: .cpu), faceDetectionProvider: legacyProvider)
            }
            let legacy = try at(.legacy) {
                try legacyEngine.process(image: image, orientation: .up, parameters: row.1)
            }
            check(legacyProvider.invocationCount == (active ? 1 : 0), "P94N_STAGE_DETECT")
            let legacyBytes = try at(.extract) { try extract(legacy, active: active) }
            returnedImageCount += 1
            check(sameColor(result.output, legacy), "P94N_META_COLOR")
            check(bytes == legacyBytes && sha(bytes) == sha(legacyBytes), "P94N_META_REPEAT")
            if let previous = first {
                check(previous == bytes && sha(previous) == sha(bytes), "P94N_META_REPEAT")
            } else {
                first = bytes
            }
            if let previous = firstResult {
                check(sameColor(previous.output, result.output), "P94N_META_COLOR")
                check(previous.metrics == result.metrics && previous.warnings == result.warnings,
                              "P94N_META_REPEAT")
                check(previous.detectionSummary?.availability == result.detectionSummary?.availability
                              && previous.detectionSummary?.reasons == result.detectionSummary?.reasons,
                              "P94N_META_REPEAT")
            } else {
                firstResult = result
            }
            if !active {
                check(bytes == source && legacyBytes == source, "P94N_META_REPEAT")
            }
        }
        guard let first else { throw Stage.result }
        return first
    }

    private func checkMetadata(_ result: BeautyResult<CIImage>, active: Bool) {
        check(result.detectionSummary?.reasons == [], "P94N_META_REASONS")
        check(result.detectionSummary?.availability == (active ? .usable : .notRun), "P94N_META_REASONS")
        check(result.metrics.values.allSatisfy { $0.isFinite }, "P94N_META_REASONS")
        if active {
            check(result.detectionSummary?.faceCount == 1 && result.detectionSummary?.usedFaceCount == 1,
                          "P94N_META_REASONS")
        }
        let text = (result.warnings.map { $0.code + " " + $0.message } + Array(result.metrics.keys))
            .joined(separator: " ").lowercased()
        let forbidden = ["landmark", "coordinate", "controlpoint", "control point", "simd", "mask", "raw",
                         "pixel", "image bytes", "transcript", "path", "/private/", "file://"]
        check(forbidden.allSatisfy { !text.contains($0) }, "P94N_META_REASONS")
    }

    private func sameColor(_ lhs: CIImage, _ rhs: CIImage) -> Bool {
        guard let left = lhs.colorSpace, let right = rhs.colorSpace else { return false }
        return CFEqual(left, right)
    }

    private func extract(_ image: CIImage, active: Bool) throws -> [UInt8] {
        check(image.extent == extent, "P94N_META_EXTENT")
        guard let sRGB = CGColorSpace(name: CGColorSpace.sRGB) else { throw Stage.extract }
        // All active rows emit raw geometry; neutral requires named sRGB.
        if let actual = image.colorSpace {
            let expected = active ? CGColorSpaceCreateDeviceRGB() : sRGB
            check(actual.model == expected.model && actual.name == expected.name,
                          "P94N_META_COLOR")
            check(actual.numberOfComponents == expected.numberOfComponents && CFEqual(actual, expected),
                          "P94N_META_COLOR")
        } else {
            fail("P94N_META_COLOR")
        }
        var bytes = [UInt8](repeating: 0, count: 640 * 800 * 4)
        let context = CIContext(options: [.workingColorSpace: sRGB, .outputColorSpace: sRGB])
        bytes.withUnsafeMutableBytes { buffer in
            context.render(image, toBitmap: buffer.baseAddress!, rowBytes: 640 * 4,
                           bounds: extent, format: .RGBA8, colorSpace: sRGB)
        }
        var opaque = true
        for i in stride(from: 3, to: bytes.count, by: 4) {
            if bytes[i] != 255 { opaque = false; break }
        }
        check(opaque, "P94N_META_ALPHA")
        return bytes
    }

    private struct PixelShape: Equatable {
        let width: Int, height: Int
        let horizontalSpan: Double, verticalSpan: Double
        let centerX: Double, centerY: Double
    }

    private func shape(_ bytes: [UInt8]) throws -> PixelShape {
        guard bytes.count == 640*800*4 else { throw Stage.metric }
        // The recipe's dark mouth is isolated from eyes and nose by this
        // source-selected window. The larger window leaves room for both
        // signed size endpoints without selecting a window from output.
        var minimumX = 640, maximumX = -1, minimumY = 800, maximumY = -1
        var weight = 0.0, momentX = 0.0, momentY = 0.0
        var leftWeight = 0.0, rightWeight = 0.0, leftMoment = 0.0, rightMoment = 0.0
        var upperWeight = 0.0, lowerWeight = 0.0, upperMoment = 0.0, lowerMoment = 0.0
        for y in 460..<660 { for x in 128..<512 {
            let offset = (y*640+x)*4
            let value = Double(Int(bytes[offset])+Int(bytes[offset+1])+Int(bytes[offset+2]))/3
            let w = max(0, 170-value)
            guard w > 0 else { continue }
            let px = Double(x)+0.5, py = Double(y)+0.5
            minimumX = min(minimumX, x); maximumX = max(maximumX, x)
            minimumY = min(minimumY, y); maximumY = max(maximumY, y)
            weight += w; momentX += w*px; momentY += w*py
            // Two source-selected cross sections distinguish geometry from
            // a y-dependent change in the number of horizontal tissue pixels.
            // A pure width warp must retain the central vertical landmarks.
            if (544..<576).contains(y) {
                // Gray 80/81 is the source's outer lip edge. Fixed corner
                // windows exclude the independently authored gray 32/33
                // opening and gray 144/145 lip fill, whose relative areas can
                // change even when every corner material point moves inward.
                let cornerWeight = max(0, 110-value)
                if (170..<255).contains(x) { leftWeight += cornerWeight; leftMoment += cornerWeight*px }
                else if (385..<470).contains(x) { rightWeight += cornerWeight; rightMoment += cornerWeight*px }
            }
            if (319..<321).contains(x) {
                if py < 560 { upperWeight += w; upperMoment += w*py }
                else { lowerWeight += w; lowerMoment += w*py }
            }
        } }
        guard maximumX >= minimumX, maximumY >= minimumY, weight > 0,
              leftWeight > 0, rightWeight > 0, upperWeight > 0, lowerWeight > 0 else { throw Stage.metric }
        return PixelShape(width: maximumX-minimumX+1, height: maximumY-minimumY+1,
            horizontalSpan: rightMoment/rightWeight-leftMoment/leftWeight,
            verticalSpan: lowerMoment/lowerWeight-upperMoment/upperWeight,
            centerX: momentX/weight, centerY: momentY/weight)
    }

    private func checkProtected(_ source: [UInt8], _ output: [UInt8], isCoarseSize: Bool) {
        var changes = 0
        for y in 0..<800 { for x in 0..<640 {
            // This fixed-observation fixture exercises coarse compatibility,
            // not the new observed continuous-mouth route. Width's compact
            // source corner support leaves the full recipe nose/eyes fixed.
            // The preexisting coarse size support reaches below the nose and
            // toward the lower face: from the source's y508/612 extrema, the
            // declared cap and radius bound its support to roughly y402...718.
            // Select fixed upper-nose/eye and distant windows independently of
            // output. The observed-map tests retain complete nose protection.
            let upperBoundary = isCoarseSize ? 390 : 448
            let lowerBoundary = isCoarseSize ? 730 : 700
            guard y < upperBoundary || y > lowerBoundary || x < 100 || x > 540 else { continue }
            let offset = (y*640+x)*4
            if source[offset..<offset+4] != output[offset..<offset+4] { changes += 1 }
        } }
        check(changes == 0, "P94N_PROTECTED_SOURCE_PIXELS")
    }

    private func sha(_ bytes: [UInt8]) -> String {
        SHA256.hash(data: Data(bytes)).map { String(format: "%02x", $0) }.joined()
    }
    private func at<T>(_ stage: Stage, _ action: () throws -> T) throws -> T {
        do { return try action() }
        catch let known as Stage { throw known }
        catch { throw stage }
    }
    private func emit(_ measured: [PixelShape]) throws {
        guard measured.count == rows.count else { throw Stage.receipt }
        let records: [[String: Any]] = zip(rows, measured).map { row, shape in
            ["case": row.0, "widthPx": shape.width, "heightPx": shape.height,
             "horizontalMaterialSpanPx": shape.horizontalSpan, "verticalMaterialSpanPx": shape.verticalSpan,
             "protectionScope": row.1.mouthSize != 0 ? "coarse-size-fixed-upper-nose-eyes-distant-windows"
                : "complete-recipe-nose-eyes-distant-windows"]
        }
        let record: [String: Any] = ["schema": 1, "measurement": "source-defined-synthetic-mouth-material",
                                     "returnedImageCount": returnedImageCount, "records": records]
        let data = try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys])
        guard let text = String(data: data, encoding: .utf8) else { throw Stage.receipt }
        print("MOUTH_NEGATIVE_WRAPPER_AGGREGATE " + text)
    }
}
