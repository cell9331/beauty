#if BEAUTY_OWNER_MOUTH_CHECK && targetEnvironment(simulator)
import BeautySDK
import CoreGraphics
import Foundation
import XCTest
@testable import BeautyEditor

/// Owner inputs are staged outside the checkout. Pixels and landmarks stay in
/// memory or task-owned temporary review output; only aggregate receipts persist.
@MainActor final class MouthPortraitAcceptanceTests: XCTestCase {
    func testFirstPortraitMouthEndpointsDirectionsAndProtection() async throws { try await evaluate("a") }
    func testSecondPortraitMouthEndpointsDirectionsAndProtection() async throws { try await evaluate("b") }

    func testPixelRegistrationOracleFindsKnownSignedTranslation() {
        let width = 40, height = 40
        var source = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height { for x in 0..<width { for c in 0..<3 {
            source[(y * width + x) * 4 + c] = UInt8((x * 37 + y * 53 + x * y * 7 + c * 47) % 220)
        } } }
        var output = source
        for y in 2..<(height - 2) { for x in 3..<width {
            for c in 0..<3 { output[(y * width + x) * 4 + c] = source[((y + 2) * width + x - 3) * 4 + c] }
        } }
        let displacement = track(P(20, 20), source: source, output: output, radius: 6, width: width, height: height)
        XCTAssertEqual(displacement.x, 3, accuracy: 0.125)
        XCTAssertEqual(displacement.y, -2, accuracy: 0.125)
    }

