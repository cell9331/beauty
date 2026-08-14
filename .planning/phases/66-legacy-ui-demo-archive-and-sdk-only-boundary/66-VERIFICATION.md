---
phase: 66-legacy-ui-demo-archive-and-sdk-only-boundary
verified: 2026-08-14T03:48:41Z
status: passed
score: 6/6 must-haves verified
overrides_applied: 0
automated_checks:
  archive_verify: passed
  artifact_only_reproduce: passed
  safe_restore_and_exact_compare: passed
  retirement_postcondition: passed
  archive_self_test: passed
  boundary_self_test: passed
  post_archive_scan: passed
  transcript_self_test: passed
  full_no_skip_swiftpm: "passed: 650 tests, 0 failures, 0 skips, 8/8 opt-ins"
  diff_hygiene: passed
requirements:
  BOUNDARY-01: satisfied
  BOUNDARY-02: satisfied
  ARCHIVE-01: satisfied
  ARCHIVE-02: satisfied
  ARCHIVE-03: satisfied
non_claims:
  - no active UI, Demo, application lifecycle, simulator, device, or UI-automation surface
  - no new or modified Metal/GPU API, backend, shader behavior, or beauty algorithm
  - no device, population, performance-budget, commercial, packaging, distribution, shipping, launch, or release-readiness conclusion
---

# Phase 66: Legacy UI/Demo Archive and SDK-Only Boundary Verification Report

**Phase Goal:** Maintainers have a verified historical copy of the legacy UI/Demo while the active repository exposes only SDK-owned build, test, documentation, and command-line validation surfaces.
**Verified:** 2026-08-14T03:48:41Z
**Status:** passed
**Re-verification:** No — initial independent verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | A maintainer can inspect and safely recover both exact historical inventories from pinned ZIP, manifest, and SHA-256 artifacts. | ✓ VERIFIED | The verifier independently checked `45` BeautyDemo entries (`342,685` bytes) and `26` meituxiuxiu entries (`88,650,871` bytes), including exactly `19` PNGs. ZIP paths, entry order, sizes, per-file SHA-256 values, manifests, and extracted files agree. Safe `restore` into a fresh private temporary directory reproduced `45/45` and `26/26` files exactly and the temporary copy was cleaned. |
| 2 | SDK integrators can use an SDK-owned effect taxonomy without treating historical layout or application behavior as requirements. | ✓ VERIFIED | `docs/SDK_EFFECT_TAXONOMY.md` contains the boundary language, exact `61`-field public inventory, and `63` legacy taxonomy rows with implemented/partial/future statuses. The boundary scanner compares all 61 fields to `BeautyParameters.swift` and compares every taxonomy row/status/mapping to its code-owned expected authority. |
| 3 | The active tree contains no original Demo executable, SwiftUI source, Xcode application project, or selected legacy UI-reference tree. | ✓ VERIFIED | `BeautyDemo/` and `meituxiuxiu/` are absent. Active source scanning found no Xcode project/workspace/scheme/test-plan artifact, SwiftUI import, or XCUI symbol; tracked media inventory is empty. The post-archive scanner passed and its mutation suite rejects restored roots, Xcode artifacts, SwiftUI/XCUI source, tracked media, active symlinks, shader drift, and GPU API drift. |
| 4 | Current build, test, documentation, planning, and command-line validation surfaces are SDK/SwiftPM-only. | ✓ VERIFIED | `BeautySDK/Package.swift` declares the `BeautySDK` library, `BeautyExampleRenderer` executable, internal/library targets, and six SwiftPM test targets. Root owners, `docs/README.md`, all seven current codebase maps, live planning owners, and the no-skip script passed the canonical current-owner scan. `ARCHITECTURE.md` and `FRONTEND.md` explicitly make archive material historical and non-executable. |
| 5 | Retirement was a fail-closed exact-target transaction, not an unchecked deletion. | ✓ VERIFIED | `retire_sources` requires two digest approvals, rejects pre-existing tracked deletion, quarantines both exact non-symlink roots, validates frozen descriptor-read inventories against manifests and pinned ZIP digests, checks the absolute deletion allowlist and sentinel fingerprints, and preserves quarantine on collision. The archive self-test covers late untracked mutation, symlink swap, unrelated deletion, and post-quarantine replacement collision. Git inspection independently proves commit `8a9274a` deleted exactly 53 tracked paths under the two intended roots and no unrelated path. |
| 6 | The mandatory no-skip closeout verifies archive and repository boundaries before one complete SwiftPM test child. | ✓ VERIFIED | Fresh execution of `bash scripts/run-no-skip-swiftpm.sh` emitted `no_skip_archive_verified` and `no_skip_sdk_boundary_verified` before the child, then executed exactly `650` XCTest tests with `0` failures and `0` skips; all eight opt-in identities passed exactly once, Swift Testing reported `0` tests/`0` suites passed, and the wrapper ended `no_skip_swiftpm_passed opt_in_tests=8 skipped_tests=0`. |

