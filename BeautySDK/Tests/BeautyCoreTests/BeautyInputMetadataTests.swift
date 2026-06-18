import ImageIO
import XCTest
import BeautySDK

final class BeautyInputMetadataTests: XCTestCase {
    func testPIPE05MetadataRoundTripsThroughCodable() throws {
        let metadata = BeautyInputMetadata(
            orientation: .right,
            isInputMirrored: false,
            isPreviewMirrored: true,
            source: .camera,
            timestamp: 1
        )

        let data = try JSONEncoder().encode(metadata)
        let decoded = try JSONDecoder().decode(BeautyInputMetadata.self, from: data)

        XCTAssertEqual(decoded, metadata)
        assertSendable(decoded)
    }

    func testPIPE05InputSourceContainsAllPublicCases() {
        XCTAssertEqual(BeautyInputSource.camera.rawValue, "camera")
        XCTAssertEqual(BeautyInputSource.photo.rawValue, "photo")
        XCTAssertEqual(BeautyInputSource.video.rawValue, "video")
        XCTAssertEqual(BeautyInputSource.export.rawValue, "export")
        XCTAssertEqual(BeautyInputSource.testFixture.rawValue, "testFixture")
    }

    private func assertSendable<T: Sendable>(_ value: T) {
        _ = value
    }
}
