# Pitfalls Research

**Domain:** Modular iOS beauty SDK with rich SwiftUI Demo app
**Researched:** 2026-06-10
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Building Visible Effects Before the Foundation

**What goes wrong:**
The project gets impressive screenshots but no stable package, facade, validation, tests, or input/output pipeline.

**Why it happens:**
Beauty apps are visually rewarding, so teams jump to skin/face effects before proving SDK integration.

**How to avoid:**
Roadmap foundation first: package targets, public facade, value models, no-op process path, tests, then visible effects.

**Warning signs:**
Demo-only code implements behavior that is not available through `BeautySDK`.

**Phase to address:**
Phase 1 and Phase 2.

---

### Pitfall 2: Realtime Pipeline Uses `UIImage`

**What goes wrong:**
Live preview stutters, memory churn rises, and the pipeline cannot meet frame latency expectations.

**Why it happens:**
`UIImage` is convenient for still images and SwiftUI previews, but camera frames arrive as sample buffers/pixel buffers.

**How to avoid:**
Keep realtime paths on `CMSampleBuffer`, `CVPixelBuffer`, Metal textures, and bounded in-flight processing.

**Warning signs:**
Realtime camera code imports UIKit image conversion utilities or allocates new image objects per frame.

**Phase to address:**
Camera pipeline phase.

---

### Pitfall 3: Coordinate and Mirroring Drift

**What goes wrong:**
Eyes warp in the wrong direction, face shape pulls the background, or overlays align in preview but not output.

**Why it happens:**
Vision landmarks, image pixels, texture coordinates, front-camera mirroring, and SwiftUI preview coordinates differ.

**How to avoid:**
Use a canonical image-normalized coordinate model and explicit mappers for Vision, texture, preview, and mirrored preview space.

**Warning signs:**
Effects are tuned by manual sign flips in UI code or per-effect coordinate hacks.

**Phase to address:**
Detection and coordinate phase.

---

### Pitfall 4: Naturalness Treated as Subjective Polish

**What goes wrong:**
The SDK produces plastic skin, sharp chins, fake smiles, over-saturated makeup, or warped backgrounds.

**Why it happens:**
UI ranges are exposed directly to algorithms without safety caps or combined-effect constraints.

**How to avoid:**
Add normalization, clamping, effect conflict rules, and visual fixture checks for default/natural/medium/high values.

**Warning signs:**
High slider values map linearly to extreme geometry without per-effect safety caps.

**Phase to address:**
Parameter model, render graph, and every effect phase.

---

### Pitfall 5: Resource Files Become Untrusted Code Paths

**What goes wrong:**
Invalid LUTs, presets, makeup packs, or sticker files crash processing or silently change behavior.

**Why it happens:**
Resource loading is treated as file I/O instead of product data validation.

**How to avoid:**
Version resource manifests, validate dimensions/ids/compatibility/ranges, and test invalid-resource behavior.

**Warning signs:**
Effects open arbitrary bundle paths directly or presets contain hidden behavior beyond parameters/resources.

**Phase to address:**
Resource system and presets phase.

---

### Pitfall 6: Privacy and Permissions Added Late

**What goes wrong:**
Camera/photo flows fail review, prompt at the wrong layer, or log sensitive image/landmark data.

**Why it happens:**
Demo code often starts with working camera access before Info.plist, privacy manifest, and logging boundaries are documented.

**How to avoid:**
Add camera/photo purpose strings before protected-resource access; keep permission prompts App-owned; add redacted logging and privacy-manifest review before SDK distribution.

**Warning signs:**
SDK code triggers protected-resource prompts or logs file paths, frame metadata, landmarks, or image details.

