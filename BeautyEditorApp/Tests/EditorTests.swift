import BeautySDK
import CoreImage
import ImageIO
import SwiftUI
import UniformTypeIdentifiers
import Vision
import XCTest
@testable import BeautyEditor

enum TestImage {
    private static let pixelContext = CIContext(options: [.cacheIntermediates: false])
    static func image(width: Int = 64, height: Int = 96) -> CGImage {
        var bytes = [UInt8](repeating: 255, count: width * height * 4)
        for y in 0..<height {
            for x in 0..<width {
                let index = (y * width + x) * 4
                bytes[index] = UInt8(x * 140 / width + 30)
                bytes[index + 1] = UInt8(y * 140 / height + 30)
                bytes[index + 2] = 110
            }
        }
        let provider = CGDataProvider(data: Data(bytes) as CFData)!
        return CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32,
                       bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
    }
    static func encoded(width: Int = 64, height: Int = 96, orientation: UInt32 = 1,
                        type: UTType = .png, metadata: [CFString: Any] = [:]) -> Data {
        let data = NSMutableData()
        let destination = CGImageDestinationCreateWithData(data, type.identifier as CFString, 1, nil)!
        var properties = metadata
        properties[kCGImagePropertyOrientation] = orientation
        CGImageDestinationAddImage(destination, image(width: width, height: height), properties as CFDictionary)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        return data as Data
    }
    static func pixels(_ image: CGImage) -> Data {
        let context = pixelContext
        var data = Data(count: image.width * image.height * 4)
        data.withUnsafeMutableBytes { pointer in
            context.render(CIImage(cgImage: image), toBitmap: pointer.baseAddress!, rowBytes: image.width * 4,
                           bounds: CGRect(x: 0, y: 0, width: image.width, height: image.height),
                           format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
        }
        return data
    }
}

@MainActor final class ControlContractTests: XCTestCase {
    func testOnlySelectedElevenEyeToolsUseReferenceSliderAppearance() {
        let expected = Set(["eye.size", "eye.positionY", "eye.eyelidSize", "eye.length", "eye.spacing",
                            "eye.irisSize", "eye.lowerLid", "eye.tailLift", "eye.tilt", "eye.innerCorner", "eye.outerCorner"])
        XCTAssertEqual(Set(ToolCatalog.all.filter(\.usesReferenceEyeSlider).map(\.id)), expected)
        for tool in ToolCatalog.all where tool.usesReferenceEyeSlider {
            XCTAssertEqual(tool.range, .signed)
            XCTAssertEqual(tool.value(in: BeautyParameters()), 0, accuracy: 0.0001)
        }
    }

    func testFaceReferenceSlidersKeepDirectionCapsAndUnrelatedParameters() throws {
        let signed = Set(["face.width", "face.size", "face.temple", "face.cheekbone",
                          "face.chinLength", "face.chinPoint", "face.jawAngle", "face.hairline"])
        let tools = ToolCatalog.tools(in: .face)
        XCTAssertEqual(tools.count, 13)
        XCTAssertEqual(tools.map(\.id), ["face.width", "face.size", "face.contourSmooth", "face.temple",
            "face.cheekbone", "face.chinLength", "face.doubleChin", "face.doubleChinRefine",
            "face.chinPoint", "face.vShape", "face.jawAngle", "face.jawline", "face.hairline"])
        XCTAssertEqual(BeautyCategory.face.defaultTool, "face.width")
        XCTAssertEqual(Set(tools.filter { $0.range == .signed }.map(\.id)), signed)
        let active = tools.filter(\.available)
        XCTAssertEqual(active.count, 11)
        XCTAssertEqual(Set(ToolCatalog.all.filter(\.usesReferenceFaceSlider).map(\.id)), Set(active.map(\.id)))
        let baseline = BeautyParameters(eyeSize: -0.18, noseWingSlim: 0.21, mouthWidth: -0.12)
        let original = try dictionary(baseline)
        for tool in active {
            XCTAssertTrue(tool.available, tool.id)
            XCTAssertTrue(tool.usesReferenceSlider, tool.id)
            XCTAssertEqual(tool.value(in: baseline), 0, tool.id)
            for value: Float in [-100, -37.125, 0, 37.125, 100] {
                var parameters = baseline
                tool.setValue(value, in: &parameters)
                let expected = min(100, max(tool.range == .signed ? -100 : 0, value))
                XCTAssertEqual(tool.value(in: parameters), expected, accuracy: 0.0001, tool.id)
                let direction: Float = ["chinLength", "chinTaper"].contains(tool.field!) ? -1 : 1
                XCTAssertEqual(tool.sdkValue(in: parameters), expected / 100 * tool.maximumSDKStrength * direction,
                               accuracy: 0.000001, tool.id)
                let updated = try dictionary(parameters)
                for field in original.keys where field != tool.field {
                    XCTAssertEqual(updated[field], original[field], tool.id + " must preserve " + field)
                }
                let restored = try JSONDecoder().decode(BeautyParameters.self, from: JSONEncoder().encode(parameters))
                XCTAssertEqual(tool.value(in: restored), expected, accuracy: 0.0001, tool.id)
            }
            var invalid = baseline
            tool.setValue(.nan, in: &invalid)
            XCTAssertEqual(invalid, baseline, tool.id)
        }
        var parameters = baseline
        ToolCatalog.find("face.jawAngle")!.setValue(-63.75, in: &parameters)
        XCTAssertEqual(ToolCatalog.find("face.jawline")!.value(in: parameters), 0, accuracy: 0.0001)
        ToolCatalog.find("face.jawline")!.setValue(71.25, in: &parameters)
        XCTAssertEqual(ToolCatalog.find("face.jawAngle")!.value(in: parameters), -63.75, accuracy: 0.0001)
        XCTAssertEqual(parameters.jawlineShadow, 0.178125, accuracy: 0.000001)
        XCTAssertFalse(ToolCatalog.find("face.jawline")!.isGeometry)
        XCTAssertEqual(ToolCatalog.find("face.chinLength")!.value(in: BeautyParameters(chinLength: 0.175)), -50, accuracy: 0.0001)
        XCTAssertEqual(ToolCatalog.find("face.chinPoint")!.value(in: BeautyParameters(chinTaper: 0.125)), -50, accuracy: 0.0001)
    }

    func testDoubleChinEntriesRemainDisabledWithoutClearingValuesOrHistory() throws {
        let disabled = [("face.doubleChin", "doubleChinReduction", Float(0.15)),
                        ("face.doubleChinRefine", "doubleChinReductionPro", Float(0.20))]
        let expectedDisabled = Set(["eye.lidLift", "eye.gazeCorrection", "eye.symmetry", "eye.redness"]
            + disabled.map { $0.0 })
        XCTAssertEqual(Set(ToolCatalog.all.filter { !$0.enabled }.map(\.id)), expectedDisabled)
        var baseline = BeautyParameters(eyeSize: -0.18, noseWingSlim: 0.21, mouthWidth: -0.12)
        baseline.doubleChinReduction = 0.15
        baseline.doubleChinReductionPro = 0.20
        for (id, field, value) in disabled {
            let tool = try XCTUnwrap(ToolCatalog.find(id))
            XCTAssertEqual(tool.field, field, id)
            XCTAssertEqual(tool.category, .face, id)
            XCTAssertEqual(tool.range, .unit, id)
            XCTAssertEqual(tool.icon, id.replacingOccurrences(of: ".", with: "_"), id)
            XCTAssertEqual(tool.pro, id == "face.doubleChinRefine", id)
            XCTAssertEqual(tool.promo, id == "face.doubleChinRefine", id)
            XCTAssertEqual(tool.maximumSDKStrength, 0.25, id)
            XCTAssertFalse(tool.enabled, id)
            XCTAssertFalse(tool.available, id)
            XCTAssertFalse(tool.usesReferenceSlider, id)
            XCTAssertEqual(tool.sdkValue(in: baseline), value, id)
            XCTAssertEqual(tool.value(in: baseline), value / 0.25 * 100, accuracy: 0.0001, id)
            for requested: Float in [0, 37.125, 100, -100, .nan] {
                var retained = baseline
                tool.setValue(requested, in: &retained)
                XCTAssertEqual(retained, baseline, id + " must retain existing values")
                var neutral = BeautyParameters()
                tool.setValue(requested, in: &neutral)
                XCTAssertEqual(neutral, BeautyParameters(), id + " must not accept a new value")
            }
        }
        let restored = try JSONDecoder().decode(BeautyParameters.self, from: JSONEncoder().encode(baseline))
        XCTAssertEqual(restored, baseline)
        let previous = EditorSnapshot(parameters: restored)
        var current = previous
        ToolCatalog.find("face.width")!.setValue(37.125, in: &current.parameters)
        XCTAssertEqual(current.parameters.doubleChinReduction, baseline.doubleChinReduction)
        XCTAssertEqual(current.parameters.doubleChinReductionPro, baseline.doubleChinReductionPro)
        var history = EditHistory()
        history.record(previous, replacing: current)
        XCTAssertEqual(history.undo(current), previous)
        XCTAssertEqual(history.redo(previous), current)
    }

    func testIrisReferenceSliderPreservesDisabledEyeBindings() throws {
        let iris = try XCTUnwrap(ToolCatalog.find("eye.irisSize"))
        XCTAssertTrue(iris.available)
        XCTAssertTrue(iris.usesReferenceEyeSlider)
        XCTAssertEqual(iris.range, .signed)
        XCTAssertEqual(iris.eyeSlider, .irisSize)
        var baseline = BeautyParameters()
        baseline.upperEyelidLift = 0.15
        baseline.gazeCorrection = 0.10
        baseline.eyeSymmetry = 0.12
        baseline.scleraRednessReduction = 0.40
        let disabled = [("eye.lidLift", "upperEyelidLift", Float(0.15)),
                        ("eye.gazeCorrection", "gazeCorrection", Float(0.10)),
                        ("eye.symmetry", "eyeSymmetry", Float(0.12)),
                        ("eye.redness", "scleraRednessReduction", Float(0.40))]
        XCTAssertEqual(Set(ToolCatalog.tools(in: .eye).filter { !$0.enabled }.map(\.id)), Set(disabled.map { $0.0 }))
        for (id, field, value) in disabled {
            let tool = try XCTUnwrap(ToolCatalog.find(id))
            XCTAssertEqual(tool.field, field, id)
            XCTAssertFalse(tool.available, id)
            XCTAssertFalse(tool.usesReferenceEyeSlider, id)
            XCTAssertEqual(tool.sdkValue(in: baseline), value, id)
            for requested: Float in [0, 100, -100, .nan] {
                var preserved = baseline
                tool.setValue(requested, in: &preserved)
                XCTAssertEqual(preserved, baseline, id + " disabled direct setter must preserve existing values")
                var neutral = BeautyParameters()
                tool.setValue(requested, in: &neutral)
                XCTAssertEqual(neutral, BeautyParameters(), id + " disabled direct setter must preserve neutral")
            }
        }
        for value: Float in [-100, -37.125, 0, 37.125, 100] {
            var adjusted = baseline
            iris.setValue(value, in: &adjusted)
            XCTAssertEqual(iris.value(in: adjusted), value, accuracy: 0.0001)
            adjusted.pupilSize = 0
            XCTAssertEqual(adjusted, baseline, "iris adjustment must retain disabled SDK fields")
        }
    }

