---
phase: 89-semantic-validation-baseline
verified: 2026-08-26T04:58:25Z
status: passed
score: 13/15 must-haves verified
overrides_applied: 0
deferred:
  - truth: "Every in-scope direction currently receives a complete source-plus-neutral semantic verdict from the owner-local command"
    addressed_in: "Phase 91"
    evidence: "Phase 91 success criteria require pupil displacement from each eye's own center, independent per-eye support, and source-safe missing/implausible support handling. Those are the exact anatomical facts the current gaze metric refuses to proxy."
  - truth: "A current full invocation publishes the promised five-batch/65-case/eight-direction aggregate and retained watermarked outputs"
    addressed_in: "Phase 95"
    evidence: "Phase 95 success criterion 3 explicitly requires a clean authorized-portrait rerun completing 65/65 outputs and reporting all eight directions effective through semantic and protection gates."
---

# Phase 89: Semantic Validation Baseline Verification Report

**Phase Goal:** The owner can run one repeatable SDK-owned portrait command and receive trustworthy semantic pass/fail evidence for every in-scope repair direction.
**Verified:** 2026-08-26T04:58:25Z
**Status:** passed after later-phase deferral filtering
**Re-verification:** No — initial verification

## Goal Achievement

Phase 89's validation machinery is real and fail-closed. The current implementation does **not** publish the superseded historical `1/8 semantic_pass, 7/8 semantic_fail` payload: code review correctly removed the dark-pixel gaze proxy, and the production comparator now throws `unsupported_metric` before any complete eight-direction payload can be published. This preserves trust but leaves two literal roadmap outcomes unavailable today. They are deferred below because Phase 91 explicitly owns the missing independent pupil/own-eye support and Phase 95 explicitly owns the final 65/65, eight-direction rerun.

### Observable Truths

