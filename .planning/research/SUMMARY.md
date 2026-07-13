# Project Research Summary

**Project:** BeautySDK
**Domain:** Local-first SwiftPM iOS beauty SDK; v1.9 independent nose-geometry API expansion and SDK branch closeout
**Researched:** 2026-07-13
**Confidence:** HIGH for repository integration, compatibility, safety, and closeout boundaries; MEDIUM for final geometry tuning and fixture thresholds

## Executive Summary

v1.9 should extend the existing SDK in place with two independent, opt-in nose controls for the remaining `山根` and `提升` rows. No new package, render pass, dependency, public geometry type, network path, or Demo UI is needed. The established route—`BeautyParameters` through resolver safety policy and `NoseWarpProvider` into the unified geometry pipeline—already owns the work. The public model grows from 31 stored fields (30 numeric plus `filterId`) to 33 stored fields (32 numeric plus `filterId`), with default-zero and missing-key decoding preserving existing source-style calls, presets, and old JSON behavior.

The research documents disagree on the exact names and direction contracts. This summary resolves the roadmap baseline to positive-only `noseRootNarrowing` (`0...1`) and positive-only `noseTipLift` (`0...1`), both defaulting to `0`. `noseRootNarrowing` is the most honest contract supported by the current 2D warp: it narrows only the uppermost root band horizontally and does not claim physical height/depth. `noseTipLift` localizes the second control to the lower tip region and avoids the whole-nose ambiguity of `noseLift`; it moves that region upward with stable horizontal coordinates and is not signed tip resizing. This decision must be frozen in the first phase before production code. If product instead requires vertical root extension or downward tip movement, planning must change the public contract and evidence matrix deliberately rather than mixing those semantics during implementation.

The main risks are semantic aliases disguised as new fields, incomplete propagation through manually enumerated safety/degradation paths, and premature branch promotion based only on changed pixels. Mitigate them with provider-level region/vector assertions, pairwise comparisons against `noseBridge` and both signed `noseTipSize` behavior, old-payload compatibility tests, all-six-nose freshness/conflict tests, facade-only output evidence, redaction/artifact scans, and atomic documentation promotion only after every gate passes.

## Reconciled Contract Decisions

| Topic | Conflicting research | Roadmap baseline | Reason / consequence |
| --- | --- | --- | --- |
| `山根` name | `noseRootHeight` versus `noseRootNarrowing` | `noseRootNarrowing` | Current rendering can prove localized horizontal definition, not physical height, projection, or lighting. Root points must be a smaller region than `noseBridge`. |
| `山根` motion | Vertical upper-root extension versus symmetric horizontal contraction | Uppermost-root horizontal contraction with stable Y | This is directly testable in 2D and distinct from broader bridge behavior. If the current geometry cannot select this subset reliably, keep the row partial instead of aliasing it. |
| `提升` name | `noseLift` versus `noseTipLift` | `noseTipLift` | The affected region is the lower tip/support region; `noseLift` could imply whole-nose translation. |
| `提升` range | Signed `-1...1` versus positive-only `0...1` | Positive-only `0...1` | Architecture and feature research converge on enhancement-only milestone scope. Downward movement would add an unrequested behavior and requires a second direction case and safety contract. |
| Public inventory | Some prose calls the current inventory “31 numeric fields” | 31 stored today = 30 numeric + `filterId`; 33 stored after v1.9 = 32 numeric + `filterId` | Mirrors the authoritative source and current `Mirror` test. Update only current owners; archived 31-field milestone evidence remains historical. |
| Renderer matrix | Two positive cases versus three cases for a signed lift | Two isolated cases under the baseline contract | With the current 34 cases and seven fixtures, this means 36 cases and 252 ignored outputs. Derive counts from actual lists so later inventory changes cannot silently stale the checker. |

## Key Findings

### Recommended Stack

Keep the existing Swift 6 / SwiftPM package, XCTest suites, Core Image-backed unified geometry pipeline, public `BeautySDK` facade, and `BeautyExampleRenderer`. Extend the existing Python output-checker/gallery pattern for deterministic local evidence. No manifest, platform, target, external library, or installation change is justified. See [STACK.md](STACK.md).

**Core technologies:**

