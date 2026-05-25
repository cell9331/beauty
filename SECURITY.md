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
- Reject NaN, infinity, and non-finite numeric values.
- Preserve default zero-effect behavior.

Algorithm-level caps are visual-safety controls and must be kept separate from public API ranges.

## 7. JSON and Preset Validation

Preset JSON is untrusted unless bundled and versioned by the SDK.

Required fields:

```text
id
version
parameters
```

Validation rules:

- `id` must match a conservative ID pattern such as `^[A-Za-z0-9._-]+$`.
- `version` must be parseable and compatible with the SDK.
- Unknown fields may be ignored only if forward-compatible.
- Missing parameters resolve to documented defaults.
- Invalid numeric values are clamped or rejected before rendering.
- Resource IDs referenced by presets must exist in the resolved resource registry.
- JSON size must have a documented maximum.
- Preset parsing errors return typed errors; they do not crash.

Forbidden:

- Executing scripts or expressions from JSON.
- Resolving JSON resource IDs as arbitrary filesystem paths.
- Loading remote preset URLs without an explicit network and integrity design.

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

| Date | Decision | Reason |
| --- | --- | --- |
| 2026-05-25 | SDK default is on-device processing with no data upload. | Image frames and facial landmarks are sensitive; local processing reduces privacy risk. |
| 2026-05-25 | External resources are disabled until a resource manager with validation exists. | LUT, makeup, model, and texture packages cross a trust boundary. |
| 2026-05-25 | Logs must never include image paths, image bytes, landmarks, or raw JSON. | Debuggability must not leak user content or biometric-adjacent data. |
| 2026-05-25 | Distributed SDK builds must revisit `PrivacyInfo.xcprivacy`. | Apple requires privacy manifests for apps and third-party SDKs according to SDK behavior. |

