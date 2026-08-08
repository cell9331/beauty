---
phase: 64-sclera-output-adversarial-safety-and-independent-closeout
verified: 2026-08-08T00:05:01Z
status: gaps_found
score: 3/6 must-haves verified
overrides_applied: 0
gaps:
  - truth: "The color-independent and recolored-protected oracles prove zero protected entry/change over complete bilateral anatomy and a bounded asymmetric perturbation grid."
    status: failed
    reason: "The executable oracle protects only six individual coordinates, all at x <= 27 near the left synthetic eye although the fixture has eyes centered at x=21 and x=59; it uses three coupled symmetric perturbations, and protectedProposalPixelCount is emitted as a constant zero rather than computed against independent truth."
    artifacts:
      - path: "BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift"
        issue: "protectedCoordinates() is a six-pixel left-side sample, not full-resolution bilateral iris/pupil/highlight/lash/skin/exterior truth; the recolor test changes the same six pixels only."
      - path: "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift"
        issue: "BeautyScleraRednessProviderSummary.protectedProposalPixelCount is always constructed as 0 and is not an oracle."
      - path: ".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py"
        issue: "T-64-03 validates token presence only, so the hollow oracle passes the eight-HIGH checker."
    missing:
      - "Independently authored full-resolution protected masks for both eyes, including iris, pupil, highlights, lash/margin, skin, and aperture exterior."
      - "Independent left/right inward, outward, horizontal, vertical, and asymmetric contour/pupil boundary perturbations, including local fail-closed cases."
      - "Direct intersection of actual proposal indices with protected truth, rather than a provider-owned constant aggregate."
      - "Score-attractive recoloring of every protected pixel followed by byte-level comparison of the complete final composed output."
  - truth: "All mandatory evidence agrees before exact product promotion, and the product ledgers claim only proven completion."
    status: failed
    reason: "SCLERA-14 and SCLERA-15 are not proven, yet both product owners and the prior verification claim that adversarial protected-anatomy safety closed and promote 祛红血丝 to implemented. The conjunction required by SCLERA-18 therefore does not hold."
    artifacts:
      - path: "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md"
        issue: "The 祛红血丝 row claims completed color-independent/recolored-protected safety unsupported by the executable oracle."
      - path: "docs/meitu-function-blueprint/FEATURE_MATRIX.md"
        issue: "The branch evidence column claims Phase 64 closed adversarial safety despite the incomplete gate."
      - path: ".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-SECURITY.md"
        issue: "T-64-03 and T-64-04 are recorded mitigated on evidence that does not cover both eyes or the full protected truth."
    missing:
      - "Close the bilateral oracle gap, rerun focused/native/private/adversarial/full gates, and repeat independent verification before retaining or reapplying promotion."
      - "Synchronize the security disposition and product-owner claims with the corrected executable result."
deferred:
  - truth: "Saved public-facade evidence is encoded through one explicit sRGB color boundary."
    addressed_in: "Phase 65"
    evidence: "Phase 65 success criterion 3 and SAFE-06 own the explicit-sRGB contract. The current Phase 64 renderer still uses CGColorSpaceCreateDeviceRGB(), so this remains a concrete Phase 65 re-verification warning rather than a Phase 64-scored requirement."
---

# Phase 64: Sclera Output, Adversarial Safety, and Independent Closeout Verification Report

**Phase Goal:** `祛红血丝` is independently complete through public output, per-eye real evidence, and adversarial protected-region proof while `去脂` remains future.
**Verified:** 2026-08-08T00:05:01Z
**Status:** gaps_found
**Re-verification:** No — the prior report contained no structured `gaps:` section, so this was an initial goal-backward verification against live code.

## Goal Achievement

The public-output and genuine-evidence portions are substantive and runnable, but the mandatory adversarial proof is materially hollow. Passing test counts do not cure that coverage defect. Because the incomplete proof was used to authorize product promotion, the phase goal is not achieved.

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Open-redness perturbations enter no protected bilateral anatomy across the bounded grid. | ✗ FAILED | The test builds a `Set` from six points at lines 21-32 and `protectedCoordinates()` defines only x=2...27 at lines 199-207, while `makeEyeBytes()` builds eyes centered at x=21 and x=59 at lines 258-279. Only three coupled perturbations exist at lines 35-39. |
| 2 | Recolored protected anatomy remains byte exact through score, feather, hard re-clip, transform, Q16 composition, and final output. | ✗ FAILED | The recolor oracle recolors and checks the same six points only (lines 69-101); it never recolors the complete protected regions or any right-eye protected pixel. |
| 3 | Isolated public-facade output proves visible behavior, peer isolation, dimensions/no-ops, and containment. | ✓ VERIFIED | `BeautyExampleRenderer` imports only `BeautySDK`, has one exact `scleraRednessReduction_1p00` case, and calls `engine.processResult` once. The strict helper performs decoded positive/negative/no-face bounds; focused renderer/provider/facade tests independently ran 46/46 green. |
| 4 | Genuine positive/negative evidence and original-detail review demonstrate bounded improvement and naturalness. | ✓ VERIFIED | The live real-fixture test executes the public facade with explicit sRGB decoding and frozen containment/channel/luminance/texture bounds. The durable review records four blinded original-detail items with no post-review tuning, and UAT records 5/5 passed. |
| 5 | Every mandatory gate agrees before exact `祛红血丝` promotion while `去脂` remains future. | ✗ FAILED | The ledgers correctly keep `去脂` future and `眼睛` partial, but they promote `祛红血丝` while the mandatory SCLERA-14/15 gates are not actually proven. SCLERA-18's conjunction is false. |
| 6 | The exact public inventory is 74 cases with one active sclera case, one baseline, and six private outputs. | ✓ VERIFIED | Source inspection and the gallery/helper checks confirm one active case, exact 74-case inventory, exact 148-file gallery contract, and a six-file private matrix. |

