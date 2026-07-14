# Stack Research

**Domain:** Existing iOS beauty SDK — remaining mouth geometry controls
**Researched:** 2026-07-14
**Confidence:** HIGH

## Recommendation

v1.10 needs no new framework, package, executable target, or remote service. Extend the existing Swift/SwiftPM, Apple Vision, `BeautyEffects` unified warp, Metal render, XCTest, and Python evidence-helper stack already proven through v1.9.

## Core Technologies

| Technology | Repository baseline | v1.10 purpose | Decision |
| --- | --- | --- | --- |
| Swift / SwiftPM | Swift 6.3.3 observed in Phase 21 | Public parameter compatibility, package-internal lip supports, provider/resolver behavior, tests | Reuse unchanged |
| Apple Vision | Platform SDK through `VisionFaceDetector` | Detect outer- and inner-lip landmark-group availability | Extend the existing adapter; no alternate detector |
| Existing unified warp / Metal | `MouthWarpProvider` → `BeautyGeometryEffectPipeline` → `BeautyRender` | Whole-mouth translation/tilt and local lip-peak/plump control points | Reuse one pass; add no per-tool Metal pass |
| XCTest | `BeautyCoreTests` and `BeautyEffectsTests` | Compatibility, support validation, provider, degradation, conflict, facade, boundary evidence | Extend focused suites |
| Existing renderer + Python helper | `BeautyExampleRenderer`, strict PNG helpers, ignored gallery | Public-facade image evidence for eight isolated cases | Extend derived matrix to 44 cases × 7 fixtures |

## Stack Additions

None.

The only platform capability not currently represented in the package model is Vision's `innerLips` region. Apple documents `outerLips` as the outside lip outline and `innerLips` as the outline of the space between the lips. v1.10 should record availability for both, but keep all generated geometry package-internal and diagnostics aggregate-only.

## Development Tools

| Tool | Purpose | v1.10 use |
| --- | --- | --- |
| `swift test --package-path BeautySDK` | Runtime contract verification | Focused then full suite |
| `BeautyExampleRenderer` | Public-facade still-image exercise | Eight new isolated mouth geometry cases |
| Existing strict output/gallery helpers | Decoder, dimensions, ROI, signed-direction, containment | Derive expected matrix from renderer cases; reject partial/stale runs |
| `rg`, `git diff --check`, `git check-ignore` | Boundary and artifact scans | Public inventory, private geometry, no network/commercial imports, ignored PNGs |

## Alternatives Considered

| Recommended | Alternative | Why not for v1.10 |
| --- | --- | --- |
| Existing `MouthWarpProvider` | A provider or Metal pass per tool | Duplicates control-point policy and breaks the established unified-warp boundary |
| Vision outer/inner-lip availability | Third-party dense-landmark SDK | Adds dependency, privacy, packaging, and license scope not requested |
| Five semantic public fields | Alias new rows to `mouthSize`, `mouthWidth`, `smile`, or `lipColor` | Would borrow evidence and make controls non-independent |
| Ignored generated outputs | Tracked PNG golden baselines | Repository policy excludes binary media and current evidence is intentionally reproducible/local |

## Compatibility Contract

- Add exactly five numeric fields with defaulted public initializer arguments and missing-key decode to zero.
- Preserve all existing field names, meanings, coding keys, preset payloads, and source call sites.
- Public inventory becomes exactly 38 stored fields: 37 numeric values plus `filterId`.
- New fields proposed by this research: signed `mouthYPosition`, signed `mouthTilt`, signed `mouthXPosition`, positive-only `lipPeakDefinition`, and positive-only `lipPlump`.
- The names are project decisions derived from the current product-neutral naming convention; `lipPeakDefinition` avoids exposing the reference UI label `M唇` as an SDK concept.

## What Not to Add

| Avoid | Reason | Use instead |
| --- | --- | --- |
| Teeth segmentation or `teethWhitening` | Not geometry; needs a separate mask/retouch ownership contract | Keep `白牙` future |
| Demo UI rows | Milestone is SDK-core and facade-evidence only | Renderer cases and ledger updates |
| Raw landmark logging or persistence | Biometric-adjacent geometry is private | Stable reason codes and aggregate counts |
| New preset keys | Existing preset JSON is compatibility evidence | Prove missing-key zero defaults |

## Sources

- Repository: `BeautyParameters.swift`, `MouthWarpProvider.swift`, `BeautyEffectResolver.swift`, `BeautyGeometryEffectPipeline.swift`, and v1.8/v1.9 milestone evidence.
- Repository authority: `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, and `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`.
- Apple Vision: https://developer.apple.com/documentation/vision/vnfacelandmarks2d
- Apple Vision `innerLips`: https://developer.apple.com/documentation/vision/vnfacelandmarks2d/innerlips
- Apple Vision `outerLips`: https://developer.apple.com/documentation/vision/vnfacelandmarks2d/outerlips

---
*Stack research for: v1.10 Mouth Remaining Geometry Controls*
*Researched: 2026-07-14*
