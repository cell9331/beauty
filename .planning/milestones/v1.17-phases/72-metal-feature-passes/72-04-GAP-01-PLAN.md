---
phase: 72-metal-feature-passes
plan: "04"
type: execute
wave: 4
depends_on: [72-03]
gap_closure: true
files_modified:
  - BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift
  - scripts/check-metal-feature-passes.sh
  - .planning/ROADMAP.md
autonomous: true
requirements: [METAL-02]
must_haves:
  truths:
    - "Metal color/skin mapping preserves the retained CPU saturation equation for a combined plan: strengths.saturation * 0.28 - strengths.skinSmoothing * 0.18 + filter.saturation, while keeping the separate smoothing uniform and finite bounded math."
    - "A generated in-memory saturation-plus-skin-smoothing CPU-vs-Metal regression fails the omitted-term implementation and passes only when the combined CPU coefficient is preserved within the declared byte tolerance."
    - "The Metal backend build no longer emits the known unused withUnsafeMutableBytes warning in its still-image rasterization copy path."
    - "The Phase 72 roadmap ledger records the three executed plans plus this gap-closure plan instead of the stale 0/TBD Not started row, and the implementation can advance that row to 4/4 Complete after closure."
  artifacts:
    - path: "BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift"
      provides: "CPU-semantic Metal color uniform mapping and warning-free rasterization copy"
      contains: "- strengths.skinSmoothing * 0.18"
    - path: "BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift"
      provides: "Generated combined saturation and skin-smoothing CPU-vs-Metal regression"
      contains: "testGeneratedCombinedSaturationAndSkinSmoothingMatchesCPU"
    - path: "scripts/check-metal-feature-passes.sh"
      provides: "Focused-count and static marker enforcement for the new combined regression"
      contains: "expected_focused_tests=32"
    - path: ".planning/ROADMAP.md"
      provides: "Phase 72 plan inventory and executed/completed progress ledger"
      contains: "72-04-GAP-01-PLAN.md"
  key_links:
    - from: "BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift"
      to: "BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift"
      via: "saturationDelta mirrors the retained CPU applyColorEffects coefficient"
      pattern: "saturationDelta:.*skinSmoothing.*0\\.18"
    - from: "BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift"
      to: "BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift"
      via: "generated combined plan renders CPU and Metal through the backend contract"
      pattern: "BeautyMetalBackend|BeautyCPUBackend|skinSmoothing"
    - from: "scripts/check-metal-feature-passes.sh"
      to: "BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift"
      via: "focused filter, expected count, suite identity, and combined-test marker"
      pattern: "BeautyMetalColorPassTests|expected_focused_tests=32"

---

<objective>
Close verification gap G-01 in the Metal color/skin pass by restoring the
retained CPU saturation coefficient for combined saturation and skin smoothing,
proving it with a generated CPU-vs-Metal regression, removing the identified
backend warning, and synchronizing the Phase 72 progress ledger.

Purpose: The individual color rows and existing feature gate can pass while a
combined plan diverges from `BeautyColorEffectPipeline.applyColorEffects`. The
Metal adapter must preserve the full existing equation before Phase 72 can be
treated as complete.

Output: Corrected backend mapping, generated combined-plan regression, focused
feature-gate accounting/static enforcement, and a non-stale Phase 72 roadmap
row. No shader, public configuration, parameter schema, or new algorithm is
introduced.
</objective>

<execution_context>
@/Users/yakangwang/.codex/get-shit-done/workflows/execute-plan.md
@/Users/yakangwang/.codex/get-shit-done/templates/summary.md
</execution_context>

<context>
@AGENTS.md
@PLANS.md
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/REQUIREMENTS.md
@.planning/STATE.md
@.planning/phases/72-metal-feature-passes/72-VERIFICATION.md
@.planning/phases/72-metal-feature-passes/72-01-SUMMARY.md
@.planning/phases/72-metal-feature-passes/72-02-SUMMARY.md
@.planning/phases/72-metal-feature-passes/72-03-SUMMARY.md
@.planning/phases/72-metal-feature-passes/72-03-PLAN.md
@BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift
@BeautySDK/Sources/BeautyEffects/Backend/BeautyCPUBackend.swift
@BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift
@BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift
@scripts/check-metal-feature-passes.sh
</context>

