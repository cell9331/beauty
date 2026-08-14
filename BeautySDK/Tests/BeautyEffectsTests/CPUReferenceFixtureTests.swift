import XCTest
import CoreGraphics
@testable import BeautyEffects

final class CPUReferenceFixtureTests: XCTestCase {
    func testGeneratedFixturesAreFiniteOpaqueNamedSRGBAndDimensionConsistent() {
        let fixtures = [
            CPUReferenceFixtureFactory.opaqueColorRamp(),
            CPUReferenceFixtureFactory.checker(),
            CPUReferenceFixtureFactory.geometryPattern(),
            CPUReferenceFixtureFactory.protectedOutsidePattern()
        ]

        for fixture in fixtures {
            XCTAssertGreaterThan(fixture.width, 0)
            XCTAssertGreaterThan(fixture.height, 0)
            XCTAssertEqual(fixture.rgba8.count, fixture.width * fixture.height * 4)
            XCTAssertEqual(fixture.rowBytes, fixture.width * 4)
            XCTAssertEqual(fixture.colorSpaceName, CGColorSpace.sRGB)
            XCTAssertTrue(fixture.isOpaque)
            XCTAssertTrue(fixture.rgba8.allSatisfy { $0 <= 255 })
        }
    }

    func testAlphaBoundaryContainsRequiredInMemoryValuesWithoutMediaLoading() {
        let fixture = CPUReferenceFixtureFactory.alphaBoundary()
        XCTAssertEqual(fixture.alphaValues, [0, 1, 127, 254, 255])
        XCTAssertEqual(fixture.rgba8.count, fixture.width * fixture.height * 4)
        XCTAssertEqual(fixture.colorSpaceName, CGColorSpace.sRGB)
        XCTAssertFalse(fixture.isOpaque)
    }

    func testGeometryAndProtectedRegionFixturesExposeAggregateLabelsOnly() {
        let geometry = CPUReferenceFixtureFactory.geometryPattern()
        let protected = CPUReferenceFixtureFactory.protectedOutsidePattern()
        XCTAssertGreaterThan(CPUReferenceMetrics.meanLuminance(of: geometry.rgba8), 0)
        XCTAssertFalse(protected.indices(in: .protected).isEmpty)
        XCTAssertFalse(protected.indices(in: .outside).isEmpty)
        XCTAssertFalse(protected.indices(in: .safe).isEmpty)
        XCTAssertTrue(CPUReferenceMetrics.regionIntersection(
            protected.indices(in: .protected), protected.indices(in: .outside)
        ).isEmpty)
    }

    func testSupportStubsAreDeterministicAndBounded() {
        let first = CPUReferenceFixtureFactory.support(.complete)
        let second = CPUReferenceFixtureFactory.support(.complete)
        XCTAssertEqual(first, second)
        XCTAssertTrue(first.faceContour.allSatisfy(CPUReferenceMetrics.isFiniteNormalized))
        XCTAssertTrue(CPUReferenceFixtureFactory.support(.malformed).observedFaceSupport != nil)
        XCTAssertTrue(CPUReferenceFixtureFactory.support(.noFace).faceContour.isEmpty)
    }

    func testRepeatedConstructionHasIdenticalBytesAndMetrics() throws {
        let first = CPUReferenceFixtureFactory.opaqueColorRamp()
        let second = CPUReferenceFixtureFactory.opaqueColorRamp()
        XCTAssertEqual(first, second)
        XCTAssertTrue(try CPUReferenceMetrics.changedIndices(before: first.rgba8, after: second.rgba8).isEmpty)
        XCTAssertEqual(
            CPUReferenceMetrics.meanLuminance(of: first.rgba8),
            CPUReferenceMetrics.meanLuminance(of: second.rgba8),
            accuracy: 0.000_001
        )
    }

    func testMetricsRejectMalformedRGBA8CarriersWithoutIndexingPastInput() {
        XCTAssertThrowsError(try CPUReferenceMetrics.changedIndices(before: [1, 2, 3], after: [1, 2, 4])) { error in
            XCTAssertEqual(error as? CPUReferenceMetrics.Error, .malformedRGBA8ByteCount)
        }
        XCTAssertThrowsError(try CPUReferenceMetrics.changedIndices(before: [1], after: [1, 2])) { error in
            XCTAssertEqual(error as? CPUReferenceMetrics.Error, .mismatchedByteCount)
        }
    }

    func testGeneratedPatternsExposeStableMetricAndRegionContracts() {
        let ramp = CPUReferenceFixtureFactory.opaqueColorRamp(width: 8, height: 8)
        let checker = CPUReferenceFixtureFactory.checker(width: 8, height: 8)
        XCTAssertNotEqual(
            CPUReferenceMetrics.meanLuminance(of: ramp.rgba8),
            CPUReferenceMetrics.meanLuminance(of: checker.rgba8)
        )
        XCTAssertTrue(CPUReferenceMetrics.alphaValues(in: ramp.rgba8).allSatisfy { $0 == 255 })
        XCTAssertTrue(CPUReferenceMetrics.alphaValues(in: checker.rgba8).allSatisfy { $0 == 255 })
        XCTAssertEqual(ramp.width * ramp.height, checker.width * checker.height)
        XCTAssertEqual(ramp.extent, CGRect(x: 0, y: 0, width: 8, height: 8))
        XCTAssertEqual(checker.extent, ramp.extent)
        XCTAssertEqual(ramp.byteCount, ramp.rowBytes * ramp.height)
        XCTAssertEqual(checker.byteCount, checker.rowBytes * checker.height)
    }

    func testProtectedOutsideFixtureHasCompleteDisjointRegionPartition() {
        let fixture = CPUReferenceFixtureFactory.protectedOutsidePattern(width: 10, height: 8)
        let allPixels = Set(0..<(fixture.width * fixture.height))
        let protected = fixture.indices(in: .protected)
        let outside = fixture.indices(in: .outside)
        let safe = fixture.indices(in: .safe)

        XCTAssertEqual(protected.union(outside).union(safe), allPixels)
        XCTAssertTrue(protected.isDisjoint(with: outside))
        XCTAssertTrue(protected.isDisjoint(with: safe))
        XCTAssertTrue(outside.isDisjoint(with: safe))
        XCTAssertEqual(fixture.colorSpaceName, CGColorSpace.sRGB)
        XCTAssertTrue(fixture.isOpaque)
    }

    func testSupportFixturesCoverCompleteMalformedAndNoFaceBoundaries() {
        let complete = CPUReferenceFixtureFactory.support(.complete)
        let malformed = CPUReferenceFixtureFactory.support(.malformed)
        let noFace = CPUReferenceFixtureFactory.support(.noFace)

        XCTAssertFalse(complete.faceContour.isEmpty)
        XCTAssertNotNil(complete.observedFaceSupport)
        XCTAssertFalse(malformed.faceContour.isEmpty)
        XCTAssertNotNil(malformed.observedFaceSupport)
        XCTAssertTrue(noFace.faceContour.isEmpty)
        XCTAssertNil(noFace.observedFaceSupport)
    }
}
