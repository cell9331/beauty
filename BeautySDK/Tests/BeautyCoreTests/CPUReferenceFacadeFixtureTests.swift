import CoreGraphics
import XCTest
import BeautySDK

final class CPUReferenceFacadeFixtureTests: XCTestCase {
    func testOpaqueFacadeFixtureHasExactRGBA8ShapeAndNamedSRGBMetadata() throws {
        let fixture = try CPUReferenceFacadeFixture.opaqueNeutral()
        XCTAssertGreaterThan(fixture.width, 0)
        XCTAssertGreaterThan(fixture.height, 0)
        XCTAssertEqual(fixture.rgba8.count, fixture.width * fixture.height * 4)
        XCTAssertEqual(fixture.rowBytes, fixture.width * 4)
        XCTAssertEqual(fixture.byteCount, fixture.rowBytes * fixture.height)
        XCTAssertEqual(fixture.colorSpaceName, CGColorSpace.sRGB)
        XCTAssertEqual(fixture.metadata.source, .testFixture)
        XCTAssertEqual(fixture.metadata.orientation, .up)
        XCTAssertTrue(fixture.alphaValues.allSatisfy { $0 == 255 })
        XCTAssertEqual(fixture.image.extent, CGRect(x: 0, y: 0, width: fixture.width, height: fixture.height))
    }

    func testGradientAndAlphaBoundaryAreConstructedEntirelyInMemory() throws {
        let gradient = try CPUReferenceFacadeFixture.geometryGradient()
        let alpha = try CPUReferenceFacadeFixture.alphaBoundary()
        XCTAssertEqual(gradient.colorSpaceName, CGColorSpace.sRGB)
        XCTAssertEqual(alpha.alphaValues, [0, 1, 127, 254, 255])
        XCTAssertEqual(alpha.metadata.source, .testFixture)
        XCTAssertEqual(alpha.image.extent.width, 5)
        XCTAssertEqual(alpha.image.extent.height, 1)
    }

    func testRepeatedFacadeFixtureConstructionHasStableBytesAndDimensions() throws {
        let first = try CPUReferenceFacadeFixture.geometryGradient()
        let second = try CPUReferenceFacadeFixture.geometryGradient()
        XCTAssertEqual(first.rgba8, second.rgba8)
        XCTAssertEqual(first.image.extent, second.image.extent)
        XCTAssertEqual(first.colorSpaceName, second.colorSpaceName)
        XCTAssertEqual(first.metadata, second.metadata)
    }

    func testTransparentFixtureReachesPublicLocalRetouchValidationAndFailsClosed() throws {
        let fixture = try CPUReferenceFacadeFixture.alphaBoundary()
        let engine = try BeautyEngine(configuration: .default)
        XCTAssertThrowsError(
            try engine.processResult(
                image: fixture.image,
                metadata: fixture.metadata,
                parameters: BeautyParameters(teethWhitening: 1)
            )
        ) { error in
            XCTAssertEqual(error as? BeautyError, .invalidInput)
        }
    }
}
