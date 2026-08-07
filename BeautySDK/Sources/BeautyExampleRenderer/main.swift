import AppKit
import CoreImage
import Foundation
import ImageIO
import BeautySDK

struct RenderCase {
    let id: String
    let displayName: String
    let parameters: BeautyParameters
}

enum ExampleRendererError: Error, CustomStringConvertible {
    case missingInputDirectory(String)
    case missingInputImages(String)
    case unknownCase(String, [String])
    case imageLoadFailed(String)
    case renderFailed(String)
    case pngEncodingFailed(String)

    var description: String {
        switch self {
        case .missingInputDirectory(let label):
            "Input directory does not exist: \(label)"
        case .missingInputImages(let label):
            "Input directory contains no PNG or JPEG images: \(label)"
        case .unknownCase(let id, let available):
            "Unknown render case: \(id). Available cases: \(available.joined(separator: ", "))"
        case .imageLoadFailed(let label):
            "Could not load image: \(label)"
        case .renderFailed(let label):
            "Could not render image: \(label)"
        case .pngEncodingFailed(let label):
            "Could not encode PNG: \(label)"
        }
    }
}

let arguments = CommandLine.arguments
let inputDirectory = value(after: "--input", in: arguments) ?? "example-images/input"
let outputDirectory = value(after: "--output", in: arguments) ?? "example-images/output"
let selectedCase = value(after: "--case", in: arguments)
let suppressWatermark = arguments.contains("--no-watermark")