    func testEveryToolChangesOnlyItsCanonicalField() throws {
        XCTAssertEqual(ToolCatalog.all.count, 59)
        XCTAssertEqual(ToolCatalog.all.filter(\.available).count, 52)
        let baseline = try dictionary(BeautyParameters())
        for tool in ToolCatalog.all where tool.available {
            var parameters = BeautyParameters()
            tool.setValue(100, in: &parameters)
            XCTAssertEqual(tool.value(in: parameters), 100, accuracy: 0.001, tool.id)
            XCTAssertEqual(abs(tool.sdkValue(in: parameters)), tool.maximumSDKStrength, tool.id)
            let updated = try dictionary(parameters)
            let changed = updated.keys.filter { updated[$0] != baseline[$0] }
            XCTAssertEqual(changed, [tool.field!], tool.id)
            tool.setValue(-100, in: &parameters)
            XCTAssertEqual(tool.value(in: parameters), tool.range == .signed ? -100 : 0, accuracy: 0.001, tool.id)
            tool.setValue(.nan, in: &parameters)
            XCTAssertEqual(tool.value(in: parameters), 0, tool.id)
        }
    }
    func testEyeReferenceSlidersHaveIndependentCenteredBindings() throws {
        let controls: [(String, String, BeautyEyeShapeSlider)] = [
            ("eye.size", "eyeSize", .eyeSize), ("eye.positionY", "eyeYPosition", .verticalPosition),
            ("eye.eyelidSize", "eyeHeight", .height), ("eye.length", "eyeLength", .length),
            ("eye.spacing", "eyeDistance", .spacing), ("eye.irisSize", "pupilSize", .irisSize),
            ("eye.lowerLid", "lowerEyelidDrop", .lowerEyelid), ("eye.tailLift", "eyeTailLift", .outerTail),
            ("eye.tilt", "eyeTilt", .tilt), ("eye.innerCorner", "innerCornerOpen", .innerCorner),
            ("eye.outerCorner", "outerCornerOpen", .outerCorner)
        ]
        XCTAssertEqual(Set(controls.map { $0.1 }).count, 11)
        XCTAssertEqual(BeautyCategory.eye.defaultTool, "eye.size")
        XCTAssertEqual(ToolCatalog.find("eye.eyelidSize")?.title, "眼高")
        XCTAssertEqual(ToolCatalog.find("eye.irisSize")?.title, "眼瞳大小")
        let baseline = BeautyParameters(noseWingSlim: 0.21, mouthWidth: -0.12,
                                        scleraRednessReduction: 0.2)
        let baselineFields = try dictionary(baseline)
        for (id, field, helper) in controls {
            let tool = try XCTUnwrap(ToolCatalog.find(id))
            XCTAssertEqual(tool.field, field)
            XCTAssertEqual(tool.range, .signed)
            XCTAssertEqual(tool.eyeSlider, helper)
            XCTAssertEqual(tool.value(in: baseline), 0, accuracy: 0.0001, id)
            for value: Float in [-100, -50, 0, 50, 100] {
                var parameters = baseline
                tool.setValue(value, in: &parameters)
                XCTAssertEqual(tool.value(in: parameters), value, accuracy: 0.0001, id)
                XCTAssertEqual(parameters, helper.applying(position: (value / 100 + 1) / 2, to: baseline), id)
                let roundTrip = try JSONDecoder().decode(BeautyParameters.self, from: JSONEncoder().encode(parameters))
                XCTAssertEqual(roundTrip, parameters, id)
                let changed = try dictionary(parameters).filter { key, value in
                    value != baselineFields[key]
                }.keys
                XCTAssertEqual(Set(changed), value == 0 ? [] : [field], id)
            }
            var positive = baseline
            tool.setValue(100, in: &positive)
            XCTAssertEqual(tool.sdkValue(in: positive), (field == "eyeTilt" ? -1 : 1) * tool.maximumSDKStrength, id)
            var parameters = baseline
            tool.setValue(.nan, in: &parameters)
            XCTAssertEqual(parameters, baseline, id)
        }
    }

    func testNewEyeControlsHaveAvailableNativeSymbols() {
        XCTAssertEqual(ToolCatalog.systemSymbols.count, 5)
        for (id, symbol) in ToolCatalog.systemSymbols {
            XCTAssertEqual(ToolCatalog.find(id)?.systemSymbol, symbol)
            XCTAssertNotNil(UIImage(systemName: symbol), id)
        }
    }

    func testAliasesRemainSynchronizedAndSuspendedToolCannotActivate() {
        var parameters = BeautyParameters()
        ToolCatalog.find("face.jawline")!.setValue(35, in: &parameters)
        XCTAssertEqual(ToolCatalog.find("face.jawAngle")!.value(in: parameters), 0, accuracy: 0.001)
        XCTAssertEqual(ToolCatalog.find("face.jawline")!.value(in: parameters), 35, accuracy: 0.001)
        ToolCatalog.find("eye.lift")!.setValue(42, in: &parameters)
        XCTAssertEqual(ToolCatalog.find("eye.tailLift")!.value(in: parameters), 42, accuracy: 0.001)
        ToolCatalog.find("eye.fatRemoval")!.setValue(100, in: &parameters)
        XCTAssertEqual(parameters.upperEyelidFullnessReduction, 0)
        XCTAssertFalse(ToolCatalog.find("eye.fatRemoval")!.available)
    }
    func testHistoryGroupsChangesAndClearsRedoAfterNewAdjustment() {
        var history = EditHistory()
        let neutral = EditorSnapshot()
        var first = neutral
        first.parameters.mouthWidth = -0.5
        history.record(neutral, replacing: first)
        XCTAssertEqual(history.undo(first), neutral)
        XCTAssertEqual(history.redo(neutral), first)
        _ = history.undo(first)
        var second = neutral
        second.parameters.noseWingSlim = 0.3
        history.record(neutral, replacing: second)
        XCTAssertTrue(history.redoStack.isEmpty)
        XCTAssertEqual(history.undo(second), neutral)
    }
    func testIndependentSliderRangesPreservePreviousFieldsAndAliases() {
        var parameters = BeautyParameters()
        for id in ["face.width", "eye.innerCorner", "nose.ala", "mouth.width"] {
            let previous = parameters
            let tool = ToolCatalog.find(id)!
            tool.setValue(id == "mouth.width" ? -100 : 100, in: &parameters)
            XCTAssertEqual(abs(tool.value(in: parameters)), 100, accuracy: 0.0001)
            for other in ToolCatalog.canonicalTools where other.field != tool.field {
                XCTAssertEqual(other.sdkValue(in: parameters), other.sdkValue(in: previous), other.id)
            }
        }
        XCTAssertEqual(parameters.faceSlim, 0.6)
        XCTAssertEqual(parameters.innerCornerOpen, 0.25)
        XCTAssertEqual(parameters.noseWingSlim, 0.35)
        XCTAssertEqual(parameters.mouthWidth, -0.35)
        XCTAssertGreaterThan(ToolCatalog.geometryTotal(in: parameters), 1)
        ToolCatalog.find("face.jawAngle")!.setValue(100, in: &parameters)
        XCTAssertEqual(ToolCatalog.find("face.jawline")!.value(in: parameters), 0, accuracy: 0.0001)
        let total = ToolCatalog.geometryTotal(in: parameters)
        ToolCatalog.find("face.jawline")!.setValue(100, in: &parameters)
        XCTAssertEqual(ToolCatalog.geometryTotal(in: parameters), total)
        ToolCatalog.find("eye.redness")!.setValue(100, in: &parameters)
        XCTAssertEqual(ToolCatalog.geometryTotal(in: parameters), total)
        XCTAssertEqual(ToolCatalog.canonicalTools.count, 57)
    }
    func testLandmarksAlignWithPortraitAndLandscapeLetterboxing() {
        let portrait = DebugLandmarkProjection.imageRect(imageSize: CGSize(width: 960, height: 1200), viewport: CGSize(width: 393, height: 600))
        XCTAssertEqual(portrait.width, 393, accuracy: 0.001)
        XCTAssertEqual(portrait.minY, 54.375, accuracy: 0.001)
        XCTAssertEqual(DebugLandmarkProjection.project(CGPoint(x: 0.5, y: 0.5), in: portrait), CGPoint(x: 196.5, y: 300))
        let landscape = DebugLandmarkProjection.imageRect(imageSize: CGSize(width: 1200, height: 600), viewport: CGSize(width: 400, height: 600))
        XCTAssertEqual(landscape, CGRect(x: 0, y: 200, width: 400, height: 200))
        XCTAssertEqual(DebugLandmarkProjection.project(CGPoint(x: 0, y: 1), in: landscape), CGPoint(x: 0, y: 400))
    }
    private func dictionary(_ value: BeautyParameters) throws -> [String: NSNumber] {
        try JSONSerialization.jsonObject(with: JSONEncoder().encode(value)) as! [String: NSNumber]
    }
}

@MainActor final class PhotoPipelineTests: XCTestCase {
    func testFileImportUsesActualBoundedBytesAndRejectsEmptyAndOversizedFiles() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        let image = TestImage.encoded()
        try image.write(to: url)
        XCTAssertEqual(try ImageInput.readBoundedFile(url), image)
        try Data().write(to: url)
        XCTAssertThrowsError(try ImageInput.readBoundedFile(url)) { XCTAssertEqual($0 as? EditorError, .invalidImage) }
        try Data(count: ImageInput.byteLimit + 1).write(to: url)
        XCTAssertThrowsError(try ImageInput.readBoundedFile(url)) { XCTAssertEqual($0 as? EditorError, .tooLarge) }
    }
    func testPreparedPreviewNoFaceReusesOnlyFixedPhotoAndExportRemainsFresh() async throws {
        let renderer = PhotoRenderer(preferredBackend: .cpu)
        let photo = try await renderer.load(TestImage.encoded())
        var edit = EditorSnapshot(); edit.parameters.eyeSize = 0.2
        let first = try await renderer.render(photo, snapshot: edit, fullResolution: false)
        let again = try await renderer.render(photo, snapshot: edit, fullResolution: false)
        XCTAssertEqual(first.detection?.availability, .noFace)
        XCTAssertEqual(first.metrics["beauty.detection.preparedReuse"], 0)
        XCTAssertEqual(again.metrics["beauty.detection.preparedReuse"], 1)
        XCTAssertTrue(TestImage.pixels(first.image) == TestImage.pixels(again.image))
        let exported = try await renderer.render(photo, snapshot: edit, fullResolution: true)
        XCTAssertNil(exported.metrics["beauty.detection.preparedReuse"])
        let afterExport = try await renderer.render(photo, snapshot: edit, fullResolution: false)
        XCTAssertEqual(afterExport.metrics["beauty.detection.preparedReuse"], 1)
        let replacement = try await renderer.load(TestImage.encoded(width: 48, height: 80))
        let replaced = try await renderer.render(replacement, snapshot: edit, fullResolution: false)
        XCTAssertEqual(replaced.metrics["beauty.detection.preparedReuse"], 0)
        XCTAssertEqual(replaced.image.width, replacement.preview.width)
        XCTAssertEqual(replaced.image.height, replacement.preview.height)
    }

