# Phase 44: Eye Geometry Safety and Ledger Closeout - Pattern Map

**Mapped:** 2026-07-19
**Files analyzed:** 31 current runtime/test/owner/helper surfaces plus Phase 30/37/40 analogs
**Analogs found:** 31 / 31

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match |
|---|---|---|---|---|
| `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` | XCTest contract | request-response transform | existing cap tests + Phase 40 cap matrix | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | XCTest resolver | transform/accounting | Phase 40 resolver tests | exact |
| `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` | XCTest provider | transform/eligibility | Phase 42 provider tests | exact |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | XCTest transitions | state transition | Phase 40/37 degradation tests | exact |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | XCTest multi-domain | transform/accounting | Phase 40 combined matrix | exact |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | XCTest convergence | transform/accounting | Phase 40 retained-set arithmetic | exact |
| `.planning/phases/44.../check_eye_geometry_boundaries.py` | boundary utility | batch scans/fixture mutations | `check_mouth_geometry_boundaries.py` | exact |
| `.planning/phases/44.../44-EYE-SAFETY-EVIDENCE.md` | evidence ledger | command/result record | `40-MOUTH-SAFETY-EVIDENCE.md` | exact |
| `.planning/phases/44.../44-SECURITY.md` | ASVS threat record | boundary evidence | Phase 37/40 security record | exact |
| `.planning/phases/44.../44-VERIFICATION.md` | phase verdict | evidence aggregation | Phase 40 verification | exact |
| `.planning/phases/44.../44-VALIDATION.md` | Nyquist ledger | command matrix | Phase 40 validation | exact |
| `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, eye/parent READMEs | promotion owners | documentation | Phase 40 five-row promotion | exact |
| root contracts and `.planning/{PROJECT,ROADMAP,REQUIREMENTS,STATE}.md`, `PLANS.md` | current contracts | documentation | Phase 37/40 owner synchronization | exact |

## Pattern Assignments

### Plan 44-01 — exact caps and exhaustive eye safety

**Runtime analogs:**

- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift`: keep static constants as the single cap owner; replace only provisional wording after tests pass.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`: use `capUnit`/`capSigned`, `capped_parameter_count`, aggregate warning, and existing complete-eye/reused/stale zeroing; do not duplicate normalization.
- `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` and `BeautyEffectResolverTests.swift`: table-driven exact caps, exact-cap no-count, overflow count, non-finite/positive-only and signed direction assertions.
- `EyeWarpProviderTests.swift`: retain direct source/direction/locality assertions and add dead-zone exactness for gaze/symmetry.
- `MissingLandmarkDegradationTests.swift` and `BeautyEngineGeometryFacadeTests.swift`: table-driven fourteen-field dependency matrix, redaction, no-face extent, and fresh/reused/stale transitions.

**Implementation shape:** mutate only safety constants/comments if needed; prefer tests as proof. Every test must read current resolver/provider fixtures first and assert effective strengths, emissions, domains, counts, warnings, metrics, and redaction together.

### Plan 44-02 — one-baseline convergence and provider equality

**Runtime analogs:**

- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` `resolveGeometryConflict`: one retained unscaled baseline, sequential eye/nose/mouth sanitization, bounded monotonic loop.
- `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift`: one private total, one scale, one weakened count; preserve signed magnitudes with `abs` only for arithmetic.
- `GeometryConflictResolverTests.swift` and `CombinedEffectSafetyTests.swift`: exact totals/counts/scales/warnings/metrics and provider-vector equality for complete and adversarial removal sets.

**Implementation shape:** create a fixture where all five face + fourteen eye + six nose + eight mouth fields emit. Assert `10.70`, `33`, `1/10.70`; then remove one provider field at a time and late fields to prove no re-add and maximum 28 removals. Do not add a second conflict path or public metric.

### Plan 44-03 — boundary, output, security, and validation gate

**Runtime/script analogs:**

- `.planning/milestones/v1.10-phases/40-mouth-geometry-safety-and-ledger-closeout/check_mouth_geometry_boundaries.py`: copy command wrapper classification, fixture-root validation, `--self-test`, default and allow-promotion modes, and artifact checks.
- `.planning/milestones/v1.9-phases/37-nose-safety-boundary-and-branch-closeout/check_nose_safety_boundaries.py`: copy owner-window/status/lifecycle checks and one-failure-per-owner fixtures.
- `.planning/phases/43.../check_eye_geometry_renderer_outputs.py`: invoke unchanged self-test/strict gate; never alter thresholds or publish files.
- `example-images/generate_gallery.py`: invoke existing gallery self-test and ignore/tracked/staged checks.

