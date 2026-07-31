# Phase 54: Rights-Approved Evidence and Eligibility Decisions - Research

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Evidence bundle completeness

- **D-01:** A feature gate can open only when one feature-specific local bundle
  contains at least one genuine positive and one genuine negative, every
  included fixture is `approved_internal_evaluation`, polarity was declared
  before review, and every fixture has complete original/mask/after assets.
- **D-02:** Bundle validation is fail-closed for absolute/traversal paths,
  duplicate or non-opaque IDs, unsupported enums, incomplete asset triples,
  missing rights records, mixed features, or missing positive/negative
  coverage. A structurally valid partial bundle remains visibly closed.
- **D-03:** `mechanics_only`, synthetic, AI-generated, disabled, parked, or
  historically authorized fixtures may exercise deterministic schema, safety,
  and reviewer mechanics but contribute zero rows and zero weight to
  product-effectiveness or naturalness aggregates.
- **D-04:** `portrait_001` is a real rights-approved fixture. It may contribute
  as an already-light-teeth/over-whitening negative only after a complete
  teeth-specific asset triple and frozen review pass. It is not a genuine
  discoloration positive and has no automatic sclera or upper-eyelid polarity.
  Even a qualified teeth-negative row cannot open the teeth gate without an
  independent genuine positive.

### Frozen blinded review

- **D-05:** Freeze the review schema and pass rules before opening any outcome.
  Each row records only target presence, mask coverage on the fixed 1–5 scale,
  protected leakage, naturalness on the fixed 1–5 scale, structure change,
  accept/reject, and one allowlisted reason code.
- **D-06:** An accepted positive must have the target present, mask coverage at
  least 4, no protected leakage, naturalness at least 4, no structure change,
  and an accept decision. An accepted negative must have its predeclared target
  absence/challenge confirmed and show no protected leakage, no structure
  change, naturalness at least 4, and an accept decision. Every selected
  genuine row must pass; post-hoc threshold changes are forbidden.
- **D-07:** Review remains browser-local, static, single-reviewer, and
  original-detail. It uses local File API object URLs only—no server, upload,
  fetch, XHR, WebSocket, beacon, analytics, or external dependency.
- **D-08:** Durable export contains only opaque fixture/feature/polarity IDs,
  the fixed structured judgments, decision, allowlisted reason code, and
  per-feature aggregates. It excludes media, filenames, filesystem paths,
  rights/documentation IDs, retention text, raw geometry or masks, reviewer
  identity, timestamps, and freeform text. Sensitive media and intermediate
  events remain local, ignored, and ephemeral.

### Independent feature decisions

- **D-09:** Teeth, sclera, and upper-eyelid decisions use separate bundle
  inventories, denominators, reason codes, and gate records. A sibling cannot
  borrow evidence, and one closed gate cannot block another feature's decision.
- **D-10:** The teeth gate closes in the current inventory because there is no
  genuine discoloration positive with a complete approved asset triple. The
  fixed reason code must distinguish the missing positive from containment or
  naturalness failure.
- **D-11:** The sclera gate closes independently because there is no genuine
  redness positive and no complete approved positive/negative bundle.
  Mechanics/jitter evidence remains excluded from product aggregates.
- **D-12:** Closed decisions are inputs—not blockers—to Phases 55–58. Downstream
  phases must preserve exact absence for closed features: no public parameter,
  admission, provider, renderer case, preset key, inert route, or promotion.

### Upper-eyelid design qualification

- **D-13:** `去脂` requires two independent prerequisites: a complete genuine
  upper-eyelid-fullness positive/negative bundle and a credible non-warp design.
  Either missing prerequisite deterministically closes the gate.
- **D-14:** The tested interior vertical warp remains invalidated and cannot be
  reconsidered, renamed, or proxied through eye/brow geometry. `eyeHeight`,
  `upperEyelidLift`, brow translation, aperture change, global smoothing,
  dark-circle work, and eye-bag work are explicit non-substitutes.
- **D-15:** The tone/frequency experiment remains partial: it preserved texture
  in mechanics fixtures but did not prove the intended fullness semantic on a
  genuine positive. It therefore does not yet qualify as the independent
  non-warp design required by LID-01.
- **D-16:** The current `去脂` decision closes for both missing genuine evidence
  and unqualified non-warp design. Phase 54 records both fixed reason codes;
  Phase 57 must keep `upperEyelidFullnessReduction` absent, `去脂` future, and
  branch `眼睛` partial unless a separately approved future phase reopens both
  prerequisites.

### the agent's Discretion

- Choose the smallest repository-native implementation shape for the pure
  validator, fixed enums, deterministic tests, local review shell, and aggregate
  decision ledger.
- Choose opaque identifier spellings and fixed reason-code names, provided they
  are stable, allowlisted, feature-specific, and contain no sensitive payload.
- Reuse Spike 006 assets or port their pure core where that reduces duplication;
  do not mutate the packaged spike source into the production contract.

### Deferred Ideas (OUT OF SCOPE)

- Acquiring additional rights-approved genuine positive/negative media is a
  separate evidence-acquisition activity. Phase 54 records current absence
  honestly and must not block waiting for it.
- Inter-rater reliability, demographic/statistical sufficiency, device
  calibration, commercial naturalness, and shared review infrastructure require
  separately approved evaluation work.
- Original-pixel composition belongs to Phase 55; visible teeth, sclera, and
  upper-eyelid implementation belongs to Phases 56–57; combined promotion and
  milestone closeout belong to Phase 58.
</user_constraints>

**Researched:** 2026-07-31  
**Domain:** Offline rights-gated evidence validation, blinded local review, and deterministic feature eligibility  
**Confidence:** HIGH

## Summary

Phase 54 should port—not edit or import in place—the Spike 006 pure JavaScript
core into a phase-owned, dependency-free evidence contract. The port should
retain the proven browser-local File API shape while correcting the gaps between
the spike and the locked Phase 54 contract: one manifest must contain one
feature only; product rows must be genuine and currently approved; polarity and
expected target state must be snapshotted before review; every selected row must
have an exact original/mask/after triple and exactly one valid review; and the
three feature decisions must be computed independently. [VERIFIED:
`.planning/phases/54-rights-approved-evidence-and-eligibility-decisions/54-CONTEXT.md`;
`.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/review-core.js`]

The most important porting correction is export-by-construction. Spike 006
currently emits `generated_at`, accepts a `now` value, copies `dataset_id`, and
the HTML appends timestamped events; all of those violate D-08 and must be
absent from the Phase 54 durable artifact. The current spike also accepts
basename/suffix aliases for selected files and does not prove exact review-set
completeness, feature-local positive/negative coverage, frozen polarity, or
threshold-consistent accept decisions. [VERIFIED:
`.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/review-core.js`;
`.codex/skills/spike-findings-beauty/sources/006-licensed-fixture-review-gate/review.html`;
`54-CONTEXT.md` D-02/D-05/D-06/D-08/D-09]

The correct current outcome is three independent closed records. Teeth closes
for missing genuine discoloration-positive evidence; sclera closes for missing
genuine redness-positive evidence and an incomplete genuine bundle; and
upper-eyelid closes for both missing genuine evidence and an unqualified
non-warp design. These are successful, consumable Phase 54 outputs, not
execution blockers, and they authorize no SDK or Demo change. [VERIFIED:
`54-CONTEXT.md` D-10/D-11/D-12/D-16]