**Score:** 3/6 must-haves verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift` | Complete bilateral geometry and final-output safety oracles | ✗ HOLLOW | Exists, runs, and is wired to the real provider/composer, but samples only six left-side pixels and three coupled perturbations. |
| `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift` | Real guarded proposals and meaningful aggregate evidence | ⚠️ PARTIAL | Provider logic is substantive and produces real proposals, but `protectedProposalPixelCount` is hard-coded to zero at line 118. |
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | Exact public sclera output through stable canonical encoding | ⚠️ VERIFIED WITH WARNING | Public route and case are real; saved evidence is converted with `CGColorSpaceCreateDeviceRGB()` at lines 448-452 rather than named sRGB. |
| `check_sclera_renderer_outputs.py` | Strict six-output decoder and numeric acceptance | ✓ VERIFIED | Bounded decoding, exact inventory, dimensions/alpha, mask exterior, positive improvement, negative naturalness, and no-face equality are substantive. It does not validate the encoded color profile. |
| `64-private-output-runner.js` | Disposable authorized pair/no-face public-facade execution | ✓ VERIFIED | Discovers the ignored bundle, stages bounded regular files, invokes the public renderer, verifies exact output, and keeps artifacts ignored/untracked. |
| `check_phase64_sclera_closeout.py` | Fail-closed eight-HIGH lifecycle checker | ✗ HOLLOW LINK | The lifecycle and inventory checks are substantive, but T-64-03 accepts mere symbol tokens (lines 103-122 and synthetic token fixture at line 302), so it cannot detect the adversarial coverage failure. |
| Product ledgers and `64-SECURITY.md` | Exact promotion only after all gates pass | ✗ CONTRADICTED | Files exist and agree textually, but their safety/completion assertion is contradicted by executable coverage. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `BeautyExampleRenderer/main.swift` | public `BeautySDK` facade | `BeautyParameters(scleraRednessReduction: 1)` + one `engine.processResult` call | ✓ WIRED | No internal or Testing import is present in the renderer. |
| `64-private-output-runner.js` | renderer + strict helper | `swift run BeautyExampleRenderer` then Python decoded verification | ✓ WIRED | Real generated files flow into the strict decoder. |
| adversarial XCTest | provider + composition owner | `makeResult` then `owner.compose` | ⚠️ PARTIAL | The real path executes, but independently authored truth is only six pixels and omits the right eye. |
| provider proposals | independent protected truth | `protectedProposalPixelCount` | ✗ NOT WIRED | The value is always zero; no protected mask or proposal intersection is provided. |
| phase checker T-64-03 | adversarial oracle quality | source token scan | ✗ NOT WIRED | Presence of names is accepted as proof; bilateral mask size, grid breadth, and actual intersections are never checked. |
| safety result | product promotion | checker/security/verification conjunction | ✗ NOT WIRED | The hollow test passes the checker and is then cited by the ledgers as completed safety. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| Public output | `result.output` | authorized image → `BeautyEngine.processResult` | Yes | ✓ FLOWING, with DeviceRGB evidence-encoding warning |
| Strict output helper | decoded baseline/active/mask pixels | six generated PNGs + private reviewed masks | Yes | ✓ FLOWING |
| Geometry oracle | `colorIndependentProtectedTruth` | six hard-coded coordinates | No complete bilateral truth | ✗ HOLLOW |
| Final-output oracle | `recoloredProtected` | same six hard-coded coordinates | No complete protected recolor | ✗ HOLLOW |
| Provider summary | `protectedProposalPixelCount` | literal `0` | No | ✗ STATIC |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Focused renderer/adversarial/provider/facade tests | `swift test --package-path BeautySDK --filter 'BeautyScleraRednessAdversarialCloseoutTests\|BeautyRendererOutputRegressionTests\|BeautyScleraRednessProviderTests\|BeautyEngineScleraRednessIntegrationTests'` | 46 executed, 0 failures | ✓ PASS, but adversarial assertions are under-scoped |
| Strict helper mutations | `python3 .../check_sclera_renderer_outputs.py --self-test` | 14/14 | ✓ PASS |
| Phase checker mutations | `python3 .../check_phase64_sclera_closeout.py --self-test` | 8/8 | ✓ PASS, but T-64-03 only mutates token presence |
| Isolated post-promotion threats | checker `--allow-promotion` plus T-64-01...08 | All reported pass | ✓ PASS, not sufficient for SCLERA-14/15 |
| Gallery inventory | `python3 example-images/generate_gallery.py --self-test` | Exact 74 cases / 148 files | ✓ PASS |
| Direct coverage audit | static extraction of protected points/grid/provider aggregate | 6 samples, max x 27, right center x 59, 3 perturbations, constant aggregate | ✗ FAIL |

The orchestrator additionally reported 630/0/8 full SwiftPM, Demo 121/121, the required private pair, and UAT 5/5. Those are useful regression evidence, but none exercises the missing bilateral protected-truth matrix.

### Probe Execution

No `probe-*.sh` path is declared by the Phase 64 plans or summaries, and no conventional repository probe was discovered for this phase. Step 7c was not applicable.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| SCLERA-14 | 64-01, 64-03, 64-04 | Color-independent protected truth across perturbations | ✗ BLOCKED | Six left-side samples and three coupled perturbations do not prove the required bilateral anatomy/grid. |
| SCLERA-15 | 64-01, 64-03, 64-04 | Recolored-protected full final-output identity | ✗ BLOCKED | Only the same six points are recolored/checked; complete iris/pupil/highlight truth is absent. |
| SCLERA-16 | 64-01, 64-02, 64-03, 64-04 | Genuine positive improvement; negative/unsafe naturalness | ✓ SATISFIED | Real-fixture/public-output bounds, provider challenge tests, review, and UAT align. |
| SCLERA-17 | 64-01, 64-02, 64-04 | Isolated public-facade output and strict decoding | ✓ SATISFIED | Exact public case, six decoded outputs, peer-eye facade harness, dimensions/no-op/containment evidence. |
| SCLERA-18 | 64-01, 64-03, 64-04 | Complete conjunction before exact promotion | ✗ BLOCKED | Promotion and owners advanced despite failed SCLERA-14/15 proof. |
| OUT-05 | 64-01, 64-02, 64-04 | Standalone public facade, decoded comparison, disposable review, original detail | ✓ SATISFIED | Renderer/runner/helper/review chain exists and executes. DeviceRGB is a reproducibility warning; explicit sRGB is owned by Phase 65 SAFE-06. |

No Phase 64 requirement is orphaned from all plan frontmatter.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| `BeautyScleraRednessAdversarialCloseoutTests.swift` | 199 | Six-point protected truth, all left-side | 🛑 Blocker | Bilateral leakage can pass undetected. |
| `BeautyScleraRednessProvider.swift` | 118 | Constant `protectedProposalPixelCount: 0` | 🛑 Blocker | A tautological aggregate is asserted as oracle evidence. |
| `check_phase64_sclera_closeout.py` | 103 | Token-presence safety validation | 🛑 Blocker | The lifecycle checker cannot distinguish the hollow test from a full matrix. |
| `BeautyExampleRenderer/main.swift` | 450 | `CGColorSpaceCreateDeviceRGB()` | ⚠️ Warning | Saved review/output evidence does not use the explicit stable sRGB contract. |

No unreferenced `TBD`, `FIXME`, or `XXX` marker was found in the phase-modified implementation files. The helper's literal `placeholder` occurs only in a negative self-test fixture.

### Deferred Items

| # | Item | Addressed In | Evidence |
| --- | --- | --- | --- |
| 1 | Encode saved public output through named sRGB, not DeviceRGB | Phase 65 | Phase 65 SC3 and SAFE-06 explicitly own the sRGB contract; current code still violates it and needs Phase 65 re-verification. |

### Human Verification Required

No outstanding human-only check is added by this report. Original-detail visual review and conversational UAT are recorded as completed (4/4 review items and 5/5 UAT). A corrected adversarial implementation would trigger a fresh strict run and fresh visual review under D-16.

### Gaps Summary

The root cause is one incomplete adversarial oracle, not a production crash or a missing renderer. It has three downstream effects: SCLERA-14 is unproven, SCLERA-15 is unproven, and SCLERA-18's promotion conjunction is false. The green 5/5 XCTest and 8/8 HIGH checker counts are misleading because the test samples six left-side pixels and the checker only scans for expected tokens. Full bilateral truth, a genuine asymmetric perturbation grid, actual proposal/truth intersection, and full protected recolor must exist before the product-owner promotion can be considered valid.

---

_Verified: 2026-08-08T00:05:01Z_
_Verifier: the agent (gsd-verifier)_
