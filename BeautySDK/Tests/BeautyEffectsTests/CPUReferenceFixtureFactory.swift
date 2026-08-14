import CoreGraphics
import CoreImage
import Foundation
import BeautyCore
import BeautyDetection
@testable import BeautyEffects

/// Target-local generated inputs for the mandatory CPU reference-oracle suite.
///
/// The factory deliberately returns byte arrays and support values rather than
/// writing an image fixture.  This keeps the evidence reproducible in a clean
/// clone and keeps raw pixels request-local to one test invocation.
struct CPUReferenceRGBA8Fixture: Equatable {
    enum Region: Hashable {
        case protected
        case outside
        case safe
    }

    let width: Int
    let height: Int
    let rgba8: [UInt8]
    let colorSpaceName: CFString
    let regions: [Region: Set<Int>]

    var rowBytes: Int { width * 4 }
    var byteCount: Int { rgba8.count }
    var extent: CGRect { CGRect(x: 0, y: 0, width: width, height: height) }
    var alphaValues: [UInt8] {
        stride(from: 3, to: rgba8.count, by: 4).map { rgba8[$0] }
    }
    var isOpaque: Bool { alphaValues.allSatisfy { $0 == 255 } }

    func indices(in region: Region) -> Set<Int> { regions[region, default: []] }
}

enum CPUReferenceSupportKind: Equatable {
    case complete
    case malformed
    case noFace
}

enum CPUReferenceFixtureFactory {
    static let width = 16
    static let height = 12

    static func softwareContext(colorSpace: CGColorSpace) -> CIContext {
        CIContext(options: [
            .useSoftwareRenderer: true,
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace,
        ])
    }

    static func opaqueColorRamp(width: Int = Self.width, height: Int = Self.height) -> CPUReferenceRGBA8Fixture {
        make(width: width, height: height) { x, y in
            return (
                UInt8((x * 19 + y * 7 + 17) % 256),
                UInt8((x * 5 + y * 23 + 43) % 256),
                UInt8((x * 29 + y * 11 + 71) % 256),
                255
            )
        }
    }

    static func checker(width: Int = Self.width, height: Int = Self.height) -> CPUReferenceRGBA8Fixture {
        make(width: width, height: height) { x, y in
            let bright = (x + y).isMultiple(of: 2)
            return bright ? (224, 196, 168, 255) : (36, 52, 84, 255)
        }
    }

    static func alphaBoundary(width: Int = 5, height: Int = 1) -> CPUReferenceRGBA8Fixture {
        let alphas: [UInt8] = [0, 1, 127, 254, 255]
        return make(width: width, height: height) { x, _ in
            let alpha = alphas[min(x, alphas.count - 1)]
            return (80, 120, 160, alpha)
        }
    }

    static func geometryPattern(width: Int = Self.width, height: Int = Self.height) -> CPUReferenceRGBA8Fixture {
        make(width: width, height: height) { x, y in
            let diagonal = (x * 13 + y * 17) % 256
            return (UInt8(diagonal), UInt8((diagonal + x * 3) % 256), UInt8((diagonal + y * 5) % 256), 255)
        }
    }

    static func protectedOutsidePattern(width: Int = Self.width, height: Int = Self.height) -> CPUReferenceRGBA8Fixture {
        var fixture = make(width: width, height: height) { x, y in
            let border = x == 0 || y == 0 || x == width - 1 || y == height - 1
            return border ? (9, 19, 29, 255) : (120, 100, 80, 255)
        }
        var protected = Set<Int>()
        var outside = Set<Int>()
        var safe = Set<Int>()
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                if x == 0 || y == 0 || x == width - 1 || y == height - 1 {
                    outside.insert(index)
                } else if x == width / 2 && y > 2 && y < height - 3 {
                    protected.insert(index)
                } else {
                    safe.insert(index)
                }
            }
        }
        fixture = CPUReferenceRGBA8Fixture(
            width: fixture.width,
            height: fixture.height,
            rgba8: fixture.rgba8,
            colorSpaceName: fixture.colorSpaceName,
            regions: [.protected: protected, .outside: outside, .safe: safe]
        )
        return fixture
    }

    static func support(_ kind: CPUReferenceSupportKind) -> FaceGeometry {
        switch kind {
        case .complete:
            return .phase46AsymmetricComplete
        case .malformed:
            return .phase48MalformedObservedContour
        case .noFace:
            return .missingContour
        }
    }

    private static func make(
        width: Int,
        height: Int,
        pixel: (Int, Int) -> (UInt8, UInt8, UInt8, UInt8)
    ) -> CPUReferenceRGBA8Fixture {
        precondition(width > 0 && height > 0)
        var bytes: [UInt8] = []
        bytes.reserveCapacity(width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let value = pixel(x, y)
                bytes.append(contentsOf: [value.0, value.1, value.2, value.3])
            }
        }
        return CPUReferenceRGBA8Fixture(
            width: width,
            height: height,
            rgba8: bytes,
            colorSpaceName: CGColorSpace.sRGB,
            regions: [:]
        )
    }
}
