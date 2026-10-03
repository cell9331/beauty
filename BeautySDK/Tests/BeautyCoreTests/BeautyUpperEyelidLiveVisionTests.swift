import CoreGraphics
import CoreImage
import CryptoKit
import Foundation
import XCTest
@testable import BeautyCore
@testable import BeautyDetection
@testable import BeautyEffects
@testable import BeautySDK

// The frozen calibration produces visible color blocks around the upper lids.
// This qualifies a known programmatic luminance target through real Vision and
// the public facade; it does not qualify natural-portrait appearance or texture
// preservation. The original uncalibrated portrait is only an identity control.
final class BeautyUpperEyelidLiveVisionTests: XCTestCase {
    private final class Requests: @unchecked Sendable {
        var value: [BeautyUpperEyelidSemanticRequest] = []
    }
    private struct Dome {
        let centerX: Double
        let centerY: Double
        let radiusX: Double
        let radiusY: Double
        let target: CGRect
        let core: CGRect
        func radiusSquared(x: Int, y: Int) -> Double {
            pow((Double(x) + 0.5 - centerX) / radiusX, 2)
                + pow((Double(y) + 0.5 - centerY) / radiusY, 2)
        }
    }
    private struct Pair {
        let raw: BeautyCanonicalStillImage
        let negative: BeautyCanonicalStillImage
        let positive: BeautyCanonicalStillImage
        let shadow: BeautyCanonicalStillImage
        let domes: [Dome]
    }
    private enum FixtureError: Error {
        case invalidName, unreadable, symbolicLink, invalidResource, oversized
        case digestMismatch, undecodable, invalidGeometry, invalidSource
    }
    private let metadata = BeautyInputMetadata(orientation: .up, isInputMirrored: false,
        isPreviewMirrored: false, source: .testFixture)
    private let configuration = BeautyConfiguration(renderBackend: .cpu)

