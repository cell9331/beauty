# SECURITY.md

> `beauty` 的安全与隐私约束。本文定义信任边界、输入校验、资源校验、日志脱敏和分发安全。
> 错误恢复与性能指标看 `RELIABILITY.md`，数据模型看 `DESIGN.md`。

## 1. Security Posture

`beauty` 是处理人像、相机帧、照片和面部关键点的 iOS 美颜 SDK。默认安全姿态：

- 默认只在设备本地处理图像与人脸数据。
- 默认不上传图片、视频、面部关键点或参数。
- 默认不持久化原始相机帧、原始照片、人脸关键点或 debug 中间纹理。
- 默认不把用户文件路径、照片路径、面部数据写入日志。
- 所有外部输入必须先校验，再进入检测、渲染或资源加载链路。

任何网络能力、云端处理、遥测上报、授权校验或动态资源下载，都必须先更新本文。

## 2. Data Classification

| Data | Classification | Storage | Logging | Notes |
| --- | --- | --- | --- | --- |
| Camera frame / photo pixels | Sensitive user content | Default no persistence | Forbidden | Only keep in memory for processing. |
| Face landmarks / bounding boxes | Biometric-adjacent derived data | Default no persistence | Forbidden | Treat as sensitive even if not identity-grade. |
| Beauty parameters | User preference data | Allowed if user or App requests | Allowed only aggregate / non-identifying | Can be Codable preset data. |
| Preset JSON | Product configuration | Allowed | Allowed with ID/version | Must validate schema and ranges. |
| LUT / makeup / model resources | Executable-adjacent product asset | Allowed | Allowed with ID/version/checksum | External packages need integrity checks. |
| Performance metrics | Operational data | Allowed if anonymized | Allowed if sampled | No image, path, face geometry, or device identifiers. |
| Crash / error diagnostics | Operational data | Allowed if redacted | Allowed if redacted | No raw frames, paths, tokens, or facial data. |

### 2.1 Detection Summary and Debug Privacy

`BeautyDetectionSummary` and Demo `DetectionDebugSummary` are allowed to expose only:

- Detection availability enum values.
- Redacted degradation reason codes.
- Face counts and used-face counts.
- Detection and coordinate-mapping durations.

They must never expose:

- Bounding boxes, points, rectangles, or landmark coordinates.
- Raw `VNFaceObservation`, Vision request objects, Core Image/Metal internals, or raw framework errors.
- Raw `NSError` / `AVError` strings.
- Local image paths such as `/private/var/...`.
- Image bytes, thumbnails, or persisted debug textures.

`InputPipelinePrivacyTests` owns the current automated guard for these public summary and Demo debug boundaries.

Phase 26 facade-geometry privacy evidence recorded 2026-07-06:

- `BeautyEngineGeometryFacadeTests` and resolver/degradation tests prove public still-image geometry activation through summaries, warnings, and aggregate metrics only.
- Public/SPI raw geometry export scans passed with zero matches for public or SPI exposure of `VisionDetectionObservation`, `BeautyFaceObservation`, `FaceGeometry`, raw landmarks, bounding boxes, or control points.
- Active-source scans over `BeautySDK` public/Core surfaces and active Demo source passed for raw Vision observation names, raw framework errors, absolute local paths, raw JSON, image bytes, and raw landmark strings.
- Phase 26 did not add Demo UI behavior, renderer geometry cases, saved-output PNG claims, network behavior, or `SHAPE_FEATURE_LEDGER.md` implementation-status promotion.

Phase 27 geometry-output privacy evidence recorded 2026-07-07:

- `BeautyExampleRenderer` remains public-facade-only and writes generated geometry PNGs only under ignored `example-images/output/`; generated human-review copies stay under ignored `example-images/gallery/`.
- `27-VERIFICATION.md` records public/SPI raw geometry export scans, active-source redaction scans, renderer public-import scans, Demo internal-import scans, and evidence-doc raw-leak scans as passed.
- The generated-output helper records only relative fixture names, case IDs, counts, dimensions, geometry-vs-baseline comparison counts, and no-face output presence.
- Phase 27 did not add Demo UI behavior, public raw geometry APIs, network behavior, raw geometry evidence fields, generated PNG baselines, or `SHAPE_FEATURE_LEDGER.md` implementation-status promotion.

Phase 28 face-shape privacy evidence recorded 2026-07-08:

- `BeautyExampleRenderer` remains public-facade-only while adding scoped face-shape cases for existing parameters.
- `28-VERIFICATION.md` records public/import boundary scans, hidden public-surface scans, redaction scans, ignored-output checks, and wording guards as passed.
- The Phase 28 helper records only relative fixture names, case IDs, counts, dimensions, top-region comparison counts, and no-face output presence.
- Generated PNGs remain ignored local artifacts; docs record commands and counts rather than generated image baselines or hashes.
- Phase 28 did not add Demo UI behavior, public raw geometry APIs, network behavior, raw geometry evidence fields, a distinct `下颌线` parameter, or broader branch status claims.

### Phase 30 Eye Safety Boundary Evidence