**Score:** 6/6 truths verified

### Roadmap Success Criteria Coverage

| Roadmap criterion | Status | Evidence |
| --- | --- | --- |
| Explicit scope, deterministic manifests/digests, independent extraction and listing/content agreement | ✓ VERIFIED | Truth 1; canonical verification, independent ZIP/manifest walk, safe restore, and exact extracted comparison all passed. |
| SDK-owned taxonomy without layout/application dependency | ✓ VERIFIED | Truth 2; exact 61-field/63-row authority and taxonomy mutation checks passed. |
| Clean checkout has no active original Demo, SwiftUI, Xcode app project, or legacy reference tree | ✓ VERIFIED | Truth 3; both roots absent and active artifact/source scans passed. |
| Active commands resolve only to SwiftPM/SDK-owned validation with no Xcode/simulator/device/deleted-tree dependency | ✓ VERIFIED | Truths 4 and 6; current-owner scan and integrated no-skip closeout passed. |

## Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `scripts/archive-legacy-ui.py` | Deterministic archive, pinned verification, safe restore, guarded retirement | ✓ VERIFIED | 1,322 substantive lines; canonical policies pin ZIP/manifest digests, sizes, counts, paths, maxima, and ratio. Descriptor-relative no-follow inventory, streamed verification/extraction, quarantine rollback, collision preservation, and mutation self-tests are implemented and executed. |
| `archives/legacy-ui/BeautyDemo-v1.16.*` | Exact 45-file historical bundle | ✓ VERIFIED | ZIP digest `04c14bbaa201cc6e9100f4c7b272b697670014041e62804dfa2f561faa29db52`; manifest digest `38314c3aa1e70918921e660308bf64b78ca85b5fac4a222ef66ae5e80250f694`; 45 exact files. |
| `archives/legacy-ui/meituxiuxiu-v1.16.*` | Exact 26-file historical bundle with 19 PNG references | ✓ VERIFIED | ZIP digest `330e8aa08155eb4ad3a7b2ab84773a8279a8cd3ae87d4737b93e2491232fce9a`; manifest digest `76037b046eb1b2eb3a5df56702d1a17875db5e0634ca2b02904234bef601216d`; 7 text/HTML files plus 19 PNGs. |
| `archives/legacy-ui/README.md` | Scope, exclusions, verification, safe restore, failure recovery | ✓ VERIFIED | Documents exact artifacts/counts/digests/resource bounds and uses only verifier-backed restore into a fresh temporary destination. No direct pre-verification extraction is documented. |
| `docs/SDK_EFFECT_TAXONOMY.md` | Current SDK effect/control authority | ✓ VERIFIED | Exact source-field equality and row/status/mapping validation passed. Visual layout and application lifecycle are explicitly excluded. |
| `scripts/check-sdk-only-boundary.sh` | Pre/post archive boundary and mutation scanner | ✓ VERIFIED | 530 substantive lines; taxonomy, owner, active-source, symlink, Xcode/UI, media, Metal digest, and GPU API checks are wired and its self-test passed. |
| `scripts/check-no-skip-transcript.py` | Bounded exact XCTest/Swift Testing transcript accounting | ✓ VERIFIED | 16 MiB/200,000-line bounds, exact aggregate checks, zero denominator/failure/skip/disabled rejection, and exact opt-in identity counting. Self-test passed. |
| `scripts/run-no-skip-swiftpm.sh` | Archive → boundary → one SwiftPM child closeout | ✓ VERIFIED | Directly invokes archive verification and post-archive scan before a single bounded all-opt-ins `swift test`; fresh complete run passed. |
| Current root owners and codebase maps | SDK-only current contract | ✓ VERIFIED | Required owner inventory exists, is non-symlinked, contains SDK-only/SwiftPM markers, and passed the current-fragment forbidden-command scan. |

## Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| Archive artifacts | Independent trust policy | `CANONICAL_BUNDLE_POLICIES` ZIP/manifest digest, count, size, path, and ratio anchors | ✓ WIRED | A self-consistent empty replacement bundle was independently rejected before extraction. |
| Archive manifests | Safe extraction | `verify_bundle_stream` preflights all metadata, then streams hash/write and re-walks output | ✓ WIRED | Canonical verify plus fresh temporary restore/exact comparison passed. |
| Retired source roots | Archive evidence | quarantine inventory → manifest equality → deterministic pinned ZIP digest | ✓ WIRED | Late mutation and collision rollback tests passed; exact retirement commit scope independently inspected. |
| Taxonomy | Public SDK parameters | scanner extracts all public `BeautyParameters` vars and exact taxonomy block | ✓ WIRED | 61/61 public fields and all 63 legacy rows passed. |
| Current owners/source | SDK-only invariant | `check-sdk-only-boundary.sh --post-archive` | ✓ WIRED | Canonical scan and mutation self-test passed. |
| No-skip wrapper | Archive and boundary checks | sequential verifier/scanner calls before transcript capture | ✓ WIRED | Fresh wrapper output proves both predecessor markers occurred before build/test output. |
| SwiftPM child transcript | Gate result | bounded capture → exact aggregate/skip/opt-in parser | ✓ WIRED | 650/0/0 and 8/8 observed; parser mutation self-test passed. |

## Data-Flow Trace (Level 4)

| Artifact | Data variable | Source | Produces real data | Status |
| --- | --- | --- | --- | --- |
| Archive verifier/restore | manifest path, size, SHA-256 rows | Pinned committed manifests and a stable ZIP snapshot | Yes — 71 real entries streamed, hashed, restored, and independently compared | ✓ FLOWING |
| Boundary scanner | current owner/source filesystem inventory | Live checkout plus Git tracked/ignored classification | Yes — canonical scan and adversarial mutations exercise pass/fail paths | ✓ FLOWING |
| No-skip closeout | bounded child transcript | One real `swift test --package-path BeautySDK` child with eight opt-ins | Yes — parser consumed the real 650-test transcript and returned success | ✓ FLOWING |

No dynamic UI/data-rendering artifact exists in this SDK-only phase; component-style hollow-prop analysis is not applicable.

## Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Canonical bundles verify after original removal | `python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui` | Both pinned ZIP digests verified; extracted listing/content checks passed | ✓ PASS |
| Artifact-only reproduction remains valid | `python3 scripts/archive-legacy-ui.py reproduce --output archives/legacy-ui` | Both roots absent; code-owned trust anchors reverified | ✓ PASS |
| Safe restoration is exact and outside the repository | `archive-legacy-ui.py restore` into `TemporaryDirectory`, then independent SHA-256 comparison | 45/45 and 26/26 exact; temporary directory cleaned | ✓ PASS |
| Retirement postcondition holds | `python3 scripts/archive-legacy-ui.py retire --output archives/legacy-ui --verify-only-postcondition` | Roots absent, artifacts valid, sentinels intact | ✓ PASS |
| SDK-only active boundary holds | `bash scripts/check-sdk-only-boundary.sh --post-archive` | `POST-ARCHIVE SDK BOUNDARY PASSED` | ✓ PASS |
| Full mandatory closeout holds | `bash scripts/run-no-skip-swiftpm.sh` | 650 tests, 0 failures, 0 skips, 8/8 opt-ins, exit 0 | ✓ PASS |

