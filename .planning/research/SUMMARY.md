# Project Research Summary

**Project:** Beauty — v1.8 Broader `美型 / 五官` SDK Slice - Mouth
**Domain:** Existing-parameter mouth geometry and lip-color evidence for a local-first iOS beauty SDK
**Researched:** 2026-07-13
**Confidence:** HIGH overall; MEDIUM for final fixture-level visual strength until the output matrix runs

## Executive Summary

v1.8 should extend the proven v1.5-v1.7 public-facade evidence architecture, not add product surface. The existing 31-field API already contains signed `mouthSize`, signed `mouthWidth`, unit-valued `smile`, and unit-valued `lipColor`; the geometry provider, unified warp pipeline, lip color pipeline, and conservative caps already exist. The milestone's work is to prove these behaviors through `BeautySDK`, close mouth-specific degradation and safety gaps, and synchronize evidence-backed documentation.

The recommended delivery is two phases. First, add six isolated facade cases across the seven established fixtures, a mouth-specific verifier, and ignored gallery routing. Second, lock caps, signed direction, missing/reused/stale behavior, combined weakening, redaction, and exact ledger promotion. This preserves the established split between black-box saved-output evidence and resolver/provider safety evidence.

The central product risk is semantic overclaim. `lipColor` is a bounded color-domain effect and is not true `丰唇` geometry. Completion may promote exactly `大小`, `宽度`, and `微笑`; `丰唇`, the remaining unmapped rows, and branch-level `嘴唇` must stay partial/future. Other key risks are sign loss, non-zero skipped strengths, false visual evidence from an unsuitable ROI or watermark, freshness/color conflation, and leakage of face-derived or generated artifacts.

## Key Findings

### Recommended Stack

No dependency, target, platform, public API, or Demo change is justified. Continue with Swift 6/SwiftPM, XCTest, the existing Core Image geometry/color pipelines, `BeautyExampleRenderer`, a Python standard-library verifier, and `example-images/generate_gallery.py`. Detailed rationale is in [STACK.md](STACK.md).

**Core technologies:**

- **Swift / SwiftPM:** Preserve the current iOS 17/macOS 14 package and 31-field public facade.
- **XCTest:** Lock caps, signed semantics, degradation, conflict weakening, redaction, and inventory without adding a test framework.
- **Core Image and existing render pipeline:** Reuse the unified mouth warp and separate bounded lip-color path.
- **Local evidence tools:** Use the existing renderer, a phase-owned standard-library checker, ignored gallery generation, and repository scans.

### Expected Features

The complete feature landscape and anti-features are in [FEATURES.md](FEATURES.md).

**Must have (table stakes):**

- Six isolated facade cases: positive/negative `mouthSize`, positive/negative `mouthWidth`, `smile`, and `lipColor`.
- Deterministic ignored evidence: expected files, decode/non-empty/dimensions, mouth-region differences, signed-pair differences, no-face preservation, gallery routing, and zero tracked generated PNGs.
- Exact caps: `mouthSize = 0.35`, `mouthWidth = 0.35`, `smile = 0.50`, `lipColor = 0.50`.
- Missing/no-face/stale fail-closed geometry; reused geometry at the established `0.5` scale with signs preserved.
- Table-driven combined weakening, redacted diagnostics, and continuation of independent safe domains.
- Promotion of exactly `大小`, `宽度`, and `微笑`, while keeping branch-level `嘴唇` partial.

**Should have (differentiators):**

- Signed-safe shaping from public input through saved output.
- Explicit geometry/color domain separation for predictable host integration.
- Failure isolation so unusable mouth geometry does not suppress unrelated safe effects.
- Evidence-backed taxonomy that avoids unsupported parity or commercial claims.

**Defer:**

- True `丰唇` geometry and controls for `上下`, `倾斜`, `左右`, and `M唇`.
- Teeth whitening and any new segmentation/resource ownership.
- SwiftUI Demo additions, physical-device/commercial review, packaging, launch readiness, and broad Meitu parity.

### Architecture Approach

Keep the current facade path: `BeautyExampleRenderer` sets one existing public field, `BeautyEngine` performs package-internal face selection, `BeautyEffectResolver` applies caps/freshness/conflict policy, and the existing geometry or color pipeline returns an extent-preserving image with geometry-free diagnostics. The detailed component and data-flow analysis is in [ARCHITECTURE.md](ARCHITECTURE.md).

**Major components:**

1. **Public-facade renderer and verifier** — Produce and validate isolated black-box mouth/lip outputs without importing internal targets.
2. **Resolver and existing providers/pipelines** — Preserve signed geometry, zero skipped strengths, apply reuse/combined weakening, and keep `lipColor` out of geometry scaling.
3. **Focused safety and facade tests** — Prove caps, direction, freshness policy, containment, redaction, privacy boundaries, and safe-domain continuation.
4. **Ledger and contract owners** — Promote only the three supported geometry rows after runtime and safety gates pass.

### Critical Pitfalls

The complete catalog and recovery guidance is in [PITFALLS.md](PITFALLS.md).

