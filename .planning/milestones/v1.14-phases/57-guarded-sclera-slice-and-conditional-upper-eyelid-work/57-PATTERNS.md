# Phase 57: Guarded Sclera Slice and Conditional Upper-Eyelid Work - Pattern Map

**Mapped:** 2026-08-04
**Files analyzed:** 12 planned new/modified artifacts
**Analogs found:** 12 / 12

## Scope Boundary

Phase 57 is a two-feature exact-absence slice. The immutable Phase 54 rows for
`sclera_redness` and `upper_eyelid_fullness` are both closed, so production SDK
and Demo files are validation fixtures rather than implementation targets. The
phase must not add either candidate, an inert route, or a proxy backed by an
already shipped eye/skin feature.

The important difference from Phase 56 is that a whole-production-source scan
cannot broadly reject eye, eyelid, pupil, smoothing, eye-bag, or dark-circle
language. `eyeHeight`, `upperEyelidLift`, the eye warp provider, skin smoothing,
and the existing dark-circle/eye-bag domains are legitimate shipped behavior.
Phase 57 should copy Phase 56's structural scanner and live-fixture mutation
architecture, then split detection into (a) strong candidate/synonym families
and (b) semantic coupling between either candidate family and a legitimate
proxy family.

`57-RESEARCH.md` was not present at mapping time. Classification comes from
`57-CONTEXT.md`, Phase 54 decisions, the finalized Phase 56 checker/evidence/
validation, current SDK/Demo tests and sources, and product/blueprint ledgers.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `57-CLOSED-EYE-GATES-EVIDENCE.md` | evidence record | batch projection/report | `56-TEETH-CLOSED-GATE-EVIDENCE.md` | exact workflow; two independent rows |
| `check_phase57_eye_gate_boundaries.py` | utility / policy gate | batch whole-source/file scan + live mutations | `check_phase56_teeth_boundaries.py` | exact architecture; semantic scanner generalization |
| `57-THREAT-INVENTORY.json` | security config | deterministic validation | `56-THREAT-INVENTORY.json` | exact |
| `57-VALIDATION.md` | validation config/evidence | batch verification map | `56-VALIDATION.md` | exact workflow |
| `BeautyParametersTests.swift` | test | serialization/reflection compatibility | existing Phase 53/56 exact-absence tests in the same file | exact |
| `BeautyResourceCatalogTests.swift` | test | file-I/O / preset decoding | existing Phase 53/56 inventory tests in the same file | exact |
| `BeautyRendererOutputRegressionTests.swift` | test | request-response / saved-output inventory | existing Phase 53/56 renderer-absence tests in the same file | exact |
| `BeautyEngineLocalRetouchFoundationTests.swift` | test | request-response lifecycle | existing Phase 53/56 no-admission facade tests in the same file | exact |
| `BeautyDemoViewStateTests.swift` | test | UI taxonomy/state transform | existing Phase 56 disabled teeth test plus current eye taxonomy assertions | exact role/data flow |
| `PRODUCT_SENSE.md` / `QUALITY_SCORE.md` | product/quality ledgers | append-only closeout record | Phase 56 closed-gate closeout sections | exact owner pattern |
| `FEATURE_MATRIX.md` / `SHAPE_FEATURE_LEDGER.md` | taxonomy ledgers | deterministic status record | current eye partial/future rows | exact in-place owner pattern |
| `PLANS.md` / `.planning/REQUIREMENTS.md` | project/requirement ledgers | append-only status projection | Phase 56 planning/final closeout and conditional dispositions | exact owner pattern |

## Pattern Assignments

### `57-CLOSED-EYE-GATES-EVIDENCE.md` (evidence record, batch report)

**Primary analog:**
`.planning/phases/56-independent-teeth-whitening-slice/56-TEETH-CLOSED-GATE-EVIDENCE.md`
lines 1-110.

