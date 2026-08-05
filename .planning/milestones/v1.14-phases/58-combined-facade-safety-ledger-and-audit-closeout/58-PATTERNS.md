# Phase 58: Combined Facade, Safety, Ledger, and Audit Closeout - Pattern Map

**Mapped:** 2026-08-04
**Files analyzed:** 15 planned new/modified owners
**Analogs found:** 15 / 15

## Scope Read

Phase 58 is a zero-admission audit closeout. The nearest patterns are therefore
the Phase 53/55 feature-neutral facade tests and the Phase 57 finalized
closed-gate checker/evidence lifecycle, not any feature provider, renderer, mask,
or image-review implementation. The spike blueprint reinforces the same boundary:
still-image only, normalize once, keep support request-local, and do not infer
product evidence from mechanics.

No browser, file picker, image generation, file upload, visual comparison, or
human checkpoint belongs in this phase.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
| --- | --- | --- | --- | --- |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift` | test | synchronous request-response plus bounded async publication | same file, Phase 53/56/57 tests | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift` | test | synchronous transform/request lifecycle | same file, Phase 55 tests | exact |
| `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` and the other two existing opt-in owners | test | local file-I/O plus Vision request-response | existing six opt-in tests | exact |
| `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` | test | static state/mapping | Phase 56/57 disabled-row assertions in same file | exact |
| `58-THREAT-INVENTORY.json` | config/security inventory | batch validation | `57-THREAT-INVENTORY.json` plus `expected_inventory()` | exact |
| `check_phase58_closeout_boundaries.py` | utility/audit checker | batch file-I/O, subprocess, mutation testing | `check_phase57_eye_gate_boundaries.py` | exact, with completed-state adaptation |
| `58-CLOSEOUT-EVIDENCE.md` | evidence/config | batch aggregate projection | `57-CLOSED-EYE-GATES-EVIDENCE.md` | exact lifecycle shape |
| `58-VALIDATION.md` | validation config | batch traceability | `57-VALIDATION.md` | exact |
| `.planning/REQUIREMENTS.md` | requirements ledger | batch owner synchronization | Phase 57 exact dispositions | exact |
| `PRODUCT_SENSE.md` | product owner | batch owner synchronization | Phase 57 closed-eye acceptance | exact |
| `SECURITY.md` | security owner | batch owner synchronization | Phase 57 security boundary | exact |
| `RELIABILITY.md` | reliability owner | batch owner synchronization | Phase 57 reliability closeout | exact |
| `QUALITY_SCORE.md` | quality owner | batch owner synchronization | Phase 57 evidence score | exact |
| `PLANS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md` | lifecycle ledgers | batch completed-state transition | Phase 57 owners, but audited after transition | exact with lifecycle change |
| `docs/meitu-function-blueprint/FEATURE_MATRIX.md`, `SHAPE_FEATURE_LEDGER.md` | product taxonomy ledgers | batch equality/no-promotion | existing future/future/future and partial/partial rows | exact |

No production file is implied by the locked branch. If a cancellation test needs
a helper, keep it private to the test file unless an existing Testing-only seam
is demonstrably insufficient. Do not add a public/SPI cancellation API, candidate
route, or cooperative-abort claim.

## Pattern Assignments

### Zero-admission facade and request-lifetime tests

**Extend:** `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift`

This file already owns both still facade entries, one request-local owner,
nonretention, valid-invalid-valid recovery, parallel/serialized behavior,
pixel-buffer/reset isolation, and exact-empty admission.

**Facade and nonretention pattern** (lines 25-52):

```swift
for entry in [SDKTestingStillImageFacadeEntry.process, .processResult] {
    let harness = try SDKTestingLocalRetouchFoundationHarness(admittedPrivateDemandCount: 1)
    _ = try harness.invoke(entry: entry, image: Self.image, parameters: .init(brightness: 0.1))
    XCTAssertEqual(harness.canonicalizeCount, 1)
    XCTAssertEqual(harness.detectAndMapCount, 1)
    XCTAssertEqual(harness.requestOwnerCreationCount, 1)
    XCTAssertEqual(harness.renderCount, 1)
}
// ...
XCTAssertEqual(harness.retainedRequestOwnerCount, 0)
```

**Valid-invalid-valid pattern** (lines 208-229): use one harness with a support
sequence, assert the malformed middle request clears mapped coordinates, then
assert fresh IDs and `retainedRequestOwnerCount == 0` after the third request.