1. **Provider-only signed proof** — Require paired facade outputs and direct positive-versus-negative comparisons, plus sign-preserving combined tests.
2. **Skipped geometry with live strengths** — Zero all three mouth geometry strengths on no-face, missing, and stale routes.
3. **Geometry/color freshness conflation** — Specify `.mouth` and `.lipColor` policy independently even though both consume outer-lip geometry.
4. **Weak or misleading ROI evidence** — Exclude the watermark, use an isolated lower-central mouth ROI, and give lip color a color-sensitive containment check.
5. **`lipColor` promoted as `丰唇`** — Treat tint as color evidence only; never cite it as volume, displacement, or control-point proof.
6. **Privacy/artifact leakage** — Keep diagnostics categorical/count-only and keep generated outputs/gallery ignored and untracked.

## Implications for Roadmap

### Phase 33: Mouth Renderer Output Evidence

**Rationale:** Public-facade visibility must be established before documentation promotion, and it provides concrete output targets for safety closeout.

**Delivers:** Six locked single-parameter renderer cases; an expected 34-case-by-seven-fixture matrix (238 ignored outputs if fixture inventory remains unchanged); a phase-owned checker; mouth/lip gallery routing; mouth-ROI, signed-pair, dimension, no-face, facade-import, ignore, and artifact checks.

**Addresses:** Public-facade cases, deterministic output evidence, signed output separation, and lip-color isolation.

**Avoids:** Provider-only proof, watermark/global-difference false positives, mixed-domain attribution, historical helper drift, and tracked generated artifacts.

### Phase 34: Mouth Safety, Degradation, and Ledger Closeout

**Rationale:** Ledger promotion requires semantic and safety proof in addition to visible pixels. This phase can build on the frozen case inventory and evidence semantics from Phase 33.

**Delivers:** Exact cap and abnormal-input tests; missing/no-face/stale exact-zero behavior; reused `0.5` geometry scaling; explicit stale/reused lip-color policy; table-driven combined weakening with sign preservation; redacted warnings/metrics and safe-domain continuation; public/privacy/import/network scans; exact three-row promotion and synchronized root/blueprint contracts.

**Uses:** XCTest, current resolver/provider/color/geometry architecture, and Phase 33's facade evidence.

**Avoids:** Non-zero skipped strengths, geometry/color conflation, direction loss, raw geometry disclosure, `丰唇` overclaim, and whole-branch promotion.

### Phase Ordering Rationale

- Freeze the six-case facade contract and output semantics before safety closeout so later tests and documentation cite stable evidence.
- Keep black-box output proof separate from resolver/provider semantic proof; neither substitutes for the other.
- Promote documentation only after output, safety, boundary, redaction, and artifact gates all pass.
- Preserve archived v1.6/v1.7 helpers and evidence; v1.8 owns its new verifier and counts.

### Research Flags

Phases likely needing targeted validation during planning:

- **Phase 33:** Confirm the mouth ROI and color-containment thresholds empirically against all usable portraits; the architecture is known but visual strength is not yet measured.
- **Phase 34:** Decide and lock the exact stale/reused `lipColor` contract independently from geometry before implementation.

Phases with standard patterns (skip broad research-phase):

- **Phase 33:** Renderer inventory, local helper, ignored gallery, and artifact scans follow the completed eye/nose pattern.
- **Phase 34:** Caps, degradation, conflict, redaction, facade-boundary, and exact ledger guards have direct predecessor patterns in Phases 30 and 32.

## Confidence Assessment

| Area | Confidence | Notes |
| --- | --- | --- |
| Stack | HIGH | Verified against the current package, test, renderer, and prior evidence infrastructure. |
| Features | HIGH | Scope and exclusions are explicit in `PROJECT.md` and current ledger owners; visual strength remains to be measured. |
| Architecture | HIGH | Existing source already separates mouth geometry and lip color and exposes the required facade route. |
| Pitfalls | HIGH | Most failure modes are visible in current seams or directly evidenced by completed eye/nose patterns. |

**Overall confidence:** HIGH

### Gaps to Address

- **Mouth ROI thresholds:** Calibrate during Phase 33 planning/execution and record immutable verifier criteria after running the seven fixtures.
- **`lipColor` freshness behavior:** Choose a fail-closed stale policy or document another proven-safe contract; never inherit geometry scaling implicitly.
- **Derived matrix counts:** Recalculate from the actual case and fixture inventories rather than scattering the provisional 34/238 counts.

## Sources

### Primary (HIGH confidence)

- Repository contracts: `.planning/PROJECT.md`, root architecture/design/product/reliability/security documents, and the authoritative beauty-shaping ledger/readmes.
- Current implementation: `BeautyEffectResolver`, `MouthWarpProvider`, geometry/color pipelines, `BeautyExampleRenderer`, and focused SDK tests.
- Completed v1.6 and v1.7 milestone artifacts: established eye/nose renderer, safety, degradation, redaction, gallery, and exact-promotion patterns.

### Secondary (MEDIUM confidence)

- Fixture-level visual expectations inferred from the current seven-fixture evidence design; thresholds require execution-time calibration.

---
*Research completed: 2026-07-13*
*Ready for roadmap: yes*