let cases = [
    RenderCase(
        id: "skinSmoothing_0p50",
        displayName: "skinSmoothing 0.50",
        parameters: BeautyParameters(skinSmoothing: 0.50)
    ),
    RenderCase(
        id: "skinWhitening_0p50",
        displayName: "skinWhitening 0.50",
        parameters: BeautyParameters(skinWhitening: 0.50)
    ),
    RenderCase(
        id: "skinRosy_0p40",
        displayName: "skinRosy 0.40",
        parameters: BeautyParameters(skinRosy: 0.40)
    ),
    RenderCase(
        id: "skinSharpen_0p40",
        displayName: "skinSharpen 0.40",
        parameters: BeautyParameters(skinSharpen: 0.40)
    ),
    RenderCase(
        id: "brightness_plus0p25",
        displayName: "brightness +0.25",
        parameters: BeautyParameters(brightness: 0.25)
    ),
    RenderCase(
        id: "contrast_plus0p25",
        displayName: "contrast +0.25",
        parameters: BeautyParameters(contrast: 0.25)
    ),
    RenderCase(
        id: "filter_softClean_0p50",
        displayName: "filter soft_clean 0.50",
        parameters: BeautyParameters(filterId: "soft_clean", filterIntensity: 0.50)
    ),
    RenderCase(
        id: "filter_warmLight_0p50",
        displayName: "filter warm_light 0.50",
        parameters: BeautyParameters(filterId: "warm_light", filterIntensity: 0.50)
    ),
    RenderCase(
        id: "skinCombo_0p50",
        displayName: "skin combo 0.50",
        parameters: BeautyParameters(
            skinSmoothing: 0.50,
            skinWhitening: 0.50,
            skinRosy: 0.35,
            skinSharpen: 0.25
        )
    ),
    RenderCase(
        id: "geometryBaseline_noop",
        displayName: "geometry baseline noop",
        parameters: BeautyParameters()
    ),
    RenderCase(
        id: "faceShapeCombo_0p35",
        displayName: "face shape combo 0.35",
        parameters: BeautyParameters(
            faceSlim: 0.35,
            faceSmall: 0.30,
            faceVShape: 0.35,
            jawSlim: 0.30,
            chinLength: 0.20
        )
    ),
    RenderCase(
        id: "faceSlim_0p35",
        displayName: "faceSlim 0.35",
        parameters: BeautyParameters(faceSlim: 0.35)
    ),
    RenderCase(
        id: "faceSmall_0p35",
        displayName: "faceSmall 0.35",
        parameters: BeautyParameters(faceSmall: 0.35)
    ),
    RenderCase(
        id: "chinLength_plus0p30",
        displayName: "chinLength +0.30",
        parameters: BeautyParameters(chinLength: 0.30)
    ),
    RenderCase(
        id: "chinLength_minus0p30",
        displayName: "chinLength -0.30",
        parameters: BeautyParameters(chinLength: -0.30)
    ),
    RenderCase(
        id: "faceVShape_0p35",
        displayName: "faceVShape 0.35",
        parameters: BeautyParameters(faceVShape: 0.35)
    ),
    RenderCase(
        id: "jawSlim_0p35",
        displayName: "jawSlim 0.35",
        parameters: BeautyParameters(jawSlim: 0.35)
    ),
    RenderCase(
        id: "faceContourSmooth_0p25",
        displayName: "faceContourSmooth 0.25",
        parameters: BeautyParameters(faceContourSmooth: 0.25)
    ),
    RenderCase(
        id: "templeFullness_0p25",
        displayName: "templeFullness 0.25",
        parameters: BeautyParameters(templeFullness: 0.25)
    ),
    RenderCase(
        id: "cheekboneSlim_0p25",
        displayName: "cheekboneSlim 0.25",
        parameters: BeautyParameters(cheekboneSlim: 0.25)
    ),
    RenderCase(
        id: "chinTaper_0p25",
        displayName: "chinTaper 0.25",
        parameters: BeautyParameters(chinTaper: 0.25)
    ),
    RenderCase(
        id: "eyeSize_0p35",
        displayName: "eyeSize 0.35",
        parameters: BeautyParameters(eyeSize: 0.35)
    ),
    RenderCase(
        id: "eyeDistance_plus0p25",
        displayName: "eyeDistance +0.25",
        parameters: BeautyParameters(eyeDistance: 0.25)
    ),
    RenderCase(
        id: "eyeDistance_minus0p25",
        displayName: "eyeDistance -0.25",
        parameters: BeautyParameters(eyeDistance: -0.25)
    ),
    RenderCase(
        id: "eyeYPosition_plus0p20",
        displayName: "eyeYPosition +0.20",
        parameters: BeautyParameters(eyeYPosition: 0.20)
    ),
    RenderCase(
        id: "eyeYPosition_minus0p20",
        displayName: "eyeYPosition -0.20",
        parameters: BeautyParameters(eyeYPosition: -0.20)
    ),
    RenderCase(
        id: "eyeTailLift_0p25",
        displayName: "eyeTailLift 0.25",
        parameters: BeautyParameters(eyeTailLift: 0.25)
    ),
    RenderCase(
        id: "eyeHeight_0p25",
        displayName: "eyeHeight 0.25",
        parameters: BeautyParameters(eyeHeight: 0.25)
    ),
    RenderCase(
        id: "eyeLength_0p25",
        displayName: "eyeLength 0.25",
        parameters: BeautyParameters(eyeLength: 0.25)
    ),
    RenderCase(
        id: "upperEyelidLift_0p25",
        displayName: "upperEyelidLift 0.25",
        parameters: BeautyParameters(upperEyelidLift: 0.25)
    ),
    RenderCase(
        id: "pupilSize_0p25",
        displayName: "pupilSize 0.25",
        parameters: BeautyParameters(pupilSize: 0.25)
    ),
    RenderCase(
        id: "gazeCorrection_0p25",
        displayName: "gazeCorrection 0.25",
        parameters: BeautyParameters(gazeCorrection: 0.25)
    ),
    RenderCase(
        id: "lowerEyelidDrop_0p25",
        displayName: "lowerEyelidDrop 0.25",
        parameters: BeautyParameters(lowerEyelidDrop: 0.25)
    ),
    RenderCase(
        id: "eyeTilt_plus0p25",
        displayName: "eyeTilt +0.25",
        parameters: BeautyParameters(eyeTilt: 0.25)
    ),
    RenderCase(
        id: "eyeTilt_minus0p25",
        displayName: "eyeTilt -0.25",
        parameters: BeautyParameters(eyeTilt: -0.25)
    ),
    RenderCase(
        id: "innerCornerOpen_0p25",
        displayName: "innerCornerOpen 0.25",
        parameters: BeautyParameters(innerCornerOpen: 0.25)
    ),
    RenderCase(
        id: "outerCornerOpen_0p25",
        displayName: "outerCornerOpen 0.25",
        parameters: BeautyParameters(outerCornerOpen: 0.25)
    ),
    RenderCase(
        id: "eyeSymmetry_0p25",
        displayName: "eyeSymmetry 0.25",
        parameters: BeautyParameters(eyeSymmetry: 0.25)
    ),
    RenderCase(
        id: "eyebrowYPosition_plus0p25",
        displayName: "eyebrowYPosition +0.25",
        parameters: BeautyParameters(eyebrowYPosition: 0.25)
    ),
    RenderCase(
        id: "eyebrowYPosition_minus0p25",
        displayName: "eyebrowYPosition -0.25",
        parameters: BeautyParameters(eyebrowYPosition: -0.25)
    ),
    RenderCase(
        id: "eyebrowThickness_plus0p25",
        displayName: "eyebrowThickness +0.25",
        parameters: BeautyParameters(eyebrowThickness: 0.25)
    ),
    RenderCase(
        id: "eyebrowThickness_minus0p25",
        displayName: "eyebrowThickness -0.25",
        parameters: BeautyParameters(eyebrowThickness: -0.25)
    ),
    RenderCase(
        id: "eyebrowLength_plus0p25",
        displayName: "eyebrowLength +0.25",
        parameters: BeautyParameters(eyebrowLength: 0.25)
    ),
    RenderCase(
        id: "eyebrowLength_minus0p25",
        displayName: "eyebrowLength -0.25",
        parameters: BeautyParameters(eyebrowLength: -0.25)
    ),
    RenderCase(
        id: "eyebrowSpacing_plus0p25",
        displayName: "eyebrowSpacing +0.25",
        parameters: BeautyParameters(eyebrowSpacing: 0.25)
    ),
    RenderCase(
        id: "eyebrowSpacing_minus0p25",
        displayName: "eyebrowSpacing -0.25",
        parameters: BeautyParameters(eyebrowSpacing: -0.25)
    ),
    RenderCase(
        id: "eyebrowHeadSpacing_plus0p25",
        displayName: "eyebrowHeadSpacing +0.25",
        parameters: BeautyParameters(eyebrowHeadSpacing: 0.25)
    ),
    RenderCase(
        id: "eyebrowHeadSpacing_minus0p25",
        displayName: "eyebrowHeadSpacing -0.25",
        parameters: BeautyParameters(eyebrowHeadSpacing: -0.25)
    ),
    RenderCase(
        id: "eyebrowTilt_plus0p25",
        displayName: "eyebrowTilt +0.25",
        parameters: BeautyParameters(eyebrowTilt: 0.25)
    ),
    RenderCase(
        id: "eyebrowTilt_minus0p25",
        displayName: "eyebrowTilt -0.25",
        parameters: BeautyParameters(eyebrowTilt: -0.25)
    ),
    RenderCase(
        id: "eyebrowPeakDefinition_0p25",
        displayName: "eyebrowPeakDefinition 0.25",
        parameters: BeautyParameters(eyebrowPeakDefinition: 0.25)
    ),
    RenderCase(
        id: "noseSlim_0p35",
        displayName: "noseSlim 0.35",
        parameters: BeautyParameters(noseSlim: 0.35)
    ),
    RenderCase(
        id: "noseWingSlim_0p35",
        displayName: "noseWingSlim 0.35",
        parameters: BeautyParameters(noseWingSlim: 0.35)
    ),
    RenderCase(
        id: "noseTipSize_plus0p30",
        displayName: "noseTipSize +0.30",
        parameters: BeautyParameters(noseTipSize: 0.30)
    ),
    RenderCase(
        id: "noseTipSize_minus0p30",
        displayName: "noseTipSize -0.30",
        parameters: BeautyParameters(noseTipSize: -0.30)
    ),
    RenderCase(
        id: "noseBridge_0p30",
        displayName: "noseBridge 0.30",
        parameters: BeautyParameters(noseBridge: 0.30)
    ),
    RenderCase(
        id: "noseRootNarrowing_0p25",
        displayName: "noseRootNarrowing 0.25",
        parameters: BeautyParameters(noseRootNarrowing: 0.25)
    ),
    RenderCase(
        id: "noseTipLift_0p25",
        displayName: "noseTipLift 0.25",
        parameters: BeautyParameters(noseTipLift: 0.25)
    ),
    RenderCase(
        id: "mouthSize_plus0p35",
        displayName: "mouthSize +0.35",
        parameters: BeautyParameters(mouthSize: 0.35)
    ),
    RenderCase(
        id: "mouthSize_minus0p35",
        displayName: "mouthSize -0.35",
        parameters: BeautyParameters(mouthSize: -0.35)
    ),
    RenderCase(
        id: "mouthWidth_plus0p35",
        displayName: "mouthWidth +0.35",
        parameters: BeautyParameters(mouthWidth: 0.35)
    ),
    RenderCase(
        id: "mouthWidth_minus0p35",
        displayName: "mouthWidth -0.35",
        parameters: BeautyParameters(mouthWidth: -0.35)
    ),
    RenderCase(
        id: "smile_0p50",
        displayName: "smile 0.50",
        parameters: BeautyParameters(smile: 0.50)
    ),
    RenderCase(
        id: "lipColor_0p50",
        displayName: "lipColor 0.50",
        parameters: BeautyParameters(lipColor: 0.50)
    ),
    RenderCase(
        id: "mouthYPosition_plus0p25",
        displayName: "mouthYPosition +0.25",
        parameters: BeautyParameters(mouthYPosition: 0.25)
    ),
    RenderCase(
        id: "mouthYPosition_minus0p25",
        displayName: "mouthYPosition -0.25",
        parameters: BeautyParameters(mouthYPosition: -0.25)
    ),
    RenderCase(
        id: "mouthTilt_plus0p25",
        displayName: "mouthTilt +0.25",
        parameters: BeautyParameters(mouthTilt: 0.25)
    ),
    RenderCase(
        id: "mouthTilt_minus0p25",
        displayName: "mouthTilt -0.25",
        parameters: BeautyParameters(mouthTilt: -0.25)
    ),
    RenderCase(
        id: "mouthXPosition_plus0p25",
        displayName: "mouthXPosition +0.25",
        parameters: BeautyParameters(mouthXPosition: 0.25)
    ),
    RenderCase(
        id: "mouthXPosition_minus0p25",
        displayName: "mouthXPosition -0.25",
        parameters: BeautyParameters(mouthXPosition: -0.25)
    ),
    RenderCase(
        id: "lipPeakDefinition_0p25",
        displayName: "lipPeakDefinition 0.25",
        parameters: BeautyParameters(lipPeakDefinition: 0.25)
    ),
    RenderCase(
        id: "lipPlump_0p25",
        displayName: "lipPlump 0.25",
        parameters: BeautyParameters(lipPlump: 0.25)
    ),
    RenderCase(
        id: "teethWhitening_1p00",
        displayName: "teethWhitening 1.00",
        parameters: BeautyParameters(teethWhitening: 1)
    ),
    RenderCase(
        id: "scleraRednessReduction_1p00",
        displayName: "scleraRednessReduction 1.00",
        parameters: BeautyParameters(scleraRednessReduction: 1)
    )
]

