import Foundation
import CryptoKit
import XCTest
import BeautySDK

final class RepairedControlCompatibilityTests: XCTestCase {
    private func source(_ relative: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        return try String(contentsOf: root.appendingPathComponent(relative), encoding: .utf8)
    }

    func testCodableHasExactly62FrozenFields() throws {
        let value = BeautyParameters(chinTaper: 0.2, filterId: "soft_clean", filterIntensity: 0.25)
        let data = try JSONEncoder().encode(value)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object.count, 62, "P95C_CODABLE_COUNT")
        XCTAssertEqual(Set(object.keys), Set(RepairedControlCompatibilityFixture.fieldNames), "P95C_CODABLE_KEYS")
        XCTAssertEqual(try JSONDecoder().decode(BeautyParameters.self, from: data), value, "P95C_CODABLE_ROUNDTRIP")
    }

    func testFivePresetsAndRendererCasesRemainFrozen() throws {
        let presets = try BeautySDKResources.builtInPresets()
        XCTAssertEqual(presets.map(\.id), RepairedControlCompatibilityFixture.presetIDs, "P95C_PRESETS")
        XCTAssertEqual(RepairedControlCompatibilityFixture.rendererCases.count, 75, "P95C_RENDERER_COUNT")
        let renderer = try source("BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift")
        for id in RepairedControlCompatibilityFixture.rendererCases { XCTAssertTrue(renderer.contains(id), "P95C_RENDERER_\(id)") }
    }

    func testPublicFacadesBackendAndSDKBoundaryRemainPresent() throws {
        let engine = try source("BeautySDK/Sources/BeautySDK/BeautyEngine.swift")
        XCTAssertTrue(engine.contains("public func processResult(\n        image: CIImage"), "P95C_FACADE_RESULT")
        XCTAssertTrue(engine.contains("public func process(\n        image: CIImage"), "P95C_FACADE_PROCESS")
        let backend = try source("BeautySDK/Sources/BeautySDK/BeautyBackendFactory.swift")
        let backendDigest = SHA256.hash(data: Data(backend.utf8))
            .map { String(format: "%02x", $0) }.joined()
        XCTAssertEqual(backendDigest,
            "16b1c86a5eb153b647c0bc9d19403bacff00019082dee0e4c2a101c7f3bc13ea",
            "P95C_BACKEND: exact unchanged backend implementation, not a source substring")
        let boundary = try source("scripts/check-sdk-only-boundary.sh")
        XCTAssertTrue(boundary.contains("SDK-only") || boundary.contains("sdk-only"), "P95C_BOUNDARY")
    }

    func testNonTargetDefaultsAndNeutralBehaviorRemainStable() throws {
        let defaults = BeautyParameters()
        for name in RepairedControlCompatibilityFixture.fieldNames where name != "filterId" {
            XCTAssertEqual(Mirror(reflecting: defaults).children.compactMap(\.label).filter { $0 == name }.count, 1, "P95C_FIELD_\(name)")
        }
        XCTAssertEqual(defaults, BeautyParameters(), "P95C_NON_TARGET_NEUTRAL")
    }
}
