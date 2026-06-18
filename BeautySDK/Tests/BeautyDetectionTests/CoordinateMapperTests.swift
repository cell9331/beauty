import CoreGraphics
import ImageIO
import XCTest
import BeautyCore
@testable import BeautyDetection

final class CoordinateMapperTests: XCTestCase {
    func testPIPE05CoordinateSpaceDeclaresAllSupportedSpaces() {
        XCTAssertEqual(
            CoordinateSpace.allCases,
            [
                .visionNormalized,
                .imageNormalized,
                .imagePixel,
                .textureUV,
                .preview,
                .mirroredPreview
            ]
        )
    }

    func testPIPE05VisionNormalizedPointFlipsToTopLeftImageNormalized() throws {
        let mapper = mapper(orientation: .up)

        let point = try mapper.map(
            point: CoordinatePoint(x: 0.25, y: 0.75),
            from: .visionNormalized,
            to: .imageNormalized
        )

        assertPoint(point, equals: CoordinatePoint(x: 0.25, y: 0.25))
    }

    func testPIPE05RepresentativeOrientationsProduceDeterministicImageNormalizedPoints() throws {
        let source = CoordinatePoint(x: 0.25, y: 0.75)
        let expected: [(CGImagePropertyOrientation, CoordinatePoint)] = [
            (.up, CoordinatePoint(x: 0.25, y: 0.25)),
            (.right, CoordinatePoint(x: 0.75, y: 0.25)),
            (.left, CoordinatePoint(x: 0.25, y: 0.75)),
            (.down, CoordinatePoint(x: 0.75, y: 0.75))
        ]

        for (orientation, expectedPoint) in expected {
            let point = try mapper(orientation: orientation).map(
                point: source,
                from: .visionNormalized,
                to: .imageNormalized
            )

            assertPoint(point, equals: expectedPoint)
            XCTAssertTrue((0...1).contains(point.x))
            XCTAssertTrue((0...1).contains(point.y))
        }
    }

    func testPIPE05InputMirroringAffectsImageNormalizedInterpretationOnly() throws {
        let point = try mapper(orientation: .up, inputMirrored: true).map(
            point: CoordinatePoint(x: 0.25, y: 0.75),
            from: .visionNormalized,
            to: .imageNormalized
        )

        assertPoint(point, equals: CoordinatePoint(x: 0.75, y: 0.25))
    }

    func testPIPE05PreviewMirroringDoesNotMutateImageNormalizedInterpretation() throws {
        let source = CoordinatePoint(x: 0.25, y: 0.75)
        let unmirrored = try mapper(orientation: .right, previewMirrored: false).map(
            point: source,
            from: .visionNormalized,
            to: .imageNormalized
        )
        let previewMirrored = try mapper(orientation: .right, previewMirrored: true).map(
            point: source,
            from: .visionNormalized,
            to: .imageNormalized
        )

        assertPoint(unmirrored, equals: CoordinatePoint(x: 0.75, y: 0.25))
        assertPoint(previewMirrored, equals: unmirrored)
    }

    func testPIPE05ImageNormalizedMapsToPixelTexturePreviewAndMirroredPreview() throws {
        let mapper = mapper(orientation: .up, previewMirrored: true)
        let imagePoint = CoordinatePoint(x: 0.25, y: 0.50)

        let pixel = try mapper.map(point: imagePoint, from: .imageNormalized, to: .imagePixel)
        let texture = try mapper.map(point: imagePoint, from: .imageNormalized, to: .textureUV)
        let preview = try mapper.map(point: imagePoint, from: .imageNormalized, to: .preview)
        let mirroredPreview = try mapper.map(point: imagePoint, from: .imageNormalized, to: .mirroredPreview)

        assertPoint(pixel, equals: CoordinatePoint(x: 100, y: 100))
        assertPoint(texture, equals: imagePoint)
        assertPoint(preview, equals: CoordinatePoint(x: 50, y: 50))
        assertPoint(mirroredPreview, equals: CoordinatePoint(x: 150, y: 50))
    }

    func testPIPE05MirroredPreviewRespectsPreviewMirroringFlag() throws {
        let mapper = mapper(orientation: .up, previewMirrored: false)

        let mirroredPreview = try mapper.map(
            point: CoordinatePoint(x: 0.25, y: 0.50),
            from: .imageNormalized,
            to: .mirroredPreview
        )

        assertPoint(mirroredPreview, equals: CoordinatePoint(x: 50, y: 50))
    }

    func testPIPE05VisionNormalizedRectMapsThroughCornerBounding() throws {
        let rect = try mapper(orientation: .up).map(
            rect: CoordinateRect(x: 0.25, y: 0.25, width: 0.50, height: 0.50),
            from: .visionNormalized,
            to: .imageNormalized
        )

        assertRect(rect, equals: CoordinateRect(x: 0.25, y: 0.25, width: 0.50, height: 0.50))
    }

    func testPIPE07InvalidImageExtentThrowsMapperError() {
        let zeroExtentMapper = mapper(orientation: .up, imageExtent: .zero)
        XCTAssertThrowsError(
            try zeroExtentMapper.map(
                point: CoordinatePoint(x: 0.25, y: 0.75),
                from: .visionNormalized,
                to: .imageNormalized
            )
        ) { error in
            XCTAssertEqual(error as? CoordinateMapper.MappingError, .invalidImageExtent)
        }

        let nonFiniteMapper = mapper(
            orientation: .up,
            imageExtent: CGSize(width: CGFloat.nan, height: 200)
        )
        XCTAssertThrowsError(
            try nonFiniteMapper.map(
                point: CoordinatePoint(x: 0.25, y: 0.75),
                from: .visionNormalized,
                to: .imageNormalized
            )
        ) { error in
            XCTAssertEqual(error as? CoordinateMapper.MappingError, .invalidImageExtent)
        }
    }

    private func mapper(
        orientation: CGImagePropertyOrientation,
        inputMirrored: Bool = false,
        previewMirrored: Bool = false,
        imageExtent: CGSize = CGSize(width: 400, height: 200),
        previewExtent: CGSize = CGSize(width: 200, height: 100)
    ) -> CoordinateMapper {
        CoordinateMapper(
            metadata: BeautyInputMetadata(
                orientation: orientation,
                isInputMirrored: inputMirrored,
                isPreviewMirrored: previewMirrored,
                source: .testFixture
            ),
            imageExtent: imageExtent,
            previewExtent: previewExtent
        )
    }

    private func assertPoint(
        _ point: CoordinatePoint,
        equals expected: CoordinatePoint,
        accuracy: Double = 0.000_001,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(point.x, expected.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(point.y, expected.y, accuracy: accuracy, file: file, line: line)
    }

    private func assertRect(
        _ rect: CoordinateRect,
        equals expected: CoordinateRect,
        accuracy: Double = 0.000_001,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(rect.x, expected.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(rect.y, expected.y, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(rect.width, expected.width, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(rect.height, expected.height, accuracy: accuracy, file: file, line: line)
    }
}
