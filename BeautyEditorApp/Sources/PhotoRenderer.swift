@_spi(OwnerDiagnostics) import BeautySDK
import CoreImage
import CoreTransferable
import ImageIO
import UniformTypeIdentifiers
import Vision
#if BEAUTY_OWNER_EYE_FIVE_CHECK
import CryptoKit

/// Content-free identity observed at the actual owner render invocation.
struct OwnerSourceRasterIdentity: Codable, Equatable, Sendable {
    let sha256: String
    let width: Int
    let height: Int
    let bytesPerRow: Int
    let rowFormat: String
    let observationSite: String
}
#endif

enum EditorError: LocalizedError, Equatable {
    case invalidImage, tooLarge, unsupportedColor, invalidOrientation
    case backgroundUnavailable, renderFailed, saveDenied, saveFailed
    var errorDescription: String? {
        switch self {
        case .invalidImage: "无法读取图片，请选择单张 JPEG、PNG 或 HEIC 静态图片。"
        case .tooLarge: "图片超过处理上限（32 MiB 或 5000 万像素），请先缩小图片。"
        case .unsupportedColor: "此图片的色彩格式暂不支持，请转换为 RGB 图片。"
        case .invalidOrientation: "图片方向信息无效，请重新导出后选择。"
        case .backgroundUnavailable: "未能分离人物与背景，背景保护未开启。请换一张人物轮廓清晰的照片。"
        case .renderFailed: "此图片暂不支持当前调整。已保留最近一次预览，你可以撤销调整或换图。"
        case .saveDenied: "未获得保存权限。你可以在系统设置中允许添加照片，或通过分享保存到文件。"
        case .saveFailed: "保存失败，图片仍保留在当前页面，请重试或使用分享。"
        }
    }
}

enum ImageInput {
    static let byteLimit = BeautyConfiguration.defaultMaximumInputByteCount
    static func readBoundedFile(_ url: URL) throws -> Data {
        let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size > 0 else { throw EditorError.invalidImage }
        guard size <= byteLimit else { throw EditorError.tooLarge }
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        // Bound the actual read too, even if the file grows after its size check.
        var data = Data()
        while data.count <= byteLimit {
            let chunk = try handle.read(upToCount: byteLimit + 1 - data.count) ?? Data()
            if chunk.isEmpty { break }
            data.append(chunk)
        }
        guard !data.isEmpty else { throw EditorError.invalidImage }
        guard data.count <= byteLimit else { throw EditorError.tooLarge }
        return data
    }
}

struct PickerPhoto: Transferable, Sendable {
    let data: Data
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .image) { received in
            PickerPhoto(data: try ImageInput.readBoundedFile(received.file))
        }
    }
}

struct ImportedPhoto: Sendable {
    let id: UUID
    let data: Data
    let preview: CGImage
    let orientation: CGImagePropertyOrientation
    let width: Int
    let height: Int
    var uprightSize: CGSize {
        switch orientation {
        case .left, .right, .leftMirrored, .rightMirrored:
            CGSize(width: height, height: width)
        default:
            CGSize(width: width, height: height)
        }
    }
}

struct RenderedPhoto: Sendable {
    let image: CGImage
    let detection: BeautyDetectionSummary?
    let warningCount: Int
    var warningCodes: [String] = []
    var metrics: [String: Double] = [:]
    var renderMilliseconds: Double = 0
    var matchesSource: Bool = false
    var backendName: String = "CPU"
    #if BEAUTY_OWNER_EYE_FIVE_CHECK
    var ownerSourceRasterIdentity: OwnerSourceRasterIdentity?
    #endif
}

/// Independent, transient SDK production-model re-detection. These are observed landmarks,
/// not SDK warp control points or proof that a particular effect was admitted.
struct DebugLandmarkGroup: Equatable, Sendable, Identifiable {
    let id: String
    let points: [CGPoint] // upright image-normalized, top-left origin
    var detectorName: String = "Test"
}