do {
    let inputURL = URL(fileURLWithPath: inputDirectory, isDirectory: true)
    let outputURL = URL(fileURLWithPath: outputDirectory, isDirectory: true)
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: inputURL.path) else {
        throw ExampleRendererError.missingInputDirectory("input directory")
    }
    try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true)

    let renderCases = cases.filter { selectedCase == nil || selectedCase == $0.id }
    if let selectedCase, renderCases.isEmpty {
        throw ExampleRendererError.unknownCase(selectedCase, cases.map(\.id))
    }

    let imageURLs = fixtureImageURLs(in: inputURL, fileManager: fileManager)
    guard !imageURLs.isEmpty else {
        throw ExampleRendererError.missingInputImages("input directory")
    }

    let engine = try BeautyEngine(configuration: .default)
    let context = CIContext(options: [
        .workingColorSpace: CGColorSpaceCreateDeviceRGB(),
        .outputColorSpace: CGColorSpaceCreateDeviceRGB()
    ])

    for imageURL in imageURLs {
        guard let inputImage = CIImage(contentsOf: imageURL, options: [.applyOrientationProperty: true]) else {
            throw ExampleRendererError.imageLoadFailed(relativePath(imageURL, from: inputURL))
        }

        for renderCase in renderCases {
            let result = try engine.processResult(
                image: inputImage,
                metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
                parameters: renderCase.parameters
            )
            guard let cgImage = context.createCGImage(result.output, from: result.output.extent) else {
                throw ExampleRendererError.renderFailed(relativePath(imageURL, from: inputURL))
            }

            let rendered: NSBitmapImageRep
            if suppressWatermark {
                rendered = NSBitmapImageRep(cgImage: cgImage)
            } else {
                let watermark = watermarkText(for: renderCase, result: result)
                rendered = try drawWatermark(watermark, on: cgImage)
            }
            let baseName = imageURL.deletingPathExtension().lastPathComponent
            let outputName = "\(baseName)__\(renderCase.id).png"
            let destination = outputURL.appendingPathComponent(outputName)
            guard let png = rendered.pngData() else {
                throw ExampleRendererError.pngEncodingFailed(outputName)
            }
            try png.write(to: destination, options: .atomic)
            print("wrote \(outputName)")
        }
    }
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}