- EYE-07 validation proves positive-only size/tail behavior, signed distance/position behavior, finite range and cap enforcement, and non-finite normalization before eye geometry is produced. Missing, reused, or stale eye inputs emit only fixed category messages/codes and aggregate metrics.
- The asserted active roots cover the public SDK surface, `BeautyCore`, `BeautyRender`, renderer source, and active Demo source. A multiline public/SPI scan found no exposure of `FaceGeometry`, `WarpControlPoint`, `CGPoint`, or `CGRect`; renderer and Demo checks found no forbidden internal import.
- Network/cloud API scans and StoreKit/entitlement scans returned no active execution paths. The only `vipChip` candidates are the two classified static allowlist occurrences `VIP-COMMERCIAL-ALLOW-01` and `VIP-COMMERCIAL-ALLOW-02`; `unclassified_matches: 0`.
- The inventory observed by the historical Phase 30/38 contract contained exactly 38 public stored fields (37 numeric plus `filterId`). Generated renderer outputs and gallery copies remained ignored, untracked local artifacts rather than committed evidence.
- Command-backed details are in `30-EYE-SAFETY-EVIDENCE.md`; threat classifications and sign-off are in `30-SECURITY.md`.

### Phase 32 Nose Safety Boundary Evidence

- Public and effective parameter tests lock three legacy positive-only fields, signed `noseTipSize`, exact caps, and non-finite normalization for the historical 31-field public inventory.
- Missing/stale nose geometry fails closed with zero strengths and category-level warnings; reused geometry exposes only the aggregate `0.5` scale.

### Phase 35 Independent Nose Security Boundary

- The current public inventory is 33 stored fields = 32 numeric plus `filterId`; `noseRootNarrowing` and `noseTipLift` are scalar parameters only and do not expose geometry.
- `FaceGeometry.noseRoot` and `.noseTip` are package-internal, default-empty explicit supports. No public/SPI raw geometry, `WarpControlPoint`, landmark, bounds, SIMD support array, or provider type crosses the facade.
- Non-finite public values become zero. Private supports are checked for finiteness, normalized/face bounds, distinctness, sufficient cardinality, and field-specific root/tip structure before any target clamp.
- New helpers never fall back to the legacy `FaceGeometry.nose` proxy. Malformed support zeros only the matching new field and emits redacted category/aggregate diagnostics without points, coordinates, paths, or framework details.
- Phase 35 ASVS L1 evidence in `35-SECURITY.md` and `35-VERIFICATION.md` found no dependency, network/cloud, commercial, renderer/Demo, generated-artifact, archive-tampering, or public raw-geometry drift. Phase 36/37 remain required before product promotion.
- Renderer and Demo remain facade-only; scans find no public/SPI raw geometry, network/cloud execution, StoreKit/entitlement/payment path, or new dependency.
- All 196 output/gallery PNGs remain ignored local artifacts; `git ls-files example-images/output example-images/gallery` returns zero files.
- Command-backed details are in `32-NOSE-SAFETY-EVIDENCE.md`; threat sign-off is in `32-SECURITY.md` with `threats_open: 0`.

### Phase 36 Generated-Gallery Publication Boundary

- Gallery population and publication stay anchored to no-follow repository descriptors. Staging directories and destination files are created descriptor-relatively and exclusively; renderer outputs are opened once as regular files and copied through those descriptors.
- Repository, `example-images`, input/output, staging, and created-entry device/inode identities are revalidated before one atomic descriptor-relative staging-to-gallery rename. No destination pathname write occurs after validation.
- A preexisting gallery is never enumerated, recursively deleted, or cleaned. It is moved intact to the single ignored `.gallery-quarantine/previous/` slot, preventing traversal of symlinks, mount points, or bind-mount-like nested directories.
- Existing quarantine or staging state blocks another run. The generator does not claim cleanup; explicit operator handling is required before retry, and all gallery/quarantine/staging artifacts must remain ignored and untracked.
- The Phase 36 PNG helper opens each PNG once with `O_NOFOLLOW`, bounds both `fstat` size and retained reads to 16 MiB plus one detection byte, and rejects same-file growth or excess without a pathname stat/read split.
- Gallery source acquisition has the same 16 MiB compressed-file ceiling before destination creation. Copying stays descriptor-relative and bounded, and publication rejects identity, size, nanosecond modification-time, or change-time drift so a same-inode in-place source mutation cannot publish a torn file.

### Phase 37 Final Nose Security Boundary

- Phase 37 retains the exact public inventory at 33 stored fields = 32 numeric plus `filterId`; the six nose fields remain scalars, while root/tip supports, `FaceGeometry`, landmarks, bounds, provider types, and control points remain package-internal.
- ASVS L1 active-source and public/SPI scans passed with no forbidden Demo/renderer internal import, dependency drift, network/cloud path, commercial execution path, raw diagnostic geometry, compatibility drift, or tracked/staged generated artifact. `37-SECURITY.md` records `threats_open: 0`.
- The unchanged renderer/helper result is 252/252 local outputs; output, gallery, staging, and quarantine artifacts remain ignored, untracked, unstaged, disposable evidence. No raw pixels or geometry enter committed evidence.
- The exact two-row and SDK-core branch promotion is authorized only by the co-located Phase 37 safety/boundary evidence. Physical-device parity, subjective/commercial naturalness, packaging, shipping, launch readiness, and the independent milestone audit remain outside this security result.

