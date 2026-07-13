# Stack Research

**Domain:** Existing-parameter mouth/lip public-facade evidence and safety for a local SwiftPM iOS beauty SDK
**Milestone:** v1.8 Broader `美型 / 五官` SDK Slice - Mouth
**Researched:** 2026-07-13
**Confidence:** HIGH — recommendations are derived from the validated repository architecture, current mouth implementation, and the completed eye/nose evidence pattern.

## Recommendation

No production dependency, platform, package target, public field, or UI stack change is needed. v1.8 should extend the repository's existing evidence stack: Swift/XCTest for contracts and safety, `BeautyExampleRenderer` for facade-only outputs, a mouth-specific Python standard-library verifier for deterministic batch evidence, and the existing ignored gallery generator for review routing.

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
| --- | --- | --- | --- |
| Swift / SwiftPM | Swift tools 6.0; existing package platforms iOS 17 and macOS 14 | Preserve the four existing public parameters and implement/test renderer evidence | `BeautySDK/Package.swift` already provides the validated module graph, public `BeautySDK` library, renderer executable, and test targets. No package change is justified. |
| XCTest | Xcode/Swift toolchain supplied | Lock caps, signed directions, degradation, conflict weakening, redaction, and facade inventory | Existing mouth provider/resolver suites already exercise these seams; focused additions are lower-risk than introducing another test framework. |
| Core Image + existing geometry/render pipeline | Apple framework versions supplied by the deployment targets | Produce mouth geometry and lip-color outputs through `BeautySDK` | `mouthSize`, `mouthWidth`, and `smile` already route through `MouthWarpProvider`; `lipColor` already routes through the separate color domain. The milestone needs evidence and containment, not a replacement renderer. |

### Supporting Tools

| Tool | Version | Purpose | When to Use |
| --- | --- | --- | --- |
| `BeautyExampleRenderer` | Existing SwiftPM executable | Add facade-only single-parameter cases for signed `mouthSize`, signed `mouthWidth`, `smile`, and `lipColor` | Use for the seven-fixture ignored-output matrix and comparisons against `geometryBaseline_noop`. Keep imports limited to `BeautySDK`. |
| Python 3 standard library | System toolchain | Mouth-specific output verification | Follow the completed eye/nose helper pattern: verify expected files, non-empty PNGs, dimensions, portrait-region differences, signed-pair differences, no-face preservation, and immutable counts. No imaging package is required if the established helper pattern remains sufficient. |
| `example-images/generate_gallery.py` | Existing repository script | Route ignored mouth/lip evidence into a review gallery | Add a mouth group/mapping only; keep generated PNG/gallery artifacts untracked. |
| `rg`, Git, shell checks | Existing developer tools | Public-inventory, forbidden-import, sensitive-token, dependency, and artifact-containment scans | Use during closeout to prove no new fields, Demo coupling, dependency, network path, raw geometry disclosure, or tracked generated output. |

## Evidence Pattern

| Concern | Existing seam to extend | Required v1.8 proof |
| --- | --- | --- |
| Public facade | `BeautyExampleRenderer` + `BeautyRendererOutputRegressionTests` | Each new case sets exactly one existing `BeautyParameters` field and imports only `BeautySDK`. |
| Signed shaping | `MouthWarpProvider`, `BeautyEffectResolver`, conflict resolver | Positive/negative `mouthSize` and `mouthWidth` retain opposite directions after caps and combined weakening; outputs differ from baseline and from their signed counterpart. |
| Exact caps | `BeautySafetyCaps` + resolver tests | Preserve `mouthSize = 0.35`, `mouthWidth = 0.35`, `smile = 0.50`, `lipColor = 0.50`. |
| Geometry degradation | Resolver/provider tests | Missing and stale mouth geometry fail closed; reused non-eye geometry stays scaled by the established `0.5`; unrelated color/filter domains continue safely. |
| Lip-color containment | `BeautyColorEffectPipeline` + output/safety tests | `lipColor` activates only with usable outer-lip geometry, remains a color-domain effect, and does not move geometry or substantiate `丰唇`. |
| Privacy | warning/metric assertions and scans | Diagnostics expose stable codes/counts only, with no landmark coordinates, control points, observation dumps, image bytes, or raw paths. |