Copy the fixed finalized frontmatter and claim-boundary-first layout, replacing
the requirement list with SCLERA-01..06 and LID-02..05. Project both Phase 54
rows independently and exactly:

```markdown
| `sclera_redness` | `closed` | `missing_genuine_positive`, `missing_genuine_negative` | `0 / 0 / 0 / 0 / 0` |
| `upper_eyelid_fullness` | `closed` | `missing_genuine_positive`, `missing_genuine_negative`, `non_warp_design_unqualified` | `0 / 0 / 0 / 0 / 0` |
```

Use separate requirement rows. SCLERA-01 records
`false_branch_exact_absence`; SCLERA-02..05 record exactly
`not_applicable_closed_gate`; SCLERA-06 records `no_promotion`. LID-02 records
the false branch, LID-03/LID-05 record `not_applicable_closed_gate`, and LID-04
records `proxy_rejected` as an affirmative invariant. Do not describe LID-04 as
not applicable: it must prove that existing geometry/color/skin domains remain
independent and unchanged.

Copy Phase 56's task/HIGH/result tables and privacy nonclaims. Do not include
portrait names/paths/hashes, reviewer/grant payloads, eye or pupil support,
masks, landmarks, vein-like descriptors, coordinates, pixels, output identity,
raw matches, or raw errors. Mechanics spikes contribute zero eligibility and
must not be summarized as product evidence.

### `check_phase57_eye_gate_boundaries.py` (utility/policy gate, batch/live mutation)

**Primary analog:**
`.planning/phases/56-independent-teeth-whitening-slice/check_phase56_teeth_boundaries.py`.

Copy these concrete structures:

- root indirection and fixture paths from lines 95-133;
- fail-closed `rg` classification from lines 136-156;
- exact ordered ASVS inventory construction from lines 159-183;
- exact decision identity/type/key/value checks from lines 235-273;
- exact 59/5/72 and test-anchor checks from lines 280-344;
- complete `BeautySDK/Sources/**/*.swift` and filename scanning from lines
  347-416;
- structural evidence frontmatter parsing from lines 485-526;
- fixed-ID classified live failures from lines 604-635;
- temporary real-fixture copy/mutate/restore helpers from lines 637-815;
- per-threat live mutations, missing fixtures, malformed inputs, and stable
  aggregate JSON output from lines 818-968.

Preserve the scanner contract verbatim in shape:

```python
def classify_rg(returncode: int, stdout: str, stderr: str) -> str:
    if returncode == 0:
        return "match"
    if returncode == 1 and not stdout and not stderr:
        return "clean"
    raise ScannerFailure("unclassified scanner outcome")
```

Replace the single teeth family with two explicit strong families. Suggested
canonical/strong spellings include:

- sclera: `scleraRednessReduction`, `sclera_redness`, conjunctiva/ocular/eye
  redness reduction, bloodshot-eye correction, and sclera/ocular whitening;
- upper eyelid: `upperEyelidFullnessReduction`, `upper_eyelid_fullness`, upper
  lid/eyelid fat removal, lid-fullness reduction, and eyelid defatting.

Do not ban standalone tokens such as `eye`, `pupil`, `eyelid`, `lid`, `red`,
`smoothing`, `eyeHeight`, or `upperEyelidLift`. Those create false positives in
shipped code. Use strong multi-token/camel-case compounds for candidate scans,
then a separate bidirectional coupling regex/semantic rule that requires a
candidate-family token within a bounded context of a proxy token. Proxy tokens
should include `eyeHeight`, `upperEyelidLift`, brow translation/movement,
aperture/vertical/interior eye warp, `skinSmoothing`/global smoothing,
dark-circle, and eye-bag terms. A file containing only a legitimate proxy must
pass; adding a comment/function that routes or aliases the candidate to it must
fail with a dedicated stable rule such as `R57-PROXY`.

Strong mutation cases should add neutrally named files beneath the real
production tree, for example:

```python
assert_added_file(
    SOURCES / "BeautyEffects" / "Planning" / "LocalColorProvider.swift",
    "package func conjunctivaRednessReduction() {}\n",
    ("R57-SCLERA-PUBLIC", "R57-SCLERA-ALIAS"),
)
assert_added_file(
    SOURCES / "BeautyEffects" / "Planning" / "LocalToneProvider.swift",
    "package func removeUpperLidFullness() {}\n",
    ("R57-LID-PUBLIC", "R57-LID-ALIAS"),
)
```

Add paired clean/mutation tests around real legitimate anchors:

- `BeautyEffectResolver.swift` lines 160-189 and 707-759;
- `EyeWarpProvider.swift` lines 4-44 and 61-98;
- `BeautyParameters.swift` fields/CodingKeys/initializer for `eyeHeight` and
  `upperEyelidLift`;
- existing skin smoothing and eye-geometry renderer cases.

The untouched fixtures must pass. Mutations such as
`upperEyelidFullnessReduction aliases upperEyelidLift`, `去脂 uses eyeHeight`,
`lid fat maps to skinSmoothing`, or `scleraRednessReduction uses brightness`
must fail. Also mutate each candidate toward the other to prove sibling
independence. Keep Phase 56 `teethWhitening` absence as a separate compatibility
anchor rather than folding it into either new decision.

### `57-THREAT-INVENTORY.json` (security inventory, deterministic config)

**Analog:** Phase 56 threat inventory and checker lines 159-183.

Copy exact whole-document equality, ordered IDs, `OWASP ASVS Level 1`,
`block_on: HIGH`, fixed STRIDE arrays, `severity: HIGH`, and
`disposition: mitigate`. Useful Phase 57 groupings are: two-row authority
tampering/independence; sclera public/production/alias activation; eyelid
public/production activation; proxy coupling; Demo activation; privacy/evidence
lifecycle; ledger/compatibility/scanner drift. Every named gate needs an
executable mutation owner; count-only equality is insufficient.

### `57-VALIDATION.md` (validation strategy, batch verification)

**Analog:** `56-VALIDATION.md` lines 1-195.

Retain one row per actual XML task ID, exact focused commands, Wave 0 tests and
checker before evidence/owner promotion, full SwiftPM and explicit Simulator
build/test final-only, exact threat/decision/task/requirement equality, and
ASVS L1 HIGH blocking. State explicitly that no production RED/GREEN
implementation exists: clean production already represents both false
branches.

Keep SCLERA and LID dispositions separate. LID-04 must have an executable
positive oracle: all shipped eye/skin domains still exist and behave normally,
while every candidate-to-proxy mutation fails. No browser, image review, file
selection, or human checkpoint belongs in validation.

### SDK exact-absence and compatibility tests

#### `BeautyParametersTests.swift`

**Analogs:** lines 1183-1237 and Phase 56 extension beginning at line 1239.

Reuse `Mirror`, real-source CodingKey parsing, encoded key equality, exact 59
fields, and legacy construction. Pin both canonical names and strong aliases.
Also assert that `eyeHeight` and `upperEyelidLift` remain present exactly once
and are not renamed or cited as candidate equivalents. Do not add zero-valued
candidate fields.

#### `BeautyResourceCatalogTests.swift`

**Analog:** lines 220-250.

Reuse exact five preset IDs, 59-field encoded parameters, absence keys, and the
five SHA-256 source hashes. Reject both candidate synonym families without
rejecting legitimate `skinSmoothing` or shipped eye geometry keys.

#### `BeautyRendererOutputRegressionTests.swift`

**Analogs:** lines 971-990 plus the expected IDs for `eyeHeight_0p25` and
`upperEyelidLift_0p25` at lines 38-40.

Preserve exact 72 IDs. Assert no sclera/eyelid candidate or alias saved-output
case exists, while explicitly retaining the legitimate eye geometry cases and
unrelated skin/color cases. This paired assertion prevents a checker from
passing by deleting shipped proxy domains.

