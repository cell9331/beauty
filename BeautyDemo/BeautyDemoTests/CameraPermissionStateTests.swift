import AVFoundation
import XCTest
@testable import BeautyDemo

@MainActor
final class CameraPermissionStateTests: XCTestCase {
    func testPIPE01PIPE08DEMO01MapsAuthorizationStatesForD03AndD07() {
        XCTAssertEqual(
            CameraPermissionState.map(authorizationStatus: .notDetermined, isCameraAvailable: true),
            .notDetermined
        )
        XCTAssertEqual(
            CameraPermissionState.map(authorizationStatus: .authorized, isCameraAvailable: true),
            .authorized
        )
        XCTAssertEqual(
            CameraPermissionState.map(authorizationStatus: .denied, isCameraAvailable: true),
            .denied
        )
        XCTAssertEqual(
            CameraPermissionState.map(authorizationStatus: .restricted, isCameraAvailable: true),
            .restricted
        )
        XCTAssertEqual(
            CameraPermissionState.map(authorizationStatus: .authorized, isCameraAvailable: false),
            .unavailable
        )
    }

    func testPIPE01D03RequestAccessOnlyRunsForNotDeterminedCameraSelection() async {
        var requestCount = 0
        let client = SystemCameraPermissionClient(
            authorizationStatus: { .notDetermined },
            cameraAvailability: { true },
            requestAccess: { completion in
                requestCount += 1
                completion(true)
            }
        )

        let state = await client.requestAccessIfNeeded()

        XCTAssertEqual(state, .authorized)
        XCTAssertEqual(requestCount, 1)
    }

    func testPIPE01D03DoesNotRequestWhenAlreadyDenied() async {
        var requestCount = 0
        let client = SystemCameraPermissionClient(
            authorizationStatus: { .denied },
            cameraAvailability: { true },
            requestAccess: { completion in
                requestCount += 1
                completion(true)
            }
        )

        let state = await client.requestAccessIfNeeded()

        XCTAssertEqual(state, .denied)
        XCTAssertEqual(requestCount, 0)
    }

    func testDEMO01D01EditorShellInitialStateDoesNotRequestCameraAccess() {
        let client = SpyCameraPermissionClient(result: .authorized)
        _ = EditorShellView(cameraPermissionClient: client)

        XCTAssertEqual(client.requestCount, 0)
    }

    func testPIPE01D06DeniedOrRestrictedKeepsCameraSelectedAndPhotoAvailable() {
        for state in [CameraPermissionState.denied, .restricted] {
            let previewState = EditorShellView.previewViewState(
                selectedMode: .camera,
                cameraPermissionState: state,
                cameraSessionState: .idle
            )
            let modeItems = EditorShellView.modeViewState(selectedMode: .camera)

            XCTAssertEqual(previewState.heading, "Camera access needed")
            XCTAssertEqual(previewState.body, "Allow camera access to preview processing on this device. Photo mode is still available.")
            XCTAssertEqual(previewState.primaryActionTitle, "Open Settings")
            XCTAssertEqual(modeItems.filter(\.isSelected).map(\.id), [.camera])
            XCTAssertTrue(modeItems.first { $0.id == .photo }?.isEnabled == true)
        }
    }

    func testPIPE01D07UnavailableCameraShowsTryAgainAndPhotoFallback() {
        let previewState = EditorShellView.previewViewState(
            selectedMode: .camera,
            cameraPermissionState: .unavailable,
            cameraSessionState: .idle
        )
        let modeItems = EditorShellView.modeViewState(selectedMode: .camera)

        XCTAssertEqual(previewState.heading, "Camera unavailable")
        XCTAssertEqual(previewState.body, "Live preview cannot start on this device. Use Photo mode to continue testing the SDK path.")
        XCTAssertEqual(previewState.primaryActionTitle, "Try Again")
        XCTAssertTrue(modeItems.first { $0.id == .photo }?.isEnabled == true)
    }
}

@MainActor
private final class SpyCameraPermissionClient: CameraPermissionClient {
    private let result: CameraPermissionState
    private(set) var requestCount = 0

    init(result: CameraPermissionState) {
        self.result = result
    }

    func currentState() -> CameraPermissionState {
        result
    }

    func requestAccessIfNeeded() async -> CameraPermissionState {
        requestCount += 1
        return result
    }
}
