# Architecture Research

**Domain:** Two independent still-image local color-retouch features in a modular Swift SDK
**Researched:** 2026-08-05
**Confidence:** HIGH
**Execution note:** Completed inline because this Codex session exposed no GSD subagent dispatch tool.

## Recommended Architecture

### System Overview

```text
┌──────────────────────────────────────────────────────────────┐
│ BeautySDK public still-image facade                          │
│  BeautyParameters: teethWhitening / scleraRednessReduction  │
└──────────────────────────────┬───────────────────────────────┘
                               ↓
┌──────────────────────────────────────────────────────────────┐
│ Existing v1.14 request foundation                            │
│ validate → canonical explicit-sRGB RGBA8 → one Vision map   │
│ → one request-local context                                  │
└───────────────┬───────────────────────────┬──────────────────┘
                ↓                           ↓
┌──────────────────────────┐   ┌───────────────────────────────┐
│ Teeth provider           │   │ Sclera provider              │
│ lip support + seeds      │   │ left/right eye+pupil guards  │
│ connected candidates     │   │ hard envelope + red score    │
│ hard mouth re-clip       │   │ feather + hard re-clip       │
└───────────────┬──────────┘   └──────────────┬────────────────┘
                └──────────────┬───────────────┘
                               ↓
┌──────────────────────────────────────────────────────────────┐
│ Existing local-retouch composition owner                     │
│ immutable source + one owner/pixel + overlap keeps source    │
└──────────────────────────────┬───────────────────────────────┘
                               ↓
┌──────────────────────────────────────────────────────────────┐
│ Existing renderer/output reconstruction and public result     │
│ aggregate-only diagnostics; no masks/support persisted       │
└──────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Implementation Boundary |
| --- | --- | --- |
| `BeautyParameters` | Independent positive-only intent, normalization, Codable/source compatibility | `BeautyCore`; add teeth first, sclera only after teeth closes. |
| Local-retouch admission/resolver | Convert nonzero eligible public fields into exact private demand | `BeautyEffects`; no opaque count-only production shortcut after activation. |
| Teeth mask provider | Validate lip support, build fixed baseline, grow connected color-qualified candidates, enforce hard mouth envelope | `BeautyEffects`; package-only, request-local, no persisted mask. |
| Sclera mask provider | Validate each eye/pupil independently, exclude iris/highlight/lash/skin, score redness, re-clip | `BeautyEffects`; returns zero, one, or two accepted eye units. |
| Bounded transforms | Read immutable original RGBA8 and produce target-local color delta | `BeautyEffects`; deterministic and separated from mask selection. |
| Composition owner | Validate ownership, compose once, preserve source on collision, return aggregate summary | Existing v1.14 `BeautyLocalRetouchComposition`. |
| Evidence/review boundary | Prove rights, polarity, target presence, containment, naturalness, and structured decision | Local ignored Phase 54-compatible tooling plus tracked sanitized aggregates/decisions. |
| Renderer/strict decoder | Exercise each field only through public facade and validate changed/protected/outside regions | `BeautyExampleRenderer` and tests; disposable generated images remain ignored. |

## Recommended Project Structure

```text
BeautySDK/
├── Sources/BeautyCore/
│   └── BeautyParameters.swift                 # append-only public fields
├── Sources/BeautyDetection/
│   └── existing request-local lip/eye support # no new request or public geometry
├── Sources/BeautyEffects/
│   ├── Planning/
│   │   └── BeautyLocalRetouchAdmission.swift  # exact feature demand
│   └── Render/
│       ├── BeautyTeethWhiteningProvider.swift
│       ├── BeautyScleraRednessProvider.swift
│       └── BeautyLocalRetouchComposition.swift
├── Sources/BeautySDK/
│   └── BeautyEngine.swift                     # one facade/request owner
└── Tests/
    ├── feature-focused contract tests
    ├── protected-region/adversarial oracles
    └── public-facade output/regression tests

