# Phase 54: Rights-Approved Evidence and Eligibility Decisions - Pattern Map

**Mapped:** 2026-07-31
**Files analyzed:** 12 new/modified files
**Analogs found:** 11 / 12

## Scope Boundary

Phase 54 is a repository-owned evaluation tool and decision record, not SDK or
Demo implementation. New executable files stay under this phase directory.
Production paths under `BeautySDK/` and `BeautyDemo/` are negative boundaries:
the checker must prove they did not gain a candidate parameter, admission,
provider, renderer case, preset key, network route, or realtime behavior.

The reusable source is Spike 006, but it is only an analog. Port it into
Phase 54 ownership and tighten it to D-01 through D-16. Do not edit or import
the packaged `.codex/skills/.../006-*` source in place.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `54-evidence-manifest.schema.json` | config / schema | file-I/O validation | `.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/fixture-manifest.schema.json` | role-match; contract must be tightened |
| `54-evidence-core.js` | service / utility | transform + request-response | `.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/review-core.js` | strong role/data-flow match; unsafe details must be replaced |
| `54-evidence-core.test.js` | test | batch mutation | `.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/test-review-core.js` | role-match; use `node:test` instead of the spike's bespoke harness |
| `54-review.html` | component / controller | event-driven + local file-I/O | `.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/review.html` | strong UI-flow match; Phase 54 UI-SPEC supersedes presentation/persistence details |
| `check_phase54_evidence_boundaries.py` | utility / policy gate | batch source/file scan | `.planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/check_still_image_foundation_boundaries.py` | exact repository checker pattern |
| `54-EVIDENCE-DECISIONS.json` | model / ledger | deterministic projection | no exact current analog | research/context-owned schema |
| `54-EVIDENCE-EVALUATION.md` | evidence record | batch report | `.planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/53-FOUNDATION-EVIDENCE.md` | role-match |
| `54-VALIDATION.md` | validation config/evidence | batch verification map | `.planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/53-VALIDATION.md` | exact workflow match |
| `.gitignore` | config | file-I/O boundary | `.gitignore` media and generated-output rules | exact shared pattern |
| `PLANS.md` | project ledger | append-only record | existing active v1.14 plan row | exact owner pattern |
| `PRODUCT_SENSE.md` / `SECURITY.md` / `RELIABILITY.md` / `QUALITY_SCORE.md` | contract docs | append-only record | existing Phase 53 owner sections | exact owner pattern |
| `ARCHITECTURE.md` / `DESIGN.md` | contract docs if needed | append-only record | existing Phase 53 owner sections | conditional role-match; only update if an enduring boundary/model contract is added |

## Pattern Assignments

### `54-evidence-manifest.schema.json` (config/schema, file-I/O validation)

**Analog:** `.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/fixture-manifest.schema.json`

Copy the small dependency-free JSON Schema shape, fixed `schema_version`, opaque
IDs, enum allowlists, and exact asset triple. Tighten it with `additionalProperties:
false` at every object, frozen one-feature bundle semantics, explicit fixture
role/status and predeclared target expectation, row-count bounds, and exact
relative asset keys. Cross-row rules still belong in `54-evidence-core.js`.

**Do not copy:** dataset identity/retention fields into the durable export,
mixed-feature acceptance, permissive unknown fields, or the idea that schema
validity alone opens a gate.

### `54-evidence-core.js` (service/utility, transform)

**Analog:** `.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/review-core.js`

**Pure module pattern** (lines 1-24, 235-243):

```javascript
(function attachReviewCore(globalObject) {
  "use strict";
  const FEATURES = new Set([
    "teeth_whitening",
    "sclera_redness",
    "upper_eyelid_fullness",
  ]);
  // ... pure functions only ...
  globalObject.ReviewCore = api;
  if (typeof module !== "undefined" && module.exports) module.exports = api;
})(typeof globalThis !== "undefined" ? globalThis : this);
```

This dual browser/Node module is the closest dependency-free pattern. Preserve
pure inputs/outputs: no DOM, filesystem, network, storage, timers, `Date`, or
process-global review state.

**Opaque input/path guards** (lines 26-43):

```javascript
function isOpaqueID(value) {
  return typeof value === "string" && /^[A-Za-z0-9_-]{1,64}$/.test(value);
}
function isSafeRelativePath(value) {
  return typeof value === "string"
    && value.length > 0
    && !value.startsWith("/")
    && !value.startsWith("\\")
    && !value.includes("..")
    && !value.includes(":")
    && !value.includes("\\")
    && !value.includes("\0");
}
```

