import CoreGraphics
import CoreImage
import XCTest
@_spi(Testing) import BeautySDK

/// A finite semantic-identifiability spike, not automatic-object acceptance.
/// Oracle material labels are deliberately absent from the automatic request.
/// Candidate code is test-only; production rendering is never changed here.
final class BeautySkinTextureSemanticFeasibilityTests: XCTestCase {
    private let side = 64
    private let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)
    private let left = Region(x: 22..<26, y: 35..<39)
    private let right = Region(x: 38..<42, y: 35..<39)
    private let tones: [(Int, Int, Int)] = [(170, 125, 110), (110, 76, 61)]

    private enum Material: Equatable { case skin, printedObject }
    private struct Scene {
        let pixels: [UInt8]
        let rightMaterial: Material
    }
    private struct Region {
        let x: Range<Int>
        let y: Range<Int>
    }

    func testDifferentMaterialScenesHaveIdenticalAutomaticInputsAndOutputs() throws {
        for tone in tones {
            let skin = scene(tone: tone, rightMaterial: .skin)
            let object = scene(tone: tone, rightMaterial: .printedObject)
            XCTAssertNotEqual(skin.rightMaterial, object.rightMaterial)
            // Equal full input, not merely equal local RGB or landmarks.
            XCTAssertEqual(skin.pixels, object.pixels)
            for smoothing in [true, false] {
                let first = try render(skin.pixels, smoothing: smoothing)
                let second = try render(object.pixels, smoothing: smoothing)
                XCTAssertEqual(first, second)
                // For this same region, source-exact preservation and a
                // nontrivial change cannot both hold for the same output.
                let differs = changed(skin.pixels, first, right) > 0
                let preserves = changed(object.pixels, second, right) == 0
                XCTAssertNotEqual(differs, preserves)
                XCTAssertFalse(differs && preserves)
            }
        }
    }

    func testUnmaskedBaselineMeetsTextureDirectionButFailsObjectProtection() throws {
        for tone in tones {
            let source = scene(tone: tone, rightMaterial: .printedObject).pixels
            XCTAssertEqual(try render(source, smoothing: true, neutral: true), source)
            for smoothing in [true, false] {
                let output = try render(source, smoothing: smoothing)
                assertDirection(source, output, left, smoothing: smoothing)
                assertDirection(source, output, right, smoothing: smoothing)
                XCTAssertGreaterThan(changed(source, output, right), 0)
                assertProtection(source, output)
                XCTAssertEqual(output, try render(source, smoothing: smoothing))
            }
        }
        print("texture_semantic_baseline variants=4 skin_direction=pass object_protection=fail joint=reject")
    }

    func testRejectedPeriodicTextureCandidatePreservesObjectButStopsSkinEffect() throws {
        for tone in tones {
            let source = scene(tone: tone, rightMaterial: .printedObject).pixels
            // Source-only candidate: no material label or oracle ROI enters it.
            let mask = try periodicTextureExclusion(source)
            for smoothing in [true, false] {
                let output = try render(source, smoothing: smoothing, mask: mask)
                XCTAssertEqual(changed(source, output, right), 0)
                XCTAssertEqual(changed(source, output, left), 0)
                XCTAssertEqual(variation(output, left), variation(source, left))
                // Explicitly record failure of the frozen effect predicate;
                // this green regression is evidence of candidate rejection.
                XCTAssertFalse(meetsDirection(source, output, left, smoothing: smoothing))
                assertProtection(source, output)
                XCTAssertEqual(output, try render(source, smoothing: smoothing, mask: mask))
            }
        }
        print("texture_semantic_candidate attempts=1 variants=4 skin_direction=fail object_protection=pass joint=reject")
    }

    func testExplicitMaskSuppliesMissingInformationAndPassesJointContract() throws {
        for tone in tones {
            let source = scene(tone: tone, rightMaterial: .printedObject).pixels
            var exclusions = [UInt8](repeating: 0, count: side * side)
            // Only this control receives the owner's independent information.
            for y in 34..<44 {
                for x in 35..<44 { exclusions[y * side + x] = 255 }
            }
            let mask = try BeautyTextureExclusionMask(
                width: side, height: side, bytes: exclusions
            )
            for smoothing in [true, false] {
                let baseline = try render(source, smoothing: smoothing)
                let output = try render(source, smoothing: smoothing, mask: mask)
                assertDirection(source, output, left, smoothing: smoothing)
                XCTAssertEqual(changed(source, output, right), 0)
                for index in exclusions.indices {
                    let offset = index * 4
                    let reference = exclusions[index] == 255 ? source : baseline
                    for channel in 0..<4 {
                        XCTAssertEqual(output[offset + channel], reference[offset + channel])
                    }
                }
                assertProtection(source, output)
                XCTAssertEqual(output, try render(source, smoothing: smoothing, mask: mask))
            }
        }
        print("texture_semantic_explicit_mask variants=4 skin_direction=pass object_protection=pass joint=pass")
    }

    private func scene(tone: (Int, Int, Int), rightMaterial: Material) -> Scene {
        // Two physical interpretations: actual skin texture or a printed,
        // skin-colored covering reproducing the same visible pixels. Material
        // is ground truth for the oracle, never an image-generation branch.
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let dx = Double(x - 32) / 20
                let dy = Double(y - 33) / 24
                let onCheek = (34..<44).contains(y) &&
                    ((20..<29).contains(x) || (35..<44).contains(x))
                let detail = (x / 2 + y / 2).isMultiple(of: 2) ? 10 : -10
                let rgb: (Int, Int, Int)
                if dx * dx + dy * dy > 1 { rgb = (35, 45, 65) }
                else if y < 20 { rgb = (32, 28, 26) }
                else if ((23..<28).contains(x) || (37..<42).contains(x)) &&
                    (25..<29).contains(y) { rgb = (50, 40, 38) }
                else if (27..<38).contains(x) && (48..<51).contains(y) {
                    rgb = (125, 63, 70)
                } else {
                    let value = onCheek ? detail : 0
                    rgb = (tone.0 + value, tone.1 + value, tone.2 + value)
                }
                let offset = (y * side + x) * 4
                pixels[offset] = UInt8(rgb.0)
                pixels[offset + 1] = UInt8(rgb.1)
                pixels[offset + 2] = UInt8(rgb.2)
                pixels[offset + 3] = 255
            }
        }
        return Scene(pixels: pixels, rightMaterial: rightMaterial)
    }

    private func periodicTextureExclusion(_ source: [UInt8]) throws -> BeautyTextureExclusionMask {
        var seeds: [(Int, Int)] = []
        for y in 4..<(side - 4) {
            for x in 4..<(side - 4) {
                let offset = (y * side + x) * 4
                let periodOffsets = [(-4, 0), (4, 0), (0, -4), (0, 4)]
                let oppositeOffsets = [(-2, 0), (2, 0), (0, -2), (0, 2)]
                guard periodOffsets.allSatisfy({ dx, dy in
                    let other = ((y + dy) * side + x + dx) * 4
                    return (0..<4).allSatisfy { source[offset + $0] == source[other + $0] }
                }), oppositeOffsets.allSatisfy({ dx, dy in
                    let other = ((y + dy) * side + x + dx) * 4
                    let delta = Int(source[other]) - Int(source[offset])
                    return abs(delta) >= 8 && (1..<3).allSatisfy {
                        Int(source[other + $0]) - Int(source[offset + $0]) == delta
                    }
                }) else { continue }
                seeds.append((x, y))
            }
        }
        var exclusions = [UInt8](repeating: 0, count: side * side)
        for (x, y) in seeds {
            for row in max(0, y - 4)...min(side - 1, y + 4) {
                for column in max(0, x - 4)...min(side - 1, x + 4) {
                    exclusions[row * side + column] = 255
                }
            }
        }
        return try BeautyTextureExclusionMask(width: side, height: side, bytes: exclusions)
    }

    private func render(
        _ source: [UInt8], smoothing: Bool, neutral: Bool = false,
        mask: BeautyTextureExclusionMask? = nil
    ) throws -> [UInt8] {
        let image = CIImage(
            bitmapData: Data(source), bytesPerRow: side * 4,
            size: CGSize(width: side, height: side), format: .RGBA8, colorSpace: colorSpace
        )
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.textureFace])
        )
        let parameters = neutral ? BeautyParameters() :
            (smoothing ? BeautyParameters(skinSmoothing: 1) : BeautyParameters(skinSharpen: 1))
        let result = try engine.processResult(
            image: image, metadata: metadata, parameters: parameters, textureExclusionMask: mask
        )
        XCTAssertEqual(result.output.extent, image.extent)
        XCTAssertEqual(result.output.colorSpace?.name, colorSpace.name)
        var output = [UInt8](repeating: 0, count: source.count)
        CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace])
            .render(result.output, toBitmap: &output, rowBytes: side * 4,
                    bounds: image.extent, format: .RGBA8, colorSpace: colorSpace)
        return output
    }

    private func changed(_ source: [UInt8], _ output: [UInt8], _ region: Region) -> Int {
        region.y.reduce(0) { total, y in
            total + region.x.reduce(0) { subtotal, x in
                let offset = (y * side + x) * 4
                return subtotal + ((0..<3).contains {
                    source[offset + $0] != output[offset + $0]
                } ? 1 : 0)
            }
        }
    }

    private func variation(_ pixels: [UInt8], _ region: Region) -> Double {
        var total = 0.0
        var count = 0
        func luminance(_ x: Int, _ y: Int) -> Double {
            let i = (y * side + x) * 4
            return Double(77 * Int(pixels[i]) + 150 * Int(pixels[i + 1]) +
                          29 * Int(pixels[i + 2])) / 256
        }
        for y in region.y {
            for x in region.x {
                if x + 1 < region.x.upperBound {
                    total += abs(luminance(x + 1, y) - luminance(x, y)); count += 1
                }
                if y + 1 < region.y.upperBound {
                    total += abs(luminance(x, y + 1) - luminance(x, y)); count += 1
                }
            }
        }
        return total / Double(count)
    }

    private func meetsDirection(
        _ source: [UInt8], _ output: [UInt8], _ region: Region, smoothing: Bool
    ) -> Bool {
        let before = variation(source, region)
        let after = variation(output, region)
        return smoothing ? after <= before * 0.80 : after >= before * 1.10
    }

    private func assertDirection(
        _ source: [UInt8], _ output: [UInt8], _ region: Region, smoothing: Bool,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertGreaterThan(variation(source, region), 0, file: file, line: line)
        XCTAssertTrue(meetsDirection(source, output, region, smoothing: smoothing),
                      "Frozen texture direction failed", file: file, line: line)
    }

    private func assertProtection(_ source: [UInt8], _ output: [UInt8]) {
        XCTAssertEqual(source.count, output.count)
        for index in stride(from: 0, to: source.count, by: 4) {
            XCTAssertEqual(source[index + 3], output[index + 3])
            for channel in 0..<3 {
                XCTAssertLessThanOrEqual(abs(Int(output[index + channel]) - Int(source[index + channel])), 16)
            }
        }
        for region in [Region(x: 0..<side, y: 0..<12),
                       Region(x: 23..<28, y: 25..<29),
                       Region(x: 37..<42, y: 25..<29),
                       Region(x: 27..<38, y: 48..<51)] {
            XCTAssertEqual(changed(source, output, region), 0)
        }
    }
}
