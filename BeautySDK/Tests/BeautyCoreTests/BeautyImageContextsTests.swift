import CoreGraphics
import CoreImage
import Foundation
import XCTest

@testable import BeautyCore

final class BeautyImageContextsTests: XCTestCase {
    func testKnownProfilesReuseContextsAndUnknownProfileDoesNotGrowRegistry() throws {
        let sRGB = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let p3 = try XCTUnwrap(CGColorSpace(name: CGColorSpace.displayP3))
        XCTAssertTrue(BeautyImageContexts.context(for: sRGB) === BeautyImageContexts.context(for: sRGB))
        XCTAssertFalse(BeautyImageContexts.context(for: sRGB) === BeautyImageContexts.context(for: p3))
        let linear = try XCTUnwrap(CGColorSpace(name: CGColorSpace.linearSRGB))
        let first = BeautyImageContexts.context(for: linear)
        let second = BeautyImageContexts.context(for: linear)
        XCTAssertFalse(first === second)
    }
    func testConcurrentIndependentRasterRequestsKeepTheirOwnPixels() async {
        let checks = await withTaskGroup(of: Bool.self, returning: [Bool].self) { group in
            for i in 0..<8 {
                group.addTask {
                    let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
                    let source = [UInt8](repeating: UInt8(40 + i * 10), count: 12 * 12 * 4).enumerated().map {
                        $0.offset % 4 == 3 ? UInt8(255) : $0.element
                    }
                    let image = CIImage(
                        bitmapData: Data(source), bytesPerRow: 48, size: CGSize(width: 12, height: 12),
                        format: .RGBA8, colorSpace: sRGB)
                    var result = [UInt8](repeating: 0, count: source.count)
                    BeautyImageContexts.context(for: sRGB).render(
                        image, toBitmap: &result, rowBytes: 48, bounds: image.extent, format: .RGBA8,
                        colorSpace: sRGB)
                    return source == result
                }
            }
            var results = [Bool]()
            for await result in group { results.append(result) }
            return results
        }
        XCTAssertEqual(checks.count, 8)
        XCTAssertTrue(checks.allSatisfy { $0 })
    }
}