Retain the allowlist mindset, but strengthen path validation to one exact
normalized selected-root-relative key. Reject absolute paths, traversal,
backslash, colon, NUL, duplicate normalized keys, basename collisions, and
ambiguous aliases.

**Per-row validation loop** (lines 95-147): use a `Set` for duplicate IDs,
validate every enum and rights record, and require each of `original`, `mask`,
and `after`. Return stable reason codes/counts, never raw path-bearing prose.

**Positive allowlist projection** (lines 199-220): the useful pattern is to
construct every review object field by field from validated inputs:

```javascript
return {
  fixture_id: review.fixture_id,
  feature: fixture.feature,
  polarity: fixture.polarity,
  target_present: review.target_present,
  mask_coverage: review.mask_coverage,
  protected_leakage: review.protected_leakage,
  naturalness: review.naturalness,
  structure_changed: review.structure_changed,
  decision: review.decision,
  reason_code: review.reason_code,
};
```

Never spread manifest/review objects. Add exact review-set equality, immutable
session snapshot/fingerprint semantics, threshold-consistent positive and
negative predicates, mechanics exclusion, and three independent reducers.
Upper eyelid is a two-prerequisite conjunction whose closed record retains both
`missing_genuine_positive` and `non_warp_design_unqualified`.

**Do not copy these Spike 006 behaviors:**

- Lines 45-55 add basename and suffix aliases. Phase 54 must use exact keys.
- Lines 150-159 count all fixture polarities together and allow mixed-feature
  borrowing. Phase 54 uses one-feature bundles and isolated denominators.
- Lines 188 and 222-232 accept `now`, emit `dataset_id` and `generated_at`, and
  use a broad shared summary. All timestamps, dataset/session/event data, and
  aliases are forbidden by D-08.
- Lines 170-185 check types/ranges only. A human `accept` is necessary but not
  sufficient; frozen positive/negative predicates and reason compatibility are
  authoritative.

### `54-evidence-core.test.js` (test, batch mutation)

**Analog:** `.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/test-review-core.js`

**Fixture-builder pattern** (lines 12-40): build opaque, synthetic in-memory
manifests from one helper and mutate one property per test. The spike's tests at
lines 47-78 demonstrate structural/mechanics separation, unsafe paths,
duplicate IDs, and recursive sentinel checks.

Replace the bespoke `check()` array (lines 7-11) and artifact-writing side
effect (lines 80-84) with Node's built-in `node:test` and `node:assert/strict`.
Tests must not write real media, paths, rights IDs, timestamps, or generated
artifacts. Use subtests/table cases for the complete research mutation matrix:
path variants, duplicates/collisions, every enum, each missing asset, mixed
feature, each non-product role, rights omission, frozen-session mutation,
duplicate/missing/extra review, score bounds/fractions, each failed acceptance
criterion, sibling borrowing, export forbidden sentinels, UI source tokens, and
all eyelid prerequisite combinations.

### `54-review.html` (component/controller, event-driven local file-I/O)

**Analog:** `.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/review.html`

**Local selection and static layout** (lines 1-60): retain a single static
document, native manifest file input, native `webkitdirectory` input, a dark
image-first surface, and three original/mask/after panes. Apply
`54-UI-SPEC.md` as the exact visual/copy/accessibility authority.

**Browser-mediated asset ownership:** use only selected `File` objects and
active-row `URL.createObjectURL` values. Revoke all three on navigation,
replacement, export completion, `pagehide`, and reset. Match files by one exact
normalized `webkitRelativePath`, never the Spike 006 basename/suffix aliases.

**Safe presentation:** build status items with `createElement`, `textContent`,
and `replaceChildren`; map core reason codes to fixed redacted copy. Never place
manifest values, fixture IDs, polarity, filenames, paths, rights records, or
raw exception messages in visible text, attributes, or DOM data fields.

**Do not copy:** Spike 006's default-selected judgment options, fit-only image
display, timestamped event collection, raw errors, dynamic dataset-derived
download name, or any persisted state. Phase 54 begins every control at
`请选择`, supports Fit/100% with synchronized pane scrolling, uses a fixed
`beauty-evidence-review-v1.json` filename, and clears state on reload.

### `check_phase54_evidence_boundaries.py` (utility/policy gate, batch scan)

**Analog:** `.planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/check_still_image_foundation_boundaries.py`

**Repository-root and immutable rule model** (lines 1-19, 73-78):

```python
ROOT = pathlib.Path(__file__).resolve().parents[3]

@dataclass(frozen=True)
class Rule:
    name: str
    pattern: str
    should_exist: bool
```

