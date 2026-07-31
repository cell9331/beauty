---
phase: 53
slug: canonical-still-image-contract-and-private-request-foundation
# status lifecycle: draft (seeded by plan-phase) → validated (set by final execution evidence)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-30
---

# Phase 53 — Validation Strategy

> Exact pending validation map for the six-plan, nine-task execution set.

## Test Infrastructure

| Property | Value |
|---|---|
| Framework | XCTest through Swift Package Manager (Swift tools 6.0) plus the standard-library Python boundary checker |
| Config file | `BeautySDK/Package.swift` |
| Fast sample | One task-owned filter/check below; each targets `<30s` on an incremental build |
| Final-only phase gate | `swift test --package-path BeautySDK` (approximately 180 seconds), run only by task `53-06-01` |
| Diff hygiene | `git diff --check`, mandatory in every GREEN task completion command and the final-only gate |

## Sampling Contract

- Use the exact task-owned fast sample below after the task's implementation edit; do not run the full SwiftPM suite during tasks `53-01-01` through `53-05-01`.
- Wave 0 tasks create the missing specifications/checker first. GREEN tasks name their exact Wave 0 dependency in the map.
- A task's PLAN `<verify>` may chain additional focused regressions, but the map below identifies its `<30s` feedback sample.
- Task `53-06-01` alone owns the approximately 180-second full suite, live checker, evidence capture, validation promotion, and final `git diff --check`.
- All rows remain pending until execution records actual command results. No task may be inferred green from a later task.
- Security target is OWASP ASVS Level 1 with `block_on: HIGH`; any failed or unverified HIGH mitigation blocks its task, plan, and phase completion.

## Exact Per-Task Verification Map

| Actual task ID | Plan | Wave | Plan dependency | Wave 0 dependency | Requirements | `<30s` task feedback sample / final-only gate | Status |
|---|---:|---:|---|---|---|---|---|
| `53-01-01` | `53-01` | 0 | `[]` | Creates `BeautyCanonicalStillImageTests` and checker | PATH-02, PATH-03 | `python3 .planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/check_still_image_foundation_boundaries.py --self-test` then expected-RED `swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests` | ✅ passed |
| `53-01-02` | `53-01` | 0 | `[]` | Creates `BeautyEngineLocalRetouchFoundationTests` | PATH-01, PATH-04, PATH-05 | Expected-RED `swift test --package-path BeautySDK --filter BeautyEngineLocalRetouchFoundationTests` | ✅ passed |
| `53-01-03` | `53-01` | 0 | `[]` | Creates `StillImageRequestSupportTests`; extends compatibility suites | PATH-04, PATH-06, PATH-07 | Expected-RED `swift test --package-path BeautySDK --filter StillImageRequestSupportTests`; separately sample `swift test --package-path BeautySDK --filter BeautyParametersTests` | ✅ passed |
| `53-02-01` | `53-02` | 1 | `[53-01]` | `53-01-01` | PATH-02 | `swift test --package-path BeautySDK --filter 'BeautyCanonicalStillImageTests/testCarrier' && git diff --check` | ✅ passed |
| `53-02-02` | `53-02` | 1 | `[53-01]` | `53-01-01` | PATH-02, PATH-03 | `swift test --package-path BeautySDK --filter BeautyCanonicalStillImageTests && git diff --check` | ✅ passed |
| `53-03-01` | `53-03` | 2 | `[53-02]` | `53-01-03` | PATH-04 | `swift test --package-path BeautySDK --filter StillImageRequestSupportTests && git diff --check` | ✅ passed |
| `53-04-01` | `53-04` | 3 | `[53-03]` | `53-01-02`, `53-01-03` | PATH-01, PATH-04, PATH-05 | `swift test --package-path BeautySDK --filter BeautyEngineLocalRetouchFoundationTests && git diff --check` | ✅ passed |
| `53-05-01` | `53-05` | 4 | `[53-04]` | `53-01-02`, `53-01-03` | PATH-02, PATH-06 | `swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests && git diff --check` | ✅ passed |
| `53-06-01` | `53-06` | 5 | `[53-05]` | `53-01-01`, `53-01-02`, `53-01-03` | PATH-01..PATH-07 | **FINAL ONLY:** checker self/live modes, named focused suites, `swift test --package-path BeautySDK`, then `git diff --check`, exactly as specified in `53-06-PLAN.md` | ✅ passed |

Task count equality: **9 actual XML task IDs = 9 validation rows = 3 Wave 0 + 6 GREEN/final tasks**.

## Wave 0 Deliverables

- [x] `53-01-01` creates `BeautySDK/Tests/BeautyCoreTests/BeautyCanonicalStillImageTests.swift` plus `check_still_image_foundation_boundaries.py`, including `PATH02-UNCLASSIFIED`, `PATH03-UNCLASSIFIED`, and the exact edge manifest.
- [x] `53-01-02` creates `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift` for public-facade admission, exact order/counts, safe continuation, and pixel-buffer isolation.
- [x] `53-01-03` creates `BeautySDK/Tests/BeautyDetectionTests/StillImageRequestSupportTests.swift` and extends exact 59-field/five-preset/no-candidate/no-local compatibility coverage.
- [x] Edge manifest equality is exact: **16 = 13 automated + 3 flagged assumptions**; flagged IDs are `PATH01-CONCURRENCY`, `PATH04-CONCURRENCY`, and `PATH05-CONCURRENCY`.

## Final-Only Phase Gate

Task `53-06-01` must run, record, and keep green in this order:

1. Boundary checker `--self-test`, including the exact 16-row equality and mutation cases.
2. Boundary checker live mode over active source.
3. Named Phase 53 focused suites and compatibility regressions.
4. `swift test --package-path BeautySDK` — the only full-suite invocation in the plan set.
5. `git diff --check`.
6. ASVS Level 1 HIGH mitigation review: every HIGH row verified by its named command; any failed/unverified row blocks validation promotion.
7. Create `53-FOUNDATION-EVIDENCE.md`, then and only then set `status: validated`, `nyquist_compliant: true`, and `wave_0_complete: true`.

## Manual-Only Verifications

None. Rights-approved original-detail naturalness review belongs to Phase 54 and later visible-feature phases, not this foundation phase.

## Actual Final Evidence

- Checker self-test: 6/6, including exact `16 = 13 automated + 3 flagged`.
- Checker live mode: passed.
- Named foundation/compatibility suites: 83/83, zero failures/skips.
- Inactive renderer compatibility: 18/18, zero failures/skips.
- Full SwiftPM: 495 tests, six documented opt-in integration skips, zero failures.
- All ASVS Level 1 HIGH mitigations: verified; none failed, skipped, or not run.
- Detailed commands, skip names, compatibility hashes, threat evidence, edge rows, and nonclaims: `53-FOUNDATION-EVIDENCE.md`.

## Validation Sign-Off

- [x] All nine actual XML task IDs have one map row with real plan/wave/dependency data.
- [x] Every task has an automated sample; tasks `53-01-01` through `53-05-01` target `<30s` feedback.
- [x] Full SwiftPM appears only in final task `53-06-01`.
- [x] Every Wave 0 consumer names its dependency.
- [x] Exact edge equality is 16 = 13 automated + 3 flagged; no missing/duplicate/extra ID.
- [x] Every plan states OWASP ASVS Level 1, `block_on: HIGH`, named mitigation verification, and completion prohibition for failed/unverified HIGH items.
- [x] Final-only command includes `git diff --check`.
- [x] Every status is promoted only after exact execution evidence exists.

**Approval:** validated
