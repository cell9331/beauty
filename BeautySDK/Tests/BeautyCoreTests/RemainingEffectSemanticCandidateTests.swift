import CoreGraphics
import CoreImage
import Foundation
import XCTest
@_spi(Testing) import BeautySDK

/// Source-fixed portrait oracles for the admitted 2D shape controls.
/// Failed semantic candidates are recorded in the active plan rather than
/// turned green by relaxing their thresholds.
final class RemainingEffectSemanticCandidateTests: XCTestCase {
    private let side = 512
    private let metadata = BeautyInputMetadata(orientation: .up, source: .testFixture)

    private struct PortraitStyle {
        let deepSkin: Bool
        var halfWidth = 108.0
        var halfHeight = 160.0
        var hairline = 130
        var hairlineWave = 0
        var lowContrastHair = false
        var mouthTop = 332
        var noseBottom = 300
        var foreheadBand = false
        var chinBulge = false
        var chinBulgeRadiusY = 22.0
        var detachedCollar = false
        var internalChinFold = false
    }

    func testHeadSemanticCandidates() throws {
        // Before output: visible hair top, lateral hair at row 150, and a
        // lower chin edge. Freeze 1-pixel movement in each claimed direction.
        for deepSkin in [false, true] {
          for (halfWidth, halfHeight) in [(108.0, 160.0), (98.0, 168.0)] {
            let style = PortraitStyle(
                deepSkin: deepSkin, halfWidth: halfWidth,
                halfHeight: halfHeight, hairline: 170
            )
            let source = makePortrait(style)
            let before = rgba(source)
            let top = hairTop(before)
            let width = hairWidth(before, row: 150)
            let chin = chinBottom(before)
            XCTAssertLessThan(top, 105)
            XCTAssertGreaterThan(width, 100)
            XCTAssertGreaterThan(chin, 405)
            XCTAssertLessThanOrEqual(maxHairSilhouetteStep(before), 4)
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            let noFace = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.noFace]))
            XCTAssertEqual(rgba(try engine.processResult(
                image: source, metadata: metadata, parameters: .init()
            ).output), before)
            for (name, parameters, minimum) in [
                ("headSmall width", BeautyParameters(headSmall: 0.30), 1.0),
                ("headWrap width", BeautyParameters(headWrap: 0.25), 1.0),
                ("crown+", BeautyParameters(cranialCrownHeight: 0.25), 1.0),
                ("crown-", BeautyParameters(cranialCrownHeight: -0.25), 1.0),
            ] {
                let result = try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                )
                let after = rgba(result.output)
                let improvement: Double
                switch name {
                case "headSmall width": improvement = width - hairWidth(after, row: 150)
                case "headWrap width": improvement = hairWidth(after, row: 150) - width
                case "crown+": improvement = top - hairTop(after)
                default: improvement = hairTop(after) - top
                }
                XCTAssertGreaterThan(improvement, minimum,
                                     "\(name) deepSkin=\(deepSkin)")
                if name == "headSmall width" {
                    XCTAssertGreaterThan(hairTop(after) - top, 1.0)
                    XCTAssertGreaterThan(chin - chinBottom(after), 1.0)
                    XCTAssertLessThanOrEqual(abs(visibleEyeWidth(after) - visibleEyeWidth(before)), 2.0)
                    XCTAssertLessThanOrEqual(abs(visibleMouthWidth(after) - visibleMouthWidth(before)), 2.0)
                    assertRegion(before, after, x: 240..<273, y: 250..<310)
                }
                if name == "headWrap width" {
                    XCTAssertEqual(headWidth(after), headWidth(before), accuracy: 0.2)
                    let ratioChange = hairWidth(after, row: 150) / headWidth(after) -
                        width / headWidth(before)
                    XCTAssertGreaterThan(ratioChange, 0.004)
                }
                if name == "headWrap width" || name.hasPrefix("crown") {
                    assertRegion(before, after, x: 190..<322, y: 184..<345)
                }
                XCTAssertLessThanOrEqual(maxHairSilhouetteStep(after), 4)
                XCTAssertEqual(result.output.extent, source.extent)
                XCTAssertEqual(after, rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output))
                assertExterior(before, after)
                assertAlpha(before, after)
                XCTAssertEqual(rgba(try noFace.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output), before)
            }
          }
        }
    }

    func testHairlineMovesDetectedBoundaryAndLeavesHairlessNegativeExact() throws {
        // Fix the source boundary and eye/brow protection before rendering.
        // Both center and lateral forehead samples must move coherently.
        for deepSkin in [false, true] {
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            let noFace = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.noFace]))
            for row in [150, 170] {
                let source = makePortrait(PortraitStyle(
                    deepSkin: deepSkin, hairline: row
                ))
                let before = rgba(source)
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: .init()
                ).output), before)
                for x in [225, 256, 287] {
                    XCTAssertEqual(hairlineRow(before, x: x), row)
                }
                for (value, sign) in [(0.25, 1.0), (-0.25, -1.0)] {
                    let parameters = BeautyParameters(hairlineHeight: Float(value))
                    let result = try engine.processResult(
                        image: source, metadata: metadata, parameters: parameters
                    )
                    let after = rgba(result.output)
                    for x in [225, 256, 287] {
                        XCTAssertGreaterThan(
                            Double(hairlineRow(after, x: x) - row) * sign, 1.0,
                            "hairline row=\(row) x=\(x) deepSkin=\(deepSkin)"
                        )
                    }
                    assertRegion(before, after, x: 190..<322, y: 186..<345)
                    assertExterior(before, after)
                    assertAlpha(before, after)
                    XCTAssertEqual(result.output.extent, source.extent)
                    XCTAssertEqual(after, rgba(try engine.processResult(
                        image: source, metadata: metadata, parameters: parameters
                    ).output))
                    XCTAssertEqual(rgba(try noFace.processResult(
                        image: source, metadata: metadata, parameters: parameters
                    ).output), before)
                }
            }
            let wavyStyle = PortraitStyle(
                deepSkin: deepSkin, hairline: 160, hairlineWave: 5
            )
            let wavySource = makePortrait(wavyStyle)
            let wavyBefore = rgba(wavySource)
            let sourceRows = [225, 256, 287].map { x in
                hairlineRow(wavyBefore, x: x)
            }
            XCTAssertGreaterThan((sourceRows.max() ?? 0) - (sourceRows.min() ?? 0), 5)
            for (value, sign) in [(0.25, 1.0), (-0.25, -1.0)] {
                let parameters = BeautyParameters(hairlineHeight: Float(value))
                let result = try engine.processResult(
                    image: wavySource, metadata: metadata, parameters: parameters
                )
                let after = rgba(result.output)
                for (index, x) in [225, 256, 287].enumerated() {
                    XCTAssertGreaterThan(
                        Double(hairlineRow(after, x: x) - sourceRows[index]) * sign, 1.0
                    )
                }
                XCTAssertLessThanOrEqual(maxHairlineStep(after), 2)
                assertRegion(wavyBefore, after, x: 190..<322, y: 186..<345)
                assertExterior(wavyBefore, after)
                assertAlpha(wavyBefore, after)
                XCTAssertEqual(result.output.extent, wavySource.extent)
                XCTAssertEqual(after, rgba(try engine.processResult(
                    image: wavySource, metadata: metadata, parameters: parameters
                ).output))
            }
            for (value, sign) in [(0.30, -1.0), (-0.30, 1.0)] {
                let parameters = BeautyParameters(foreheadHeight: Float(value))
                let result = try engine.processResult(
                    image: wavySource, metadata: metadata, parameters: parameters
                )
                let after = rgba(result.output)
                for (index, x) in [225, 256, 287].enumerated() {
                    XCTAssertGreaterThan(
                        Double(hairlineRow(after, x: x) - sourceRows[index]) * sign, 1.0
                    )
                }
                XCTAssertLessThanOrEqual(maxHairlineStep(after), 2)
                XCTAssertEqual(regionChangedPixels(wavyBefore, after,
                    x: 190..<322, y: 186..<345), 0)
                assertExterior(wavyBefore, after)
                assertAlpha(wavyBefore, after)
                XCTAssertEqual(result.output.extent, wavySource.extent)
                XCTAssertTrue(after == rgba(try engine.processResult(
                    image: wavySource, metadata: metadata, parameters: parameters
                ).output))
            }
            XCTAssertTrue(rgba(try engine.processResult(
                image: wavySource, metadata: metadata,
                parameters: BeautyParameters(
                    foreheadHeight: 0.30, hairlineHeight: 0.25
                )
            ).output) == wavyBefore)
            let ambiguous = makePortrait(PortraitStyle(
                deepSkin: deepSkin, hairline: 160, lowContrastHair: true
            ))
            let ambiguousBytes = rgba(ambiguous)
            for value in [0.25, -0.25] {
                XCTAssertEqual(rgba(try engine.processResult(
                    image: ambiguous, metadata: metadata,
                    parameters: BeautyParameters(hairlineHeight: Float(value))
                ).output), ambiguousBytes)
            }
            let noHair = makePortrait(PortraitStyle(
                deepSkin: deepSkin, hairline: 0
            ))
            let noHairBytes = rgba(noHair)
            for value in [0.25, -0.25] {
                XCTAssertEqual(rgba(try engine.processResult(
                    image: noHair, metadata: metadata,
                    parameters: BeautyParameters(hairlineHeight: Float(value))
                ).output), noHairBytes)
            }
            let decorated = makePortrait(PortraitStyle(
                deepSkin: deepSkin, hairline: 0, foreheadBand: true
            ))
            let decoratedBytes = rgba(decorated)
            for value in [0.25, -0.25] {
                XCTAssertEqual(rgba(try engine.processResult(
                    image: decorated, metadata: metadata,
                    parameters: BeautyParameters(hairlineHeight: Float(value))
                ).output), decoratedBytes)
            }
            let closeToBrow = makePortrait(PortraitStyle(
                deepSkin: deepSkin, hairline: 180
            ))
            let closeBytes = rgba(closeToBrow)
            let observedBrows = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.phase92PairedObservedEyebrows]))
            for value in [0.25, -0.25] {
                XCTAssertEqual(rgba(try observedBrows.processResult(
                    image: closeToBrow, metadata: metadata,
                    parameters: BeautyParameters(hairlineHeight: Float(value))
                ).output), closeBytes)
            }
        }
    }

    func testHeadWrapUnsupportedHairNegativesRemainExact() throws {
        for deepSkin in [false, true] {
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            for style in [
                PortraitStyle(deepSkin: deepSkin, hairline: 0),
                PortraitStyle(deepSkin: deepSkin, hairline: 0, foreheadBand: true),
                PortraitStyle(deepSkin: deepSkin, hairline: 170, lowContrastHair: true),
            ] {
                let source = makePortrait(style)
                let before = rgba(source)
                XCTAssertTrue(rgba(try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: BeautyParameters(headWrap: 0.25)
                ).output) == before)
            }
        }
    }

    func testFaceShorteningVisibleContourCandidate() throws {
        // Admission and threshold are fixed from the source before rendering:
        // complete hair/chin silhouette has a long-face height/width ratio.
        for deepSkin in [false, true] {
            let source = makePortrait(PortraitStyle(deepSkin: deepSkin, hairline: 170))
            let before = rgba(source)
            let initialTop = hairTop(before)
            let initialChin = chinBottom(before)
            XCTAssertGreaterThan((initialChin - initialTop) / hairWidth(before, row: 150), 1.25)
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            let parameters = BeautyParameters(faceShortening: 0.25)
            let result = try engine.processResult(
                image: source, metadata: metadata, parameters: parameters
            )
            let after = rgba(result.output)
            let shortening = (initialChin - initialTop) -
                (chinBottom(after) - hairTop(after))
            XCTAssertGreaterThan(shortening, 1.0, "deepSkin=\(deepSkin)")
            XCTAssertEqual(visibleEyeWidth(after), visibleEyeWidth(before), accuracy: 1.0)
            XCTAssertEqual(visibleMouthWidth(after), visibleMouthWidth(before), accuracy: 1.0)
            assertRegion(before, after, x: 240..<273, y: 250..<310)
            XCTAssertEqual(result.output.extent, source.extent)
            assertExterior(before, after)
            assertAlpha(before, after)
            XCTAssertEqual(after, rgba(try engine.processResult(
                image: source, metadata: metadata, parameters: parameters
            ).output))
        }
    }

    func testSubmentalBulgeReductionAndFlatChinNegative() throws {
        for deepSkin in [false, true] {
          for bulgeRadius in [22.0, 27.0] {
            let source = makePortrait(PortraitStyle(
                deepSkin: deepSkin, hairline: 170, chinBulge: true,
                chinBulgeRadiusY: bulgeRadius
            ))
            let before = rgba(source)
            let bottom = chinBottom(before)
            XCTAssertGreaterThan(bottom, 425)
            let sourceArea = submentalArea(before)
            XCTAssertGreaterThan(sourceArea, 100)
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            let noFace = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.noFace]))
            XCTAssertEqual(rgba(try engine.processResult(
                image: source, metadata: metadata, parameters: .init()
            ).output), before)
            let baseResult = try engine.processResult(
                image: source, metadata: metadata,
                parameters: .init(doubleChinReduction: 0.25)
            )
            let proResult = try engine.processResult(
                image: source, metadata: metadata,
                parameters: .init(doubleChinReductionPro: 0.25)
            )
            XCTAssertEqual(baseResult.output.extent, source.extent)
            XCTAssertEqual(proResult.output.extent, source.extent)
            let base = rgba(baseResult.output)
            let pro = rgba(proResult.output)
            XCTAssertGreaterThan(bottom - chinBottom(base), 5.0)
            XCTAssertGreaterThan(chinBottom(base) - chinBottom(pro), 1.0)
            let baseArea = submentalArea(base)
            let proArea = submentalArea(pro)
            XCTAssertGreaterThan(Double(sourceArea - baseArea) / Double(sourceArea), 0.05)
            XCTAssertGreaterThan(Double(baseArea - proArea) / Double(baseArea), 0.05)
            for after in [base, pro] {
                assertRegion(before, after, x: 190..<322, y: 184..<345)
                assertExterior(before, after)
                assertAlpha(before, after)
                XCTAssertLessThanOrEqual(maxChinContourStep(after), 3)
            }
            let flat = makePortrait(PortraitStyle(deepSkin: deepSkin, hairline: 170))
            let flatBytes = rgba(flat)
            for parameters in [BeautyParameters(doubleChinReduction: 0.25),
                               BeautyParameters(doubleChinReductionPro: 0.25)] {
                XCTAssertEqual(rgba(try engine.processResult(
                    image: flat, metadata: metadata, parameters: parameters
                ).output), flatBytes)
                XCTAssertEqual(rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output), parameters.doubleChinReduction > 0 ? base : pro)
                XCTAssertEqual(rgba(try noFace.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output), before)
            }
            for style in [
                PortraitStyle(deepSkin: deepSkin, hairline: 170, detachedCollar: true),
                PortraitStyle(deepSkin: deepSkin, hairline: 170, internalChinFold: true),
            ] {
                let negative = makePortrait(style)
                let negativeBytes = rgba(negative)
                XCTAssertEqual(negativeBytes[(420 * side + 256) * 4], 25)
                for parameters in [BeautyParameters(doubleChinReduction: 0.25),
                                   BeautyParameters(doubleChinReductionPro: 0.25)] {
                    XCTAssertTrue(rgba(try engine.processResult(
                        image: negative, metadata: metadata, parameters: parameters
                    ).output) == negativeBytes,
                    "collar=\(style.detachedCollar) fold=\(style.internalChinFold)")
                }
            }
          }
        }
    }

    func testShortFaceNegativeRemainsExact() throws {
        for deepSkin in [false, true] {
            let source = makePortrait(PortraitStyle(
                deepSkin: deepSkin, halfHeight: 100, hairline: 170
            ))
            let before = rgba(source)
            let visibleRatio = (chinBottom(before) - hairTop(before)) / headWidth(before)
            XCTAssertLessThan(visibleRatio, 1.25)
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.shortFace]))
            let result = try engine.processResult(
                image: source, metadata: metadata,
                parameters: BeautyParameters(faceShortening: 0.25)
            )
            XCTAssertEqual(rgba(result.output), before)
            XCTAssertEqual(result.output.extent, source.extent)
        }
    }

    func testVerticalGapSemanticCandidates() throws {
        // Source visibly separates nose, upper lip and chin. The upper lip is
        // registered with the injected face support before any output is read.
        for deepSkin in [false, true] {
          for (mouthTop, noseEnd) in [(313, 292), (315, 300), (315, 292), (318, 292)] {
            let source = makePortrait(PortraitStyle(
                deepSkin: deepSkin, hairline: 170,
                mouthTop: mouthTop, noseBottom: noseEnd
            ))
            let before = rgba(source)
            let nose = noseBottom(before)
            let lip = lipTop(before)
            let chin = chinBottom(before)
            XCTAssertGreaterThan(lip - nose, 10)
            XCTAssertGreaterThan(chin - lip, 90)
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            let gpu = try BeautyEngine(
                configuration: .init(renderBackend: .gpu),
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
            )
            let noFace = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.noFace]))
            let noNose = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.phase93MissingNose]))
            let noLips = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.phase94MouthPortraitMissingOuterLips]))
            for (name, value, parameters) in [
                ("philtrum+", 1.0, BeautyParameters(philtrumLength: 0.30)),
                ("philtrum-", -1.0, BeautyParameters(philtrumLength: -0.30)),
                ("lower+", 1.0, BeautyParameters(lowerFaceLength: 0.30)),
                ("lower-", -1.0, BeautyParameters(lowerFaceLength: -0.30)),
            ] {
                let result = try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                )
                let after = rgba(result.output)
                let gapChange = name.hasPrefix("philtrum")
                    ? (lipTop(after) - noseBottom(after)) - (lip - nose)
                    : (chinBottom(after) - lipTop(after)) - (chin - lip)
                XCTAssertGreaterThan(gapChange * value, 0.5,
                                     "\(name) deepSkin=\(deepSkin) mouth=\(mouthTop) nose=\(noseEnd)")
                if name.hasPrefix("philtrum") {
                    XCTAssertLessThan(abs(noseBottom(after) - nose), 0.5,
                                      "nose protection \(name)")
                    XCTAssertEqual(visibleMouthWidth(after), visibleMouthWidth(before),
                                   accuracy: 1.0)
                    XCTAssertEqual(regionChangedPixels(before, after,
                        x: 190..<322, y: 184..<250), 0)
                    XCTAssertTrue(after == rgba(try gpu.processResult(
                        image: source, metadata: metadata, parameters: parameters
                    ).output))
                } else {
                    XCTAssertLessThan(abs(lipTop(after) - lip), 0.5,
                                      "upper-lip protection \(name)")
                }
                XCTAssertEqual(result.output.extent, source.extent)
                assertExterior(before, after)
                assertAlpha(before, after)
                XCTAssertLessThanOrEqual(maxChinContourStep(after), 3)
                XCTAssertTrue(after == rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output))
                XCTAssertTrue(rgba(try noFace.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output) == before)
                if name.hasPrefix("philtrum") {
                    for unsupported in [noNose, noLips] {
                        XCTAssertTrue(rgba(try unsupported.processResult(
                            image: source, metadata: metadata, parameters: parameters
                        ).output) == before)
                    }
                }
            }
          }
        }
    }

    func testForeheadAndMidfaceVisibleProportionCandidates() throws {
        for deepSkin in [false, true] {
          for noseBottom in [292, 300] {
            let source = makePortrait(PortraitStyle(
                deepSkin: deepSkin, hairline: 170, noseBottom: noseBottom
            ))
            let before = rgba(source)
            let hairline = hairlineRow(before, x: 256)
            let eyes = visibleEyes(before)
            let nose = darkCentroid(before, x: 240..<273, y: 245..<312)
            let lip = visibleMouth(before)
            XCTAssertGreaterThan(eyes.left.y - Double(hairline), 30)
            XCTAssertGreaterThan(nose.y - eyes.left.y, 50)
            XCTAssertGreaterThan(lip.y - nose.y, 40)
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            let noFace = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.noFace]))
            let noNose = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.phase93MissingNose]))
            XCTAssertTrue(rgba(try engine.processResult(
                image: source, metadata: metadata, parameters: .init()
            ).output) == before)
            for (name, sign, parameters) in [
                ("forehead+", 1.0, BeautyParameters(foreheadHeight: 0.30)),
                ("forehead-", -1.0, BeautyParameters(foreheadHeight: -0.30)),
                ("midface+", 1.0, BeautyParameters(midfaceLength: 0.30)),
                ("midface-", -1.0, BeautyParameters(midfaceLength: -0.30)),
            ] {
                let result = try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                )
                let after = rgba(result.output)
                let movedEyes = visibleEyes(after)
                let movedLip = visibleMouth(after)
                if name.hasPrefix("forehead") {
                    let movedHairline = hairlineRow(after, x: 256)
                    XCTAssertGreaterThan(Double(hairline - movedHairline) * sign, 0.5)
                    XCTAssertLessThan(abs(movedEyes.left.y - eyes.left.y), 0.3)
                    XCTAssertEqual(regionChangedPixels(before, after,
                        x: 190..<322, y: 184..<345), 0)
                } else {
                    let movedNose = darkCentroid(after, x: 240..<273, y: 245..<312)
                    XCTAssertGreaterThan((movedNose.y - nose.y) * sign, 0.5)
                    XCTAssertLessThan(abs(movedEyes.left.y - eyes.left.y), 0.3)
                    XCTAssertLessThan(abs(movedLip.y - lip.y), 0.3)
                    let sourceRatio = (nose.y - eyes.left.y) / (lip.y - eyes.left.y)
                    let outputRatio = (movedNose.y - movedEyes.left.y) /
                        (movedLip.y - movedEyes.left.y)
                    XCTAssertGreaterThan((outputRatio - sourceRatio) * sign, 0.003)
                    XCTAssertEqual(sourceDarkFeatureChangedPixels(before, after,
                        x: 190..<322, y: 186..<217), 0)
                    XCTAssertEqual(regionChangedPixels(before, after,
                        x: 190..<322, y: 332..<345), 0)
                }
                assertExterior(before, after)
                assertAlpha(before, after)
                XCTAssertEqual(result.output.extent, source.extent)
                XCTAssertTrue(after == rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output))
                XCTAssertTrue(rgba(try noFace.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output) == before)
            }
            for value in [0.30, -0.30] {
                XCTAssertTrue(rgba(try noNose.processResult(
                    image: source, metadata: metadata,
                    parameters: BeautyParameters(midfaceLength: Float(value))
                ).output) == before)
            }
            for style in [
                PortraitStyle(deepSkin: deepSkin, hairline: 0),
                PortraitStyle(deepSkin: deepSkin, hairline: 170, lowContrastHair: true),
            ] {
                let negative = makePortrait(style)
                let negativeBytes = rgba(negative)
                for value in [0.30, -0.30] {
                    XCTAssertTrue(rgba(try engine.processResult(
                        image: negative, metadata: metadata,
                        parameters: BeautyParameters(foreheadHeight: Float(value))
                    ).output) == negativeBytes)
                }
            }
          }
        }
    }

    func testLowerFaceLengthVariedChinCandidates() throws {
        for deepSkin in [false, true] {
          for (halfHeight, mouthTop) in [(155.0, 313), (160.0, 315), (165.0, 315)] {
            let source = makePortrait(PortraitStyle(
                deepSkin: deepSkin, halfHeight: halfHeight,
                hairline: 170, mouthTop: mouthTop
            ))
            let before = rgba(source)
            let lip = lipTop(before)
            let chin = chinBottom(before)
            XCTAssertGreaterThan(chin - lip, 85)
            XCTAssertLessThanOrEqual(maxChinContourStep(before), 3)
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            let noFace = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.noFace]))
            let noLips = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.phase94MouthPortraitMissingOuterLips]))
            for (value, sign) in [(0.30, 1.0), (-0.30, -1.0)] {
                let parameters = BeautyParameters(lowerFaceLength: Float(value))
                let result = try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                )
                let after = rgba(result.output)
                let changedGap = (chinBottom(after) - lipTop(after)) - (chin - lip)
                XCTAssertGreaterThan(changedGap * sign, 0.5)
                XCTAssertLessThan(abs(lipTop(after) - lip), 0.5)
                XCTAssertLessThanOrEqual(maxChinContourStep(after), 3)
                XCTAssertEqual(regionChangedPixels(before, after,
                    x: 190..<322, y: 184..<345), 0)
                assertExterior(before, after)
                assertAlpha(before, after)
                XCTAssertEqual(result.output.extent, source.extent)
                XCTAssertTrue(after == rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output))
                XCTAssertTrue(rgba(try noFace.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output) == before)
                XCTAssertTrue(rgba(try noLips.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output) == before)
            }
          }
        }
    }

    func testPhiltrumOffsetLipSourceExitsWithoutSkinWarp() throws {
        for deepSkin in [false, true] {
            let source = makePortrait(PortraitStyle(
                deepSkin: deepSkin, hairline: 170,
                mouthTop: 323, noseBottom: 292
            ))
            let before = rgba(source)
            XCTAssertEqual(lipTop(before), 323)
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            let gpu = try BeautyEngine(
                configuration: .init(renderBackend: .gpu),
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
            )
            for value in [0.30, -0.30] {
                let parameters = BeautyParameters(philtrumLength: Float(value))
                XCTAssertTrue(rgba(try engine.processResult(
                    image: source, metadata: metadata,
                    parameters: parameters
                ).output) == before)
                XCTAssertTrue(rgba(try gpu.processResult(
                    image: source, metadata: metadata,
                    parameters: parameters
                ).output) == before)
            }
            let noLip = makePortrait(PortraitStyle(
                deepSkin: deepSkin, hairline: 170, mouthTop: 500
            ))
            let noLipBytes = rgba(noLip)
            XCTAssertTrue(rgba(try engine.processResult(
                image: noLip, metadata: metadata,
                parameters: .init(philtrumLength: 0.30)
            ).output) == noLipBytes)
        }
    }

    func testQualifiedWholeFaceOrientationMirrorAndOffsetExtent() throws {
        let source = makePortrait(PortraitStyle(deepSkin: false, hairline: 170))
        for orientation: CGImagePropertyOrientation in [.up, .down, .left, .right] {
            for mirrored in [false, true] {
                let orientedSource = source.oriented(orientation)
                let before = rgba(orientedSource)
                let metadata = BeautyInputMetadata(
                    orientation: orientation, isInputMirrored: mirrored,
                    source: .testFixture
                )
                let engine = try BeautyEngine(faceDetectionProvider:
                    SDKTestingFaceDetectionProvider([.usableFace]))
                for parameters in [BeautyParameters(wholeFaceXPosition: 0.30),
                                   BeautyParameters(wholeFaceYPosition: -0.30)] {
                    let output = try engine.processResult(
                        image: orientedSource, metadata: metadata, parameters: parameters
                    ).output
                    XCTAssertEqual(output.extent, orientedSource.extent)
                    XCTAssertFalse(rgba(output) == before,
                                   "orientation=\(orientation) mirrored=\(mirrored)")
                    XCTAssertTrue(rgba(output) == rgba(try engine.processResult(
                        image: orientedSource, metadata: metadata, parameters: parameters
                    ).output))
                }
            }
        }
        let offset = source.transformed(by: CGAffineTransform(translationX: 17, y: -9))
        let engine = try BeautyEngine(faceDetectionProvider:
            SDKTestingFaceDetectionProvider([.usableFace]))
        let output = try engine.processResult(
            image: offset, metadata: metadata,
            parameters: .init(wholeFaceXPosition: 0.30)
        ).output
        XCTAssertEqual(output.extent, offset.extent)
        XCTAssertFalse(rgbaAtExtent(output) == rgbaAtExtent(offset))
    }

    func testWholeFaceVisibleSilhouetteCandidates() throws {
        for deepSkin in [false, true] {
          for (halfWidth, halfHeight, wave) in [(108.0, 160.0, 0), (98.0, 168.0, 5)] {
            let source = makePortrait(PortraitStyle(
                deepSkin: deepSkin, halfWidth: halfWidth,
                halfHeight: halfHeight, hairline: 170, hairlineWave: wave
            ))
            let before = rgba(source)
            let top = hairTop(before)
            let chin = chinBottom(before)
            let center = headCenterX(before)
            let eyes = visibleEyes(before)
            let mouth = visibleMouth(before)
            XCTAssertGreaterThan(chin - top, 300)
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            let gpu = try BeautyEngine(
                configuration: .init(renderBackend: .gpu),
                faceDetectionProvider: SDKTestingFaceDetectionProvider([.usableFace])
            )
            let noFace = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.noFace]))
            XCTAssertTrue(rgba(try engine.processResult(
                image: source, metadata: metadata, parameters: .init()
            ).output) == before)
            for (name, sign, parameters) in [
                ("wholeY+", 1.0, BeautyParameters(wholeFaceYPosition: 0.30)),
                ("wholeY-", -1.0, BeautyParameters(wholeFaceYPosition: -0.30)),
                ("wholeX+", 1.0, BeautyParameters(wholeFaceXPosition: 0.30)),
                ("wholeX-", -1.0, BeautyParameters(wholeFaceXPosition: -0.30)),
            ] {
                let result = try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                )
                let after = rgba(result.output)
                let dx = name.hasPrefix("wholeX") ? Int(sign * 7) : 0
                let dy = name.hasPrefix("wholeY") ? Int(sign * 11) : 0
                let movedEyes = visibleEyes(after, dx: dx, dy: dy)
                let movedMouth = visibleMouth(after, dx: dx, dy: dy)
                if name.hasPrefix("wholeY") {
                    XCTAssertGreaterThan((hairTop(after) - top) * sign, 0.3, name)
                    XCTAssertGreaterThan((chinBottom(after) - chin) * sign, 0.3, name)
                    XCTAssertGreaterThan((movedEyes.left.y - eyes.left.y) * sign, 0.4, name)
                    XCTAssertGreaterThan((movedEyes.right.y - eyes.right.y) * sign, 0.4, name)
                    XCTAssertGreaterThan((movedMouth.y - mouth.y) * sign, 0.4, name)
                    XCTAssertEqual(movedMouth.y - movedEyes.left.y,
                                   mouth.y - eyes.left.y, accuracy: 0.1)
                } else {
                    XCTAssertGreaterThan((headCenterX(after) - center) * sign, 0.5, name)
                    XCTAssertGreaterThan((movedEyes.left.x - eyes.left.x) * sign, 0.4, name)
                    XCTAssertGreaterThan((movedEyes.right.x - eyes.right.x) * sign, 0.4, name)
                    XCTAssertGreaterThan((movedMouth.x - mouth.x) * sign, 0.4, name)
                    XCTAssertEqual(movedMouth.x - movedEyes.left.x,
                                   mouth.x - eyes.left.x, accuracy: 0.1)
                }
                XCTAssertEqual(visibleEyeWidth(after, dx: dx, dy: dy),
                               visibleEyeWidth(before), accuracy: 0.1)
                XCTAssertEqual(visibleMouthWidth(after, dx: dx, dy: dy),
                               visibleMouthWidth(before), accuracy: 0.1)
                XCTAssertEqual(movedEyes.right.x - movedEyes.left.x,
                               eyes.right.x - eyes.left.x, accuracy: 0.1)
                XCTAssertEqual(foregroundCount(after), foregroundCount(before))
                XCTAssertEqual(chinBottom(after) - hairTop(after), chin - top, accuracy: 3.0)
                XCTAssertEqual(result.output.extent, source.extent)
                assertExterior(before, after)
                assertAlpha(before, after)
                XCTAssertEqual(after, rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output))
                XCTAssertTrue(after == rgba(try gpu.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output))
                XCTAssertTrue(rgba(try noFace.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output) == before)
            }
          }
            let detached = makePortrait(PortraitStyle(
                deepSkin: deepSkin, hairline: 170, detachedCollar: true
            ))
            let detachedBytes = rgba(detached)
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            for parameters in [BeautyParameters(wholeFaceXPosition: 0.30),
                               BeautyParameters(wholeFaceYPosition: -0.30)] {
                XCTAssertTrue(rgba(try engine.processResult(
                    image: detached, metadata: metadata, parameters: parameters
                ).output) == detachedBytes)
            }
        }
    }

    func testWholeFaceTiltVisibleFeaturesAndSilhouetteCandidate() throws {
        // A level source eye line and horizontal lip are observed before any
        // result; both must rotate coherently while eye-center spacing holds.
        for deepSkin in [false, true] {
            let source = makePortrait(PortraitStyle(deepSkin: deepSkin, hairline: 170))
            let before = rgba(source)
            let eyes = visibleEyes(before)
            let crownX = hairCapCenterX(before)
            let chinX = chinRegionCenterX(before)
            XCTAssertLessThan(abs(eyes.right.y - eyes.left.y), 0.2)
            let engine = try BeautyEngine(faceDetectionProvider:
                SDKTestingFaceDetectionProvider([.usableFace]))
            for (sign, parameters) in [
                (1.0, BeautyParameters(wholeFaceTilt: 0.30)),
                (-1.0, BeautyParameters(wholeFaceTilt: -0.30)),
            ] {
                let result = try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                )
                let after = rgba(result.output)
                let movedEyes = visibleEyes(after)
                let movedMouth = visibleMouth(after)
                let eyeSlope = movedEyes.right.y - movedEyes.left.y
                XCTAssertGreaterThan(eyeSlope * sign, 0.8)
                XCTAssertGreaterThan((movedMouth.right.y - movedMouth.left.y) * sign, 0.3)
                XCTAssertGreaterThan((hairCapCenterX(after) - crownX) * sign, 0.4)
                XCTAssertGreaterThan((chinX - chinRegionCenterX(after)) * sign, 0.4)
                let sourceEyeSpan = hypot(eyes.right.x - eyes.left.x,
                                          eyes.right.y - eyes.left.y)
                let movedEyeSpan = hypot(movedEyes.right.x - movedEyes.left.x,
                                         movedEyes.right.y - movedEyes.left.y)
                XCTAssertEqual(movedEyeSpan, sourceEyeSpan, accuracy: 1.0)
                XCTAssertEqual(result.output.extent, source.extent)
                assertExterior(before, after)
                assertAlpha(before, after)
                XCTAssertEqual(after, rgba(try engine.processResult(
                    image: source, metadata: metadata, parameters: parameters
                ).output))
            }
        }
    }

    private func makePortrait(_ style: PortraitStyle) -> CIImage {
        var pixels = [UInt8](repeating: 255, count: side * side * 4)
        for y in 0..<side {
            for x in 0..<side {
                let dx = (Double(x) - 256) / style.halfWidth
                let dy = (Double(y) - 256) / style.halfHeight
                let chinBulge = style.chinBulge &&
                    pow(Double(x - 256) / 42, 2) +
                    pow(Double(y - 408) / style.chinBulgeRadiusY, 2) <= 1
                let insideHead = dx * dx + dy * dy <= 1 || chinBulge
                let eye = (200...216).contains(y) &&
                    ((202...228).contains(x) || (284...310).contains(x))
                let brow = (186...191).contains(y) &&
                    ((198...232).contains(x) || (280...314).contains(x))
                let nose = (259...style.noseBottom).contains(y) && (251...261).contains(x)
                let mouth = (style.mouthTop...(style.mouthTop + 12)).contains(y) &&
                    (225...287).contains(x)
                let texture = ((x / 7 + y / 7) % 2 == 0) ? 2 : -2
                let skin: (Int, Int, Int) = style.deepSkin
                    ? (100 + texture, 75 + texture, 60 + texture)
                    : (195 + texture, 150 + texture, 125 + texture)
                let rgb: (Int, Int, Int)
                if style.detachedCollar && (435...448).contains(y) &&
                    (210...302).contains(x) { rgb = (155, 130, 112) }
                else if !insideHead { rgb = (25, 40, 55) }
                else if y < style.hairline + Int((sin(Double(x - 256) / 24.0) *
                                                  Double(style.hairlineWave)).rounded()) {
                    rgb = style.lowContrastHair
                        ? (skin.0 - 12, skin.1 - 12, skin.2 - 12)
                        : (28, 25, 25)
                }
                else if (style.internalChinFold && (392...399).contains(y) &&
                         (230...282).contains(x)) || brow || eye || nose ||
                    (style.foreheadBand && (150...155).contains(y)) {
                    rgb = (40, 33, 30)
                }
                else if mouth { rgb = (150, 55, 70) }
                else { rgb = skin }
                let offset = (y * side + x) * 4
                pixels[offset] = UInt8(rgb.0)
                pixels[offset + 1] = UInt8(rgb.1)
                pixels[offset + 2] = UInt8(rgb.2)
                pixels[offset + 3] = 255
            }
        }
        return CIImage(bitmapData: Data(pixels), bytesPerRow: side * 4,
                       size: CGSize(width: side, height: side), format: .RGBA8,
                       colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
    }

    private func rgba(_ image: CIImage) -> [UInt8] {
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        CIContext(options: [.workingColorSpace: space, .outputColorSpace: space]).render(
            image, toBitmap: &pixels, rowBytes: side * 4,
            bounds: CGRect(x: 0, y: 0, width: side, height: side),
            format: .RGBA8, colorSpace: space)
        return pixels
    }

    private func rgbaAtExtent(_ image: CIImage) -> [UInt8] {
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        CIContext(options: [.workingColorSpace: space, .outputColorSpace: space]).render(
            image, toBitmap: &pixels, rowBytes: side * 4,
            bounds: image.extent, format: .RGBA8, colorSpace: space
        )
        return pixels
    }

    private func hairSignal(_ pixels: [UInt8], x: Int, y: Int) -> Double {
        let blue = Double(pixels[(y * side + x) * 4 + 2])
        return min(1, max(0, (45 - blue) / 20))
    }

    private func hairlineRow(_ pixels: [UInt8], x: Int) -> Int {
        for y in 120..<195 {
            if pixels[(y * side + x) * 4] >= 60 { return y }
        }
        XCTFail("source or output lost the forehead hair/skin boundary")
        return 180
    }

    private func maxHairlineStep(_ pixels: [UInt8]) -> Int {
        var maximum = 0
        var previous: Int?
        for x in 215..<298 {
            let row = hairlineRow(pixels, x: x)
            if let previous { maximum = max(maximum, abs(row - previous)) }
            previous = row
        }
        return maximum
    }

    private func hairTop(_ pixels: [UInt8]) -> Double {
        var previous = 0.0
        var weighted = 0.0
        var total = 0.0
        for y in 45..<200 {
            let signal = hairSignal(pixels, x: 256, y: y)
            let entering = max(0, signal - previous)
            weighted += Double(y) * entering
            total += entering
            previous = signal
        }
        XCTAssertGreaterThan(total, 0.5)
        return weighted / max(total, 0.01)
    }

    private func hairWidth(_ pixels: [UInt8], row: Int) -> Double {
        (125..<387).reduce(0) { sum, x in sum + hairSignal(pixels, x: x, y: row) }
    }

    private func maxHairSilhouetteStep(_ pixels: [UInt8]) -> Int {
        var maximum = 0
        var previousLeft: Int?
        var previousRight: Int?
        for y in 120..<165 {
            let left = (125..<256).first { hairSignal(pixels, x: $0, y: y) > 0.5 }
            let right = (256..<387).last { hairSignal(pixels, x: $0, y: y) > 0.5 }
            XCTAssertNotNil(left)
            XCTAssertNotNil(right)
            if let left, let right {
                if let previousLeft { maximum = max(maximum, abs(left - previousLeft)) }
                if let previousRight { maximum = max(maximum, abs(right - previousRight)) }
                previousLeft = left
                previousRight = right
            }
        }
        return maximum
    }

    private func hairCapCenterX(_ pixels: [UInt8]) -> Double {
        var total = 0.0
        var weighted = 0.0
        for y in 115..<145 {
            for x in 175..<337 {
                let signal = hairSignal(pixels, x: x, y: y)
                total += signal
                weighted += signal * Double(x)
            }
        }
        XCTAssertGreaterThan(total, 500)
        return weighted / max(total, 1)
    }

    private func chinRegionCenterX(_ pixels: [UInt8]) -> Double {
        var total = 0.0
        var weighted = 0.0
        for y in 400..<420 {
            for x in 180..<332 {
                let red = Double(pixels[(y * side + x) * 4])
                let signal = min(1, max(0, (red - 45) / 30))
                total += signal
                weighted += signal * Double(x)
            }
        }
        XCTAssertGreaterThan(total, 500)
        return weighted / max(total, 1)
    }

    private func chinBottom(_ pixels: [UInt8]) -> Double {
        var previous = 1.0
        var weighted = 0.0
        var total = 0.0
        for y in 340..<450 {
            let red = Double(pixels[(y * side + 256) * 4])
            let face = min(1, max(0, (red - 45) / 30))
            let exiting = max(0, previous - face)
            weighted += Double(y) * exiting
            total += exiting
            previous = face
        }
        XCTAssertGreaterThan(total, 0.5)
        return weighted / max(total, 0.01)
    }

    private func submentalArea(_ pixels: [UInt8]) -> Int {
        (420..<445).reduce(0) { total, y in
            total + (210..<302).reduce(0) { row, x in
                row + (pixels[(y * side + x) * 4] >= 70 ? 1 : 0)
            }
        }
    }

    private func maxChinContourStep(_ pixels: [UInt8]) -> Int {
        var previous: Int?
        var maximum = 0
        for x in 225..<288 {
            var edge = 445
            for y in 390..<445 where pixels[(y * side + x) * 4] < 70 {
                edge = y
                break
            }
            if let previous { maximum = max(maximum, abs(edge - previous)) }
            previous = edge
        }
        return maximum
    }

    private func noseBottom(_ pixels: [UInt8]) -> Double {
        (255..<310).reduce(0.0) { edge, y in
            let green = Double(pixels[(y * side + 256) * 4 + 1])
            return green < 52 ? Double(y) : edge
        }
    }

    private func lipTop(_ pixels: [UInt8]) -> Double {
        for y in 307..<360 {
            let green = Double(pixels[(y * side + 256) * 4 + 1])
            if green < 65 { return Double(y) }
        }
        XCTFail("source or output lost visible upper lip")
        return 360
    }

    private func headCenterX(_ pixels: [UInt8]) -> Double {
        var total = 0.0
        var weighted = 0.0
        for x in 100..<412 {
            let red = Double(pixels[(256 * side + x) * 4])
            let signal = min(1, max(0, (red - 35) / 30))
            total += signal
            weighted += signal * Double(x)
        }
        XCTAssertGreaterThan(total, 150)
        return weighted / max(total, 1)
    }

    private func headWidth(_ pixels: [UInt8]) -> Double {
        (100..<412).reduce(0) { total, x in
            let red = Double(pixels[(256 * side + x) * 4])
            return total + min(1, max(0, (red - 35) / 30))
        }
    }

    private func visibleEyeWidth(_ pixels: [UInt8], dx: Int = 0, dy: Int = 0) -> Double {
        Double(((190 + dx)..<(242 + dx)).filter { x in
            ((198 + dy)..<(231 + dy)).contains { y in
                let offset = (y * side + x) * 4
                return pixels[offset] < 70 && pixels[offset + 1] < 60
            }
        }.count)
    }

    private func visibleEyes(
        _ pixels: [UInt8], dx: Int = 0, dy: Int = 0
    ) -> (left: CGPoint, right: CGPoint) {
        (darkCentroid(pixels, x: (188 + dx)..<(244 + dx), y: (198 + dy)..<(231 + dy)),
         darkCentroid(pixels, x: (268 + dx)..<(324 + dx), y: (198 + dy)..<(231 + dy)))
    }

    private func visibleMouth(_ pixels: [UInt8], dx: Int = 0, dy: Int = 0) ->
        (x: Double, y: Double, left: CGPoint, right: CGPoint) {
        let all = lipCentroid(pixels, x: (210 + dx)..<(302 + dx),
                              y: (315 + dy)..<(365 + dy))
        return (all.x, all.y,
                lipCentroid(pixels, x: (215 + dx)..<(256 + dx),
                            y: (315 + dy)..<(365 + dy)),
                lipCentroid(pixels, x: (257 + dx)..<(298 + dx),
                            y: (315 + dy)..<(365 + dy)))
    }

    private func darkCentroid(_ pixels: [UInt8], x: Range<Int>, y: Range<Int>) -> CGPoint {
        featureCentroid(pixels, x: x, y: y) { r, g, _ in r < 70 && g < 60 }
    }

    private func lipCentroid(_ pixels: [UInt8], x: Range<Int>, y: Range<Int>) -> CGPoint {
        featureCentroid(pixels, x: x, y: y) { r, g, _ in r >= 120 && g < 90 }
    }

    private func featureCentroid(
        _ pixels: [UInt8], x: Range<Int>, y: Range<Int>,
        selecting: (UInt8, UInt8, UInt8) -> Bool
    ) -> CGPoint {
        var count = 0.0
        var xSum = 0.0
        var ySum = 0.0
        for row in y {
            for column in x {
                let offset = (row * side + column) * 4
                if selecting(pixels[offset], pixels[offset + 1], pixels[offset + 2]) {
                    count += 1
                    xSum += Double(column)
                    ySum += Double(row)
                }
            }
        }
        XCTAssertGreaterThan(count, 5)
        return CGPoint(x: xSum / max(count, 1), y: ySum / max(count, 1))
    }

    private func visibleMouthWidth(_ pixels: [UInt8], dx: Int = 0, dy: Int = 0) -> Double {
        Double(((215 + dx)..<(298 + dx)).filter { x in
            ((315 + dy)..<(365 + dy)).contains { y in
                let offset = (y * side + x) * 4
                return pixels[offset] >= 120 && pixels[offset + 1] < 90
            }
        }.count)
    }

    private func foregroundCount(_ pixels: [UInt8]) -> Int {
        stride(from: 0, to: pixels.count, by: 4).reduce(0) { count, offset in
            let difference = abs(Int(pixels[offset]) - 25) +
                abs(Int(pixels[offset + 1]) - 40) +
                abs(Int(pixels[offset + 2]) - 55)
            return count + (difference > 35 ? 1 : 0)
        }
    }


    private func assertRegion(_ before: [UInt8], _ after: [UInt8],
                              x: Range<Int>, y: Range<Int>,
                              file: StaticString = #filePath, line: UInt = #line) {
        for row in y {
            for column in x {
                let offset = (row * side + column) * 4
                XCTAssertEqual(Array(after[offset..<(offset + 4)]),
                               Array(before[offset..<(offset + 4)]), file: file, line: line)
            }
        }
    }

    private func regionChangedPixels(
        _ before: [UInt8], _ after: [UInt8], x: Range<Int>, y: Range<Int>
    ) -> Int {
        var count = 0
        for row in y {
            for column in x {
                let offset = (row * side + column) * 4
                if (0..<4).contains(where: { before[offset + $0] != after[offset + $0] }) {
                    count += 1
                }
            }
        }
        return count
    }

    private func sourceDarkFeatureChangedPixels(
        _ before: [UInt8], _ after: [UInt8], x: Range<Int>, y: Range<Int>
    ) -> Int {
        var count = 0
        for row in y {
            for column in x {
                let offset = (row * side + column) * 4
                guard before[offset] < 70, before[offset + 1] < 60 else { continue }
                if (0..<4).contains(where: { before[offset + $0] != after[offset + $0] }) {
                    count += 1
                }
            }
        }
        return count
    }

    private func assertExterior(_ before: [UInt8], _ after: [UInt8],
                                file: StaticString = #filePath, line: UInt = #line) {
        for y in 0..<side {
            for x in 0..<side where x < 50 || x >= side - 50 || y < 40 || y >= side - 40 {
                let offset = (y * side + x) * 4
                XCTAssertEqual(Array(after[offset..<(offset + 4)]),
                               Array(before[offset..<(offset + 4)]), file: file, line: line)
            }
        }
    }

    private func assertAlpha(_ before: [UInt8], _ after: [UInt8],
                             file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(stride(from: 3, to: before.count, by: 4).map { before[$0] },
                       stride(from: 3, to: after.count, by: 4).map { after[$0] },
                       file: file, line: line)
    }

}