**Fail-closed subprocess classification** (lines 94-105):

```python
def classify_rg(returncode: int, stdout: str, stderr: str) -> str:
    if returncode == 0:
        return "match"
    if returncode == 1 and not stdout and not stderr:
        return "clean"
    raise RuntimeError(f"rg command error rc={returncode}: {stderr.strip()}")
```

This prevents an unavailable/broken scanner from being reported as clean.
Reuse direct UTF-8 parsing, exact inventories, and missing-required-file
failures from lines 119-166. Reuse explicit mutation self-tests and nonzero live
exit from lines 246-290.

Phase 54 live checks should cover:

- required phase files and exact decision-ledger shape/order;
- forbidden recursive export keys/sentinel values;
- reviewer network, external resource, storage, service-worker, clipboard,
  unsafe DOM, dynamic filename, and timestamp/event tokens;
- Git tracking/ignore status for portraits, manifests, masks, afters, local
  downloads, and review artifacts;
- exact absence of candidate fields/providers/render cases/preset keys and no
  edits/imports under `BeautyDemo/` or production SDK targets;
- exact three independent decisions and the current closed reasons;
- checker `--self-test` mutations proving scanner errors and each critical
  boundary fail closed.

Keep failures redacted. Do not include file contents or sensitive local paths in
messages.

### `54-EVIDENCE-DECISIONS.json` (model/ledger, deterministic projection)

**No exact analog found.** Build it from the Phase 54 research/context contract,
using the same field-by-field positive allowlist as the core export. Fixed
feature order is `teeth_whitening`, `sclera_redness`,
`upper_eyelid_fullness`. Current outcomes are independently closed:

- teeth: `missing_genuine_positive`;
- sclera: missing genuine positive and incomplete genuine bundle (using the
  frozen allowlisted reason spelling selected by implementation);
- upper eyelid: `missing_genuine_positive` plus
  `non_warp_design_unqualified`.

The ledger contains only schema version, fixed feature IDs, open/closed state,
allowlisted reasons, and permitted aggregate counts. It contains no reviews if
no qualified review row exists and never contains paths, media, asset names,
rights/document IDs, retention, timestamps, events, reviewers, hashes,
geometry, or prose/freeform text. Serialize with stable key order, two spaces,
LF, and one final newline.

### Evidence and validation records

**Analogs:** `53-FOUNDATION-EVIDENCE.md` and `53-VALIDATION.md`.

Follow Phase 53's validation architecture:

- declare framework/direct commands and one exact task row per real XML task;
- create RED tests/checker in Wave 0 before GREEN implementation;
- keep focused Node/checker samples per task and reserve full SwiftPM plus Demo
  regression for final closeout;
- name every Wave 0 dependency and record actual results, never inferred green;
- require OWASP ASVS Level 1 with `block_on: HIGH`; any failed or unverified
  HIGH mitigation blocks completion;
- final evidence records exact commands/counts, static browser original-detail
  smoke, privacy/scope scans, nonclaims, and closed-gate outcomes.

### Contract and ledger updates

**Analogs:** existing Phase 53 sections in root owners and the active v1.14 row
in `PLANS.md`.

- `PLANS.md`: append Phase 54 execution state/evidence to the existing active
  milestone entry; do not create a parallel plan.
- `PRODUCT_SENSE.md`: own honest evidence/gate language and downstream exact
  absence for closed candidates.
- `SECURITY.md`: own untrusted local manifest/media, ephemeral File API/object
  URL use, positive-allowlist export, no network/storage, and redacted errors.
- `RELIABILITY.md`: own fail-closed validation, deterministic stable reason
  codes, replacement/reset recovery, and exact validation commands.
- `QUALITY_SCORE.md`: own executed test/checker/UI smoke counts and explicit
  evidence/nonclaim score boundaries.
- `ARCHITECTURE.md` and `DESIGN.md`: update only if the phase-owned tool/ledger
  establishes an enduring repository boundary/model not already owned above.
  Do not describe it as an SDK target or production pipeline component.

## Shared Patterns

### Privacy by construction

**Sources:** Spike 006 core lines 199-220; `example-images/FIXTURE_AUTHORIZATION.md`
lines 1-5 and 20-23.

Only opaque IDs and aggregate structured fields cross into tracked/durable
artifacts. The authorization record explicitly excludes subject identity,
source metadata/path, bytes, geometry, and identity descriptors. Apply the same
rule to tests, checker output, UI DOM, JSON, docs, and commit messages.

### Rights approval is not polarity