- Swift / SwiftPM — add the two values and route them through the existing target graph; the current package boundaries already match ownership.
- XCTest — lock defaults, normalization, Codable compatibility, provider semantics, resolver safety, facade routing, and inventory.
- Core Image plus the unified geometry pipeline — render bounded local warps without adding a pass or exposing control points.
- `BeautyExampleRenderer` and a milestone-owned Python checker — produce facade-only, ignored, reproducible output evidence across committed fixtures.

### Expected Features

The milestone is complete only when the fields are independent in storage, geometry, safety policy, and public evidence—not merely when two labels exist. See [FEATURES.md](FEATURES.md).

**Must have (table stakes):**

- Two default-zero, compatibility-safe public fields with exact positive-only semantics and a 33-stored-field inventory.
- Root-only horizontal contraction and lower-tip vertical-only lift, with nonzero, bounded, deterministic provider vectors.
- New-vs-baseline and new-vs-nearest-legacy comparisons through `BeautySDK`, above the watermark and focused on a nose ROI.
- Exact evidence-calibrated natural caps, six-field nose zero/reuse/conflict handling, safe-domain continuation, and redacted diagnostics.
- Full ignored output/gallery inventory, no-face evidence, zero tracked generated PNGs, and synchronized SDK-branch closeout.

**Should have (differentiators):**

- Orthogonal controls that hosts can combine without duplicate slider semantics.
- Compatibility-safe model growth where old JSON and bundled presets stay neutral.
- Evidence-backed capability status that separates SDK support from Demo, device, commercial, and parity claims.

**Defer:**

- Real `noseCrest` or other detection-model refinement unless the current internal proxy cannot satisfy the frozen contract.
- Signed root widening or downward tip movement; these require separate product demand and bidirectional evidence.
- Demo controls, physical-device/commercial approval, 3D depth/relighting, packaging, account/commerce, cloud, and broad reference-app parity.

### Architecture Approach

Add the fields to `BeautyParameters`, thread them through `BeautyEffectiveStrengths`, centralized safety caps, geometry-required routing, freshness reduction, and a single combined-geometry weakening step, then generate distinct points inside `NoseWarpProvider`. The existing geometry adapter, unified render pipeline, `BeautyEngine`, and public result shape should remain intact. Prefer resolving combined geometry exactly once after caps/freshness and before providers; if that refactor is declined, exhaustive tests must prove neither omission nor double scaling. See [ARCHITECTURE.md](ARCHITECTURE.md).

**Major components:**

1. `BeautyCore` public model — storage, coding keys, defaulted initializer, missing-key decode, normalization, and the 31→33 stored-field contract.
2. `BeautyEffects` planning/safety — caps, six-field nose activation, zeroing, reused `0.5` scaling, stale/missing failure, and combined weakening.
3. `NoseWarpProvider` — independently named upper-root narrowing and lower-tip lift point generation using internal geometry only.
4. `BeautySDK` facade and unified render — existing detection/routing and extent-preserving output, with no new public geometry.
5. Renderer/checker/docs — isolated public cases, ignored evidence, privacy/artifact checks, and atomic row/branch promotion.

### Critical Pitfalls

See [PITFALLS.md](PITFALLS.md) for the full prevention checklist.

1. **Semantic aliasing** — never back either field with `noseBridge`, `noseTipSize`, or their archived evidence; require distinct provider vectors and pairwise public-output differences.
2. **Incomplete public-model plumbing** — update stored properties, coding keys, initializer defaults, decoder, normalization, round trip, presets, and inventory together; do not rewrite archived evidence.
3. **No-op or overlapping geometry** — assert region, axis, direction, nonzero displacement, bounds, deterministic order, and combined behavior rather than only point counts.
4. **Freshness/conflict omissions** — trace both fields through every legacy nose list: detection, activation, cap counts, zeroing, reused scaling, stale/missing failure, total/count/scale, and provider-empty fallback.
5. **Weak or privacy-unsafe evidence** — pixels alone do not prove semantics; use facade plus provider/resolver tests, keep diagnostics aggregate/category-only, and keep generated portraits ignored and untracked.
6. **Premature overclaim** — promote exactly `山根`, `提升`, and the SDK-core `鼻子` branch only after all owners agree; do not imply Demo, device, commercial, packaging, launch, or broad parity readiness.