func value(after flag: String, in arguments: [String]) -> String? {
    guard let index = arguments.firstIndex(of: flag),
          arguments.indices.contains(index + 1)
    else {
        return nil
    }
    return arguments[index + 1]
}

func fixtureImageURLs(in directory: URL, fileManager: FileManager) -> [URL] {
    guard let enumerator = fileManager.enumerator(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
    ) else {
        return []
    }

    var urls: [URL] = []
    for case let url as URL in enumerator {
        guard ["png", "jpg", "jpeg"].contains(url.pathExtension.lowercased()) else {
            continue
        }
        let values = try? url.resourceValues(forKeys: [.isRegularFileKey])
        guard values?.isRegularFile == true else {
            continue
        }
        urls.append(url)
    }

    return urls.sorted {
        relativePath($0, from: directory) < relativePath($1, from: directory)
    }
}

func relativePath(_ url: URL, from directory: URL) -> String {
    let directoryPath = directory.standardizedFileURL.path
    let filePath = url.standardizedFileURL.path
    let prefix = directoryPath.hasSuffix("/") ? directoryPath : directoryPath + "/"
    guard filePath.hasPrefix(prefix) else {
        return url.lastPathComponent
    }
    return String(filePath.dropFirst(prefix.count))
}

func watermarkText(for renderCase: RenderCase, result: BeautyResult<CIImage>) -> String {
    _ = result
    return renderCase.displayName
}

