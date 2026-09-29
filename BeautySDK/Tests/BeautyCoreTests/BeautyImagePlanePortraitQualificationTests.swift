import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

/// Portrait-shaped generated pixels complement the isolated marker and provider
/// oracles. They qualify only the documented two-dimensional image-plane scope.
final class BeautyImagePlanePortraitQualificationTests: XCTestCase {
    private let side = 128
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

    func testWholeFaceTranslationsRejectUnregisteredSmallPortraits() throws {
        // This 128-pixel silhouette does not match the injected face bounds.
        // The registered 512-pixel positives live in the semantic suite.
        for deepSkin in [false, true] {
            let source = makePortrait(markers: [], deepSkin: deepSkin)
            let original = rgba(source)
            let before = [
                ("left eye", visibleFeature(original, region: (43..<59, 48..<60), kind: .dark)),
                ("right eye", visibleFeature(original, region: (72..<88, 48..<60), kind: .dark)),
                ("mouth", visibleFeature(original, region: (50..<78, 80..<90), kind: .lip)),
            ]
            XCTAssertGreaterThan(before[1].1.x - before[0].1.x, 20)
            XCTAssertGreaterThan(before[2].1.y - before[0].1.y, 25)
            let engine = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
            )
            let noFace = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
            )
            XCTAssertEqual(rgba(try engine.processResult(
                image: source, metadata: metadata, parameters: .init()
            ).output), original)
            for (name, parameters) in [
                ("y+", BeautyParameters(wholeFaceYPosition: 0.30)),
                ("y-", BeautyParameters(wholeFaceYPosition: -0.30)),
                ("x+", BeautyParameters(wholeFaceXPosition: 0.30)),
                ("x-", BeautyParameters(wholeFaceXPosition: -0.30)),
            ] {
                let result = try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                )
                let output = rgba(result.output)
                XCTAssertTrue(output == original, "\(name) deepSkin=\(deepSkin)")
                XCTAssertEqual(result.output.extent, source.extent)
                assertExterior(original, output)
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output), output)
                XCTAssertEqual(rgba(try noFace.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output), original)
            }
        }
    }

    func testWholeFaceTiltRotatesVisibleEyeLineOnGeneratedPortraits() throws {
        // Source admission is fixed before rendering: two separated dark eyes,
        // a red lip band, and a face silhouette on both skin variants. The
        // no-face observation and neutral request are the unchanged negatives.
        for deepSkin in [false, true] {
            let source = makePortrait(markers: [], deepSkin: deepSkin)
            let original = rgba(source)
            let leftEye = visibleFeature(original, region: (43..<59, 48..<60), kind: .dark)
            let rightEye = visibleFeature(original, region: (72..<88, 48..<60), kind: .dark)
            let mouth = visibleFeature(original, region: (50..<78, 80..<90), kind: .lip)
            XCTAssertGreaterThan(rightEye.x - leftEye.x, 20)
            XCTAssertLessThan(abs(rightEye.y - leftEye.y), 0.2)
            XCTAssertGreaterThan(mouth.y - leftEye.y, 25)

            let engine = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
            )
            let noFace = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
            )
            XCTAssertEqual(rgba(try engine.processResult(
                image: source, metadata: metadata, parameters: .init()
            ).output), original)
            for (parameters, sign) in [
                (BeautyParameters(wholeFaceTilt: 0.30), 1.0),
                (BeautyParameters(wholeFaceTilt: -0.30), -1.0),
            ] {
                let result = try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                )
                let output = rgba(result.output)
                let movedLeftEye = visibleFeature(output, region: (39..<63, 44..<64), kind: .dark)
                let movedRightEye = visibleFeature(output, region: (68..<92, 44..<64), kind: .dark)
                let sourceSlope = rightEye.y - leftEye.y
                let outputSlope = movedRightEye.y - movedLeftEye.y
                XCTAssertGreaterThan((outputSlope - sourceSlope) * sign, 0.8)
                XCTAssertEqual(result.output.extent, source.extent)
                assertExterior(original, output)
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output), output)
                XCTAssertEqual(rgba(try noFace.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output), original)
            }
        }
    }

    func testPositiveCrownControlRaisesVisibleHairTopOnGeneratedPortraits() throws {
        // A source hair cap reaches the upper side controls, ends ten pixels
        // above the eyes, and has a measurable outer edge and crown.
        for deepSkin in [false, true] {
            let source = makePortrait(markers: [], deepSkin: deepSkin, hairlineRow: 43)
            let original = rgba(source)
            let hairWidth = visibleHairWidth(original, y: 37)
            let crownTop = visibleCrownTop(original)
            XCTAssertGreaterThan(hairWidth, 30)
            XCTAssertLessThan(crownTop, 18)
            let engine = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
            )
            let noFace = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
            )
            XCTAssertEqual(rgba(try engine.processResult(
                image: source, metadata: metadata, parameters: .init()
            ).output), original)
            let parameters = BeautyParameters(cranialCrownHeight: 0.25)
            let result = try engine.processResult(
                image: source, metadata: metadata, parameters: parameters
            )
            let output = rgba(result.output)
            XCTAssertGreaterThan(crownTop - visibleCrownTop(output), 0.3)
            XCTAssertEqual(result.output.extent, source.extent)
            assertExterior(original, output)
            XCTAssertEqual(rgba(try engine.processResult(
                image: source, metadata: metadata, parameters: parameters
            ).output), output)
            XCTAssertEqual(rgba(try noFace.processResult(
                image: source, metadata: metadata, parameters: parameters
            ).output), original)
        }
    }

    func testMidfaceControlMovesVisibleNoseOnGeneratedPortraits() throws {
        // Forehead direction belongs to the source-qualified 512-pixel
        // hair/skin boundary oracle; this 128-pixel schematic retains the
        // distinct-eye and separate-nose midface direction check.
        for deepSkin in [false, true] {
            let source = makePortrait(markers: [], deepSkin: deepSkin, hairlineRow: 43)
            let original = rgba(source)
            let beforeEyes = visibleFeature(original, region: (43..<59, 48..<60), kind: .dark)
            let beforeNose = visibleFeature(original, region: (59..<70, 61..<79), kind: .dark)
            XCTAssertGreaterThan(beforeNose.y - beforeEyes.y, 12)
            let engine = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
            )
            let noFace = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
            )
            XCTAssertEqual(rgba(try engine.processResult(
                image: source, metadata: metadata, parameters: .init()
            ).output), original)
            for (name, parameters, sign) in [
                ("midface+", BeautyParameters(midfaceLength: 0.30), 1.0),
                ("midface-", BeautyParameters(midfaceLength: -0.30), -1.0),
            ] {
                let result = try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                )
                let output = rgba(result.output)
                let afterEyes = visibleFeature(output, region: (43..<59, 48..<60), kind: .dark)
                let afterNose = visibleFeature(output, region: (59..<70, 61..<79), kind: .dark).y
                XCTAssertGreaterThan((afterNose - beforeNose.y) * sign, 0.3,
                                     "\(name) deepSkin=\(deepSkin)")
                XCTAssertLessThan(abs(afterEyes.y - beforeEyes.y), 0.3,
                                  "\(name) eye protection deepSkin=\(deepSkin)")
                XCTAssertEqual(result.output.extent, source.extent)
                assertExterior(original, output)
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output), output)
                XCTAssertEqual(rgba(try noFace.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output), original)
            }
        }
    }

    private func visibleHairline(_ pixels: [UInt8]) -> Double {
        var previous = 1.0
        var total = 0.0
        var weightedY = 0.0
        for y in 34..<51 {
            let blue = Double(pixels[(y * side + 64) * 4 + 2])
            let hair = min(1, max(0, (45 - blue) / 13))
            let exiting = max(0, previous - hair)
            total += exiting
            weightedY += Double(y) * exiting
            previous = hair
        }
        XCTAssertGreaterThan(total, 0.5)
        return weightedY / max(total, 0.01)
    }

    private func visibleHairWidth(_ pixels: [UInt8], y: Int) -> Double {
        (25..<103).reduce(0.0) { width, x in
            let blue = Double(pixels[(y * side + x) * 4 + 2])
            return width + min(1, max(0, (45 - blue) / 13))
        }
    }

    private func visibleCrownTop(_ pixels: [UInt8]) -> Double {
        var previous = 0.0
        var total = 0.0
        var weightedY = 0.0
        for y in 5..<30 {
            let blue = Double(pixels[(y * side + 64) * 4 + 2])
            let hair = min(1, max(0, (45 - blue) / 13))
            let entering = max(0, hair - previous)
            total += entering
            weightedY += Double(y) * entering
            previous = hair
        }
        XCTAssertGreaterThan(total, 0.5)
        return weightedY / max(total, 0.01)
    }

    private enum FeatureKind { case dark, lip }

    private func visibleFeature(
        _ pixels: [UInt8], region: (Range<Int>, Range<Int>), kind: FeatureKind
    ) -> (x: Double, y: Double) {
        var count = 0.0
        var xSum = 0.0
        var ySum = 0.0
        for y in region.1 {
            for x in region.0 {
                let offset = (y * side + x) * 4
                let r = Int(pixels[offset])
                let g = Int(pixels[offset + 1])
                let b = Int(pixels[offset + 2])
                let selected: Bool
                switch kind {
                case .dark: selected = r < 70 && g < 65 && b < 65
                case .lip: selected = r - g > 25 && b > g - 5
                }
                if selected {
                    count += 1
                    xSum += Double(x)
                    ySum += Double(y)
                }
            }
        }
        XCTAssertGreaterThan(count, 4)
        return (xSum / max(count, 1), ySum / max(count, 1))
    }

    func testWholeFaceTiltOnGeneratedPortraits() throws {
        for deepSkin in [false, true] {
            try assertDirection(.init(wholeFaceTilt: 0.30),
                                marker: (64, 41), axis: .x, sign: 1,
                                minimum: 1, deepSkin: deepSkin)
            try assertDirection(.init(wholeFaceTilt: -0.30),
                                marker: (64, 41), axis: .x, sign: -1,
                                minimum: 1, deepSkin: deepSkin)
            try assertDirection(.init(wholeFaceTilt: 0.30),
                                marker: (48, 64), axis: .y, sign: -1,
                                minimum: 1, deepSkin: deepSkin)
            try assertDirection(.init(wholeFaceTilt: -0.30),
                                marker: (48, 64), axis: .y, sign: 1,
                                minimum: 1, deepSkin: deepSkin)
        }
    }

    func testVerticalProportionsOnGeneratedPortraits() throws {
        for deepSkin in [false, true] {
            for (value, marker, sign, minimum) in [
                // Forehead direction uses the registered 512-pixel
                // source-boundary oracle, not an isolated upper marker.
                (BeautyParameters(midfaceLength: 0.30), (64, 64), 1.0, 1.0),
                (BeautyParameters(midfaceLength: -0.30), (64, 64), -1.0, 1.0),
                // Philtrum direction and nose protection use the registered
                // 512-pixel nose/lip source in RemainingEffectSemanticCandidateTests.
                (BeautyParameters(lowerFaceLength: 0.30), (64, 93), 1.0, 0.0),
                (BeautyParameters(lowerFaceLength: -0.30), (64, 93), -1.0, 0.0),
                (BeautyParameters(faceShortening: 0.30), (64, 43), 1.0, 1.0),
                (BeautyParameters(faceShortening: 0.30), (64, 93), -1.0, 1.0),
            ] {
                try assertDirection(value, marker: marker, axis: .y,
                                    sign: sign, minimum: minimum,
                                    deepSkin: deepSkin)
            }
        }
    }

    func testSymmetryOnGeneratedPortraits() throws {
        for deepSkin in [false, true] {
            let engine = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
            )
            // Chin effects use the qualified source-silhouette oracle in the
            // 512-pixel suite; a lone chin marker cannot identify a bulge.
            let symmetrySource = makePortrait(markers: [], deepSkin: deepSkin)
            let original = rgba(symmetrySource)
            let result = try engine.processResult(
                image: symmetrySource, metadata: metadata,
                parameters: .init(wholeFaceSymmetry: 0.25)
            )
            let output = rgba(result.output)
            XCTAssertGreaterThan(changedPixels(original, output, x: 25..<103, y: 45..<100), 10)
            assertExterior(original, output)
            XCTAssertEqual(result.output.extent, symmetrySource.extent)
            XCTAssertEqual(rgba(try engine.processResult(
                image: symmetrySource, metadata: metadata,
                parameters: .init(wholeFaceSymmetry: 0.25)
            ).output), output)
            let noFace = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
            )
            XCTAssertEqual(rgba(try noFace.processResult(
                image: symmetrySource, metadata: metadata,
                parameters: .init(wholeFaceSymmetry: 0.25)
            ).output), original)
        }
    }

    func testObservedAsymmetryNarrowsPublicContourMarkerWidthDifference() throws {
        // These marker sites correspond to the two lower-contour observations
        // nearest the source-fixed symmetry band in the injected face.
        let axisX = 63.4
        for deepSkin in [false, true] {
            let source = makePortrait(markers: [
                (42, 67, 1), (82, 77, 2),
            ], deepSkin: deepSkin)
            let before = rgba(source)
            let engine = try BeautyEngine(
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
            )
            let after = rgba(try engine.processResult(
                image: source, metadata: metadata,
                parameters: .init(wholeFaceSymmetry: 0.25)
            ).output)
            let leftBefore = chromaticCentroidX(before, marker: (42, 67), channel: 1)
            let rightBefore = chromaticCentroidX(before, marker: (82, 77), channel: 2)
            let leftAfter = chromaticCentroidX(after, marker: (42, 67), channel: 1)
            let rightAfter = chromaticCentroidX(after, marker: (82, 77), channel: 2)
            let sourceImbalance = abs((axisX - leftBefore) - (rightBefore - axisX))
            let outputImbalance = abs((axisX - leftAfter) - (rightAfter - axisX))
            XCTAssertGreaterThan(sourceImbalance, 2)
            XCTAssertGreaterThan(leftAfter - leftBefore, 0.3)
            XCTAssertGreaterThan(rightAfter - rightBefore, 0.3)
            XCTAssertLessThan(outputImbalance, sourceImbalance - 0.3)
            assertExterior(before, after)
        }
    }

    private enum Axis { case x, y }

    private func assertDirection(
        _ parameters: BeautyParameters, marker: (Int, Int), axis: Axis,
        sign: Double, minimum: Double, deepSkin: Bool
    ) throws {
        let source = makePortrait(markers: [(marker.0, marker.1, 0)], deepSkin: deepSkin)
        let original = rgba(source)
        let engine = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
        )
        let noFace = try BeautyEngine(
            faceDetectionProvider: SDKTestingFaceDetectionProvider([.noFace])
        )
        let before = centroid(original, marker: marker)
        XCTAssertEqual(rgba(try engine.processResult(
            image: source, metadata: metadata, parameters: .init()
        ).output), original)
        let result = try engine.processResult(
            image: source, metadata: metadata, parameters: parameters
        )
        let output = rgba(result.output)
        let after = centroid(output, marker: marker)
        let displacement = axis == .x ? after.x - before.x : after.y - before.y
        XCTAssertGreaterThan(displacement * sign, minimum)
        XCTAssertEqual(result.output.extent, source.extent)
        assertExterior(original, output)
        XCTAssertEqual(rgba(try engine.processResult(
            image: source, metadata: metadata, parameters: parameters
        ).output), output)
        XCTAssertEqual(rgba(try noFace.processResult(
            image: source, metadata: metadata, parameters: parameters
        ).output), original)
    }

    private func makePortrait(
        markers: [(Int, Int, Int)], deepSkin: Bool, hairlineRow: Int = 35
    ) -> CIImage {
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let dx = Double(x - 64) / 37
                let dy = Double(y - 63) / 49
                let inside = dx * dx + dy * dy <= 1
                let eye = (52...55).contains(y) &&
                    ((47...53).contains(x) || (75...81).contains(x))
                let nose = (65...75).contains(y) && (62...66).contains(x)
                let mouth = (83...86).contains(y) && (53...75).contains(x)
                let texture = (x / 3 + y / 3).isMultiple(of: 2) ? 3 : -3
                let skin: (Int, Int, Int) = deepSkin
                    ? (90 + texture, 77 + texture, 68 + texture)
                    : (157 + texture, 132 + texture, 116 + texture)
                var rgb: (Int, Int, Int)
                if !inside { rgb = (30, 40, 50) }
                else if y < hairlineRow { rgb = (35, 33, 32) }
                else if eye || nose { rgb = (45, 40, 38) }
                else if mouth { rgb = (110, 70, 75) }
                else { rgb = skin }
                for (markerX, markerY, channel) in markers
                where abs(x - markerX) <= 2 && abs(y - markerY) <= 2 {
                    switch channel {
                    case 0: rgb = (240, 40, 50)
                    case 1: rgb = (40, 240, 50)
                    default: rgb = (40, 50, 240)
                    }
                }
                let offset = (y * side + x) * 4
                pixels[offset] = UInt8(rgb.0)
                pixels[offset + 1] = UInt8(rgb.1)
                pixels[offset + 2] = UInt8(rgb.2)
                pixels[offset + 3] = 255
            }
        }
        return CIImage(
            bitmapData: Data(pixels), bytesPerRow: side * 4,
            size: CGSize(width: side, height: side), format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
        )
    }

    private func rgba(_ image: CIImage) -> [UInt8] {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        CIContext(options: [.workingColorSpace: colorSpace, .outputColorSpace: colorSpace]).render(
            image, toBitmap: &pixels, rowBytes: side * 4,
            bounds: CGRect(x: 0, y: 0, width: side, height: side),
            format: .RGBA8, colorSpace: colorSpace
        )
        return pixels
    }

    private func centroid(_ pixels: [UInt8], marker: (Int, Int)) -> (x: Double, y: Double) {
        var total = 0.0
        var xTotal = 0.0
        var yTotal = 0.0
        for y in max(0, marker.1 - 14)..<min(side, marker.1 + 15) {
            for x in max(0, marker.0 - 14)..<min(side, marker.0 + 15) {
                let offset = (y * side + x) * 4
                let signal = Double(max(0, Int(pixels[offset]) -
                    max(Int(pixels[offset + 1]), Int(pixels[offset + 2])) - 80))
                xTotal += Double(x) * signal
                yTotal += Double(y) * signal
                total += signal
            }
        }
        return (xTotal / max(1, total), yTotal / max(1, total))
    }

    private func chromaticCentroidX(
        _ pixels: [UInt8], marker: (Int, Int), channel: Int
    ) -> Double {
        var total = 0.0
        var xTotal = 0.0
        for y in max(0, marker.1 - 12)..<min(side, marker.1 + 13) {
            for x in max(0, marker.0 - 12)..<min(side, marker.0 + 13) {
                let offset = (y * side + x) * 4
                let others = (0..<3).filter { $0 != channel }.map { Int(pixels[offset + $0]) }
                let signal = Double(max(0, Int(pixels[offset + channel]) - (others.max() ?? 0) - 80))
                total += signal
                xTotal += Double(x) * signal
            }
        }
        return xTotal / max(1, total)
    }

    private func changedPixels(
        _ before: [UInt8], _ after: [UInt8], x: Range<Int>, y: Range<Int>
    ) -> Int {
        y.reduce(0) { total, row in
            total + x.reduce(0) { count, column in
                let offset = (row * side + column) * 4
                return count + (before[offset..<(offset + 3)] !=
                    after[offset..<(offset + 3)] ? 1 : 0)
            }
        }
    }

    private func assertExterior(
        _ before: [UInt8], _ after: [UInt8],
        file: StaticString = #filePath, line: UInt = #line
    ) {
        for y in 0..<side {
            for x in 0..<side where x < 12 || x >= side - 12 || y < 12 || y >= side - 12 {
                let offset = (y * side + x) * 4
                XCTAssertEqual(Array(after[offset..<(offset + 4)]),
                               Array(before[offset..<(offset + 4)]), file: file, line: line)
            }
        }
        XCTAssertTrue(stride(from: 3, to: after.count, by: 4).allSatisfy {
            after[$0] == 255
        }, file: file, line: line)
    }
}