## Requirements Implications

The three active requirements in [PROJECT.md](../PROJECT.md) should become explicit, traceable acceptance groups:

| Active requirement | Derived acceptance implications |
| --- | --- |
| Define independent public semantics and compatibility | Freeze `noseRootNarrowing` and `noseTipLift`; prove default zero, positive-only finite clamps, non-finite zero, missing-key zero, new round trips, old presets, source-style initializer compatibility, and exactly 33 stored fields. |
| Produce facade-visible output and safety/degradation evidence | Prove provider region/vector independence; exact caps; new-only detection; fresh/reused/missing/stale/no-face behavior across all six nose strengths; once-only conflict weakening; safe-domain continuation; redacted results; isolated facade outputs and pairwise ROI differences. |
| Promote remaining rows and branch only after closeout | Require full renderer/checker/gallery inventory, ignored/untracked artifacts, active-source boundary scans, full tests, synchronized current owners, preserved archives, and explicit SDK-only non-claims before status changes. |

No requirement should be considered validated by a public field alone, provider tests alone, or output differences alone. Each needs contract, semantic, integration, safety, and evidence coverage.

## Implications for Roadmap

Based on the dependency chain, use three phases. These align with the phase numbering anticipated by the detailed research and keep semantic/API risk ahead of expensive output generation.

### Phase 35: Public Contract and Independent Geometry

**Rationale:** Names, ranges, and displacement semantics become costly public commitments and determine model plumbing, cap tests, and renderer case count.

**Delivers:** Frozen `noseRootNarrowing`/`noseTipLift` contract; 33-field model and Codable compatibility; effective-strength and routing propagation; provisional conservative caps; distinct provider paths; focused normalization, cap, region, axis, non-alias, detection, and missing-input tests.

**Addresses:** Independent public parameter contracts, provider spatial separation, compatibility-safe inventory growth.

**Avoids:** Semantic aliases, ABI/source compatibility overclaims, no-op vectors, implicit directionality, and omissions from repeated resolver lists.

### Phase 36: Public-Facade Output Evidence

**Rationale:** Output evidence is meaningful only after semantics and provider behavior are locked. Isolated rendering then calibrates the exact natural caps and thresholds used for closeout.

**Delivers:** Two one-field renderer cases; milestone-owned checker and ignored gallery routes; full 36×7 inventory if current fixtures/cases remain unchanged; 12 portrait baseline comparisons; root-vs-bridge and lift-vs-tip-size ROI comparisons; representative no-face and artifact-containment evidence.

**Uses:** `BeautyExampleRenderer`, existing facade/detection/render path, XCTest inventory guards, Python standard-library checker, and ignored output/gallery roots.

**Implements:** Black-box proof that each independent provider path survives the public SDK without changing dimensions or exposing internals.

### Phase 37: Nose Safety, Boundary, and Branch Closeout

**Rationale:** Shared degradation/conflict behavior and status promotion are cross-cutting gates best finalized after isolated outputs establish viable caps and semantics.

**Delivers:** Exact cap and capped-count locks; all-six no-face/missing/stale zeroing; reused exact `0.5`; once-only combined weakening; safe-domain continuation; redaction/import/network/dependency/public-geometry/generated-artifact scans; full tests and renderer rerun; synchronized current documentation; atomic promotion of the two rows and SDK-core `鼻子` branch.

**Addresses:** Safety/degradation evidence and evidence-backed branch completion.

**Avoids:** Stale geometry, unscaled new fields, double weakening, sensitive diagnostics, matrix drift, archive rewriting, and product-scope overclaim.

### Phase Ordering Rationale

- Contract decisions must precede implementation because range/direction determine `clampUnit` versus `clampSigned`, provider tests, caps, and whether the renderer needs two or three cases.
- Public model and resolver routing precede provider/facade evidence so a visible output cannot mask compatibility or degradation gaps.
- Provider semantics precede black-box comparisons; pixels prove observability while vector tests prove meaning.
- Exact tuning is finalized from isolated fixture evidence before exhaustive combined-safety assertions are locked.
- Branch promotion is last because it depends on every contract, runtime, privacy, artifact, and documentation owner agreeing.

