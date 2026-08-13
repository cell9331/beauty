import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects

final class BeautyFullScleraRednessProviderTests: XCTestCase {
    private let width = 320
    private let height = 200
    private let leftCenter = (x: 90, y: 100)
    private let rightCenter = (x: 230, y: 100)

    func testFullStrategyCoversBroadBilateralScleraAndRetainsFocalBaseline() throws {
        let fixture = makeFixture(includeVessels: true)
        let source = try canonical(fixture.bytes)

        let fullOwner = BeautyLocalRetouchCompositionOwner(source: source)
        let full = BeautyFullScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [rightSupport, leftSupport],
            eyeOrder: .canonical,
            strength: 1,
            owner: fullOwner
        )
        let fullOutput = Array(try fullOwner.compose(full.units).canonicalImage.rgba8Data)

        let focalOwner = BeautyLocalRetouchCompositionOwner(source: source)
        let focal = BeautyFocalScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [rightSupport, leftSupport],
            eyeOrder: .canonical,
            strength: 1,
            owner: focalOwner
        )

        let fullProposals = Set(full.proposalPixelIndices)
        XCTAssertEqual(full.summary.leftOutcome, .accepted)
        XCTAssertEqual(full.summary.rightOutcome, .accepted)
        XCTAssertEqual(full.units.count, 2)
        XCTAssertGreaterThan(fullProposals.count, max(200, focal.proposalPixelIndices.count * 3))
        XCTAssertFalse(fullProposals.intersection(fixture.neutralSclera).isEmpty)
        XCTAssertFalse(fullProposals.intersection(fixture.lowerCrescent).isEmpty)
        XCTAssertTrue(fullProposals.isDisjoint(with: fixture.caruncle))
        XCTAssertTrue(fullProposals.isDisjoint(with: fixture.protectedPixels))

        let changed = changedPixelIndices(before: fixture.bytes, after: fullOutput)
        XCTAssertFalse(changed.intersection(fixture.neutralSclera).isEmpty)
        XCTAssertFalse(changed.intersection(fixture.lowerCrescent).isEmpty)
        XCTAssertTrue(changed.isDisjoint(with: fixture.caruncle))
        XCTAssertTrue(changed.isDisjoint(with: fixture.protectedPixels))
    }

    func testStableFacadeRoutesToFullStrategyExactly() throws {
        let fixture = makeFixture(includeVessels: true)
        let source = try canonical(fixture.bytes)

        let directOwner = BeautyLocalRetouchCompositionOwner(source: source)
        let direct = BeautyFullScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [leftSupport, rightSupport],
            eyeOrder: .canonical,
            strength: 1,
            owner: directOwner
        )
        let directOutput = try directOwner.compose(direct.units).canonicalImage.rgba8Data

        let facadeOwner = BeautyLocalRetouchCompositionOwner(source: source)
        let facade = BeautyScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [leftSupport, rightSupport],
            eyeOrder: .canonical,
            strength: 1,
            owner: facadeOwner
        )
        let facadeOutput = try facadeOwner.compose(facade.units).canonicalImage.rgba8Data

        XCTAssertEqual(facade.summary, direct.summary)
        XCTAssertEqual(facade.proposalPixelIndices, direct.proposalPixelIndices)
        XCTAssertEqual(facadeOutput, directOutput)
    }

    func testCaruncleAloneCannotAdmitBroadWhitening() throws {
        let fixture = makeFixture(includeVessels: false)
        let source = try canonical(fixture.bytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let result = BeautyFullScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [leftSupport, rightSupport],
            eyeOrder: .canonical,
            strength: 1,
            owner: owner
        )

        XCTAssertTrue(result.units.isEmpty)
        XCTAssertEqual(result.summary.leftOutcome, .noMaterialRedness)
        XCTAssertEqual(result.summary.rightOutcome, .noMaterialRedness)
        XCTAssertTrue(result.proposalPixelIndices.isEmpty)
        XCTAssertEqual(try owner.compose(result.units).canonicalImage.rgba8Data, source.rgba8Data)
    }

    func testTwoRedPixelsCannotAmplifyAcrossColoredApertureInterior() throws {
        let fixture = makeFixture(includeVessels: false)
        var bytes = fixture.bytes
        for index in fixture.neutralSclera {
            replaceRGB(&bytes, index: index, color: (50, 180, 50))
        }
        for center in [leftCenter, rightCenter] {
            replaceRGB(
                &bytes,
                index: pixelIndex(x: center.x - 36, y: center.y),
                color: (210, 150, 150)
            )
            replaceRGB(
                &bytes,
                index: pixelIndex(x: center.x - 35, y: center.y),
                color: (210, 150, 150)
            )
        }
        let source = try canonical(bytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let result = BeautyFullScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [leftSupport, rightSupport],
            eyeOrder: .canonical,
            strength: 1,
            owner: owner
        )

        XCTAssertTrue(result.units.isEmpty)
        XCTAssertEqual(result.summary.leftOutcome, .noMaterialRedness)
        XCTAssertEqual(result.summary.rightOutcome, .noMaterialRedness)
        XCTAssertTrue(result.proposalPixelIndices.isEmpty)
        XCTAssertEqual(try owner.compose(result.units).canonicalImage.rgba8Data, source.rgba8Data)
    }

    func testAcceptedEyeLeavesColoredApertureInteriorUnowned() throws {
        let fixture = makeFixture(includeVessels: true)
        var bytes = fixture.bytes
        var coloredInterior = Set<Int>()
        for center in [leftCenter, rightCenter] {
            for y in (center.y - 5)...(center.y + 5) {
                for x in (center.x - 50)...(center.x - 41) {
                    let index = pixelIndex(x: x, y: y)
                    guard fixture.neutralSclera.contains(index) else { continue }
                    replaceRGB(&bytes, index: index, color: (50, 180, 50))
                    coloredInterior.insert(index)
                }
            }
        }
        XCTAssertFalse(coloredInterior.isEmpty)
        let source = try canonical(bytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let result = BeautyFullScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [leftSupport, rightSupport],
            eyeOrder: .canonical,
            strength: 1,
            owner: owner
        )
        let output = Array(try owner.compose(result.units).canonicalImage.rgba8Data)

        XCTAssertEqual(result.summary.leftOutcome, .accepted)
        XCTAssertEqual(result.summary.rightOutcome, .accepted)
        XCTAssertTrue(Set(result.proposalPixelIndices).isDisjoint(with: coloredInterior))
        XCTAssertTrue(changedPixelIndices(before: bytes, after: output).isDisjoint(with: coloredInterior))
    }

    func testOversizedValidEyeWorkspaceIsRejectedBeforeMaskConstruction() throws {
        let fixture = makeFixture(includeVessels: true)
        let source = try canonical(fixture.bytes)
        let owner = BeautyLocalRetouchCompositionOwner(source: source)
        let oversized = BeautyObservedEyeSupport(
            side: .left,
            contour: [
                CoordinatePoint(x: 0.255, y: 0.305),
                CoordinatePoint(x: 0.745, y: 0.305),
                CoordinatePoint(x: 0.745, y: 0.695),
                CoordinatePoint(x: 0.255, y: 0.695),
            ],
            pupil: [CoordinatePoint(x: 0.5, y: 0.5)]
        )
        let result = BeautyFullScleraRednessProvider.makeResult(
            source: source,
            eyeSupport: [oversized],
            eyeOrder: .canonical,
            strength: 1,
            owner: owner
        )

        XCTAssertTrue(result.units.isEmpty)
        XCTAssertEqual(result.summary.leftOutcome, .unitRejected)
        XCTAssertEqual(result.summary.rightOutcome, .missingSupport)
        XCTAssertTrue(result.proposalPixelIndices.isEmpty)
    }

    func testFullTransformUsesBroadCueAndStrongerMeasuredRedCorrection() throws {
        let neutral = try XCTUnwrap(BeautyFullScleraRednessTransform.target(
            red: 210,
            green: 206,
            blue: 207,
            strength: 1
        ))
        let red = try XCTUnwrap(BeautyFullScleraRednessTransform.target(
            red: 210,
            green: 150,
            blue: 150,
            strength: 1
        ))

        XCTAssertGreaterThan(luminance(neutral), luminance((210, 206, 207)))
        XCTAssertLessThan(redExcess(red), redExcess((210, 150, 150)))
        XCTAssertLessThanOrEqual(maximumChannelDelta(red, (210, 150, 150)), 44)
        XCTAssertNil(BeautyFullScleraRednessTransform.target(
            red: 50,
            green: 180,
            blue: 50,
            strength: 1
        ))
        XCTAssertNil(BeautyFullScleraRednessTransform.target(
            red: 210,
            green: 150,
            blue: 150,
            strength: 0
        ))
    }

    private struct Fixture {
        let bytes: [UInt8]
        let neutralSclera: Set<Int>
        let lowerCrescent: Set<Int>
        let caruncle: Set<Int>
        let protectedPixels: Set<Int>
    }

    private func makeFixture(includeVessels: Bool) -> Fixture {
        var bytes = Array(
            repeating: [UInt8(164), UInt8(118), UInt8(105), UInt8(255)],
            count: width * height
        ).flatMap { $0 }
        var neutral = Set<Int>()
        var lower = Set<Int>()
        var caruncle = Set<Int>()
        var protected = Set<Int>()

        for (side, center) in [
            (BeautyObservedEyeSide.left, leftCenter),
            (.right, rightCenter),
        ] {
            for y in (center.y - 27)...(center.y + 27) {
                for x in (center.x - 55)...(center.x + 55) {
                    let dx = Double(x - center.x)
                    let dy = Double(y - center.y)
                    guard dx * dx / (55 * 55) + dy * dy / (27 * 27) <= 1 else { continue }
                    let index = pixelIndex(x: x, y: y)
                    let distance = hypot(dx, dy)
                    let isBoundary = dx * dx / (53 * 53) + dy * dy / (25 * 25) > 1
                    let isIris = distance <= 23.5
                    let isHighlight = (x == center.x - 6 || x == center.x - 5)
                        && (y == center.y - 7 || y == center.y - 6)
                    if isBoundary || isIris || isHighlight {
                        let color: (UInt8, UInt8, UInt8)
                        if isHighlight { color = (248, 248, 248) }
                        else if isIris { color = distance <= 9 ? (35, 41, 48) : (72, 79, 86) }
                        else { color = (38, 28, 30) }
                        replaceRGB(&bytes, index: index, color: color)
                        protected.insert(index)
                        continue
                    }

                    let isMedial = side == .left
                        ? x >= center.x + 43
                        : x <= center.x - 43
                    if isMedial {
                        replaceRGB(&bytes, index: index, color: (218, 135, 145))
                        caruncle.insert(index)
                        continue
                    }

                    replaceRGB(&bytes, index: index, color: (210, 206, 207))
                    neutral.insert(index)
                    if y >= center.y + 20 { lower.insert(index) }
                }
            }

            guard includeVessels else { continue }
            for anchor in [
                (x: center.x - 36, y: center.y),
                (x: center.x + 34, y: center.y + 5),
                (x: center.x + 11, y: center.y + 24),
            ] {
                for y in (anchor.y - 2)...(anchor.y + 2) {
                    for x in (anchor.x - 3)...(anchor.x + 3) {
                        let index = pixelIndex(x: x, y: y)
                        guard neutral.contains(index) else { continue }
                        replaceRGB(&bytes, index: index, color: (210, 150, 150))
                    }
                }
            }
        }
        return Fixture(
            bytes: bytes,
            neutralSclera: neutral,
            lowerCrescent: lower,
            caruncle: caruncle,
            protectedPixels: protected
        )
    }

    private var leftSupport: BeautyObservedEyeSupport {
        support(side: .left, center: leftCenter)
    }

    private var rightSupport: BeautyObservedEyeSupport {
        support(side: .right, center: rightCenter)
    }

    private func support(
        side: BeautyObservedEyeSide,
        center: (x: Int, y: Int)
    ) -> BeautyObservedEyeSupport {
        BeautyObservedEyeSupport(
            side: side,
            contour: (0..<24).map { index in
                let angle = Double(index) * 2 * .pi / 24
                return CoordinatePoint(
                    x: (Double(center.x) + 55 * cos(angle)) / Double(width),
                    y: (Double(center.y) + 27 * sin(angle)) / Double(height)
                )
            },
            pupil: [CoordinatePoint(
                x: Double(center.x) / Double(width),
                y: Double(center.y) / Double(height)
            )]
        )
    }

    private func canonical(_ bytes: [UInt8]) throws -> BeautyCanonicalStillImage {
        try BeautyCanonicalStillImage(
            rgba8Data: Data(bytes),
            width: width,
            height: height,
            rowBytes: width * 4,
            metadata: BeautyInputMetadata(
                orientation: .up,
                isInputMirrored: false,
                isPreviewMirrored: false,
                source: .photo
            )
        )
    }

    private func changedPixelIndices(before: [UInt8], after: [UInt8]) -> Set<Int> {
        Set((0..<(width * height)).filter { index in
            let offset = index * 4
            return before[offset..<(offset + 3)] != after[offset..<(offset + 3)]
        })
    }

    private func replaceRGB(
        _ bytes: inout [UInt8],
        index: Int,
        color: (UInt8, UInt8, UInt8)
    ) {
        let offset = index * 4
        bytes[offset] = color.0
        bytes[offset + 1] = color.1
        bytes[offset + 2] = color.2
    }

    private func luminance(_ pixel: BeautyFullScleraRednessTarget) -> Double {
        luminance((pixel.red, pixel.green, pixel.blue))
    }

    private func luminance(_ pixel: (UInt8, UInt8, UInt8)) -> Double {
        0.2126 * Double(pixel.0) / 255
            + 0.7152 * Double(pixel.1) / 255
            + 0.0722 * Double(pixel.2) / 255
    }

    private func redExcess(_ pixel: BeautyFullScleraRednessTarget) -> Double {
        redExcess((pixel.red, pixel.green, pixel.blue))
    }

    private func redExcess(_ pixel: (UInt8, UInt8, UInt8)) -> Double {
        max(
            0,
            Double(pixel.0) / 255
                - 0.83 * Double(pixel.1) / 255
                - 0.17 * Double(pixel.2) / 255
        )
    }

    private func maximumChannelDelta(
        _ target: BeautyFullScleraRednessTarget,
        _ source: (UInt8, UInt8, UInt8)
    ) -> Int {
        max(
            abs(Int(target.red) - Int(source.0)),
            max(
                abs(Int(target.green) - Int(source.1)),
                abs(Int(target.blue) - Int(source.2))
            )
        )
    }

    private func pixelIndex(x: Int, y: Int) -> Int { y * width + x }
}
