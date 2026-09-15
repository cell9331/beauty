---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-15T02:54:47Z
depth: standard
scope: generated-only-identifiability-probe
files_reviewed: 1
files_reviewed_list:
  - scripts/phase95-root-identifiability-probe.py
findings:
  critical: 0
  warning: 1
  info: 0
  total: 1
status: issues_found
portrait_scoring_authorized: false
phase_completion_review: false
input_sha256:
  scripts/phase95-root-identifiability-probe.py: 1a48ec33d014bbe8ee1cb5703d4ab12098ecdeee8dc7125f11163b0e9975d9b0
  scripts/phase95-root-edge-metric.swift: 7100a47cc3176035cb097016b252f00be477307f0d75fde932bffa869027287b
  .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-FIRST-PRINCIPLES.md: 05c4a1186920902bfed6b899a06003d0bfa3a754d2eca0a79ca2944e7a22a425
  AGENTS.md: 13701c303143657a504312b7420ef0ba64f065e422a14d191a26c7109800ecf1
  PLANS.md: d003291d9aa93075b10cb61c146246d5bbdc2ef48317aecd872a6d319045f7e9
  DESIGN.md: af788f294ffd404bd53f00684cdd72533db31f5ebe65e20daf3c1a6d0e5e8e16
  SECURITY.md: 79965c00d7acd9684fc877c66b1728bc2f0d2994a718e4ca35667d2e7ebdeec3
  QUALITY_SCORE.md: 5575a2f6287ce333c9f9e6666af8385199c77bb133cc781c63863e56c4e658bb
  RELIABILITY.md: bfedd796d39b2ac55a1904a5e55c0ae76ab0afbf5b6dfe4b5a5d694054c085c8
---

# Phase 95: Narrow Generated-Proof Review

## Narrative Findings (AI reviewer)

### WR-01 — WARNING: The known-width oracle is not asserted against the generated input

**File:** `/Users/yakangwang/codes/beauty/scripts/phase95-root-identifiability-probe.py:51-58` (reported at lines 93–96).

**Issue:** `truthQ16` is the literal arithmetic `4 * 65536 / 512`; no assertion connects it to the stripe actually supplied to the frozen metric. The sole margin check requires a result below 16, which identity also satisfies. Replacing only `let narrow = try probePlane(2)` with `let narrow = try probePlane(0)` in memory leaves the complete self-test successful. It still reports `known_contraction_q16=512`, with 32 retained zero-motion explanations and a margin of −1106, although the actual contraction is zero. The later NCC loop builds its own images and does not detect this change. Thus a regression in the counterexample setup can silently retain a false proof claim.

The submitted bytes currently generate the correct four-pixel contraction; this is a demonstrated test-reliability defect, not a finding that the current mathematical counterexample is false.

**Fix:** Independently measure the generated source and candidate stripe spans, without using the frozen metric or provider, and assert 112 and 108 pixels respectively, yielding exactly 512 Q16. Bind the reported truth to that checked result. Add an identity-substitution negative test that must fail the known-contraction proof. An exact −594 regression assertion may additionally bind the documented frozen result, but cannot replace the independent geometry assertion.

## Proof assessment and limits

- **Exact result:** Independent counting of the generated stripe gives widths 112 and 108 pixels. Their four-pixel difference is exactly 512 Q16 at width 512. Frozen source width interval is [13783, 14889], candidate interval [13271, 14377]; source lower bound minus candidate upper bound is exactly −594 Q16. This negative conservative margin does not assert actual expansion.
- **Zero-motion explanation:** Independently constructing the candidate from the unchanged source using a spatially varying point-mass kernel at offset −2 on one side and +2 on the other reproduces all 16,384 samples exactly. Each kernel is nonnegative, normalized and supported within the frozen ±2 envelope, with gain 1, offset 0 and noise 0. Consequently the same observations have both a contracting-geometry explanation and an allowed zero-motion nuisance explanation. This establishes model identifiability loss for this construction, beyond merely trusting `compatible()` to return true. It does not establish the nuisance model of the actual CPU rendering path or portrait.
- **Registration:** The added remote transition makes the frozen global dominance predicate reject a generator-known structure. Local matching succeeds using predetermined anchors whose windows exclude that remote transition. This is an existence example of correspondence without global dominance, not automatic anatomical selection or resistance to competing structure inside a matching window.
- **NCC:** The 18 cases cover integer contraction/identity/expansion with positive gain and offset. Flat, periodic and ramp controls reject. The matcher reads a single row of vertically repeated data and searches integer shifts only. Neither these successes nor a unique correlation maximum prove anatomical correspondence, arbitrary two-dimensional registration, subpixel accuracy, calibrated uncertainty, blur robustness or measurement power near the 16 Q16 floor. The probe comments and first-principles document explicitly preserve these limits.
- **Old positive:** Reading the frozen self-test confirms its primary binary stripe narrows from 122 to 102 pixels, while its exact 15/16/17 decision-boundary tests use supplied point intervals. Its additional pixel-domain near-threshold checks permit conservative non-detection. These checks therefore do not establish sensitivity near the acceptance floor.

