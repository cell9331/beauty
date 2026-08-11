import CoreGraphics
import CoreImage
import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautySDK

final class BeautyScleraRednessRealFixtureTests: XCTestCase {
    func testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds() throws {
        let environment = ProcessInfo.processInfo.environment
        guard environment["PHASE63_REQUIRE_LOCAL_EVIDENCE"] == "1" else {
            throw XCTSkip("phase63_private_evidence_opt_in")
        }
        guard let rawBundle = environment["PHASE62_SCLERA_BUNDLE"] else {
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
            try BeautyReviewedMaskValidation.validate(
                maskImage,
                width: canonical.width,
                height: canonical.height
            )
            let outputImage = try BeautyEngine().processResult(
                image: originalImage,
                metadata: metadata,
                parameters: BeautyParameters(scleraRednessReduction: 1)
            ).output
            let output = try renderRGBA8(outputImage, width: canonical.width, height: canonical.height)
            let mask = try renderRGBA8(maskImage, width: canonical.width, height: canonical.height)
            let measurement = measure(
                before: Array(canonical.rgba8Data),
                after: Array(output),
                reviewedMask: Array(mask),
                width: canonical.width,
                height: canonical.height
            )
            guard measurement.alphaChangedPixelCount == 0 else {
                XCTFail("private_alpha_bound_failed")
                return
            }
            guard measurement.changedOutsideReviewedMask == 0 else {
                XCTFail(containmentFailureCode(
                    before: Array(canonical.rgba8Data),
                    after: Array(output),
                    reviewedMask: Array(mask),
                    width: canonical.width,
                    height: canonical.height
                ))
                return
            }
            guard (0.82...1.18).contains(measurement.textureEnergyRatio) else {
                XCTFail("private_texture_bound_failed")
                return
            }
            guard measurement.maximumChannelDelta <= 44 else {
                XCTFail("private_channel_bound_failed")
                return
            }
            if fixture.polarity == "positive" {
                let minimumVisibleCount = max(
                    100,
                    Int(Double(measurement.reviewedMaskPixelCount) * 0.08)
                )
                guard measurement.changedInsideReviewedMask >= minimumVisibleCount,
                      measurement.changedInsideLeftHalf >= 20,
                      measurement.changedInsideRightHalf >= 20,
                      measurement.maximumChannelDelta >= 20,
                      measurement.meanRedExcessAfter
                        <= measurement.meanRedExcessBefore * 0.80,
                      abs(measurement.meanLuminanceDelta) <= 0.018
                else {
                    XCTFail("private_positive_bounds_failed")
                    return
                }
            } else {
                guard measurement.changedInsideReviewedMask == 0,
                      measurement.meanAbsoluteRGBDelta == 0,
                      abs(measurement.meanLuminanceDelta) <= 0.006
                else {
                    XCTFail("private_negative_bounds_failed")
                    return
                }
            }
        }
    }

    private struct Manifest: Decodable { let schema_version: Int; let fixtures: [Fixture] }
    private struct Fixture: Decodable {
        let fixture_id: String
        let feature: String
        let polarity: String
        let rights_status: String
        let assets: [String: String]
    }
    private struct Measurement {
        let reviewedMaskPixelCount: Int
        let changedInsideReviewedMask: Int
        let changedInsideLeftHalf: Int
        let changedInsideRightHalf: Int
        let changedOutsideReviewedMask: Int
        let alphaChangedPixelCount: Int
        let maximumChannelDelta: Int
        let meanAbsoluteRGBDelta: Double
        let meanLuminanceDelta: Double
        let meanRedExcessBefore: Double
        let meanRedExcessAfter: Double
        let textureEnergyRatio: Double
    }

    private func loadFixtures(from bundle: URL) throws -> [Fixture] {
        let data = try Data(contentsOf: bundle.appendingPathComponent("manifest.json"))
        let manifest = try JSONDecoder().decode(Manifest.self, from: data)
        guard manifest.schema_version == 1,
              manifest.fixtures.count == 2,
              manifest.fixtures.allSatisfy({
                  $0.feature == "sclera_redness"
                      && $0.rights_status == "approved_internal_evaluation"
                      && !$0.fixture_id.isEmpty
              })
        else { throw BeautyError.invalidInput }
        return manifest.fixtures
    }

    private func assetURL(named name: String, fixture: Fixture, bundle: URL) throws -> URL {
        guard let relative = fixture.assets[name],
              !relative.hasPrefix("/"),
              relative.split(separator: "/").allSatisfy({ $0 != ".." && !$0.isEmpty })
        else { throw BeautyError.invalidInput }
        let url = bundle.appendingPathComponent(relative).standardizedFileURL
        guard url.path.hasPrefix(bundle.path + "/") else { throw BeautyError.invalidInput }
        return url
    }

