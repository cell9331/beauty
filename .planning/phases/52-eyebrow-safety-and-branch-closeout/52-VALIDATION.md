---
phase: 52
slug: eyebrow-safety-and-branch-closeout
status: in_progress
nyquist_compliant: true
wave_0_complete: true
task_coverage: 23/23
execution_green: 14/23
created: 2026-07-27
---

# Phase 52 — Validation Strategy

> Per-phase validation contract for final eyebrow safety, exact convergence, independently reviewed gap closure, and final re-verification handoff.

## Test Infrastructure

| Property | Value |
| --- | --- |
| **Framework** | XCTest via SwiftPM 6.3.3; Python 3.9 standard-library self-tests and static gates |
| **Config file** | `BeautySDK/Package.swift`; no new target or dependency |
| **Quick run command** | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyEffectResolverTests` |
| **Full suite command** | `swift test --package-path BeautySDK --disable-sandbox --jobs 1` |
| **Static gate** | `python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py` |
| **Strict output gate** | Phase 51 helper against a guarded clean `example-images/output` render, without `--measure` |
| **Estimated runtime** | Focused feedback under 3 minutes; full/output closeout host-dependent |

## Exact Evidence Vocabulary

- Public inventory: exactly 59 stored fields, 58 numeric plus `filterId`.
- Eyebrow inventory: exactly seven named fields; six signed and one positive-only.
- Complete geometry inventory: exactly 44 fields = 9 face/chin + 14 eye + 7 eyebrow + 6 nose + 8 mouth.
- Final all-field arithmetic: exact unscaled total `13.45`, count/weakened count `44`, one scale `1 / 13.45`, and final total `1`.
- Output evidence remains the unchanged Phase 51 contract: 72 `e6` portrait outputs, thirteen separate no-face comparisons, and 144 total disposable two-fixture files.

## Sampling Rate

- **After every task commit:** Run the narrow owning XCTest suite or checker mode plus `git diff --check`.
- **After every plan wave:** Run all suites touched in that wave, checker self-test/live mode when available, and diff hygiene.
- **Before promotion:** Run all focused suites, full SwiftPM, guarded Phase 51 strict output/gallery/actual-image evidence, standard review, Nyquist audit, ASVS L1 audit, default checker, artifact scans, and diff hygiene.
- **Before `$gsd-verify-work`:** Full SwiftPM, unchanged strict output/gallery, post-promotion/owner/final checker modes, requirements/roadmap analysis, and artifact containment must be green.
- **Max normal focused feedback latency:** 180 seconds.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | Expected Result | File Exists | Status |
| --- | --- | ---: | --- | --- | --- | --- | --- | --- | --- | --- |
| 52-01-01 | 01 | 1 | SAFE-01 | T-52-01–02 | One final cap authority; exact dead-zone/cap adjacency, overflow, direction, count, warning, and metric semantics | unit | `G52-01-01` verbatim below | Both focused suites exit 0; cap declaration count is exactly 7; provisional-cap scan has no match; diff hygiene exits 0. | ✅ extend | ✅ green |
| 52-01-02 | 01 | 1 | SAFE-01, SAFE-02 | T-52-01–04, T-52-07 | Seven-field finite/unit/radius and nil/single-side/missing/malformed/provider-empty matrix with no support fabrication | unit | `G52-01-02` verbatim below | Both focused suites exit 0; `provisionalCap` has no match; unique named safety-cap reference count is exactly 7; diff hygiene exits 0. | ✅ extend | ✅ green |
| 52-01-03 | 01 | 1 | SAFE-02 | T-52-05–08 | Stateless complete lifecycle/transitions, parallel/interrupted isolation, safe siblings, unchanged extent, aggregate-only facade diagnostics | integration | `G52-01-03` verbatim below | Degradation and facade suites exit 0; diff hygiene exits 0. | ✅ extend | ✅ green |
| 52-02-01 | 02 | 2 | SAFE-01, SAFE-02 | T-52-09–10 | Exact 44-field inventory, 13.45/44/1÷13.45 arithmetic, threshold adjacency, and preserved signs | unit | `G52-02-01` verbatim below | Conflict and combined-safety suites exit 0; diff hygiene exits 0. | ✅ extend | ✅ green |
| 52-02-02 | 02 | 2 | SAFE-02 | T-52-10–12 | At most 44 monotone removals; final effective/emission/metric/dispatch equality | unit + integration | `G52-02-02` verbatim below | Combined-safety and pipeline suites exit 0; production `0..<44` loop count is exactly 1; diff hygiene exits 0. | ✅ extend | ✅ green |
| 52-03-01 | 03 | 3 | SAFE-03, DOC-01 | T-52-13–18, T-52-22–23, T-52-SC | Fail-closed pre/post-promotion, owner, privacy, dependency, artifact, concurrency/interruption, and lifecycle checker | static + adversarial | `G52-03-01` verbatim below | Python compilation, checker self-test, default live checker, and diff hygiene all exit 0. | ✅ Wave 0 | ✅ green |
| 52-03-02 | 03 | 3 | SAFE-01, SAFE-02, SAFE-03 | T-52-17–20, T-52-22 | Fresh runtime plus unchanged strict output/gallery, fourteen reopened images, and disposable artifact evidence | full + integration | `G52-03-02` verbatim below | Eight focused suites, full SwiftPM, guarded renderer/helper/gallery, and checker exit 0; output and gallery counts are exactly 144 each; visual rows are exactly 14 with PASS; generated roots are untracked/unstaged. | ✅ reuse | ✅ green |
| 52-03-03 | 03 | 3 | SAFE-03 | T-52-19, T-52-21, T-52-23 | Historical review/Nyquist/ASVS precondition for Plans 01–06; superseded for gap closure by 52-08-02 and the independent post-Wave-8 review gate | review + security | `G52-03-03` verbatim below | Checker self-test/default exit 0; review is clean; threats open are 0; Nyquist is true; original-row count is exactly 14; diff hygiene exits 0. | ✅ Wave 3 | ✅ historical green; current gate superseded |
| 52-04-01 | 04 | 4 | DOC-01 | T-52-24, T-52-26 | Fresh evidence reauthorizes only the exact eyebrow status transaction | static | `G52-04-01` verbatim below | Checker self-test/default exit 0 at the owning pre-promotion state; clean review, zero open threats, and Nyquist gates match; diff hygiene exits 0. | ✅ Wave 0 | ✅ green |
| 52-04-02 | 04 | 4 | DOC-01 | T-52-25–27 | Exactly seven rows and branch `眉毛` become implemented at SDK-core scope; all nonclaims preserved | docs/static | `G52-04-02` verbatim below | Exact post-promotion checker and diff hygiene exit 0. | ✅ Wave 0 | ✅ green |
| 52-05-01 | 05 | 5 | SAFE-03, DOC-01 | T-52-28 | Example owners retain exact 72/13/144 vocabulary, fourteen-file review, disposable artifacts, and final cap/safety result | docs/static | `G52-05-01` verbatim below | Example-owner mode, strict-helper self-test, gallery self-test, and diff hygiene all exit 0. | ✅ Wave 0 | ✅ green |
| 52-05-02 | 05 | 5 | SAFE-01, SAFE-02, SAFE-03, DOC-01 | T-52-29–30 | Routed root owners agree on caps, lifecycle, privacy, reliability, product, quality, and nonclaims | docs/static | `G52-05-02` verbatim below | Each of six bounded root-owner modes, aggregate owner mode, and diff hygiene exit 0. | ✅ Wave 0 | ✅ green |
| 52-06-01 | 06 | 6 | SAFE-01, SAFE-02, SAFE-03, DOC-01 | T-52-31–34 | Close exact requirements/plans only after executable evidence; independent audit remains pending | docs/static | `G52-06-01` verbatim below | Completed requirement count is exactly 4; completed original-plan count is exactly 6; phase-complete and independent-audit text gates match; planning owner mode and diff hygiene exit 0. | ✅ Wave 0 | ✅ green |
| 52-06-02 | 06 | 6 | SAFE-01, SAFE-02, SAFE-03, DOC-01 | T-52-19, T-52-21, T-52-31–34 | Historical six-plan verification handoff; superseded by gap closure, independent review, Wave 10 final gate, and independent Phase 52 re-verification | verify | `G52-06-02` verbatim below | Final checker/full SwiftPM/guarded render/helper/gallery and roadmap analysis exit 0; output/gallery counts are exactly 144 each; verification is passed and Nyquist true at the owning historical state; generated roots remain untracked. | ✅ Wave 6 | ✅ historical green; current gate superseded |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

## Gap-Closure Task Verification Map

The following nine rows extend the original fourteen-task matrix to exact
23/23 planned coverage. `52-REVIEW.md` remains exclusively owned by the
independent post-Wave-8 `gsd-code-reviewer`; `52-VERIFICATION.md` remains
independently owned and `status: gaps_found`. Rows may turn green only from
their owning command result.

| Task ID | Plan | Wave | Requirement | Threat Ref | Exact Automated Command | Expected Result | Evidence Status |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| 52-07-01 | 07 | 7 | SAFE-01 | T-52-07-01 | `G52-07-01` verbatim below | Exactly 14 provider tests execute with zero failures; every shared fixture enters through the production adapter. | ⬜ pending |
| 52-07-02 | 07 | 7 | SAFE-02, SAFE-03 | T-52-07-02–03 | `G52-07-02` verbatim below | Exactly one targeted test passes after a callback inside `EyebrowWarpProvider.fieldEmissions` proves provider-owned entry and holds the request; cancellation occurs only then, release permits cancellation-aware discard or safe completion, and parallel/subsequent requests remain isolated. | ⬜ pending |
| 52-07-03 | 07 | 7 | SAFE-01, SAFE-02 | T-52-07-04–05 | `G52-07-03` verbatim below | Exactly one targeted test covers all seven rows with a nonzero production pre-sanitization value, monotone removal, no later re-entry, final accounting exclusion, and identical repeated fixed point. | ⬜ pending |
| 52-08-01 | 08 | 8 | SAFE-01, SAFE-02, SAFE-03 | T-52-08-02–03, T-52-08-05 | `G52-08-01` verbatim below | Checker self-test is exactly 130/130; full SwiftPM is exactly 450 executed with six documented conditional skips and zero failures; discovery proves `iPhone 17 Pro` on iOS 26.5 is available; explicit-destination build/test both exit 0; Demo diff is empty. | ⬜ pending |
| 52-08-02 | 08 | 8 | SAFE-01, SAFE-02, SAFE-03, DOC-01 | T-52-08-01, T-52-08-04, T-52-08-06 | `G52-08-02` verbatim below | WR-01/02/03 evidence exists, ASVS L1 open threats are zero, all 23 task rows map once to 23 concrete same-ID command/result entries, verifier remains gaps-found, review is unchanged, and the non-promotion checker passes with Waves 9–10 pending. | ⬜ pending |
| 52-09-01 | 09 | 9 | SAFE-01, SAFE-02, SAFE-03, DOC-01 | T-52-09-01–02, T-52-09-05 | `G52-09-01` verbatim below | Read-only review gate proves independent clean 0/0/0/0 status and freshness after committed Waves 7–8; validation is 23/23; security and reliability modes pass. | ⬜ pending — independent review gate |
| 52-09-02 | 09 | 9 | SAFE-01, SAFE-02, SAFE-03, DOC-01 | T-52-09-03–04 | `G52-09-02` verbatim below | Architecture, design, security, reliability, product, quality, and examples owner modes all pass. | ⬜ pending — after 52-09-01 |
| 52-10-01 | 10 | 10 | SAFE-01, SAFE-02, SAFE-03, DOC-01 | T-52-10-01–02, T-52-10-04 | `G52-10-01` verbatim below | Roadmap analysis passes; 52-09 summary exists; exactly ten plans, clean independent review, 23/23 validation, pending verifier state, and gaps-found report agree. | ⬜ pending — after Wave 9 |
| 52-10-02 | 10 | 10 | SAFE-01, SAFE-02, SAFE-03, DOC-01 | T-52-10-01–05 | `G52-10-02` verbatim below | Self-test is exactly 130/130; live gate is exactly 35/35 with `verification=pending-independent` and Nyquist 23/23; roadmap passes; Demo diff is empty. | ⬜ pending — after 52-10-01 |

## Exact Command and Result Registry

Every Phase 52 task row maps once to the same-ID registry key below. Commands
for Plans 01–06 are the concrete shell forms from their owning `<verify>`
blocks; their expected results describe the owning historical wave state.
Commands for Plans 07–10 are the current gap-closure contracts.

`G52-01-01`

```bash
swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautySafetyCapsTests && swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyEffectResolverTests && test "$(rg -n 'static let eyebrow(YPosition|Thickness|Length|Spacing|HeadSpacing|Tilt|PeakDefinition): Float = 0\.25\b' BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift | wc -l | tr -d ' ')" -eq 7 && ! rg -n 'Provisional Phase 50 eyebrow caps' BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift && git diff --check
```

**Expected result:** Both focused suites exit 0; the exact `0.25` cap declaration count is 7; the provisional-cap scan has no match; `git diff --check` exits 0.

`G52-01-02`

```bash
swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests && swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.MissingLandmarkDegradationTests && ! rg -n 'provisionalCap' BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift && test "$(rg -n 'BeautySafetyCaps\.eyebrow(YPosition|Thickness|Length|Spacing|HeadSpacing|Tilt|PeakDefinition)' BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift | sed 's/.*BeautySafetyCaps\.//' | sort -u | wc -l | tr -d ' ')" -eq 7 && git diff --check
```

**Expected result:** Both focused suites exit 0; `provisionalCap` has no match; the unique named eyebrow safety-cap reference count is 7; `git diff --check` exits 0.

`G52-01-03`

```bash
swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.MissingLandmarkDegradationTests && swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests && git diff --check
```

**Expected result:** The degradation and facade suites exit 0 and `git diff --check` exits 0.

`G52-02-01`

```bash
swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.GeometryConflictResolverTests && swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.CombinedEffectSafetyTests && git diff --check
```

**Expected result:** The conflict-resolver and combined-safety suites exit 0 and `git diff --check` exits 0.

`G52-02-02`

```bash
swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.CombinedEffectSafetyTests && swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.BeautyGeometryEffectPipelineTests && test "$(rg -n 'for _ in 0\.\.<44' BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift | wc -l | tr -d ' ')" -eq 1 && git diff --check
```

**Expected result:** Both focused suites exit 0; the production `0..<44` loop count is exactly 1; `git diff --check` exits 0.

`G52-03-01`

```bash
PYTHONPYCACHEPREFIX=/tmp/beauty-pycache python3 -m py_compile .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --self-test && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py && git diff --check
```

**Expected result:** Python compilation, checker self-test, default live checker, and `git diff --check` all exit 0.

`G52-03-02`

```bash
/bin/zsh -lc 'for filter in BeautyEffectsTests.BeautySafetyCapsTests BeautyEffectsTests.BeautyEffectResolverTests BeautyEffectsTests.EyebrowWarpProviderTests BeautyEffectsTests.MissingLandmarkDegradationTests BeautyEffectsTests.GeometryConflictResolverTests BeautyEffectsTests.CombinedEffectSafetyTests BeautyEffectsTests.BeautyGeometryEffectPipelineTests BeautyCoreTests.BeautyEngineGeometryFacadeTests; do swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter "$filter" || exit 1; done' && swift test --package-path BeautySDK --disable-sandbox --jobs 1 && test -f example-images/input/portraits/e6.jpg && test ! -L example-images/input/portraits/e6.jpg && test -s example-images/input/portraits/e6.jpg && OUTPUT_ROOT="$(cd example-images/output && pwd -P)" && test "$OUTPUT_ROOT" = "$(pwd -P)/example-images/output" && git check-ignore -q example-images/output && find "$OUTPUT_ROOT" -mindepth 1 -delete && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output && python3 .planning/phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py --input example-images/input --output example-images/output --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift && python3 example-images/generate_gallery.py --self-test && python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery && test "$(find example-images/output -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')" -eq 144 && test "$(find example-images/gallery -type f -name '*.png' | wc -l | tr -d ' ')" -eq 144 && test "$(rg -c '^\| `e6__(geometryBaseline_noop|eyebrow[^`]*)\.png`' .planning/phases/52-eyebrow-safety-and-branch-closeout/52-EYEBROW-SAFETY-EVIDENCE.md)" -eq 14 && rg -q '^Visual review verdict: PASS$' .planning/phases/52-eyebrow-safety-and-branch-closeout/52-EYEBROW-SAFETY-EVIDENCE.md && test -z "$(git ls-files example-images/output example-images/gallery example-images/.gallery-staging example-images/.gallery-quarantine)" && test -z "$(git diff --cached --name-only -- example-images/output example-images/gallery example-images/.gallery-staging example-images/.gallery-quarantine)" && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py && git diff --check
```

**Expected result:** All eight focused suites and full SwiftPM exit 0; e6/output containment preflights pass; renderer, strict helper, gallery self-test/publication, and default checker exit 0; output and gallery contain exactly 144 PNGs each; evidence has exactly 14 visual rows and `Visual review verdict: PASS`; generated roots are untracked and unstaged; `git diff --check` exits 0.

`G52-03-03`

```bash
python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --self-test && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py && rg -q '^status: clean$' .planning/phases/52-eyebrow-safety-and-branch-closeout/52-REVIEW.md && rg -q '^threats_open: 0$' .planning/phases/52-eyebrow-safety-and-branch-closeout/52-SECURITY.md && rg -q '^nyquist_compliant: true$' .planning/phases/52-eyebrow-safety-and-branch-closeout/52-VALIDATION.md && test "$(rg -n '^\| 52-0[1-6]-0[1-3] ' .planning/phases/52-eyebrow-safety-and-branch-closeout/52-VALIDATION.md | wc -l | tr -d ' ')" -eq 14 && git diff --check
```

**Expected result:** Checker self-test/default exit 0; review is clean; threats open are 0; Nyquist is true; the original Plans 01–06 row count is exactly 14; `git diff --check` exits 0.

`G52-04-01`

```bash
python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --self-test && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py && rg -q '^status: clean$' .planning/phases/52-eyebrow-safety-and-branch-closeout/52-REVIEW.md && rg -q '^threats_open: 0$' .planning/phases/52-eyebrow-safety-and-branch-closeout/52-SECURITY.md && rg -q '^nyquist_compliant: true$' .planning/phases/52-eyebrow-safety-and-branch-closeout/52-VALIDATION.md && git diff --check
```

**Expected result:** At the owning pre-promotion wave state, checker self-test/default, clean-review, zero-open-threat, Nyquist, and diff-hygiene gates all exit 0.

`G52-04-02`

```bash
python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-promotion && git diff --check
```

**Expected result:** Exact post-promotion classification and `git diff --check` both exit 0.

`G52-05-01`

```bash
python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-owners --owner example && python3 .planning/phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py --self-test && python3 example-images/generate_gallery.py --self-test && git diff --check
```

**Expected result:** Example-owner mode, strict-helper self-test, gallery self-test, and `git diff --check` all exit 0.

`G52-05-02`

```bash
/bin/zsh -lc 'for owner in architecture design security reliability product quality; do python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-owners --owner "$owner" || exit 1; done' && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-owners && git diff --check
```

**Expected result:** All six bounded root-owner modes, aggregate owner mode, and `git diff --check` exit 0.

`G52-06-01`

```bash
test "$(rg -n '^- \[x\] \*\*(SAFE-0[123]|DOC-01)\*\*' .planning/REQUIREMENTS.md | wc -l | tr -d ' ')" -eq 4 && test "$(rg -n '^- \[x\] 52-0[1-6]-PLAN\.md' .planning/ROADMAP.md | wc -l | tr -d ' ')" -eq 6 && rg -q 'Phase 52.*Complete|52\. Eyebrow Safety.*Complete' .planning/ROADMAP.md && rg -qi 'independent.*milestone.*audit' PLANS.md .planning/PROJECT.md .planning/STATE.md .planning/phases/52-eyebrow-safety-and-branch-closeout/52-EYEBROW-SAFETY-EVIDENCE.md && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-owners --owner planning && git diff --check
```

**Expected result:** Completed requirement count is exactly 4; completed original-plan count is exactly 6; phase-complete and independent-audit text gates match; planning owner mode and `git diff --check` exit 0.

`G52-06-02`

```bash
python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --allow-promotion && swift test --package-path BeautySDK --disable-sandbox --jobs 1 && OUTPUT_ROOT="$(cd example-images/output && pwd -P)" && test "$OUTPUT_ROOT" = "$(pwd -P)/example-images/output" && git check-ignore -q example-images/output && find "$OUTPUT_ROOT" -mindepth 1 -delete && DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output && python3 .planning/phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py --input example-images/input --output example-images/output --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift && python3 example-images/generate_gallery.py --self-test && python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery && test "$(find example-images/output -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')" -eq 144 && test "$(find example-images/gallery -type f -name '*.png' | wc -l | tr -d ' ')" -eq 144 && test -z "$(git ls-files example-images/output example-images/gallery example-images/.gallery-staging example-images/.gallery-quarantine)" && rg -q '^status: passed$' .planning/phases/52-eyebrow-safety-and-branch-closeout/52-VERIFICATION.md && rg -q '^nyquist_compliant: true$' .planning/phases/52-eyebrow-safety-and-branch-closeout/52-VALIDATION.md && node /Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs query roadmap.analyze && git diff --check
```

**Expected result:** Final checker, full SwiftPM, guarded renderer/helper/gallery, roadmap analysis, and diff hygiene exit 0; output/gallery counts are exactly 144 each; generated roots are untracked; verification is passed and Nyquist is true at the owning historical state.

`G52-07-01`

```bash
cd BeautySDK && swift test --filter EyebrowWarpProviderTests
```

**Expected result:** Exactly 14 provider tests execute with zero failures, and all shared fixtures enter through the production adapter.

`G52-07-02`

```bash
cd BeautySDK && swift test --filter MissingLandmarkDegradationTests/testSAFE02ParallelCompletionOrderAndInterruptedWorkCannotLeakRequestState
```

**Expected result:** Exactly one targeted test executes with zero failures; an argument-free callback running inside `EyebrowWarpProvider.fieldEmissions` proves provider-owned entry and holds that request before cancellation, the test cancels only after resolver and provider entry, then releases the barrier and observes cancellation-aware discard or documented safe completion, while parallel and subsequent request identities, callbacks, releases, results, and aggregate diagnostics remain isolated.

`G52-07-03`

```bash
cd BeautySDK && swift test --filter CombinedEffectSafetyTests/testSAFE02EveryEyebrowRowIsRemovedMonotonicallyWhenSharedScaleMakesProviderEmpty
```

**Expected result:** Exactly one targeted test executes with zero failures, covering all seven rows, strictly nonzero production pre-sanitization values, monotone removal/no re-entry, final accounting exclusion, and an identical repeated fixed point.

`G52-08-01`

```bash
python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --self-test && swift test --package-path BeautySDK && xcrun simctl list devices available | awk '/^-- iOS 26\.5 --$/{runtime=1; next} /^-- /{runtime=0} runtime && /iPhone 17 Pro \([0-9A-F-]+\) \((Booted|Shutdown)\)$/{found=1} END{exit !found}' && xcodebuild -quiet -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' build && xcodebuild -quiet -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' test && test -z "$(git diff --name-only -- BeautyDemo)"
```

**Expected result:** Checker self-test reports exactly 130/130; full SwiftPM reports exactly 450 executed with six documented conditional skips and zero failures; simulator discovery proves `iPhone 17 Pro` on iOS 26.5 is available; explicit-destination build and test both exit 0; the `BeautyDemo` diff is empty. If discovery cannot prove that runtime, record the blocker and do not fabricate either Xcode pass.

`G52-08-02`

```bash
python3 -c 'from pathlib import Path; import re; base=Path(".planning/phases/52-eyebrow-safety-and-branch-closeout"); e=(base/"52-EYEBROW-SAFETY-EVIDENCE.md").read_text(); s=(base/"52-SECURITY.md").read_text(); n=(base/"52-VALIDATION.md").read_text(); v=(base/"52-VERIFICATION.md").read_text(); assert all(x in e for x in ("WR-01", "WR-02", "WR-03", "pending")); assert "threats_open: 0" in s; ids={f"52-{p:02d}-{t:02d}" for p,count in ((1,3),(2,2),(3,3),(4,2),(5,2),(6,2),(7,3),(8,2),(9,2),(10,2)) for t in range(1,count+1)}; row_lines=re.findall(r"^\| (52-\d{2}-\d{2}) \|([^\n]+)$",n,re.M); rows=[task for task,_ in row_lines]; assert len(rows)==23 and set(rows)==ids; assert all(rest.count(f"`G{task}`")==1 for task,rest in row_lines); entries=re.findall(r"^`G(52-\d{2}-\d{2})`\n\n```bash\n(.*?)\n```\n\n\*\*Expected result:\*\* ([^\n]+)$",n,re.M|re.S); assert len(entries)==23 and {task for task,_,_ in entries}==ids; assert all(command.strip() and expected.strip() for _,command,expected in entries); commands=dict((task,command) for task,command,_ in entries); assert "xcrun simctl list devices available" in commands["52-08-01"]; assert all(token in commands["52-08-01"] for token in ("platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5", " build", " test", "git diff --name-only -- BeautyDemo")); assert "23/23" in n and "execution are complete for all fourteen" not in n.lower() and "all fourteen task rows are green" not in n.lower(); assert "status: gaps_found" in v' && git diff --exit-code -- .planning/phases/52-eyebrow-safety-and-branch-closeout/52-REVIEW.md && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py
```

**Expected result:** WR-01/02/03 and pending-handoff evidence are present; `threats_open: 0`; validation has exactly 23 unique task rows, exactly 23 same-ID command/result registry entries, and `23/23`; every row maps once to its command key; `G52-08-01` contains simulator discovery, both explicit-destination Xcode actions, and the no-UI gate; stale fourteen-task sign-off is absent; verifier remains `status: gaps_found`; review diff is empty; non-promotion checker exits 0 with Waves 9–10 pending.

`G52-09-01`

```bash
python3 -c 'from pathlib import Path; from datetime import datetime; import re, subprocess; b=Path(".planning/phases/52-eyebrow-safety-and-branch-closeout"); r=(b/"52-REVIEW.md").read_text(); assert all(x in r for x in ("status: clean","critical: 0","warning: 0","info: 0","total: 0","gsd-code-reviewer")); reviewed=datetime.fromisoformat(re.search(r"^reviewed:\s*(\S+)",r,re.M).group(1).replace("Z","+00:00")); commits=[datetime.fromisoformat(subprocess.check_output(["git","log","-1","--format=%cI","--",str(b/f"52-{n:02d}-SUMMARY.md")],text=True).strip()) for n in (7,8)]; assert reviewed > max(commits); v=(b/"52-VALIDATION.md").read_text(); ids={f"52-{p:02d}-{t:02d}" for p,count in ((1,3),(2,2),(3,3),(4,2),(5,2),(6,2),(7,3),(8,2),(9,2),(10,2)) for t in range(1,count+1)}; rows=re.findall(r"^\| (52-\d{2}-\d{2}) \|",v,re.M); assert len(rows)==23 and set(rows)==ids and "23/23" in v' && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-security && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-reliability
```

**Expected result:** Read-only gate proves independent `gsd-code-reviewer` ownership, clean 0/0/0/0 findings, a review timestamp later than committed Wave 7/8 summaries, and exact 23/23 validation; security and reliability modes both exit 0.

`G52-09-02`

```bash
python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-architecture && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-design && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-security && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-reliability && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-product && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-quality && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --check-examples
```

**Expected result:** Architecture, design, security, reliability, product, quality, and examples modes all exit 0.

`G52-10-01`

```bash
node /Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs query roadmap.analyze && python3 -c 'from pathlib import Path; import re; b=Path(".planning/phases/52-eyebrow-safety-and-branch-closeout"); assert (b/"52-09-SUMMARY.md").exists(); r=Path(".planning/ROADMAP.md").read_text(); s=Path(".planning/STATE.md").read_text(); review=(b/"52-REVIEW.md").read_text(); v=(b/"52-VERIFICATION.md").read_text(); n=(b/"52-VALIDATION.md").read_text(); ids={f"52-{p:02d}-{t:02d}" for p,count in ((1,3),(2,2),(3,3),(4,2),(5,2),(6,2),(7,3),(8,2),(9,2),(10,2)) for t in range(1,count+1)}; rows=re.findall(r"^\| (52-\d{2}-\d{2}) \|",n,re.M); assert all(f"52-{x:02d}-PLAN.md" in r for x in range(1,11)); assert "pending" in s.lower() and "verif" in s.lower(); assert all(x in review for x in ("status: clean","critical: 0","warning: 0","info: 0","total: 0")); assert "status: gaps_found" in v; assert len(rows)==23 and set(rows)==ids and "23/23" in n'
```

**Expected result:** Roadmap analysis exits 0; `52-09-SUMMARY.md` exists; all ten plan names are present; state is pending verification; independent review is clean 0/0/0/0; verifier remains gaps-found; validation is exactly 23/23.

`G52-10-02`

```bash
python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --self-test && python3 .planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py --allow-promotion && node /Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs query roadmap.analyze && test -z "$(git diff --name-only -- BeautyDemo)"
```

**Expected result:** Checker self-test reports exactly 130/130; live `--allow-promotion` reports exactly 35/35 with `verification=pending-independent` and Nyquist 23/23; roadmap analysis exits 0; the `BeautyDemo` diff is empty.

## Wave 0 Requirements

- [x] `check_eyebrow_safety_boundaries.py` — compose Phase 49/50 classified boundaries and add cap, convergence, promotion, owner, lifecycle, and adversarial command/path/status modes.
- [x] `BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift` — one shared typed seven-field cap/dead-zone/radius/lifecycle/local-failure descriptor consumed by existing safety/resolver/provider/degradation tests.
- [x] Final Phase 52 late-removal/reused/mixed-sign rows in existing convergence/pipeline tests.
- [x] `52-EYEBROW-SAFETY-EVIDENCE.md` and `52-SECURITY.md`; `52-VERIFICATION.md` remains explicitly owned by Wave 6 and has a complete automated row before that dependency is reached.

## Manual-Only Verifications

Commercial naturalness, physical-device parity, long-run performance, packaging, shipping, and launch readiness are outside Phase 52. The required fourteen-file actual-image review is inherited from Phase 51 and must be reconfirmed against the unchanged final-cap render before promotion; it supplements but does not replace the automated strict gate.

## Validation Sign-Off

- [x] All tasks have `<automated>` verification or an explicit Wave 0 dependency.
- [x] Sampling continuity: no three consecutive tasks lack automated verification.
- [x] Wave 0 covers all missing references before dependent promotion tasks.
- [x] No watch-mode flags.
- [x] Normal focused feedback latency remains under 180 seconds.
- [x] All SAFE/DOC requirements have automated coverage plus the inherited actual-image acceptance gate.
- [x] `nyquist_compliant: true` records exact 23/23 planned task coverage with exact commands/results.
- [ ] Fourteen original rows are green; all nine gap-closure rows remain pending until their owning Waves 7–10 execute.
- [ ] Independent post-Wave-8 code review is pending and remains the exclusive owner of `52-REVIEW.md`.
- [ ] Independent final Phase 52 re-verification is pending and remains the exclusive owner of `52-VERIFICATION.md`.

**Coverage:** 23/23 Phase 52 tasks have explicit automated commands and expected results. Execution is 14/23 green; nine gap-closure rows are pending. Milestone audit is not authorized until independent review, Waves 9–10, and independent final re-verification complete.
