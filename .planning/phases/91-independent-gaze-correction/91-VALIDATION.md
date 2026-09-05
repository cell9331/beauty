---
phase: "91"
slug: "independent-gaze-correction"
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-09-04"
updated: "2026-09-05"
---

# Phase 91 — Validation Strategy

> Execution-time validation map for the independently checked four-plan set. This file remains draft and non-Nyquist-complete until every missing seam exists and all mapped commands pass.

---

## Test Infrastructure

| Property | Value |
| --- | --- |
| **Framework** | XCTest from the Swift toolchain plus SDK-owned Swift/Bash/Python gates |
| **Config file** | `BeautySDK/Package.swift`; frozen semantic contract in `scripts/face-feature-batch-manifest.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter 'BeautyFaceGeometryAdapterTests|EyeWarpProviderTests|BeautyEffectResolverTests|GeometryConflictResolverTests|BeautyEngineGazeCorrectionRepairTests|BeautyExampleRendererProcessTests'` |
| **Current-authority suite command** | `test "$(swift test --package-path BeautySDK list | rg -c 'FaceContourSmoothRepairTests/testFACE01GeneratedCPUFixturePassesFrozenSemanticAndProtectionContract')" -eq 1 && swift test --package-path BeautySDK --filter '^(?!.*FaceContourSmoothRepairTests/testFACE01GeneratedCPUFixturePassesFrozenSemanticAndProtectionContract).*$'` (all 840 current tests except the single discovered Phase-90-deferred frozen FACE-01 RED oracle) |
| **Final compatibility command** | `swift test --package-path BeautySDK --filter 'BeautyParametersTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests|BeautyEngineMetadataCompatibilityTests|BeautyBackendContractTests|BeautyBackendSelectionConcurrencyTests'` |
| **Semantic/boundary commands** | `swift scripts/compare-face-feature-batches.swift --self-test`; `python3 scripts/test-face-feature-batch-boundaries.py`; `bash scripts/run-face-feature-batches.sh --preflight-only` |
| **Archive/SDK-only commands** | `python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui`; `bash scripts/check-sdk-only-boundary.sh --post-archive` |

## Sampling Rate