    func testAuthorizedCalibratedLuminancePairThroughLiveVisionAndPublicFacade() throws {
        guard ProcessInfo.processInfo.environment["BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS"] == "1" else {
            throw XCTSkip("upper_eyelid_live_vision_opt_in")
        }
        let pair = try makePair()
        try assertSourcePair(pair)
        // Independently authorized and source-registered flatter-lid control;
        // its negative role is not inferred from a previous owner rejection.
        let naturalNegative = try canonical(loadAuthorizedFixture(
            name: "upper-eyelid-negative-control.png",
            expectedDigest: "3e0b6a3bd824e22d99632bef861ac647191ff829af8c70ccd6e181e97c815856"))
        guard assertExact(try canonical(naturalNegative.ciImage).rgba8Data,
            naturalNegative.rgba8Data, "natural negative source round trip") else {
            throw FixtureError.invalidSource
        }
        let negative = pair.negative
        let positive = pair.positive
        let negativeCount = try admissionCount(negative, label: "flat")
        let positiveCount = try admissionCount(positive, label: "positive")
        let shadowCount = try admissionCount(pair.shadow, label: "shadow")
        let rawCount = try admissionCount(pair.raw, label: "raw")
        let naturalNegativeCount = try admissionCount(naturalNegative, label: "natural negative")
        XCTAssertEqual(negativeCount, 0, "predeclared flat admission")
        XCTAssertEqual(positiveCount, 2, "predeclared positive admission")
        XCTAssertEqual(shadowCount, 0, "predeclared shadow admission")
        XCTAssertEqual(rawCount, 0, "registered raw admission")
        XCTAssertEqual(naturalNegativeCount, 0, "registered natural negative admission")
        guard negativeCount == 0, positiveCount == 2, shadowCount == 0,
            rawCount == 0, naturalNegativeCount == 0 else {
            throw FixtureError.invalidSource
        }
        let engine = try BeautyEngine(configuration: configuration)
        let neutral = try engine.processResult(image: positive.ciImage, metadata: metadata,
            parameters: BeautyParameters())
        let neutralOutput = try assertOutputMetadata(neutral.output, source: positive, label: "neutral")
        assertExact(neutralOutput.rgba8Data, positive.rgba8Data, "neutral")
        var previous = positive.rgba8Data
        var previousTotal = 0
        for strength: Float in [0.25, 0.5, 0.75, 1] {
            let label = "strength=\(strength)"
            let result = try engine.processResult(image: positive.ciImage, metadata: metadata,
                parameters: BeautyParameters(upperEyelidFullnessReduction: strength))
            XCTAssertEqual(result.detectionSummary?.faceCount, 1, label)
            XCTAssertEqual(result.detectionSummary?.usedFaceCount, 1, label)
            let output = try assertOutputMetadata(result.output, source: positive, label: label)
            let repeated = try engine.processResult(image: positive.ciImage, metadata: metadata,
                parameters: BeautyParameters(upperEyelidFullnessReduction: strength))
            let repeatedOutput = try assertOutputMetadata(repeated.output, source: positive, label: "repeat \(label)")
            assertExact(repeatedOutput.rgba8Data, output.rgba8Data, "repeat \(label)")
            for (name, source) in [("flat", negative), ("shadow", pair.shadow), ("raw", pair.raw),
                ("natural negative", naturalNegative)] {
                let unchanged = try engine.processResult(image: source.ciImage, metadata: metadata,
                    parameters: BeautyParameters(upperEyelidFullnessReduction: strength))
                XCTAssertEqual(unchanged.detectionSummary?.faceCount, 1, "\(name) \(label)")
                XCTAssertEqual(unchanged.detectionSummary?.usedFaceCount, 1, "\(name) \(label)")
                let unchangedOutput = try assertOutputMetadata(unchanged.output, source: source, label: "\(name) \(label)")
                assertExact(unchangedOutput.rgba8Data, source.rgba8Data, "\(name) \(label)")
            }
            let repeatedNegative = try engine.processResult(image: naturalNegative.ciImage, metadata: metadata,
                parameters: BeautyParameters(upperEyelidFullnessReduction: strength))
            XCTAssertEqual(repeatedNegative.detectionSummary?.faceCount, 1, "natural negative repeat \(label)")
            XCTAssertEqual(repeatedNegative.detectionSummary?.usedFaceCount, 1, "natural negative repeat \(label)")
            let repeatedNegativeOutput = try assertOutputMetadata(repeatedNegative.output,
                source: naturalNegative, label: "natural negative repeat \(label)")
            // Whole RGBA identity includes alpha and makes both invocations exact.
            assertExact(repeatedNegativeOutput.rgba8Data, naturalNegative.rgba8Data,
                "natural negative repeat \(label)")
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
            previous = output.rgba8Data
            previousTotal = total
        }
    }