    func testAxisNormalRegistrationOracleFindsSignedSubpixelMotionWithFixedOpening() throws {
        let width = 72, height = 64
        let normal = P(0.6, 0.8)
        let point = P(31.25, 28.75)
        func texture(_ point: P, channel: Int) -> UInt8 {
            let value = 115 + 31 * sin(point.x * 0.23 + Double(channel))
                + 29 * cos(point.y * 0.31 - Double(channel) * 0.4)
                + 17 * sin((point.x + point.y) * 0.17)
            return UInt8(min(255, max(0, value.rounded())))
        }
        func translatedTexture(_ distance: Double) -> [UInt8] {
            var bytes = [UInt8](repeating: 255, count: width * height * 4)
            for y in 0..<height { for x in 0..<width { for channel in 0..<3 {
                let sourcePoint = P(Double(x), Double(y)) - normal * distance
                bytes[(y * width + x) * 4 + channel] = texture(sourcePoint, channel: channel)
            } } }
            return bytes
        }
        let source = translatedTexture(0)
        for distance in [-0.625, -0.1875, 0, 0.1875, 0.625] {
            let result = trackNormal(point, source: source, output: translatedTexture(distance),
                                     axisY: normal, radius: 3, width: width, height: height)
            XCTAssertEqual(result.distance, distance, accuracy: 0.09375)
            if distance == 0 { XCTAssertEqual(result.distance, 0) }
            else { XCTAssertGreaterThan(result.distance * (distance < 0 ? -1 : 1), 0.02) }
        }

        let palettes: [([Double], [Double])] = [
            ([192, 142, 116], [154, 52, 70]),
            ([115, 72, 52], [128, 42, 56]),
            ([220, 184, 164], [180, 68, 102])
        ]
        for palette in palettes {
            func straightEdge(_ distance: Double) -> [UInt8] {
                var bytes = [UInt8](repeating: 255, count: width * height * 4)
                for y in 0..<height { for x in 0..<width {
                    let location = P(Double(x), Double(y)) - point
                    let depth = location.x * normal.x + location.y * normal.y - distance
                    let lip = 1 / (1 + exp(-depth * 2))
                    for channel in 0..<3 {
                        let value = palette.0[channel] * (1 - lip) + palette.1[channel] * lip
                        bytes[(y * width + x) * 4 + channel] = UInt8(value.rounded())
                    }
                } }
                return bytes
            }
            let edgeSource = straightEdge(0)
            for distance in [-0.625, -0.1875, 0, 0.1875, 0.625] {
                let boundary = try XCTUnwrap(trackBoundary(point, source: edgeSource, output: straightEdge(distance),
                                                          axisY: normal, radius: 3, width: width, height: height))
                XCTAssertEqual(boundary.distance, distance, accuracy: 0.09375)
                if distance == 0 { XCTAssertEqual(boundary.distance, 0) }
                else { XCTAssertGreaterThan(boundary.distance * (distance < 0 ? -1 : 1), 0.02) }
            }
        }

        // Draw independent curved color boundaries, without invoking any SDK
        // map or resampling field. Only the upper outer edge bends; the oral
        // opening begins at a fixed row and its RGB bytes never move.
        func upperEdge(_ x: Double) -> Double { 29.5 + 0.006 * (x - 32) * (x - 32) }
        func curvedLip(_ strength: Double, palette: ([Double], [Double])) -> [UInt8] {
            var bytes = [UInt8](repeating: 255, count: width * height * 4)
            for y in 0..<height { for x in 0..<width {
                let horizontal = Double(x)
                let phase = sin(.pi * (horizontal - 16) / 16)
                let edge = upperEdge(horizontal) - strength * phase * phase
                let lip = 1 / (1 + exp(-(Double(y) - edge) * 2))
                for channel in 0..<3 {
                    let value: Double
                    if y >= 32 && y <= 36 { value = 22 + Double(channel * 5) + 2 * cos(horizontal * 0.17) }
                    else if y > 36 { value = 180 + Double(channel * 9) }
                    else {
                        let skin = palette.0[channel]
                        let red = palette.1[channel]
                        value = skin * (1 - lip) + red * lip + 3 * sin(horizontal * 0.29)
                    }
                    bytes[(y * width + x) * 4 + channel] = UInt8(min(255, max(0, value.rounded())))
                }
            } }
            return bytes
        }
        let positions = [P(32, upperEdge(32)), P(24, upperEdge(24)), P(40, upperEdge(40))]
        for palette in palettes {
            let lipSource = curvedLip(0, palette: palette)
            for strength in [-0.5, -0.125, 0, 0.125, 0.5] {
                let output = curvedLip(strength, palette: palette)
                let tracked = try positions.map {
                    try XCTUnwrap(trackBoundary($0, source: lipSource, output: output, axisY: P(0, 1),
                                                radius: 3, width: width, height: height)).distance
                }
                let curvature = tracked[0] - (tracked[1] + tracked[2]) / 2
                if strength == 0 { XCTAssertEqual(curvature, 0) }
                else { XCTAssertGreaterThan(curvature * (strength < 0 ? -1 : 1), 0.02) }
                XCTAssertEqual(curvature, strength, accuracy: 0.25)
                for y in 32...36 { for x in 0..<width { for channel in 0..<4 {
                    let offset = (y * width + x) * 4 + channel
                    XCTAssertEqual(output[offset], lipSource[offset])
                } } }
            }
        }
        let flat = [UInt8](repeating: 128, count: width * height * 4)
        XCTAssertNil(trackBoundary(point, source: flat, output: flat, axisY: normal,
                                   radius: 3, width: width, height: height))
    }

    private struct Frame: Encodable {
        let tool: String
        let value: Int
        let directionScorePixels: Double
        let directionPassed: Bool
        let unrestrictedDirectionScorePixels: Double?
        let normalMatchRMSE: Double?
        let windowNormalDirectionScorePixels: Double?
        let boundaryMinimumSourceContrast: Double?
        let boundaryMinimumThresholdCount: Int?
        let boundaryMaximumThresholdSpreadPixels: Double?
        let unrestrictedMaxTangentialPixels: Double?
        let smileHorizontalSpanChangePixels: Double?
        let changedPixels: Int
        let protectedChangedPixels: Int
        let outerChangedPixels: Int
        let repeated: Bool
        let alphaPreserved: Bool
        let warnings: [String]
    }
    private struct Receipt: Encodable {
        let schemaVersion: Int
        let detector: String
        let width: Int
        let height: Int
        let neutralIdentity: Bool
        let neutralRestored: Bool
        let frames: [Frame]
        let oracle: String
    }
    private typealias P = SIMD2<Double>
    private let tools = ["mouth.size", "mouth.width", "mouth.positionY", "mouth.tilt", "mouth.positionX",
                         "mouth.mShape", "mouth.fullness", "mouth.smile"]