#### `BeautyEngineLocalRetouchFoundationTests.swift`

**Analogs:** Phase 56 tests beginning at lines 295 and 355; production fixtures
are `BeautyEffectResolver.swift` lines 67-74 and
`BeautyLocalRetouchAdmission.swift` lines 1-17.

Copy literal `.none`, empty `productionAdmissionNames`, both still entries,
unchanged dimensions/bytes/warnings/metrics/detection summary, unrelated effect
continuation, valid-invalid-valid recovery, and pixel-buffer/reset zero-work
assertions. Keep Phase 55 opaque testing scenarios anatomy-free.

### `BeautyDemoViewStateTests.swift` (test, disabled taxonomy)

**Production fixture:** `MeituEditorToolModels.swift` lines 95-115.

Guard exact order and exact rows:

```swift
unsupported("eyes.fat", title: "去脂", icon: "minus.circle", badge: .free)
unsupported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free)
```

Copy Phase 56's disabled teeth test structure from lines 80 onward: exact ID,
title, icon, badge, unsupported state, nil `controlID`, fixed unavailable copy,
no active panel controls, and no binding/processor/reset route. Reuse taxonomy
order lines 47-59. Keep the shipped eye controls in panel state (lines 550-557)
unchanged; do not make the static disabled rows disappear merely to prove no
active mapping.

### Product, quality, requirement, and blueprint ledgers

Use exact in-place anchors:

- `FEATURE_MATRIX.md` line 25: `眼睛 = partial` solely because both retouch
  rows remain future;
- `SHAPE_FEATURE_LEDGER.md` lines 84-94: `眼高` and `提肌` remain implemented,
  `去脂` and `祛红血丝` remain future;
- `PRODUCT_SENSE.md` lines 517 and 522-524 plus lines 619/637: closed independent
  decisions, exact absence, both future rows, branch partial;
- `QUALITY_SCORE.md` lines 287 and 584-590: no product credit from mechanics or
  closed evidence;
- `.planning/REQUIREMENTS.md` lines 53-68: exact SCLERA/LID conditional
  dispositions, especially affirmative LID-04 proxy rejection;
- `PLANS.md`: follow Phase 56's discussion → planning → wave evidence → final
  closeout progression with actual command/count evidence and explicit
  nonclaims.

Update these owners only after executable checks are green. Do not turn them
into a second admission authority. `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`,
`SECURITY.md`, and `RELIABILITY.md` remain read-only unless execution discovers
a genuinely new enduring contract; exact absence normally adds none.

## Shared Patterns

### Independent Closed Decision Authority

**Source:** Phase 54 `54-EVIDENCE-DECISIONS.json` lines 17-47.

Select each feature by exact identity, require exactly one row, exact ordered
keys/reasons and strict integer zero values, and reject lookalike/duplicate/
missing rows. Never use array position or allow one row to discharge another.

### Exact Compatibility and Admission

**Sources:** `BeautyParametersTests.swift` lines 1183-1237;
`BeautyResourceCatalogTests.swift` lines 220-250;
`BeautyRendererOutputRegressionTests.swift` lines 971-990;
`BeautyEffectResolver.swift` lines 67-74.

The invariant remains exact `59 / 5 / 72 / .none`, plus both still facade
entries, empty production admission names, and no pixel-buffer/reset work.

### Preserve Legitimate Proxy Domains While Rejecting Coupling

**Sources:** `BeautyEffectResolver.swift` lines 160-189 and 707-759;
`EyeWarpProvider.swift` lines 4-44 and 61-98; blueprint ledger lines 84-94.

Clean shipped `eyeHeight`, `upperEyelidLift`, pupil/eye contours, skin smoothing,
dark-circle, and eye-bag behavior must remain legal. Detection should fail only
when a candidate/synonym is declared or semantically connected to one of these
domains. Pair every rejection mutation with a clean-fixture assertion.