**Parallel and same-harness serialization pattern** (lines 231-274): independent
harnesses must not cross payloads; a shared harness runs 32 complete transactions
and returns the exact set of request IDs with zero retained owners.

**Isolation pattern** (lines 276-293): pixel-buffer and reset invoke zero
canonicalization/detection/context/provider work, and production admission names
are exactly `[]`.

Apply these patterns to SAFE-01/02/03 and OUT-01/02. Add assertions for repeated,
valid-invalid-valid, serialized same-harness, parallel independent harness,
no-face, missing/malformed support, throw/recovery, unrelated-effect continuation,
both facade entries, literal `.none`, and zero candidate/admitted pair construction.
Do not expose anatomy or pixel identity to make the assertions possible.

### Cancellation publication discard

**Primary pattern:** caller-owned task cancellation around an intact synchronous
invocation. The closest synchronization mechanics are in
`BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift:1387-1498`:

```swift
let interrupted = Task { () -> Snapshot in
    await withCheckedContinuation { continuation in
        queue.async {
            let value = synchronousInvocation()
            continuation.resume(returning: value)
        }
    }
}
// wait until the synchronous work has entered
interrupted.cancel()
XCTAssertTrue(interrupted.isCancelled)
releaseWork()
let completedValue = await interrupted.value
```

Copy only the bounded entry/release/join structure. For Phase 58, the caller must
discard publication after cancellation, allow the one synchronous opaque
invocation to finish intact, then run a fresh request and publish only that fresh
aggregate result. Explicitly assert no retained request owner and no stale
aggregate observation. Do **not** copy Phase 52's stronger sibling/cooperative
cancellation semantics and do not claim TD-013.

`CameraSessionControllerTests.swift:62-81` is a secondary generation-token analog
for publication invalidation, but it is a realtime camera owner and must not be
imported into the still-image runtime. Its useful idea is only: an older generation
cannot be published after cancel/restart.

### Feature-neutral composition safety

**Extend/read:** `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift`

**Aggregate-only observation pattern** (lines 22-40): assert the exact Mirror
label allowlist and keep bytes/digests/source tokens absent.

**Failure and recovery pattern** (lines 96-139, 159-211): compare malformed local
work to accepted siblings while unrelated brightness/filter work continues;
snapshot each observation; a thrown middle request must reset to
`SDKTestingLocalCompositionObservation()` before a fresh request.

**No-admission and non-still isolation pattern** (lines 223-241): pixel buffer and
reset perform zero composition work; exact production admission count/names remain
`0`/`[]`.

Do not turn opaque A/B/C mechanics into teeth/sclera/eyelid product evidence and
do not add feature-named composition scenarios.

### Six-test opt-in Vision gate

The six existing opt-in tests are the owners; extend no skip mechanism and add no
new fixture picker:

- `VisionFaceDetectorTests.swift:477-501`
- `VisionFaceDetectorTests.swift:542-582`
- `VisionFaceDetectorTests.swift:584-624`
- `BeautyFaceGeometryAdapterTests.swift:753-819`
- `BeautyFaceGeometryAdapterTests.swift:820-...`
- `BeautyEngineGeometryFacadeTests.swift:656-...`

They all use this exact gate:

```swift
guard ProcessInfo.processInfo.environment[
    "BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS"
] == "1" else {
    throw XCTSkip("Set BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS=1 on the pinned Apple Vision host")
}
```

OUT-03 must run normal full SwiftPM separately, then rerun with the environment
variable set and prove all six named tests executed with **zero skips**. Record
only aggregate test totals. Do not put fixture names, paths, or per-image Vision
summaries into durable Phase 58 evidence.

### Phase 58 completed-state checker

**Create:** `check_phase58_closeout_boundaries.py`

**Analog:** `check_phase57_eye_gate_boundaries.py`

Copy these concrete structures:

- Configurable root and explicit owner paths (`configure_root`, lines 228-275).
- Tri-state `rg` handling where only return codes 0 and clean 1 are classified;
  anything else raises and fails closed (`classify_rg`, lines 278-298).
- Exact whole-document ASVS L1/HIGH inventory construction (`expected_inventory`,
  lines 301-327).
- `live_failures()` composition of independent classifiers (lines 1040-1053).
- Temporary real-repository copies, not synthetic contracts (`copy_fixture`,
  lines 1056-1065).
- Missing/unreadable fixture, scanner exception, exact stdout/empty stderr tests
  (lines 1694-1764).