| # | Truth | Status | Evidence |
|---|---|---|---|
| 1 | The manifest contains exactly five batches, 65 unique selected renderer cases, and eight ordered semantic contracts. | ✓ VERIFIED | `jq` reports `5/65/65 unique/8`; runner preflight independently reports `live=75 selected=65 semantic=8`. |
| 2 | Every frozen contract names source and neutral comparisons, target and protected regions, a direction-specific metric/sign, fixed signal/locality thresholds, and protection ceilings. | ✓ VERIFIED | `SemanticContract`, `ExpectedSemanticContract`, and the pinned contract digest validate all eight records in `compare-face-feature-batches.swift:45-52,243-276,344-428`; the manifest contains the corresponding fixed integers. |
| 3 | Generated tests exercise exact boundaries, one-unit mutations, ownership, ordering, arithmetic, reports, privacy, and verdict derivation without authorized portraits. | ✓ VERIFIED | Independent `--self-test` passed `554` mutations with the named categories and exact `5/65/8` inventory. |
| 4 | Malformed, duplicate, reordered, overlapping, out-of-range, empty, unknown, or arithmetic-overflow contract state fails before image work. | ✓ VERIFIED | `validateManifestData` and ownership/rasterization checks are substantive; the 554-mutation self-test exercises each rejection class. |
| 5 | One current full command publishes all five-batch/65-case outputs and a complete eight-direction aggregate. | ✗ FAILED (DEFERRED) | The runner is wired to render 66 units per attempt, but `pupilToOwnEyeCenter` deliberately throws `unsupported_metric` (`compare-face-feature-batches.swift:759-764`), so the comparator exits infrastructure failure, attempts are not retained, and only a sanitized failure envelope is published. Phase 95 SC3 owns the full rerun. |
| 6 | Every one of the eight directions currently receives source-plus-neutral semantic measurement and a pass/fail verdict. | ✗ FAILED (DEFERRED) | Seven real metric implementations exist. Gaze is intentionally non-creditable until independent pupil/eye-contour anatomy exists; the self-test proves lash/shadow and foreign-dark-patch proxies cannot earn credit. Phase 91 SC1-3 own exactly that missing per-eye support. |
| 7 | Watermark rows are excluded from source, neutral, target, outside, sibling, mechanical, and protected measurements. | ✓ VERIFIED | `watermarkExcludedRows`, `watermarkSafeRegions`, `regionSignal`, and `metrics` all clamp comparison to rows above the watermark; empty clipped watermark protection contributes zero rather than evidence. |
| 8 | Arbitrary changed-pixel summaries cannot set a semantic-effective verdict. | ✓ VERIFIED | Mechanical rows are emitted only as `complete_mechanical_summary`; `semanticMeasurement`/`deriveSemanticFailureReasons` require target signal, both signed comparisons, sibling distinction, locality, and every protection ceiling. Mutated inconsistent verdict/reason payloads are rejected. |
| 9 | Stable report data is aggregate-only, deterministically ordered, separately digested, and independent of volatile attempt metadata. | ✓ VERIFIED | `StableSemanticPayload` excludes timestamp/attempt ID; stable encoding canonicalizes fixture, batch, case, direction, protection, and failure-reason order before SHA-256. Reordering probes preserve identical bytes/digest. |
| 10 | Missing, malformed, escaped, symlinked, duplicate, dimension-changing, stale, unsupported, or incomplete input cannot publish semantic success. | ✓ VERIFIED | Comparator admission is fail-closed and runner boundary tests passed stale pass/fail replacement, alias preservation, symlink-parent preservation, invalid reports, path-component boundaries, and three preflight infrastructure faults. |
| 11 | Two independent CPU attempts must reconcile stable payload bytes, digest, and completion class before publication. | ✓ VERIFIED | `run-face-feature-batches.sh:692-780` invokes the comparator twice, validates exact `5/65/8`, byte-compares sorted payload JSON, compares digests/status, and independently recomputes the reconciliation digest. |
| 12 | Retained media is owner-local and watermarked; repeat media, renderer/comparator reports, workspaces, logs, and child transcripts are temporary and verified removed before semantic publication. | ✓ VERIFIED | Descriptor-relative cleanup and retained-inventory checks are substantive; cleanup failure forces exit 2 and blocks credit. `.gitignore` contains the local report boundary. |
| 13 | Complete semantic failure is distinct from infrastructure failure, and stale safe reports are replaced atomically with a current sanitized envelope. | ✓ VERIFIED | Exit 0/3/2 classes are distinct; `publish_failure_envelope` allowlists fixed reasons/counts and atomically replaces an admitted report. Boundary tests passed stale pass and stale fail replacement. |
| 14 | Owner documentation, quality, security, reliability, and planning ledgers match the implemented privacy/status/nonclaim contract without promoting repairs. | ✓ VERIFIED | Current owner sections explicitly revoke the pre-review gaze aggregate, document `unsupported_metric` and exit 2, preserve aggregate-only evidence, and leave repair ownership to Phases 90-94. |
| 15 | Compatibility and SDK-only gates preserve 62 parameters, five presets, 75 renderer cases, public facades, and CPU/GPU contracts. | ✓ VERIFIED | Focused SwiftPM selection passed `107/0`; archive verification and post-archive SDK-only boundary passed; runner preflight reports 75 live cases; `git diff --check` is clean. |

**Score:** 13/15 truths currently verified; two failed truths are explicitly deferred by later roadmap success criteria.

### Deferred Items

| # | Item | Addressed In | Evidence |
|---|---|---|---|
| 1 | Independent gaze semantic measurement is unavailable without pupil/own-eye anatomy. | Phase 91 | SC1 requires pupil displacement from that eye's own center; SC2-3 require independent support and source-safe per-eye degradation. |
| 2 | The current command cannot publish/retain a complete eight-direction run because gaze aborts aggregate construction. | Phase 95 | SC3 requires a clean 65/65 rerun with all eight directions reported through semantic and protection gates. |

### Required Artifacts