func drawWatermark(_ text: String, on cgImage: CGImage) throws -> NSBitmapImageRep {
    let width = cgImage.width
    let height = cgImage.height
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bitmapFormat: [],
        bytesPerRow: 0,
        bitsPerPixel: 0
    ),
        let graphics = NSGraphicsContext(bitmapImageRep: bitmap)
    else {
        throw ExampleRendererError.renderFailed("watermark")
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphics
    graphics.cgContext.draw(
        cgImage,
        in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    )

    let fontSize = CGFloat(max(34, min(72, width / 30)))
    let padding = CGFloat(max(24, width / 70))
    let bandHeight = fontSize * 1.75
    let bandRect = NSRect(
        x: padding,
        y: padding,
        width: CGFloat(width) - padding * 2,
        height: bandHeight
    )
    NSColor.black.withAlphaComponent(0.62).setFill()
    NSBezierPath(roundedRect: bandRect, xRadius: 18, yRadius: 18).fill()

    let horizontalInset = padding * 0.6
    let verticalInset = (bandHeight - fontSize * 1.15) / 2
    let textRect = bandRect.insetBy(dx: horizontalInset, dy: verticalInset)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .semibold),
        .foregroundColor: NSColor.white
    ]
    (text as NSString).draw(with: textRect, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], attributes: attributes)
    NSGraphicsContext.restoreGraphicsState()

    return bitmap
}

extension NSBitmapImageRep {
    func pngData() -> Data? {
        representation(using: .png, properties: [:])
    }
}
