@preconcurrency import AVFoundation
import Combine
import CoreMedia
import CoreVideo
import Foundation
import ImageIO

@MainActor
final class CameraSessionController: NSObject, ObservableObject {
    @Published private(set) var state: CameraSessionState = .idle

    nonisolated(unsafe) let session: AVCaptureSession
    private let sessionQueue: DispatchQueue
    private let sampleQueue: DispatchQueue
    private let sampleSink = CameraSampleBufferSink()
    private let lifecycle: CameraSessionLifecycle

    nonisolated static let requestedPixelFormat: OSType = kCVPixelFormatType_32BGRA
    nonisolated static let videoOutputSettings: [String: Any] = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]

    init(
        session: AVCaptureSession = AVCaptureSession(),
        sessionQueue: DispatchQueue = DispatchQueue(label: "beauty.demo.camera.session"),
        sampleQueue: DispatchQueue = DispatchQueue(label: "beauty.demo.camera.frames"),
        lifecycle: CameraSessionLifecycle = CameraSessionLifecycle()
    ) {
        self.session = session
        self.sessionQueue = sessionQueue
        self.sampleQueue = sampleQueue
        self.lifecycle = lifecycle
        super.init()
    }

    func start(onFrame: ((CameraPreviewFrame) -> Void)? = nil) {
        guard state != .configuring, state != .running else {
            return
        }

        let lifecycleGeneration = lifecycle.beginStart()
        state = .configuring
        sampleSink.onFrame = { frame in
            Task { @MainActor in
                onFrame?(frame)
            }
        }

        let session = session
        let sampleQueue = sampleQueue
        let sampleSink = sampleSink
        let lifecycle = lifecycle
        let controller = self

        sessionQueue.async {
            let configurationResult = Self.configureSession(
                session,
                sampleSink: sampleSink,
                sampleQueue: sampleQueue
            )

            switch configurationResult {
            case .success:
                guard lifecycle.permitsRunning(generation: lifecycleGeneration) else {
                    return
                }
                if !session.isRunning {
                    session.startRunning()
                }

                Task { @MainActor in
                    guard lifecycle.permitsRunning(generation: lifecycleGeneration) else {
                        return
                    }
                    controller.state = .running
                }
            case .failure(let failure):
                Task { @MainActor in
                    guard lifecycle.permitsRunning(generation: lifecycleGeneration) else {
                        return
                    }
                    controller.state = failure == .noVideoDevice ? .unavailable : .failedSetup(failure)
                }
            }
        }
    }

    func stop() {
        lifecycle.cancel()
        guard state != .idle else {
            return
        }

        let session = session
        sessionQueue.async {
            if session.isRunning {
                session.stopRunning()
            }
        }
        state = .idle
    }

    nonisolated static func makeVideoOutput(
        delegate: AVCaptureVideoDataOutputSampleBufferDelegate?,
        queue: DispatchQueue?
    ) -> AVCaptureVideoDataOutput {
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = videoOutputSettings
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(delegate, queue: queue)
        return output
    }

    nonisolated static func makeFrame(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation = .right,
        timestamp: TimeInterval,
        source: CameraPreviewFrame.Source = .camera
    ) -> CameraPreviewFrame {
        CameraPreviewFrame(
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            timestamp: timestamp,
            source: source
        )
    }

    nonisolated static func makeFrame(
        from sampleBuffer: CMSampleBuffer,
        orientation: CGImagePropertyOrientation = .right
    ) -> CameraPreviewFrame? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }

        return makeFrame(
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            timestamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        )
    }

    nonisolated private static func configureSession(
        _ session: AVCaptureSession,
        sampleSink: CameraSampleBufferSink,
        sampleQueue: DispatchQueue
    ) -> Result<Void, CameraSessionFailure> {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }

        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        }

        if session.inputs.isEmpty {
            guard let device = AVCaptureDevice.default(for: .video) else {
                return .failure(.noVideoDevice)
            }

            let input: AVCaptureDeviceInput
            do {
                input = try AVCaptureDeviceInput(device: device)
            } catch {
                return .failure(.cannotCreateInput)
            }

            guard session.canAddInput(input) else {
                return .failure(.cannotAddInput)
            }
            session.addInput(input)
        }

        if !session.outputs.contains(where: { $0 is AVCaptureVideoDataOutput }) {
            let output = makeVideoOutput(delegate: sampleSink, queue: sampleQueue)
            guard session.canAddOutput(output) else {
                return .failure(.cannotAddOutput)
            }
            session.addOutput(output)
        }

        return .success(())
    }
}

nonisolated final class CameraSessionLifecycle: @unchecked Sendable {
    private let lock = NSLock()
    private var generation: UInt64 = 0
    private var wantsRunning = false

    func beginStart() -> UInt64 {
        lock.lock()
        defer { lock.unlock() }

        generation &+= 1
        wantsRunning = true
        return generation
    }

    func cancel() {
        lock.lock()
        defer { lock.unlock() }

        generation &+= 1
        wantsRunning = false
    }

    func permitsRunning(generation candidate: UInt64) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        return wantsRunning && generation == candidate
    }
}

private final class CameraSampleBufferSink: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated(unsafe) var onFrame: ((CameraPreviewFrame) -> Void)?

    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let frame = CameraSessionController.makeFrame(from: sampleBuffer) else {
            return
        }

        onFrame?(frame)
    }
}
