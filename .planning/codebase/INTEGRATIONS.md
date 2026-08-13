# External Integrations

**Analysis Date:** 2026-08-13

## APIs & External Services

**Apple On-Device Vision:**
- Vision face landmark detection - Used locally to derive internal face observations and request-local support for geometry and local retouch.
  - SDK/Client: Apple `Vision` framework, imported by `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`.
  - Auth: None; `VNDetectFaceLandmarksRequest` executes on-device and does not require an API key.
  - Boundary: Keep raw Vision observations, landmarks, pupils, and masks inside `BeautyDetection` and request-local SDK internals as required by `ARCHITECTURE.md` and `SECURITY.md`.

**Apple Camera:**
- AVFoundation capture - Provides Demo camera permission, capture session, BGRA video frames, and preview.
  - SDK/Client: Apple `AVFoundation`, `CoreMedia`, and `CoreVideo` in `BeautyDemo/BeautyDemo/Camera/CameraPermissionClient.swift`, `BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift`, and `BeautyDemo/BeautyDemo/Camera/CameraPreviewLayerView.swift`.
  - Auth: iOS camera permission requested through `AVCaptureDevice.requestAccess(for: .video)` in `BeautyDemo/BeautyDemo/Camera/CameraPermissionClient.swift`.
  - Configuration: `NSCameraUsageDescription` is generated from `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.

**Apple Photo Library:**
- PhotosUI picker - Lets the Demo select local images without implementing a remote file service.
  - SDK/Client: Apple `PhotosUI` through `PhotosPicker` in `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift`.
  - Auth: System-managed picker access; `NSPhotoLibraryUsageDescription` is generated from `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` for the app’s declared photo flow.

**Network / Cloud Services:**
- Not detected. Active SDK and Demo sources under `BeautySDK/Sources/` and `BeautyDemo/BeautyDemo/` contain no `URLSession`, HTTP endpoint, upload, remote configuration, analytics, account, payment, entitlement, or cloud SDK integration.
- Preserve the local-first boundary enforced by `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` and documented in `SECURITY.md`; adding a service requires explicit privacy, integrity, dependency, failure, and licensing design.

## Data Storage

**Databases:**
- Not detected. There is no database client, schema, ORM, or connection configuration in `BeautySDK/Package.swift`, `BeautySDK/Sources/`, or `BeautyDemo/BeautyDemo/`.

**File Storage:**
- Bundled SwiftPM resources only for production SDK data: `BeautySDK/Sources/BeautyResources/Resources/manifest.json`, `BeautySDK/Sources/BeautyResources/Resources/Presets/*.json`, and `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`.
- `BeautyResourceCatalog` resolves immutable resources with `Bundle.module` in `BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift`; no remote resource or runtime download path exists.
- `BeautyExampleRenderer` reads local fixture directories and writes local PNG evidence using `FileManager` in `BeautySDK/Sources/BeautyExampleRenderer/main.swift`. This is an executable/evidence workflow, not SDK persistence.
- Local real-image fixtures and generated review outputs are Git-ignored under `example-images/`; authorization metadata is tracked separately in `example-images/FIXTURE_AUTHORIZATION.md`.
- Demo photo selection is in-memory through `PhotosPickerItem` processing in `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` and `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift`; active source contains no raw photo/frame persistence path.

**Caching:**
- No external or disk cache is detected. `BeautyStillImageCanonicalizer` reuses an in-process `CIContext` in `BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift`, while image buffers, observations, masks, and local-retouch ownership remain request-local.
- Do not introduce persistence for raw images, landmarks, masks, pupil positions, teeth geometry, or vein patterns; the request-local invariant is defined in `.codex/skills/spike-findings-beauty/SKILL.md` and `SECURITY.md`.

## Authentication & Identity

**Auth Provider:**
- None. The SDK and Demo have no login, account, OAuth, token, session, Keychain, or identity-provider integration in `BeautySDK/Sources/` or `BeautyDemo/BeautyDemo/`.
- Camera access is device permission, not user authentication; its state mapping and request path live in `BeautyDemo/BeautyDemo/Camera/CameraPermissionClient.swift`.

## Monitoring & Observability

**Error Tracking:**
- None. No Sentry, Firebase Crashlytics, hosted crash reporter, or telemetry client is declared in `BeautySDK/Package.swift` or imported by `BeautySDK/Sources/` and `BeautyDemo/BeautyDemo/`.

**Logs:**
- Production-facing diagnostics are local typed results: `BeautyError`, `BeautyValidationWarning`, `BeautyDetectionSummary`, and aggregate metrics under `BeautySDK/Sources/BeautyCore/Models/` and `BeautySDK/Sources/BeautyCore/Diagnostics/`.
- The example renderer prints only local output filenames in `BeautySDK/Sources/BeautyExampleRenderer/main.swift`; select test/evidence suites print aggregate reports under `BeautySDK/Tests/`.
- Do not log raw images, Vision objects, geometry, masks, paths, errors, or stable biometric signatures. Redacted diagnostics and privacy tests are owned by `SECURITY.md`, `RELIABILITY.md`, and `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift`.

## CI/CD & Deployment

**Hosting:**
- Not applicable. This repository builds an iOS Demo, a Swift package library, and a local macOS evidence renderer from `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` and `BeautySDK/Package.swift`.
- No App Store deployment, hosted backend, package registry publication, or production distribution configuration is present.

**CI Pipeline:**
- Not detected. No `.github/workflows/`, GitLab CI, Jenkins, Bitrise, or Fastlane pipeline is present in the inspected repository.
- Local verification entry points are `swift test --package-path BeautySDK`, `scripts/run-no-skip-swiftpm.sh`, and explicit-simulator `xcodebuild` commands documented in `AGENTS.md`.

## Environment Configuration

**Required env vars:**
- None for normal SDK, Demo, renderer build, or the default SwiftPM test run; no `.env` files are present.
- Private real-fixture Vision tests under `BeautySDK/Tests/BeautyCoreTests/BeautyTeethWhiteningRealFixtureTests.swift` and `BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift` use opt-in test-process environment configuration and local ignored assets. Treat their exact variable contracts as test-only, not application configuration.

**Secrets location:**
- Not applicable. No credential, key, certificate, package-auth, or service-account file is part of the detected runtime integration surface.
- User-authorized fixture rights are recorded without service secrets in `example-images/FIXTURE_AUTHORIZATION.md`; binary portrait data remains local and ignored under `example-images/`.

## Webhooks & Callbacks

**Incoming:**
- No network webhooks or URL callbacks are implemented.
- Local asynchronous framework callbacks exist for camera permission and capture frames in `BeautyDemo/BeautyDemo/Camera/CameraPermissionClient.swift` and `BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift`; these are in-process Apple framework callbacks, not externally reachable endpoints.

**Outgoing:**
- None. SDK and Demo processing does not emit HTTP requests, webhook deliveries, analytics events, uploads, or remote crash reports from `BeautySDK/Sources/` or `BeautyDemo/BeautyDemo/`.

---

*Integration audit: 2026-08-13*
