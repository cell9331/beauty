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

    func testInvalidEXIFOrientationFailsDecodingInsteadOfChangingToUp() throws {
        let valid = try JSONEncoder().encode(BeautyInputMetadata(
            orientation: .right,
            source: .photo
        ))
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: valid) as? [String: Any])
        object["orientation"] = 9
        let malformed = try JSONSerialization.data(withJSONObject: object)

        XCTAssertThrowsError(try JSONDecoder().decode(BeautyInputMetadata.self, from: malformed)) {
            error in
            guard case DecodingError.dataCorrupted(let context) = error else {
                return XCTFail("Expected a dataCorrupted orientation error")
            }
            XCTAssertEqual(context.codingPath.last?.stringValue, "orientation")
        }
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
