import BeautyCore
import BeautyDetection
import CoreGraphics
import CoreImage
import Foundation
import ImageIO

/// An explicit CPU still-image executor with a resize cutpoint after the
/// original-source iris sampler. The default backend extent contract is not
/// used or changed by this route.
package enum BeautyIrisPreviewCutpoint {
    package struct Result: @unchecked Sendable, CustomStringConvertible,
        CustomDebugStringConvertible, CustomReflectable {
        package let output: CIImage
        package let metrics: [String: Double]

        package var description: String {
            "BeautyIrisPreviewResult(width: \(Int(output.extent.width)), height: \(Int(output.extent.height)), cpu: true)"
        }
        package var debugDescription: String { description }
        package var customMirror: Mirror {
            Mirror(self, children: ["width": Int(output.extent.width),
                                    "height": Int(output.extent.height), "cpu": true], displayStyle: .struct)
        }
    }

    /// Framework objects only; images, owners and observations remain local
    /// to one invocation and are never retained by this resource holder.
    private final class Resources: @unchecked Sendable {
        let sRGB: CGColorSpace
        let thumbnailContext: CIContext
        init() {
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
            sRGB = colorSpace
            thumbnailContext = CIContext(options: [.cacheIntermediates: false, .workingColorSpace: colorSpace])
        }
    }
    private static let resources = Resources()

    private struct Raster: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        let width: Int
        let height: Int
        let rgba: [UInt8]

        var description: String {
            "BeautyIrisPreviewRaster(width: \(width), height: \(height), byteCount: \(rgba.count))"
        }
        var debugDescription: String { description }
        var customMirror: Mirror {
            Mirror(self, children: ["width": width, "height": height, "byteCount": rgba.count],
                   displayStyle: .struct)
        }
    }

    /// The facade supplies its normalized, locally composed original carrier
    /// and the already resolved sibling plan/validated normalized observation.
    /// No detection, plan resolution, or local-retouch composition occurs here.
    package static func execute(
        original: BeautyCanonicalStillImage,
        plan: BeautyEffectPlan,
        renderQuality: BeautyRenderQuality = .balanced,
        selectedFaceObservation: BeautyFaceObservation?,
        maximumPreviewEdge: Int = 960,
        textureExclusionMask: BeautyTextureExclusionMask? = nil
    ) throws -> Result {
        guard (1...960).contains(maximumPreviewEdge), original.width > 0, original.height > 0,
              original.width <= BeautyConfiguration.defaultMaximumInputPixelCount / original.height,
              textureExclusionMask == nil ||
                (textureExclusionMask!.width == original.width && textureExclusionMask!.height == original.height)
        else { throw BeautyError.invalidInput }

        let colorSource = BeautyColorEffectPipeline.prepareStillImagePrefix(
            to: original, plan: plan, renderQuality: renderQuality,
            selectedFaceObservation: selectedFaceObservation, textureExclusionMask: textureExclusionMask)
        let colorRGBA = try rasterize(colorSource, width: original.width, height: original.height,
                                      context: BeautyImageContexts.context(for: resources.sRGB))
        let face = selectedFaceObservation.map(BeautyFaceGeometryAdapter.makeGeometry(from:))
        let prefix = BeautyStillImageGeometryStage.prepareSourcePrefix(
            colorRGBA, width: original.width, height: original.height, plan: plan, face: face)
        let iris: BeautyIrisScaleRemap.OwnedRaster
        if let face, let sampler = BeautyIrisScaleRemap(
            width: original.width, height: original.height, face: face,
            strengths: plan.effectiveStrengths, sourceRGBA: prefix.rgba) {
            iris = sampler.applyRGBAWithSourceOwner(prefix.rgba)
        } else {
            iris = BeautyIrisScaleRemap.OwnedRaster(rgba: prefix.rgba,
                owner: .empty(width: original.width, height: original.height))
        }

        // I keeps the existing original-resolution color/refiner/IR order.
        // B follows the legacy view order: resize the canonical source first,
        // then apply the same resolved CPU prefix at that view's dimensions.
        // Neither prefix resolves a plan or detects support again.
        let remapped = try thumbnail(iris.rgba, width: original.width, height: original.height,
                                     maximumEdge: maximumPreviewEdge)
        let baseline: Raster
        let originalBaseline: Raster
        let mapSource: Raster
        let baselineAdmission: BeautyStillImageGeometryStage.SourceAdmission
        let previewBaselinePrefixPasses: Double
        if textureExclusionMask != nil {
            // An explicit mask authorizes only its original canonical grid.
            // Keep that existing source-prefix baseline rather than guessing
            // a view mask or using original mask bytes on a different grid.
            baseline = try thumbnail(prefix.rgba, width: original.width, height: original.height,
                                     maximumEdge: maximumPreviewEdge)
            originalBaseline = baseline
            mapSource = colorRGBA == prefix.rgba ? baseline : try thumbnail(
                colorRGBA, width: original.width, height: original.height, maximumEdge: maximumPreviewEdge)
            baselineAdmission = prefix.admission
            previewBaselinePrefixPasses = 0
        } else {
            let canonicalSourceRGBA = [UInt8](original.rgba8Data)
            let viewSource = try thumbnail(canonicalSourceRGBA, width: original.width,
                                           height: original.height, maximumEdge: maximumPreviewEdge)
            originalBaseline = prefix.rgba == canonicalSourceRGBA ? viewSource : try thumbnail(
                prefix.rgba, width: original.width, height: original.height, maximumEdge: maximumPreviewEdge)
            let viewCarrier = try BeautyCanonicalStillImage(
                rgba8Data: Data(viewSource.rgba), width: viewSource.width, height: viewSource.height,
                rowBytes: viewSource.width * 4, metadata: original.metadata)
            let viewColor = BeautyColorEffectPipeline.prepareStillImagePrefix(
                to: viewCarrier, plan: plan, renderQuality: renderQuality,
                selectedFaceObservation: selectedFaceObservation, textureExclusionMask: nil)
            let viewColorRGBA = try rasterize(viewColor, width: viewSource.width, height: viewSource.height,
                                              context: BeautyImageContexts.context(for: resources.sRGB))
            let viewPrefix = BeautyStillImageGeometryStage.prepareSourcePrefix(
                viewColorRGBA, width: viewSource.width, height: viewSource.height, plan: plan, face: face)
            baseline = Raster(width: viewSource.width, height: viewSource.height, rgba: viewPrefix.rgba)
            mapSource = Raster(width: viewSource.width, height: viewSource.height, rgba: viewColorRGBA)
            baselineAdmission = viewPrefix.admission
            previewBaselinePrefixPasses = 1
        }
        guard baseline.width == remapped.width, baseline.height == remapped.height,
              baseline.width == originalBaseline.width, baseline.height == originalBaseline.height,
              baseline.width == mapSource.width, baseline.height == mapSource.height
        else { throw BeautyError.renderFailed("iris_preview_extent") }

        var clipped = baseline.rgba
        for row in 0..<baseline.height {
            for column in 0..<baseline.width {
                let index = (row * baseline.width + column) * 4
                // Compare the IR pair sharing the same original prefix. An
                // equal pixel has no observable IR change; prefix/resize-order
                // differences cannot authorize a copy. The hard source owner
                // remains independently mandatory, without an RGB tissue mask.
                guard remapped.rgba[index] != originalBaseline.rgba[index] ||
                        remapped.rgba[index + 1] != originalBaseline.rgba[index + 1] ||
                        remapped.rgba[index + 2] != originalBaseline.rgba[index + 2] else { continue }
                guard iris.owner.permitsPreviewPixel(column: column, row: row,
                        width: baseline.width, height: baseline.height) else { continue }
                for channel in 0..<3 { clipped[index + channel] = remapped.rgba[index + channel] }
            }
        }

        // The cutpoint is before all remaining geometry. Existing maps now
        // carry the composed iris and every sibling together, once, without
        // exporting or transporting an owner mask through their samplers.
        let stage = BeautyStillImageGeometryStage(
            postIrisRGBA: clipped, mapAdmissionRGBA: mapSource.rgba,
            width: baseline.width, height: baseline.height, plan: plan, face: face,
            sourceAdmission: baselineAdmission, eyebrowSourceRGBA: mapSource.rgba)
        let selectedGeometry = stage.usesDenseMap
            ? stage.applyingDenseMap(to: stage.sourceRGBA)
            : BeautyGeometryEffectPipeline.warpedRGBABytes(
                stage.sourceRGBA, width: baseline.width, height: baseline.height,
                points: stage.controlPoints.compactMap(BeautyGeometryEffectPipeline.RenderableWarpPoint.init))
        let nasal = stage.applyingContinuousNose(to: selectedGeometry)
        let mouth = stage.applyingContinuousMouth(to: nasal)
        let eyebrows = stage.applyingContinuousEyebrows(to: mouth)
        let outputRGBA = stage.applyingTranslation(to: stage.applyingContinuousContour(to: eyebrows))
        try requireOpaque(outputRGBA, width: baseline.width, height: baseline.height)
        let output = CIImage(bitmapData: Data(outputRGBA), bytesPerRow: baseline.width * 4,
                             size: CGSize(width: baseline.width, height: baseline.height),
                             format: .RGBA8, colorSpace: resources.sRGB)
        return Result(output: output, metrics: [
            "beauty.irisPreview.originalFirstCPU": 1,
            "beauty.irisPreview.maximumEdge": Double(maximumPreviewEdge),
            "beauty.irisPreview.sourceWidth": Double(original.width),
            "beauty.irisPreview.sourceHeight": Double(original.height),
            "beauty.irisPreview.outputWidth": Double(baseline.width),
            "beauty.irisPreview.outputHeight": Double(baseline.height),
            "beauty.irisPreview.completedEyeCount": Double(iris.owner.appliedEyeCount),
            "beauty.irisPreview.originalIRPrefixPasses": 1,
            "beauty.irisPreview.previewBaselinePrefixPasses": previewBaselinePrefixPasses,
            "beauty.irisPreview.colorTexturePasses": 1 + previewBaselinePrefixPasses,
            "beauty.irisPreview.sourceRefinerPasses": 1 + previewBaselinePrefixPasses,
            "beauty.irisPreview.postGeometryPasses": 1
        ])
    }

    private static func requireOpaque(_ rgba: [UInt8], width: Int, height: Int) throws {
        guard rgba.count == width * height * 4,
              stride(from: 3, to: rgba.count, by: 4).allSatisfy({ rgba[$0] == 255 })
        else { throw BeautyError.invalidInput }
    }

    private static func rasterize(_ image: CIImage, width: Int, height: Int,
                                  context: CIContext) throws -> [UInt8] {
        let extent = CGRect(x: 0, y: 0, width: width, height: height)
        guard image.extent == extent else { throw BeautyError.invalidInput }
        var rgba = [UInt8](repeating: 0, count: width * height * 4)
        rgba.withUnsafeMutableBytes { bytes in
            if let base = bytes.baseAddress {
                context.render(image, toBitmap: base, rowBytes: width * 4, bounds: extent,
                               format: .RGBA8, colorSpace: resources.sRGB)
            }
        }
        try requireOpaque(rgba, width: width, height: height)
        return rgba
    }

    /// One fixed ImageIO path, matching the owner's thumbnail preparation:
    /// lossless RGBA8/sRGB carrier -> ImageIO thumbnail -> RGBA8/sRGB CI view.
    /// No caller-selected kernel, alternate scale, or output calibration.
    private static func thumbnail(_ rgba: [UInt8], width: Int, height: Int,
                                  maximumEdge: Int) throws -> Raster {
        try requireOpaque(rgba, width: width, height: height)
        // Use the same CI bitmap carrier as the full-resolution executor;
        // Core Image owns its row orientation before PNG/ImageIO sees it.
        let fullView = CIImage(bitmapData: Data(rgba), bytesPerRow: width * 4,
                               size: CGSize(width: width, height: height),
                               format: .RGBA8, colorSpace: resources.sRGB)
        guard let sourceImage = resources.thumbnailContext.createCGImage(
            fullView, from: fullView.extent, format: .RGBA8, colorSpace: resources.sRGB, deferred: false)
        else { throw BeautyError.renderFailed("iris_preview_raster") }
        let encoded = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(encoded, "public.png" as CFString, 1, nil)
        else { throw BeautyError.renderFailed("iris_preview_encode") }
        CGImageDestinationAddImage(destination, sourceImage, [kCGImagePropertyOrientation: 1] as CFDictionary)
        guard CGImageDestinationFinalize(destination),
              let source = CGImageSourceCreateWithData(encoded as CFData, nil)
        else { throw BeautyError.renderFailed("iris_preview_encode") }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumEdge,
            kCGImageSourceShouldCacheImmediately: true
        ]
        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary),
              thumbnail.colorSpace?.model == .rgb
        else { throw BeautyError.renderFailed("iris_preview_resize") }
        let view = CIImage(cgImage: thumbnail)
        guard let materialized = resources.thumbnailContext.createCGImage(
            view, from: view.extent, format: .RGBA8, colorSpace: resources.sRGB, deferred: false)
        else { throw BeautyError.renderFailed("iris_preview_materialize") }
        let bytes = try rasterize(CIImage(cgImage: materialized), width: materialized.width,
                                  height: materialized.height, context: resources.thumbnailContext)
        return Raster(width: materialized.width, height: materialized.height, rgba: bytes)
    }
}