## Actual commands and results

Working directory: `/Users/yakangwang/codes/beauty`. Python 3.9.6; Apple Swift 6.3.3, target arm64-apple-macosx26.0. Results below are aggregate measurements, not retained child transcripts.

1. `python3 scripts/phase95-root-identifiability-probe.py --self-test` — exit 0. Known contraction 512 Q16; conservative margin −594 Q16; zero-motion explanations 32; remote-edge rejection true; integer correspondence cases 18; negative controls 3. Acceptance credit false, phase complete false, portrait scoring attempts zero. Returned frozen hash matches the dependency hash above.
2. Independent generated-only harness invoked with `python3 -B -c` and two in-memory `subprocess.run(["swift", "-"], ..., timeout=180)` calls — exit 0. The harness hash-checked the dependency, retained its definitions and the probe helper functions, independently counted stripe widths, constructed the zero-motion blur explanation, measured width intervals and asserted the exact margin. Results: 112→108, 512 Q16, 16,384/16,384 equal samples and −594 Q16. A separate in-memory identity mutation exited 0 and falsely retained the 512 Q16 truth claim. No source or harness file was written.
3. Reproduced WR-01 through the actual Python wrapper using this exact command, which modifies only the loaded in-memory Swift string:

```sh
python3 -B -c 'import runpy,sys; m=runpy.run_path("scripts/phase95-root-identifiability-probe.py"); m["main"].__globals__["SWIFT"]=m["SWIFT"].replace("let narrow = try probePlane(2)", "let narrow = try probePlane(0)"); sys.argv=["probe","--self-test"]; m["main"]()'
```

Result: exit 0; claimed contraction 512 Q16 despite identity input; conservative margin −1106 Q16; 32 zero-motion explanations; 18 NCC cases and three negative controls still pass.

4. `shasum -a 256 AGENTS.md PLANS.md DESIGN.md SECURITY.md QUALITY_SCORE.md RELIABILITY.md scripts/phase95-root-identifiability-probe.py scripts/phase95-root-edge-metric.swift .planning/phases/95-compatibility-and-sdk-only-closeout/95-ROOT-FIRST-PRINCIPLES.md` — exit 0, exact hashes recorded above. Repeated hashes for the six mandatory inputs matched their initial snapshot.
5. `git check-ignore scripts/phase95-root-identifiability-probe.py scripts/phase95-root-edge-metric.swift` — no ignored matches. `.gitignore` was read; `.codexignore` and `.agents/skills/` are absent.

## Scope and disposition

One new source file received standard review. The complete Swift metric was read solely as a frozen dependency; active Phase95 owners and first-principles claims were contextual inputs. Existing unrelated worktree changes were preserved. Only this report was written; no production changes, threshold changes, private image access, network access, new agents or commits occurred.

The code-review skill supplied scope and finding structure. The project spike skill informed aggregate-only privacy and generated-evidence limits; it did not expand the review into fixture evaluation. The configured agent-skills query returned no additional skills. Serena and dedicated Read/Write tools were unavailable; local command reads and the available patch tool were used.

**Disposition:** Zero proven blockers and one warning within this exact scope. The identifiability counterexample is sound for the submitted bytes, with the regression gap above. This is not a full Phase95 implementation, security, goal or closeout review; it grants no source-registration approval, portrait scoring authorization, acceptance credit or completion credit. The referenced external literature was not independently assessed in this local code review.
