import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects
@testable import BeautySDK

// Temporary fixed challenge: retain the entire authorized natural background.
// N is the original image; P differs only by the predeclared +30 quartic dome.
// Passing qualifies the added image-space luminance signal, not tissue volume
// or general natural-portrait/texture quality. Do not calibrate this source.
final class BeautyUpperEyelidNaturalChallengeTests: XCTestCase {
    private final class Requests: @unchecked Sendable {
        var value: [BeautyUpperEyelidSemanticRequest] = []
    }
    private struct Dome {
        let centerX: Double
        let centerY: Double
        let radiusX: Double
        let radiusY: Double
        let target: CGRect
        func radiusSquared(x: Int, y: Int) -> Double {
            pow((Double(x) + 0.5 - centerX) / radiusX, 2)
                + pow((Double(y) + 0.5 - centerY) / radiusY, 2)
        }
    }
    private struct Pair {
        let negative: BeautyCanonicalStillImage
        let positive: BeautyCanonicalStillImage
        let domes: [Dome]
    }
    private enum FixtureError: Error {
        case invalidName, unreadable, symbolicLink, invalidResource, oversized
        case digestMismatch, undecodable, invalidGeometry, invalidSource, invalidOutputDirectory
    }
    private let metadata = BeautyInputMetadata(orientation: .up, isInputMirrored: false,
        isPreviewMirrored: false, source: .testFixture)
    private let configuration = BeautyConfiguration()
    private let strengths: [Float] = [0.25, 0.5, 0.75, 1]