## Installation

No installation or manifest modification is recommended.

```bash
swift test --package-path BeautySDK
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output
python3 <mouth-output-helper>.py
```

The exact helper path and immutable matrix counts should be owned by the roadmap/phase plan after the final renderer-case inventory is chosen.

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
| --- | --- | --- |
| Extend the current renderer and focused tests | Add a new mouth-specific executable or package target | Only if the existing renderer cannot express a facade-only case, which current source evidence does not indicate. |
| Python standard-library evidence helper | Pillow, OpenCV, or a snapshot-test dependency | Only if a later requirement needs perceptual metrics unavailable in the established helper; dependency cost is unjustified for current invariant/region checks. |
| Current outer-lip geometry and color mask | New ML model, segmentation framework, or third-party beauty SDK | Only in a separately approved milestone with dependency, privacy, performance, and trust-boundary design. |
| Ignored generated evidence | Tracked golden PNG baselines | Only after an explicit cross-platform baseline policy addresses encoder/toolchain drift and repository growth. |

## What NOT to Use

| Avoid | Why | Use Instead |
| --- | --- | --- |
| New public parameters or Demo UI | v1.8 is the SDK-only slice of the existing 31-field inventory. | Exercise `mouthSize`, `mouthWidth`, `smile`, and `lipColor` through the public facade. |
| A geometry interpretation of `lipColor` | The current implementation tints a bounded lip region and contributes no warp control points; calling it `丰唇` would overclaim evidence. | Treat it as separate color-domain containment evidence and promote only `大小`, `宽度`, and `微笑`. |
| Direct renderer imports of internal targets | This would bypass the host-facing contract the milestone must prove. | Import only `BeautySDK`. |
| Cloud processing, analytics, or network fixtures | Conflicts with the local-first scope and adds unnecessary privacy/dependency surface. | Keep fixtures, rendering, verification, and galleries local. |
| Broad image-wide difference assertions | Watermarks and unrelated pixels can produce false confidence. | Exclude the watermark band and use a mouth/central-face region plus signed-pair comparisons. |
| Silent continuation of stale/missing mouth shaping | Unsafe geometry can distort output and obscure degradation behavior. | Fail closed for missing/stale geometry, reduce reused geometry by the established policy, and continue independent safe domains. |

## Version Compatibility

| Component | Compatible With | Notes |
| --- | --- | --- |
| Swift tools 6.0 package | iOS 17+, macOS 14+ | Preserve `Package.swift`; renderer evidence runs on macOS while exercising the public SDK facade. |
| Existing Core Image path | Current byte-buffer and CIImage rendering branches | Verify lip-color containment in both relevant branches if tests expose both; do not introduce divergent semantics. |
| Existing 31-field `BeautyParameters` | v1.8 renderer and safety tests | Inventory must remain unchanged. Signed normalization applies to `mouthSize` and `mouthWidth`; `smile` and `lipColor` remain unit-valued. |
| Existing ignored fixture/gallery workflow | Seven current fixtures | Generated outputs and galleries remain local artifacts and must not be committed. |

## Repository Sources

- `BeautySDK/Package.swift` — validated package platforms, products, targets, and dependency boundaries.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` — exact mouth/lip caps.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` — signed/unit normalization, mouth/lip activation, degradation, metrics, and safe-domain continuation.
- `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift` — signed size/width and positive smile geometry behavior.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` — distinct bounded lip-color domain.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` and `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` — facade-only matrix and exact inventory owner.
- `BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift` and `MissingLandmarkDegradationTests.swift` — current mouth direction/degradation baseline.
- `.planning/milestones/v1.7-phases/31-nose-renderer-output-evidence/31-SHARED-CONTRACT-SCAN.md` — established renderer/helper/gallery evidence pattern.

---
*Stack research for: v1.8 Broader `美型 / 五官` SDK Slice - Mouth*
*Researched: 2026-07-13*
