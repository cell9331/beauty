import CryptoKit
import Foundation

enum MediaPipeModelResource {
    static let expectedByteCount = 3_758_596
    static let expectedSHA256 = "64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff"

    static func validate(_ data: Data) -> Bool {
        guard data.count == expectedByteCount else { return false }
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        return digest == expectedSHA256
    }

    static func verifiedURL() throws -> URL {
        guard let url = Bundle.module.url(forResource: "face_landmarker", withExtension: "task"),
              let bytes = try? Data(contentsOf: url), validate(bytes) else {
            throw BeautyFaceDetector.Failure.detectorUnavailable
        }
        return url
    }
}