    func testFrozenNaturalBackgroundDome() throws {
        try requireOptIn()
        let pair = try makePair()
        try assertSourcePair(pair)
        try assertOracleReference(pair)
        // Independently authorized, previously registered flatter-lid control.
        // Its negative role is source-defined, not inferred from past rejection.
        let negativeControl = try canonical(loadAuthorizedFixture(
            name: "upper-eyelid-negative-control.png",
            expectedDigest: "3e0b6a3bd824e22d99632bef861ac647191ff829af8c70ccd6e181e97c815856"))
        try export(pair.negative, name: "negative")
        try export(pair.positive, name: "positive")
        let negativeCount = try admissionCount(pair.negative, label: "raw negative")
        let controlCount = try admissionCount(negativeControl, label: "registered natural negative")
        let positiveCount = try admissionCount(pair.positive, label: "raw plus dome positive")
        XCTAssertEqual(negativeCount, 0, "predeclared natural negative admission")
        XCTAssertEqual(controlCount, 0, "registered natural negative admission")
        XCTAssertEqual(positiveCount, 2, "predeclared natural positive admission")
        guard negativeCount == 0, controlCount == 0, positiveCount == 2 else {
            throw FixtureError.invalidSource
        }
        let engine = try BeautyEngine(configuration: configuration)
        let neutral = try engine.processResult(image: pair.positive.ciImage, metadata: metadata,
            parameters: BeautyParameters())
        let neutralOutput = try assertOutputMetadata(neutral.output, source: pair.positive, label: "neutral")
        assertExact(neutralOutput.rgba8Data, pair.positive.rgba8Data, "neutral")
        var previous = pair.positive.rgba8Data
        var previousTotal = 0
        for strength in strengths {
            let label = "actual strength=\(strength)"
            let result = try engine.processResult(image: pair.positive.ciImage, metadata: metadata,
                parameters: BeautyParameters(upperEyelidFullnessReduction: strength))
            XCTAssertEqual(result.detectionSummary?.faceCount, 1, label)
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1, label)
            let output = try assertOutputMetadata(result.output, source: pair.positive, label: label)
            let repeated = try engine.processResult(image: pair.positive.ciImage, metadata: metadata,
                parameters: BeautyParameters(upperEyelidFullnessReduction: strength))
            let repeatedOutput = try assertOutputMetadata(repeated.output, source: pair.positive, label: "repeat \(label)")
            assertExact(repeatedOutput.rgba8Data, output.rgba8Data, "repeat \(label)")
            for (name, negative) in [("raw negative", pair.negative), ("registered natural negative", negativeControl)] {
                let unchanged = try engine.processResult(image: negative.ciImage, metadata: metadata,
                    parameters: BeautyParameters(upperEyelidFullnessReduction: strength))
                XCTAssertEqual(unchanged.detectionSummary?.faceCount, 1, "\(name) \(label)")
                XCTAssertEqual(unchanged.detectionSummary?.usedFaceCount, 1, "\(name) \(label)")
                let unchangedOutput = try assertOutputMetadata(unchanged.output, source: negative, label: "\(name) \(label)")
                assertExact(unchangedOutput.rgba8Data, negative.rgba8Data, "\(name) \(label)")
            }
            previousTotal = assertEffect(output, pair: pair, strength: strength, previous: previous,
                previousTotal: previousTotal, label: label)
            previous = output.rgba8Data
            try export(output, name: "output-\(Int(strength * 100))")
        }
    }

    func testSourceAdmission() throws {
        try requireOptIn()
        let pair = try makePair()
        try assertSourcePair(pair)
        for (name, image) in [("negative", pair.negative), ("positive", pair.positive)] {
            let requests = Requests()
            var detector = VisionFaceDetector()
            _ = detector.detectWithUpperEyelidSupport(image: image.ciImage, metadata: metadata,
                imageExtent: image.ciImage.extent.size, configuration: configuration,
                semanticOwner: { input in requests.value = input; return [] })
            XCTAssertEqual(requests.value.count, 2, name)
            guard requests.value.count == 2 else { throw FixtureError.invalidGeometry }
            for (eye, request) in requests.value.enumerated() {
                let model = try XCTUnwrap(BeautyExperimentalUpperEyelidReliefModel.analyze(
                    source: image, pixels: request.maximumFeatheredPixels()))
                print("NATURAL_LID_ADMISSION source=\(name) eye=\(eye) central=\(model.centralConvexityScore) localized=\(model.localizedConvexityScore) fraction=\(model.localizedPositiveFraction) admitted=\(model.isFullnessSupported)")
            }
        }
    }

    private func requireOptIn() throws {
        guard ProcessInfo.processInfo.environment["BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS"] == "1" else {
            throw XCTSkip("upper_eyelid_natural_challenge_opt_in")
        }
    }

    private func assertOracleReference(_ pair: Pair) throws {
        // Independent constructive witness that the frozen oracle is feasible.
        // This never replaces the subsequent production admission/effect gate.
        var previous = pair.positive.rgba8Data
        var previousTotal = 0
        for strength in strengths {
            var bytes = pair.negative.rgba8Data
            for offset in stride(from: 0, to: bytes.count, by: 4) {
                for channel in 0..<3 {
                    let baseline = Int(pair.negative.rgba8Data[offset+channel])
                    let signal = Int(pair.positive.rgba8Data[offset+channel])-baseline
                    bytes[offset+channel] = UInt8(baseline + Int(((1-0.4*Double(strength))*Double(signal)).rounded()))
                }
            }
            let reference = try BeautyCanonicalStillImage(rgba8Data: bytes, width: pair.negative.width,
                height: pair.negative.height, rowBytes: pair.negative.rowBytes, metadata: pair.negative.metadata)
            previousTotal = assertEffect(reference, pair: pair, strength: strength, previous: previous,
                previousTotal: previousTotal, label: "oracle witness strength=\(strength)")
            previous = bytes
        }
    }

    @discardableResult
    private func assertEffect(_ output: BeautyCanonicalStillImage, pair: Pair, strength: Float,
        previous: Data, previousTotal: Int, label: String) -> Int {
        let positive = pair.positive
        let negative = pair.negative
        var exterior = 0, alpha = 0, chromaChanges = 0, maximumDelta = 0, minimumResidual = 0
        var overshoot = 0, strengthReversal = 0, total = 0
        for y in 0..<positive.height {
            for x in 0..<positive.width {
                let p = y * positive.width + x
                let offset = p * 4
                let target = pair.domes.contains { $0.target.contains(CGPoint(x: Double(x)+0.5, y: Double(y)+0.5)) }
                if output.rgba8Data[offset + 3] != positive.rgba8Data[offset + 3] { alpha += 1 }
                let redDelta = Int(output.rgba8Data[offset])-Int(positive.rgba8Data[offset])
                for c in 0..<3 {
                    let original = Int(positive.rgba8Data[offset+c])
                    let baseline = Int(negative.rgba8Data[offset+c])
                    let edited = Int(output.rgba8Data[offset+c])
                    let delta = edited-original
                    if delta != redDelta { chromaChanges += 1 }
                    total += abs(delta)
                    maximumDelta = max(maximumDelta, abs(delta))
                    strengthReversal = max(strengthReversal, edited-Int(previous[offset+c]))
                    if !target && delta != 0 { exterior += 1 }
                    minimumResidual = min(minimumResidual, edited-baseline)
                    overshoot = max(overshoot, edited-original)
                }
            }
        }
        XCTAssertEqual(exterior, 0, label)
        XCTAssertEqual(alpha, 0, label)
        XCTAssertEqual(chromaChanges, 0, "equal RGB correction \(label)")
        XCTAssertLessThanOrEqual(maximumDelta, 16, label)
        XCTAssertGreaterThanOrEqual(minimumResidual, -1, label)
        XCTAssertLessThanOrEqual(overshoot, 1, label)
        XCTAssertEqual(strengthReversal, 0, label)
        XCTAssertGreaterThan(total, previousTotal, label)
        for (eye, dome) in pair.domes.enumerated() {
            var centerSource = 0.0, centerOutput = 0.0
            var changed = 0
            var sums = Array(repeating: Array(repeating: 0.0, count: 10), count: 4)
            var counts = Array(repeating: Array(repeating: 0, count: 10), count: 4)
            for y in Int(dome.target.minY)..<Int(dome.target.maxY) {
                for x in Int(dome.target.minX)..<Int(dome.target.maxX) {
                    let offset = (y * positive.width + x) * 4
                    let sourceSignal = Double(Int(positive.rgba8Data[offset])-Int(negative.rgba8Data[offset]))
                    let outputSignal = Double(Int(output.rgba8Data[offset])-Int(negative.rgba8Data[offset]))
                    if output.rgba8Data[offset] != positive.rgba8Data[offset] { changed += 1 }
                    if sourceSignal >= 20 {
                        centerSource += sourceSignal
                        centerOutput += outputSignal
                    }
                    let r2 = dome.radiusSquared(x: x, y: y)
                    guard r2 < 1 else { continue }
                    let sector = (Double(x)+0.5 < dome.centerX ? 0 : 1) + (Double(y)+0.5 < dome.centerY ? 0 : 2)
                    let bin = min(9, Int(sqrt(r2) * 10))
                    sums[sector][bin] += outputSignal
                    counts[sector][bin] += 1
                }
            }
            XCTAssertGreaterThan(centerSource, 0, "source center \(eye)")
            XCTAssertGreaterThanOrEqual(changed, 100, "\(label) eye=\(eye)")
            XCTAssertGreaterThanOrEqual((centerSource-centerOutput)/centerSource,
                0.20 * Double(strength), "\(label) eye=\(eye)")
            var rise = 0.0
            for sector in 0..<4 {
                for bin in 1..<10 where counts[sector][bin-1] > 0 && counts[sector][bin] > 0 {
                    rise = max(rise, sums[sector][bin]/Double(counts[sector][bin])
                        - sums[sector][bin-1]/Double(counts[sector][bin-1]))
                }
            }
            XCTAssertLessThanOrEqual(rise, 1, "\(label) eye=\(eye)")
        }
        return total
    }

    private func makePair() throws -> Pair {
        let negative = try canonical(loadAuthorizedFixture())
        let requests = Requests()
        var detector = VisionFaceDetector()
        let geometry = detector.detectWithUpperEyelidSupport(image: negative.ciImage,
            metadata: metadata, imageExtent: negative.ciImage.extent.size,
            configuration: configuration, semanticOwner: { input in requests.value = input; return [] })
        XCTAssertEqual(geometry.detectionSummary.faceCount, 1)
        XCTAssertEqual(geometry.detectionSummary.usedFaceCount, 1)
        XCTAssertEqual(requests.value.count, 2)
        guard geometry.detectionSummary.faceCount == 1,
            geometry.detectionSummary.usedFaceCount == 1, requests.value.count == 2 else {
            throw FixtureError.invalidGeometry
        }
        let domes = requests.value.map { request -> Dome in
            let e = request.permittedEnvelope
            let rect = CGRect(x: e.minX * Double(negative.width), y: e.minY * Double(negative.height),
                width: e.width * Double(negative.width), height: e.height * Double(negative.height))
            return Dome(centerX: rect.midX, centerY: rect.midY, radiusX: rect.width * 0.45,
                radiusY: rect.height * 0.45, target: rect.insetBy(dx: -2, dy: -2))
        }
        let extent = CGRect(x: 0, y: 0, width: negative.width, height: negative.height)
        guard domes.allSatisfy({ dome in
            !dome.target.isEmpty && extent.contains(dome.target) && dome.radiusX > 1 && dome.radiusY > 1
        }), !domes[0].target.intersects(domes[1].target) else { throw FixtureError.invalidGeometry }
        var bytes = negative.rgba8Data
        var changed = [0, 0], centers = [0, 0], clipping = 0
        for y in 0..<negative.height {
            for x in 0..<negative.width {
                for (eye, dome) in domes.enumerated() {
                    let r2 = dome.radiusSquared(x: x, y: y)
                    guard r2 < 1 else { continue }
                    let increment = Int((30 * pow(1-r2, 2)).rounded())
                    if increment > 0 { changed[eye] += 1 }
                    if increment >= 20 { centers[eye] += 1 }
                    let offset = (y * negative.width + x) * 4
                    for channel in 0..<3 {
                        let value = Int(negative.rgba8Data[offset+channel]) + increment
                        if value > 255 { clipping += 1 }
                        bytes[offset+channel] = UInt8(clamping: value)
                    }
                }
            }
        }
        XCTAssertEqual(clipping, 0)
        XCTAssertTrue(changed.allSatisfy { $0 >= 100 })
        XCTAssertTrue(centers.allSatisfy { $0 >= 20 })
        guard clipping == 0, changed.allSatisfy({ $0 >= 100 }), centers.allSatisfy({ $0 >= 20 }) else {
            throw FixtureError.invalidSource
        }
        let positive = try BeautyCanonicalStillImage(rgba8Data: bytes, width: negative.width,
            height: negative.height, rowBytes: negative.rowBytes, metadata: negative.metadata)
        return Pair(negative: negative, positive: positive, domes: domes)
    }

    private func assertSourcePair(_ pair: Pair) throws {
        var valid = true
        for (name, source) in [("negative", pair.negative), ("positive", pair.positive)] {
            valid = assertExact(try canonical(source.ciImage).rgba8Data, source.rgba8Data,
                "source round trip \(name)") && valid
        }
        var wrongDome = 0, alphaChanges = 0, nonopaque = 0, clipping = 0
        for y in 0..<pair.negative.height {
            for x in 0..<pair.negative.width {
                let offset = (y*pair.negative.width+x)*4
                let expected = pair.domes.reduce(0) { result, dome in
                    let r2 = dome.radiusSquared(x: x, y: y)
                    return result + (r2 < 1 ? Int((30 * pow(1-r2, 2)).rounded()) : 0)
                }
                for channel in 0..<3 {
                    let baseline = Int(pair.negative.rgba8Data[offset+channel])
                    if Int(pair.positive.rgba8Data[offset+channel])-baseline != expected { wrongDome += 1 }
                    if baseline+expected > 255 { clipping += 1 }
                }
                if pair.positive.rgba8Data[offset+3] != pair.negative.rgba8Data[offset+3] { alphaChanges += 1 }
                if pair.negative.rgba8Data[offset+3] != 255 { nonopaque += 1 }
            }
        }
        XCTAssertEqual(wrongDome, 0, "P-N is exactly the predeclared dome everywhere")
        XCTAssertEqual(alphaChanges, 0)
        XCTAssertEqual(nonopaque, 0)
        XCTAssertEqual(clipping, 0)
        guard valid, wrongDome == 0, alphaChanges == 0, nonopaque == 0, clipping == 0 else {
            throw FixtureError.invalidSource
        }
    }

    private func assertOutputMetadata(
        _ image: CIImage, source: BeautyCanonicalStillImage, label: String
    ) throws -> BeautyCanonicalStillImage {
        // Inspect the returned image before canonicalization can normalize it.
        XCTAssertEqual(image.extent, source.ciImage.extent, label)
        XCTAssertEqual(image.colorSpace?.name, CGColorSpace.sRGB, label)
        let output = try canonical(image)
        XCTAssertEqual(output.width, source.width, label)
        XCTAssertEqual(output.height, source.height, label)
        XCTAssertEqual(output.rowBytes, source.rowBytes, label)
        return output
    }

    private func loadAuthorizedFixture(
        name selectedName: String? = nil,
        expectedDigest: String = "fabc4bac1fe5c71ac4adaef225501c847a913a3144ef8ce31003c6a4fded1f7b"
    ) throws -> CIImage {
        let name = selectedName ?? ProcessInfo.processInfo.environment["BEAUTYSDK_UPPER_EYELID_FIXTURE"]
            ?? "upper-eyelid-generated-base.png"
        guard name.count > 4, name.hasSuffix(".png"),
            !name.contains("/"), !name.contains("\\"),
            !name.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else {
            throw FixtureError.invalidName
        }
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let fixture = root.appendingPathComponent("example-images/input/portraits", isDirectory: true)
            .appendingPathComponent(name).standardizedFileURL
        let maximumBytes = 16 * 1_024 * 1_024
        let data: Data
        do {
            // Check every parent as well as the file; a basename cannot bypass
            // the ignored local directory through a symbolic-link ancestor.
            var current = fixture
            while current.path != "/" {
                let values = try current.resourceValues(forKeys: [.isSymbolicLinkKey])
                guard values.isSymbolicLink == false else { throw FixtureError.symbolicLink }
                current.deleteLastPathComponent()
            }
            let values = try fixture.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
            guard values.isRegularFile == true, let size = values.fileSize, size > 0 else {
                throw FixtureError.invalidResource
            }
            guard size <= maximumBytes else { throw FixtureError.oversized }
            let handle = try FileHandle(forReadingFrom: fixture)
            defer { try? handle.close() }
            data = try handle.read(upToCount: maximumBytes + 1) ?? Data()
            guard data.count <= maximumBytes else { throw FixtureError.oversized }
            guard data.count == size else { throw FixtureError.invalidResource }
        } catch let error as FixtureError {
            throw error
        } catch {
            // Foundation errors can contain the owner's private input locator.
            throw FixtureError.unreadable
        }
        let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        guard digest == expectedDigest else {
            throw FixtureError.digestMismatch
        }
        guard let image = CIImage(data: data) else { throw FixtureError.undecodable }
        return image
    }

    private func canonical(_ image: CIImage) throws -> BeautyCanonicalStillImage {
        try BeautyStillImageCanonicalizer().canonicalize(image: image, metadata: metadata,
            maximumPixelCount: 4_000_000)
    }
    private func admissionCount(_ source: BeautyCanonicalStillImage, label: String) throws -> Int {
        let requests = Requests()
        let actualOwner = BeautyExperimentalUpperEyelidFullnessSemanticAnalyzer.makeOwner(source: source)
        var detector = VisionFaceDetector()
        let result = detector.detectWithUpperEyelidSupport(image: source.ciImage,
            metadata: metadata, imageExtent: source.ciImage.extent.size, configuration: configuration,
            semanticOwner: { input in
                requests.value = input
                return actualOwner(input)
            })
        // Zero semantic support is a valid negative only after live Vision has
        // supplied both eye requests for the selected face.
        XCTAssertEqual(result.detectionSummary.faceCount, 1, label)
        XCTAssertEqual(result.detectionSummary.usedFaceCount, 1, label)
        XCTAssertEqual(requests.value.count, 2, label)
        guard result.detectionSummary.faceCount == 1,
            result.detectionSummary.usedFaceCount == 1, requests.value.count == 2 else {
            throw FixtureError.invalidGeometry
        }
        return result.supportResolution.supportedEyeCount
    }
    @discardableResult
    private func assertExact(_ actual: Data, _ expected: Data, _ label: String) -> Bool {
        XCTAssertEqual(actual.count, expected.count, label)
        let count = zip(actual, expected).reduce(0) { $0 + ($1.0 == $1.1 ? 0 : 1) }
        XCTAssertEqual(count, 0, label)
        return actual.count == expected.count && count == 0
    }
    private func export(_ source: BeautyCanonicalStillImage, name: String) throws {
        guard let directory = ProcessInfo.processInfo.environment["NATURAL_LID_OUTPUT"] else { return }
        let root = URL(fileURLWithPath: directory, isDirectory: true).standardizedFileURL
        guard root.path.hasPrefix("/private/tmp/"), root.resolvingSymlinksInPath().path == root.path else {
            throw FixtureError.invalidOutputDirectory
        }
        do {
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            let output = root.appendingPathComponent(name + ".png")
            guard root.resolvingSymlinksInPath().path == root.path,
                output.resolvingSymlinksInPath().path == output.path else {
                throw FixtureError.invalidOutputDirectory
            }
            let space = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
            try CIContext().writePNGRepresentation(of: source.ciImage,
                to: output, format: .RGBA8, colorSpace: space)
        } catch {
            throw FixtureError.invalidOutputDirectory
        }
    }
}