| Artifact | Expected | Status | Details |
|---|---|---|---|
| `scripts/face-feature-batch-manifest.json` | Exact 5/65 inventory plus eight frozen contracts | ✓ VERIFIED | Exists, substantive, decoded and digest-pinned by the comparator. |
| `scripts/compare-face-feature-batches.swift` | Contract validation, seven metric kinds/eight directions, stable aggregate report, mutation gate | ⚠ PARTIAL / DEFERRED | 3,014 lines, wired and extensively tested. Seven metrics flow; gaze correctly fails closed as unsupported, preventing a complete live payload until Phase 91. |
| `scripts/run-face-feature-batches.sh` | Exact inventory admission, two attempts, atomic publication, cleanup, status classes | ✓ VERIFIED | 813 lines, calls the public renderer and comparator, reconciles payloads, and atomically publishes only complete semantic or sanitized infrastructure envelopes. The plan's literal `contains: semantic_failure` check is a stale spelling expectation; implemented behavior uses `semantic_fail` and `SemanticExitCode.semanticFailure`. |
| `scripts/face-feature-path-helper.py` | Descriptor-relative, no-follow path mutation support | ✓ VERIFIED | 454 lines; spaces, Unicode, 120/121/255-byte components, symlink parents, and atomic operations are covered by boundary tests. |
| `scripts/test-face-feature-batch-boundaries.py` | Runner stale/path/preflight adversarial checks | ✓ VERIFIED | 240 lines; independent run passed all reported probes. |
| `example-images/README.md` | Owner-facing command/report/status/privacy contract | ✓ VERIFIED | Documents current unsupported-gaze behavior rather than repeating the superseded summary claim. |
| `QUALITY_SCORE.md` | Bounded validation evidence without repair promotion | ✓ VERIFIED | Explicitly revokes the prior gaze-based aggregate and preserves nonclaims. |
| `SECURITY.md` | Manifest/path/report/transcript trust boundary | ✓ VERIFIED | Aggregate allowlist, request-local sensitive state, path admission, cleanup, and failure publication are synchronized with code. |
| `RELIABILITY.md` | Fresh attempts, deterministic reconciliation, stale recovery, exit classes | ✓ VERIFIED | Matches current executable behavior, including unsupported gaze as non-creditable infrastructure failure. |
| `PLANS.md` | Honest Phase 89 ledger and downstream ownership | ✓ VERIFIED | Records the historical aggregate as revoked and current execution as bounded/fail-closed. |

### Key Link Verification

| From | To | Via | Status | Details |
|---|---|---|---|---|
| Manifest | Comparator | `BatchManifest.semanticContracts` decode, exact expected inventory, pinned digest | ✓ WIRED | `verify.key-links` passed and implementation validates every record before image decode. |
| Source + neutral + candidate/sibling PNGs | Comparator metrics | One oriented explicit-sRGB canonical decode and watermark-safe regions | ⚠ PARTIAL / DEFERRED | Real data flows for seven metrics; gaze stops as `unsupported_metric` rather than borrowing a proxy. |
| Runner | `BeautyExampleRenderer` | `--list-cases`, explicit `--case`, `--backend cpu` | ✓ WIRED | Preflight confirms 75 live cases; render loop requests neutral plus all 65 selected cases per attempt. |
| Runner | Comparator | Two temporary reports, exact shape validation, stable-byte/status/digest reconciliation | ✓ WIRED | Both comparator invocations and independent Python reconciliation are present and substantive. |
| Runner | Public report | Cleanup gate then descriptor-relative atomic write | ✓ WIRED | Semantic publication requires verified cleanup; infrastructure failures use a sanitized fixed envelope. |
| README / owners | Runner contract | Exact command, flags, statuses, privacy, retention, nonclaims | ✓ WIRED | Documentation reflects post-review code, not the original summary narrative. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|---|---|---|---|---|
| Comparator | `mechanicalCases` | Canonical source/neutral/candidate PNG buffers | Yes, for all 65 selected cases after complete inventory admission | ✓ FLOWING |
| Comparator | `semanticDirections` | Eight contracts + source/neutral/candidate/sibling images | Seven directions flow; gaze rejects missing anatomical ownership | ⚠ DEFERRED |
| Comparator | `stablePayloadDigest` | Canonically ordered aggregate payload bytes | Yes; recomputed and mutation-tested | ✓ FLOWING |
| Runner | `publication_document` | Two validated comparator payloads | Yes only when both complete; currently blocked by unsupported gaze | ⚠ DEFERRED |
| Runner | failure envelope | Fixed failure reason + admitted 75/65/8 counts | Yes; aggregate-only and atomically written | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|---|---|---|---|
| Contract, metric, report, privacy, and verdict mutation gate | `swift scripts/compare-face-feature-batches.swift --self-test` | `PASS mutations=554 inventories=5/65/8` | ✓ PASS |
| Stale-report, alias, symlink, component, and preflight failure boundaries | `python3 scripts/test-face-feature-batch-boundaries.py` | All named probes passed; preflight faults `3`, unchanged state `1` | ✓ PASS |
| Live inventory admission without mutation | `bash scripts/run-face-feature-batches.sh --preflight-only` | `PASS live=75 selected=65 semantic=8` | ✓ PASS |
| Comparator compiles | `swiftc -typecheck scripts/compare-face-feature-batches.swift` | exit 0 | ✓ PASS |
| Focused compatibility suite | `swift test --package-path BeautySDK --filter 'BeautyParametersTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests|BeautyEngineMetadataCompatibilityTests|BeautyBackendContractTests|BeautyBackendSelectionConcurrencyTests'` | `107 tests, 0 failures` | ✓ PASS |
| Archive trust and SDK-only boundary | `python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui` then `bash scripts/check-sdk-only-boundary.sh --post-archive` | Two pinned archives verified; boundary passed | ✓ PASS |