    private func renderRGBA8(_ image: CIImage, width: Int, height: Int) throws -> Data {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.unsupportedPixelFormat
        }
        let context = CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
        var data = Data(count: width * height * 4)
        data.withUnsafeMutableBytes { buffer in
            guard let base = buffer.baseAddress else { return }
            context.render(
                image,
                toBitmap: base,
                rowBytes: width * 4,
                bounds: CGRect(x: 0, y: 0, width: width, height: height),
                format: .RGBA8,
                colorSpace: colorSpace
            )
        }
        return data
    }

    private func measure(before: [UInt8], after: [UInt8], reviewedMask: [UInt8], width: Int, height: Int) -> Measurement {
        var changedInside = 0
        var changedInsideLeft = 0
        var changedInsideRight = 0
        var changedOutside = 0
        var alphaChanged = 0
        var maxChannel = 0
        var rgbTotal = 0.0
        var lumaTotal = 0.0
        var redBefore = 0.0
        var redAfter = 0.0
        var maskCount = 0
        var changedMaskCount = 0
        for index in 0..<(width * height) {
            let offset = index * 4
            let inside = max(reviewedMask[offset], max(reviewedMask[offset + 1], reviewedMask[offset + 2])) > 2
            let changed = before[offset..<(offset + 3)] != after[offset..<(offset + 3)]
            if before[offset + 3] != after[offset + 3] { alphaChanged += 1 }
            if changed {
                if inside {
                    changedInside += 1
                    if index % width < width / 2 {
                        changedInsideLeft += 1
                    } else {
                        changedInsideRight += 1
                    }
                } else {
                    changedOutside += 1
                }
            }
            guard inside else { continue }
            maskCount += 1
            let deltas = (0..<3).map { abs(Int(after[offset + $0]) - Int(before[offset + $0])) }
            maxChannel = max(maxChannel, deltas.max() ?? 0)
            rgbTotal += Double(deltas.reduce(0, +)) / (3 * 255)
            lumaTotal += luminance(after, offset) - luminance(before, offset)
            if changed {
                changedMaskCount += 1
                redBefore += redExcess(before, offset)
                redAfter += redExcess(after, offset)
            }
        }
        let maskDivisor = Double(max(1, maskCount))
        let changedDivisor = Double(max(1, changedMaskCount))
        let beforeTexture = textureEnergy(before, reviewedMask, width, height)
        let afterTexture = textureEnergy(after, reviewedMask, width, height)
        return Measurement(
            reviewedMaskPixelCount: maskCount,
            changedInsideReviewedMask: changedInside,
            changedInsideLeftHalf: changedInsideLeft,
            changedInsideRightHalf: changedInsideRight,
            changedOutsideReviewedMask: changedOutside,
            alphaChangedPixelCount: alphaChanged,
            maximumChannelDelta: maxChannel,
            meanAbsoluteRGBDelta: rgbTotal / maskDivisor,
            meanLuminanceDelta: lumaTotal / maskDivisor,
            meanRedExcessBefore: redBefore / changedDivisor,
            meanRedExcessAfter: redAfter / changedDivisor,
            textureEnergyRatio: beforeTexture > 0 ? afterTexture / beforeTexture : 1
        )
    }

    private func luminance(_ bytes: [UInt8], _ offset: Int) -> Double {
        0.2126 * Double(bytes[offset]) / 255
            + 0.7152 * Double(bytes[offset + 1]) / 255
            + 0.0722 * Double(bytes[offset + 2]) / 255
    }

    private func redExcess(_ bytes: [UInt8], _ offset: Int) -> Double {
        let red = Double(bytes[offset]) / 255
        let green = Double(bytes[offset + 1]) / 255
        let blue = Double(bytes[offset + 2]) / 255
        return max(0, red - 0.83 * green - 0.17 * blue)
    }

    private func containmentFailureCode(
        before: [UInt8],
        after: [UInt8],
        reviewedMask: [UInt8],
        width: Int,
        height: Int
    ) -> String {
        let inside: (Int) -> Bool = { index in
            let offset = index * 4
            return max(reviewedMask[offset], max(reviewedMask[offset + 1], reviewedMask[offset + 2])) > 2
        }
        let changedOutside = (0..<(width * height)).filter { index in
            let offset = index * 4
            return !inside(index) && before[offset..<(offset + 3)] != after[offset..<(offset + 3)]
        }
        for radius in [1, 2, 4] {
            let allNearReviewedMask = changedOutside.allSatisfy { index in
                let x = index % width
                let y = index / width
                for deltaY in -radius...radius {
                    for deltaX in -radius...radius {
                        let peerX = x + deltaX
                        let peerY = y + deltaY
                        if peerX >= 0, peerY >= 0, peerX < width, peerY < height,
                           inside(peerY * width + peerX)
                        {
                            return true
                        }
                    }
                }
                return false
            }
            if allNearReviewedMask {
                return "private_containment_edge_\(radius)_failed"
            }
        }
        return "private_containment_broad_failed"
    }

    private func textureEnergy(_ bytes: [UInt8], _ mask: [UInt8], _ width: Int, _ height: Int) -> Double {
        var total = 0.0
        var count = 0
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                guard max(mask[offset], max(mask[offset + 1], mask[offset + 2])) > 2 else { continue }
                for peer in [x + 1 < width ? offset + 4 : -1, y + 1 < height ? offset + width * 4 : -1] where peer >= 0 {
                    if max(mask[peer], max(mask[peer + 1], mask[peer + 2])) > 2 {
                        total += abs(luminance(bytes, offset) - luminance(bytes, peer))
                        count += 1
                    }
                }
            }
        }
        return count > 0 ? total / Double(count) : 0
    }
}