    private func evaluate(_ input: String) async throws {
        let root = URL(fileURLWithPath: "/private/tmp/beauty-mouth-native", isDirectory: true)
        let runName = try String(contentsOf: root.appendingPathComponent("run-name.txt"), encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !runName.isEmpty, runName.utf8.count <= 64,
              runName.range(of: "^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$", options: .regularExpression) != nil else {
            throw NSError(domain: "MouthReferenceCheck", code: 1)
        }
        let output = root.appendingPathComponent(runName).appendingPathComponent(input)
        guard !FileManager.default.fileExists(atPath: output.path) else {
            throw NSError(domain: "MouthReferenceCheck", code: 2)
        }
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        let data = try ImageInput.readBoundedFile(root.appendingPathComponent("input-" + input + ".png"))
        let renderer = PhotoRenderer(preferredBackend: .cpu)
        let photo = try await renderer.load(data)
        let width = photo.preview.width, height = photo.preview.height
        let original = [UInt8](TestImage.pixels(photo.preview))
        let detected = try await renderer.landmarks(photo.preview)
        let face = try XCTUnwrap(detected.first)
        XCTAssertEqual(detected.count, 1)
        XCTAssertEqual(face.detectorName, "MediaPipe 478")
        guard face.points.count == 478 else { throw NSError(domain: "MouthReferenceCheck", code: 3) }
        let points = face.points.map { P(Double($0.x) * Double(width), Double($0.y) * Double(height)) }
        let baseline = points[291] - points[61]
        let span = hypot(baseline.x, baseline.y)
        XCTAssertGreaterThan(span, 12)
        let axisX = baseline / span, axisY = P(-axisX.y, axisX.x)
        let protected = protectionOffsets(points, width: width, height: height)
        let lipIndices = [61, 185, 40, 39, 37, 0, 267, 269, 270, 409, 291, 375, 321, 405, 314, 17, 84, 181, 91, 146]
        let lipPoints = lipIndices.map { points[$0] }
        let mouthRect = CGRect(x: lipPoints.map(\.x).min()!, y: lipPoints.map(\.y).min()!,
                              width: lipPoints.map(\.x).max()! - lipPoints.map(\.x).min()!,
                              height: lipPoints.map(\.y).max()! - lipPoints.map(\.y).min()!)
            .insetBy(dx: -span * 0.9, dy: -span * 0.8)
        let outer = (0..<(width * height)).filter {
            !mouthRect.contains(CGPoint(x: Double($0 % width) + 0.5, y: Double($0 / width) + 0.5))
        }.map { $0 * 4 }
        let neutral = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: false)
        let neutralIdentity = [UInt8](TestImage.pixels(neutral.image)) == original
        XCTAssertTrue(neutralIdentity)
        try await renderer.encodePNG(neutral.image).write(to: output.appendingPathComponent("neutral.png"))
        var frames = [Frame]()
        for id in tools {
            let tool = try XCTUnwrap(ToolCatalog.find(id))
            for value: Float in [-100, 100] {
                var snapshot = EditorSnapshot()
                tool.setValue(value, in: &snapshot.parameters)
                XCTAssertEqual(tool.value(in: snapshot.parameters), value, accuracy: 0.0001)
                let result = try await renderer.render(photo, snapshot: snapshot, fullResolution: false)
                XCTAssertEqual(result.detection?.usedFaceCount, 1, id)
                XCTAssertEqual(result.metrics["beauty.detection.meshPointCount"], 478, id)
                XCTAssertEqual(result.image.width, width)
                XCTAssertEqual(result.image.height, height)
                XCTAssertEqual(result.image.colorSpace?.name, CGColorSpace.sRGB)
                XCTAssertFalse(result.warningCodes.contains("mouth_inputs_missing"), id)
                let current = [UInt8](TestImage.pixels(result.image))
                guard current.count == original.count else { throw NSError(domain: "MouthReferenceCheck", code: 4) }
                let alpha = stride(from: 3, to: current.count, by: 4).allSatisfy { current[$0] == original[$0] }
                let changed = changedPixels(current, original, offsets: stride(from: 0, to: current.count, by: 4))
                let protectedChanged = changedPixels(current, original, offsets: protected)
                let outerChanged = changedPixels(current, original, offsets: outer)
                XCTAssertTrue(alpha, id)
                XCTAssertGreaterThan(changed, 0, id)
                XCTAssertEqual(protectedChanged, 0, id + " nose and complete eyes must remain exact")
                XCTAssertEqual(outerChanged, 0, id + " outer raster must remain exact")
                let repeatedResult = try await renderer.render(photo, snapshot: snapshot, fullResolution: false)
                let repeated = [UInt8](TestImage.pixels(repeatedResult.image)) == current
                XCTAssertTrue(repeated, id)
                let measurement = try directionMeasurement(id, source: original, output: current, points: points,
                                                       axisX: axisX, axisY: axisY, span: span, width: width, height: height)
                let score = measurement.score
                let directionPassed = score * Double(value) / 100 > 0.02
                XCTAssertTrue(directionPassed, id + " signed pixel motion must follow the reference slider")
                if id == "mouth.smile" {
                    let horizontal = try XCTUnwrap(measurement.smileHorizontalSpanChangePixels)
                    XCTAssertGreaterThan(horizontal * Double(value) / 100, 0.02,
                                         "smile corner span must spread/shrink with the same signed slider")
                }
                frames.append(Frame(tool: id, value: Int(value), directionScorePixels: score,
                                    directionPassed: directionPassed,
                                    unrestrictedDirectionScorePixels: measurement.unrestrictedScore,
                                    normalMatchRMSE: measurement.normalRMSE,
                                    windowNormalDirectionScorePixels: measurement.windowNormalScore,
                                    boundaryMinimumSourceContrast: measurement.minimumContrast,
                                    boundaryMinimumThresholdCount: measurement.minimumThresholdCount,
                                    boundaryMaximumThresholdSpreadPixels: measurement.maximumThresholdSpread,
                                    unrestrictedMaxTangentialPixels: measurement.maxTangential,
                                    smileHorizontalSpanChangePixels: measurement.smileHorizontalSpanChangePixels,
                                    changedPixels: changed,
                                    protectedChangedPixels: protectedChanged, outerChangedPixels: outerChanged,
                                    repeated: repeated, alphaPreserved: alpha, warnings: result.warningCodes))
                let name = id.replacingOccurrences(of: ".", with: "-") + (value < 0 ? "-negative.png" : "-positive.png")
                try await renderer.encodePNG(result.image).write(to: output.appendingPathComponent(name))
            }
        }
        let restored = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: false)
        let neutralRestored = [UInt8](TestImage.pixels(restored.image)) == original
        XCTAssertTrue(neutralRestored)
        XCTAssertEqual([UInt8](TestImage.pixels(photo.preview)), original)
        let receipt = Receipt(schemaVersion: 4, detector: face.detectorName, width: width, height: height,
                              neutralIdentity: neutralIdentity, neutralRestored: neutralRestored, frames: frames,
                              oracle: "Source-fixed RGB lip texture patch registration. M curvature measures source-fixed upper-lip red-chroma boundary crossings along the normal of source mouth corners, with a fixed tangent band and five source-derived 25/37.5/50/62.5/75% contrast thresholds. Median crossing displacement is primary; unrestricted 2D and 1D window scores, RMS residual and tangential excursion remain diagnostics. Other seven directions retain unrestricted 2D registration. Smile additionally checks projected corner-span change while retaining its original corner-height direction. Both matchers have independent known signed translation/curvature and neutral controls; unchanged signed direction threshold >0.02 preview pixels. Source-defined observed nose envelope and complete eyes exact. This is bounded direction and protection evidence, not reference appearance parity.")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(receipt).write(to: output.appendingPathComponent("aggregate.json"))
    }

    private func changedPixels<S: Sequence>(_ current: [UInt8], _ original: [UInt8], offsets: S) -> Int where S.Element == Int {
        offsets.reduce(0) { total, offset in total + ((0..<4).contains { current[offset + $0] != original[offset + $0] } ? 1 : 0) }
    }

    private func protectionOffsets(_ points: [P], width: Int, height: Int) -> [Int] {
        let contours = [
            [33, 7, 163, 144, 145, 153, 154, 155, 133, 173, 157, 158, 159, 160, 161, 246],
            [263, 249, 390, 373, 374, 380, 381, 382, 362, 398, 384, 385, 386, 387, 388, 466]
        ]
        var protected = Set<Int>()
        for indices in contours {
            let path = CGMutablePath()
            path.addLines(between: indices.map { CGPoint(x: points[$0].x, y: points[$0].y) })
            path.closeSubpath()
            let rim = path.copy(strokingWithWidth: 4, lineCap: .round, lineJoin: .round, miterLimit: 2)
            let bounds = path.boundingBoxOfPath.insetBy(dx: -2, dy: -2)
            for y in max(0, Int(floor(bounds.minY)))..<min(height, Int(ceil(bounds.maxY))) {
                for x in max(0, Int(floor(bounds.minX)))..<min(width, Int(ceil(bounds.maxX))) {
                    let point = CGPoint(x: Double(x) + 0.5, y: Double(y) + 0.5)
                    if path.contains(point) || rim.contains(point) { protected.insert((y * width + x) * 4) }
                }
            }
        }
        // Source-fixed nose envelope, padded by two preview pixels.
        let nose = [168, 6, 197, 195, 5, 4, 1, 2, 98, 327].map { points[$0] }
        for y in max(0, Int(floor(nose.map(\.y).min()! - 2)))..<min(height, Int(ceil(nose.map(\.y).max()! + 2))) {
            for x in max(0, Int(floor(nose.map(\.x).min()! - 2)))..<min(width, Int(ceil(nose.map(\.x).max()! + 2))) {
                protected.insert((y * width + x) * 4)
            }
        }
        XCTAssertFalse(protected.isEmpty)
        return protected.sorted()
    }

    private struct DirectionMeasurement {
        let score: Double
        let unrestrictedScore: Double?
        let normalRMSE: Double?
        let windowNormalScore: Double?
        let minimumContrast: Double?
        let minimumThresholdCount: Int?
        let maximumThresholdSpread: Double?
        let maxTangential: Double?
        let smileHorizontalSpanChangePixels: Double?
    }

    private func directionMeasurement(_ tool: String, source: [UInt8], output: [UInt8], points: [P],
                                      axisX: P, axisY: P, span: Double, width: Int, height: Int) throws -> DirectionMeasurement {
        let identifiers: [Int]
        switch tool {
        case "mouth.size", "mouth.positionY", "mouth.positionX": identifiers = [61, 291, 0, 17]
        case "mouth.width", "mouth.tilt": identifiers = [61, 291]
        case "mouth.mShape": identifiers = [0, 37, 267]
        case "mouth.fullness": identifiers = [0, 17]
        case "mouth.smile": identifiers = [61, 291, 13]
        default: preconditionFailure("Unrecognized mouth test control")
        }
        let motion = Dictionary(uniqueKeysWithValues: identifiers.map { index in
            (index, track(points[index], source: source, output: output, radius: min(20, max(4, span * 0.22)),
                          width: width, height: height))
        })
        func dx(_ index: Int) -> Double { let d = motion[index]!; return d.x * axisX.x + d.y * axisX.y }
        func dy(_ index: Int) -> Double { let d = motion[index]!; return d.x * axisY.x + d.y * axisY.y }
        if tool == "mouth.mShape" {
            let matches = Dictionary(uniqueKeysWithValues: identifiers.map { index in
                (index, trackNormal(points[index], source: source, output: output, axisY: axisY,
                                    radius: min(20, max(4, span * 0.22)), width: width, height: height))
            })
            let boundaryRadius = min(8, max(4, span * 0.08))
            let boundaries = try Dictionary(uniqueKeysWithValues: identifiers.map { index in
                let boundary = try XCTUnwrap(trackBoundary(points[index], source: source, output: output,
                                                          axisY: axisY, radius: boundaryRadius,
                                                          width: width, height: height),
                                             "M boundary requires valid source contrast, stable source crossings and corresponding output crossings")
                return (index, boundary)
            })
            let boundaryScore = boundaries[0]!.distance - (boundaries[37]!.distance + boundaries[267]!.distance) / 2
            let normalScore = matches[0]!.distance - (matches[37]!.distance + matches[267]!.distance) / 2
            let unrestrictedScore = dy(0) - (dy(37) + dy(267)) / 2
            let residual = sqrt(matches.values.map { $0.rmse * $0.rmse }.reduce(0, +) / Double(matches.count))
            let tangential = identifiers.map { abs(dx($0)) }.max()!
            return DirectionMeasurement(score: boundaryScore, unrestrictedScore: unrestrictedScore,
                                        normalRMSE: residual, windowNormalScore: normalScore,
                                        minimumContrast: boundaries.values.map(\.sourceContrast).min()!,
                                        minimumThresholdCount: boundaries.values.map(\.thresholdCount).min()!,
                                        maximumThresholdSpread: boundaries.values.map(\.thresholdSpread).max()!,
                                        maxTangential: tangential, smileHorizontalSpanChangePixels: nil)
        }
        let score: Double
        switch tool {
        case "mouth.size": score = -(dx(291) - dx(61) + dy(17) - dy(0))
        case "mouth.width": score = dx(291) - dx(61)
        case "mouth.positionY": score = -(dy(61) + dy(291) + dy(0) + dy(17)) / 4
        case "mouth.tilt": score = dy(291) - dy(61)
        case "mouth.positionX": score = (dx(61) + dx(291) + dx(0) + dx(17)) / 4
        case "mouth.fullness": score = dy(17) - dy(0)
        case "mouth.smile": score = -((dy(61) + dy(291)) / 2 - dy(13))
        default: preconditionFailure("Unrecognized mouth test control")
        }
        return DirectionMeasurement(score: score, unrestrictedScore: nil, normalRMSE: nil, windowNormalScore: nil,
                                    minimumContrast: nil, minimumThresholdCount: nil, maximumThresholdSpread: nil,
                                    maxTangential: nil,
                                    smileHorizontalSpanChangePixels: tool == "mouth.smile" ? dx(291) - dx(61) : nil)
    }

    private struct BoundaryMatch {
        let distance: Double
        let sourceContrast: Double
        let thresholdCount: Int
        let thresholdSpread: Double
    }

    /// Observe an outer skin-to-red-lip boundary, rather than requiring a mixed
    /// skin/lip/fixed-opening window to move rigidly. The ROI and thresholds are
    /// defined entirely from the source. Output pixels only locate the matching
    /// crossing in that same ROI. No production offsets or destination points
    /// enter this measurement, and missing contrast/crossings cannot become zero.
    /// Stability admits the source outer edge; the matching output crossing may
    /// border the fixed oral opening, so its interior need not stay red for 0.5 px.
    private func trackBoundary(_ point: P, source: [UInt8], output: [UInt8], axisY: P,
                               radius: Double, width: Int, height: Int) -> BoundaryMatch? {
        let tangent = P(axisY.y, -axisY.x)
        let extent = Int(ceil(radius) * 32)
        let step = 1.0 / 32
        func profile(_ bytes: [UInt8]) -> [Double] {
            (-extent...extent).map { index in
                let normalPosition = point + axisY * (Double(index) * step)
                return [-1.0, -0.5, 0, 0.5, 1].reduce(0) { sum, offset in
                    let location = normalPosition + tangent * offset
                    let red = sample(bytes, at: location, channel: 0, width: width, height: height)
                    let green = sample(bytes, at: location, channel: 1, width: width, height: height)
                    let blue = sample(bytes, at: location, channel: 2, width: width, height: height)
                    return sum + red - (green + blue) * 0.5
                } / 5
            }
        }
        func median(_ values: [Double]) -> Double {
            let sorted = values.sorted()
            let middle = sorted.count / 2
            return sorted.count.isMultiple(of: 2) ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle]
        }
        let original = profile(source)
        let current = profile(output)
        let skin = median(Array(original.prefix(25)))
        let lip = original.dropFirst(25).max()!
        let contrast = lip - skin
        guard contrast >= 4 else { return nil }
        func crossings(_ values: [Double], threshold: Double, requireStableSource: Bool) -> [Double] {
            var found = [Double]()
            for index in 0..<(values.count - 1) {
                let before = values[index], after = values[index + 1]
                guard before <= threshold, after > threshold else { continue }
                if requireStableSource {
                    guard index >= 16, index + 17 < values.count,
                          values[index - 16] <= threshold - contrast * 0.02,
                          values[index + 17] >= threshold + contrast * 0.02 else { continue }
                }
                let fraction = (threshold - before) / (after - before)
                found.append((Double(index - extent) + fraction) * step)
            }
            return found
        }
        var movements = [Double]()
        for fraction in [0.25, 0.375, 0.5, 0.625, 0.75] {
            let threshold = skin + contrast * fraction
            guard let sourceCrossing = crossings(original, threshold: threshold, requireStableSource: true).min(by: { abs($0) < abs($1) }) else { continue }
            guard let outputCrossing = crossings(current, threshold: threshold, requireStableSource: false).min(by: {
                abs($0 - sourceCrossing) < abs($1 - sourceCrossing)
            }) else { return nil }
            movements.append(outputCrossing - sourceCrossing)
        }
        guard movements.count >= 3 else { return nil }
        return BoundaryMatch(distance: median(movements), sourceContrast: contrast,
                             thresholdCount: movements.count, thresholdSpread: movements.max()! - movements.min()!)
    }

    private struct NormalMatch {
        let distance: Double
        let rmse: Double
    }

    /// For upper-edge curvature, the expected observation is motion along the
    /// normal of source mouth corners. Removing the unconstrained tangential
    /// search avoids a texture aperture ambiguity; no production map is read.
    private func trackNormal(_ point: P, source: [UInt8], output: [UInt8], axisY: P,
                             radius: Double, width: Int, height: Int) -> NormalMatch {
        var template = [(P, Int, Double)]()
        for y in -2...2 { for x in -2...2 { for channel in 0..<3 {
            let location = point + P(Double(x), Double(y))
            template.append((location, channel, sample(source, at: location, channel: channel, width: width, height: height)))
        } } }
        func error(_ distance: Double) -> Double {
            template.reduce(0) { value, item in
                let delta = sample(output, at: item.0 + axisY * distance, channel: item.1,
                                   width: width, height: height) - item.2
                return value + delta * delta
            } / Double(template.count)
        }
        var best = 0.0, lowest = error(0)
        let extent = Int(ceil(radius) * 32)
        for step in -extent...extent {
            let distance = Double(step) / 32
            let residual = error(distance)
            let regularized = residual + 0.0001 * distance * distance
            if regularized < lowest + 0.0001 * best * best {
                lowest = residual
                best = distance
            }
        }
        return NormalMatch(distance: best, rmse: sqrt(lowest))
    }

    /// Independent image registration; it has no access to production offsets,
    /// warp maps or generated destination landmarks. Fractional matching detects
    /// small but coherent motion without counting changed pixels as direction.
    private func track(_ point: P, source: [UInt8], output: [UInt8], radius: Double, width: Int, height: Int) -> P {
        var template = [(P, Int, Double)]()
        for y in -2...2 { for x in -2...2 { for channel in 0..<3 {
            let location = point + P(Double(x), Double(y))
            template.append((location, channel, sample(source, at: location, channel: channel, width: width, height: height)))
        } } }
        func error(_ shift: P) -> Double {
            template.reduce(0) { value, item in
                let delta = sample(output, at: item.0 + shift, channel: item.1, width: width, height: height) - item.2
                return value + delta * delta
            } / Double(template.count) + 0.0001 * (shift.x * shift.x + shift.y * shift.y)
        }
        var best = P.zero, lowest = error(.zero)
        for y in stride(from: -ceil(radius), through: ceil(radius), by: 1.0) {
            for x in stride(from: -ceil(radius), through: ceil(radius), by: 1.0) {
                let candidate = P(x, y), score = error(candidate)
                if score < lowest { lowest = score; best = candidate }
            }
        }
        let coarse = best
        for y in stride(from: -0.875, through: 0.875, by: 0.125) {
            for x in stride(from: -0.875, through: 0.875, by: 0.125) {
                let candidate = coarse + P(x, y), score = error(candidate)
                if score < lowest { lowest = score; best = candidate }
            }
        }
        return best
    }

    private func sample(_ bytes: [UInt8], at p: P, channel: Int, width: Int, height: Int) -> Double {
        let x = min(Double(width - 1), max(0, p.x)), y = min(Double(height - 1), max(0, p.y))
        let x0 = Int(floor(x)), y0 = Int(floor(y)), x1 = min(width - 1, x0 + 1), y1 = min(height - 1, y0 + 1)
        let fx = x - Double(x0), fy = y - Double(y0)
        func at(_ x: Int, _ y: Int) -> Double { Double(bytes[(y * width + x) * 4 + channel]) }
        return (at(x0, y0) * (1 - fx) + at(x1, y0) * fx) * (1 - fy)
            + (at(x0, y1) * (1 - fx) + at(x1, y1) * fx) * fy
    }
}
#endif