- **After every task commit:** run the task's exact `<automated>` command; stop on its first failure.
- **After each wave:** run the combined focused Swift filter plus every script seam changed in that wave.
- **Before Phase 91 owner synchronization:** run the full Task 91-04-01 conjunction, including the exact 840-test current-authority SwiftPM suite while proving the one Phase-90-deferred frozen FACE-01 RED oracle remains discovered and solely excluded, focused compatibility, comparator mutations, Python boundaries, exact 75/65/8 preflight, backend-neutral inventory/privacy, archive integrity, post-archive SDK-only boundary, and diff hygiene.
- **After owner synchronization:** run Task 91-04-02's behavior/product consistency command, then Task 91-04-03's trust/privacy/preflight/archive/SDK-only consistency command.
- **Attempt ceiling:** the three implementation summaries must agree on attempt `1` or `2`; a failed second attempt stops for explicit owner repair/defer/stop and cannot start a third attempt.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat refs | Files | Secure/observable behavior | Test type | Exact automated command | File state | Status |
| --- | --- | ---: | --- | --- | --- | --- | --- | --- | --- | --- |
| 91-01-01 | 91-01 | 1 | EYE-01 | T-91-01, T-91-03, T-91-04 | `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift`; `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift`; `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` | Local gaze eligibility survives a missing/malformed/ratio-invalid peer while paired pupil-size compatibility, privacy, ordering, and recovery remain unchanged. | unit/mutation | `swift test --package-path BeautySDK --filter BeautyFaceGeometryAdapterTests` | existing test extends | pending |
| 91-01-02 | 91-01 | 1 | EYE-01 | T-91-02, T-91-03, T-91-04 | `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift`; `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` | Exact 0.002/0.25/35% law, 0/1/2-side order, simple closed aperture, strict source/target containment, frozen 0.5 clearance radius, aggregate algebra, and no peer borrowing. | unit/mutation | `swift test --package-path BeautySDK --filter 'EyeWarpProviderTests|BeautyFaceGeometryAdapterTests' && git diff --check` | existing tests extend | pending |
| 91-02-01 | 91-02 | 2 | EYE-01 | T-91-05, T-91-08, T-91-09 | `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`; `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | Resolved post-conflict `BeautyEffectResolver` seam emits exactly six consistent aggregate metrics only from final admitted gaze work. | unit/integration | `swift test --package-path BeautySDK --filter 'BeautyEffectResolverTests|GeometryConflictResolverTests|EyeWarpProviderTests'` | existing tests extend | pending |
| 91-02-02 | 91-02 | 2 | EYE-01 | T-91-06, T-91-07, T-91-08, T-91-09 | `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift`; `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGazeCorrectionRepairTests.swift` | Minimal `BeautyEngineTestingSupport` fixture seam drives generated 512×512 actual input/output pixel proof of own-center motion, rejected-peer source identity, frozen target/protection values, metadata, determinism, and recovery. | integration/actual-pixel | `swift test --package-path BeautySDK --filter 'BeautyEngineGazeCorrectionRepairTests|BeautyEffectResolverTests' && git diff --check` | new actual-pixel test missing until Wave 2 TDD RED | pending |
| 91-03-01 | 91-03 | 3 | EYE-01 | T-91-10, T-91-11, T-91-13, T-91-15 | `BeautySDK/Sources/BeautyExampleRenderer/RendererCLIContract.swift`; `BeautySDK/Sources/BeautyExampleRenderer/RendererExecution.swift`; `BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift` | Only the exact successful gaze renderer unit can carry a deterministic valid six-field aggregate; all malformed/sibling/failure forms fail closed without leakage. | integration/process | `swift test --package-path BeautySDK --filter BeautyExampleRendererProcessTests && git diff --check` | existing test extends | pending |
| 91-03-02 | 91-03 | 3 | EYE-01 | T-91-10, T-91-11, T-91-12, T-91-13, T-91-14, T-91-15 | `scripts/compare-face-feature-batches.swift`; `scripts/run-face-feature-batches.sh`; `scripts/test-face-feature-batch-boundaries.py` | Same-output aggregate admission remains conjoined with frozen actual-pixel target/sibling/locality/protection gates; replay/proxy/path/cleanup mutations fail; reports are consumed then absent; preflight is exact 75/65/8. | mutation/boundary | `swift scripts/compare-face-feature-batches.swift --self-test && python3 scripts/test-face-feature-batch-boundaries.py && bash -n scripts/run-face-feature-batches.sh && bash scripts/run-face-feature-batches.sh --preflight-only && git diff --check` | existing scripts extend | pending |
| 91-04-01 | 91-04 | 4 | EYE-01 | T-91-16, T-91-17, T-91-18, T-91-19, T-91-20 | `.planning/phases/91-independent-gaze-correction/91-01-SUMMARY.md`; `.planning/phases/91-independent-gaze-correction/91-02-SUMMARY.md`; `.planning/phases/91-independent-gaze-correction/91-03-SUMMARY.md`; `BeautySDK/`; `scripts/compare-face-feature-batches.swift`; `scripts/run-face-feature-batches.sh`; `scripts/test-face-feature-batch-boundaries.py`; `scripts/check-backend-neutral-contract.sh`; `scripts/archive-legacy-ui.py`; `scripts/check-sdk-only-boundary.sh` | Summaries reconcile to attempt 1 or 2; the CPU reference gaze samples are aperture-interior; and the final 840-test current-authority/focused SwiftPM, comparator, boundary, exact preflight, backend-neutral, archive, SDK-only, privacy, inventory, and diff conjunction passes without the single deferred FACE-01 oracle or Phase-95 work. | phase/compatibility/security | `for summary in 91-01/02/03 summaries: require one shared implementation_attempt in 1...2; then run the exact Task 91-04-01 full conjunction` | all prior summaries/seams required | pending |
| 91-04-02 | 91-04 | 4 | EYE-01 | T-91-17, T-91-18, T-91-19 | `PLANS.md`; `DESIGN.md`; `ARCHITECTURE.md`; `PRODUCT_SENSE.md` | Behavior, architecture, owner journey, and ledger record one exact verified outcome, aggregate path, attempt count, compatibility surface, and nonclaims. | documentation | exact Task 91-04-02 `rg` owner-section and diff command below | owner files exist; Phase 91 sections pending | pending |
| 91-04-03 | 91-04 | 4 | EYE-01 | T-91-17, T-91-18, T-91-19 | `SECURITY.md`; `RELIABILITY.md`; `QUALITY_SCORE.md`; `docs/SDK_EFFECT_TAXONOMY.md` | Trust, recovery, quality, and taxonomy owners match the verified outcome; privacy, exact preflight, archive, SDK-only boundary, and Phase-95 nonclaims remain green. | documentation/boundary | exact Task 91-04-03 owner/privacy/preflight/archive/SDK-only/diff command below | owner files exist; Phase 91 sections pending | pending |

### Exact Automated Commands by Task

These commands are copied from the revised plans; the table above maps each command to its task, files, wave, requirement, and threat IDs.

- `91-01-01`: `swift test --package-path BeautySDK --filter BeautyFaceGeometryAdapterTests`
- `91-01-02`: `swift test --package-path BeautySDK --filter 'EyeWarpProviderTests|BeautyFaceGeometryAdapterTests' && git diff --check`
- `91-02-01`: `swift test --package-path BeautySDK --filter 'BeautyEffectResolverTests|GeometryConflictResolverTests|EyeWarpProviderTests'`
- `91-02-02`: `swift test --package-path BeautySDK --filter 'BeautyEngineGazeCorrectionRepairTests|BeautyEffectResolverTests' && git diff --check`
- `91-03-01`: `swift test --package-path BeautySDK --filter BeautyExampleRendererProcessTests && git diff --check`
- `91-03-02`: `swift scripts/compare-face-feature-batches.swift --self-test && python3 scripts/test-face-feature-batch-boundaries.py && bash -n scripts/run-face-feature-batches.sh && bash scripts/run-face-feature-batches.sh --preflight-only && git diff --check`
- `91-04-01`: `for summary in .planning/phases/91-independent-gaze-correction/91-01-SUMMARY.md .planning/phases/91-independent-gaze-correction/91-02-SUMMARY.md .planning/phases/91-independent-gaze-correction/91-03-SUMMARY.md; do test -f "$summary" && test ! -L "$summary" && test "$(rg -c '^implementation_attempt: [12]$' "$summary")" -eq 1 || exit 1; done && test "$(rg --no-filename '^implementation_attempt: [12]$' .planning/phases/91-independent-gaze-correction/91-0[1-3]-SUMMARY.md | sort -u | wc -l | tr -d ' ')" -eq 1 && test "$(swift test --package-path BeautySDK list | rg -c 'FaceContourSmoothRepairTests/testFACE01GeneratedCPUFixturePassesFrozenSemanticAndProtectionContract')" -eq 1 && swift test --package-path BeautySDK --filter '^(?!.*FaceContourSmoothRepairTests/testFACE01GeneratedCPUFixturePassesFrozenSemanticAndProtectionContract).*$' && swift test --package-path BeautySDK --filter 'BeautyParametersTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests|BeautyEngineMetadataCompatibilityTests|BeautyBackendContractTests|BeautyBackendSelectionConcurrencyTests' && swift scripts/compare-face-feature-batches.swift --self-test && python3 scripts/test-face-feature-batch-boundaries.py && bash -n scripts/run-face-feature-batches.sh && bash scripts/run-face-feature-batches.sh --preflight-only && bash scripts/check-backend-neutral-contract.sh && python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui && bash scripts/check-sdk-only-boundary.sh --post-archive && git diff --check`
- `91-04-02`: `rg -q '^### C-[0-9]{4}-[0-9]{2}-[0-9]{2}-phase-91-independent-gaze-correction' PLANS.md && for file in DESIGN.md ARCHITECTURE.md PRODUCT_SENSE.md; do rg -q '^## Phase 91 ' "$file" || exit 1; done && git diff --check`
- `91-04-03`: `for file in SECURITY.md RELIABILITY.md QUALITY_SCORE.md docs/SDK_EFFECT_TAXONOMY.md; do rg -q '^## Phase 91 ' "$file" || exit 1; done && rg -q 'gazeCorrection' docs/SDK_EFFECT_TAXONOMY.md && python3 scripts/test-face-feature-batch-boundaries.py && bash scripts/run-face-feature-batches.sh --preflight-only && python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui && bash scripts/check-sdk-only-boundary.sh --post-archive && git diff --check`

## Threat Coverage Map

| Plan | Threat IDs covered by mapped tasks |
| --- | --- |
| 91-01 | T-91-01, T-91-02, T-91-03, T-91-04, T-91-SC |
| 91-02 | T-91-05, T-91-06, T-91-07, T-91-08, T-91-09, T-91-SC |
| 91-03 | T-91-10, T-91-11, T-91-12, T-91-13, T-91-14, T-91-15, T-91-SC |
| 91-04 | T-91-16, T-91-17, T-91-18, T-91-19, T-91-20, T-91-SC |

Every HIGH threat is mapped to a concrete implementation or closeout task and blocks completion until its exact automated command passes.

## Wave 0 / TDD RED Requirements

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGazeCorrectionRepairTests.swift` must be created before its production/testing-support implementation. It owns deterministic in-memory 512×512 explicit-sRGB RGBA8 actual input/output pixels, independently declared chromatic pupil identities and eye centers, zero/one/two-side correction, rejected-side source identity, frozen target/sibling/locality/protection integers, alpha/extent/metadata, determinism, and valid-invalid-valid recovery.
- [ ] Extend `BeautyFaceGeometryAdapterTests.swift` and `EyeWarpProviderTests.swift` with the peer-failure, exact boundary, ordering, aperture-clearance, aggregate-hidden-regression, and recovery RED mutations before production edits.
- [ ] Extend `BeautyEffectResolverTests.swift` before aggregate implementation and use only the resolved post-conflict `BeautyEffectResolver.resolve` seam.
- [ ] Extend `SDKTestingFaceDetectionFixture` / `BeautyEngineTestingSupport` only after the public actual-pixel RED needs the minimum fixed per-eye matrix; no public/Codable anatomy type.
- [ ] Extend `BeautyExampleRendererProcessTests.swift` with gaze success/abstention/sibling/failure/malformed/deterministic/privacy report fixtures before renderer changes.
- [ ] Add comparator aggregate builders and every proxy/replay/identity/algebra/sibling/path mutation while preserving all prior Phase 89 probes.
- [ ] Add Python runner probes for retained-until-consumed reports, replay/symlink/path mismatch, cleanup fault, and verified absence.