## Independent Critical Regression Probes

| Probe | Command | Result | Status |
| --- | --- | --- | --- |
| Archive corruption, path safety, resource bounds, source symlink race, retirement rollback/collision, and safe restore | `python3 scripts/archive-legacy-ui.py self-test` | `SELF-TEST PASSED` | PASS |
| Restored roots, Xcode/SwiftUI/XCUI artifacts, current-owner drift, media, symlinks, Metal and GPU drift | `bash scripts/check-sdk-only-boundary.sh --self-test` | `SDK BOUNDARY SELF-TEST PASSED` | PASS |
| XCTest/Swift Testing failure, skip/disabled, duplicate/contradictory aggregate, missing summary, byte/line overflow | `bash scripts/run-no-skip-swiftpm.sh --self-test` | `NO-SKIP TRANSCRIPT SELF-TEST PASSED` | PASS |
| Review CR-01 regression: self-consistent empty replacement bundle | Direct `verify_bundle_bytes` invocation with matching empty ZIP/header-only manifest/digest | Rejected against independent pinned compressed-size authority | PASS |

No conventional `scripts/*/tests/probe-*.sh` or phase-declared `probe-*.sh` exists, so there is no separate Step 7c probe file to execute.

## Requirements Coverage

| Requirement | Source plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| BOUNDARY-01 | 66-03 | Only SwiftPM products/targets/tests and SDK-owned CLI validation are active | ✓ SATISFIED | Package inventory, current-owner scan, source/artifact scan, and full no-skip run. The unchecked REQUIREMENTS checkbox remains orchestrator-owned lifecycle metadata, not an implementation absence. |
| BOUNDARY-02 | 66-01, 66-03 | Preserve algorithm taxonomy in SDK-owned text without UI behavior | ✓ SATISFIED | Exact 61-field/63-row taxonomy authority, boundary tokens, and scanner equality. |
| ARCHIVE-01 | 66-01, 66-02 | Explicit ZIP scope excluding transient/per-user content | ✓ SATISFIED | Exact 45/26 inventories; prior-tree comparison found one excluded tracked `xcuserdata` file; no manifest path contains an excluded class. |
| ARCHIVE-02 | 66-01, 66-02 | Deterministic manifest/digest plus extraction/content agreement before deletion | ✓ SATISFIED | Canonical pinned digests, normalized ZIP metadata, byte/content verification, safe extraction, and deterministic live-source creation path exercised by self-test. |
| ARCHIVE-03 | 66-02, 66-03 | Originals absent and no active dependency remains | ✓ SATISFIED | Both roots absent; exact 53-path retirement commit; post-archive/current-owner scans and integrated gate passed. |

All five Phase 66 requirement IDs are claimed by plans and mapped exactly once to Phase 66 in `REQUIREMENTS.md`; no orphaned Phase 66 requirement was found.

## Plan Prohibitions

