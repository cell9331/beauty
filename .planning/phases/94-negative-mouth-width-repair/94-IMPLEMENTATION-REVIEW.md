---
phase: 94-negative-mouth-width-repair
reviewed: 2026-09-11
depth: deep
files_reviewed: 6
files_reviewed_list:
  - BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift
  - BeautySDK/Tests/BeautyCoreTests/MouthNegativeOracleTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthNegativeTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/MouthNegativeFieldTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthLifecycleTests.swift
  - scripts/check-phase94-remaining.py
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
---

# Phase94 94-05 Task1 independent implementation/security review

```json
{
  "schema": "phase94.implementation-review.1",
  "reviewer_role": "independent-parent",
  "verdict": "PASS",
  "unresolved_blockers": 0,
  "high_security_findings": 0,
  "checks_sha256": "fa696dba3273f248924bdd34744088979bae1e23a35a8d5d433e1c379a8f3ac4",
  "provider_sha256": "7c3218d0586704cb078b4c7e2004805e182341c37b371567f204094be59153c8",
  "inputs": {
    "BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthLifecycleTests.swift": "30e6dc39fe1ec3ac7d88c5b33880e1a0bfd7e179e2fcf7f2026573dcf8ff3ef9",
    "BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthNegativeTests.swift": "f6bf8d3c9ce59ce25ac09c9e0b4147a61e5e54d9e397abfd6ee35c2b4e4cc65a",
    "BeautySDK/Tests/BeautyCoreTests/MouthNegativeOracleTests.swift": "5f76e3c6587bc68c0b3fcbaf2eee0f7a488bdbb4d303a154529a77141a418109",
    "BeautySDK/Tests/BeautyEffectsTests/MouthNegativeFieldTests.swift": "9037d41956edba99dc4fb0cf9c11ba64138960aaca975c2e49be35d2e6552a00",
    "scripts/check-phase94-remaining.py": "d7ddb91e59548f752422c62f91f632d8312a6cc57712d626300ef74ae370c45d"
  }
}
```

## Narrative Findings (AI reviewer)

**Disposition: PASS for this exact accepted B identity.** No unresolved correctness BLOCKER, high-security finding, or actionable WARNING was found in the reviewed scope. This reviewer did not author the implementation. Prior reviews were read as historical context and binding inputs, not substituted for independent source analysis.

**Scope.** Read AGENTS, active PLANS, 94-05 PLAN, REMAINING-VALIDATION and CONTEXT; applied the project privacy skill and relevant owner contracts. Read the complete provider, all four new test files and remaining runner. Traced dependencies through the immutable integer oracle/source/registration tests, observation SPI, facade geometry route, adapter, resolver sanitation and CPU inverse sampler; inspected inherited capture/discovery/aggregate helpers and the historical runner defects/disposition. No structural pre-pass was supplied. The six-file list above is the primary implementation scope; dependency and historical evidence reads are supporting context.

**Provider and field mathematics.** `MouthWarpProvider.swift:121–207`: removing exactly the marked dispatch/helper yields the complete original `624cee5a` provider, SHA-256 `d8f306e3643aca367451a3dbd3bc97c2208e0abfa9b4ab80fdfb3c4390fcc6b3`. B equals committed A (`3230d016`) with precisely `gap / 8` replaced by `gap / 7`. Positive width, sibling bodies and shared helpers remain byte-identical. The negative branch uses validated support and capped signed strength, gap-derived radius and the declared face-width/radius/gap displacement caps. It constructs final Float points, computes their two-field bound, applies at most one prescribed rescaling, then rejects invalid, non-inward, crossing or Y-changing pairs. Shared `makePoints` supplies finite/support/radius/emission checks. The retained displacement floor and renderer cutoff remain distinct; tiny-strength exact proportionality is not promised.

The field oracle was compared with `BeautyGeometryEffectPipeline.swift:143–289`: target-centered quadratic inverse displacement, renderer L1/radius admission, radius clamp and original-buffer bilinear sampling agree for these emissions. F3 inspects actual provider outputs on both fixed support cases, including target order, sampled interior reversal and central determinant; an inconclusive sufficient bound is not mislabeled a defect. F4 includes contributing sibling fields in its overlap calculation and tests actual resolver reuse/stale/conflict sanitation. The two-negative-field bound is not a universal claim about mixed siblings, boundary clamping or raster injectivity.

