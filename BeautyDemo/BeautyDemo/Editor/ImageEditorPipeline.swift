import BeautySDK
import Combine
import CoreGraphics
import CoreImage
import Foundation
import ImageIO

nonisolated struct ImageInputDecoder: Sendable {
    let decode: @Sendable (ImageInputSource) throws -> DecodedImageInput?

    nonisolated init(decode: @escaping @Sendable (ImageInputSource) throws -> DecodedImageInput?) {
        self.decode = decode
    }

    static let `default` = ImageInputDecoder { source in
        switch source.kind {
        case .cancelled:
            return nil
        case .fixture:
            guard let image = source.fixtureImage else {
                throw BeautyError.invalidInput
            }
            return DecodedImageInput(source: source, image: image, orientation: source.orientation)
        case .photosPickerData:
            guard let data = source.data, let image = CIImage(data: data) else {
                throw BeautyError.invalidInput
            }
            return DecodedImageInput(source: source, image: image, orientation: source.orientation)
        }
    }
}

nonisolated struct StillImageProcessor: Sendable {
    let process: @Sendable (CIImage, CGImagePropertyOrientation, BeautyParameters) throws -> CIImage

    nonisolated init(
        process: @escaping @Sendable (CIImage, CGImagePropertyOrientation, BeautyParameters) throws -> CIImage
    ) {
        self.process = process
    }

    static func beautyEngine() -> StillImageProcessor {
        do {
            let processor = try BeautyEngineStillImageProcessor()
            return StillImageProcessor { image, orientation, parameters in
                try processor.process(image: image, orientation: orientation, parameters: parameters)
            }
        } catch {
            return StillImageProcessor { _, _, _ in
                throw BeautyError.metalUnavailable
            }
        }
    }
}

nonisolated final class ImageDisplayRenderer: @unchecked Sendable {
    private let context: CIContext

    nonisolated init(context: CIContext = CIContext(options: [.workingColorSpace: CGColorSpaceCreateDeviceRGB()])) {
        self.context = context
    }

    func render(_ image: CIImage) throws -> CGImage {
        guard let cgImage = context.createCGImage(image, from: image.extent) else {
            throw BeautyError.invalidInput
        }
        return cgImage
    }
}

@MainActor
final class ImageEditorPipeline: ObservableObject {
    @Published private(set) var state: PhotoProcessingState = .empty

    private let decoder: ImageInputDecoder
    private let processor: StillImageProcessor
    private let renderer: ImageDisplayRenderer
    private let processingQueue: DispatchQueue
    private var latestInput: ImageInputSource?
    private var generation: UInt64 = 0
    private var activeCount = 0
    private var idleContinuations: [CheckedContinuation<Void, Never>] = []

    init(
        decoder: ImageInputDecoder = .default,
        processor: StillImageProcessor = .beautyEngine(),
        renderer: ImageDisplayRenderer = ImageDisplayRenderer(),
        processingQueue: DispatchQueue = DispatchQueue(label: "beauty.demo.photo.pipeline", qos: .userInitiated)
    ) {
        self.decoder = decoder
        self.processor = processor
        self.renderer = renderer
        self.processingQueue = processingQueue
    }

    func process(input: ImageInputSource, parameters: BeautyParameters) {
        guard input.kind != .cancelled else {
            return
        }

        latestInput = input
        generation &+= 1
        let work = ImageProcessingWork(input: input, parameters: parameters, generation: generation)
        let previousSnapshot = state.latestSnapshot
        state = .loading(previousSnapshot: previousSnapshot)
        activeCount = 1

        let decoder = decoder
        let processor = processor
        let renderer = renderer
        processingQueue.async {
            let result: ImageProcessingResult
            do {
                guard let decoded = try decoder.decode(work.input) else {
                    result = .cancelled
                    Task { @MainActor in
                        self.finish(work, result: result)
                    }
                    return
                }

                let outputImage = try processor.process(decoded.image, decoded.orientation, work.parameters)
                let snapshot = ImageProcessingSnapshot(
                    sourceKind: decoded.source.kind,
                    sourceID: decoded.source.id,
                    inputImage: decoded.image,
                    outputImage: outputImage,
                    inputCGImage: try renderer.render(decoded.image),
                    outputCGImage: try renderer.render(outputImage),
                    orientation: decoded.orientation,
                    parameters: work.parameters
                )
                result = .success(snapshot)
            } catch {
                result = .failure
            }

            Task { @MainActor in
                self.finish(work, result: result)
            }
        }
    }

    func reprocessLatest(parameters: BeautyParameters) {
        guard let latestInput else {
            return
        }

        process(input: latestInput, parameters: parameters)
    }

    func recordSelectionFailure() {
        generation &+= 1
        activeCount = 0
        state = .failed(
            previousSnapshot: state.latestSnapshot,
            message: PhotoProcessingState.decodeFailureText
        )
        resumeIdleContinuationsIfNeeded()
    }

    func waitUntilIdle() async {
        if activeCount == 0 {
            return
        }

        await withCheckedContinuation { continuation in
            idleContinuations.append(continuation)
        }
    }

    private func finish(_ work: ImageProcessingWork, result: ImageProcessingResult) {
        guard work.generation == generation else {
            return
        }

        activeCount = 0
        switch result {
        case .success(let snapshot):
            state = .loaded(snapshot)
        case .cancelled:
            break
        case .failure:
            state = .failed(
                previousSnapshot: state.latestSnapshot,
                message: PhotoProcessingState.decodeFailureText
            )
        }
        resumeIdleContinuationsIfNeeded()
    }

    private func resumeIdleContinuationsIfNeeded() {
        guard activeCount == 0 else {
            return
        }

        let continuations = idleContinuations
        idleContinuations.removeAll()
        continuations.forEach { $0.resume() }
    }
}

nonisolated private struct ImageProcessingWork: @unchecked Sendable {
    let input: ImageInputSource
    let parameters: BeautyParameters
    let generation: UInt64
}

nonisolated private enum ImageProcessingResult: @unchecked Sendable {
    case success(ImageProcessingSnapshot)
    case cancelled
    case failure
}

nonisolated private final class BeautyEngineStillImageProcessor: @unchecked Sendable {
    private let engine: BeautyEngine

    nonisolated init() throws {
        self.engine = try BeautyEngine(configuration: .default)
    }

    func process(
        image: CIImage,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CIImage {
        try engine.process(
            image: image,
            orientation: orientation,
            parameters: parameters
        )
    }
}