### Phase 38 Remaining Mouth Geometry Security Boundary

- The five new public values are scalars only. Vision `innerLips` crosses detection as coarse availability, while default-empty upper/lower/inner support arrays, `FaceGeometry`, bounds, SIMD values, provider types, and control points remain package-internal.
- Provider input validation rejects non-finite or out-of-bounds support, insufficient cardinality, duplicate points, degenerate spans, invalid strength, and non-renderable displacement before final clamp/output construction. Failure removes only the dependent field.
- Facade results expose only stable category warnings and numeric aggregate metrics. Focused facade and source scans reject raw support names, coordinates, landmarks, bounds, framework objects, paths, or provider internals.
- Phase 38 ASVS L1 evidence found no public/SPI geometry leak, new dependency, network/cloud path, commercial path, Demo/renderer drift, generated artifact, or premature product promotion. Output evidence, final caps, exhaustive safety, and promotion remain Phase 39/40 gates.

### Phase 41 Observed Eye-Support Security Boundary

- The current public surface adds only ten scalars: positive-only `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, `innerCornerOpen`, `outerCornerOpen`, and `eyeSymmetry`, plus signed `eyeTilt`. Default/missing/non-finite values are zero and the exact current inventory is 48 stored fields: 47 numeric plus `filterId`.
- Left/right contour and optional pupil payloads are package-only, `Sendable`, request-scoped, non-Codable evidence. They cross `CoordinateMapper` once, remain finite and closed-unit bounded, are not retained beyond the observation/request path, and never enter public/SPI APIs, persistence, logs, metrics, warnings, errors, descriptions, snapshots, or Demo imports.
- An explicit observed payload is accepted only when production mapping derives exactly one finite `.left` and one finite `.right` contour whose mapped centers have positive separation above `0.000001` on the face-local horizontal axis transformed by the same `CoordinateMapper`. Missing, duplicate, coincident, side-inverted, or non-finite order fails closed before semantic support or a provider can consume it; orientation and input mirroring do not relabel valid anatomical sides.
- Derived contour span and signed inner-to-outer tilt remain package-private, non-Codable, ephemeral values subject to the same raw-geometry redaction and persistence prohibitions as contour and pupil points.
- Contours fail closed outside 6...16 points, 4 unique points, relative width `0.04...0.50`, height `0.01...0.30`, or area above `0.0004`. Pupils independently require 10% expanded containment, normalized ellipse offset at most `0.70`, and paired contour width/height ratios `0.50...2.00`. These reject biometric-adjacent malformed evidence and are not visual caps.
- Pupil failure removes only `pupilSize`/`gazeCorrection` eligibility. Explicit missing/invalid contour sides remain empty with no proxy fallback and reach the resolver's complete-eye skip. A nil observed payload preserves only the established shipped zero-default compatibility path.
- `check_eye_support_boundaries.py` fails closed on `rg` errors/unclassified matches, public/SPI support, Codable/persistence, raw diagnostic geometry, network/cloud or commercial paths, drift from manifest/Demo baseline `f1c28fa`, and tracked/staged/non-ignored-untracked output/gallery/staging/quarantine artifacts. Phase 41 adds no provider/output/final-cap/promotion, Demo, device, commercial, packaging, shipping, or launch-readiness claim.

### Phase 45 Observed Face-Support Security Boundary

- The public expansion is scalar-only: `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper`. Raw and derived contour/centerline support, bounds, semantic indices, and eligibility values remain package-only, non-Codable, request-scoped, and absent from public/SPI APIs.
- Vision contour and median inputs are untrusted biometric-adjacent data. Each optional region is rejected before provider access when empty, above its 32/16-point ceiling, non-finite, outside closed unit bounds, duplicate, undersized, direction-degenerate, self-intersecting, side-inconsistent, or cross-support-inconsistent. A malformed region cannot authorize another region or erase safe shipped siblings.
- The shipped seven-point synthetic face-box `faceContour` is compatibility geometry only. Presenting it as observed Vision evidence, substituting it for `observedFaceSupport`, or using it to claim support for the four new fields is prohibited.
- Face landmarks are not an identity, recognition, authentication, or biometric-profiling capability. Raw coordinates must not be logged, serialized, persisted, cached, described, exposed to Demo code, or included in warnings, errors, metrics, snapshots, files, or network payloads. Only fixed redacted reasons and aggregate counts may appear in descriptions, structural reflection, or dumps; interruption or request completion leaves no support state to clean up.
- Phase 45 adds no dependency, target, public support/result type, semantic model, model asset, resource manifest, runtime download, network/cloud path, provider, resolver route, facade route, render path, or Demo source. `去双下巴`, `去双下巴 Pro`, and `发际线` remain future; no synthetic proxy, person matte, or unapproved model may be used as evidence for them.
- `check_face_support_boundaries.py` fails closed on missing paths, repository escape, tool errors, unclassified matches, public/Codable/persistence/diagnostic exposure, manifest or Demo drift from `9aedd6b40a7c033ac86cea2c75e06bac138cf9ef`, preset-byte drift, semantic model/resource/network additions, facade-only import violations, and generated-artifact escape. Phase 45 closeout passes all 36 adversarial self-tests and all 13 live checks.

### Phase 49 Observed Eyebrow-Support Security Boundary

- Apple Vision eyebrow regions are untrusted biometric-adjacent input, not identity, recognition, authentication, or profiling data. `leftEyebrow` and `rightEyebrow` are classified independently before copy/map; accepted support must satisfy the bounded open-path count, finite closed-unit coordinates, exact uniqueness, chord, span, non-adjacent-intersection, anatomical-side, and endpoint-order checks owned by `DESIGN.md`.
- Eye contours, historical eye geometry, generated traces, synthetic points, and the seven-point face proxy cannot spoof eyebrow provenance. A malformed or missing side cannot authorize its sibling, cannot erase an independently valid sibling, and cannot be repaired through sorting, closure, retry, cache, or substitution.
- Raw and derived eyebrow carriers are immutable, package/internal, request-scoped, non-Codable, non-persistent, non-networked, and absent from public/SPI API. Coordinates, arrays, endpoints, centers, apex indices, bounds, framework objects, hashes, or stable geometry signatures must not appear in descriptions, reflection, dumps, logs, warnings, errors, metrics, snapshots, files, or network payloads; only fixed availability labels, booleans, and aggregate point counts are permitted transitively through parent diagnostics.
- Phase 49 adds no dependency, target, model, resource, manifest, runtime download, network/cloud path, cache, Demo/UI import, provider, resolver/conflict/facade route, renderer/gallery path, generated tracked artifact, or product promotion. `check_eyebrow_support_boundaries.py` fails closed on tool errors, missing/escaping paths, unclassified matches, proxy substitution, public/Codable/persistence/diagnostic exposure, scope drift, preset/hash drift, artifact escape, and an unreadable/empty/non-regular `example-images/input/portraits/e1.png` prerequisite.

## 3. Trust Boundaries

```text
Host App UI
→ public BeautySDK API
→ parameter and input validation
→ detection / resources / render
→ output image buffer
```

Boundary rules:

| Boundary | Trust Level | Required Check |
| --- | --- | --- |
| Host App → SDK | Untrusted caller | Validate parameters, pixel formats, dimensions, orientation. |
| User JSON → Preset loader | Untrusted data | Validate schema version, field names, ranges, resource IDs. |
| External resource URL → Resource manager | Untrusted file | Validate location, size, type, manifest, checksum, version. |
| Camera / PhotoKit → Demo pipeline | User-protected resource | Confirm authorization and Info.plist usage descriptions. |
| SDK internals → logs / metrics | Sensitive internal state | Redact and aggregate before emitting. |
| Debug tools → UI | Developer-only diagnostics | Gate behind debug setting and avoid sensitive payloads. |

## 4. Platform Privacy Requirements

iOS protected resources require user-visible purpose strings and runtime authorization. Current official references:

- [NSCameraUsageDescription](https://developer.apple.com/documentation/bundleresources/information-property-list/nscamerausagedescription)
- [NSPhotoLibraryUsageDescription](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSPhotoLibraryUsageDescription)
- [AVCaptureDevice.requestAccess](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1624584-requestaccess)
- [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)
- [Adding a privacy manifest to your app or third-party SDK](https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk)
- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)

Rules:

- `BeautyDemo` must include a clear `NSCameraUsageDescription` before accessing camera APIs.
- If `BeautyDemo` reads from the photo library, it must include `NSPhotoLibraryUsageDescription`.
- If `BeautyDemo` only saves to the photo library, prefer add-only photo usage where the product flow allows it.
- Camera permission must be requested before capture session use and reflected in UI state.
- A distributed `BeautySDK` target must include `PrivacyInfo.xcprivacy` when it collects data or uses Apple required-reason APIs that must be declared.
- The SDK privacy manifest must describe SDK behavior only; the host App remains responsible for its own App Store privacy answers.
- If data is processed only on device and not collected, do not describe it as uploaded or retained in product docs.

Phase 3 protected-resource evidence recorded 2026-06-12:

- `BeautyDemo` generated Info.plist settings contain the exact Camera purpose string `Use the camera to preview beauty processing on this device.` in Debug and Release.
- `BeautyDemo` generated Info.plist settings contain the exact Photo purpose string `Select photos to preview beauty processing on this device.` in Debug and Release.
- `InputPipelinePrivacyTests` verifies the purpose strings and scans Camera, Editor, and Support input paths for network/upload calls, raw `/private/var` paths, and raw framework error copy.
- Static scan `rg -n "URLSession|http://|https://|upload|/private/var|NSError|AVError" BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor BeautyDemo/BeautyDemo/Support` returned no matches.

Phase 25 privacy-manifest evidence recorded 2026-07-03:

- `find BeautySDK BeautyDemo -name PrivacyInfo.xcprivacy -print` found no existing privacy manifest.
- Phase 25 explicitly defers adding `PrivacyInfo.xcprivacy` because current SDK facade and Demo app evidence shows no default data collection, upload, raw frame or landmark persistence, analytics, remote config, payment, entitlement, or hidden third-party SDK behavior.
- Required-reason seed scans found no active SDK facade or Demo app use of `UserDefaults`, file timestamp, disk-space, system boot-time, active keyboard, or POSIX stat APIs. The only `FileManager.default` seed hit is in the `BeautyExampleRenderer` local example executable and is classified separately as local input/output fixture enumeration.
- Re-evaluate the manifest before SDK behavior collects data, uses required-reason APIs, adds third-party SDKs, adds network/cloud/analytics behavior, packages the example executable into an app distribution, or enters App Store/commercial packaging review.

## 5. Permission Model

Demo App permission states:

```text
notDetermined
requesting
authorized
denied
restricted
unavailable
```

Rules:

- Permission prompts are initiated by `BeautyDemo`, not SDK internals.
- SDK APIs must not trigger protected-resource prompts on their own.
- Denied camera permission must not crash the Demo; show an editor-only or explanation path.
- UI updates after permission callbacks must return to the main actor.
- Permission copy must explain the feature being enabled, not use vague text.

## 6. Input Validation

All public API input validation happens before expensive work.

### 6.1 Pixel Buffer Validation

Required checks:

| Check | Rule |
| --- | --- |
| Format | Accept only documented pixel formats. Reject or convert unsupported formats. |
| Dimensions | Reject zero, negative, or above configured maximum size. |
| Plane layout | Validate expected planes before texture creation. |
| Orientation | Require explicit orientation; do not infer from UI state. |
| Lifetime | Do not retain realtime buffers beyond the processing window. |
| Mutability | Do not mutate caller-owned input buffers unless API explicitly documents in-place processing. |

### 6.2 Image Validation

Required checks:

- Validate image extent is finite and within configured maximum pixels.
- Normalize EXIF orientation before detection/render coordinate agreement.
- Reject images whose color space or pixel format cannot be rendered safely.
- Avoid loading full-resolution images on the main thread.

### 6.3 Parameter Validation

Required checks:

- Clamp enhancement parameters to `0.0...1.0`.
- Clamp bidirectional parameters to `-1.0...1.0`.
- Apply algorithm-level safety caps before generating geometry or color uniforms.
- Treat unknown resource IDs as missing resources, not as file paths.
- Reset NaN, infinity, and non-finite numeric values to documented no-op defaults before rendering.
- Preserve default zero-effect behavior.

Algorithm-level caps are visual-safety controls and must be kept separate from public API ranges.

Phase 6 current behavior:

- Public slider range remains unchanged, but effective skin/color/geometry/lip/filter strengths are capped or weakened inside `BeautyEffects`.
- Combined face, eye, nose, and mouth geometry weakening is reported only as redacted warnings and numeric metrics.
- No-face routing skips face-dependent skin, geometry, eye, nose, mouth, and lip-color domains while allowing face-agnostic color/filter domains to continue.
- Missing eye, nose, and mouth landmark groups skip only their dependent domains; raw landmark points, bounding boxes, and provider internals remain private.
- Mouth warnings and metrics expose only stable reason codes and aggregate counts. No-face or missing outer lips zero skipped mouth/lip strengths; stale geometry zeros only mouth geometry while safe color/filter work and eligible `lipColor` continuation remain local and redacted.

## 7. JSON and Preset Validation

Preset JSON is untrusted unless bundled and versioned by the SDK.

Required fields:

```text
schemaVersion
id
version
parameters
```

Validation rules:

- Bundled preset `schemaVersion` must be compatible with the SDK; unsupported versions fail with a redacted typed error.
- `id` must match a conservative ID pattern such as `^[A-Za-z0-9._-]+$`.
- `version` must be parseable and compatible with the SDK.
- Unknown fields may be ignored only if forward-compatible.
- Missing parameters resolve to documented defaults.
- Invalid numeric values are clamped or rejected before rendering.
- Resource IDs referenced by presets must exist in the resolved resource registry.
- JSON size must have a documented maximum.
- Preset parsing errors return typed errors; they do not crash.
- Preset decoding failures must map to `BeautyError.presetDecodeFailed` with a redacted reason.

Forbidden:

- Executing scripts or expressions from JSON.
- Resolving JSON resource IDs as arbitrary filesystem paths.
- Loading remote preset URLs without an explicit network and integrity design.

Phase 7 Demo parameter JSON evidence recorded 2026-06-23:

- Demo parameter JSON is copy/paste-only and limited to 65,536 UTF-8 bytes before decoding.
- The accepted envelope is `schemaVersion: 1` plus `parameters`; unsupported schemas, malformed JSON, oversized payloads, and unknown `filterId` values map to stable friendly errors.
- Import preview validates through the public `BeautySDKResources.validate(parameters:)` facade before Apply; failed imports do not mutate current parameters, selected filter, selected preset, sliders, compare state, or debug state.
- Export emits only deterministic `schemaVersion` and `parameters`; it does not include timestamps, source labels, detection summaries, debug metrics, local paths, or build metadata.
- Raw pasted JSON is confined to the explicit sheet text editor and is not echoed in status, error, debug, or log copy.
- The broad raw-token scan over all Demo source/tests reports expected XCTest guard literals and existing non-debug image geometry helpers; the scoped active JSON/debug surface scan returned no matches.

## 8. Resource Security

Resource types:

```text
LUT
Preset JSON
Makeup Package
Sticker Texture
Background Texture
Model File
Metal shader resource
```

Bundled resources:

- Use `Bundle.module` for Swift Package resources.
- Do not hardcode absolute file paths.
- Manifest and preset references must pass conservative identifier validation before bundle lookup.
- Phase 5 bundled filter resources are metadata-only IDs; `.cube`, thumbnails, swatches, and arbitrary relative paths are out of scope until an explicit render/resource security design exists.
- Record resource `id`, `name`, `version`, `minimumSDKVersion`, and `items`.
- Fail with a typed error when required bundled resources are missing.

External resources:

| Resource | Required Validation |
| --- | --- |
| LUT | File extension, dimensions, color data length, maximum file size, checksum if packaged. |
| Makeup package | Manifest schema, item paths, image dimensions, blend modes, SDK compatibility. |
| Model file | Version, expected model type, size limit, checksum/signature before load. |
| Background / sticker texture | File type, dimensions, color space, decompression safety, size limit. |

Rules:

- External resources are disabled until a `BeautyResourceManager` design is implemented.
- When enabled, external resources must be registered through a single resource manager.
- Resource packages must not contain executable code.
- Relative paths inside packages must not escape the package root.
- Caches must have size limits and eviction rules.
- Missing optional resources degrade gracefully; missing required resources return typed errors.

Phase 25 resource-trust evidence recorded 2026-07-03:

- Current `BeautyResources` evidence covers bundled SwiftPM resources only: manifest schema version, metadata filters, five bundled presets, logical resource identifiers, traversal-like ID rejection, unknown preset/filter behavior, and typed redacted missing-resource errors.
- `swift test --package-path BeautySDK --filter BeautyResourcesTests.BeautyResourceCatalogTests` passed with 6 tests and `swift test --package-path BeautySDK --filter BeautySDKTests.BeautySDKFacadeTests` passed with 5 tests.
- Resource scans confirmed `Bundle.module`, conservative identifier validation, `resourceNotFound`, `presetDecodeFailed`, and no active resource target network, download, remote config, cloud, payment, entitlement, or listed third-party SDK behavior.
- This does not complete external LUT, makeup, model, sticker, dynamic download, cache, checksum/signature, or package-integrity capability. Those remain disabled until a future resource-manager design defines type, size, path confinement, integrity, cache, privacy, and failure policy.

## 9. Logging and Metrics

Log levels:

```text
none
error
warning
info
debug
```

Security rules:

- Release default log level is `error`.
- Debug logs can be `warning` or `info`, but must still be redacted.
- Logs must not include image bytes, file paths, face landmarks, bounding boxes, user identifiers, tokens, or raw JSON payloads.
- Per-frame logs are disabled by default.
- Performance logs are sampled or aggregated.
- Debug result APIs must be gated by configuration and must not persist sensitive buffers.
- File logging is disabled by default. If enabled by the host App, logs stay in the App sandbox, rotate by date or size, default to 7-day retention and 5 MB per file, and must be redacted before export or sharing.

Allowed examples:

```text
resource_not_found id=clean_01
render_failed code=texture_creation_failed
frame_dropped reason=backpressure
```

Forbidden examples:

```text
/private/var/mobile/Containers/Data/.../IMG_1234.JPG
landmarks=[(0.421,0.215), ...]
rawPresetJson={...}
```

Phase 6 warning and metric payloads may include stable domain names, counts, capped-domain totals, geometry point counts, and effective-strength values. They must not include raw face coordinates, bounding boxes, local paths, raw framework errors, or image bytes.

## 10. Network Policy

Current SDK policy:

- SDK has no network dependency.
- Demo App should not upload frames, photos, landmarks, presets, metrics, or crash diagnostics by default.
- Dynamic downloads are out of scope until explicitly designed.

Before adding network behavior:

1. Update this file with endpoint, payload, retention, authentication, and failure behavior.
2. Update `PRODUCT_SENSE.md` with user-facing disclosure and acceptance criteria.
3. Update `RELIABILITY.md` with retry, timeout, and offline behavior.
4. Add privacy manifest and App Store privacy details review items where applicable.

## 11. SDK Distribution Security

If the SDK becomes commercially distributed:

- Ship source SPM or signed XCFramework with documented checksum.
- Include `PrivacyInfo.xcprivacy` when required by SDK behavior.
- Document required host App Info.plist keys.
- Document whether the SDK collects data. Default answer should remain no collection.
- Keep license validation separate from image processing correctness.
- License failure must not corrupt output or expose user data.
- Feature gating must not silently enable hidden network calls.

Commercial hooks that require security design before implementation:

- License server validation.
- Remote config.
- Dynamic resource package download.
- Watermark strategy.
- Per-module entitlement.
- Trial period enforcement.

## 12. Dependency Policy

Default dependency policy:

- Prefer Apple frameworks and local Swift/Metal code.
- Avoid third-party image-processing SDKs in the core pipeline.
- Do not introduce dependencies that collect analytics, advertising identifiers, or cross-app tracking.
- New dependencies must document license, privacy behavior, network behavior, binary distribution, and update path.
- Dependencies that include required-reason APIs or data collection must be reflected in privacy manifests and App privacy review.

## 13. Secure Failure Behavior

| Failure | Secure Behavior |
| --- | --- |
| Camera permission denied | No capture; show UI fallback. |
| Invalid parameter | Clamp or reject before render. |
| Invalid preset JSON | Return typed parse error; keep current parameters. |
| Missing optional LUT | Disable filter and continue. |
| Missing required shader | Return render error; do not crash in release. |
| Unsupported pixel format | Reject or route through documented conversion. |
| Resource checksum mismatch | Reject resource and clear related cache entry. |
| Debug data requested in release | Return unavailable or empty debug payload. |

## 14. Security Test Checklist

Security-sensitive changes must add or update checks for:

- Parameter NaN, infinity, below-range, and above-range values.
- Preset JSON missing fields, unknown fields, wrong types, oversized payloads.
- Unknown `filterId`, `makeupId`, and resource IDs.
- LUT parsing with invalid dimensions and invalid data length.
- Package paths that attempt `../` traversal.
- Camera permission denied and restricted states.
- Photo library unavailable or denied states.
- Logging output with debug mode on and off.
- Realtime frame processing without persistence.
- Privacy manifest presence when SDK behavior requires it.

Phase 6 effect/privacy evidence recorded 2026-06-22:

- `CombinedEffectSafetyTests` and `MissingLandmarkDegradationTests` cover combined caps, no-face routing, partial landmark skips, stale/reused degradation, and redacted warning/metric behavior.
- Demo import-boundary tests keep `BeautyDemo` on the public `BeautySDK` facade.
- Static scans cover stale pending UI copy, `VNFaceObservation`, bounding boxes, raw framework errors, local paths, raw preset JSON, and image-byte dump tokens on active SDK/Demo surfaces.

Phase 7 debug/privacy evidence recorded 2026-06-23:

- The preview debug overlay shows only frame status, detection availability/reason/count/timing summaries, warning counts, redacted error codes, and friendly status copy.
- No face boxes, landmarks, control points, geometry overlay, raw Vision objects, raw `NSError`, local paths, stack traces, image bytes, network calls, document pickers, file importers, or file exporters were added to active JSON/debug surfaces.
- `rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.