<interfaces>
`BeautyColorEffectPipeline.applyColorEffects` is the retained still-image CPU
reference and computes the saturation scale from
`1 + strengths.saturation * 0.28 - strengths.skinSmoothing * 0.18 +
filter.saturation`. `BeautyMetalBackend.makePasses` converts the same plan into
`BeautyMetalColorParameters.saturationDelta`; `Warp.metal` already consumes
that delta and the separate `strengths.skinSmoothing * 0.16` smoothing value.
`BeautyMetalColorPassTests` already owns generated in-memory fixtures and CPU/
Metal helpers, while `check-metal-feature-passes.sh` requires its focused suite
and exact aggregate count. Keep CPU as the reference, preserve the one retained
shader, and keep all diagnostics aggregate-only.
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Restore the combined CPU coefficient and prove G-01</name>
  <read_first>BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift; BeautySDK/Sources/BeautyEffects/Backend/BeautyCPUBackend.swift; BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift; BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift; BeautySDK/Tests/BeautyEffectsTests/CPUReferenceColorOracleTests.swift; scripts/check-metal-feature-passes.sh</read_first>
  <files>BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift; BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift; scripts/check-metal-feature-passes.sh</files>
  <action>In `BeautyMetalBackend.makePasses`, map `saturationDelta` to the exact retained CPU coefficient `strengths.saturation * 0.28 - strengths.skinSmoothing * 0.18 + filter.saturation` (the missing term is the G-01 fix); leave the existing separate `smoothing: strengths.skinSmoothing * 0.16`, shader uniform contract, pass order, bounds, and no-CPU-alternate boundary unchanged. In the same backend file, explicitly discard the return value of the rasterization `bytes.withUnsafeMutableBytes` copy operation so the known unused-result warning at the current rasterization line is gone without changing row-byte validation or input bytes. Extend `BeautyMetalColorPassTests` with a generated in-memory test named `testGeneratedCombinedSaturationAndSkinSmoothingMatchesCPU`: exercise a matrix containing at least `saturation=0.8` and `skinSmoothing=0.8` together, render the same opaque generated fixture through the retained CPU still-image reference and Metal backend, assert equal dimensions/alpha, `maxChannelDelta <= 8`, and `meanRGBDelta < 5.0` so the pre-fix omitted-term output (observed up to 12 per channel) fails, and retain aggregate-only diagnostics with no raw payloads or durable fixtures. The test must fail against the old mapping, not merely assert that both individual rows are nonzero. Update `check-metal-feature-passes.sh` for the added focused XCTest (expected count 32) and require the named combined regression marker in the generated color suite; preserve its existing five-suite filter, availability split, mutation checks, and zero-failure/zero-skip accounting.</action>
  <verify>
    <automated>swift build --package-path BeautySDK</automated>
    <automated>swift test --package-path BeautySDK --filter 'BeautyEffectsTests.BeautyMetalColorPassTests|BeautyEffectsTests.BeautyMetalBackendTests|BeautyEffectsTests.CPUReferenceColorOracleTests'</automated>
    <automated>bash scripts/check-metal-feature-passes.sh --self-test</automated>
    <automated>bash scripts/check-metal-feature-passes.sh</automated>
    <automated>build_log=$(mktemp "${TMPDIR:-/tmp}/beauty-metal-build.XXXXXX"); swift build --package-path BeautySDK 2>&1 | tee "$build_log" >/dev/null; if rg -n 'result of call to withUnsafeMutableBytes is unused|withUnsafeMutableBytes.*unused' "$build_log"; then rm -f "$build_log"; exit 1; fi; rm -f "$build_log"</automated>
    <automated>git diff --check</automated>
  </verify>
  <done>The Metal color adapter includes the retained CPU skin-smoothing contribution, the generated combined plan rejects the former omission through CPU-vs-Metal output checks, the feature preflight accounts for the new test, and the backend build warning is absent.</done>
</task>

