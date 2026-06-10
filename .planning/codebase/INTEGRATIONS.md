# External Integrations

**Analysis Date:** 2026-06-10

## APIs & External Services

**Payment Processing:**
- None found in code.

**Email/SMS:**
- None found in code.

**External APIs:**
- None found in code.
- Root contracts explicitly require local-first image processing by default. `SECURITY.md` says network, cloud processing, telemetry upload, license checks, or dynamic resource download require an explicit security and reliability update first.

## Data Storage

**Databases:**
- None found.

**File Storage:**
- None found.
- Asset metadata is local and bundled through `BeautyDemo/BeautyDemo/Assets.xcassets`.

**Caching:**
- None implemented in current source.
- Future SDK docs discuss bounded texture/resource caches, but no `BeautySDK` source exists yet.

## Authentication & Identity

**Auth Provider:**
- None found.

**OAuth Integrations:**
- None found.

## Apple Platform Capabilities

**Current app capabilities:**
- Current code imports only SwiftUI.
- No `AVCaptureSession`, `AVCaptureDevice.requestAccess`, PhotoKit, Vision, Metal, Core Image, or Core ML usage appears in current app source.

**Protected resource declarations:**
- No checked-in `Info.plist` exists because the Xcode project generates Info.plist.
- Build settings currently generate launch screen, scene manifest, supported orientations, and indirect input events.
- No `NSCameraUsageDescription` or `NSPhotoLibraryUsageDescription` is configured in the checked-in project.
- No `PrivacyInfo.xcprivacy` file exists.

**Future capability constraints from contracts:**
- Camera permission is owned by `BeautyDemo`, not the SDK.
- A distributed `BeautySDK` must add `PrivacyInfo.xcprivacy` when its behavior or required-reason APIs require it.
- Realtime processing must avoid `UIImage` in the frame path.

## Monitoring & Observability

**Error Tracking:**
- None implemented.

**Analytics:**
- None implemented.

**Logs:**
- No logging framework is used by current Swift code.
- `RELIABILITY.md` defines future local diagnostics through `BeautyCore/Diagnostics` and Swift `Logger` / OSLog, but this is not implemented.

## CI/CD & Deployment

**Hosting:**
- Not applicable to current iOS demo app.

**CI Pipeline:**
- No `.github/workflows`, CI YAML, or project-specific pipeline files were found in the main worktree.

## Environment Configuration

**Development:**
- Current development is local Xcode-based.
- Key commands:
  - `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj`
  - `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build`

**Staging:**
- None defined.

**Production:**
- None defined.

## Webhooks & Callbacks

**Incoming:**
- None.

**Outgoing:**
- None.

---
*Integration audit: 2026-06-10*
*Update when adding Apple protected-resource usage, network features, CI, telemetry, or external resources.*