Phase 25 active-source security evidence recorded 2026-07-03:

- Active SDK/Demo/package/project scans found no default `URLSession`, HTTP(S), upload, cloud, analytics, telemetry, tracking, remote config, StoreKit, payment, entitlement, or hidden third-party SDK behavior after the narrow Demo product-copy fix.
- Scoped raw path/error/geometry/diagnostic scans over active SDK core/facade and Demo camera/editor surfaces found no raw framework errors, absolute local paths, face geometry payloads, raw JSON, or image-byte exposure.
- Focused `InputPipelinePrivacyTests` and `BeautyDemoImportBoundaryTests` passed on `platform=iOS Simulator,name=iPhone 17,OS=26.5`, including the new SEC-04 active-source product-scope regression guard.

Phase 26 geometry facade security evidence recorded 2026-07-06:

- Focused `BeautyEngineGeometryFacadeTests`, `BeautyDetectionTests.VisionFaceDetectorTests`, `BeautyEffectResolverTests`, and `MissingLandmarkDegradationTests` passed, and full `swift test --package-path BeautySDK` passed with 159 tests.
- Public/SPI raw geometry export scan, active-source raw-leak scan, Demo internal-import scan, renderer geometry-case exclusion scan, and `SHAPE_FEATURE_LEDGER.md` implemented-status guard are recorded in `26-VERIFICATION.md`.
- Public evidence remains limited to `BeautyDetectionSummary`, warnings, and numeric aggregate metrics; no raw landmarks, bounds, control points, framework errors, local paths, raw JSON, or image bytes are allowed across the public facade.