**Pixel and lifecycle evidence.** `MouthNegativeOracleTests.swift` uses checked Int64 primitives, strict frozen contract decoding, sorted darkness-weighted centroids, literal floor/exclusive rasterization, tolerance >2 with all RGB deltas included, and both comparator-clipped/full protection passes. Independent boundary mutations and measured array counterexamples exercise every predicate, all three sibling comparisons, source/neutral distinction and typed rejection. `BeautyEngineMouthNegativeTests.swift` measures actual returned images from both public wrappers twice, with the immutable generated source and observation; it does not infer contraction from provider coordinates. Retained source/neutral/positive/signed-size digests are checked against the pinned historical receipt. The separate retained-row method covers all fourteen rows. Lifecycle assertions cover caps, nonfinite identity, translated extent, raw color/alpha, eight encoding/inverse pairs, mapped mirror policy, reset/rejection/recovery and redacted metadata. Canonical .up is the semantic contraction scope; other encodings establish raw-wrapper behavior only.

**Current versus historical admission and budget.** Independently recomputed CHECKS/input/provider hashes, verified all 166 event links and each published receipt's bytes/content binding, and reconciled all 41 distinct accepted method records and execution counts. The original full baseline remains 41/39/2 with four protection predicates and two F3 predicates failing. A remains 41/40/1, failing only SOURCE_SIGNAL and NEUTRAL_SIGNAL (392 changed versus 500 required); this is precisely B eligibility. Events 119/120 preserve rollback to the original before counted begin2; events 121–123 bind B's separate compile/review/seal, and 166 binds B's fresh 41/41 acceptance. Research and plan-set counts remain one; implementation attempts are 2/2, with no third attempt authorized.

Accepted source/neutral measurements are each 520 changed, 73743 RGB and −24 Q16; positive/size-plus/size-minus separations are 200/181/37 Q16. Outside, height, face, background and watermark maxima are all 0 changed/0 RGB. Counts are 41 discovered/executed/passed, zero failed/skipped/unexecuted. These are verified receipt facts, not newly rerun native measurements. Old prerequisite failures, six initial runner defects, authoring corrections, original seed and historical GREEN remain preserved; no old gate was replayed against B.

**Security and failure disposition.** `check-phase94-remaining.py:68–114, 213–610, 676–843` checks relative non-symlink paths, bounded reads, strict current JSON schemas, legal event transitions, exact receipt/review identities, immutable historical/nonprovider inputs and pre/post-child identity. The marked source exception does not itself prove helper correctness: exact independent review of the compiled candidate is the additional trust boundary. This review independently checked that helper. Failed/unknown execution cannot produce passing CHECKS; orphan publication and stale/missing compile/review/seal evidence reject. Success receipts use exclusive atomic publication; history is append-only. Review identity is a parent-controlled local workflow assertion, not a cryptographic human signature or protection against an owner rewriting all trust roots.

Inherited `check-phase94-mouth-repair.py:194–237` captures stdout/stderr together in memory under 8 MiB, uses finite child deadlines and a separate process group, kills the group and reaps/closes pipes on exit. Only fixed markers, validated aggregates, counts and hashes are persisted. No raw image/support arrays, private locators or child transcript were added to this report. Historical helper loading is pinned and used for capture/parsing, not historical current-provider authority. Existing runner defects are resolved within the admitted successor; no historical BLOCKER was silently reclassified as a passing measurement.

**Review verification and limits.** Fresh read-only new-runner `scope` returned `scope_pass`, policy B. Fresh runner `self-test` returned 16/16, 72 attack rejections, zero failures/skips/native tests; it exercises real admission functions plus disposable synthetic stores and short Python timeout/overflow children. No Swift build/native test, old gate status, receipt/event mutation, install or commit was performed by this review. No callable Serena or dedicated Read/Write tool was available; shell reads and the file patch tool were used. Only this report is a persistent review write. Owner synchronization and independent goal/final completion remain subsequent tasks; CHECKS still explicitly says `phase_complete: false`.

**No-install / nonclaims.** No new dependency, package configuration, UI, Metal/backend, public API, external service, data/model/weight or private-fixture work. Generated input proves the frozen owner-local SDK mechanics only, not individual anatomical fidelity, portrait/population quality, all-orientation semantics, device performance, commercial quality, external distribution or release readiness. Phase95 private portraits, final65 and full no-skip remain separate and unexecuted here. No authority to spend another implementation attempt or change frozen tests is granted.