    private func makePair() throws -> Pair {
        let raw = try canonical(loadAuthorizedFixture())
        // Capture only the raw base's live-Vision geometry to construct sources.
        // Effect invocations above always run live Vision through BeautyEngine.
        let requests = Requests()
        var detector = VisionFaceDetector()
        let geometry = detector.detectWithUpperEyelidSupport(image: raw.ciImage,
            metadata: metadata, imageExtent: raw.ciImage.extent.size,
            configuration: configuration, semanticOwner: { input in
                requests.value = input
                return []
            })
        XCTAssertEqual(geometry.detectionSummary.faceCount, 1)
        XCTAssertEqual(geometry.detectionSummary.usedFaceCount, 1)
        XCTAssertEqual(requests.value.count, 2)
        guard geometry.detectionSummary.faceCount == 1,
            geometry.detectionSummary.usedFaceCount == 1, requests.value.count == 2 else {
            throw FixtureError.invalidGeometry
        }
        let domes = requests.value.map { request -> Dome in
            let e = request.permittedEnvelope
            let rect = CGRect(x: e.minX * Double(raw.width), y: e.minY * Double(raw.height),
                width: e.width * Double(raw.width), height: e.height * Double(raw.height))
            let gap = rect.height / 0.75
            let browBottom = rect.minY - gap * 0.20
            let eyeTop = rect.maxY + gap * 0.05
            let core = CGRect(x: rect.minX - rect.width * 0.10, y: browBottom + 2,
                width: rect.width * 1.20, height: eyeTop - browBottom - 4)
            let target = CGRect(x: rect.minX - rect.width * 0.20, y: browBottom + 1,
                width: rect.width * 1.40, height: eyeTop - browBottom - 2)
            return Dome(centerX: rect.midX, centerY: rect.midY, radiusX: rect.width * 0.45,
                radiusY: rect.height * 0.45, target: target, core: core)
        }
        let extent = CGRect(x: 0, y: 0, width: raw.width, height: raw.height)
        guard domes.allSatisfy({ dome in
            let ellipseBounds = CGRect(x: dome.centerX-dome.radiusX, y: dome.centerY-dome.radiusY,
                width: dome.radiusX*2, height: dome.radiusY*2)
            return !dome.target.isEmpty && extent.contains(dome.target)
                && !dome.core.isEmpty && dome.target.contains(dome.core)
                && dome.radiusX > 1 && dome.radiusY > 1 && dome.core.contains(ellipseBounds)
        }), !domes[0].target.intersects(domes[1].target) else {
            throw FixtureError.invalidGeometry
        }
        var calibrated = raw.rgba8Data
        for dome in domes {
            var representative: [(Int, Int)] = []
            for y in Int(dome.centerY-dome.radiusY)..<Int(dome.centerY+dome.radiusY) {
                for x in Int(dome.centerX-dome.radiusX)..<Int(dome.centerX+dome.radiusX) {
                    let o = (y*raw.width+x)*4
                    let l = Int(raw.rgba8Data[o])+Int(raw.rgba8Data[o+1])+Int(raw.rgba8Data[o+2])
                    representative.append((l, o))
                }
            }
            representative.sort { $0.0 == $1.0 ? $0.1 < $1.1 : $0.0 < $1.0 }
            let medianOffset = representative[representative.count/2].1
            let color = (0..<3).map { Double(raw.rgba8Data[medianOffset+$0]) }
            for y in Int(dome.target.minY)..<Int(ceil(dome.target.maxY)) {
                for x in Int(dome.target.minX)..<Int(ceil(dome.target.maxX)) {
                    let point = CGPoint(x: Double(x)+0.5, y: Double(y)+0.5)
                    guard dome.target.contains(point) else { continue }
                    let tx = min(1, min((point.x-dome.target.minX)/(dome.core.minX-dome.target.minX),
                        (dome.target.maxX-point.x)/(dome.target.maxX-dome.core.maxX)))
                    let ty = min(1, min((point.y-dome.target.minY)/(dome.core.minY-dome.target.minY),
                        (dome.target.maxY-point.y)/(dome.target.maxY-dome.core.maxY)))
                    let t = max(0, min(tx, ty))
                    let w = t*t*(3-2*t)
                    let o = (y*raw.width+x)*4
                    for c in 0..<3 {
                        calibrated[o+c] = UInt8((Double(raw.rgba8Data[o+c])*(1-w)+color[c]*w).rounded())
                    }
                }
            }
        }
        let negative = try BeautyCanonicalStillImage(rgba8Data: calibrated, width: raw.width,
            height: raw.height, rowBytes: raw.rowBytes, metadata: raw.metadata)
        var bytes = negative.rgba8Data
        var shadowBytes = negative.rgba8Data
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
                        let shadowValue = Int(negative.rgba8Data[offset+channel]) - increment
                        if value > 255 || shadowValue < 0 { clipping += 1 }
                        bytes[offset+channel] = UInt8(clamping: value)
                        shadowBytes[offset+channel] = UInt8(clamping: shadowValue)
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
        let shadow = try BeautyCanonicalStillImage(rgba8Data: shadowBytes, width: negative.width,
            height: negative.height, rowBytes: negative.rowBytes, metadata: negative.metadata)
        return Pair(raw: raw, negative: negative, positive: positive, shadow: shadow, domes: domes)
    }