- Exact unique root-owner anchors plus deletion, duplication, contradictory
  status/count/disposition mutations (lines 955-1037 and 1766-1792).
- Rule-only output and top-level exception collapse (`emit`/`main`, lines
  2002-2054).

Phase 58 must **not edit** the frozen Phase 57 checker. Invoke it as a subprocess
and require:

1. `--decision`, `--sclera`, `--eyelid`, and `--self-test` are green;
2. its aggregate denominator remains 519 and per-threat totals remain
   `65 / 68 / 90 / 143 / 23 / 81 / 7 / 42`;
3. after the Phase 57 transition, default mode returns the single expected fixed
   compatibility failure `R57-COMPAT`, with no traceback/path/raw detail;
4. the new checker independently proves that mismatch is the permitted frozen
   transition state and that all current Phase 57 completed owners, evidence,
   requirements, and ledgers are otherwise exact.

The new checker should scan the complete current production Swift tree and the
complete relevant Demo tree, add neutral-file mutations, and use fixed Phase 58
rule IDs. It must cover decision tampering, admission/candidate activation,
privacy disclosure, retention claims, compatibility drift, Demo/ledger promotion,
completed-owner deletion/duplication/count drift, scanner exceptions, raw-error
leakage, network/resource/model/dependency/artifact drift, and Vision skip-count
misreporting.

### Privacy, network, resource, and tracked-artifact scans

Use Phase 57's `source_failures`, `evidence_failures`, and compatibility/scanner
mutations as the closest analog, but scan whole owned trees and classify outcomes.
The durable allowlist is fixed reasons, aggregate timing/counts, and the exact six
composition counters. Reject raw support, landmarks, pupils, masks, pixels,
reviewer data, paths, digests, raw scanner output/errors, source tokens, anatomy,
and output identity from public/SPI/Codable, logs, metrics, persistence, network,
tracked artifacts, and evidence.

Do not ban legitimate existing shipped domains, Vision framework usage, bundled
five-preset resources, test-only local fixture loading, `.planning` evidence text,
or the disabled Demo taxonomy rows. Match candidate behavior in semantic context,
and keep exact allowlisted declarations where required.

### Demo and product ledger equality

**Extend:** `BeautyDemoViewStateTests.swift` for the exact three disabled rows and
nil active mappings. Follow the Phase 56/57 tests; assert exact IDs/titles/order,
empty controls, and no parameter/store/processor/reset mapping. Do not merely scan
for the Chinese labels because their disabled taxonomy declarations are required.

**Read/validate without promotion:**

- `SHAPE_FEATURE_LEDGER.md`: `去脂`, `祛红血丝`, `白牙` remain `future`.
- `FEATURE_MATRIX.md`: `眼睛` and `嘴唇` remain `partial`.
- Demo: all three named rows remain disabled and nil-mapped.

Use exact unique row equality and mutations that change one row to implemented,
duplicate it, remove it, borrow sibling/mechanics evidence, or activate its Demo
mapping. OUT-04 passes only when the promoted row set is exactly empty.

### Evidence lifecycle and root-owner equality

**Create:** `58-CLOSEOUT-EVIDENCE.md` using
`57-CLOSED-EYE-GATES-EVIDENCE.md:1-136` as the schema/lifecycle analog:

- exact frontmatter (`phase`, lifecycle `status`, ASVS L1, `block_on: HIGH`, exact
  requirement list);
- exact unique disposition, task, HIGH, final automated evidence, owner equality,
  privacy allowlist, and nonclaim sections;
- aggregate values only;
- draft until every final-only command is current and green;
- validated only after all focused/full/Vision/Demo/checker/GSD/owner gates pass.

Parse the document structurally. Do not accept a validated file because it merely
contains historical words such as `passed` or `validated`. Reject duplicate
frontmatter keys/sections/rows, pending results, count drift, contradictory
activation/readiness prose, and any sensitive payload.

Root-owner equality should follow Phase 57's exact unique-anchor map but use
Phase 58 completed-state expectations. Validate `PRODUCT_SENSE.md`, `SECURITY.md`,
`RELIABILITY.md`, `QUALITY_SCORE.md`, `PLANS.md`, ROADMAP, STATE, REQUIREMENTS,
both product blueprints, validation, evidence, and review/verification lifecycle.
Test missing, duplicate, stale, premature-complete, and contradictory variants.

## Shared Patterns