No framework or package installation is required. `wave_0_complete` remains false until these test seams exist; `nyquist_compliant` remains false until they pass.

## Frozen Gates and Nonclaims

- Actual-pixel gaze target regions remain left `300000...480000`, right `520000...700000`, y `550000...700000`; changed pixels `>=256`; RGB delta `>=768`; signed Q16 `>=16`; outside `<=128/512`; eye contours `<=64/256`; eyebrows `<=32/128`; background/watermark `0/0`.
- The live/selected/semantic preflight remains exactly `75/65/8`; public compatibility remains exactly 62 stored fields, five presets, and 75 renderer cases with unchanged facades, CPU/GPU policy, and retained `Warp.metal`.
- Phase 91 does not run authorized portraits, publish the final clean 65 outputs, invoke `scripts/run-no-skip-swiftpm.sh`, or establish device, naturalness, population, commercial, packaging, shipping, launch, release, or distribution readiness.

## Validation Sign-Off

- [ ] Every listed task exists in 91-01 through 91-04 and uses the exact mapped command.
- [ ] All Wave 0/TDD RED seams exist.
- [ ] Every mapped command passes in its declared wave.
- [ ] Every HIGH threat is mitigated with passing evidence.
- [ ] All three implementation summaries agree on attempt one or two; no third attempt occurs.
- [ ] Task 91-04-01 full phase gate passes before any owner synchronization.
- [ ] Task 91-04-02 behavior/product owner consistency gate passes after synchronization.
- [ ] Task 91-04-03 trust/evidence/taxonomy consistency and boundary gate passes after synchronization.
- [ ] Generated image tests assert actual input/output pixels and metadata, not only control points, aggregates, or command success.
- [ ] `nyquist_compliant: true` and `wave_0_complete: true` are set only after execution supplies all passing evidence.

**Approval:** pending execution
