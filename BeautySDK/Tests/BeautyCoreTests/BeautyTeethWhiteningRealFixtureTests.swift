import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautySDK

final class BeautyTeethWhiteningRealFixtureTests: XCTestCase {
    func testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds() throws {
        let environment = ProcessInfo.processInfo.environment
        guard environment["PHASE60_REQUIRE_LOCAL_EVIDENCE"] == "1" else {
            throw XCTSkip("phase60_private_evidence_opt_in")
        }
        guard let rawBundle = environment["PHASE59_TEETH_BUNDLE"] else {
            XCTFail("private_bundle_missing")
            return
        }

        let bundle = URL(fileURLWithPath: rawBundle, isDirectory: true).standardizedFileURL
        let fixtures = try loadFixtures(from: bundle)
        guard fixtures.count == 2,
              Set(fixtures.map(\.polarity)) == Set(["positive", "negative"])
        else {
            XCTFail("private_manifest_pair_invalid")
            return
        }

        for fixture in fixtures {
            let originalURL = try assetURL(named: "original", fixture: fixture, bundle: bundle)
            let maskURL = try assetURL(named: "mask", fixture: fixture, bundle: bundle)
            guard let originalImage = CIImage(contentsOf: originalURL),
                  let maskImage = CIImage(contentsOf: maskURL)
            else {
                XCTFail("private_asset_decode_failed")
                return
            }

            let metadata = BeautyInputMetadata(
                orientation: .up,
                isInputMirrored: false,
                isPreviewMirrored: false,
                source: .photo
            )
            let canonical = try BeautyStillImageCanonicalizer().canonicalize(
                image: originalImage,
                metadata: metadata,
                maximumPixelCount: BeautyConfiguration.default.maximumInputPixelCount
            )
            let result = try BeautyEngine().processResult(
                image: originalImage,
                metadata: metadata,
                parameters: BeautyParameters(teethWhitening: 1)
            )
            let output = try renderRGBA8(
                result.output,
                width: canonical.width,
                height: canonical.height
            )
            let mask = try renderRGBA8(
                maskImage,
                width: canonical.width,
                height: canonical.height
            )

            guard output.count == canonical.byteCount,
                  mask.count == canonical.byteCount
            else {
                XCTFail("private_dimensions_changed")
                return
            }
            let before = Array(canonical.rgba8Data)
            let after = Array(output)
            let maskBytes = Array(mask)
            let measurement = measure(
                before: before,
                after: after,
                reviewedMask: maskBytes,
                width: canonical.width,
                height: canonical.height
            )

            guard measurement.alphaChangedPixelCount == 0,
                  measurement.changedOutsideReviewedMask == 0,
                  (0.85...1.15).contains(measurement.textureEnergyRatio)
            else {
                XCTFail("private_common_bounds_failed")
                return
            }

            switch fixture.polarity {
            case "positive":
                guard measurement.changedInsideReviewedMask > 0,
                      measurement.meanYellowExcessAfter < measurement.meanYellowExcessBefore,
                      measurement.meanLuminanceDelta > 0,
                      measurement.meanLuminanceDelta <= 0.03,
                      measurement.maximumChannelDelta <= 48
                else {
                    XCTFail("private_positive_bounds_failed")
                    return
                }
            case "negative":
                guard measurement.meanAbsoluteRGBDelta <= 0.012,
                      abs(measurement.meanLuminanceDelta) <= 0.006
                else {
                    XCTFail("private_negative_bounds_failed")
                    return
                }
            default:
                XCTFail("private_polarity_invalid")
                return
            }
        }
    }

    private struct Manifest: Decodable {
        let schema_version: Int
        let fixtures: [Fixture]
    }

    private struct Fixture: Decodable {
        let fixture_id: String
        let feature: String
        let polarity: String
        let rights_status: String
        let assets: [String: String]
    }

    private struct Measurement {
        let changedInsideReviewedMask: Int
        let changedOutsideReviewedMask: Int
        let alphaChangedPixelCount: Int
        let maximumChannelDelta: Int
        let meanAbsoluteRGBDelta: Double
        let meanLuminanceDelta: Double
        let meanYellowExcessBefore: Double
        let meanYellowExcessAfter: Double
        let textureEnergyRatio: Double
    }

    private func loadFixtures(from bundle: URL) throws -> [Fixture] {
        let manifestURL = bundle.appendingPathComponent("manifest.json", isDirectory: false)
        let data = try Data(contentsOf: manifestURL)
        let manifest = try JSONDecoder().decode(Manifest.self, from: data)
        guard manifest.schema_version == 1,
              manifest.fixtures.count == 2,
              manifest.fixtures.allSatisfy({
                  $0.feature == "teeth_whitening"
                      && $0.rights_status == "approved_internal_evaluation"
                      && !$0.fixture_id.isEmpty
              })
        else {
            throw BeautyError.invalidInput
        }
        return manifest.fixtures
    }

    private func assetURL(named name: String, fixture: Fixture, bundle: URL) throws -> URL {
        guard let relative = fixture.assets[name],
              !relative.hasPrefix("/"),
              relative.split(separator: "/").allSatisfy({ $0 != ".." && !$0.isEmpty })
        else {
            throw BeautyError.invalidInput
        }
        let url = bundle.appendingPathComponent(relative, isDirectory: false).standardizedFileURL
        guard url.path.hasPrefix(bundle.path + "/") else {
            throw BeautyError.invalidInput
        }
        return url
    }