**Implementation shape:** standard-library only; classify subprocess exit 0 as matches to inspect, 1 as clean no-match, >1/missing tool as blocking. Default mode must reject promotion state; allow mode must require exactly ten row statuses and all evidence docs. ASVS L1 HIGH is blocking and `44-SECURITY.md` records `threats_open: 0` only after all checks pass.

### Plan 44-04 — atomic four-file promotion

**Documentation analogs:**

- `SHAPE_FEATURE_LEDGER.md`: exact second-level rows and independent evidence citations.
- `FEATURE_MATRIX.md`: branch-level status; retain `眼睛: partial` because `去脂`/`祛红血丝` remain future.
- `features/beauty-shaping/eyes/README.md` and parent README: branch contract and non-claims.
**Implementation shape:** read all gate artifacts first; run checker default live; apply one atomic patch touching only the four blueprint owners and promoting exactly ten rows. Immediately run live `--check-promotion`, scope scan, and `git diff --check`. Keep future retouch rows and the partial branch unchanged.

### Plan 44-05 — example and root owner synchronization

**Documentation analogs:**

- `EXAMPLE_IMAGE_VALIDATION.md`: exact 55-case/385-output current evidence and limitations.
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`: each receives only its owned invariant/evidence statement.

**Implementation shape:** update owner files in bounded groups. After each group, run live `--check-owners --owner <name>` against the actual repository; finish with aggregate `--check-owners`. Do not defer owner correctness to the final lifecycle gate.

### Plan 44-06 — planning ledger, verification, and audit handoff

**Documentation analogs:**

- `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, `PLANS.md`: phase execution/requirement mapping and conservative handoff.
- `44-VERIFICATION.md`: EYE-19..23 pass evidence and DOC-01 `pending-independent-audit` disposition.

**Implementation shape:** update registered planning state only after Plans 01..05 pass, finalize one-to-one validation, and run full live `--allow-promotion` after every owner change. Mark EYE-19..23 complete but leave DOC-01 pending until the separately owned milestone-audit workflow creates and validates its artifact. Do not claim audit, archive, tag, cleanup, shipping, or launch success.

## Shared Patterns

### Fail-closed diagnostics

**Sources:** `BeautyEffectPlan.swift`, `BeautyEngine.swift`, Phase 40/37 degradation tests. Keep warning codes/messages aggregate and fixed. Tests should assert absence of raw geometry terms rather than snapshotting internal payloads.

### Evidence-first promotion

**Sources:** Phase 40 `40-MOUTH-SAFETY-EVIDENCE.md` and Phase 37 promotion plans. Leave status owners untouched through plans 44-01..03; default checker must reject any premature status; only final plan edits status after all evidence.

### Disposable artifact containment

**Sources:** Phase 43 helper and gallery scripts. Generated PNGs may be produced locally for regression but must remain ignored, untracked, unstaged, and descriptor-safe; no binary files enter the commit.

### Atomic GSD ledger updates

Use registered `gsd-tools.cjs query roadmap/state` handlers for state/roadmap mutations. `PLANS.md` records the completed phase and evidence; no direct unsafe `STATE.md` rewrite.

## Artifacts this phase produces

- `.planning/phases/44-eye-geometry-safety-and-ledger-closeout/check_eye_geometry_boundaries.py`
- `.planning/phases/44-eye-geometry-safety-and-ledger-closeout/44-EYE-SAFETY-EVIDENCE.md`
- `.planning/phases/44-eye-geometry-safety-and-ledger-closeout/44-SECURITY.md`
- `.planning/phases/44-eye-geometry-safety-and-ledger-closeout/44-VERIFICATION.md`
- `.planning/phases/44-eye-geometry-safety-and-ledger-closeout/44-VALIDATION.md`
- Focused XCTest additions for exact caps, fourteen-field degradation/transitions, 33-field retained arithmetic, and 28-removal convergence.
- Exactly ten promoted documentation rows and synchronized current owner statements; no generated media.

## No Analog Required

No new package, public type, SwiftUI surface, Xcode project file, network client, or persistent geometry model is allowed, so no analog is needed for those categories.