**Primary recommendation:** implement one phase-owned pure validation/review
module, one static local reviewer, one adversarial boundary checker, and one
tracked aggregate-only three-row decision artifact; keep all manifests and
media session-local and ignored. [VERIFIED: `54-CONTEXT.md` D-07/D-08/D-09 and
the agent's Discretion]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
| --- | --- | --- | --- |
| Manifest/schema validation | Phase-owned local tooling core | Static browser UI | The pure core owns enums, structure, path-key rules, bundle completeness, and eligibility; the UI only presents results. [VERIFIED: `54-CONTEXT.md` D-01/D-02] |
| Rights/current-inventory admission | Phase-owned local tooling core | Local ignored manifest | Rights IDs and paths are sensitive session inputs; only the core may use them to select genuine current rows. [VERIFIED: `54-CONTEXT.md` D-03/D-08] |
| Blinded original-detail review | Browser/client | Phase-owned local tooling core | The browser owns local file selection, image display, controls, and object URLs; the core validates and freezes judgments. [CITED: https://www.w3.org/TR/FileAPI/] |
| Product eligibility decision | Phase-owned local tooling core | Tracked decision ledger | Gate calculation is deterministic and feature-local; the ledger is an aggregate-only projection. [VERIFIED: `54-CONTEXT.md` D-06/D-09] |
| Durable evidence export | Phase-owned local tooling core | Browser download action | The core constructs an explicit allowlisted object; the browser only downloads a fixed filename. [VERIFIED: `54-CONTEXT.md` D-08] |
| Sensitive media lifecycle | Browser/client memory | Git ignore boundary | File objects, object URLs, images, masks, and transient events remain local and ephemeral. [VERIFIED: `SECURITY.md` §§1–2; `54-CONTEXT.md` D-07/D-08] |
| SDK/product behavior | No Phase 54 owner | — | `BeautySDK`, renderer, Demo, realtime, and pixel-buffer paths are intentionally untouched. [VERIFIED: `54-CONTEXT.md` Phase Boundary/D-12] |

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
| --- | --- | --- |
| EVID-01 | Each visible feature has its own opaque, rights-approved local evaluation bundle containing at least one genuine positive and one negative with complete original/mask/after assets and predeclared polarity. | One-feature manifests, immutable pre-review snapshots, exact asset-key matching, and independent positive/negative counts. [VERIFIED: `.planning/REQUIREMENTS.md`] |
| EVID-02 | Mechanics-only or synthetic fixtures are excluded from product-effectiveness and naturalness aggregates even when they remain eligible for deterministic safety tests. | Separate non-product validation mode; product row selection admits only current genuine approved rows and exports zero mechanics rows. [VERIFIED: `.planning/REQUIREMENTS.md`; `54-CONTEXT.md` D-03] |
| EVID-03 | Review criteria are frozen before a blinded local original-detail review records structured target presence, mask coverage, protected leakage, naturalness, structure change, decision, and fixed reason code. | Frozen session snapshot, explicit no-default controls, deterministic row-pass predicate, reason compatibility checks, and 100% detail view. [VERIFIED: `.planning/REQUIREMENTS.md`; `54-CONTEXT.md` D-05/D-06] |
| EVID-04 | Persistent review export contains only opaque fixture/feature/polarity identifiers, structured judgments, decisions, and aggregates; it contains no media, paths, rights records, raw geometry, masks, or freeform reviewer text. | Positive allowlist serializer plus exact forbidden-key/value tests; no timestamp, dataset ID, event list, source filename, or dynamic download filename. [VERIFIED: `.planning/REQUIREMENTS.md`; `54-CONTEXT.md` D-08] |
| EVID-05 | Failure to acquire or validate a feature's positive/negative bundle closes only that feature's product gate and does not block an independently qualified sibling. | Three isolated gate evaluations and mutation tests forbidding cross-feature borrowing or denominator sharing. [VERIFIED: `.planning/REQUIREMENTS.md`; `54-CONTEXT.md` D-09] |
| LID-01 | The milestone records a deterministic go/no-go decision for `去脂` only after a complete rights-approved genuine upper-eyelid-fullness positive/negative bundle and a credible independent non-warp design are reviewed. | Two-input conjunction with two independently retained closure reasons; invalidated warp and partial tone experiment cannot satisfy design qualification. [VERIFIED: `.planning/REQUIREMENTS.md`; `54-CONTEXT.md` D-13–D-16] |
</phase_requirements>

## Project Constraints (from AGENTS.md)

- Read `AGENTS.md`, then `PLANS.md`, then the owning specialist documents and
  relevant code/tests before editing. [VERIFIED: `AGENTS.md` §§2,6]
- Treat code and tests as higher authority than `PLANS.md`, specialist docs,
  and historical `docs/` material, in that order. [VERIFIED: `AGENTS.md` §2]
- Keep the change focused, preserve unrelated local work, run the narrowest
  meaningful verification, and record what changed, why, and how it was
  verified. [VERIFIED: `AGENTS.md` §§1,6,7]
- Update `PLANS.md` and the single root contract owner when implementation
  changes a durable architecture, design, security, reliability, product, or
  quality boundary; do not duplicate the same fact across owners. [VERIFIED:
  `AGENTS.md` §§4,6,7]
- Do not expand scope to production SDK, Demo, realtime, or visible effects;
  record unrelated discoveries as technical debt instead. [VERIFIED:
  `AGENTS.md` §7; `54-CONTEXT.md` Phase Boundary]
- For local-retouch planning and implementation, apply the
  `spike-findings-beauty` requirements: still-image-only scope, genuine licensed
  evidence, request/session-local sensitive data, and fail-closed behavior.
  [VERIFIED: `.codex/skills/spike-findings-beauty/SKILL.md`]
- If Xcode verification is required, discover the installed scheme/simulator
  and use an explicit iOS Simulator destination; never report a failed or
  unrun build as passed. [VERIFIED: `AGENTS.md` §8]

## Standard Stack

### Core

| Library/API | Version | Purpose | Why Standard Here |
| --- | --- | --- | --- |
| HTML + CSS + ECMAScript | Browser-native | Static review shell and structured controls | Locked no-server/no-dependency client tier; the existing spike proves the shape. [VERIFIED: `54-CONTEXT.md` D-07; Spike 006 `review.html`] |
| W3C File API (`File`, `Blob`, object URLs) | Current browser implementation | User-mediated local manifest/media access and ephemeral image URLs | The File API defines programmatic access to user-selected files and blob URLs without requiring a server. [CITED: https://www.w3.org/TR/FileAPI/] |
| `<input type="file" webkitdirectory multiple>` | Current supported browser implementation | Select one local bundle directory | `webkitdirectory` exposes the selected directory hierarchy through file-relative paths; compatibility must be smoke-tested on the chosen local browser. [CITED: https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement/webkitdirectory] |
| Node.js built-ins (`node:test`, `assert`) | Local v26.0.0 | Deterministic pure-core and mutation tests | Node is installed and no package is needed. [VERIFIED: local `node --version`] |
| Python standard library | Local 3.9.6 | Fail-closed source/privacy/boundary checker | Python is installed and phase checkers are an established repository pattern. [VERIFIED: local `python3 --version`; Phase 53 `check_still_image_foundation_boundaries.py`] |
| JSON Schema draft 2020-12 document | Schema version frozen by Phase 54 | Declarative exact object/enums/additional-property contract | Spike 006 already uses this draft; cross-row and inventory semantics still belong in the pure core. [VERIFIED: Spike 006 `fixture-manifest.schema.json`] |

### Supporting

| API/Tool | Version | Purpose | When to Use |
| --- | --- | --- | --- |
| `URL.createObjectURL` / `URL.revokeObjectURL` | File API | Display selected images without copying them into tracked storage | Create only for the active row and revoke after the pane is replaced or the session ends. [CITED: https://developer.mozilla.org/en-US/docs/Web/API/URL/revokeObjectURL_static] |
| `JSON.parse` / explicit object construction / `JSON.stringify` | ECMAScript built-in | Parse local manifest and emit a deterministic allowlisted artifact | Construct the export from named fields; never clone/filter the input manifest. [VERIFIED: `54-CONTEXT.md` D-08] |
| `git check-ignore`, `git ls-files`, `git diff --check` | Repository tooling | Prove media stays ignored/untracked and textual changes are hygienic | Run per task and at the phase gate. [VERIFIED: `example-images/README.md`; `QUALITY_SCORE.md`] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
| --- | --- | --- |
| Static browser-local reviewer | Local HTTP review server | Rejected because it adds a service, port, transfer, and retention boundary forbidden by D-07. [VERIFIED: Spike 006 `README.md`; `54-CONTEXT.md` D-07] |
| Static browser-local reviewer | Native macOS reviewer | Deferred because it adds build/distribution scope without improving the Phase 54 decision contract. [VERIFIED: Spike 006 `README.md`] |
| Dependency-free pure validator | Third-party schema/UI package | Rejected for this phase because the repository already has a tested pure core and D-07 forbids external dependencies for the reviewer. [VERIFIED: `54-CONTEXT.md` D-07 and the agent's Discretion] |

**Installation:** none. Phase 54 should add no npm, SwiftPM, Python, CDN, font,
analytics, or browser extension dependency. [VERIFIED: `54-CONTEXT.md` D-07]

## Package Legitimacy Audit

Not applicable: this phase installs no external package. No package checkpoint
or registry lookup is required. [VERIFIED: `54-CONTEXT.md` D-07]

## Architecture Patterns

### System Architecture Diagram

```text
User selects local manifest + one local asset directory
                         |
                         v
              [bounded parse / exact schema]
                         |
             +-----------+-----------+
             | invalid               | structurally valid
             v                       v
      [closed, redacted errors] [one-feature inventory classifier]
                                     |
                     +---------------+----------------+
                     | mechanics/non-current          | genuine current approved
                     v                                v
              [tooling-only; zero rows]     [exact original/mask/after lookup]
                                                      |
                                                      v
                                           [immutable review snapshot]
                                                      |
                                                      v
                File objects -> object URLs -> [blinded 100% review UI]
                                                      |
                                                      v
                                         [structured review validation]
                                                      |
                                                      v
                                      [feature-local row pass predicate]
                                                      |
                           +--------------------------+------------------+
                           | teeth                    | sclera           | eyelid
                           v                          v                  v
                    [independent gate]        [independent gate] [evidence AND
                                                                     design gate]
                           \__________________________|__________________/
                                                      |
                                                      v
                         [explicit allowlist projection; no session metadata]
                                                      |
                                                      v
                      tracked aggregate decision JSON + optional local download
```

The diagram has no edge into `BeautySDK`, `BeautyDemo`, a renderer, a server, or
a network boundary. [VERIFIED: `54-CONTEXT.md` Phase Boundary/D-12]

### Recommended Project Structure

```text
.planning/phases/54-rights-approved-evidence-and-eligibility-decisions/
├── 54-evidence-manifest.schema.json       # phase-owned local-input contract
├── 54-evidence-core.js                    # pure validation/review/gate/export logic
├── 54-review.html                         # static offline reviewer
├── 54-evidence-core.test.js               # built-in Node test + mutation matrix
├── check_phase54_evidence_boundaries.py   # privacy/scope/source checker
└── 54-EVIDENCE-DECISIONS.json             # tracked aggregate-only 3-row output

example-images/local-retouch-review/        # ignored local manifests/media/session artifacts
```

The phase-owned files should port selected behavior from Spike 006 without
modifying `.codex/skills/spike-findings-beauty/sources/`. The local review
directory needs an explicit directory-level ignore rule because global binary
ignores do not cover a sensitive local JSON manifest containing paths and
rights IDs. [VERIFIED: `.gitignore`; `54-CONTEXT.md` D-08]

### Pattern 1: Separate Structural Validity, Product Eligibility, and Review Pass

**What:** return three distinct concepts:

1. `structurallyValid` — exact schema/enums/IDs/path keys are safe;
2. `productBundleReady` — exactly one feature has current genuine approved
   positive and negative rows with complete triples;
3. `featureDecision` — every selected row passes the frozen review predicate,
   and eyelid additionally has a qualified non-warp design.

This lets a mechanics-only or incomplete manifest be valid enough to exercise
the tool while keeping the product gate visibly closed. [VERIFIED:
`54-CONTEXT.md` D-02/D-03/D-13]

**When to use:** every load, asset-directory change, review save, export, and
decision-ledger build. Recompute from the immutable snapshot rather than
retaining a mutable `gateOpen` flag. [VERIFIED: `54-CONTEXT.md` D-06/D-09]

### Pattern 2: Freeze the Selected Bundle Before Review

**What:** validate, canonicalize, copy, sort, and freeze the selected product
rows before showing outcome images. Include a local-only
`expected_target_present` boolean in the manifest snapshot so a negative's
predeclared absence/challenge expectation can be checked without adding a
review field or durable export field. Reloading a manifest or asset directory
must discard all reviews and object URLs. [VERIFIED: `54-CONTEXT.md` D-05/D-06]

**When to use:** the transition from bundle validation to item 1. Do not read
polarity, asset paths, or rights state from a mutable manifest during export.

### Pattern 3: Exact Asset Keys, Never Basename Aliases

**What:** derive one normalized selected-root-relative key from
`File.webkitRelativePath`, reject empty/dot/dot-dot/backslash/absolute/colon/NUL
segments, reject duplicate normalized keys, and require exact equality with the
manifest asset key. Do not add basename or suffix aliases. [VERIFIED: Spike 006
currently adds basename/suffix aliases in `normalizeAssetPaths` and
`assetCandidates`; D-02 requires fail-closed path handling]

**When to use:** while indexing the user-selected directory, before any object
URL is created. The manifest `accept` attribute or MIME string is only a hint;
the validator must enforce extension/type/size bounds itself. [CITED:
https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html]

### Pattern 4: Export by Positive Allowlist

**What:** construct each durable row and aggregate from named permitted fields.
Do not spread, clone, recursively scrub, or serialize the manifest, session,
events, `File`, errors, or review-form object. The top-level artifact should
contain only schema version, fixed feature records, sanitized reviews if any,
and feature-local counts/decision/reason codes. [VERIFIED: `54-CONTEXT.md`
D-08/D-09]

**When to use:** both browser download and tracked
`54-EVIDENCE-DECISIONS.json`. Serialize the same pure-core result to avoid two
privacy contracts.

### Pattern 5: Independent Gate Reducers

**What:** evaluate each feature from a separately validated one-feature bundle,
separate selected-row set, separate denominator, separate review array, and
separate fixed gate reasons. Never compute a milestone-wide positive or
negative count. The upper-eyelid reducer is:

```text
open = evidenceBundlePassed AND nonWarpDesignQualified
```

and retains both closure reasons when both inputs are false. [VERIFIED:
`54-CONTEXT.md` D-09/D-13/D-16]

**When to use:** decision generation and all mutations involving sibling rows.

### Pattern 6: Ephemeral Browser Resource Ownership

**What:** hold selected `File` objects, reviews-in-progress, transient errors,
and optional aggregate events only in memory. Create object URLs for the active
original/mask/after panes, revoke replaced URLs, and revoke all URLs on reload,
reset, and page unload. Do not use `localStorage`, IndexedDB, service workers,
Cache API, cookies, session restore, or filename-derived download names.
[VERIFIED: `54-CONTEXT.md` D-07/D-08; W3C File API lifecycle is documented at
https://www.w3.org/TR/FileAPI/]

**When to use:** all UI transitions. Image load/decode failure must keep the
row unreviewable and the gate closed.

### Component Responsibilities

| Component | Owns | Must Not Own |
| --- | --- | --- |
| `54-evidence-core.js` | enums, exact validation, immutable snapshots, row predicates, feature reducers, allowlist export | DOM, file reads, network, persistence, product SDK behavior |
| `54-review.html` | local file selection, 100% image inspection, explicit form state, redacted status, object-URL cleanup, fixed-name download | eligibility policy, mutable thresholds, path/name display, `innerHTML`, storage, network |
| `54-evidence-core.test.js` | clean and adversarial fixtures, mutation matrix, exact export shape | real media or rights IDs |
| `check_phase54_evidence_boundaries.py` | forbidden source/API tokens, exact artifact shape, allowed-path/source drift, Git media policy, mutation self-test | image processing or product eligibility logic |
| `54-EVIDENCE-DECISIONS.json` | three fixed feature records, fixed decisions/reasons, permitted aggregate counts | paths, media, rights/docs IDs, timestamps, events, reviewers, hashes, geometry, freeform |

### Anti-Patterns to Avoid

- **One milestone-wide gate:** it allows a teeth positive and sclera negative to
  satisfy shared counts. Validate one feature per bundle and reducer.
  [VERIFIED: `54-CONTEXT.md` D-02/D-09]
- **Mutable review manifest:** it permits post-review polarity, path, or rights
  changes. Snapshot and freeze before item 1. [VERIFIED: `54-CONTEXT.md` D-06]
- **Trusting the human `accept` value:** an accept that contradicts coverage,
  naturalness, leakage, target, or structure fields must be invalid, not a pass.
  [VERIFIED: `54-CONTEXT.md` D-06]
- **Sanitizing after serialization:** denylist removal is fragile. Construct
  the permitted artifact from named fields. [VERIFIED: `54-CONTEXT.md` D-08]
- **Original-detail in name only:** `object-fit: contain` without a real 100%
  pixel mode cannot establish original-detail inspection. [VERIFIED: Spike 006
  `review.html`; `54-CONTEXT.md` D-07]
- **Feature admission as a side effect:** Phase 54 writes gate decisions only;
  it must not add public fields, providers, renderer cases, or inert routes.
  [VERIFIED: `54-CONTEXT.md` D-12]

## Fixed Contract Recommendations

### Manifest-local enums

Use one `feature` per manifest:
`teeth_whitening`, `sclera_redness`, or `upper_eyelid_fullness`. Use
`positive`/`negative` polarity, `approved_internal_evaluation`/
`mechanics_only`/`rejected` rights status, and a separate local-only
`evidence_role` allowlist that can explicitly classify
`genuine_candidate`, `synthetic`, `ai_generated`, `disabled`, `parked`, and
`historical`. Only `genuine_candidate` plus current
`approved_internal_evaluation` can enter product rows. [VERIFIED:
`54-CONTEXT.md` D-01/D-03]

Use opaque IDs matching `^[A-Za-z0-9_-]{1,64}$`. Retain rights/documentation
IDs and asset paths only in the ignored local manifest; do not project them.
[VERIFIED: Spike 006 schema; `54-CONTEXT.md` D-08]

### Review reason codes

Keep review reasons separate from gate reasons. Accepted rows require `none`.
Rejected rows require exactly one feature-prefixed code compatible with the
structured failure, for example:

```text
<feature>_target_mismatch
<feature>_mask_coverage_below_4
<feature>_protected_leakage
<feature>_naturalness_below_4
<feature>_structure_change
<feature>_unsupported_input
```

This prevents `missing_positive` (a bundle problem) from being confused with
`protected_leakage` (a reviewed-row problem). [VERIFIED: `54-CONTEXT.md`
D-05/D-10]

### Gate reason codes

Use a sorted allowlisted array because D-16 requires retaining two simultaneous
upper-eyelid closure causes:

```text
teeth_missing_genuine_positive
teeth_missing_genuine_negative
teeth_incomplete_bundle
teeth_review_rejected
sclera_missing_genuine_positive
sclera_missing_genuine_negative
sclera_incomplete_bundle
sclera_review_rejected
upper_eyelid_missing_genuine_positive
upper_eyelid_missing_genuine_negative
upper_eyelid_incomplete_bundle
upper_eyelid_review_rejected
upper_eyelid_nonwarp_design_unqualified
```

The reducer should emit the full applicable set in stable lexical or declared
enum order; downstream plans consume only the feature's `open`/`closed`
decision and reasons. [VERIFIED: `54-CONTEXT.md` D-09/D-10/D-11/D-16]

### Deterministic row rules

- Positive pass: expected target is present, observed target is present,
  coverage `>= 4`, leakage is false, naturalness `>= 4`, structure change is
  false, decision is `accept`, reason is `none`. [VERIFIED: `54-CONTEXT.md`
  D-06]
- Negative pass: observed target equals the predeclared local expected target
  state, leakage is false, naturalness `>= 4`, structure change is false,
  decision is `accept`, reason is `none`; coverage remains a recorded 1–5
  judgment but has no positive threshold. [VERIFIED: `54-CONTEXT.md` D-05/D-06]
- Bundle pass: every selected genuine row passes; one accepted positive and one
  accepted negative are required; any missing/duplicate/unreviewed selected row
  closes the feature. [VERIFIED: `54-CONTEXT.md` D-01/D-06]

### Current three-row output

| Feature | Current Decision | Required Current Reason Evidence |
| --- | --- | --- |
| `teeth_whitening` | `closed` | Must include `teeth_missing_genuine_positive`; `portrait_001` cannot count as a positive and cannot count as an accepted negative until its complete teeth triple and review pass exist. [VERIFIED: `54-CONTEXT.md` D-04/D-10] |
| `sclera_redness` | `closed` | Must include `sclera_missing_genuine_positive` and `sclera_incomplete_bundle`; mechanics/jitter rows contribute zero product rows. [VERIFIED: `54-CONTEXT.md` D-11] |
| `upper_eyelid_fullness` | `closed` | Must include evidence-closure reason(s) plus `upper_eyelid_nonwarp_design_unqualified`. [VERIFIED: `54-CONTEXT.md` D-13–D-16] |

The implementation should derive any additional applicable missing-negative or
incomplete-row reasons from the validated current inventory rather than
hard-coding counts. [VERIFIED: `54-CONTEXT.md` D-02/D-09]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
| --- | --- | --- | --- |
| Local transfer | Local HTTP server, upload API, WebSocket, or beacon | Native file inputs, `File.text()`, and object URLs | A server would create a forbidden transfer and retention boundary. [VERIFIED: `54-CONTEXT.md` D-07] |
| Browser persistence | Custom autosave, local database, service worker, cache | In-memory session plus explicit sanitized download | Browser storage would persist sensitive session state outside the frozen durable contract. [VERIFIED: `54-CONTEXT.md` D-08] |
| HTML sanitization | Regex-based HTML escaping | `textContent`, `value`, and created text nodes only | OWASP identifies `textContent` as a safe sink and recommends removing unsafe `innerHTML` use. [CITED: https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html] |
| Generic filesystem resolver | Basename guessing, suffix matching, `..` cleanup | Exact selected-root-relative key validation | Ambiguous filenames and traversal strings must fail, not be repaired. [CITED: https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html] |
| Eligibility via UI state | Mutable `gateOpen` flag or disabled-button count | Pure reducer from immutable bundle + exact review set | UI state does not prove policy or review completeness. [VERIFIED: Spike 006 core/HTML gap; `54-CONTEXT.md` D-06] |
| Timestamp/audit stream | Custom event persistence | Aggregate counts only in the allowed artifact | Timestamps and intermediate events are expressly excluded. [VERIFIED: `54-CONTEXT.md` D-08] |
| Cryptographic attestation | Hashing media/manifests into the durable export | Repository decisions + exact structured contract | Hashes are unnecessary for the current local single-reviewer decision and can become stable sensitive correlators. [VERIFIED: `SECURITY.md` data-minimization posture; `54-CONTEXT.md` D-08] |

**Key insight:** the difficult part is not displaying three images; it is
maintaining a one-way projection from a sensitive, mutable local session into a
small deterministic artifact whose fields cannot grow accidentally. [VERIFIED:
`54-CONTEXT.md` D-05–D-09]

## Common Pitfalls

### Pitfall 1: Porting Spike 006's Timestamped Export

**What goes wrong:** `buildSanitizedExport` emits `generated_at`, accepts
`now`, and the HTML later appends timestamped `events`.  
**Why it happens:** the spike allowed ephemeral observability fields that Phase
54 explicitly forbids durably.  
**How to avoid:** remove the `now` parameter, `generated_at`, `events`, and
timestamp creation from every export path; test exact top-level and nested key
sets.  
**Warning signs:** `Date`, `now`, `timestamp`, `generated_at`, `events`, or
`toISOString` in export/runtime source. [VERIFIED: Spike 006
`review-core.js`/`review.html`; `54-CONTEXT.md` D-08]

### Pitfall 2: Cross-Feature Evidence Borrowing

**What goes wrong:** an approved positive from one feature and a negative from
another open a shared gate.  
**Why it happens:** Spike 006 counts polarity across the whole manifest and
does not reject mixed features.  
**How to avoid:** reject mixed-feature bundles and run one reducer per feature.
Add mutations that swap a row's feature or inject a sibling row.  
**Warning signs:** milestone-wide `counts.positive`/`counts.negative`.
[VERIFIED: Spike 006 `validateManifest`; `54-CONTEXT.md` D-02/D-09]

### Pitfall 3: Mechanics Rows Contaminate Product Aggregates

**What goes wrong:** synthetic or parked rows increase `review_count`,
naturalness denominator, or pass counts.  
**Why it happens:** visually reviewed rows are treated as equivalent to
product-evidence rows.  
**How to avoid:** classify first and select product rows only from current
genuine approved fixtures; mechanics mode must yield zero product rows and zero
product weights.  
**Warning signs:** any product aggregate containing a
`mechanics_only`, `synthetic`, `ai_generated`, `disabled`, `parked`, or
`historical` fixture. [VERIFIED: `54-CONTEXT.md` D-03]

### Pitfall 4: Basename Collision or Suffix Alias

**What goes wrong:** a file in the wrong directory satisfies a manifest path,
or duplicate basenames overwrite each other in a `Map`.  
**Why it happens:** Spike 006 indexes raw path, stripped-root path, and basename
for each file.  
**How to avoid:** derive exactly one normalized relative key, reject collisions,
and require an exact triple.  
**Warning signs:** `file.name` fallback, `parts.slice(1)`, or multiple aliases
per selected file. [VERIFIED: Spike 006 `review.html` and
`normalizeAssetPaths`]

### Pitfall 5: Incomplete or Duplicate Review Set

**What goes wrong:** the pure core exports a subset, duplicate review, or review
for the wrong bundle even though the UI button appeared complete.  
**Why it happens:** Spike 006 validates each supplied review but does not
require exact set equality with selected fixtures.  
**How to avoid:** require exactly one review per selected fixture ID, no extras,
no duplicates, and no missing IDs in the pure core.  
**Warning signs:** export accepts `reviews.length < selectedRows.length`.
[VERIFIED: Spike 006 `buildSanitizedExport`; `54-CONTEXT.md` D-06]

### Pitfall 6: Human Accept Contradicts Frozen Fields

**What goes wrong:** a row with coverage 2, leakage, low naturalness, or
structure change still passes because `decision === "accept"`.  
**Why it happens:** the spike validates types/ranges only.  
**How to avoid:** compute pass from all frozen fields and validate reason-code
compatibility; the decision is necessary but never sufficient.  
**Warning signs:** gate code checks only `decision`. [VERIFIED: Spike 006
`validateReview`; `54-CONTEXT.md` D-06]

### Pitfall 7: Post-Hoc Polarity or Threshold Mutation

**What goes wrong:** outcomes are seen, then polarity/expectation or thresholds
are changed to obtain a pass.  
**Why it happens:** review/export reads the live mutable manifest or mutable
constants.  
**How to avoid:** freeze the schema constants and immutable selected-row
snapshot before the first image; any reload resets all review state.
Mutation-test manifest edits after session start.  
**Warning signs:** export dereferences the original manifest. [VERIFIED:
`54-CONTEXT.md` D-05/D-06]

### Pitfall 8: Rights Approval Becomes Feature Polarity

**What goes wrong:** `portrait_001` is treated as a teeth positive, sclera row,
or eyelid row merely because it is authorized.  
**Why it happens:** permission and product evidence are conflated.  
**How to avoid:** require feature-specific predeclared polarity, triple, and
review; authorization alone only permits evaluation.  
**Warning signs:** current gate logic derives polarity from fixture identity or
rights status. [VERIFIED: `example-images/FIXTURE_AUTHORIZATION.md`;
`54-CONTEXT.md` D-04]

### Pitfall 9: Export Sanitization Is a Denylist

**What goes wrong:** a newly added manifest/session field leaks because a scrub
list was not updated.  
**Why it happens:** the exporter clones rich inputs and deletes known secrets.
  
**How to avoid:** construct allowed rows and aggregates field by field; test
deep key sets and forbidden sentinel values.  
**Warning signs:** spread syntax over manifest/review/session objects or
`JSON.stringify(manifest)`. [VERIFIED: `54-CONTEXT.md` D-08]

### Pitfall 10: Unsafe DOM Error Rendering

**What goes wrong:** local manifest-controlled text reaches `innerHTML`, or
browser error details expose unintended content.  
**Why it happens:** Spike 006 uses `problems.innerHTML` for parse errors.  
**How to avoid:** create list nodes and assign only `textContent`; map errors to
fixed redacted codes.  
**Warning signs:** `innerHTML`, `outerHTML`, `insertAdjacentHTML`,
`document.write`, or raw `error.message`. [CITED:
https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html]

### Pitfall 11: Fit-to-Window Is Mistaken for Original Detail

**What goes wrong:** the reviewer never sees native pixels and misses leakage
or texture changes.  
**Why it happens:** Spike 006 fixes images to `object-fit: contain`.  
**How to avoid:** provide a true 100% pixel mode, visible zoom state,
pan/scroll, independent load/decode failures, and no review submission until
all three panes are ready.  
**Warning signs:** no 1:1 control or image natural-dimension state. [VERIFIED:
Spike 006 `review.html`; `54-CONTEXT.md` D-07]

### Pitfall 12: Hidden Persistence or Network Drift

**What goes wrong:** analytics, font/CDN loading, fetch, browser storage, or a
service worker retains or transmits sensitive data.  
**Why it happens:** static pages often acquire convenience dependencies.
  
**How to avoid:** keep all CSS/JS inline or phase-local, scan runtime source for
network/storage APIs and URLs, and test under `file://`.  
**Warning signs:** `fetch`, `XMLHttpRequest`, `WebSocket`, `sendBeacon`,
`URLSession`, `http:`, `https:`, `localStorage`, `indexedDB`, `caches`, or
`serviceWorker`. [VERIFIED: `54-CONTEXT.md` D-07/D-08; `SECURITY.md` §10]

## Code Examples

### Exact Review Predicates

```javascript
// Source: 54-CONTEXT.md D-05/D-06; recommended Phase 54 port pattern.
function rowPasses(fixture, review) {
  const common =
    review.target_present === fixture.expected_target_present &&
    review.protected_leakage === false &&
    review.naturalness >= 4 &&
    review.structure_changed === false &&
    review.decision === "accept" &&
    review.reason_code === "none";

  if (fixture.polarity === "positive") {
    return fixture.expected_target_present === true &&
      review.target_present === true &&
      review.mask_coverage >= 4 &&
      common;
  }
  return fixture.polarity === "negative" && common;
}
```

The local-only expected-target value resolves the locked
absence/challenge-confirmation rule without adding a durable review field.
[VERIFIED: `54-CONTEXT.md` D-05/D-06/D-08]

### Exact Review-Set Equality

```javascript
// Source: repository recommendation derived from 54-CONTEXT.md D-06.
function requireExactReviewSet(selectedRows, reviews) {
  const expected = new Set(selectedRows.map((row) => row.fixture_id));
  const seen = new Set();
  for (const review of reviews) {
    if (!expected.has(review.fixture_id) || seen.has(review.fixture_id)) {
      throw new Error("review_set_invalid");
    }
    seen.add(review.fixture_id);
  }
  if (seen.size !== expected.size) throw new Error("review_set_incomplete");
}
```

### Allowlist Export Without Time or Session Metadata

```javascript
// Source: 54-CONTEXT.md D-08/D-09; never spread input objects.
function durableReview(fixture, review) {
  return {
    fixture_id: fixture.fixture_id,
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
}
```

The top-level result must likewise omit `dataset_id`, `generated_at`, events,
filenames, paths, rights/documentation IDs, retention text, reviewer fields,
hashes, and freeform text. [VERIFIED: `54-CONTEXT.md` D-08]

### Safe DOM Text

```javascript
// Source: OWASP XSS Prevention Cheat Sheet.
const item = document.createElement("li");
item.textContent = fixedRedactedMessage;
problems.replaceChildren(item);
```

OWASP recommends `textContent`/text nodes instead of untrusted `innerHTML`.
[CITED:
https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html]

### Object URL Ownership

```javascript
// Source: W3C File API / MDN URL.revokeObjectURL.
let activeURLs = [];
function replaceImages(files) {
  for (const url of activeURLs) URL.revokeObjectURL(url);
  activeURLs = files.map((file) => URL.createObjectURL(file));
}
window.addEventListener("pagehide", () => {
  for (const url of activeURLs) URL.revokeObjectURL(url);
  activeURLs = [];
});
```

Object URLs should be revoked when no longer needed so the browser can release
their references. [CITED:
https://developer.mozilla.org/en-US/docs/Web/API/URL/revokeObjectURL_static]

## State of the Art

| Old/Spike Approach | Phase 54 Approach | Impact |
| --- | --- | --- |
| Whole-manifest positive/negative counts | One-feature bundle plus independent reducers | Prevents sibling borrowing. [VERIFIED: Spike 006 core; `54-CONTEXT.md` D-09] |
| Basename/suffix asset aliases | One exact normalized selected-root-relative key | Prevents ambiguous or wrong-file matches. [VERIFIED: Spike 006 core/HTML; `54-CONTEXT.md` D-02] |
| Type/range-only review validation | Frozen deterministic row-pass predicate | Human accept cannot override thresholds. [VERIFIED: Spike 006 core; `54-CONTEXT.md` D-06] |
| Timestamped export + timestamped events | No time/session/event fields at all | Satisfies the durable privacy contract. [VERIFIED: Spike 006 core/HTML; `54-CONTEXT.md` D-08] |
| Contained three-column images | Explicit 100% pixel inspection mode | Makes original-detail review real rather than nominal. [VERIFIED: Spike 006 HTML; `54-CONTEXT.md` D-07] |
| Mechanics reviews included in general review count | Mechanics can exercise the UI but contribute zero product rows/weight | Preserves deterministic tooling without product overclaim. [VERIFIED: `54-CONTEXT.md` D-03] |

**Deprecated/outdated for Phase 54:**

- Spike 006 `generated_at`, `now`, `events`, and timestamp logging in any
  durable result. [VERIFIED: `54-CONTEXT.md` D-08]
- Spike 006 `dataset_id` in durable export and dataset-derived download
  filenames. [VERIFIED: `54-CONTEXT.md` D-08]
- Spike 006 basename/suffix asset matching. [VERIFIED: `54-CONTEXT.md` D-02]
- Any attempt to reuse the invalidated upper-eyelid interior warp or proxy
  through shipped eye/brow/smoothing features. [VERIFIED: `54-CONTEXT.md`
  D-14/D-15]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
| --- | --- | --- | --- |
| — | None. All prescriptive decisions are locked by Phase 54 context, verified against repository sources, or cited to current web standards/security guidance. | — | — |

## Open Questions

No planning-blocking question remains. [VERIFIED: `54-CONTEXT.md` status
`Ready for planning`]

Resolved implementation unknowns:

1. **Where should the contract live?** In the Phase 54 planning directory, not
   in production targets and not by editing the packaged spike. [VERIFIED:
   `54-CONTEXT.md` the agent's Discretion/Integration Points]
2. **Does current evidence need to block execution?** No; independent closed
   gates are valid outputs and feed Phases 55–58. [VERIFIED: `54-CONTEXT.md`
   D-10–D-12]
3. **Can `portrait_001` open teeth?** No; authorization and possible
   already-light negative eligibility cannot supply a genuine positive, and it
   does not count at all until a complete teeth triple and frozen review pass.
   [VERIFIED: `54-CONTEXT.md` D-04/D-10]
4. **Can the Spike 006 core be reused unchanged?** No; its timestamped export,
   shared counts, alias matching, and incomplete review-policy enforcement must
   be reworked in a phase-owned port. [VERIFIED: Spike 006 source and
   `54-CONTEXT.md`]
5. **Are packages or a server required?** No. Browser-native APIs plus installed
   Node/Python standard libraries cover the implementation and tests.
   [VERIFIED: local environment audit; `54-CONTEXT.md` D-07]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
| --- | --- | --- | --- | --- |
| Node.js | Pure-core tests and syntax checks | ✓ | v26.0.0 | None needed. [VERIFIED: local command] |
| Python 3 | Boundary checker/self-tests | ✓ | 3.9.6 | Node-only checker is possible but not recommended because Python phase checkers are established. [VERIFIED: local command/repository patterns] |
| macOS `open` | Manual static reviewer launch | ✓ | system tool | Open the HTML directly in a chosen supported browser. [VERIFIED: local `command -v open`] |
| Browser with File API + directory input | Review UI | Not pinned by repository | — | UI smoke must record the chosen browser; file selection remains user-mediated. [VERIFIED: no browser runtime is pinned in repository] |
| Xcode/iOS Simulator | Regression-only post-wave gate | Available in Phase 53 evidence | iPhone 17e / iOS 26.5 recorded by orchestration | Use the same explicit simulator destination. [VERIFIED: Phase 53 execution evidence/current environment handoff] |

**Missing dependencies with no fallback:** none. The browser choice requires a
smoke record but does not require package installation. [VERIFIED: environment
audit]

**Missing dependencies with fallback:** no CLI browser automation was detected;
use the product's browser-control capability or a documented manual local smoke
for the static page while keeping policy in pure automated tests. [VERIFIED:
local command audit]

## Validation Architecture

### Test Framework

| Property | Value |
| --- | --- |
| Framework | Node built-in `node:test` + Python standard-library checker/self-test |
| Config file | None — phase-owned direct commands |
| Quick run command | `node --test .planning/phases/54-rights-approved-evidence-and-eligibility-decisions/54-evidence-core.test.js` |
| Policy gate | `python3 .planning/phases/54-rights-approved-evidence-and-eligibility-decisions/check_phase54_evidence_boundaries.py --self-test && python3 .planning/phases/54-rights-approved-evidence-and-eligibility-decisions/check_phase54_evidence_boundaries.py` |
| Full regression | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache swift test --package-path BeautySDK` |

The phase tests should contain no real media, local rights IDs, source
filenames, or raw paths; use opaque in-memory objects and synthetic file
metadata only. [VERIFIED: `54-CONTEXT.md` D-03/D-08]

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
| --- | --- | --- | --- | --- |
| EVID-01 | One-feature genuine approved positive/negative bundle, exact triples, predeclared polarity/target expectation | unit + mutation | `node --test .../54-evidence-core.test.js --test-name-pattern='bundle'` | ❌ Wave 0 |
| EVID-02 | Mechanics/synthetic/AI/disabled/parked/historical rows produce zero product rows and weight | unit + mutation | `node --test .../54-evidence-core.test.js --test-name-pattern='mechanics|non-product'` | ❌ Wave 0 |
| EVID-03 | Frozen schema, exact review set, positive/negative predicates, reason compatibility, manifest-reload reset | unit + UI contract scan | `node --test .../54-evidence-core.test.js --test-name-pattern='review|frozen'` | ❌ Wave 0 |
| EVID-04 | Exact allowlisted export; all forbidden keys and sentinel values absent at every depth | unit + boundary checker | `node --test .../54-evidence-core.test.js --test-name-pattern='export|privacy'; python3 .../check_phase54_evidence_boundaries.py` | ❌ Wave 0 |
| EVID-05 | Sibling rows/counts/reviews cannot affect another feature; all three reducers always produce records | unit + mutation | `node --test .../54-evidence-core.test.js --test-name-pattern='independent|sibling'` | ❌ Wave 0 |
| LID-01 | Eyelid requires evidence AND qualified non-warp design; retains both reasons when both false | unit + decision-artifact check | `node --test .../54-evidence-core.test.js --test-name-pattern='eyelid|design'; python3 .../check_phase54_evidence_boundaries.py` | ❌ Wave 0 |

### Required Mutation Matrix

The Node and Python self-tests should cover at least these independent
mutations: absolute path; `../`; backslash/colon/NUL; duplicate opaque ID;
duplicate normalized asset key; basename collision; unsupported feature,
polarity, rights, role, decision, or reason enum; mixed feature; missing each
asset in turn; no selected directory; missing positive; missing negative;
mechanics-only, synthetic, AI-generated, disabled, parked, and historical rows;
rights record missing; manifest or polarity changed after session start;
duplicate/missing/extra review; 0/6/fractional scores; accept with each failed
criterion; reject with `none`; positive from sibling; negative from sibling;
mechanics denominator contamination; export timestamp/event/dataset/path/name/
rights/retention/reviewer/freeform/raw-geometry sentinel; UI network/storage/
unsafe-DOM token; and one/both eyelid prerequisites absent. [VERIFIED:
`54-CONTEXT.md` D-01–D-16 and identified Spike 006 gaps]

### Sampling Rate

- **Per task commit:** focused Node test pattern plus
  `git diff --check`. [VERIFIED: repository workflow]
- **Per wave merge:** complete Node suite, boundary checker self/live modes,
  JavaScript syntax check, JSON parse, representative `git check-ignore`, and
  `git ls-files` proof for local review artifacts. [VERIFIED:
  `QUALITY_SCORE.md`; `SECURITY.md`]
- **Phase gate:** full Node/checker suite, static browser smoke at original
  detail, full SwiftPM regression, explicit Demo build/test post-hook, schema/UI
  GSD gates, and independent verifier. [VERIFIED: GSD config and established
  Phase 53 closeout pattern]

### Wave 0 Gaps

- [ ] `54-evidence-core.test.js` — RED tests for EVID-01 through EVID-05 and
  LID-01.
- [ ] `check_phase54_evidence_boundaries.py --self-test` — adversarial
  mutations for privacy, scope, network/storage, exact artifact keys, and
  closed-feature absence.
- [ ] An ignored local review directory rule — keeps sensitive manifests,
  original/mask/after assets, and downloads out of Git.
- [ ] A UI contract/smoke record — proves no default selections, all three
  images load, 100% mode works, reload resets reviews, errors are redacted, and
  export uses a fixed filename.

No framework installation gap exists. [VERIFIED: environment audit]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
| --- | --- | --- |
| V1 Architecture / threat modeling | yes | Phase plan threat model explicitly treats local manifest/media as untrusted sensitive input and blocks HIGH findings. [VERIFIED: `.planning/config.json` ASVS L1/HIGH policy] |
| V2 Authentication | no | Static single-user local page has no identity or authentication boundary. [VERIFIED: `54-CONTEXT.md` D-07] |
| V3 Session Management | limited | In-memory review session only; reload/manifest change destroys state and object URLs; no cookies/storage. [VERIFIED: `54-CONTEXT.md` D-07/D-08] |
| V4 Access Control | limited | Browser-mediated file selection is the only resource grant; no ambient path access or server. [CITED: https://html.spec.whatwg.org/multipage/input.html#file-upload-state-(type=file)] |
| V5 Input Validation | yes | Exact schema, allowlisted enums/IDs, bounded files, safe exact relative keys, duplicate detection, and cross-row semantics. [CITED: https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html] |
| V6 Cryptography | no | No encryption, signature, hash, credential, or token mechanism is required or authorized. [VERIFIED: Phase boundary] |
| V7 Error/Logging | yes | Fixed redacted errors; ephemeral aggregate events only; no durable timestamps or raw `error.message`. [VERIFIED: `SECURITY.md` §§9,13; `54-CONTEXT.md` D-08] |
| V8 Data Protection | yes | Media/paths/rights/raw geometry/reviewer identity stay local and ephemeral; durable export is a strict positive allowlist. [VERIFIED: `SECURITY.md` §§1–2; `54-CONTEXT.md` D-08] |
| V12 File/Resource Handling | yes | User-selected manifest/images are untrusted; enforce type/size/key bounds, no traversal or alias lookup, no active formats. [CITED: https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html] |
| V14 Configuration | yes | Static source scan forbids network, external resources, storage, service workers, and unsafe DOM sinks. [VERIFIED: `54-CONTEXT.md` D-07/D-08] |

OWASP ASVS is the project's security verification basis; the repository
configuration requires Level 1 and blocks HIGH findings. [CITED:
https://owasp.org/www-project-application-security-verification-standard/;
VERIFIED: `.planning/config.json`]

### Known Threat Patterns for the Static Reviewer

| Pattern | STRIDE | Standard Mitigation |
| --- | --- | --- |
| Manifest/path tampering | Tampering | Exact schema, one normalized relative key, duplicate/collision rejection, immutable session snapshot |
| Cross-feature evidence borrowing | Tampering / Repudiation | One-feature bundles and three isolated reducers/denominators |
| Post-hoc polarity/threshold change | Tampering / Repudiation | Freeze snapshot/constants before review; reload clears reviews |
| Sensitive export growth | Information Disclosure | Positive allowlist serializer and deep exact-key/sentinel tests |
| Filename/path/rights leak in UI/error/download | Information Disclosure | Blinded labels, fixed error codes, `textContent`, fixed download filename |
| Timestamp/event/session leak | Information Disclosure | No `Date`/events in export; transient aggregates only |
| DOM XSS from local manifest/error | Elevation of Privilege / Information Disclosure | No `innerHTML`; safe text sinks; no SVG/HTML asset formats |
| Oversized/malformed files | Denial of Service | Freeze conservative manifest/row/file count, compressed-byte, MIME/extension, and decoded-dimension budgets before review |
| Object URL retention | Information Disclosure / resource exhaustion | Active-row-only URLs and deterministic revocation on transition/reset/pagehide |
| Hidden network/storage dependency | Information Disclosure | Runtime token/source scans plus local `file://` smoke |
| Production scope smuggling | Tampering | Allowed-path diff classifier and exact absence scans for public fields/providers/renderers/Demo/realtime |

### Recommended Frozen Tooling Budgets

Use repository-native conservative ceilings: manifest JSON at most 65,536
UTF-8 bytes, at most 64 fixture rows, PNG/JPEG only, each selected asset at most
16 MiB compressed, and decoded dimensions no greater than 4096 × 4096 for the
reviewer. These limits are tooling safety bounds, not product/device claims.
The 65,536-byte JSON precedent is the Demo import boundary; 16 MiB and 4096 ×
4096 are established local gallery/output safety precedents. [VERIFIED:
`SECURITY.md` §7; `example-images/generate_gallery.py`; `QUALITY_SCORE.md`]

The HTML `accept` attribute must not be treated as validation. Validate the
actual selected `File` metadata and loaded image dimensions, reject duplicates,
and keep the review button disabled on any load/decode/budget failure. [CITED:
https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html]

## Sources

### Primary (HIGH confidence)

- `.planning/phases/54-rights-approved-evidence-and-eligibility-decisions/54-CONTEXT.md`
  — locked Phase 54 decisions D-01 through D-16 and scope.
- `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`,
  `.planning/PROJECT.md` — milestone requirements, ordering, known evidence
  gaps, and closed-gate downstream semantics.
- `AGENTS.md`, `PLANS.md`, `SECURITY.md`, `RELIABILITY.md`,
  `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `ARCHITECTURE.md` — repository
  workflow, privacy, failure, product, quality, and no-production-change
  contracts.
- `example-images/FIXTURE_AUTHORIZATION.md`, `example-images/README.md`,
  `.gitignore` — current authorized fixture limits and local-media policy.
- `.codex/skills/spike-findings-beauty/SKILL.md` and references
  `licensed-fixture-evaluation.md`, `teeth-whitening.md`,
  `sclera-redness.md`, `upper-eyelid-fullness.md` — implementation blueprint
  and evidence-specific constraints.
- Spike 006 `review-core.js`, `review.html`,
  `fixture-manifest.schema.json`, `test-review-core.js`, and `README.md` —
  reusable core plus the precise gaps that must be corrected.
- [W3C File API](https://www.w3.org/TR/FileAPI/) — selected files, blobs, and
  object URL lifecycle.
- [WHATWG HTML file upload state](https://html.spec.whatwg.org/multipage/input.html#file-upload-state-(type=file))
  — browser-mediated file input.
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
  — security verification framework.
- [OWASP Input Validation Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html)
  — allowlist and file-input validation.
- [OWASP File Upload Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html)
  — path/name/type/size defense in depth.
- [OWASP XSS Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
  — safe DOM sinks.

### Secondary (MEDIUM confidence)

- [MDN `webkitdirectory`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement/webkitdirectory)
  — current directory-input implementation notes.
- [MDN `URL.revokeObjectURL`](https://developer.mozilla.org/en-US/docs/Web/API/URL/revokeObjectURL_static)
  — operational object URL cleanup guidance.

### Tertiary (LOW confidence)

- None.

## Metadata

**Confidence breakdown:**

- Standard stack: **HIGH** — fixed by context, verified against the current
  spike and local runtime; no external package selection.
- Architecture: **HIGH** — follows explicit phase boundary and existing
  phase-owned checker/evidence patterns.
- Eligibility rules: **HIGH** — copied from D-01 through D-16 and mapped to
  pure predicates.
- Privacy/security pitfalls: **HIGH** — verified in current spike source and
  cross-checked with repository security contracts and OWASP/W3C sources.
- Browser presentation details: **MEDIUM-HIGH** — native APIs are documented,
  but the chosen local browser still needs a smoke check for directory input
  and `file://` behavior.

**Research date:** 2026-07-31  
**Valid until:** 2026-08-30 for the stable repository contract; re-check browser
compatibility if the reviewer target changes.
