import Foundation
import XCTest
@testable import BeautyEffects

/// Independent source geometry controls. The analytic dark-side bulge is
/// declared before any coarse carrier or gain; no private photo/mask is read.
final class WideJawlineShadowDenseEnvelopeTests: XCTestCase {
    private func sourcePhase(_ x: Double) -> Double {
        max(0, 3 * (1 - abs(x - 8) / 2))
    }
    private func envelope(gap: Bool = false) throws -> BeautyWideJawlineShadowTrial.DenseDarkSideEnvelope {
        var phases = (0...16).map { Optional(sourcePhase(Double($0))) }
        if gap { phases[8] = nil }
        return try XCTUnwrap(BeautyWideJawlineShadowTrial.DenseDarkSideEnvelope(start: 0, step: 1, phases: phases))
    }

    func testDenseDarkSideBulgeCannotBeCutByACompleteCoarseCarrierChord() throws {
        let dense = try envelope()
        // Both coarse endpoints have complete source support and zero phase;
        // their straight chord is nevertheless ABOVE the true source bulge.
        let left = try XCTUnwrap(dense.phase(2)), right = try XCTUnwrap(dense.phase(14))
        XCTAssertEqual(left, 0); XCTAssertEqual(right, 0)
        var coarseWouldAdmit = 0, independentlyUnsafeAdmitted = 0, safeAdmitted = 0
        for xi in 8...56 {
            let x = Double(xi) / 4, edge = 20 + 0.75 * x, ny = 0.8
            for yi in 1...24 {
                let y = edge + Double(yi) / 4
                let carrier = edge + left + (right - left) * (x - 2) / 12
                let independentSourceDarkSide = edge + sourcePhase(x) / ny
                let allowed = dense.contains(localX: x, localY: y, originalBoundaryY: edge, normalY: ny)
                if y > carrier && y <= independentSourceDarkSide { coarseWouldAdmit += 1 }
                if allowed && y <= independentSourceDarkSide { independentlyUnsafeAdmitted += 1 }
                if allowed && y > independentSourceDarkSide { safeAdmitted += 1 }
            }
        }
        XCTAssertGreaterThan(coarseWouldAdmit, 16, "the independent source witness must exercise the original chord gap")
        XCTAssertEqual(independentlyUnsafeAdmitted, 0)
        XCTAssertGreaterThan(safeAdmitted, 16, "the envelope cannot pass by rejecting every source position")
    }

    func testCompletePixelFootprintRejectsCrossingButKeepsFartherSourceSupport() throws {
        let dense = try envelope()
        for angle in [0.0, 0.37, -0.37] {
            let c = cos(angle), s = sin(angle)
            func completeFootprint(_ y: Double) -> Bool {
                guard dense.contains(localX: 8, localY: y, originalBoundaryY: 20, normalY: 1) else { return false }
                for dy in [-0.5, 0.5] { for dx in [-0.5, 0.5] {
                    let x = 8 + dx * c + dy * s, localY = y - dx * s + dy * c
                    if !dense.contains(localX: x, localY: localY, originalBoundaryY: 20, normalY: 1) { return false }
                } }
                return true
            }
            XCTAssertTrue(dense.contains(localX: 8, localY: 23.25, originalBoundaryY: 20, normalY: 1))
            XCTAssertFalse(completeFootprint(23.25), "centre-only permission must not admit a crossing pixel")
            XCTAssertTrue(completeFootprint(25), "a complete opaque source footprint beyond the bulge remains usable")
        }
    }

    func testMissingNativeColumnsAndMalformedGeometryFailClosed() throws {
        let dense = try envelope(gap: true)
        XCTAssertNotNil(dense.phase(2)); XCTAssertNotNil(dense.phase(14))
        for x in [6.0, 7.0, 8.0, 9.0] {
            XCTAssertFalse(dense.contains(localX: x, localY: 100, originalBoundaryY: 20, normalY: 1),
                "two valid carrier endpoints cannot bridge missing dense source support")
        }
        let complete = try envelope()
        XCTAssertFalse(complete.contains(localX: .nan, localY: 100, originalBoundaryY: 20, normalY: 1))
        XCTAssertFalse(complete.contains(localX: 8, localY: .infinity, originalBoundaryY: 20, normalY: 1))
        XCTAssertFalse(complete.contains(localX: 8, localY: 100, originalBoundaryY: nil, normalY: 1))
        XCTAssertFalse(complete.contains(localX: 8, localY: 100, originalBoundaryY: 20, normalY: 0.2))
        XCTAssertFalse(complete.contains(localX: 8, localY: 100, originalBoundaryY: 20, normalY: Double.nan))
        XCTAssertFalse(complete.contains(localX: Double.greatestFiniteMagnitude, localY: 100, originalBoundaryY: 20, normalY: 1))
        XCTAssertTrue(BeautyWideJawlineShadowTrial.DenseDarkSideEnvelope(start: 0, step: 0, phases: [0, 0, 0, 0]) == nil)
        XCTAssertTrue(BeautyWideJawlineShadowTrial.DenseDarkSideEnvelope(start: 0, step: 1, phases: [0, Double.nan, 0, 0]) == nil)
        XCTAssertTrue(BeautyWideJawlineShadowTrial.DenseDarkSideEnvelope(start: .infinity, step: 1, phases: [0, 0, 0, 0]) == nil)
        XCTAssertTrue(BeautyWideJawlineShadowTrial.DenseDarkSideEnvelope(start: 0, step: 1, phases: [0, 0, 0]) == nil)
    }
}
