import AVFoundation
import Foundation

enum CameraPermissionState: Equatable, Sendable {
    case notDetermined
    case requesting
    case authorized
    case denied
    case restricted
    case unavailable

    static func map(
        authorizationStatus: AVAuthorizationStatus,
        isCameraAvailable: Bool
    ) -> CameraPermissionState {
        guard isCameraAvailable else {
            return .unavailable
        }

        switch authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        @unknown default:
            return .unavailable
        }
    }

    var isPermissionBlocked: Bool {
        self == .denied || self == .restricted
    }
}

@MainActor
protocol CameraPermissionClient: AnyObject {
    func currentState() -> CameraPermissionState
    func requestAccessIfNeeded() async -> CameraPermissionState
}

@MainActor
final class SystemCameraPermissionClient: CameraPermissionClient {
    private let authorizationStatus: () -> AVAuthorizationStatus
    private let cameraAvailability: () -> Bool
    private let requestAccess: (@escaping @Sendable (Bool) -> Void) -> Void

    init(
        authorizationStatus: @escaping () -> AVAuthorizationStatus = {
            AVCaptureDevice.authorizationStatus(for: .video)
        },
        cameraAvailability: @escaping () -> Bool = {
            AVCaptureDevice.default(for: .video) != nil
        },
        requestAccess: @escaping (@escaping @Sendable (Bool) -> Void) -> Void = { completion in
            AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
        }
    ) {
        self.authorizationStatus = authorizationStatus
        self.cameraAvailability = cameraAvailability
        self.requestAccess = requestAccess
    }

    func currentState() -> CameraPermissionState {
        CameraPermissionState.map(
            authorizationStatus: authorizationStatus(),
            isCameraAvailable: cameraAvailability()
        )
    }

    func requestAccessIfNeeded() async -> CameraPermissionState {
        let state = currentState()
        guard state == .notDetermined else {
            return state
        }

        let granted = await withCheckedContinuation { continuation in
            requestAccess { granted in
                continuation.resume(returning: granted)
            }
        }

        let mappedState = currentState()
        if mappedState == .notDetermined {
            return granted && cameraAvailability() ? .authorized : .denied
        }

        return mappedState
    }
}