<task type="auto">
  <name>Task 2: Finalize the Phase 72 progress ledger after gap closure</name>
  <files>.planning/ROADMAP.md</files>
  <action>Synchronize the Phase 72 detail and progress entries with the executed plan inventory: retain the three completed plan entries, list `72-04-GAP-01-PLAN.md` as the gap-closure plan, remove the stale `0/TBD`/`Not started` state, and after Task 1's focused/live preflight is green set the progress row to `4/4 | Complete` with the actual closure date. Leave Phase 73 and Phase 74 rows, requirements ownership, and all deferred product/device/release boundaries unchanged.</action>
  <verify>
    <automated>if rg -n -C 1 '^\| 72\. Metal Feature Passes \|.*0/TBD|^\| 72\. Metal Feature Passes \|.*Not started' .planning/ROADMAP.md; then exit 1; fi</automated>
    <automated>rg -n '72-04-GAP-01-PLAN\.md|\| 72\. Metal Feature Passes \|.*4/4 \| Complete \|' .planning/ROADMAP.md</automated>
    <automated>bash scripts/check-sdk-only-boundary.sh --post-archive</automated>
    <automated>bash scripts/run-no-skip-swiftpm.sh --self-test</automated>
    <automated>git diff --check</automated>
  </verify>
  <done>The roadmap enumerates the gap-closure plan and records Phase 72 as 4/4 Complete only after the combined regression and feature gate pass; no later-phase scope is moved.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
| --- | --- |
| Retained CPU effect plan → Metal color uniforms | Normalized effect strengths and filter contribution become finite GPU scalar parameters. |
| Generated CPU reference → Metal output regression | In-memory synthetic bytes cross only into test-local CPU/Metal render calls; no private fixture or raw diagnostic is persisted. |
| Verification evidence → roadmap lifecycle | Focused test/gate results authorize the Phase 72 completion-row update; later public configuration and parity phases remain separate. |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
| --- | --- | --- | --- | --- |
| T-72-G01 | Tampering | `BeautyMetalBackend.makePasses` saturation mapping | mitigate | Copy the exact retained CPU coefficient including `-strengths.skinSmoothing * 0.18`; generated combined CPU-vs-Metal coverage fails the omission. |
| T-72-G02 | Information Disclosure | Combined color regression and diagnostics | mitigate | Use generated in-memory fixtures, bounded byte comparisons, and existing aggregate-only result fields; do not add masks, landmarks, pixels, locators, or logs to durable artifacts. |
| T-72-G03 | Denial of Service | Color uniform and rasterization copy path | mitigate | Preserve existing finite parameter validation, checked dimensions/row bytes, bounded fixture size, and warning-only cleanup change; no new allocation or shader dispatch is introduced. |
| T-72-G04 | Repudiation/Tampering | Phase 72 roadmap completion row | mitigate | Change the row only after focused/live feature preflight and warning checks pass; leave Phase 73/74 ownership and excluded claims unchanged. |
| T-72-SC | Tampering | npm/pip/cargo installs | accept | No package-manager installation or dependency change is part of this closure. |
</threat_model>

<verification>
Run the focused generated color/backend/CPU-reference suites, build and warning
scan, Metal feature preflight self-test and live mode with updated exact
accounting, the mandatory archive-first no-skip wrapper, post-archive SDK-only
boundary, and `git diff --check`. The closure must show separate Metal
availability classification and no public configuration, shader inventory,
parameter, UI, device, performance, or release-scope change.
</verification>

<success_criteria>
- G-01 is closed: `saturationDelta` includes the retained
  `-strengths.skinSmoothing * 0.18` contribution and a generated combined
  saturation-plus-smoothing CPU-vs-Metal regression rejects the old mapping.
- The known backend `withUnsafeMutableBytes` unused-result warning is absent.
- `check-metal-feature-passes.sh` passes self-test/live mode with 32 focused
  tests, zero failures/skips, and explicit Metal availability accounting.
- `.planning/ROADMAP.md` no longer reports Phase 72 as `0/TBD`/`Not started`;
  after execution it records the four-plan phase as complete without changing
  Phase 73/74 ownership or excluded claims.
</success_criteria>

<output>
Create `.planning/phases/72-metal-feature-passes/72-04-GAP-01-SUMMARY.md` when done.
</output>