    #if BEAUTY_OWNER_PORTRAIT_CHECK
    func testOwnerPreparedPreviewMatchesFreshNativeModelAcrossSnapshotsAndReplacement() async throws {
        let data = try ImageInput.readBoundedFile(URL(fileURLWithPath: "/private/tmp/beauty-editor-owner-check.png"))
        let renderer = PhotoRenderer(preferredBackend: .cpu)
        let photo = try await renderer.load(data)
        let fresh = try BeautyEngine(configuration: BeautyConfiguration(
            preferredProcessingSize: CGSize(width: 960, height: 960), maximumFaceCount: 1))
        let context = CIContext(options: [.cacheIntermediates: false,
            .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!])
        var first = Data()
        for (index, value) in [Float(0.1), Float(0.2), Float(0.3), Float(0.1)].enumerated() {
            var edit = EditorSnapshot(); edit.parameters.noseWingSlim = value
            let result = try await renderer.render(photo, snapshot: edit, fullResolution: false)
            let reference = try fresh.processResult(image: CIImage(cgImage: photo.preview),
                metadata: BeautyInputMetadata(orientation: .up, source: .photo), parameters: edit.parameters)
            let referenceImage = try XCTUnwrap(context.createCGImage(reference.output, from: reference.output.extent,
                format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!))
            XCTAssertEqual(result.detection?.usedFaceCount, 1)
            XCTAssertEqual(result.metrics["beauty.detection.meshPointCount"], 478)
            XCTAssertEqual(result.metrics["beauty.detection.preparedReuse"], index == 0 ? 0 : 1)
            XCTAssertTrue(TestImage.pixels(result.image) == TestImage.pixels(referenceImage))
            if index == 0 {
                first = TestImage.pixels(result.image)
                XCTAssertTrue(first != TestImage.pixels(photo.preview))
            }
            if index == 3 { XCTAssertTrue(TestImage.pixels(result.image) == first) }
        }
        let replacement = try await renderer.load(data)
        var edit = EditorSnapshot(); edit.parameters.noseWingSlim = 0.1
        let next = try await renderer.render(replacement, snapshot: edit, fullResolution: false)
        XCTAssertEqual(next.metrics["beauty.detection.preparedReuse"], 0)
        XCTAssertTrue(TestImage.pixels(next.image) == first)
    }
    func testOwnerMediaPipe478DebugIsTransientAndPixelInert() async throws {
        let renderer = PhotoRenderer()
        let data = try ImageInput.readBoundedFile(URL(fileURLWithPath: "/private/tmp/beauty-editor-owner-check.png"))
        let photo = try await renderer.load(data)
        var edit = EditorSnapshot()
        edit.parameters.noseWingSlim = 0.2
        let before = try await renderer.render(photo, snapshot: edit, fullResolution: false)
        let source = try await renderer.landmarks(photo.preview)
        let output = try await renderer.landmarks(before.image)
        for groups in [source, output] {
            XCTAssertEqual(groups.count, 1)
            XCTAssertEqual(groups.first?.detectorName, "MediaPipe 478")
            XCTAssertEqual(groups.first?.points.count, 478)
            XCTAssertTrue(groups.flatMap(\.points).allSatisfy {
                $0.x.isFinite && $0.y.isFinite && (0...1).contains($0.x) && (0...1).contains($0.y)
            })
        }
        let again = try await renderer.landmarks(photo.preview)
        XCTAssertTrue(again == source)
        let after = try await renderer.render(photo, snapshot: edit, fullResolution: false)
        XCTAssertTrue(TestImage.pixels(before.image) == TestImage.pixels(after.image))
        XCTAssertEqual(after.detection?.usedFaceCount, 1)
        let blank = TestImage.image()
        let noFace = try await renderer.landmarks(blank)
        XCTAssertTrue(noFace.isEmpty)
        let recovered = try await renderer.landmarks(photo.preview)
        XCTAssertEqual(recovered.first?.points.count, 478)
    }

    func testOwnerMediaPipeFullRangeCombinationKeepsFieldsAndActualPixels() async throws {
        let renderer = PhotoRenderer()
        let data = try ImageInput.readBoundedFile(URL(fileURLWithPath: "/private/tmp/beauty-editor-owner-check.png"))
        let photo = try await renderer.load(data)
        let original = TestImage.pixels(photo.preview)
        var priorPixels = original
        var snapshot = EditorSnapshot()
        for id in ["face.width", "eye.innerCorner", "nose.ala", "mouth.width"] {
            let tool = ToolCatalog.find(id)!
            let previous = snapshot.parameters
            tool.setValue(id == "mouth.width" ? -100 : 100, in: &snapshot.parameters)
            XCTAssertEqual(abs(tool.value(in: snapshot.parameters)), 100, accuracy: 0.0001)
            for other in ToolCatalog.canonicalTools where other.field != tool.field {
                XCTAssertEqual(other.sdkValue(in: previous), other.sdkValue(in: snapshot.parameters), other.id)
            }
            let output = try await renderer.render(photo, snapshot: snapshot, fullResolution: false)
            XCTAssertEqual(output.detection?.usedFaceCount, 1)
            XCTAssertEqual(output.metrics["beauty.effects.denseMapCombination"], 1)
            XCTAssertFalse(output.warningCodes.contains("combined_geometry_weakened"))
            XCTAssertFalse(output.warningCodes.contains("beauty_strength_capped"))
            XCTAssertEqual(output.image.width, photo.preview.width)
            XCTAssertEqual(output.image.height, photo.preview.height)
            let pixels = TestImage.pixels(output.image)
            XCTAssertTrue(pixels != priorPixels, id)
            XCTAssertTrue(pixels != original, id)
            XCTAssertTrue(stride(from: 3, to: pixels.count, by: 4).allSatisfy { pixels[$0] == 255 })
            let repeated = try await renderer.render(photo, snapshot: snapshot, fullResolution: false)
            XCTAssertTrue(pixels == TestImage.pixels(repeated.image))
            priorPixels = pixels
        }
        XCTAssertGreaterThan(ToolCatalog.geometryTotal(in: snapshot.parameters), 1)
        XCTAssertTrue(original == TestImage.pixels(photo.preview))
        let final = try await renderer.render(photo, snapshot: snapshot, fullResolution: false)
        let observed = try await renderer.landmarks(final.image)
        XCTAssertEqual(observed.first?.detectorName, "MediaPipe 478")
        XCTAssertEqual(observed.first?.points.count, 478)
    }

    /// Owner-opt-in observation run. A passing XCTest is not an appearance or
    /// protection pass: the aggregate receipt reports protected-pixel failures.
    func testOwnerPortraitNoseReferenceIsolationAndExport() async throws {
        struct PixelDelta: Encodable {
            let pixelCount: Int
            let changedPixels: Int
            let maxChannelDifference: Int
            let meanRGBDifference: Double
        }
        struct FrameReceipt: Encodable {
            let tool: String
            let value: Int
            let sdkValue: Float
            let imageDelta: PixelDelta
            let protectedRegions: [String: PixelDelta]
            let protectionAssessment: String
            let warningCodes: [String]
            let renderMilliseconds: Double
            let actualBackend: String
            let endpointDeterministic: Bool?
        }
        struct RunReceipt: Encodable {
            let schemaVersion: Int
            let detector: String
            let meshPointCount: Int
            let width: Int
            let height: Int
            let outputImageCount: Int
            let neutralIdentity: Bool
            let neutralRestored: Bool
            let protectionAssessment: String
            let protectionDefinition: String
            let effectQualification: String
            let frames: [FrameReceipt]
        }
        let manager = FileManager.default
        #if targetEnvironment(simulator)
        let root = URL(fileURLWithPath: "/private/tmp/beauty-nose-implementation", isDirectory: true)
        let inputURL = URL(fileURLWithPath: "/private/tmp/beauty-owner-portrait-check.png")
        #else
        let root = try manager.url(for: .documentDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true).appendingPathComponent("OwnerNoseReference", isDirectory: true)
        let inputURL = root.appendingPathComponent("input.png")
        #endif
        let runName = try String(contentsOf: root.appendingPathComponent("run-name.txt"), encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !runName.isEmpty, runName.utf8.count <= 64,
              runName.range(of: "^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$", options: .regularExpression) != nil else {
            throw NSError(domain: "NoseReferenceReview", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid review run name"])
        }
        let directory = root.appendingPathComponent(runName, isDirectory: true)
        guard !manager.fileExists(atPath: directory.path) else {
            throw NSError(domain: "NoseReferenceReview", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Review run already exists"])
        }
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try ImageInput.readBoundedFile(inputURL)
        let renderer = PhotoRenderer(preferredBackend: .cpu)
        let photo = try await renderer.load(data)
        let width = photo.preview.width, height = photo.preview.height
        let original = TestImage.pixels(photo.preview)
        let source = try await renderer.landmarks(photo.preview)
        let group = try XCTUnwrap(source.first)
        XCTAssertEqual(source.count, 1)
        XCTAssertEqual(group.detectorName, "MediaPipe 478")
        guard group.points.count == 478 else {
            XCTFail("Expected the production dense model")
            throw NSError(domain: "NoseReferenceReview", code: 3)
        }
        // Pinned MediaPipe topology; coordinates and membership stay in memory.
        // Full interiors plus a 2-pixel rim protect tissue and antialiased edges.
        let contours: [String: [Int]] = [
            "leftEye": [33, 7, 163, 144, 145, 153, 154, 155, 133, 173, 157, 158, 159, 160, 161, 246],
            "rightEye": [263, 249, 390, 373, 374, 380, 381, 382, 362, 398, 384, 385, 386, 387, 388, 466],
            "leftBrow": [107, 66, 105, 63, 70, 46, 53, 52, 65, 55],
            "rightBrow": [336, 296, 334, 293, 300, 276, 283, 282, 295, 285],
            "lips": [61, 185, 40, 39, 37, 0, 267, 269, 270, 409, 291, 375, 321, 405, 314, 17, 84, 181, 91, 146]
        ]
        var protectedOffsets: [String: [Int]] = [:]
        var protectedUnion = Set<Int>()
        for (name, indices) in contours {
            let path = CGMutablePath()
            let points = indices.map { CGPoint(x: group.points[$0].x * CGFloat(width),
                                               y: group.points[$0].y * CGFloat(height)) }
            path.addLines(between: points)
            path.closeSubpath()
            let rim = path.copy(strokingWithWidth: 4, lineCap: .round, lineJoin: .round, miterLimit: 2)
            let bounds = path.boundingBoxOfPath.insetBy(dx: -2, dy: -2)
                .intersection(CGRect(x: 0, y: 0, width: width, height: height))
            var offsets: [Int] = []
            if !bounds.isNull, !bounds.isEmpty {
                for y in Int(floor(bounds.minY))..<min(height, Int(ceil(bounds.maxY))) {
                    for x in Int(floor(bounds.minX))..<min(width, Int(ceil(bounds.maxX))) {
                        let center = CGPoint(x: Double(x) + 0.5, y: Double(y) + 0.5)
                        if path.contains(center) || rim.contains(center) { offsets.append((y * width + x) * 4) }
                    }
                }
            }
            XCTAssertFalse(offsets.isEmpty, name)
            protectedOffsets[name] = offsets
            protectedUnion.formUnion(offsets)
        }
        protectedOffsets["union"] = protectedUnion.sorted()
        let allOffsets = Array(stride(from: 0, to: original.count, by: 4))
        func delta(_ current: Data, offsets: [Int]) -> PixelDelta {
            var changed = 0, maximum = 0
            var total: UInt64 = 0
            for offset in offsets {
                var pixelChanged = false
                for channel in 0..<4 {
                    let difference = abs(Int(current[offset + channel]) - Int(original[offset + channel]))
                    maximum = max(maximum, difference)
                    pixelChanged = pixelChanged || difference != 0
                    if channel < 3 { total += UInt64(difference) }
                }
                if pixelChanged { changed += 1 }
            }
            return PixelDelta(pixelCount: offsets.count, changedPixels: changed,
                              maxChannelDifference: maximum,
                              meanRGBDifference: offsets.isEmpty ? 0 : Double(total) / Double(offsets.count * 3))
        }
        func validate(_ result: RenderedPhoto) throws -> Data {
            XCTAssertEqual(result.image.width, width)
            XCTAssertEqual(result.image.height, height)
            XCTAssertEqual(result.image.colorSpace?.name, CGColorSpace.sRGB)
            let pixels = TestImage.pixels(result.image)
            guard pixels.count == original.count else {
                throw NSError(domain: "NoseReferenceReview", code: 4)
            }
            XCTAssertTrue(stride(from: 3, to: pixels.count, by: 4).allSatisfy { pixels[$0] == original[$0] })
            XCTAssertEqual(TestImage.pixels(photo.preview), original, "immutable_source")
            return pixels
        }
        let neutral = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: false)
        let neutralIdentity = try validate(neutral) == original
        XCTAssertTrue(neutralIdentity)
        try await renderer.encodePNG(neutral.image).write(to: directory.appendingPathComponent("neutral.png"), options: .atomic)
        var frames: [FrameReceipt] = []
        let zero = BeautyParameters()
        let tools = ToolCatalog.tools(in: .nose)
        XCTAssertEqual(tools.count, 6)
        for tool in tools {
            for value: Float in [-100, -75, -50, -25, 25, 50, 75, 100] {
                var edit = EditorSnapshot()
                tool.setValue(value, in: &edit.parameters)
                XCTAssertEqual(tool.value(in: edit.parameters), value, accuracy: 0.0001)
                for other in ToolCatalog.canonicalTools where other.field != tool.field {
                    XCTAssertEqual(other.sdkValue(in: edit.parameters), other.sdkValue(in: zero), other.id)
                }
                let result = try await renderer.render(photo, snapshot: edit, fullResolution: false)
                let current = try validate(result)
                XCTAssertEqual(result.detection?.usedFaceCount, 1)
                XCTAssertEqual(result.metrics["beauty.detection.meshPointCount"], 478)
                XCTAssertFalse(result.warningCodes.contains("nose_inputs_missing"), tool.id)
                XCTAssertFalse(result.warningCodes.contains("beauty_strength_capped"), tool.id)
                let regions = protectedOffsets.mapValues { delta(current, offsets: $0) }
                let protectedUnchanged = regions["union"]?.changedPixels == 0
                var repeated: Bool?
                if abs(value) == 100 {
                    let suffix = value < 0 ? "minus-100" : "plus-100"
                    let name = tool.id.replacingOccurrences(of: ".", with: "-") + "-" + suffix + ".png"
                    try await renderer.encodePNG(result.image).write(to: directory.appendingPathComponent(name), options: .atomic)
                    let again = try await renderer.render(photo, snapshot: edit, fullResolution: false)
                    repeated = try validate(again) == current
                    XCTAssertEqual(repeated, true, "endpoint_determinism \(tool.id) \(Int(value))")
                }
                frames.append(FrameReceipt(tool: tool.id, value: Int(value), sdkValue: tool.sdkValue(in: edit.parameters),
                    imageDelta: delta(current, offsets: allOffsets), protectedRegions: regions,
                    protectionAssessment: protectedUnchanged ? "passed_zero_difference" : "failed_nonzero_difference",
                    warningCodes: result.warningCodes, renderMilliseconds: result.renderMilliseconds,
                    actualBackend: result.backendName,
                    endpointDeterministic: repeated))
            }
        }
        let restored = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: false)
        let neutralRestored = try validate(restored) == original
        XCTAssertTrue(neutralRestored)
        XCTAssertEqual(frames.count, 48)
        let imageCount = try manager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "png" }.count
        XCTAssertEqual(imageCount, 13)
        let receipt = RunReceipt(schemaVersion: 1, detector: group.detectorName, meshPointCount: group.points.count,
            width: width, height: height, outputImageCount: imageCount, neutralIdentity: neutralIdentity,
            neutralRestored: neutralRestored,
            protectionAssessment: frames.allSatisfy { $0.protectionAssessment == "passed_zero_difference" }
                ? "passed_zero_difference" : "failed_nonzero_difference",
            protectionDefinition: "Source-fixed complete eye/brow/lip polygons plus a 2-preview-pixel rim; all RGBA channels exact",
            effectQualification: "not_assessed_by_this_harness", frames: frames)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(receipt).write(to: directory.appendingPathComponent("aggregate.json"), options: .atomic)
    }

