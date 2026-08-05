# Stack Research

**Domain:** Local-first iOS still-image teeth whitening and sclera redness reduction
**Researched:** 2026-08-05
**Confidence:** HIGH
**Execution note:** Completed inline because this Codex session exposed no GSD subagent dispatch tool; sources and conclusions remain milestone-scoped.

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
| --- | --- | --- | --- |
| Swift / SwiftPM | Repository baseline: Swift tools 6.0; current local toolchain remains authoritative | Public parameters, request-local providers, deterministic transforms, package tests | Already owns all SDK contracts and avoids a dependency or ABI expansion. |
| Apple Vision | Existing `VNDetectFaceLandmarksRequest` production path; preserve the repository-pinned behavior | One selected-face request providing actual inner/outer lip, eye-contour, and pupil support | Apple exposes the exact coarse regions needed as support. They remain support, not semantic tooth/sclera labels. |
| Core Image / Core Graphics color management | Existing canonical explicit-sRGB RGBA8 path | Normalize once and deliver the same pixels to Vision, providers, composition, and output | Core Image color-matches input, working, and destination spaces; v1.14 already established one reused context and explicit sRGB output. |
| Existing pure-Swift local-retouch composer | v1.14 production baseline | Immutable-original Q16 blending, hard containment, collision-to-source, per-unit abstention | This is already verified and should become the sole composition owner for the two new providers. |

### Supporting Components

| Component | Version | Purpose | When to Use |
| --- | --- | --- | --- |
| `BeautyObservedLipSupport` | Repository baseline | Actual request-local outer/inner lip support | Teeth provider only; never treat either polygon as the tooth mask. |
| Existing observed eye/pupil support | Repository baseline | Independent left/right eye support | Sclera provider only; each eye validates and fails independently. |
| Phase 54 local review core | Repository baseline | Rights, polarity, original/mask/after, structured blind review, sanitized export | Before either feature is admitted or promoted. |
| `BeautyExampleRenderer` and strict decoder | Repository baseline | Public-facade saved-output evidence | After each feature has an admitted production route. |
| XCTest plus existing Node/Python boundary checkers | Repository baseline | Contract, mutation, privacy, compatibility, and lifecycle verification | Throughout every phase; no new test framework is needed. |

### Development Tools

| Tool | Purpose | Notes |
| --- | --- | --- |
| `swift test --package-path BeautySDK` | Focused and full package verification | Opt-in Apple Vision integration remains a separate explicit gate. |
| `xcodebuild` with explicit simulator destination | Demo compatibility regression | v1.15 does not activate Demo rows, but must prove they remain honest and compatible. |
| Local ignored evidence reviewer | Original-detail mask/output inspection | Media, masks, paths, reviewer identity, and raw support remain untracked and non-diagnostic. |

## Installation

No package, model, target, binary, or network service should be added for the deterministic v1.15 path.

```bash
swift package resolve --package-path BeautySDK
swift test --package-path BeautySDK
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
| --- | --- | --- |
| Deterministic Vision-support + color-qualified provider | Learned teeth or eye segmentation model | Only after dataset, checkpoint, conversion, redistribution, checksum, size, cold/warm performance, and measured-superiority gates pass in a separately approved scope. |
| Existing classic Vision request path | New beta Vision revision with denser landmark constellation | Consider only in a future compatibility phase after final OS availability and cross-version output calibration; do not change revision behavior during v1.15 feature qualification. |
| CPU/reference deterministic implementation first | New Metal kernel | Add only after correctness and device profiling identify a real bottleneck and preserve the exact byte/safety oracle. |

## What NOT to Use

| Avoid | Why | Use Instead |
| --- | --- | --- |
| Unlicensed EasyPortrait/Core ML artifact | Dataset/checkpoint/conversion/redistribution chain is not approved; prior cold-load and memory evidence is unfavorable | Existing deterministic providers and a separately gated comparator only. |
| Whole inner-lip/outer-lip whitening | Includes lips, tongue, gums, and non-tooth aperture pixels | Seeded color-qualified connected candidates inside a hard mouth-local envelope. |
| Whole-eye or pupil-circle redness transform | Eye landmarks are coarse; blink can make pupil support inaccurate; native dark iris can hide geometric leakage | Per-eye validation, hard iris/highlight exclusions, color scoring, feathering, then hard re-clipping. |
| Global desaturation/brightness/red suppression | Aliases shipped effects and changes skin, lips, iris, and unrelated pixels | Bounded feature-local transforms derived from immutable original pixels. |
| Shared mutable mask/provider cache | Risks cross-request portrait leakage and stale support | Stack/request-local immutable context and ephemeral masks only. |

## Stack Patterns by Variant

**If teeth evidence is incomplete or rejected:**

- Keep `teethWhitening` absent, production admission unchanged for teeth, and do not begin teeth renderer/promotion work.
- Continue evidence acquisition without borrowing sclera evidence or candidate status.

**If teeth completes but sclera evidence is incomplete:**

- Preserve the independently shipped teeth slice.
- Keep `scleraRednessReduction` absent and begin no sclera production route.

**If one sclera eye is unsafe:**

- Abstain only that eye.
- Never reuse, mirror, infer, or copy support from the accepted peer eye.

## Version Compatibility

| Component | Compatible With | Notes |
| --- | --- | --- |
| `BeautyParameters` append-only v1.15 fields | Existing source construction, Codable payloads, five presets, zero defaults | Add each field only in its own independently approved slice and update exact inventory contracts. |
| Existing `VNDetectFaceLandmarksRequest` | iOS 17 / macOS 14 package floor | Preserve one request and repository-selected face/revision semantics; no second detector request. |
| Canonical explicit-sRGB RGBA8 carrier | Vision `.up` metadata and local-retouch composer | Both providers and rendering must consume the same carrier. |

## Sources

- [Apple: VNDetectFaceLandmarksRequest](https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest) — request behavior, input observations, and revisions.
- [Apple: VNFaceLandmarks2D.innerLips](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/innerlips) — inner lips outline the space between lips; eye, pupil, and outer-lip regions are separate optional support.
- [Apple: Analyzing a selfie and visualizing its content](https://developer.apple.com/documentation/vision/analyzing-a-selfie-and-visualizing-its-content) — official landmark-region and coordinate-conversion example.
- [Apple: CIContext](https://developer.apple.com/documentation/coreimage/cicontext) — working/destination color matching, immutable context use, and context reuse guidance.
- [Apple: CIContext outputColorSpace](https://developer.apple.com/documentation/coreimage/cicontextoption/outputcolorspace) — explicit destination-space behavior.
- Repository `spike-findings-beauty` references and v1.14 audit — exact local implementation constraints and measured mechanics.

---
*Stack research for: v1.15 independent teeth and sclera retouch*
*Researched: 2026-08-05*
