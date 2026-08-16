import BeautyCore
import BeautyDetection
import BeautyRender
import CoreGraphics
import CoreImage
import CoreVideo
import Foundation

/// Package-only Metal execution for the shared backend boundary.
///
/// The runtime owns Metal resources. This executor only bridges one admitted
/// request into a bounded RGBA8 transaction and publishes aggregate results.
package final class BeautyMetalBackend: BeautyBackendExecutor, @unchecked Sendable {
    package struct ExecutionHooks: @unchecked Sendable {
        package let onRuntimeInvocation: @Sendable () -> Void
        package let onTerminalError: @Sendable (BeautyError) -> Void

        package init(
            onRuntimeInvocation: @escaping @Sendable () -> Void = {},
            onTerminalError: @escaping @Sendable (BeautyError) -> Void = { _ in }
        ) {
            self.onRuntimeInvocation = onRuntimeInvocation
            self.onTerminalError = onTerminalError
        }
    }

    private let runtime: BeautyMetalRuntime
    private let hooks: ExecutionHooks
    private let pixelBufferFactory = PixelBufferFactory()

    package init(
        runtime: BeautyMetalRuntime,
        hooks: ExecutionHooks = ExecutionHooks()
    ) {
        self.runtime = runtime
        self.hooks = hooks
    }

    package init(
        dependencies: BeautyMetalRuntime.Dependencies = .live,
        maximumPixelCount: Int = BeautyConfiguration.defaultMaximumInputPixelCount,
        hooks: ExecutionHooks = ExecutionHooks()
    ) throws {
        self.runtime = try BeautyMetalRuntime(
            dependencies: dependencies,
            maximumPixelCount: maximumPixelCount
        )
        self.hooks = hooks
    }

    package func execute(_ request: BeautyBackendRequest) throws -> BeautyBackendResult {
        do {
            guard request.policy == .metal else {
                throw BeautyError.invalidInput
            }

            let output: BeautyBackendOutput
            switch request.input {
            case .pixelBuffer(let pixelBuffer):
                output = .pixelBuffer(try execute(
                    pixelBuffer: pixelBuffer,
                    plan: request.plan,
                    selectedFaceSupport: request.selectedFaceSupport
                ))
            case .stillImage(let image):
                output = .stillImage(try execute(
                    stillImage: image,
                    canonicalImage: request.canonicalImage,
                    plan: request.plan,
                    selectedFaceSupport: request.selectedFaceSupport
                ))
            }

            let dimensions = dimensions(of: output)
            let summary = request.compositionSummary
            let pixelCount = dimensions.width.multipliedReportingOverflow(by: dimensions.height)
            let boundedPixelCount = pixelCount.overflow
                ? BeautyConfiguration.defaultMaximumInputPixelCount
                : pixelCount.partialValue
            let diagnostics = BeautyBackendDiagnostics(
                width: dimensions.width,
                height: dimensions.height,
                preservesAlpha: true,
                preservesExtent: true,
                unitCount: min(summary?.acceptedUnitCount ?? 0, boundedPixelCount),
                failureCount: min(summary?.rejectedUnitCount ?? 0, boundedPixelCount),
                collisionCount: min(summary?.collisionPixelCount ?? 0, boundedPixelCount),
                changedPixelCount: min(summary?.changedPixelCount ?? 0, boundedPixelCount)
            )
            return try BeautyBackendResult(
                output: output,
                diagnostics: diagnostics,
                for: request
            )
        } catch let error as BeautyError {
            hooks.onTerminalError(error)
            throw error
        } catch {
            let terminalError = BeautyError.renderFailed("terminal")
            hooks.onTerminalError(terminalError)
            throw terminalError
        }
    }

    private func execute(
        pixelBuffer: CVPixelBuffer,
        plan: BeautyEffectPlan,
        selectedFaceSupport: BeautyFaceObservation?
    ) throws -> CVPixelBuffer {
        guard CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA else {
            throw BeautyError.unsupportedPixelFormat
        }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let rowBytes = try packedRowBytes(width: width)
        let sourceBytes = try read(pixelBuffer: pixelBuffer, width: width, height: height, rowBytes: rowBytes)
        let rgbaBytes = bgraToRgba(sourceBytes)
        let renderedRGBA = try invokeRuntime(
            width: width,
            height: height,
            bytes: rgbaBytes,
            passes: try makePasses(plan: plan, selectedFaceSupport: selectedFaceSupport)
        )
        let renderedBytes = rgbaToBgra(renderedRGBA)
        let output = try pixelBufferFactory.makePixelBuffer(width: width, height: height)
        try write(renderedBytes, to: output, width: width, height: height, rowBytes: rowBytes)
        return output
    }

    private func execute(
        stillImage image: CIImage,
        canonicalImage: BeautyCanonicalStillImage?,
        plan: BeautyEffectPlan,
        selectedFaceSupport: BeautyFaceObservation?
    ) throws -> CIImage {
        let extent = image.extent
        guard let dimensions = BeautyBackendRequest.checkedDimensions(for: extent) else {
            throw BeautyError.invalidInput
        }

        let bytes: [UInt8]
        if let canonicalImage {
            guard canonicalImage.width == dimensions.width,
                  canonicalImage.height == dimensions.height
            else {
                throw BeautyError.invalidInput
            }
            bytes = Array(canonicalImage.rgba8Data)
        } else {
            bytes = try rasterize(image: image, extent: extent, width: dimensions.width, height: dimensions.height)
        }

        let renderedBytes = try invokeRuntime(
            width: dimensions.width,
            height: dimensions.height,
            bytes: bytes,
            passes: try makePasses(plan: plan, selectedFaceSupport: selectedFaceSupport)
        )
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.unsupportedPixelFormat
        }
        let output = CIImage(
            bitmapData: Data(renderedBytes),
            bytesPerRow: dimensions.width * 4,
            size: CGSize(width: dimensions.width, height: dimensions.height),
            format: .RGBA8,
            colorSpace: colorSpace
        )
        guard output.extent == CGRect(origin: .zero, size: CGSize(width: dimensions.width, height: dimensions.height)) else {
            throw BeautyError.renderFailed("output_conversion_failed")
        }
        return extent.origin == .zero
            ? output
            : output.transformed(by: CGAffineTransform(translationX: extent.minX, y: extent.minY))
    }

    private func rasterize(image: CIImage, extent: CGRect, width: Int, height: Int) throws -> [UInt8] {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw BeautyError.unsupportedPixelFormat
        }
        let context = CIContext(options: [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace,
        ])
        guard let cgImage = context.createCGImage(
            image,
            from: extent,
            format: .RGBA8,
            colorSpace: colorSpace
        ),
        cgImage.width == width,
        cgImage.height == height,
        let providerData = cgImage.dataProvider?.data
        else {
            throw BeautyError.renderFailed("input_conversion_failed")
        }

        let packedRowBytes = try packedRowBytes(width: width)
        let sourceRowBytes = cgImage.bytesPerRow
        guard sourceRowBytes >= packedRowBytes,
              let source = CFDataGetBytePtr(providerData)
        else {
            throw BeautyError.renderFailed("input_conversion_failed")
        }
        var bytes = [UInt8](repeating: 0, count: packedRowBytes * height)
        for row in 0..<height {
            bytes.withUnsafeMutableBytes { destination in
                memcpy(
                    destination.baseAddress!.advanced(by: row * packedRowBytes),
                    source.advanced(by: row * sourceRowBytes),
                    packedRowBytes
                )
            }
        }
        guard stride(from: 3, to: bytes.count, by: 4).allSatisfy({ bytes[$0] == 255 }) else {
            throw BeautyError.invalidInput
        }
        return bytes
    }

    private func invokeRuntime(
        width: Int,
        height: Int,
        bytes: [UInt8],
        passes: [BeautyMetalPass]
    ) throws -> [UInt8] {
        hooks.onRuntimeInvocation()
        return try runtime.render(width: width, height: height, rgba8Bytes: bytes, passes: passes)
    }

    private func makePasses(
        plan: BeautyEffectPlan,
        selectedFaceSupport: BeautyFaceObservation?
    ) throws -> [BeautyMetalPass] {
        let face = selectedFaceSupport.map(BeautyFaceGeometryAdapter.makeGeometry(from:))
        let strengths = plan.effectiveStrengths
        let globalColor = !plan.activeDomains.isDisjoint(with: [.skin, .color, .filter])
        let lipRequested = plan.activeDomains.contains(.lipColor) && strengths.lipColor > 0
        let lipEnvelope = lipRequested ? face.flatMap(lipEnvelope) : nil
        let geometryPoints = face.map {
            BeautyGeometryEffectPipeline.controlPoints(for: plan, face: $0)
        } ?? []
        let geometry = try makeGeometryPass(points: geometryPoints)
        guard globalColor || lipEnvelope != nil || geometry != nil else { return [] }

        var passes: [BeautyMetalPass] = []

        let filter = filterContribution(for: plan)
        let parameters = try BeautyMetalColorParameters(
            saturationDelta: strengths.saturation * 0.28 + filter.saturation,
            contrastScale: 1 + strengths.contrast * 0.22 + strengths.skinSharpen * 0.18,
            lightLift: strengths.brightness * 0.16 + strengths.exposure * 0.10 + strengths.skinWhitening * 0.18 + filter.brightness,
            redBias: strengths.skinRosy * 0.08 + strengths.temperature * 0.04 + strengths.tint * 0.02 + filter.redBias,
            greenBias: strengths.skinWhitening * 0.02 + strengths.tint * 0.03 + filter.greenBias,
            blueBias: -strengths.temperature * 0.04 + filter.blueBias,
            highlightLift: strengths.highlight * 0.08,
            shadowLift: strengths.shadow * 0.08,
            smoothing: strengths.skinSmoothing * 0.16,
            lipCenterX: lipEnvelope?.centerX ?? 0,
            lipCenterY: lipEnvelope?.centerY ?? 0,
            lipRadiusX: lipEnvelope?.radiusX ?? 0,
            lipRadiusY: lipEnvelope?.radiusY ?? 0,
            lipStrength: min(strengths.lipColor, BeautySafetyCaps.lipColor),
            lipEnabled: lipEnvelope != nil
        )
        let uniform = parameters.uniform
        let isNeutral = uniform.saturationDelta == 0
            && uniform.contrastScale == 1
            && uniform.lightLift == 0
            && uniform.redBias == 0
            && uniform.greenBias == 0
            && uniform.blueBias == 0
            && uniform.highlightLift == 0
            && uniform.shadowLift == 0
            && uniform.smoothing == 0
            && uniform.lipEnabled == 0
        if !isNeutral {
            passes.append(.color(parameters))
        }
        if let geometry {
            // CPU applies color before the unified geometry pipeline. Keep the
            // same order in the bounded Metal graph and never synthesize a
            // second provider, support, or collision owner here.
            passes.append(geometry)
        }
        return passes
    }

    private func makeGeometryPass(points: [WarpControlPoint]) throws -> BeautyMetalPass? {
        guard !points.isEmpty,
              points.count <= BeautyMetalGeometryParameters.maximumPointCount
        else {
            return nil
        }

        let payload = points.compactMap { point -> BeautyMetalWarpPoint? in
            guard point.source.x.isFinite, point.source.y.isFinite,
                  point.target.x.isFinite, point.target.y.isFinite,
                  point.radius.isFinite, point.strength.isFinite,
                  point.falloff.isFinite,
                  (0...1).contains(point.source.x),
                  (0...1).contains(point.source.y),
                  (0...1).contains(point.target.x),
                  (0...1).contains(point.target.y),
                  point.radius > 0, point.radius <= 1,
                  abs(point.strength) <= 1,
                  point.falloff >= 1, point.falloff <= 3
            else {
                return nil
            }
            return try? BeautyMetalWarpPoint(
                sourceX: point.source.x,
                sourceY: point.source.y,
                targetX: point.target.x,
                targetY: point.target.y,
                radius: point.radius,
                strength: point.strength,
                falloff: point.falloff
            )
        }
        guard payload.count == points.count, !payload.isEmpty else {
            // Malformed support/geometry abstains locally. Face-agnostic
            // siblings remain eligible because this only omits this pass.
            return nil
        }
        return .geometry(try BeautyMetalGeometryParameters(points: payload))
    }

    private func lipEnvelope(of face: FaceGeometry) -> (centerX: Float, centerY: Float, radiusX: Float, radiusY: Float)? {
        guard let center = LandmarkGeometryHelper.center(of: face.outerLips),
              !face.outerLips.isEmpty
        else { return nil }
        let radiusX = max(face.outerLips.map { abs($0.x - center.x) }.max() ?? 0, 0.03)
        let radiusY = max(face.outerLips.map { abs($0.y - center.y) }.max() ?? 0, 0.02)
        guard center.x.isFinite, center.y.isFinite,
              radiusX.isFinite, radiusY.isFinite,
              (0...1).contains(center.x), (0...1).contains(center.y),
              radiusX <= 1, radiusY <= 1
        else { return nil }
        return (center.x, center.y, radiusX, radiusY)
    }

    private func filterContribution(for plan: BeautyEffectPlan) -> (brightness: Float, saturation: Float, redBias: Float, greenBias: Float, blueBias: Float) {
        guard plan.activeDomains.contains(.filter), plan.effectiveStrengths.filterIntensity > 0 else {
            return (0, 0, 0, 0, 0)
        }
        let intensity = plan.effectiveStrengths.filterIntensity
        if plan.metrics["beauty.effects.filter.softClean"] == 1 {
            return (intensity * 0.05, -intensity * 0.04, intensity * 0.015, intensity * 0.018, intensity * 0.012)
        }
        if plan.metrics["beauty.effects.filter.warmLight"] == 1 {
            return (intensity * 0.035, intensity * 0.025, intensity * 0.055, intensity * 0.020, -intensity * 0.025)
        }
        return (0, 0, 0, 0, 0)
    }

    private func bgraToRgba(_ bytes: [UInt8]) -> [UInt8] {
        var output = bytes
        for offset in stride(from: 0, to: output.count, by: 4) {
            output.swapAt(offset, offset + 2)
        }
        return output
    }

    private func rgbaToBgra(_ bytes: [UInt8]) -> [UInt8] {
        bgraToRgba(bytes)
    }

    private func dimensions(of output: BeautyBackendOutput) -> (width: Int, height: Int) {
        switch output {
        case .pixelBuffer(let pixelBuffer):
            (CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))
        case .stillImage(let image):
            (Int(image.extent.width), Int(image.extent.height))
        }
    }

    private func packedRowBytes(width: Int) throws -> Int {
        let result = width.multipliedReportingOverflow(by: 4)
        guard width > 0, result.overflow == false, result.partialValue > 0 else {
            throw BeautyError.invalidInput
        }
        return result.partialValue
    }

    private func read(
        pixelBuffer: CVPixelBuffer,
        width: Int,
        height: Int,
        rowBytes: Int
    ) throws -> [UInt8] {
        guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else {
            throw BeautyError.renderFailed("input_conversion_failed")
        }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        guard CVPixelBufferGetBytesPerRow(pixelBuffer) >= rowBytes,
              let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        else {
            throw BeautyError.renderFailed("input_conversion_failed")
        }
        var bytes = [UInt8](repeating: 0, count: rowBytes * height)
        let sourceRowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        bytes.withUnsafeMutableBytes { destination in
            for row in 0..<height {
                memcpy(
                    destination.baseAddress!.advanced(by: row * rowBytes),
                    baseAddress.advanced(by: row * sourceRowBytes),
                    rowBytes
                )
            }
        }
        return bytes
    }

    private func write(
        _ bytes: [UInt8],
        to pixelBuffer: CVPixelBuffer,
        width: Int,
        height: Int,
        rowBytes: Int
    ) throws {
        guard bytes.count == rowBytes * height,
              CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess
        else {
            throw BeautyError.renderFailed("output_conversion_failed")
        }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard CVPixelBufferGetBytesPerRow(pixelBuffer) >= rowBytes,
              let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        else {
            throw BeautyError.renderFailed("output_conversion_failed")
        }
        let destinationRowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        bytes.withUnsafeBytes { source in
            for row in 0..<height {
                memcpy(
                    baseAddress.advanced(by: row * destinationRowBytes),
                    source.baseAddress!.advanced(by: row * rowBytes),
                    rowBytes
                )
            }
        }
    }
}