### Fail-Closed Real-Fixture Mutation Testing

**Source:** Phase 56 checker lines 637-968.

Copy required fixtures into a temporary root, redirect every path through
`configure_root`, mutate one anchored fact or add one neutral filename, invoke
the same live checker, require the stable rule ID, and restore in `finally`.
Missing anchors/files, malformed JSON/frontmatter, missing `rg`, scanner exit
other than 0/clean-1, and unclassified exceptions must fail closed.

### Privacy-Safe Durable Evidence

**Sources:** Phase 56 checker lines 485-603 and closed-gate evidence lines
81-110.

Allow only fixed task/requirement/threat IDs, allowlisted statuses/reasons,
zero-valued aggregates, compatibility totals, and test counts. For Phase 57,
the forbidden payload inventory must additionally name eye/pupil/iris/landmark
support, sclera/eyelid masks, vein-like descriptors, and any per-eye geometry.

## Read-Only / No-Change Boundaries

| Boundary | Required Phase 57 posture |
|---|---|
| public `BeautyParameters` / Codable / Testing SPI | no candidate or inert field/key/default/name |
| providers, transforms, effect plan, renderer, presets/resources/package | no candidate route or synonym; preserve legitimate shipped domains |
| resolver/admission/engine/composer | literal `.none`; feature-neutral testing mechanics only |
| `MeituEditorToolModels.swift` and Demo mapping/state | preserve exact disabled rows and order; no active control |
| Phase 54 decisions/reviewer | immutable input; do not regenerate or edit |
| images/review/generated media | do not select, inspect, create, track, or cite as Phase 57 evidence |
| product/blueprint ledgers | exact future/future/partial until all automated owners are green |
| spike skill/source | read-only mechanics background with zero admission weight |

## Pitfalls to Block Explicitly

- A broad `eyelid|eye|pupil|smoothing` ban that breaks legitimate shipped code.
- A narrow canonical-name-only scan that misses conjunctiva/bloodshot/ocular
  redness or upper-lid fat/fullness synonyms in neutrally named files.
- Treating `upperEyelidLift`, `eyeHeight`, brow/warp, smoothing, dark-circle, or
  eye-bag output as `去脂` evidence or implementation.
- Deleting or disabling shipped proxy features to make a broad scanner pass.
- Treating guarded sclera spike mechanics as SCLERA-02..05 implementation or
  product safety/effectiveness/naturalness evidence.
- Borrowing teeth, sclera, eyelid, or Phase 55 composition evidence across
  independent gates.
- Marking SCLERA-02..05 or LID-03/LID-05 as passed/implemented/waived instead of
  exact `not_applicable_closed_gate`.
- Marking LID-04 not applicable; proxy rejection is an active required proof.
- Activating, renaming, reordering, or removing the legitimate disabled Demo
  taxonomy rows.
- Allowing missing files, malformed structures, scanner failures, missing
  mutation anchors, count-only inventories, or raw exceptions to report green.

## No Analog Found

None. Phase 56 supplies the exact-absence/evidence/checker workflow, Phase 54
supplies the two authoritative decision rows, and the current eye geometry
implementation supplies the legitimate-proxy clean fixtures. No new production
role needs an analog because production creation is out of scope.

## Metadata

**Analog search scope:** `.planning/phases/54-*`, `.planning/phases/56-*`,
`BeautySDK/Sources`, `BeautySDK/Tests`, `BeautyDemo/BeautyDemo`,
`BeautyDemo/BeautyDemoTests`, root contract ledgers, and
`docs/meitu-function-blueprint`.

**Strong analogs read:** Phase 54 decision ledger; Phase 56 checker, validation,
evidence, and pattern map; parameter/resource/renderer/foundation tests;
resolver/admission/eye-warp sources; Demo taxonomy/tests; product, quality,
requirements, and blueprint ledgers.

**Pattern extraction date:** 2026-08-04
