---
phase: 54
slug: rights-approved-evidence-and-eligibility-decisions
# status lifecycle: draft (plan-phase) -> validated (Plan 54-05 after exact evidence)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-31
---

# Phase 54 — Validation Strategy

> Exact pending validation map for the five-plan, nine-task execution set. A
> deterministic closed feature gate is a successful expected result; an invalid,
> unverified, privacy-leaking, cross-feature, or scope-drifting result is not.

## Test Infrastructure

| Property | Value |
|---|---|
| Framework | Node built-in `node:test`/`node:assert/strict`, Python standard-library checker, tool-driven local browser smoke, SwiftPM/XCTest, and Xcode simulator XCTest |
| Config file | No JS/Python package config; existing `BeautySDK/Package.swift` and `BeautyDemo/BeautyDemo.xcodeproj` only |
| Fast samples | Exact task-owned Node pattern/checker mode below; each avoids full SDK/Demo regression |
| Boundary checker | `check_phase54_evidence_boundaries.py --self-test` plus exact Wave 0 `--expect-wave0-red`, `--core`, `--ui`, `--ledger`, `--owners`, `--scope`, and default live modes |
| UI equality | Exact closed inventory: **27 = 8 UI consideration truths + 19 UI acceptance criteria** |
| Final-only regression | Full SwiftPM and explicit iPhone 17e/iOS 26.5 Demo build/test run only in `54-05-01` |
| Security | OWASP ASVS Level 1, `block_on: HIGH`; canonical `54-THREAT-INVENTORY.json` derives the active HIGH denominator (currently 8); any failed/not-run/unverified HIGH row blocks its task/plan/phase |
| Diff hygiene | `git diff --check` in every GREEN task and the final gate |

## Sampling Contract

- Wave 0 creates all core/UI mutation specifications and the fail-closed checker
  before any implementation artifact.
- `54-01-01` and `54-01-02` are expected RED only because their planned core/UI
  artifacts do not exist. Syntax/harness/privacy failures are not acceptable RED.
- Plans 54-02 through 54-04 use focused Node patterns and checker modes. They do
  not run full SwiftPM or Demo build/test.
- Task `54-05-01` alone owns complete Node/checker runs, browser-control smoke,
  full SwiftPM, Demo build/test, GSD schema/UI gates, evidence capture, and
  validation promotion.
- Every task records its own actual result. A later full gate does not silently
  convert an unrun earlier row to passed.
- Sensitive manifests/media/downloads/smoke files stay under ignored
  `example-images/local-retouch-review/` and never appear in tracked evidence.
- Closed current teeth/sclera/upper-eyelid decisions are derived from the
  explicit validated inventory, not feature-specific baseline assertions or
  failure waivers. Zero eligible/review rows require both missing polarities.

## Exact Per-Task Verification Map

| Actual task ID | Plan | Wave | Plan dependency | Wave 0 dependency | Requirements | Focused sample / final-only gate | Status |
|---|---:|---:|---|---|---|---|---|
| `54-01-01` | `54-01` | 0 | `[]` | Creates core mutation suite | EVID-01..05, LID-01 | Syntax check plus exact `RED_MISSING_ARTIFACT:54-evidence-core.js` oracle; arbitrary nonzero failures are rejected | passed |
| `54-01-02` | `54-01` | 0 | `[]` | Creates UI contract suite and checker | EVID-03..05, LID-01 | Python/JS syntax, checker `--self-test` + exact `--expect-wave0-red`, and exact absent HTML/controller RED marker | passed |
| `54-02-01` | `54-02` | 1 | `[54-01]` | `54-01-01` | EVID-01, EVID-02 | Node pattern `bundle|manifest|path|identity|role|rights|eligibility|snapshot|portrait`, JS/JSON syntax, checker `--core` | passed |
| `54-02-02` | `54-02` | 1 | `[54-01]` | `54-01-01` | EVID-03..05, LID-01 | Complete `54-evidence-core.test.js`, checker `--core` | passed |
| `54-03-01` | `54-03` | 2 | `[54-02]` | `54-01-02` | EVID-01, EVID-03, EVID-04 | UI pattern `initial|local-only|redacted|blinded|detail|asset|loader|gate|comparison|empty|loading|error|populated|partial`, checker `--ui` | passed |
| `54-03-02` | `54-03` | 2 | `[54-02]` | `54-01-01`, `54-01-02` | EVID-02..05, LID-01 | Complete UI/core Node suites, checker `--ui`, exact `27 = 8 + 19` | passed |
| `54-04-01` | `54-04` | 3 | `[54-03]` | `54-01-01`, `54-01-02` | EVID-01, EVID-02, EVID-04, EVID-05, LID-01 | JSON parse, checker `--ledger`, Git ignore/untracked proof | passed |
| `54-04-02` | `54-04` | 3 | `[54-03]` | `54-01-02` | EVID-01..05, LID-01 | checker `--owners`, `--scope`, and default implementation live mode | passed |
| `54-05-01` | `54-05` | 4 | `[54-04]` | `54-01-01`, `54-01-02` | EVID-01..05, LID-01 | **FINAL ONLY:** complete Node/checker/browser/full SwiftPM/Demo/schema/UI/diff gate from `54-05-PLAN.md` | passed |

