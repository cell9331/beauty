---
phase: 91-independent-gaze-correction
verified: 2026-09-06T00:11:46Z
status: passed
score: 21/21 must-haves verified
overrides_applied: 0
---

# Phase 91: Independent Gaze Correction Verification Report

**Phase Goal:** The owner can correct supported gaze independently per eye while preserving the surrounding eye and face anatomy.
**Requirement:** EYE-01
**Verified:** 2026-09-06
**Status:** passed

## Goal Achievement

Phase 91 is complete. The production path accepts only request-local observed
support for positive gaze, decides eligibility per eye, moves each admitted
pupil toward that same eye's center, bounds the field inside a finite simple
aperture, reconciles credit against the exact final post-conflict points, and
publishes only six bounded aggregate metrics. Generated public-facade pixels
independently prove direction, peer isolation, target signal, protected-region
identity, metadata, determinism, and recovery.

The renderer/comparator bridge binds that aggregate to the exact successful
`gazeCorrection_0p25` output and still requires the frozen source/neutral,
sibling, locality, and protected-region pixel gates. Temporary renderer reports
are consumed and verified removed before durable publication. This is
package-host EYE-01 evidence only; Phase 95 still owns the authorized portrait
rerun, clean 65-output publication, and complete no-skip closeout.

## Roadmap Success Criteria

| # | Observable truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Positive `gazeCorrection` reduces each supported pupil's displacement from its own eye center. | VERIFIED | `EyeWarpProvider.gazeSample` computes `target = pupil + (center - pupil) * blend`, with an exact `0.002` dead zone and a maximum `0.35` blend (`EyeWarpProvider.swift:239-254`). The generated public-facade oracle measured left/right own-center reductions of `201/203 Q16`, both above the frozen floor of 16. |
| 2 | One-eye correction neither borrows peer geometry nor exceeds the aperture/contour/brow/background bounds. | VERIFIED | The gaze selector compact-maps independently eligible observed sides and never enters the legacy support path (`EyeWarpProvider.swift:174-181`). Strict source/target containment and radius `min(5% face width, 0.5 * smaller clearance)` are enforced at lines 256-290. Generated pixels report target `1316/51731`, while outside, contour, brow, background, and watermark aggregates are all `0/0`. |
| 3 | Missing or implausible support fails closed per eye without suppressing a valid peer. | VERIFIED | Adapter/provider mutations cover nil, multiple, nonfinite, outside, malformed, ratio-implausible, degenerate, self-intersecting, boundary, and outside-target inputs. The public oracle proves left-only, right-only, valid-plus-missing, and valid-plus-malformed cases change only the valid ROI; centered, invalid-pupil, no-face, and exact-dead-zone cases remain source-exact. Valid-invalid-valid recovery is byte-identical. |

All three roadmap criteria are verified.

## PLAN Must-Haves Audit

| Plan | Result | Evidence |
| --- | --- | --- |
| 91-01 | 5/5 verified | Separate gaze-only pupil eligibility, observed-only zero/one/two-side selection, exact `0.002`/`0.25`/35% law, simple-aperture containment, half-clearance radius, exact final-point reconciliation, request-local privacy, and RED-before-GREEN history are present. |
| 91-02 | 5/5 verified | The resolver derives the six-field aggregate only after conflict convergence and final field recomputation (`BeautyEffectResolver.swift:443-485`), validates its algebra (`:680-717`), and the generated 512x512 RGBA8 oracle proves actual public-facade pixels, metadata, locality, protection, determinism, peer rejection, and recovery. |
| 91-03 | 5/5 verified | Only the exact successful gaze renderer unit receives an optional aggregate (`RendererExecution.swift:369-378`); report admission binds schema/backend/counts and unique input/case/output identity; the hybrid comparator uses the aggregate only for direction and retains every actual-pixel gate (`compare-face-feature-batches.swift:815-930`); runner cleanup is descriptor-safe and mutation-tested. |
| 91-04 | 6/6 verified | All three predecessor summaries are regular files with shared `implementation_attempt: 1`; the 840-test current-authority suite, focused compatibility, comparator, boundary, preflight, backend-neutral, archive, SDK-only, owner-document, and diff gates passed; all owners record the same bounded outcome and Phase-95 handoff. |

**Score:** 21/21 PLAN must-haves verified.

## Required Artifacts