### Research Flags

Phases likely needing deeper validation during planning:

- **Phase 35:** Validate that current internal nose points support a deterministic uppermost-root subset distinct from `noseBridge`; if not, stop and re-scope detection quality rather than aliasing.
- **Phase 36:** Calibrate exact caps and nose-ROI thresholds across the six usable portrait fixtures; current `<= 0.25` values and expected difference counts are hypotheses until rendered.
- **Phase 37:** Inspect current conflict-resolver call placement before choosing a once-only refactor; shared behavior needs regression coverage for previously shipped face, eye, nose, and mouth fields.

Phases with standard patterns (skip broad external research):

- **Phase 35 public model compatibility:** The repository already has the authoritative manual `Codable`/normalization pattern and tests.
- **Phase 36 renderer/helper/gallery mechanics:** v1.7 and v1.8 provide established local patterns; create v1.9-owned evidence rather than editing archived helpers.
- **Phase 37 boundary and owner scans:** Existing security, reliability, and closeout contracts define the required commands and non-claims.

## Confidence Assessment

| Area | Confidence | Notes |
| --- | --- | --- |
| Stack | HIGH | Existing package graph, test framework, facade renderer, and unified render path are verified repository seams; no dependency change is needed. |
| Features | HIGH for required gates; MEDIUM for final visual tuning | Independence, compatibility, degradation, privacy, and closeout expectations are explicit; cap/ROI thresholds require fixture evidence. |
| Architecture | HIGH for integration; MEDIUM for root geometry and conflict refactor | Ownership and routing are established. The upper-root subset and once-only conflict placement require implementation inspection/tests. |
| Pitfalls | HIGH | Risks are grounded in current manual field enumeration, archived evidence rules, render behavior, and repository privacy boundaries. |

**Overall confidence:** HIGH for roadmap direction, MEDIUM for final algorithm/tuning details.

### Gaps to Address

- **Final product sign-off on the reconciled contract:** Confirm positive-only `noseRootNarrowing` and `noseTipLift` before code. A choice of vertical “height” or signed lowering changes API names, tests, and renderer inventory.
- **Upper-root landmark sufficiency:** Prove the internal nose proxy selects a stable, localized subset across fixtures; otherwise preserve partial status and plan detection refinement.
- **Exact natural caps and ROI thresholds:** Start conservatively at no more than `0.25`, then lock values only from focused output review and tests.
- **Conflict-resolution call placement:** Determine whether the existing resolver can be safely made once-per-plan; otherwise require exhaustive proof of equivalent single scaling.
- **Binary compatibility:** The plan preserves source rebuild and JSON compatibility, not ABI compatibility for precompiled clients. Binary distribution remains separately scoped.

## Sources

### Primary (HIGH confidence)

- [PROJECT.md](../PROJECT.md) — v1.9 goal, active requirements, scope, and non-claims.
- [STACK.md](STACK.md) — repository stack, public model compatibility, integration seams, and alternatives.
- [FEATURES.md](FEATURES.md) — independent feature semantics, evidence gates, dependencies, and prioritization.
- [ARCHITECTURE.md](ARCHITECTURE.md) — target ownership, geometry flow, resolver/provider integration, build order, and documentation owners.
- [PITFALLS.md](PITFALLS.md) — failure modes, phase mapping, security/artifact risks, and recovery guidance.
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — authoritative current 31-stored-field shape and normalization/decoding pattern.
- Existing resolver, provider, renderer, and test sources referenced by the four detailed research documents — authoritative implementation and verification seams.

### Secondary (MEDIUM confidence)

- Archived v1.7/v1.8 milestone requirements, helpers, and evidence — established facade-output, safety, degradation, artifact, and closeout patterns; historical counts remain immutable.
- Root contracts and current feature-ledger/branch documentation cited by the detailed research — current ownership and product-status boundaries.

### Tertiary (LOW confidence)

- Historical naming suggestions such as `noseBridgeHeight` and signed `noseTipLift` — useful for identifying ambiguity, but superseded by current 2D capability boundaries and the explicit v1.9 contract decision.

---
*Research completed: 2026-07-13*
*Ready for roadmap: yes, after Phase 35 explicitly freezes the reconciled public semantics*