Task count equality: **9 actual XML task IDs = 9 validation rows = 2 Wave 0 + 6 focused GREEN + 1 final closeout**.

## Wave 0 Deliverables

- [x] `54-01-01` creates `54-evidence-core.test.js` with the complete path,
  identity, schema, enum, completeness, product-exclusion, frozen-review,
  independent-reducer, eyelid-conjunction, export, and privacy mutation matrix.
- [x] `54-01-02` creates `54-review.contract.test.js` and
  `check_phase54_evidence_boundaries.py`, including every network/storage/DOM,
  Git, current-ledger, production-scope, packaged-spike, owner, and scanner-error
  mutation. Its RED oracle names the absent HTML/controller pair exactly and
  rejects syntax, discovery, subprocess, scanner, or unclassified failures.
- [x] Checker self-test freezes exact UI equality **27 = 8 considerations + 19
  acceptance criteria**, rejecting missing, duplicate, extra, or reclassified IDs.
- [x] Wave 0 tests contain only opaque synthetic in-memory data and write no
  media, path, rights, reviewer, timestamp, or generated artifact.

## Requirement-to-Evidence Map

| Requirement | Exact evidence owners |
|---|---|
| EVID-01 | One-feature schema/core mutations; exact triple/key/readiness tests; current ledger; browser validation smoke |
| EVID-02 | All six non-product role/right mutations; denominator/naturalness invariance; UI/gate and ledger checks |
| EVID-03 | Frozen snapshot/review-set/predicate/reason tests; seven unselected UI fields; original-detail browser smoke |
| EVID-04 | Positive-allowlist/deterministic serializer tests; recursive forbidden key/value checker; fixed-download browser smoke |
| EVID-05 | Sibling-borrowing/isolated-reducer tests; exact three-row ledger; closed-sibling UI/export behavior |
| LID-01 | Evidence-AND-design truth table; invalidated/proxy design mutations; exact current dual-reason ledger/browser display |

## UI Contract Map

### Eight consideration truths

1. `UI-CONSIDERATION-01`: empty.
2. `UI-CONSIDERATION-02`: loading.
3. `UI-CONSIDERATION-03`: error.
4. `UI-CONSIDERATION-04`: populated.
5. `UI-CONSIDERATION-05`: partial.
6. `UI-CONSIDERATION-06`: overflow.
7. `UI-CONSIDERATION-07`: zero-one-many.
8. `UI-CONSIDERATION-08`: long-text.

### Nineteen acceptance criteria

1. `UI-AC-01`: initial boundary.
2. `UI-AC-02`: local-only operation.
3. `UI-AC-03`: redacted invalid input.
4. `UI-AC-04`: blinded display.
5. `UI-AC-05`: original detail after bounded PNG/JPEG header and pixel-budget preflight.
6. `UI-AC-06`: required judgments.
7. `UI-AC-07`: no implicit approval.
8. `UI-AC-08`: progress and navigation.
9. `UI-AC-09`: mechanics exclusion.
10. `UI-AC-10`: independent gates.
11. `UI-AC-11`: frozen acceptance.
12. `UI-AC-12`: upper-eyelid decision.
13. `UI-AC-13`: closed-result export.
14. `UI-AC-14`: determinism.
15. `UI-AC-15`: export privacy.
16. `UI-AC-16`: ephemeral media.
17. `UI-AC-17`: accessibility.
18. `UI-AC-18`: responsive behavior.
19. `UI-AC-19`: scope boundary.