The verifier did not run the full portrait command because it writes ignored owner-local media and reports, and current source tracing already proves its all-or-nothing comparator will terminate on the gaze metric. The project policy treats deterministic SDK-owned automation as primary evidence and does not require physical-device or visual review for this validation-only phase.

### Probe Execution

No conventional or phase-declared `probe-*.sh` files exist for Phase 89. The phase-declared runnable checks are recorded under Behavioral Spot-Checks.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|---|---|---|---|---|
| VAL-01 | 89-01 through 89-04 | One command writes 65 watermarked outputs and a source-plus-neutral aggregate report | ⚠ PARTIAL / DEFERRED | Inventory, renderer wiring, output paths, and report machinery exist; current gaze abstention prevents complete publication. Phase 95 SC3 owns the full rerun. |
| VAL-02 | 89-01 through 89-04 | Every direction has deterministic semantic, locality, signal, and protection assertions; arbitrary differences cannot pass | ⚠ PARTIAL / DEFERRED | Seven metrics and all eight frozen contracts are real; gaze refuses an unsafe proxy until Phase 91 supplies independent anatomy. Arbitrary-difference rejection is verified. |

No additional Phase 89 requirement is orphaned from plan frontmatter or roadmap traceability.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|---|---|---|---|---|
| `scripts/compare-face-feature-batches.swift` | 759-764 | `unsupportedMetric` for gaze | ℹ️ Info | Intentional fail-closed ownership boundary, not a stub; prevents false pupil credit from lashes/shadows/dark patches. |

No phase-added `TBD`, `FIXME`, `XXX`, `TODO`, `HACK`, placeholder, empty-handler, static-empty-output, or console-only implementation was found in the executable/artifact changes.

### Disconfirmation Pass

- **Partial requirement found:** VAL-01/VAL-02 cannot currently produce an eight-direction live aggregate because gaze lacks admitted anatomy. This is recorded, not softened into a semantic failure.
- **Potentially misleading green test checked:** `--self-test` proves report machinery and deliberately proves gaze is unsupported; it does not prove the current full command returns semantic exit 0/3. The report does not use it as such evidence.
- **Error path checked:** comparator exit outside 0/2 maps to runner infrastructure failure; the EXIT trap publishes a fixed sanitized envelope only to an independently admitted report destination. Boundary tests cover stale-report replacement, alias preservation, and preflight faults.

### Human Verification Required

None. Visual quality, physical-device behavior, naturalness, population coverage, and commercial readiness are explicit nonclaims and are not Phase 89 completion gates. The two code-review items marked “requires human verification” now have deterministic path-component and preflight-fault regression probes that passed independently.

### Gaps Summary

No actionable Phase 89 gap remains after roadmap deferral filtering. The literal eight-direction live aggregate is not currently available, but the implementation fails closed rather than accepting a proxy. Phase 91 must provide independent pupil/own-eye support before gaze can become creditable, and Phase 95 must prove the final clean 65/65, eight-direction publication. If either later phase omits that wiring, the milestone closeout must fail.

---

_Verified: 2026-08-26T04:58:25Z_
_Verifier: the agent (gsd-verifier)_
