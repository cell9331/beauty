# Phase 31: Nose Renderer Output Evidence - Context

**Gathered:** 2026-07-13
**Status:** Ready for planning
**Mode:** Autonomous `--auto`; all user-locked decisions accepted

<domain>
## Phase Boundary

Add public-`BeautySDK`-facade renderer, helper, and ignored gallery evidence for the four existing nose parameters. This phase does not promote blueprint rows or claim the Phase 32 safety/closeout gates.

</domain>

<decisions>
## Implementation Decisions

### Renderer Matrix
- Add exactly five cases: `noseSlim_0p35`, `noseWingSlim_0p35`, `noseTipSize_plus0p30`, `noseTipSize_minus0p30`, and `noseBridge_0p30`.
- Each case sets exactly one existing public `BeautyParameters` field and uses no internal SDK import.
- Preserve the seven existing fixtures, expanding the matrix from 23 to 28 cases and from 161 to 196 outputs.
- Treat signed `noseTipSize` as two required directions; do not collapse the negative case or convert the field to positive-only.

### Output Helper
- Add a Phase 31 nose-specific Python standard-library helper rather than weakening or repurposing earlier eye/face helpers.
- Require every one of 196 PNG files to exist, fully decode, be non-empty, and match its source dimensions.
- Compare all five nose cases against `geometryBaseline_noop` above the watermark band in a nose/central-face region for all six portrait fixtures, yielding 30/30 required comparisons.
- Require positive and negative `noseTipSize` outputs to differ from one another and each to differ visibly from baseline; failures must be fixed in implementation or fixture logic, not hidden with tolerance/count reductions.
- Require a representative no-face nose output to exist and retain the source dimensions.

### Gallery and Artifact Boundary
- Extend `example-images/generate_gallery.py` with an ignored `nose` group containing exactly the five new case IDs.
- Keep `example-images/output/` and `example-images/gallery/` as ignored generated evidence only; commit no generated PNG baseline.
- Verify representative `git check-ignore` paths and require `git ls-files example-images/output example-images/gallery` to return zero files.
- Preserve gallery deletion safeguards and path-redacted renderer/helper diagnostics.

### Scope and Claims
- SDK-core only: no SwiftUI Demo UI, public field, dependency, network/cloud behavior, account/payment/VIP/entitlement/commercial path, or product-family expansion.
- Do not claim device parity, commercial visual approval, broad Meitu parity, packaging readiness, launch readiness, or whole-branch `鼻子` completion.
- Leave the four-row promotion and all Phase 32 safety/ledger conclusions pending until their focused evidence passes.

### the agent's Discretion
- Choose the smallest central-face crop and byte/pixel-delta reporting details that robustly prove visible nose-localized output while keeping the locked 30-comparison count and signed-direction gates.
- Reuse established Phase 29 helper/evidence structure and repository naming conventions.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyExampleRenderer/main.swift` already defines the 23-case public-facade matrix and seven-fixture output convention.
- `BeautyRendererOutputRegressionTests.swift` owns exact case inventory, facade-only import guards, and one-public-field-per-case patterns.
- Phase 29's `check_eye_renderer_outputs.py` provides the closest helper structure for full PNG decoding, dimensions, portrait-region comparisons, and no-face evidence.
- `example-images/generate_gallery.py` already enforces the allowed gallery root and safe deletion behavior.

### Established Patterns
- Generated flat outputs use `{fixtureStem}__{caseID}.png`; gallery copies use `{group}/{caseID}/{fixtureStem}.png`.
- Geometry cases compare with `geometryBaseline_noop` and exclude the watermark band.
- Current fixtures are six portraits plus `negatives/no-face-gradient.png`.

### Integration Points
- Add cases to `BeautySDK/Sources/BeautyExampleRenderer/main.swift`.
- Extend inventory and scope tests in `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`.
- Add the Phase 31 helper/evidence under this phase directory.
- Add the `nose` group to `example-images/generate_gallery.py` and synchronize example-image owner docs after observed verification.

</code_context>

<specifics>
## Specific Ideas

The five case IDs, 28 × 7 = 196 output count, 6 × 5 = 30 portrait comparisons, signed tip distinction, representative no-face evidence, and ignored-artifact gates are immutable acceptance constraints from the goal objective.

</specifics>

<deferred>
## Deferred Ideas

Exact caps, abnormal-input counts, missing/reused/stale nose geometry, combined weakening, security/ledger promotion, root-contract synchronization, and milestone closeout belong to Phase 32. `山根` alias design and `提升` remain future work.

</deferred>