Plan `54-03-PLAN.md` contains the full behavior-level mapping. Wave 0 freezes the
IDs; Plan 54-03 makes them green; Plan 54-05 records the complete static/core and
tool-driven browser results.

## Final-Only Phase Gate

Task `54-05-01` must execute and record, in order:

1. JS syntax and both JSON parse checks.
2. Complete core and UI Node suites.
3. Boundary checker `--self-test`, including all mutation groups and exact
   `27 = 8 + 19` equality.
4. Boundary checker default live mode, which includes core/UI/ledger/owner/scope,
   recursive export/privacy/source scans, Git ignore/tracking, and production/
   packaged-spike absence.
5. Tool-driven direct-`file://` browser smoke using only ignored mechanics media,
   covering all interaction, original-detail, focus, URL, export, and responsive
   requirements listed in `54-05-PLAN.md`.
6. `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-phase54-clang-module-cache swift test --package-path BeautySDK`.
7. `xcodebuild -quiet -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17e,OS=26.5' build`.
8. The same explicit destination with `test`.
9. GSD `verify.schema-drift` and `ui.safety-gate`; separately classify
   `verify.codebase-drift` and allow only the recorded historical warning.
10. `git diff --check`.
11. ASVS L1 HIGH review: all HIGH rows must have exact green evidence.
12. Create `54-EVIDENCE-EVALUATION.md`; only then promote this file and update
    PLANS.md/QUALITY_SCORE.md with actual counts.

## Forbidden Export, Source, and Privacy Scans

The checker must fail closed on:

- recursive durable keys/values for dataset/session/time/event/metadata/reviewer/
  notes/freeform, filenames/paths/directories, rights/docs/retention, media/
  original/mask/after/blob, coordinates/landmarks/pupils/descriptors/raw geometry,
  raw errors, or browser/environment metadata;
- reviewer `fetch`, XHR, WebSocket, EventSource, beacon/WebRTC, HTTP(S)/external
  resources, analytics/dependencies, storage/caches/cookies/service workers,
  clipboard/workers/form submission, unsafe DOM sinks, dynamic filenames, or
  raw input/error interpolation;
- tracked/unstaged sensitive review manifests/media/downloads/smoke artifacts;
- production/Demo candidate field, CodingKey, admission, provider, renderer,
  preset, realtime/pixel-buffer, reviewer import, or packaged Spike 006 edit;
- current ledger row/order/reason/count drift or any cross-feature aggregate;
- missing/duplicate/extra UI requirement IDs, required files, owner statements,
  or unclassified command/scanner outcomes.

Checker failures remain redacted: report fixed rule names/counts, never matched
contents or sensitive local paths.

## Manual-Only Verifications

None. The original-detail/UI smoke is tool-driven by the execution agent through
the available browser-control capability. If that capability or a required
interaction cannot run, its HIGH mitigation remains unverified and validation
must not be promoted.

## Validation Sign-Off

- [x] All nine actual task IDs have one exact map row.
- [x] Every task has an automated sample and records its own result.
- [x] Full SwiftPM and Demo build/test appear only in `54-05-01`.
- [x] Every GREEN task names its Wave 0 dependency.
- [x] Mutation coverage includes every research matrix item.
- [x] UI equality is exactly 27 = 8 + 19 with no missing/duplicate/extra row.
- [x] EVID-01..05 and LID-01 each have core, boundary, and final evidence.
- [x] Every plan declares ASVS Level 1, `block_on: HIGH`, and named mitigation commands; canonical inventory maps active T-54-01…T-54-08 with no retired/merged IDs currently recorded.
- [x] Current closed decisions are inventory-derived and record both missing polarities for zero eligible/review rows, plus the independent upper-eyelid design gap.
- [x] No sensitive local artifact, SDK/Demo behavior, or unsupported readiness claim is added.
- [x] `54-EVIDENCE-EVALUATION.md` exists before validation fields change.

**Approval:** validated by `54-EVIDENCE-EVALUATION.md`; all nine task rows and every ASVS Level 1 HIGH mitigation passed.