    private func assertSourcePair(_ pair: Pair) throws {
        // Independent source oracle: P=N+D and shadow=N-D on an exactly flat K.
        // It never consumes the producer's residual fit, support weights or score.
        var valid = true
        for (name, source) in [("raw", pair.raw), ("flat", pair.negative),
            ("positive", pair.positive), ("shadow", pair.shadow)] {
            XCTAssertEqual(source.width, pair.raw.width, name)
            XCTAssertEqual(source.height, pair.raw.height, name)
            XCTAssertEqual(source.rowBytes, pair.raw.rowBytes, name)
            XCTAssertEqual(source.metadata, pair.raw.metadata, name)
            guard source.width == pair.raw.width, source.height == pair.raw.height,
                source.rowBytes == pair.raw.rowBytes, source.metadata == pair.raw.metadata else {
                throw FixtureError.invalidSource
            }
            let exact = assertExact(try canonical(source.ciImage).rgba8Data, source.rgba8Data,
                "source grid round trip \(name)")
            valid = valid && exact
        }
        var wrongDome = 0, wrongShadow = 0, changedExterior = 0
        var alphaChanges = 0, nonopaque = 0, clipped = 0, domeOutsideCore = 0
        for y in 0..<pair.raw.height {
            for x in 0..<pair.raw.width {
                let offset = (y * pair.raw.width + x) * 4
                let point = CGPoint(x: Double(x) + 0.5, y: Double(y) + 0.5)
                let withinCalibration = pair.domes.contains { $0.target.contains(point) }
                var expected = 0
                for dome in pair.domes {
                    let r2 = dome.radiusSquared(x: x, y: y)
                    guard r2 < 1 else { continue }
                    if !dome.core.contains(point) { domeOutsideCore += 1 }
                    expected += Int((30 * pow(1-r2, 2)).rounded())
                }
                for channel in 0..<3 {
                    let raw = Int(pair.raw.rgba8Data[offset+channel])
                    let baseline = Int(pair.negative.rgba8Data[offset+channel])
                    let positive = Int(pair.positive.rgba8Data[offset+channel])
                    let shadow = Int(pair.shadow.rgba8Data[offset+channel])
                    if positive-baseline != expected { wrongDome += 1 }
                    if baseline-shadow != expected { wrongShadow += 1 }
                    if !withinCalibration && baseline != raw { changedExterior += 1 }
                    if baseline+expected > 255 || baseline-expected < 0 { clipped += 1 }
                }
                let rawAlpha = pair.raw.rgba8Data[offset+3]
                if rawAlpha != 255 { nonopaque += 1 }
                for source in [pair.negative, pair.positive, pair.shadow] {
                    if source.rgba8Data[offset+3] != rawAlpha { alphaChanges += 1 }
                }
            }
        }
        XCTAssertEqual(wrongDome, 0, "independent absolute positive dome")
        XCTAssertEqual(wrongShadow, 0, "independent absolute shadow dome")
        XCTAssertEqual(changedExterior, 0, "calibration exterior remains raw-source exact")
        XCTAssertEqual(alphaChanges, 0, "source alpha unchanged")
        XCTAssertEqual(nonopaque, 0, "opaque source")
        XCTAssertEqual(clipped, 0, "unclipped source pair")
        XCTAssertEqual(domeOutsideCore, 0, "entire dome lies in constant core K")
        for dome in pair.domes {
            let centerOffset = (Int(dome.centerY)*pair.negative.width+Int(dome.centerX))*4
            var nonflat = 0
            for y in Int(dome.core.minY)..<Int(ceil(dome.core.maxY)) {
                for x in Int(dome.core.minX)..<Int(ceil(dome.core.maxX)) {
                    guard dome.core.contains(CGPoint(x: Double(x)+0.5, y: Double(y)+0.5)) else { continue }
                    let offset = (y*pair.negative.width+x)*4
                    for channel in 0..<3 {
                        if pair.negative.rgba8Data[offset+channel] != pair.negative.rgba8Data[centerOffset+channel] {
                            nonflat += 1
                        }
                    }
                }
            }
            XCTAssertEqual(nonflat, 0, "independent known constant baseline K")
            valid = valid && nonflat == 0
        }
        guard valid, wrongDome == 0, wrongShadow == 0, changedExterior == 0,
            alphaChanges == 0, nonopaque == 0, clipped == 0, domeOutsideCore == 0 else {
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
}