protocol PhotoRendering: Sendable {
    func load(_ data: Data) async throws -> ImportedPhoto
    func render(_ photo: ImportedPhoto, snapshot: EditorSnapshot,
                fullResolution: Bool) async throws -> RenderedPhoto
    func encodePNG(_ image: CGImage) async throws -> Data
    func landmarks(_ image: CGImage) async throws -> [DebugLandmarkGroup]
}

extension PhotoRendering {
    func landmarks(_ image: CGImage) async throws -> [DebugLandmarkGroup] { [] }
}

/// All access to the non-Sendable BeautyEngine and Vision masks stays on one actor.
/// Preview/export always start from the imported source, never a previous result.
actor PhotoRenderer: PhotoRendering {
    private let context = CIContext(options: [.cacheIntermediates: false,
                                              .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!])
    private var engine: BeautyEngine?
    private var gpuEngine: BeautyEngine?
    private var originalIrisEngine: BeautyEngine?
    private var preparedPhotoID: UUID?
    private var cpuPrepared: BeautyPreparedStillImage?
    private var gpuPrepared: BeautyPreparedStillImage?
    private var originalIrisPrepared: BeautyPreparedStillImage?
    #if BEAUTY_OWNER_EYE_FIVE_CHECK
    private var cpuPreparedIdentity: OwnerSourceRasterIdentity?
    private var gpuPreparedIdentity: OwnerSourceRasterIdentity?
    private var originalIrisPreparedIdentity: OwnerSourceRasterIdentity?
    private var lastOwnerSourceRasterIdentity: OwnerSourceRasterIdentity?
    #endif
    private let landmarkDetector = BeautyOwnerLandmarkDetector()
    private let preferredBackend: BeautyRenderBackend

    init(preferredBackend: BeautyRenderBackend = .gpu) {
        self.preferredBackend = preferredBackend
    }

    private func makeEngine(_ backend: BeautyRenderBackend) throws -> BeautyEngine {
        try BeautyEngine(configuration: BeautyConfiguration(
            preferredProcessingSize: CGSize(width: 960, height: 960),
            maximumFaceCount: 1, enableFaceTracking: true,
            detectionFrameInterval: 1, renderBackend: backend
        ))
    }
    private var maskID: UUID?
    private var cachedMask: CIImage?
    private let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!

    func load(_ data: Data) throws -> ImportedPhoto {
        try Task.checkCancellation()
        guard !data.isEmpty else { throw EditorError.invalidImage }
        guard data.count <= ImageInput.byteLimit else { throw EditorError.tooLarge }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              CGImageSourceGetCount(source) == 1,
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue,
              let height = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue,
              width > 0, height > 0
        else { throw EditorError.invalidImage }
        guard width <= BeautyConfiguration.defaultMaximumInputPixelCount / height else {
            throw EditorError.tooLarge
        }
        let rawOrientation = (properties[kCGImagePropertyOrientation] as? NSNumber)?.uint32Value ?? 1
        guard let orientation = CGImagePropertyOrientation(rawValue: rawOrientation) else {
            throw EditorError.invalidOrientation
        }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 960,
            kCGImageSourceShouldCacheImmediately: true
        ]
        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw EditorError.invalidImage
        }
        guard thumbnail.colorSpace?.model == .rgb else { throw EditorError.unsupportedColor }
        let preview = try materialize(CIImage(cgImage: thumbnail))
        // Clear support from the previous selection; no coordinates/masks are persisted.
        cachedMask = nil
        maskID = nil
        engine = try makeEngine(.cpu)
        gpuEngine = nil
        originalIrisEngine = nil
        preparedPhotoID = nil
        cpuPrepared = nil
        gpuPrepared = nil
        originalIrisPrepared = nil
        #if BEAUTY_OWNER_EYE_FIVE_CHECK
        cpuPreparedIdentity = nil
        gpuPreparedIdentity = nil
        originalIrisPreparedIdentity = nil
        lastOwnerSourceRasterIdentity = nil
        #endif
        landmarkDetector.reset()
        return ImportedPhoto(id: UUID(), data: data, preview: preview,
                             orientation: orientation, width: width, height: height)
    }

    func render(_ photo: ImportedPhoto, snapshot: EditorSnapshot,
                fullResolution: Bool) throws -> RenderedPhoto {
        try Task.checkCancellation()
        let start = ContinuousClock.now
        return try autoreleasepool {
            #if BEAUTY_OWNER_EYE_FIVE_CHECK
            lastOwnerSourceRasterIdentity = nil
            #endif
            let cpu: BeautyEngine
            if let engine { cpu = engine }
            else { cpu = try makeEngine(.cpu); engine = cpu }
            let source = fullResolution ? try originalImage(photo) : CIImage(cgImage: photo.preview)
            let usesOriginalIrisPreview = !fullResolution && snapshot.parameters.pupilSize != 0
            var selectedEngine = cpu
            var backendName = "CPU"
            // The selected Metal backend shares the CPU-owned continuous nasal
            // map, including root narrowing. Unsupported legacy geometry keeps
            // the existing typed-error CPU fallback below.
            #if !targetEnvironment(simulator)
            if !usesOriginalIrisPreview, preferredBackend == .gpu,
               snapshot.parameters != BeautyParameters() {
                if gpuEngine == nil { gpuEngine = try? makeEngine(.gpu) }
                if let gpuEngine { selectedEngine = gpuEngine; backendName = "Metal" }
            }
            #endif
            let result: BeautyResult<CIImage>
            if usesOriginalIrisPreview {
                resetPreparedSourcesIfNeeded(photo.id)
                let originalEngine: BeautyEngine
                if let originalIrisEngine { originalEngine = originalIrisEngine }
                else {
                    originalEngine = try makeEngine(.cpu)
                    originalIrisEngine = originalEngine
                }
                let token: BeautyPreparedStillImage
                if let originalIrisPrepared { token = originalIrisPrepared }
                else {
                    let originalRaster = try materialize(originalImage(photo))
                    #if BEAUTY_OWNER_EYE_FIVE_CHECK
                    originalIrisPreparedIdentity = try ownerRasterIdentity(
                        originalRaster, site: "originalIrisPrepared"
                    )
                    #endif
                    token = try originalEngine.prepareStillImage(
                        image: originalRaster,
                        metadata: BeautyInputMetadata(orientation: .up, source: .photo)
                    )
                    originalIrisPrepared = token
                }
                #if BEAUTY_OWNER_EYE_FIVE_CHECK
                lastOwnerSourceRasterIdentity = originalIrisPreparedIdentity
                #endif
                result = try originalEngine.processIrisPreviewResult(
                    preparedImage: token, maximumPreviewEdge: 960,
                    parameters: snapshot.parameters
                )
                guard result.output.extent.size == source.extent.size else {
                    throw EditorError.renderFailed
                }
                backendName = "CPU original iris preview"
            } else {
                do {
                    result = try process(selectedEngine, photo: photo, source: source,
                        parameters: snapshot.parameters, fullResolution: fullResolution,
                        useCPU: selectedEngine === cpu)
                } catch {
                    guard backendName == "Metal", error is BeautyError else { throw error }
                    // Alpha/finite-raster preflight or unavailable Metal can fall back
                    // to the unchanged CPU reference. CPU failure still propagates.
                    backendName = "CPU fallback"
                    result = try process(cpu, photo: photo, source: source,
                        parameters: snapshot.parameters, fullResolution: fullResolution, useCPU: true)
                }
            }
            try Task.checkCancellation()
            let output: CIImage
            if snapshot.protectBackground {
                // Segmentation is computed from the unedited upright preview, then scaled.
                // Original background is the compositor's explicit second input.
                let mask = try personMask(photo)
                let scaledMask = mask.transformed(by: CGAffineTransform(
                    scaleX: source.extent.width / mask.extent.width,
                    y: source.extent.height / mask.extent.height)).cropped(to: source.extent)
                output = result.output.applyingFilter("CIBlendWithMask", parameters: [
                    kCIInputBackgroundImageKey: source, kCIInputMaskImageKey: scaledMask
                ])
            } else {
                output = result.output
            }
            if result.metrics["beauty.backend.cpuGeometryCapacityFallback"] == 1 {
                backendName = "CPU capacity fallback"
            }
            let image = try materialize(output)
            let matchesSource = !fullResolution && previewPixelsMatch(image, photo.preview)
            let elapsed = start.duration(to: .now)
            var rendered = RenderedPhoto(image: image, detection: result.detectionSummary,
                                 warningCount: result.warnings.count,
                                 warningCodes: result.warnings.map(\.code), metrics: result.metrics,
                                 renderMilliseconds: Double(elapsed.components.seconds) * 1000 + Double(elapsed.components.attoseconds) / 1e15,
                                 matchesSource: matchesSource,
                                 backendName: backendName)
            #if BEAUTY_OWNER_EYE_FIVE_CHECK
            rendered.ownerSourceRasterIdentity = lastOwnerSourceRasterIdentity
            #endif
            return rendered
        }
    }

    /// Non-iris preview tokens bind support to the fixed thumbnail. Iris uses a
    /// separate original-bound engine; exports use fresh original support.
    private func process(_ selected: BeautyEngine, photo: ImportedPhoto, source: CIImage,
                         parameters: BeautyParameters, fullResolution: Bool,
                         useCPU: Bool) throws -> BeautyResult<CIImage> {
        let metadata = BeautyInputMetadata(orientation: .up, source: .photo)
        if fullResolution {
            #if BEAUTY_OWNER_EYE_FIVE_CHECK
            lastOwnerSourceRasterIdentity = try ownerRasterIdentity(
                materialize(source), site: "freshOriginalProcessSRGBMaterialization"
            )
            #endif
            return try selected.processResult(image: source, metadata: metadata, parameters: parameters)
        }
        resetPreparedSourcesIfNeeded(photo.id)
        let token: BeautyPreparedStillImage
        if let existing = useCPU ? cpuPrepared : gpuPrepared { token = existing }
        else {
            #if BEAUTY_OWNER_EYE_FIVE_CHECK
            let identity = try ownerRasterIdentity(photo.preview, site: "legacyThumbnailPrepared")
            if useCPU { cpuPreparedIdentity = identity } else { gpuPreparedIdentity = identity }
            #endif
            token = try selected.prepareStillImage(image: photo.preview, metadata: metadata)
            if useCPU { cpuPrepared = token } else { gpuPrepared = token }
        }
        #if BEAUTY_OWNER_EYE_FIVE_CHECK
        lastOwnerSourceRasterIdentity = useCPU ? cpuPreparedIdentity : gpuPreparedIdentity
        #endif
        return try selected.processResult(preparedImage: token, parameters: parameters)
    }

    private func resetPreparedSourcesIfNeeded(_ photoID: UUID) {
        guard preparedPhotoID != photoID else { return }
        engine?.releasePreparedStillImage()
        gpuEngine?.releasePreparedStillImage()
        originalIrisEngine?.releasePreparedStillImage()
        cpuPrepared = nil
        gpuPrepared = nil
        originalIrisPrepared = nil
        #if BEAUTY_OWNER_EYE_FIVE_CHECK
        cpuPreparedIdentity = nil
        gpuPreparedIdentity = nil
        originalIrisPreparedIdentity = nil
        lastOwnerSourceRasterIdentity = nil
        #endif
        preparedPhotoID = photoID
    }

    #if BEAUTY_OWNER_EYE_FIVE_CHECK
    private func ownerRasterIdentity(_ image: CGImage, site: String) throws -> OwnerSourceRasterIdentity {
        guard image.bitsPerComponent == 8, image.bitsPerPixel == 32,
              let provider = image.dataProvider?.data else { throw EditorError.renderFailed }
        let (count, overflow) = image.bytesPerRow.multipliedReportingOverflow(by: image.height)
        let bytes = provider as Data
        guard !overflow, count > 0, bytes.count >= count else { throw EditorError.renderFailed }
        let format = "RGB8-32-bitmapInfo:\(image.bitmapInfo.rawValue)"
        var digest = SHA256()
        digest.update(data: Data("\(image.width):\(image.height):\(image.bytesPerRow):\(format)\n".utf8))
        digest.update(data: bytes.prefix(count))
        return OwnerSourceRasterIdentity(
            sha256: digest.finalize().map { String(format: "%02x", $0) }.joined(),
            width: image.width, height: image.height, bytesPerRow: image.bytesPerRow,
            rowFormat: format, observationSite: site
        )
    }
    #endif

    func landmarks(_ image: CGImage) async throws -> [DebugLandmarkGroup] {
        try Task.checkCancellation()
        let result = try landmarkDetector.detect(image)
        try Task.checkCancellation()
        guard !result.points.isEmpty else { return [] }
        return [DebugLandmarkGroup(id: result.detectorName, points: result.points,
                                   detectorName: result.detectorName)]
    }

    func encodePNG(_ image: CGImage) throws -> Data {
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.png.identifier as CFString, 1, nil) else {
            throw EditorError.saveFailed
        }
        // Fresh sRGB, upright output. Source EXIF, GPS, filenames and capture metadata are omitted.
        CGImageDestinationAddImage(destination, image, [kCGImagePropertyOrientation: 1] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw EditorError.saveFailed }
        return output as Data
    }

    private func originalImage(_ photo: ImportedPhoto) throws -> CIImage {
        guard let source = CGImageSourceCreateWithData(photo.data as CFData, nil),
              let decoded = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw EditorError.invalidImage
        }
        let oriented = CIImage(cgImage: decoded).oriented(photo.orientation)
        return oriented.transformed(by: CGAffineTransform(translationX: -oriented.extent.minX,
                                                          y: -oriented.extent.minY))
    }

    private func materialize(_ image: CIImage) throws -> CGImage {
        guard let result = context.createCGImage(image, from: image.extent,
                                                format: .RGBA8, colorSpace: sRGB, deferred: false) else {
            throw EditorError.renderFailed
        }
        return result
    }

    /// Provider bytes may differ in row padding/layout for identical images.
    /// Compare only canonical preview pixels; no original-size copies or cache.
    private func previewPixelsMatch(_ output: CGImage, _ source: CGImage) -> Bool {
        guard output.width == source.width, output.height == source.height else { return false }
        let rowBytes = source.width * 4
        let bounds = CGRect(x: 0, y: 0, width: source.width, height: source.height)
        func pixels(_ image: CGImage) -> Data {
            var data = Data(count: rowBytes * source.height)
            data.withUnsafeMutableBytes { pointer in
                context.render(CIImage(cgImage: image), toBitmap: pointer.baseAddress!, rowBytes: rowBytes,
                               bounds: bounds, format: .RGBA8, colorSpace: sRGB)
            }
            return data
        }
        return pixels(output) == pixels(source)
    }

    private func personMask(_ photo: ImportedPhoto) throws -> CIImage {
        if maskID == photo.id, let cachedMask { return cachedMask }
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .balanced
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
        do {
            #if targetEnvironment(simulator)
            for (stage, devices) in try request.supportedComputeStageDevices {
                if let cpu = devices.first(where: { if case .cpu = $0 { return true }; return false }) {
                    request.setComputeDevice(cpu, for: stage)
                }
            }
            #endif
            try VNImageRequestHandler(cgImage: photo.preview, orientation: .up).perform([request])
        } catch {
            throw EditorError.backgroundUnavailable
        }
        guard let buffer = request.results?.first?.pixelBuffer else {
            throw EditorError.backgroundUnavailable
        }
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(buffer) else { throw EditorError.backgroundUnavailable }
        let width = CVPixelBufferGetWidth(buffer), height = CVPixelBufferGetHeight(buffer)
        let stride = CVPixelBufferGetBytesPerRow(buffer)
        var admitted = 0
        let bytes = base.assumingMemoryBound(to: UInt8.self)
        for y in 0..<height {
            for x in 0..<width where bytes[y * stride + x] >= 128 { admitted += 1 }
        }
        guard admitted > width * height / 100, admitted < width * height * 99 / 100 else {
            throw EditorError.backgroundUnavailable
        }
        let mask = CIImage(cvPixelBuffer: buffer)
        cachedMask = mask
        maskID = photo.id
        return mask
    }
}