### Fail closed

Every ASVS L1 HIGH identity must pass independently. A missing/unreadable owner,
malformed JSON/frontmatter/table, unexpected subprocess result, scanner error,
unclassified match, stale count, or unknown rule collapses to a fixed blocking
rule. Never emit raw exception text or repository paths.

### Real-fixture mutations

Build temporary copies of current repository owners and rerun the actual live
classifier. Add neutral filenames for every candidate/retention/privacy family.
Synthetic string-contract self-tests are insufficient.

### Exact equality over lower bounds

Freeze literal `.none`, 59 stored/CodingKey fields, five presets, 72 renderer
cases, both still entries, zero admitted candidates, three disabled Demo rows,
future/future/future, partial/partial, exact task/decision/threat counts, and exact
Vision executed/skipped totals. Avoid `>=`, substring-only, or count-only gates.

### Testing and closeout order

Freeze focused tests and checker matrices first. Keep evidence draft while waves
remain. Run full SwiftPM, the separate opt-in Vision command, explicit Demo build
and full tests, all prior checkers, Phase 58 aggregate/per-threat modes, privacy/
network/resource/artifact scans, GSD gates, diff hygiene, root-owner equality,
review/fix, and independent verification before validation/final lifecycle
promotion.

## Review-Derived Anti-Patterns

- **Address-only identity (Phase 55 CR-01):** never authorize request-local data
  using a bare `ObjectIdentifier`; the production fix retains strong opaque
  identities and compares with `===`.
- **Invalid work consuming sibling budget (Phase 55 CR-02):** validate before
  issuance; malformed work cannot starve a valid sibling.
- **Per-property locking (Phase 55 WR-01):** it does not serialize a complete
  request transaction. Test complete same-harness transactions.
- **Synthetic checker contracts (Phase 55 WR-02):** mutations must alter copies of
  real files and execute the live classifier.
- **Substring lifecycle checks (Phase 56 CR-01 / Phase 57 CR-04):** parse exact
  frontmatter and tables; reject contradictory positive claims.
- **Known-file-only candidate scans (Phase 56 verifier gap):** recurse through all
  production Swift, including neutral filenames.
- **Incomplete alias/identity families (Phase 56 CR-02; Phase 57 CR-01/03 and
  verifier gap):** cover camel, snake, dotted Demo IDs, Chinese owned labels, and
  neutral-file candidate-to-proxy relations without repository-wide prose bans.
- **Known Demo-owner-only scans (Phase 57 CR-02):** recurse across the relevant
  Demo Swift tree while allowing only the exact disabled declarations.
- **Loose privacy regexes (Phase 57 CR-05):** use exact aggregate-only evidence
  structure plus comprehensive payload mutations.
- **Raw exception fallthrough (Phase 57 CR-06):** every CLI mode catches errors and
  emits fixed rules with empty stderr.
- **Claimed but untested owner equality (Phase 57 CR-07):** mutate every root and
  lifecycle owner, including deletion, duplication, count drift, and conflicting
  status.
- **Editing the frozen prior checker:** Phase 58 audits Phase 57's completed state
  externally; it must not weaken or rewrite the 519-case checker.
- **Overclaiming cancellation:** publication discard around intact synchronous work
  is not cooperative abort or a public concurrency guarantee.

## Files to Extend vs. Files to Preserve

Extend focused tests in the existing foundation/composition/Demo owners. Create
only the Phase 58 checker, threat inventory, evidence, and validation artifacts.
Update root/lifecycle owners only at their planned closeout point.

Preserve production `BeautySDK/Sources/**`, the Phase 54 decision ledger, Phase 55
feature-neutral mechanics, the Phase 56/57 closed routes, the Phase 57 checker,
all six existing opt-in Vision test bodies, the three disabled Demo declarations,
and shipped proxy behavior unless an existing SAFE contract test exposes a real
defect.

## No Analog Found

None. Phase 58 is deliberately composed from existing facade, safety, checker,
evidence, and lifecycle patterns. There is no legitimate analog for a new visible
retouch provider/output because the admitted feature set is empty.

## Metadata

**Analog search scope:** `BeautySDK/Tests`, `BeautyDemo/BeautyDemoTests`, Phase
53-57 plans/summaries/reviews/verifications/checkers/evidence, root contract
owners, and Meitu ledgers.

**Strong analogs used:** 5 primary code/checker/evidence families.

**Pattern extraction date:** 2026-08-04