| Artifact | Status | Verification |
| --- | --- | --- |
| `BeautyFaceGeometryAdapter.swift` / `WarpControlPoint.swift` | VERIFIED | Stores locally validated `gazePupil` separately from paired `pupilSize` eligibility; both representations remain target-internal, request-local, and non-Codable. |
| `EyeWarpProvider.swift` | VERIFIED | Implements observed-only per-eye selection, own-center movement, exact boundary/cap law, aperture admission, clearance-bounded radius, and aggregate reconciliation against exact admitted points. |
| `BeautyEffectResolver.swift` | VERIFIED | Attaches exactly six gaze metrics after final emissions; malformed or inconsistent evidence collapses to the fixed abstaining form. |
| `BeautyEngineTestingSupport.swift` | VERIFIED | Supplies only package-internal deterministic gaze fixtures; no product-public anatomy type or persistent media path was added. |
| `BeautyEngineGazeCorrectionRepairTests.swift` | VERIFIED | Three substantive tests exercise generated 512x512 explicit-sRGB RGBA8 pixels through `BeautyEngine.processResult`, with independent chromatic markers and frozen semantic/protection thresholds. |
| `RendererCLIContract.swift` / `RendererExecution.swift` | VERIFIED | Carries an optional fixed six-field aggregate only on the exact successful gaze unit; validates field count, integrality, ranges, booleans, and count algebra. |
| `compare-face-feature-batches.swift` | VERIFIED | Admits exact renderer identity, uses the aggregate only for gaze direction, keeps source/neutral target signal, sibling, outside, and protected-region checks, canonicalizes stable output, and rejects privacy-unsafe JSON. |
| `run-face-feature-batches.sh` / boundary tests | VERIFIED | Retains reports until both comparisons consume them, verifies cleanup, preserves sanitized failure publication, and passes replay/path/symlink/cleanup mutations. |
| Root owners and taxonomy | VERIFIED | `PLANS.md`, `DESIGN.md`, `ARCHITECTURE.md`, `PRODUCT_SENSE.md`, `SECURITY.md`, `RELIABILITY.md`, `QUALITY_SCORE.md`, and `docs/SDK_EFFECT_TAXONOMY.md` contain consistent Phase 91 sections. |
| `91-VALIDATION.md` | VERIFIED | Final status is `validated`, `nyquist_compliant: true`, and `wave_0_complete: true`; every task, RED seam, HIGH threat, and sign-off row is checked. |

## Key-Link and Data-Flow Verification

| From | To | Via | Status |
| --- | --- | --- | --- |
| Observed eye support | `BeautyEyeSemanticSupport.gazePupil` | Adapter-local validation independent of paired pupil-size compatibility | WIRED |
| Per-eye gaze support | `WarpControlPoint` | Own-center target, exact strength law, strict aperture containment, clearance-bounded radius | WIRED |
| Final eye emissions | `BeautyResult.metrics` | Post-conflict exact-point reconciliation and fixed six-key validator | WIRED |
| Generated input | Public still-image output | `BeautyEngine.processResult` with independent chromatic marker centroid oracle | FLOWING |
| Successful gaze output | Renderer report unit | Exact `inputID + caseID + outputID`, CPU backend, reconciled status/counts | WIRED |
| Temporary renderer reports | Semantic comparator | Same-output aggregate direction plus frozen actual-pixel target/sibling/locality/protection gates | FLOWING |
| Comparator attempts | Durable semantic payload | Canonical stable reconciliation only after report cleanup verification | WIRED |
| Taxonomy | SDK-only boundary checker | Retained `gazeCorrection = implemented` qualification under unchanged 62/5/75 inventory | WIRED |

No component-only shortcut can earn credit: a control point without public
pixel evidence, an aggregate without same-output identity, or target pixels
without sibling/locality/protection evidence all fail the chain.

## Fresh Automated Evidence

| Check | Result |
| --- | --- |
| Phase 91 focused SwiftPM selection | `125` executed, `0` failures, `2` established Vision opt-in skips |
| Current-authority SwiftPM suite | Deferred FACE-01 oracle discovered exactly once; all other `840` tests passed with `0` failures and `8` established opt-in skips |
| Focused compatibility inventory | `107` executed, `0` failures, `0` skips |
| Semantic comparator mutation gate | `PASS`, `mutations=576`, `inventories=5/65/8` |
| Runner boundary gate | `PASS`; stale pass/fail, alias, symlink parent, invalid report, spaces/Unicode/component boundaries, `preflight_faults=3`, `report_cleanup=6` |
| Runner preflight | `PASS live=75 selected=65 semantic=8` |
| Backend-neutral contract | `PASS focused_tests=24 cpu_reference_tests=41` |
| Archive integrity | Both pinned legacy archives verified with hashes `04c14b...29db52` and `330e8a...fce9a` |
| SDK-only boundary | `POST-ARCHIVE SDK BOUNDARY PASSED` |
| Diff hygiene | `git diff --check` passed |