    /// Owner-opt-in original-resolution export check. Source-fixed protection
    /// and metadata are asserted; this does not qualify perceptual reference parity.
    func testOwnerPortraitNoseOriginalResolutionEndpointsAndRecovery() async throws {
        struct PixelDelta: Encodable {
            let pixelCount: Int
            let changedPixels: Int
            let maxChannelDifference: Int
            let meanRGBDifference: Double
        }
        struct FrameReceipt: Encodable {
            let tool: String
            let value: Int
            let sdkValue: Float
            let imageDelta: PixelDelta
            let protectedRegions: [String: PixelDelta]
            let protectionAssessment: String
            let warningCodes: [String]
            let renderMilliseconds: Double
            let actualBackend: String
            let endpointDeterministic: Bool?
        }
        struct RunReceipt: Encodable {
            let schemaVersion: Int
            let detector: String
            let meshPointCount: Int
            let width: Int
            let height: Int
            let outputImageCount: Int
            let neutralIdentity: Bool
            let neutralRestored: Bool
            let protectionAssessment: String
            let protectionDefinition: String
            let effectQualification: String
            let frames: [FrameReceipt]
        }
        let manager = FileManager.default
        #if targetEnvironment(simulator)
        let root = URL(fileURLWithPath: "/private/tmp/beauty-nose-implementation", isDirectory: true)
        let inputURL = URL(fileURLWithPath: "/private/tmp/beauty-owner-portrait-check.png")
        #else
        let root = try manager.url(for: .documentDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true).appendingPathComponent("OwnerNoseReference", isDirectory: true)
        let inputURL = root.appendingPathComponent("input.png")
        #endif
        let runName = try String(contentsOf: root.appendingPathComponent("run-name.txt"), encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !runName.isEmpty, runName.utf8.count <= 64,
              runName.range(of: "^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$", options: .regularExpression) != nil else {
            throw NSError(domain: "NoseReferenceReview", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid review run name"])
        }
        let directory = root.appendingPathComponent(runName + "-original", isDirectory: true)
        guard !manager.fileExists(atPath: directory.path) else {
            throw NSError(domain: "NoseReferenceReview", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Review run already exists"])
        }
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try ImageInput.readBoundedFile(inputURL)
        let renderer = PhotoRenderer(preferredBackend: .gpu)
        let photo = try await renderer.load(data)
        let width = Int(photo.uprightSize.width), height = Int(photo.uprightSize.height)
        let previewOriginal = TestImage.pixels(photo.preview)
        // Decode and orient the original independently of the SDK's neutral result.
        let imageSource = try XCTUnwrap(CGImageSourceCreateWithData(data as CFData, nil))
        let decoded = try XCTUnwrap(CGImageSourceCreateImageAtIndex(imageSource, 0, nil))
        let oriented = CIImage(cgImage: decoded).oriented(photo.orientation)
        let upright = oriented.transformed(by: CGAffineTransform(
            translationX: -oriented.extent.minX, y: -oriented.extent.minY))
        let sRGB = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB))
        let context = CIContext(options: [.cacheIntermediates: false, .workingColorSpace: sRGB])
        let originalImage = try XCTUnwrap(context.createCGImage(upright, from: upright.extent,
            format: .RGBA8, colorSpace: sRGB, deferred: false))
        XCTAssertEqual(originalImage.width, width)
        XCTAssertEqual(originalImage.height, height)
        XCTAssertGreaterThan(max(width, height), max(photo.preview.width, photo.preview.height),
                             "This opt-in fixture must exercise original-resolution export")
        let original = TestImage.pixels(originalImage)
        let source = try await renderer.landmarks(originalImage)
        let group = try XCTUnwrap(source.first)
        XCTAssertEqual(source.count, 1)
        XCTAssertEqual(group.detectorName, "MediaPipe 478")
        guard group.points.count == 478 else {
            XCTFail("Expected the production dense model")
            throw NSError(domain: "NoseReferenceReview", code: 3)
        }
        // Pinned MediaPipe topology; coordinates and membership stay in memory.
        // Full interiors plus a 2-pixel rim protect tissue and antialiased edges.
        let contours: [String: [Int]] = [
            "leftEye": [33, 7, 163, 144, 145, 153, 154, 155, 133, 173, 157, 158, 159, 160, 161, 246],
            "rightEye": [263, 249, 390, 373, 374, 380, 381, 382, 362, 398, 384, 385, 386, 387, 388, 466],
            "leftBrow": [107, 66, 105, 63, 70, 46, 53, 52, 65, 55],
            "rightBrow": [336, 296, 334, 293, 300, 276, 283, 282, 295, 285],
            "lips": [61, 185, 40, 39, 37, 0, 267, 269, 270, 409, 291, 375, 321, 405, 314, 17, 84, 181, 91, 146]
        ]
        var protectedOffsets: [String: [Int]] = [:]
        var protectedUnion = Set<Int>()
        for (name, indices) in contours {
            let path = CGMutablePath()
            let points = indices.map { CGPoint(x: group.points[$0].x * CGFloat(width),
                                               y: group.points[$0].y * CGFloat(height)) }
            path.addLines(between: points)
            path.closeSubpath()
            let rim = path.copy(strokingWithWidth: 4, lineCap: .round, lineJoin: .round, miterLimit: 2)
            let bounds = path.boundingBoxOfPath.insetBy(dx: -2, dy: -2)
                .intersection(CGRect(x: 0, y: 0, width: width, height: height))
            var offsets: [Int] = []
            if !bounds.isNull, !bounds.isEmpty {
                for y in Int(floor(bounds.minY))..<min(height, Int(ceil(bounds.maxY))) {
                    for x in Int(floor(bounds.minX))..<min(width, Int(ceil(bounds.maxX))) {
                        let center = CGPoint(x: Double(x) + 0.5, y: Double(y) + 0.5)
                        if path.contains(center) || rim.contains(center) { offsets.append((y * width + x) * 4) }
                    }
                }
            }
            XCTAssertFalse(offsets.isEmpty, name)
            protectedOffsets[name] = offsets
            protectedUnion.formUnion(offsets)
        }
        protectedOffsets["union"] = protectedUnion.sorted()
        func delta<Offsets: Sequence>(_ current: Data, offsets: Offsets) -> PixelDelta where Offsets.Element == Int {
            var count = 0, changed = 0, maximum = 0
            var total: UInt64 = 0
            for offset in offsets {
                count += 1
                var pixelChanged = false
                for channel in 0..<4 {
                    let difference = abs(Int(current[offset + channel]) - Int(original[offset + channel]))
                    maximum = max(maximum, difference)
                    pixelChanged = pixelChanged || difference != 0
                    if channel < 3 { total += UInt64(difference) }
                }
                if pixelChanged { changed += 1 }
            }
            return PixelDelta(pixelCount: count, changedPixels: changed,
                              maxChannelDifference: maximum,
                              meanRGBDifference: count == 0 ? 0 : Double(total) / Double(count * 3))
        }
        func validate(_ result: RenderedPhoto) throws -> Data {
            XCTAssertEqual(result.image.width, width)
            XCTAssertEqual(result.image.height, height)
            XCTAssertEqual(result.image.colorSpace?.name, CGColorSpace.sRGB)
            let pixels = TestImage.pixels(result.image)
            guard pixels.count == original.count else {
                throw NSError(domain: "NoseReferenceReview", code: 4)
            }
            XCTAssertTrue(stride(from: 3, to: pixels.count, by: 4).allSatisfy { pixels[$0] == original[$0] })
            XCTAssertTrue(TestImage.pixels(photo.preview) == previewOriginal, "immutable_preview_source")
            XCTAssertTrue(photo.data == data, "immutable_original_source")
            XCTAssertNil(result.metrics["beauty.detection.preparedReuse"], "Export must use fresh original support")
            return pixels
        }
        func writeExport(_ result: RenderedPhoto, name: String, expectedPixels: Data) async throws {
            let encoded = try await renderer.encodePNG(result.image)
            let container = try XCTUnwrap(CGImageSourceCreateWithData(encoded as CFData, nil))
            XCTAssertEqual(CGImageSourceGetCount(container), 1)
            XCTAssertEqual(CGImageSourceGetType(container) as String?, UTType.png.identifier)
            let properties = try XCTUnwrap(CGImageSourceCopyPropertiesAtIndex(container, 0, nil) as? [CFString: Any])
            XCTAssertEqual((properties[kCGImagePropertyOrientation] as? NSNumber)?.intValue, 1)
            let exported = try XCTUnwrap(CGImageSourceCreateImageAtIndex(container, 0, nil))
            XCTAssertEqual(exported.width, width)
            XCTAssertEqual(exported.height, height)
            XCTAssertEqual(exported.colorSpace?.name, CGColorSpace.sRGB)
            XCTAssertTrue(TestImage.pixels(exported) == expectedPixels, "Lossless upright PNG round trip")
            try encoded.write(to: directory.appendingPathComponent(name), options: .atomic)
        }
        let neutral = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: true)
        let neutralIdentity = try validate(neutral) == original
        XCTAssertTrue(neutralIdentity)
        try await writeExport(neutral, name: "neutral.png", expectedPixels: original)
        var frames: [FrameReceipt] = []
        let zero = BeautyParameters()
        let tools = ToolCatalog.tools(in: .nose)
        XCTAssertEqual(tools.count, 6)
        for tool in tools {
            for value: Float in [-100, 100] {
                var edit = EditorSnapshot()
                tool.setValue(value, in: &edit.parameters)
                XCTAssertEqual(tool.value(in: edit.parameters), value, accuracy: 0.0001)
                for other in ToolCatalog.canonicalTools where other.field != tool.field {
                    XCTAssertEqual(other.sdkValue(in: edit.parameters), other.sdkValue(in: zero), other.id)
                }
                let result = try await renderer.render(photo, snapshot: edit, fullResolution: true)
                let current = try validate(result)
                XCTAssertTrue(current != original, "Original-resolution endpoint must change pixels: \(tool.id)")
                XCTAssertEqual(result.detection?.usedFaceCount, 1)
                XCTAssertEqual(result.metrics["beauty.detection.meshPointCount"], 478)
                XCTAssertFalse(result.warningCodes.contains("nose_inputs_missing"), tool.id)
                XCTAssertFalse(result.warningCodes.contains("beauty_strength_capped"), tool.id)
                let regions = protectedOffsets.mapValues { delta(current, offsets: $0) }
                let protectedUnchanged = regions["union"]?.changedPixels == 0
                for (name, region) in regions {
                    XCTAssertEqual(region.changedPixels, 0, "Original-resolution protection: \(tool.id) \(Int(value)) \(name)")
                }
                var repeated: Bool?
                if abs(value) == 100 {
                    let suffix = value < 0 ? "minus-100" : "plus-100"
                    let name = tool.id.replacingOccurrences(of: ".", with: "-") + "-" + suffix + ".png"
                    try await writeExport(result, name: name, expectedPixels: current)
                    let again = try await renderer.render(photo, snapshot: edit, fullResolution: true)
                    repeated = try validate(again) == current
                    XCTAssertEqual(repeated, true, "endpoint_determinism \(tool.id) \(Int(value))")
                }
                frames.append(FrameReceipt(tool: tool.id, value: Int(value), sdkValue: tool.sdkValue(in: edit.parameters),
                    imageDelta: delta(current, offsets: stride(from: 0, to: original.count, by: 4)), protectedRegions: regions,
                    protectionAssessment: protectedUnchanged ? "passed_zero_difference" : "failed_nonzero_difference",
                    warningCodes: result.warningCodes, renderMilliseconds: result.renderMilliseconds,
                    actualBackend: result.backendName,
                    endpointDeterministic: repeated))
            }
        }
        let restored = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: true)
        let neutralRestored = try validate(restored) == original
        XCTAssertTrue(neutralRestored)
        XCTAssertEqual(frames.count, 12)
        let imageCount = try manager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "png" }.count
        XCTAssertEqual(imageCount, 13)
        let receipt = RunReceipt(schemaVersion: 1, detector: group.detectorName, meshPointCount: group.points.count,
            width: width, height: height, outputImageCount: imageCount, neutralIdentity: neutralIdentity,
            neutralRestored: neutralRestored,
            protectionAssessment: frames.allSatisfy { $0.protectionAssessment == "passed_zero_difference" }
                ? "passed_zero_difference" : "failed_nonzero_difference",
            protectionDefinition: "Source-fixed original-resolution complete eye/brow/lip polygons plus a 2-original-pixel rim; all RGBA channels exact",
            effectQualification: "not_assessed_by_this_harness", frames: frames)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(receipt).write(to: directory.appendingPathComponent("aggregate.json"), options: .atomic)
    }

    /// Physical-device endpoint parity with a fixed, small render budget.
    /// All six fields must select the production Metal backend; its shared
    /// nasal sampler remains CPU-owned. Fallback cannot qualify Metal parity.
    func testOwnerPortraitNoseCPUAndGPUParityAndBoundedTiming() async throws {
        #if targetEnvironment(simulator)
        throw XCTSkip("Physical-device Metal comparison; simulator host selects CPU")
        #else
        struct Endpoint: Encodable {
            let tool: String
            let value: Int
            let maxChannelDifference: Int
            let meanRGBDifference: Double
            let cpuBackend: String
            let preferredGPUActualBackend: String
            let cpuMilliseconds: Double
            let preferredGPUMilliseconds: Double
            let cpuWarnings: [String]
            let preferredGPUWarnings: [String]
        }
        struct Timing: Encodable {
            let count: Int
            let medianMilliseconds: Double
            let p95Milliseconds: Double
            let maximumMilliseconds: Double
        }
        struct Receipt: Encodable {
            let schemaVersion: Int
            let scope: String
            let buildConfiguration: String
            let width: Int
            let height: Int
            let warmupRenderCount: Int
            let measuredRenderCount: Int
            let comparisonTolerance: Int
            let actualMetalEndpointCount: Int
            let parityWithinTolerance: Bool
            let cpuTiming: Timing
            let preferredGPUTiming: Timing
            let endpoints: [Endpoint]
        }
        let manager = FileManager.default
        let root = try manager.url(for: .documentDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true).appendingPathComponent("OwnerNoseReference", isDirectory: true)
        let runName = try String(contentsOf: root.appendingPathComponent("run-name.txt"), encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !runName.isEmpty, runName.utf8.count <= 64,
              runName.range(of: "^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$", options: .regularExpression) != nil else {
            throw NSError(domain: "NoseReferenceReview", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid review run name"])
        }
        let receiptURL = root.appendingPathComponent(runName + "-cpu-gpu-parity.json")
        guard !manager.fileExists(atPath: receiptURL.path) else {
            throw NSError(domain: "NoseReferenceReview", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Parity review run already exists"])
        }
        let data = try ImageInput.readBoundedFile(root.appendingPathComponent("input.png"))
        let cpu = PhotoRenderer(preferredBackend: .cpu), gpu = PhotoRenderer(preferredBackend: .gpu)
        let cpuPhoto = try await cpu.load(data), gpuPhoto = try await gpu.load(data)
        let original = TestImage.pixels(cpuPhoto.preview)
        XCTAssertEqual(original, TestImage.pixels(gpuPhoto.preview))
        let width = cpuPhoto.preview.width, height = cpuPhoto.preview.height
        let cpuNeutral = try await cpu.render(cpuPhoto, snapshot: EditorSnapshot(), fullResolution: false)
        let gpuNeutral = try await gpu.render(gpuPhoto, snapshot: EditorSnapshot(), fullResolution: false)
        XCTAssertEqual(TestImage.pixels(cpuNeutral.image), original)
        XCTAssertEqual(TestImage.pixels(gpuNeutral.image), original)
        var warmup = EditorSnapshot()
        ToolCatalog.find("nose.size")!.setValue(25, in: &warmup.parameters)
        _ = try await cpu.render(cpuPhoto, snapshot: warmup, fullResolution: false)
        _ = try await gpu.render(gpuPhoto, snapshot: warmup, fullResolution: false)
        var endpoints: [Endpoint] = []
        for tool in ToolCatalog.tools(in: .nose) {
            for value: Float in [-100, 100] {
                var snapshot = EditorSnapshot()
                tool.setValue(value, in: &snapshot.parameters)
                let cpuResult = try await cpu.render(cpuPhoto, snapshot: snapshot, fullResolution: false)
                let gpuResult = try await gpu.render(gpuPhoto, snapshot: snapshot, fullResolution: false)
                let cpuPixels = TestImage.pixels(cpuResult.image), gpuPixels = TestImage.pixels(gpuResult.image)
                for result in [cpuResult, gpuResult] {
                    XCTAssertEqual(result.image.width, width)
                    XCTAssertEqual(result.image.height, height)
                    XCTAssertEqual(result.image.colorSpace?.name, CGColorSpace.sRGB)
                    XCTAssertEqual(result.detection?.usedFaceCount, 1)
                    XCTAssertEqual(result.metrics["beauty.detection.meshPointCount"], 478)
                    XCTAssertTrue(result.renderMilliseconds.isFinite && result.renderMilliseconds >= 0)
                }
                guard cpuPixels.count == original.count, gpuPixels.count == original.count else {
                    throw NSError(domain: "NoseReferenceReview", code: 4)
                }
                XCTAssertNotEqual(cpuPixels, original, tool.id)
                XCTAssertNotEqual(gpuPixels, original, tool.id)
                XCTAssertEqual(cpuResult.backendName, "CPU")
                XCTAssertEqual(gpuResult.backendName, "Metal", tool.id)
                XCTAssertTrue(stride(from: 3, to: original.count, by: 4).allSatisfy {
                    cpuPixels[$0] == original[$0] && gpuPixels[$0] == original[$0]
                })
                var maximum = 0
                var totalRGB: UInt64 = 0
                for index in 0..<original.count {
                    let difference = abs(Int(cpuPixels[index]) - Int(gpuPixels[index]))
                    maximum = max(maximum, difference)
                    if index % 4 != 3 { totalRGB += UInt64(difference) }
                }
                XCTAssertLessThanOrEqual(maximum, 1, "\(tool.id) \(Int(value))")
                endpoints.append(Endpoint(tool: tool.id, value: Int(value), maxChannelDifference: maximum,
                    meanRGBDifference: Double(totalRGB) / Double(width * height * 3),
                    cpuBackend: cpuResult.backendName, preferredGPUActualBackend: gpuResult.backendName,
                    cpuMilliseconds: cpuResult.renderMilliseconds, preferredGPUMilliseconds: gpuResult.renderMilliseconds,
                    cpuWarnings: cpuResult.warningCodes, preferredGPUWarnings: gpuResult.warningCodes))
            }
        }
        XCTAssertEqual(endpoints.count, 12)
        XCTAssertEqual(TestImage.pixels(cpuPhoto.preview), original)
        XCTAssertEqual(TestImage.pixels(gpuPhoto.preview), original)
        func timing(_ samples: [Double]) -> Timing {
            let sorted = samples.sorted()
            let middle = sorted.count / 2
            let median = sorted.count.isMultiple(of: 2) ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle]
            let p95 = sorted[min(sorted.count - 1, Int(ceil(Double(sorted.count) * 0.95)) - 1)]
            return Timing(count: sorted.count, medianMilliseconds: median, p95Milliseconds: p95,
                          maximumMilliseconds: sorted.last ?? 0)
        }
        let metalCount = endpoints.filter { $0.preferredGPUActualBackend == "Metal" }.count
        XCTAssertEqual(metalCount, 12)
        #if DEBUG
        let buildConfiguration = "Debug"
        #else
        let buildConfiguration = "Release"
        #endif
        let receipt = Receipt(schemaVersion: 1,
            scope: "Owner photo, 960-pixel preview, twelve isolated signed endpoints; bounded \(buildConfiguration) timings, not FPS or sustained/thermal claims",
            buildConfiguration: buildConfiguration,
            width: width, height: height, warmupRenderCount: 4, measuredRenderCount: 24, comparisonTolerance: 1,
            actualMetalEndpointCount: metalCount,
            parityWithinTolerance: endpoints.allSatisfy { $0.maxChannelDifference <= 1 },
            cpuTiming: timing(endpoints.map(\.cpuMilliseconds)), preferredGPUTiming: timing(endpoints.map(\.preferredGPUMilliseconds)),
            endpoints: endpoints)
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(receipt).write(to: receiptURL, options: .atomic)
        #endif
    }

    func testOwnerPortraitNoseRangeCompositionAndDebugReDetection() async throws {
        let renderer = PhotoRenderer()
        let data = try ImageInput.readBoundedFile(URL(fileURLWithPath: "/private/tmp/beauty-editor-owner-check.png"))
        let photo = try await renderer.load(data)
        XCTAssertLessThanOrEqual(max(photo.preview.width, photo.preview.height), 960)
        let original = TestImage.pixels(photo.preview)
        let source = try await renderer.landmarks(photo.preview)
        XCTAssertFalse(source.isEmpty)
        for tool in ToolCatalog.tools(in: .nose) {
            var previous = original
            for value: Float in [-100, -75, -50, -25, 25, 50, 75, 100] {
                var edit = EditorSnapshot()
                tool.setValue(value, in: &edit.parameters)
                let result = try await renderer.render(photo, snapshot: edit, fullResolution: false)
                let current = TestImage.pixels(result.image)
                print("NOSE_PREVIEW \(tool.id) \(Int(value)) ms=\(result.renderMilliseconds)")
                XCTAssertEqual(result.image.width, photo.preview.width)
                XCTAssertEqual(result.image.height, photo.preview.height)
                XCTAssertEqual(result.image.colorSpace?.name, CGColorSpace.sRGB)
                XCTAssertTrue(stride(from: 3, to: current.count, by: 4).allSatisfy { current[$0] == original[$0] })
                XCTAssertEqual(TestImage.pixels(photo.preview), original, "immutable_source")
                XCTAssertNotEqual(previous, current, tool.id)
                XCTAssertEqual(result.detection?.usedFaceCount, 1, "\(tool.id) \(Int(value)) \(result.detection?.reasons.map(\.rawValue) ?? [])")
                XCTAssertFalse(result.warningCodes.contains("nose_inputs_missing"), tool.id)
                XCTAssertFalse(result.warningCodes.contains("beauty_strength_capped"), tool.id)
                previous = current
            }
        }
        var combined = EditorSnapshot()
        for id in ["face.width", "eye.innerCorner", "nose.ala", "nose.root", "mouth.width"] {
            let previous = combined.parameters
            let tool = ToolCatalog.find(id)!
            tool.setValue(71, in: &combined.parameters)
            for other in ToolCatalog.canonicalTools where other.field != tool.field {
                XCTAssertEqual(other.sdkValue(in: previous), other.sdkValue(in: combined.parameters), other.id)
            }
        }
        let output = try await renderer.render(photo, snapshot: combined, fullResolution: false)
        XCTAssertFalse(output.warningCodes.contains("combined_geometry_weakened"))
        let points = try await renderer.landmarks(output.image)
        XCTAssertFalse(points.isEmpty)
        let repeatResult = try await renderer.render(photo, snapshot: combined, fullResolution: false)
        XCTAssertEqual(TestImage.pixels(output.image), TestImage.pixels(repeatResult.image))
        XCTAssertNotEqual(original, TestImage.pixels(output.image))
    }
    func testOwnerPortraitFaceEditingChangesPixelsAndRepeats() async throws {
        let renderer = PhotoRenderer()
        let data = try ImageInput.readBoundedFile(URL(fileURLWithPath: "/private/tmp/beauty-editor-owner-check.png"))
        let photo = try await renderer.load(data)
        var shape = EditorSnapshot()
        shape.parameters.faceSlim = 0.8
        let first = try await renderer.render(photo, snapshot: shape, fullResolution: false)
        let second = try await renderer.render(photo, snapshot: shape, fullResolution: false)
        XCTAssertEqual(first.detection?.usedFaceCount, 1)
        XCTAssertNotEqual(TestImage.pixels(first.image), TestImage.pixels(photo.preview))
        XCTAssertEqual(TestImage.pixels(first.image), TestImage.pixels(second.image))
        XCTAssertEqual(first.image.width, photo.preview.width)
        XCTAssertEqual(first.image.height, photo.preview.height)
    }
    func testOwnerVisionRuntimeDiagnostic() async throws {
        let data = try ImageInput.readBoundedFile(URL(fileURLWithPath: "/private/tmp/beauty-editor-owner-check.png"))
        let photo = try await PhotoRenderer().load(data)
        var receipts: [[String: Any]] = []
        for cpuOnly in [false, true] {
            let request = VNDetectFaceLandmarksRequest()
            if cpuOnly {
                for (stage, devices) in try request.supportedComputeStageDevices {
                    if let cpu = devices.first(where: { if case .cpu = $0 { return true }; return false }) {
                        request.setComputeDevice(cpu, for: stage)
                    }
                }
            }
            do {
                try VNImageRequestHandler(cgImage: photo.preview, orientation: .up).perform([request])
                receipts.append(["cpu_only": cpuOnly, "faces": request.results?.count ?? 0, "status": "available"])
            } catch {
                let error = error as NSError
                receipts.append(["cpu_only": cpuOnly, "status": "unavailable", "domain": error.domain, "code": error.code])
            }
        }
        for quality in [VNGeneratePersonSegmentationRequest.QualityLevel.fast, .balanced, .accurate] {
            let request = VNGeneratePersonSegmentationRequest()
            request.qualityLevel = quality
            request.outputPixelFormat = kCVPixelFormatType_OneComponent8
            do {
                for (stage, devices) in try request.supportedComputeStageDevices {
                    if let cpu = devices.first(where: { if case .cpu = $0 { return true }; return false }) {
                        request.setComputeDevice(cpu, for: stage)
                    }
                }
                try VNImageRequestHandler(cgImage: photo.preview, orientation: .up).perform([request])
                var maximum: UInt8 = 0
                var admitted = 0
                if let buffer = request.results?.first?.pixelBuffer {
                    CVPixelBufferLockBaseAddress(buffer, .readOnly)
                    if let base = CVPixelBufferGetBaseAddress(buffer)?.assumingMemoryBound(to: UInt8.self) {
                        let w = CVPixelBufferGetWidth(buffer), h = CVPixelBufferGetHeight(buffer)
                        let stride = CVPixelBufferGetBytesPerRow(buffer)
                        for y in 0..<h { for x in 0..<w {
                            maximum = max(maximum, base[y * stride + x])
                            if base[y * stride + x] >= 128 { admitted += 1 }
                        } }
                    }
                    CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
                }
                receipts.append(["request": "person", "quality": quality.rawValue,
                                 "results": request.results?.count ?? 0, "status": "available",
                                 "maximum": maximum, "foreground_pixels": admitted])
            } catch {
                let error = error as NSError
                receipts.append(["request": "person", "quality": quality.rawValue,
                                 "status": "unavailable", "domain": error.domain, "code": error.code])
            }
        }
        let attachment = XCTAttachment(data: try JSONSerialization.data(withJSONObject: receipts, options: [.sortedKeys]),
                                       uniformTypeIdentifier: UTType.json.identifier)
        attachment.name = "vision-runtime-aggregate-diagnostic"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    // Explicit owner validation only. The image is supplied temporarily by the
    // validation command; it is never bundled or copied into this project.
    func testOwnerPortraitChangesFacePixelsAndPreservesBackground() async throws {
        let renderer = PhotoRenderer()
        let data = try ImageInput.readBoundedFile(URL(fileURLWithPath: "/private/tmp/beauty-editor-owner-check.png"))
        let photo = try await renderer.load(data)
        let original = TestImage.pixels(photo.preview)
        var shape = EditorSnapshot()
        shape.parameters.faceSlim = 0.8
        let first = try await renderer.render(photo, snapshot: shape, fullResolution: false)
        let second = try await renderer.render(photo, snapshot: shape, fullResolution: false)
        XCTAssertEqual(first.detection?.usedFaceCount, 1, "\(String(describing: first.detection))")
        XCTAssertNotEqual(TestImage.pixels(first.image), original)
        XCTAssertEqual(TestImage.pixels(first.image), TestImage.pixels(second.image))
        var tone = EditorSnapshot()
        tone.parameters.brightness = 0.2
        let edited = try await renderer.render(photo, snapshot: tone, fullResolution: false)
        tone.protectBackground = true
        let protected = try await renderer.render(photo, snapshot: tone, fullResolution: false)
        let result = TestImage.pixels(protected.image)
        let unprotected = TestImage.pixels(edited.image)
        XCTAssertNotEqual(result, original)
        var unprotectedChanges = 0
        // This fixture's central side margins are background; lower corners are clothing.
        for y in (photo.preview.height / 4)..<(photo.preview.height * 3 / 4) {
            for x in [0, 1, photo.preview.width - 2, photo.preview.width - 1] {
                let index = (y * photo.preview.width + x) * 4
                XCTAssertEqual(result[index..<(index + 4)], original[index..<(index + 4)])
                if unprotected[index..<(index + 4)] != original[index..<(index + 4)] { unprotectedChanges += 1 }
            }
        }
        XCTAssertGreaterThan(unprotectedChanges, 0)
    }
    #endif
    func testImportNormalizesAllEXIFOrientations() async throws {
        let renderer = PhotoRenderer()
        let context = CIContext(options: [.cacheIntermediates: false])
        let source = TestImage.image()
        for raw in UInt32(1)...8 {
            let imported = try await renderer.load(TestImage.encoded(orientation: raw))
            let expected = CIImage(cgImage: source).oriented(CGImagePropertyOrientation(rawValue: raw)!)
            let normalized = context.createCGImage(expected, from: expected.extent,
                                                   format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))!
            XCTAssertEqual(imported.preview.width, Int(imported.uprightSize.width))
            XCTAssertEqual(imported.preview.height, Int(imported.uprightSize.height))
            XCTAssertEqual(TestImage.pixels(imported.preview), TestImage.pixels(normalized), "EXIF \(raw)")
        }
    }
    func testNeutralAndNoFaceGeometryKeepActualPixelsAndRecoverAfterFailure() async throws {
        let renderer = PhotoRenderer()
        do {
            _ = try await renderer.load(Data([0, 1, 2]))
            XCTFail("Corrupt input accepted")
        } catch { XCTAssertEqual(error as? EditorError, .invalidImage) }
        let photo = try await renderer.load(TestImage.encoded())
        let neutral = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: false)
        XCTAssertEqual(TestImage.pixels(neutral.image), TestImage.pixels(photo.preview))
        var active = EditorSnapshot()
        active.parameters.mouthWidth = -0.6
        let noFace = try await renderer.render(photo, snapshot: active, fullResolution: false)
        let summary = try XCTUnwrap(noFace.detection)
        if summary.availability == .skipped {
            // Typed detector unavailability must remain safe on any runtime.
            XCTAssertEqual(summary.reasons, [.detectorUnavailable])
        } else { XCTAssertEqual(summary.availability, .noFace) }
        XCTAssertEqual(summary.usedFaceCount, 0)
        XCTAssertEqual(TestImage.pixels(noFace.image), TestImage.pixels(photo.preview))
        let repeatNeutral = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: false)
        XCTAssertEqual(TestImage.pixels(repeatNeutral.image), TestImage.pixels(neutral.image))
    }
    func testRealSDKToneOutputChangesAndIsDeterministic() async throws {
        let renderer = PhotoRenderer()
        let photo = try await renderer.load(TestImage.encoded())
        var edit = EditorSnapshot()
        edit.parameters.brightness = 0.2
        let one = try await renderer.render(photo, snapshot: edit, fullResolution: false)
        let two = try await renderer.render(photo, snapshot: edit, fullResolution: false)
        XCTAssertNotEqual(TestImage.pixels(one.image), TestImage.pixels(photo.preview))
        XCTAssertEqual(TestImage.pixels(one.image), TestImage.pixels(two.image))
        XCTAssertEqual(one.image.width, photo.preview.width)
        XCTAssertEqual(one.image.height, photo.preview.height)
        XCTAssertEqual(one.image.colorSpace?.name, CGColorSpace.sRGB)
    }
    func testDisplayP3AndNonOpaqueAlphaAreCanonicalizedAndPreserved() async throws {
        var bytes = [UInt8](repeating: 0, count: 64 * 96 * 4)
        for y in 24..<72 { for x in 12..<52 {
            let i = (y * 64 + x) * 4
            bytes[i] = 70; bytes[i + 1] = 45; bytes[i + 2] = 25; bytes[i + 3] = 128
        } }
        let provider = CGDataProvider(data: Data(bytes) as CFData)!
        let image = CGImage(width: 64, height: 96, bitsPerComponent: 8, bitsPerPixel: 32,
            bytesPerRow: 256, space: CGColorSpace(name: CGColorSpace.displayP3)!,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
        let data = NSMutableData()
        let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, image, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        let renderer = PhotoRenderer()
        let photo = try await renderer.load(data as Data)
        XCTAssertEqual(photo.preview.colorSpace?.name, CGColorSpace.sRGB)
        let neutral = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: true)
        XCTAssertEqual(TestImage.pixels(neutral.image), TestImage.pixels(photo.preview))
        var tone = EditorSnapshot(); tone.parameters.brightness = 0.2
        let edited = try await renderer.render(photo, snapshot: tone, fullResolution: true)
        let before = TestImage.pixels(neutral.image), after = TestImage.pixels(edited.image)
        let alpha = stride(from: 3, to: before.count, by: 4).map { before[$0] }
        XCTAssertTrue(alpha.contains(0) && alpha.contains(128))
        XCTAssertEqual(alpha, stride(from: 3, to: after.count, by: 4).map { after[$0] })
    }
    func testExportRendersOriginalResolutionAndStripsSourceMetadata() async throws {
        let renderer = PhotoRenderer()
        let source = TestImage.encoded(width: 1700, height: 80, orientation: 6, type: .jpeg,
            metadata: [kCGImagePropertyTIFFDictionary: [kCGImagePropertyTIFFMake: "SyntheticFixture"],
                       kCGImagePropertyGPSDictionary: [kCGImagePropertyGPSLatitude: 0]])
        let photo = try await renderer.load(source)
        XCTAssertLessThan(photo.preview.height, 1700)
        let result = try await renderer.render(photo, snapshot: EditorSnapshot(), fullResolution: true)
        XCTAssertEqual(result.image.width, 80)
        XCTAssertEqual(result.image.height, 1700)
        let data = try await renderer.encodePNG(result.image)
        let output = CGImageSourceCreateWithData(data as CFData, nil)!
        let properties = CGImageSourceCopyPropertiesAtIndex(output, 0, nil) as! [CFString: Any]
        XCTAssertNil(properties[kCGImagePropertyGPSDictionary])
        let tiff = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any]
        XCTAssertNil(tiff?[kCGImagePropertyTIFFMake])
        XCTAssertEqual((properties[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue, 80)
        XCTAssertEqual((properties[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue, 1700)
        XCTAssertEqual((properties[kCGImagePropertyOrientation] as? NSNumber)?.intValue ?? 1, 1)
        let decoded = CGImageSourceCreateImageAtIndex(output, 0, nil)!
        XCTAssertEqual(TestImage.pixels(decoded), TestImage.pixels(result.image))
    }
    func testBackgroundProtectionRejectsNoPersonWithoutFakeSuccess() async throws {
        let renderer = PhotoRenderer()
        let photo = try await renderer.load(TestImage.encoded())
        var snapshot = EditorSnapshot()
        snapshot.protectBackground = true
        do {
            _ = try await renderer.render(photo, snapshot: snapshot, fullResolution: false)
            XCTFail("No-person image should not enable protection")
        } catch { XCTAssertEqual(error as? EditorError, .backgroundUnavailable) }
    }
}

actor FakeRenderer: PhotoRendering {
    private let actual = PhotoRenderer()
    private(set) var exportSnapshot: EditorSnapshot?
    private(set) var renderCount = 0
    private(set) var previewValues: [Float] = []
    private(set) var landmarkCount = 0
    func load(_ data: Data) async throws -> ImportedPhoto { try await actual.load(data) }
    func render(_ photo: ImportedPhoto, snapshot: EditorSnapshot, fullResolution: Bool) async throws -> RenderedPhoto {
        renderCount += 1
        if fullResolution { exportSnapshot = snapshot }
        else { previewValues.append(snapshot.parameters.faceSlim) }
        // Deliberately finish old jobs despite cancellation to exercise the model's revision gate.
        let delay = snapshot.parameters.faceSlim < 0.5 ? 150 : 20
        await withCheckedContinuation { continuation in
            Task {
                try? await Task.sleep(for: .milliseconds(delay))
                continuation.resume()
            }
        }
        return RenderedPhoto(image: photo.preview, detection: .notRun, warningCount: 0)
    }
    func landmarks(_ image: CGImage) async throws -> [DebugLandmarkGroup] {
        landmarkCount += 1
        // Complete canceled work too, exercising the independent debug revision gate.
        await withCheckedContinuation { continuation in
            Task { try? await Task.sleep(for: .milliseconds(80)); continuation.resume() }
        }
        return [DebugLandmarkGroup(id: "nose", points: [CGPoint(x: 0.5, y: 0.5)])]
    }
    func encodePNG(_ image: CGImage) async throws -> Data { try await actual.encodePNG(image) }
}

@MainActor struct DeniedWriter: PhotoLibrarySaving {
    func save(_ data: Data) async throws { throw EditorError.saveDenied }
}

@MainActor final class EditorSessionTests: XCTestCase {
    func testFaceReferenceContinuousDragGroupsHistoryAndPreservesOtherCategories() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        let siblings: [(BeautyCategory, String, Float)] = [
            (.eye, "eye.irisSize", 37.125), (.nose, "nose.ala", -41.25), (.mouth, "mouth.width", 45.5)
        ]
        for (category, id, value) in siblings {
            model.selectCategory(category)
            model.selectTool(try XCTUnwrap(ToolCatalog.find(id)))
            model.updateValue(value)
            model.endAdjustment()
        }
        model.selectCategory(.face)
        let baseline = model.snapshot
        let adjustments: [(String, Float)] = [("face.width", -63.75), ("face.chinLength", 44.125),
            ("face.chinPoint", -28.5), ("face.vShape", 91.375), ("face.contourSmooth", 37.125),
            ("face.jawAngle", -31.75), ("face.jawline", 72.625)]
        var snapshots = [baseline]
        for (id, value) in adjustments {
            model.selectTool(try XCTUnwrap(ToolCatalog.find(id)))
            let count = model.history.undoStack.count
            model.beginAdjustment()
            model.updateValue(value / 2)
            model.updateValue(value)
            model.endAdjustment()
            XCTAssertEqual(model.history.undoStack.count, count + 1, id)
            XCTAssertEqual(model.value, value, accuracy: 0.0001, id)
            XCTAssertEqual(model.snapshot.parameters.pupilSize, baseline.parameters.pupilSize)
            XCTAssertEqual(model.snapshot.parameters.noseWingSlim, baseline.parameters.noseWingSlim)
            XCTAssertEqual(model.snapshot.parameters.mouthWidth, baseline.parameters.mouthWidth)
            snapshots.append(model.snapshot)
        }
        XCTAssertEqual(model.snapshot.parameters.jawSlim, -0.142875, accuracy: 0.000001)
        XCTAssertEqual(model.value, 72.625, accuracy: 0.0001)
        for snapshot in snapshots.dropLast().reversed() {
            model.undo()
            XCTAssertEqual(model.snapshot, snapshot)
        }
        for snapshot in snapshots.dropFirst() {
            model.redo()
            XCTAssertEqual(model.snapshot, snapshot)
        }
        let beforeReset = model.snapshot
        model.resetCurrentTool()
        XCTAssertEqual(model.value, 0, accuracy: 0.0001)
        model.undo()
        XCTAssertEqual(model.snapshot, beforeReset)
    }

    func testDisabledDoubleChinToolsCannotSelectOrPolluteHistory() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        XCTAssertEqual(model.selectedToolID, "face.width")
        model.updateValue(37.125)
        model.endAdjustment()
        let adjusted = model.snapshot
        model.undo()
        let neutral = model.snapshot
        let undo = model.history.undoStack
        let redo = model.history.redoStack
        let revision = model.revision
        for id in ["face.doubleChin", "face.doubleChinRefine"] {
            model.selectTool(try XCTUnwrap(ToolCatalog.find(id)))
            XCTAssertEqual(model.selectedToolID, "face.width", id)
            XCTAssertEqual(model.category, .face, id)
            XCTAssertEqual(model.snapshot, neutral, id)
            XCTAssertEqual(model.history.undoStack, undo, id)
            XCTAssertEqual(model.history.redoStack, redo, id)
            XCTAssertEqual(model.revision, revision, id)
            XCTAssertNil(model.errorMessage, id)
            XCTAssertNil(model.successMessage, id)
        }
        model.redo()
        XCTAssertEqual(model.snapshot, adjusted)
        XCTAssertEqual(model.value, 37.125, accuracy: 0.0001)
        XCTAssertEqual(model.snapshot.parameters.doubleChinReduction, 0)
        XCTAssertEqual(model.snapshot.parameters.doubleChinReductionPro, 0)
    }

    func testDisabledEyeToolsCannotSelectOrPolluteHistory() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        model.selectCategory(.eye)
        model.selectTool(try XCTUnwrap(ToolCatalog.find("eye.irisSize")))
        model.updateValue(37.125)
        model.endAdjustment()
        let adjusted = model.snapshot
        model.undo()
        let neutral = model.snapshot
        let undo = model.history.undoStack
        let redo = model.history.redoStack
        let revision = model.revision
        for id in ["eye.lidLift", "eye.gazeCorrection", "eye.symmetry", "eye.redness"] {
            model.selectTool(try XCTUnwrap(ToolCatalog.find(id)))
            XCTAssertEqual(model.selectedToolID, "eye.irisSize", id)
            XCTAssertEqual(model.category, .eye, id)
            XCTAssertEqual(model.snapshot, neutral, id)
            XCTAssertEqual(model.history.undoStack, undo, id)
            XCTAssertEqual(model.history.redoStack, redo, id)
            XCTAssertEqual(model.revision, revision, id)
        }
        model.redo()
        XCTAssertEqual(model.snapshot, adjusted)
        XCTAssertEqual(model.value, 37.125, accuracy: 0.0001)
    }

    func testFirstFiveEyeContinuousValuesKeepIndependentHistory() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        model.selectCategory(.eye)
        let adjustments: [(String, Float)] = [("eye.size", -63.75), ("eye.positionY", 44.125),
                                             ("eye.eyelidSize", -28.5), ("eye.length", 91.375),
                                             ("eye.spacing", 37.125)]
        var snapshots = [model.snapshot]
        for (id, value) in adjustments {
            model.selectTool(try XCTUnwrap(ToolCatalog.find(id)))
            let priorCount = model.history.undoStack.count
            model.beginAdjustment()
            model.updateValue(value / 2)
            model.updateValue(value)
            model.endAdjustment()
            XCTAssertEqual(model.history.undoStack.count, priorCount + 1, id)
            XCTAssertEqual(model.value, value, accuracy: 0.0001, id)
            snapshots.append(model.snapshot)
        }
        for (id, value) in adjustments {
            model.selectTool(try XCTUnwrap(ToolCatalog.find(id)))
            XCTAssertEqual(model.value, value, accuracy: 0.0001, id)
        }
        for snapshot in snapshots.dropLast().reversed() {
            model.undo()
            XCTAssertEqual(model.snapshot, snapshot)
        }
        for snapshot in snapshots.dropFirst() {
            model.redo()
            XCTAssertEqual(model.snapshot, snapshot)
        }
        let beforeReset = model.snapshot
        model.resetCurrentTool()
        XCTAssertEqual(model.value, 0, accuracy: 0.0001)
        model.undo()
        XCTAssertEqual(model.snapshot, beforeReset)
    }

    func testEyeSizeAndIrisSlidersKeepIndependentHistoryAndNeutralReset() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        model.selectCategory(.eye)
        XCTAssertEqual(model.selectedToolID, "eye.size")
        model.updateValue(-80); model.endAdjustment()
        let small = model.snapshot
        model.selectTool(ToolCatalog.find("eye.irisSize")!)
        model.updateValue(60); model.endAdjustment()
        XCTAssertEqual(model.snapshot.parameters.eyeSize, -0.36, accuracy: 0.0001)
        XCTAssertEqual(model.snapshot.parameters.pupilSize, 0.15, accuracy: 0.0001)
        XCTAssertEqual(model.snapshot.parameters.eyeHeight, 0)
        model.undo()
        XCTAssertEqual(model.snapshot, small)
        model.redo()
        XCTAssertEqual(model.value, 60, accuracy: 0.0001)
        model.resetCurrentTool()
        XCTAssertEqual(model.value, 0, accuracy: 0.0001)
        XCTAssertEqual(model.snapshot, small)
        model.selectTool(ToolCatalog.find("eye.size")!)
        XCTAssertEqual(model.value, -80, accuracy: 0.0001)
        model.confirmEditing(); model.resumeEditing()
        model.updateValue(80); model.endAdjustment()
        model.cancelEditing()
        XCTAssertEqual(model.snapshot, small)
    }

    func testThrottleKeepsLatestAndReleaseFlushesPendingTimer() async throws {
        let renderer = FakeRenderer()
        let model = EditorModel(renderer: renderer, previewInterval: .seconds(2))
        try await load(model)
        model.updateValue(20)
        try await wait { !model.isRendering && model.displayedRevision == model.revision }
        model.updateValue(30); model.updateValue(40); model.updateValue(90)
        try await Task.sleep(for: .milliseconds(30))
        let beforeRelease = await renderer.renderCount
        XCTAssertEqual(beforeRelease, 1, "The pending timer must coalesce values")
        let start = ContinuousClock.now
        model.endAdjustment()
        try await wait { !model.isRendering && model.displayedRevision == model.revision }
        XCTAssertLessThan(start.duration(to: .now), .seconds(1), "Release must bypass the two-second throttle")
        let values = await renderer.previewValues
        XCTAssertEqual(values.count, 2)
        XCTAssertEqual(values.last!, 0.54, accuracy: 0.0001, "Only the latest pending snapshot renders")
        XCTAssertEqual(model.history.undoStack.count, 1)
    }

    func testDebugAnalysisWaitsForDragToFinishWithoutStarvingPreview() async throws {
        let renderer = FakeRenderer()
        let model = EditorModel(renderer: renderer)
        try await load(model)
        model.toggleDebug()
        try await wait { !model.isDebugAnalyzing }
        let initial = await renderer.landmarkCount
        model.updateValue(20)
        try await wait { !model.isRendering && model.displayedRevision == model.revision }
        let dragging = await renderer.landmarkCount
        XCTAssertEqual(dragging, initial, "No fresh output detection while dragging")
        XCTAssertEqual(model.debugRevision, -1)
        model.endAdjustment()
        try await wait { !model.isDebugAnalyzing && model.debugRevision == model.displayedRevision }
        let settled = await renderer.landmarkCount
        XCTAssertEqual(settled, initial + 1, "One final output detection; original remains cached")
    }

    func testCategorySelectionRetainsValuesAndGroupsUndo() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        model.beginAdjustment()
        model.updateValue(20)
        model.updateValue(60)
        model.endAdjustment()
        XCTAssertEqual(model.history.undoStack.count, 1)
        model.selectCategory(.mouth)
        model.selectTool(ToolCatalog.find("mouth.width")!)
        model.updateValue(-40)
        model.endAdjustment()
        model.selectCategory(.face)
        XCTAssertEqual(model.value, 60, accuracy: 0.001)
        model.undo()
        XCTAssertEqual(model.snapshot.parameters.mouthWidth, 0)
        XCTAssertEqual(model.snapshot.parameters.faceSlim, 0.36, accuracy: 0.0001)
        model.redo()
        XCTAssertEqual(model.snapshot.parameters.mouthWidth, -0.14, accuracy: 0.0001)
    }
    func testCommittedTransactionAndCancelRestoreConfirmedParameters() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        model.updateValue(30)
        model.confirmEditing()
        XCTAssertFalse(model.isEditing)
        model.resumeEditing()
        model.updateValue(80)
        model.endAdjustment()
        model.cancelEditing()
        XCTAssertEqual(model.snapshot.parameters.faceSlim, 0.18, accuracy: 0.0001)
        XCTAssertEqual(model.snapshot, model.committed)
        XCTAssertFalse(model.isEditing)
    }
    func testFinalPreviewCannotBeOverwrittenByOlderWorker() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        model.updateValue(20)
        try await Task.sleep(for: .milliseconds(140))
        model.updateValue(90)
        model.endAdjustment()
        let latest = model.revision
        try await wait { !model.isRendering && model.displayedRevision == latest }
        try await Task.sleep(for: .milliseconds(200))
        XCTAssertEqual(model.displayedRevision, latest)
        XCTAssertEqual(model.snapshot.parameters.faceSlim, 0.54, accuracy: 0.0001)
    }
    func testContinuousDragDisplaysCompletedFramesWhileLatestIsPending() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        let importedRevision = model.displayedRevision
        model.updateValue(20)
        try await Task.sleep(for: .milliseconds(140))
        model.updateValue(40)
        try await wait { model.displayedRevision > importedRevision }
        XCTAssertTrue(model.isRendering)
        XCTAssertLessThan(model.displayedRevision, model.revision)
        model.endAdjustment()
        try await wait { !model.isRendering && model.displayedRevision == model.revision }
    }
    func testFailedReplacementPreservesOriginalSession() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        model.updateValue(40)
        model.endAdjustment()
        let id = model.photo!.id
        model.importPhoto(Data([0, 1]))
        try await wait { !model.isLoading }
        XCTAssertEqual(model.photo!.id, id)
        XCTAssertEqual(model.snapshot.parameters.faceSlim, 0.24, accuracy: 0.0001)
        XCTAssertNotNil(model.errorMessage)
        try await wait { !model.isRendering && model.displayedRevision == model.revision }
    }
    func testExportUsesCurrentSnapshotAndSaveDenialPreservesEdits() async throws {
        let renderer = FakeRenderer()
        let model = EditorModel(renderer: renderer, photoWriter: DeniedWriter())
        try await load(model)
        model.updateValue(70)
        model.endAdjustment()
        model.saveToPhotos()
        XCTAssertTrue(model.isExporting)
        model.updateValue(10)
        try await wait { !model.isExporting }
        let snapshot = await renderer.exportSnapshot
        XCTAssertEqual(snapshot?.parameters.faceSlim ?? 0, 0.42, accuracy: 0.0001)
        XCTAssertEqual(model.snapshot.parameters.faceSlim, 0.42, accuracy: 0.0001)
        XCTAssertEqual(model.errorMessage, EditorError.saveDenied.localizedDescription)
        XCTAssertNotNil(model.photo)
    }
    func testUnavailableToolAndUnspecifiedCategoriesDoNotChangeState() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        model.selectCategory(.sculpt)
        model.selectCategory(.management)
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.category, .face)
        model.selectCategory(.eye)
        let id = model.selectedToolID
        model.selectTool(ToolCatalog.find("eye.fatRemoval")!)
        XCTAssertEqual(model.selectedToolID, id)
        XCTAssertEqual(model.snapshot.parameters.upperEyelidFullnessReduction, 0)
        XCTAssertNil(model.errorMessage)
    }
    func testIndependentFullRangeCombinationAndUndoRestorePreviousValues() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        try await load(model)
        model.updateValue(100); model.endAdjustment()
        model.selectCategory(.eye)
        model.selectTool(ToolCatalog.find("eye.innerCorner")!)
        model.updateValue(100); model.endAdjustment()
        model.selectCategory(.nose)
        model.selectTool(ToolCatalog.find("nose.ala")!)
        model.updateValue(100); model.endAdjustment()
        XCTAssertEqual(model.snapshot.parameters.faceSlim, 0.6)
        XCTAssertEqual(model.snapshot.parameters.innerCornerOpen, 0.25)
        XCTAssertEqual(model.snapshot.parameters.noseWingSlim, 0.35, accuracy: 0.0001)
        XCTAssertEqual(model.value, 100, accuracy: 0.0001)
        model.undo()
        XCTAssertEqual(model.snapshot.parameters.noseWingSlim, 0)
        model.redo()
        XCTAssertEqual(model.snapshot.parameters.noseWingSlim, 0.35, accuracy: 0.0001)
    }
    func testRapidUpdatesCoalesceAndDebugOnlyFollowsDisplayedImage() async throws {
        let renderer = FakeRenderer()
        let model = EditorModel(renderer: renderer)
        try await load(model)
        for value in 1...100 { model.updateValue(Float(value)) }
        model.endAdjustment()
        try await wait { !model.isRendering && model.displayedRevision == model.revision }
        let renders = await renderer.renderCount
        XCTAssertLessThanOrEqual(renders, 2, "Queued slider ticks must not all render")
        let callsBeforeDebug = await renderer.landmarkCount
        XCTAssertEqual(callsBeforeDebug, 0)
        model.toggleDebug()
        try await wait { !model.isDebugAnalyzing }
        XCTAssertEqual(model.sourceLandmarks.count, 1)
        XCTAssertEqual(model.previewLandmarks.count, 1)
        XCTAssertEqual(model.debugRevision, model.displayedRevision)
        model.updateValue(40); model.endAdjustment()
        try await wait { !model.isRendering && !model.isDebugAnalyzing && model.debugRevision == model.displayedRevision }
        XCTAssertEqual(model.debugRevision, model.revision)
        let callsAfterEdit = await renderer.landmarkCount
        XCTAssertEqual(callsAfterEdit, 3, "The source points should be reused; output points must be fresh")
        model.toggleDebug()
        XCTAssertTrue(model.previewLandmarks.isEmpty && model.sourceLandmarks.isEmpty)
        XCTAssertEqual(model.debugRevision, -1)
        model.toggleDebug()
        model.toggleDebug()
        try await Task.sleep(for: .milliseconds(200))
        XCTAssertTrue(model.previewLandmarks.isEmpty && model.sourceLandmarks.isEmpty)
    }
    private func load(_ model: EditorModel) async throws {
        model.importPhoto(TestImage.encoded())
        try await wait { !model.isLoading && model.photo != nil }
    }
    private func wait(_ predicate: () -> Bool) async throws {
        let deadline = Date().addingTimeInterval(5)
        while !predicate(), Date() < deadline { try await Task.sleep(for: .milliseconds(10)) }
        XCTAssertTrue(predicate(), "State did not settle")
    }
}