**Phase to address:**
Camera/photo phase and SDK distribution hardening.

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Implement effect directly in Demo | Fast visual proof | Breaks SDK module boundary | Only as throwaway spike outside main implementation. |
| Skip no-op process tests | Faster first commit | Cannot prove regression safety | Never for SDK foundation. |
| Use one giant target | Less package setup | Harder ownership, testing, distribution | Not acceptable for this project direction. |
| Store raw frames for debugging | Easier visual inspection | Privacy and storage risk | Only with explicit opt-in fixture/debug flow and redaction policy. |
| Add unversioned presets | Faster preset UI | Future schema drift | Not acceptable beyond disposable mock data. |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| AVFoundation camera | Queue every captured frame | Drop stale frames and bound in-flight work. |
| Vision landmarks | Ignore orientation/mirroring | Pass explicit orientation and map through canonical coordinates. |
| Metal rendering | Allocate textures/buffers every frame | Reuse caches/pools and centralize context ownership. |
| SwiftUI Demo | Run processing on main actor | Keep UI state main-actor; run SDK work off main where API allows. |
| Xcode package integration | Manually edit pbxproj broadly | Use narrow edits and verify with `xcodebuild -list` plus explicit simulator build. |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Per-frame image conversion | Stutter, memory spikes | Pixel-buffer/texture pipeline | As soon as live camera preview starts. |
| Unbounded queues | Latency grows behind user input | Drop stale frames and cap in-flight work | Under device pressure or high resolution. |
| Per-effect GPU passes | Battery drain, low FPS | Merge compatible color/skin operations and use RenderGraph | Once multiple effects combine. |
| Main-thread processing | Frozen sliders/preview | Run processing on capture/render queues | Immediately visible in Demo. |
| Missing quality modes | Low-end devices fail | Performance/quality configuration and degradation | Older devices or high-resolution images. |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Uploading faces/photos by default | Privacy breach and policy complexity | Local-only processing by default. |
| Logging sensitive paths or landmarks | User data leakage | Redact logs; aggregate metrics. |
| Loading arbitrary resources | Crash, wrong output, unsafe file access | Manifest validation and bundle/path constraints. |
| SDK-owned permission prompts | Host app loses UX control | Demo/host app owns camera/photo authorization. |
| Missing privacy manifest review | Distribution compliance risk | Evaluate `PrivacyInfo.xcprivacy` when SDK target ships. |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Disabled effects look active | Users think SDK is broken | Hide or visibly disable unavailable controls. |
| Sliders do not sync after preset | Users lose trust in controls | Applying preset updates all mapped slider state. |
| Compare shifts crop/orientation | Before/after comparison feels fake | Same crop/orientation for both states. |
| Too many controls before presets | Users cannot find a good look quickly | Presets first, fine tuning second. |
| Overpowered default values | Output looks fake immediately | Default no-op; natural preset conservative. |

## "Looks Done But Isn't" Checklist

- [ ] **SDK facade:** Often missing internal-target hiding — verify Demo imports only `BeautySDK`.
- [ ] **Camera preview:** Often missing frame dropping — verify bounded in-flight policy.
- [ ] **Still image:** Often missing EXIF orientation — verify rotated fixture images.
- [ ] **Presets:** Often missing schema/version validation — verify invalid presets.
- [ ] **Filters:** Often missing missing-resource behavior — verify absent LUT path.
- [ ] **Geometry effects:** Often missing no-face behavior — verify no crash/no unsafe warp.
- [ ] **Privacy:** Often missing purpose strings and manifest review — verify before camera/photo/shipping.
- [ ] **Tests:** Often missing facade import tests — verify host-app-style import works.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Demo imports internals | MEDIUM | Add missing facade API, migrate Demo imports, add grep test. |
| Realtime path uses `UIImage` | HIGH | Replace with pixel-buffer/texture pipeline, add allocation/performance checks. |
| Coordinate model wrong | HIGH | Freeze coordinate contract, add fixtures, rewrite mappers before more effects. |
| Resource validation missing | MEDIUM | Add manifest schema, validators, invalid-resource tests. |
| Privacy prompts/logging wrong | MEDIUM/HIGH | Move prompts to Demo/host layer, redact logs, update privacy docs/manifests. |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Effects before foundation | SDK foundation | Package builds, facade imports, no-op process tests. |
| Realtime `UIImage` conversion | Camera pipeline | Search for `UIImage` in realtime path; performance smoke. |
| Coordinate drift | Detection/coordinates | Fixture-based mapping tests for orientation/mirroring. |
| Fake-looking output | Core effects | Natural preset checks and safety-cap tests. |
| Resource trust | Presets/resources | Invalid manifest and missing-resource tests. |
| Privacy late | Camera/photo and distribution | Purpose strings, log redaction checks, privacy manifest review. |

## Sources

- Apple Developer Documentation, `AVCaptureVideoDataOutput`: https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutput
- Apple Technical Note TN2445, Handling Frame Drops with `AVCaptureVideoDataOutput`: https://developer.apple.com/library/archive/technotes/tn2445/_index.html
- Apple Developer Documentation, `VNDetectFaceLandmarksRequest`: https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest
- Apple Developer Documentation, Metal: https://developer.apple.com/documentation/metal
- Apple Developer Documentation, `CIColorCube`: https://developer.apple.com/documentation/coreimage/cicolorcube
- Apple Developer Documentation, privacy manifests for apps and third-party SDKs: https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk
- Local `SECURITY.md`, `RELIABILITY.md`, `FRONTEND.md`, `DESIGN.md`, `PRODUCT_SENSE.md`, `.planning/codebase/CONCERNS.md`.

---
*Pitfalls research for: modular iOS beauty SDK*
*Researched: 2026-06-10*