    private func renderRGBA8(_ image: CIImage, width: Int, height: Int) throws -> Data {
        guard width > 0,
              height > 0,
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        else {
            throw BeautyError.unsupportedPixelFormat
        }
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace,
        ])
        var data = Data(count: width * height * 4)
        data.withUnsafeMutableBytes { buffer in
            guard let baseAddress = buffer.baseAddress else { return }
            context.render(
                image,
                toBitmap: baseAddress,
                rowBytes: width * 4,
                bounds: CGRect(x: 0, y: 0, width: width, height: height),
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }
        return data
    }

    private func measure(
        before: [UInt8],
        after: [UInt8],
        reviewedMask: [UInt8],
        width: Int,
        height: Int
    ) -> Measurement {
        var changedInside = 0
        var changedOutside = 0
        var alphaChanged = 0
        var maximumChannelDelta = 0
        var rgbDeltaTotal = 0.0
        var luminanceDeltaTotal = 0.0
        var yellowBeforeTotal = 0.0
        var yellowAfterTotal = 0.0
        var reviewedPixelCount = 0
        var changedReviewedPixelCount = 0

        for index in 0..<(width * height) {
            let offset = index * 4
            let inside = max(
                reviewedMask[offset],
                max(reviewedMask[offset + 1], reviewedMask[offset + 2])
            ) > 2
            let rgbChanged = before[offset] != after[offset]
                || before[offset + 1] != after[offset + 1]
                || before[offset + 2] != after[offset + 2]
            if before[offset + 3] != after[offset + 3] {
                alphaChanged += 1
            }
            if rgbChanged {
                if inside { changedInside += 1 } else { changedOutside += 1 }
            }
            guard inside else { continue }
            reviewedPixelCount += 1
            let redDelta = abs(Int(after[offset]) - Int(before[offset]))
            let greenDelta = abs(Int(after[offset + 1]) - Int(before[offset + 1]))
            let blueDelta = abs(Int(after[offset + 2]) - Int(before[offset + 2]))
            maximumChannelDelta = max(maximumChannelDelta, max(redDelta, max(greenDelta, blueDelta)))
            rgbDeltaTotal += Double(redDelta + greenDelta + blueDelta) / (3 * 255)
            luminanceDeltaTotal += luminance(after, offset: offset) - luminance(before, offset: offset)
            if rgbChanged {
                changedReviewedPixelCount += 1
                yellowBeforeTotal += yellowExcess(before, offset: offset)
                yellowAfterTotal += yellowExcess(after, offset: offset)
            }
        }

        let reviewedDivisor = Double(max(1, reviewedPixelCount))
        let changedDivisor = Double(max(1, changedReviewedPixelCount))
        let beforeTexture = textureEnergy(before, mask: reviewedMask, width: width, height: height)
        let afterTexture = textureEnergy(after, mask: reviewedMask, width: width, height: height)
        return Measurement(
            changedInsideReviewedMask: changedInside,
            changedOutsideReviewedMask: changedOutside,
            alphaChangedPixelCount: alphaChanged,
            maximumChannelDelta: maximumChannelDelta,
            meanAbsoluteRGBDelta: rgbDeltaTotal / reviewedDivisor,
            meanLuminanceDelta: luminanceDeltaTotal / reviewedDivisor,
            meanYellowExcessBefore: yellowBeforeTotal / changedDivisor,
            meanYellowExcessAfter: yellowAfterTotal / changedDivisor,
            textureEnergyRatio: beforeTexture > 0 ? afterTexture / beforeTexture : 1
        )
    }

    private func luminance(_ bytes: [UInt8], offset: Int) -> Double {
        0.2126 * Double(bytes[offset]) / 255
            + 0.7152 * Double(bytes[offset + 1]) / 255
            + 0.0722 * Double(bytes[offset + 2]) / 255
    }

    private func yellowExcess(_ bytes: [UInt8], offset: Int) -> Double {
        max(
            0,
            (Double(bytes[offset]) + Double(bytes[offset + 1])) / (2 * 255)
                - Double(bytes[offset + 2]) / 255
        )
    }

    private func textureEnergy(
        _ bytes: [UInt8],
        mask: [UInt8],
        width: Int,
        height: Int
    ) -> Double {
        var total = 0.0
        var count = 0
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                let offset = index * 4
                guard max(mask[offset], max(mask[offset + 1], mask[offset + 2])) > 2 else {
                    continue
                }
                if x + 1 < width {
                    let peer = offset + 4
                    if max(mask[peer], max(mask[peer + 1], mask[peer + 2])) > 2 {
                        total += abs(luminance(bytes, offset: offset) - luminance(bytes, offset: peer))
                        count += 1
                    }
                }
                if y + 1 < height {
                    let peer = offset + width * 4
                    if max(mask[peer], max(mask[peer + 1], mask[peer + 2])) > 2 {
                        total += abs(luminance(bytes, offset: offset) - luminance(bytes, offset: peer))
                        count += 1
                    }
                }
            }
        }
        return count > 0 ? total / Double(count) : 0
    }
}