| Prohibition | Status | Evidence |
| --- | --- | --- |
| Transient, cache/build, `.DS_Store`, or per-user Xcode state enters an archive | ✓ ENFORCED | Manifest exclusion scan is clear; pre-retirement tree comparison records the single tracked `xcuserdata` exclusion. |
| Tooling deletes source before both archives pass | ✓ ENFORCED | Retirement requires both fresh verified digests, then quarantines and validates both frozen roots before irreversible deletion. |
| Git-tracked-only enumeration omits 19 ignored PNG references | ✓ ENFORCED | Filesystem inventory policy plus exact 19-PNG assertion; retained archive has exactly 19 PNGs beyond the seven tracked text/HTML files. |
| Digest, safe-path, extraction, listing, content-hash, or resource-bound failure can be accepted | ✓ ENFORCED | Pinned preflight and mutation tests reject every listed failure class. |
| Current docs/scripts require deleted Xcode, SwiftUI, simulator/device, or UI-test surfaces | ✓ ENFORCED | Current-fragment owner scan and active source/artifact scan passed. |
| Phase 66 claims Metal/GPU, commercial, packaging, shipping, or release readiness | ✓ ENFORCED | Owners explicitly state these are absent/out of scope; retained `Warp.metal` is byte-pinned and any Metal inventory/content or GPU API drift fails the scanner. |

## Anti-Patterns Found

| File | Line/pattern | Severity | Impact |
| --- | --- | --- | --- |
| `scripts/archive-legacy-ui.py` | Literal `placeholder` in malicious ZIP self-test data | ℹ️ Info | Adversarial fixture only; it is expected to fail and does not flow to production/archive output. |
| `.planning/codebase/STRUCTURE.md` | “placeholder shader resource” | ℹ️ Info | Documents the pre-existing inactive, byte-pinned `Warp.metal` non-claim; no new backend or behavior exists. |
| `.planning/ROADMAP.md` | Six `TBD` plan-count values for Phases 67-69 | ℹ️ Info | Structured scheduling placeholders for three explicitly named later phases, not unresolved Phase 66 implementation debt. Phase 66 itself is `3/3` and verification-pending. |
| `PLANS.md` | Historical rows quote `TODO`/`TBD`/`FIXME` as earlier scan patterns | ℹ️ Info | The tokens occur inside immutable historical verification narration saying those scans had no matches; they are not live debt markers. |

No actionable unreferenced debt marker, empty implementation, console-only handler, user-visible placeholder, or hardcoded empty dynamic data was found in Phase 66 implementation artifacts.

## Disconfirmation Notes

- `reproduce` in the current artifact-only state intentionally re-verifies pinned anchors; it cannot rebuild from deleted live roots. This is not used as evidence of current live-source reproducibility. Pre-retirement equivalence is instead corroborated by canonical paths/digests, the prior-tree comparison, exact retirement scope, and the live-source deterministic self-test.
- The review's former green self-consistency tests would not alone have protected against total empty-bundle replacement. The independent empty-bundle probe confirms the fixed code-owned anchors now reject that case before extraction.
- The rare branch where an operating-system error interrupts rollback after collision-free preflight is code-inspected but has no deterministic fault-injection test. It preserves un-restored staged originals and reports the quarantine path. This is outside the roadmap's observable contract and does not weaken the tested collision/data-loss requirement.
- `BOUNDARY-01` remains unchecked in `REQUIREMENTS.md` because phase completion metadata is intentionally owned by the orchestrator. Actual code/document/gate evidence satisfies it.

## Human Verification Required

None. This phase's success criteria are archive integrity, static repository boundaries, deterministic restoration, and command-line test accounting; all are programmatically observable. Visual UI quality, realtime behavior, device behavior, and external services are explicitly outside the phase goal.

## Deferred-Item Filter

No failed Phase 66 truth required deferral. Phases 67-69 own consumer/CLI strengthening, CPU reference oracles, and concurrency/milestone closeout respectively; none is needed to make the Phase 66 archive and SDK-only boundary true now.

## Gaps Summary

No blocker or warning gap found. All roadmap criteria, merged plan must-haves, five mapped requirements, and six prohibitions are verified against current code, artifacts, Git history, mutation tests, and a fresh complete no-skip run.

---

_Verified: 2026-08-14T03:48:41Z_
_Verifier: the agent (gsd-verifier)_