If automated tests are not yet available, record manual checks in `PLANS.md`.

## 15. Review Gates

Before merging any change touching these areas, update `SECURITY.md` if needed:

| Area | Required Review |
| --- | --- |
| Public API input | Validation behavior and failure mode. |
| Parameters | Range, clamp, safety cap, serialization compatibility. |
| Resource loading | Trust boundary, schema, path, size, checksum. |
| Logging / metrics | Redaction and default log level. |
| Debug APIs | Access gating and sensitive data handling. |
| Network | Payload, retention, consent, privacy manifest impact. |
| SDK distribution | Privacy manifest, signature/checksum, host integration docs. |
| New dependency | License, privacy, network, required-reason API impact. |

## 16. Security Decision Log

### v1.10 Phase 40 Mouth Geometry Closeout

- `40-SECURITY.md` records ASVS L1 review with `threats_open: 0` for `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, and `lipPlump`.
- Active-source checks fail closed for raw geometry/support exposure, internal Demo/renderer imports, compatibility drift, unclassified matches, network/cloud behavior, commercial paths, dependencies, and generated artifacts.
- Diagnostics remain aggregate-only and redact paths, identifiers, coordinates, and support points. The existing privacy-manifest disposition is unchanged because Phase 40 adds no collected-data category, system API, remote transfer, account behavior, or tracking behavior.

### v1.11 Phase 41 Eye Support Boundary

- ASVS L1 boundary checks pass only when all active SDK source matches are explicitly classified, `rg` status is 0/1-aware and fail-closed otherwise, the `f1c28fa` manifest/Demo baseline is unchanged, and all four generated-artifact roots remain ignored and untracked/unstaged.
- Production-derived side order fails closed on missing, duplicate, coincident, side-inverted, or non-finite observed pairs before package-private span/tilt derivation or provider consumption. The orientation/mirror-aware axis uses the same coordinate metadata as the observed contours rather than a separate orientation switch.
- The privacy-manifest disposition remains unchanged: the package-only observed eye evidence is local, ephemeral, non-persistent, non-networked, and absent from diagnostic/public surfaces.

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-05-25 | SDK default is on-device processing with no data upload. | Image frames and facial landmarks are sensitive; local processing reduces privacy risk. |
| 2026-05-25 | External resources are disabled until a resource manager with validation exists. | LUT, makeup, model, and texture packages cross a trust boundary. |
| 2026-05-25 | Logs must never include image paths, image bytes, landmarks, or raw JSON. | Debuggability must not leak user content or biometric-adjacent data. |
| 2026-05-25 | Distributed SDK builds must revisit `PrivacyInfo.xcprivacy`. | Apple requires privacy manifests for apps and third-party SDKs according to SDK behavior. |
| 2026-07-03 | Phase 25 defers `PrivacyInfo.xcprivacy` for current source behavior and keeps external resources disabled. | Current command evidence supports local-first SDK/Demo behavior and bundled-resource trust only; future collection, required-reason APIs, third-party SDKs, network behavior, or external packages must reopen the review. |
| 2026-07-06 | Phase 26 keeps geometry detection and landmark routing package-internal and redacted at the public facade. | Still-image geometry intent can be proven without exposing raw biometric-adjacent payloads, sensitive diagnostics, Demo internals, or saved-output implementation claims. |

### v1.11 Phase 44 Eye Geometry Security Closeout

- Observed contours/pupils remain request-scoped, package-only, non-Codable, non-persistent, and absent from public or diagnostic raw geometry payloads.
- The active-source gate classifies the exact 48-field public inventory and eight source owners; command errors, unclassified matches, dependency/import drift, persistence, network/cloud, commercial paths, and artifact escapes fail closed.
- Generated output/gallery/staging/quarantine remains ignored, untracked, and unstaged. ASVS L1 HIGH findings block promotion; `threats_open: 0` after the 57/57 self-test and 13/13 live boundary pass.

### Phase 46 Contour Geometry Security Boundary

- The four new providers authorize work only from Phase 45 validated observed support. The synthetic seven-point compatibility contour may continue to drive the five shipped fields but cannot authorize smoothing, temple, cheekbone, or taper output.
- Every observed or derived coordinate, axis, progress value, displacement, target, radius, strength, and falloff must be finite before bounded construction. Invalid, incomplete, non-improving, or non-renderable work fails the owning field closed; it is never repaired from NaN/∞ by a clamp or borrowed from a sibling.
- Observed contour and median evidence remains immutable, package-only, non-Codable, request-scoped, non-persistent, and non-networked. The deterministic `.usableFace` payload is testing SPI input that traverses the production mapper and validator; it creates no public support/result inventory.
- Public diagnostics remain limited to generic warnings and aggregate numeric counts/scales. Raw or derived contour, median, apex, index, source/target, displacement, coordinate, bounds, provider, framework object, file path, and image-byte details are prohibited.
- The privacy-manifest disposition is unchanged because Phase 46 adds no collected-data category, required-reason API, remote transfer, account behavior, tracking behavior, dependency, model, resource, target, public API, Demo import, renderer case, or generated evidence.
- `check_face_geometry_boundaries.py` passes 24/24 adversarial self-tests and 14/14 live checks, including the pinned manifest and Phase 45 checker hashes, exact 7+2 ownership, exact 37-pass convergence, artifact containment, redaction, and future-row non-promotion.
- Concrete source manifestations pass, and the independent ASVS L1 audit in `46-SECURITY.md` resolves the three repository-scoped governance statements about biometric profiling, synthetic-proxy representation, and silent deferred-feature activation with `threats_open: 0`. Phase 47 owns decoded output; Phase 48 owns final safety and promotion.

### Phase 48 Face Safety Security Closeout

- Phase 48 keeps observed contour/median/apex support package-only, request-scoped, immutable, non-Codable, non-persistent, non-networked, and absent from public/SPI API.
- Public results contain only generic warnings and aggregate metrics. Any raw geometry, derived coordinate, provider object, framework object, image byte, or file path in diagnostics is prohibited.
- The self-tested active-source boundary classifies all eight owners and fails closed on command errors, unclassified matches, persistence/cache/static state, internal Demo/renderer imports, dependency/model/resource/network/commercial drift, deferred semantic activation, and generated-artifact escape.
- ASVS L1 closes 16/16 registered threats and 3/3 repository governance inputs at the HIGH blocking threshold; `threats_open: 0`.