.planning/
├── evidence/ or phase evidence                 # sanitized tracked decisions only
└── local ignored review media                  # original/mask/after assets
```

### Structure Rationale

- **Keep providers in `BeautyEffects`:** selection and bounded color transforms are effect policy, while Vision continues to own only observed support.
- **Reuse `BeautyDetection`:** v1.14 already captures actual lip, eye, and pupil support from one request; no second detector or semantic cache is justified.
- **Keep composition feature-neutral:** providers propose owned local edits; the composer remains the only overlap and immutable-source authority.
- **Separate evidence from production:** review data decides whether code may activate, but raw media and masks never become SDK resources or repository diagnostics.

## Architectural Patterns

### Independent Evidence-to-Admission Gate

**What:** Each feature follows `complete bundle → frozen review → decision → field/provider/admission`, with no route created before the decision passes.

**When to use:** Teeth first, then sclera. A failed/closed gate leaves exact absence and does not alter its sibling.

**Trade-off:** More phases and explicit checkpoints, but prevents inert APIs and evidence borrowing.

### Support Is Not Segmentation

**What:** Vision regions bound and validate search space; color/geometry rules produce a conservative private mask.

**When to use:** Inner/outer lips for teeth and eye/pupil support for sclera.

**Trade-off:** Lower recall than a learned segmenter, but deterministic, local, license-safe, and fail-closed.

### Smallest Anatomical Failure Unit

**What:** Teeth is one mouth unit; sclera is two independent eye units. Invalid units abstain without changing accepted siblings or unrelated effects.

**When to use:** Missing lip seeds, closed/occluded mouth, blink, pupil outside aperture, glare, or malformed support.

### Original-Pixel Single Owner

**What:** Every accepted edit reads the canonical source; composition accepts at most one feature owner per pixel and preserves source on collision.

**When to use:** Standalone and combined requests.

**Trade-off:** Requires explicit ownership proposals but removes ordering semantics and color feedback.

## Data Flow

### Teeth Request

```text
public teethWhitening > 0
  → canonicalize once
  → one Vision selected-face mapping
  → validate inner+outer lip support
  → fixed strong teeth seeds
  → connected adaptive candidates inside narrow hard mouth envelope
  → feather and hard re-clip
  → bounded yellow-excess/luminance transform from original pixels
  → composer → renderer → public result
```

### Sclera Request

```text
public scleraRednessReduction > 0
  → canonicalize once
  → one Vision selected-face mapping
  → independently validate left and right eye+pupil
  → per-eye hard aperture/iris/highlight envelope
  → redness score → local feather → same hard re-clip
  → bounded red-excess transform from original pixels
  → composer (0/1/2 eye units) → renderer → public result
```

### Combined Request

```text
one canonical source + one mapped request context
  → teeth proposal(s) and sclera eye proposal(s)
  → deterministic ownership validation
  → disjoint pixels: exactly one source-derived transform
  → overlap pixels: canonical source retained
  → one output + aggregate-only summary
```

## Scale and Performance Considerations

| Scale | Architecture Adjustment |
| --- | --- |
| Current still-image SDK | Correctness-first CPU/reference providers with bounded allocations and one Vision request. |
| Large still images | Keep existing input ceilings; use mouth/eye ROI work only after full-frame ownership and byte oracles remain identical. |
| Realtime/video | Out of v1.15; requires a separate temporal and device architecture rather than reusing still masks. |

### Scaling Priorities

1. **First bottleneck:** per-pixel full-image provider loops; optimize to validated ROIs only after feature correctness.
2. **Second bottleneck:** Vision and output rendering; preserve one request and a reused `CIContext`, then profile on target devices.

## Anti-Patterns

### Provider Hidden Inside Renderer

**What people do:** Infer anatomy and change colors in one opaque render pass.
**Why it is wrong:** Mask quality, protected leakage, transform bounds, and failure isolation cannot be tested separately.
**Do this instead:** Separate request-local provider, transform, composition, and output evidence.

### Shared Eligibility Authority

**What people do:** Let one “local retouch enabled” flag authorize both features.
**Why it is wrong:** A completed teeth bundle cannot prove sclera safety or vice versa.
**Do this instead:** Feature-specific decisions and exact admission rows.

### Second Vision Request

**What people do:** Redetect for each provider.
**Why it is wrong:** Adds drift, cost, and conflicting face/support ownership.
**Do this instead:** Consume the one canonical request context from v1.14.

## Integration Points

### External Frameworks

| Framework | Integration Pattern | Notes |
| --- | --- | --- |
| Apple Vision | Existing single request over canonical `.up` image | Optional regions can be absent; pupil may be inaccurate during blink; fail closed. |
| Core Image | Existing reused context with explicit sRGB working/output behavior | Do not create divergent Vision/render inputs or multiple contexts per request. |

### Internal Boundaries

| Boundary | Communication | Notes |
| --- | --- | --- |
| `BeautySDK` ↔ `BeautyCore` | Public value model | Append-only fields with zero-default compatibility. |
| `BeautySDK` ↔ `BeautyDetection` | Package-only immutable observation | One mapped selected-face context; no masks returned publicly. |
| `BeautySDK` ↔ `BeautyEffects` | Exact private admission + request context | Teeth activates before any sclera production route. |
| Providers ↔ composer | Request-local owned proposals | Hard-clipped masks and source-bound transforms only. |
| SDK ↔ review tooling | No runtime communication | Review artifacts decide promotion but are not packaged resources. |

## Sources

- [Apple: VNDetectFaceLandmarksRequest](https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest) — single-request face/feature analysis behavior.
- [Apple: rightPupil](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/rightpupil) — pupil support is optional and may be inaccurate during blink.
- [Apple: CIContext](https://developer.apple.com/documentation/coreimage/cicontext) — managed color pipeline and context reuse.
- Repository root architecture/design/security/reliability contracts, v1.14 audit, and `spike-findings-beauty` references.

---
*Architecture research for: v1.15 independent teeth and sclera retouch*
*Researched: 2026-08-05*