**Source:** `example-images/FIXTURE_AUTHORIZATION.md` lines 25-37.

`portrait_001` has permission for internal evaluation, but contributes only
after a feature-specific predeclared polarity, complete asset triple, and
frozen review. Its already-light teeth may support a teeth negative/challenge;
it is not a discoloration positive and supplies no automatic sclera/eyelid
polarity.

### Ignored local media

**Sources:** `.gitignore` lines 7-10 and 13-27;
`example-images/README.md` lines 21-43.

Raw/derived images remain ignored and untracked. Add a narrow ignored local
Phase 54 review workspace/download rule if needed, while keeping the tool,
schema, tests, aggregate decision JSON, and evidence documents tracked. Verify
with both `git check-ignore` and `git ls-files`.

### Independent fail-closed gates

Structural validity, product eligibility, row review pass, and feature decision
are separate pure stages. A valid partial/mechanics bundle is a successful
closed result, not an exception. Invalid input disables review/export. A closed
feature neither borrows from nor blocks a sibling.

### Determinism

Sort rows and features explicitly; freeze enum/reason/threshold inventories;
avoid `Date`, locale sorting, random IDs, environment data, or dynamic download
names. Two exports of identical structured inputs must be byte-identical.

## What Not to Copy

| Source behavior | Why rejected | Replacement |
|---|---|---|
| Spike 006 `normalizeAssetPaths()` basename/suffix aliases (core lines 45-55) | Collision/wrong-file ambiguity | Exact normalized selected-root-relative key |
| Spike 006 `dataset_id`, `now`, `generated_at` (core lines 188, 222-225) | D-08 forbids dataset/session/time metadata | Stable positive-allowlist export without time/session identity |
| Spike 006 mixed global positive/negative counts (core lines 123-159) | Allows sibling evidence borrowing | One-feature bundles plus three independent reducers |
| Spike 006 type-only review validation (core lines 170-185) | Human accept could contradict frozen thresholds | Exact positive/negative pass predicates and compatible reason codes |
| Spike 006 file-writing test harness (test lines 80-84) | Creates side-effect artifact and has weak isolation | `node:test`, strict assertions, in-memory synthetic fixtures |
| Spike 006 visible paths/errors/timestamped events | Privacy leak and nondeterminism | Fixed redacted copy, ephemeral aggregate state, no events in export |
| Phase 53 production-file implementation patterns | Phase 54 must not activate SDK/Demo behavior | Use only its checker/validation/evidence workflow patterns |
| Historical/parked or mechanics fixture outcomes | They are not current product evidence | Zero denominator/weight; mechanics tests only |
| Invalidated eyelid warp or aliases to eye/brow/smoothing | Violates LID-01 and D-14 | Closed design prerequisite until a separately qualified non-warp design exists |

## Likely Task Boundaries

1. **Wave 0 — RED contracts:** add the Node mutation suite, Python checker
   self-test/live skeleton, and ignored local-review boundary. Prove expected
   failures for missing core/UI/ledger.
2. **Pure contract:** add schema and `54-evidence-core.js`; make structural,
   eligibility, frozen-review, independent-reducer, deterministic-export, and
   privacy tests green.
3. **Offline reviewer:** add `54-review.html` against `54-UI-SPEC.md`; implement
   File API validation, exact key resolution, blinded Fit/100% review, object
   URL lifecycle, redacted state, fixed export, accessibility/responsive
   contract, and static/browser smoke.
4. **Current decisions:** generate/commit the exact aggregate-only three-row
   `54-EVIDENCE-DECISIONS.json`; prove current independent closures and
   `portrait_001` non-overclaim.
5. **Closeout:** update root owners/`PLANS.md`, create evaluation evidence,
   complete `54-VALIDATION.md`, run Node/checker/JSON/JS/privacy/Git gates,
   static original-detail browser smoke, full SwiftPM and Demo regressions, and
   record ASVS L1 HIGH review.

These boundaries can be split further for context limits, but keep production
absence checks and final full regressions in the closeout task.

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| `54-EVIDENCE-DECISIONS.json` | model / ledger | deterministic projection | No prior tracked three-feature privacy-minimized eligibility ledger exists; use the locked context/research schema rather than inventing from a production feature ledger. |

## Metadata

**Analog search scope:** `.planning/phases/53-*`, `.planning/spikes/006-*`,
`.codex/skills/spike-findings-beauty/sources/006-*`, `example-images/`, root
contract documents, `.gitignore`, and production paths as negative boundaries.

**Files scanned:** 24 primary/reference files plus production absence targets.

**Pattern extraction date:** 2026-07-31