The current-authority suite intentionally excludes only
`FaceContourSmoothRepairTests/testFACE01GeneratedCPUFixturePassesFrozenSemanticAndProtectionContract`.
Phase 90 owns that frozen effectiveness oracle as an explicitly deferred,
non-GREEN FUTURE-04 item. It remains discovered and unchanged; its exclusion is
not a Phase 91 skip, repair claim, or weakening of EYE-01 evidence.

## Requirement Coverage

| Requirement | Status | Evidence |
| --- | --- | --- |
| EYE-01 | SATISFIED | Own-eye positive displacement, no peer borrowing, frozen aperture/contour/brow/background preservation, and per-eye fail-closed behavior are proven in production source, generated facade pixels, final aggregate algebra, renderer/comparator admission, and fresh gates. `REQUIREMENTS.md` maps EYE-01 exactly once to Phase 91 and marks it complete. |

No Phase 91 requirement is orphaned or deferred.

## TDD, Attempt, and Threat Audit

- All Phase 91 implementation work is `implementation_attempt: 1`; no second or
  third attempt occurred.
- Each implementation seam has a preceding RED commit and a later GREEN commit:
  `d856b92 -> 949d6a5`, `c05e2c1 -> f07845d`, `56636d0 -> 3a38bd9`,
  `de5a63d -> 7675721`, `e175cb5 -> 51e6d99`, and
  `101c81c -> f742a54`.
- HIGH threats T-91-01 through T-91-19 are mitigated by field-local observed
  ownership, strict topology/arithmetic admission, exact final-point matching,
  independent chromatic pixel proof, fixed thresholds, bounded aggregate
  validation, exact output identity, path/no-follow admission, verified cleanup,
  aggregate-only durable evidence, and explicit Phase-95 nonclaims.
- T-91-20's bounded closeout and T-91-SC's no-install boundary are satisfied.
  No dependency, package, model, dataset, weight, or external service was added.

## Compatibility, Privacy, and Nonclaims

- Exactly 62 stored parameter fields, five presets, 75 renderer cases, both
  public still-image facades, CPU reference behavior, selectable CPU/GPU policy,
  terminal Metal-unavailable behavior, and retained `Warp.metal` remain intact.
- No raw/per-side pupil or contour coordinates, source/target points, radii,
  masks, generated pixels, private locators, report rows, paths, or child
  transcripts enter durable result evidence or owner documentation.
- The generated image remains in memory; no Phase 91 media artifact is tracked.
- The authorized portrait batch, final clean 65-output publication, and
  `scripts/run-no-skip-swiftpm.sh` did not run and remain Phase 95 work.
- No device, population, naturalness, performance, thermal, battery, endurance,
  commercial visual-quality, packaging, shipping, launch, release-readiness, or
  external-distribution conclusion follows from this verification.

## Anti-Patterns and Disconfirmation Pass

- The retained `unsupportedMetric` leaf for direct pixel-derived
  `pupilToOwnEyeCenter` prevents revival of the old darkness proxy. The current
  gaze branch deliberately bypasses that proxy only after exact aggregate
  admission, then still applies every real pixel gate. This is a safety boundary,
  not a stub.
- Empty emissions are validated fail-closed paths, not placeholder behavior.
- The public oracle was checked for the strongest alternative explanations:
  peer-center substitution, general darkness, aggregate-only success, symmetric
  sibling behavior, one-eye masking, stale support, and state leakage. All are
  rejected by explicit tests or mutation probes.
- No TODO/FIXME/placeholder, empty handler, static-success report, or untracked
  production dependency was found in the Phase 91 implementation surface.

## Human Verification Required

None. Physical-device behavior and subjective naturalness are explicit
nonclaims and are not Phase 91 completion gates under the project policy.

## Gaps Summary

No gaps. Phase 91 achieves its goal and satisfies EYE-01 with a complete,
bounded package-host evidence chain. The orchestrator may advance ROADMAP,
STATE, PROJECT, and requirement bookkeeping to Phase 92.

---

_Verified: 2026-09-06T00:11:46Z_
_Verifier: Codex orchestrator fallback after the required gsd-verifier dispatch was interrupted by the account usage window_
