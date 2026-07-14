---
phase: 36
status: passed
verified: 2026-07-14
requirements: [NOSE-07, NOSE-08, NOSE-09]
verifier: independent
verified_head: c8c8588
---

# Phase 36 Independent Verification

## Verdict

Passed. The Phase 36 goal and NOSE-07, NOSE-08, and NOSE-09 are satisfied by the current code, generated local evidence, and fresh independent reruns. This verdict was derived from the implementation and artifacts, not from summaries alone.

The repository is clean at `c8c8588`; the final implementation remediation is `efdaad4`, and the subsequent deep review records zero critical, warning, or informational findings. No Phase 37 cap, exhaustive safety, active-source closeout, product promotion, or readiness claim is included.

## Must-Have Verification

| Must-have | Independent result | Actual owner/evidence |
| --- | --- | --- |
| Exactly 36 public-facade cases | Passed: 36 `RenderCase` IDs, all unique; one shared `engine.processResult` call; only `BeautySDK` plus platform imports | `BeautyExampleRenderer/main.swift`; focused renderer inventory test |
| Exactly two isolated new cases | Passed: `noseRootNarrowing_0p25` and `noseTipLift_0p25` each occur once and each initializes only its matching public field at exact `0.25`; the nose contract is seven cases over six fields with no alias/combo case | Renderer source and `testPhase36NOSE07NoseCasesUseExactlyOnePublicNoseParameter` |
| Seven fixtures / 252 outputs | Passed: seven unique recursive fixture stems, six portraits plus the 64 x 64 no-face fixture; 36 x 7 = 252 output PNGs are present | Actual `example-images/input`, `example-images/output`, and strict helper discovery |
| Strict full decode / same extent / no extras | Passed: the helper discovers inventories before frozen assertions, rejects missing/unexpected names, reads bounded regular files without following symlinks, validates PNG CRC/chunks/IEND/trailing data, bounds and completes zlib decode, reverses filters, and requires exact input dimensions | `check_nose_remaining_renderer_outputs.py`; helper self-test and live strict run |
| 12/12 baseline visibility | Passed at fixed ROI/floors: root 6/6, minimum 1,130 changed pixels / 5,125 RGB delta; lift 6/6, minimum 1,644 / 26,334 | Live 252-output helper and `36-NOSE-OUTPUT-EVIDENCE.md` |
| 6/6 root vs bridge | Passed: minimum 1,291 changed pixels / 5,951 RGB delta | Live strict helper |
| 12/12 lift vs signed tip | Passed: positive-tip 6/6, minimum 1,839 / 20,433; negative-tip 6/6, minimum 2,132 / 34,911 | Live strict helper |
| No-face 2/2 | Passed: both new outputs fully decode at 64 x 64 and equal baseline over the fixed 2,048-pixel label-safe region; focused facade tests also prove extent, `.noFace`, `.noFaceDetected`, zero used faces, aggregate/category-only evidence, and redaction | Strict helper and renderer XCTest |
| Ignored/untracked output and gallery | Passed: actual output and gallery each contain 252 PNGs; representative paths are ignored; tracked and staged scans for output/gallery/staging/quarantine are empty | `.gitignore`, Git containment scans, actual generated roots |
| Safe gallery after deep review | Passed: exact duplicate-free 36-case renderer/gallery bijection; bounded no-follow source acquisition; full identity/size/mtime/ctime stability; exclusive descriptor-relative staging and atomic publication; intact non-traversed single-slot quarantine; fail-closed retry and portability checks | `generate_gallery.py`, gallery self-test, `36-REVIEW-FIX.md`, clean iteration-5 `36-REVIEW.md` |
| No promotion; Phase 37 ownership intact | Passed: `提升` remains future, `山根` and branch-level `鼻子` remain partial; NOSE-10 through NOSE-14 and DOC-01 remain pending under Phase 37, which is next and not started | `FEATURE_MATRIX.md`, `REQUIREMENTS.md`, `ROADMAP.md`, `STATE.md`, and no-promotion diffs |

The fixed portrait ROI is top-origin x `[0.25, 0.75)` and y `[0.20, 0.70)`, and the helper proves its bottom remains above the renderer-matched watermark boundary. Acceptance floors remain fixed at 500 changed pixels and 2,000 absolute RGB delta; the accepting run does not derive its own thresholds.

## Fresh Independent Commands

| Gate | Result |
| --- | --- |
| `python3 example-images/generate_gallery.py --self-test` | Passed, including descriptor leaks, bounded work, source/staging mutation, ancestor swap, quarantine, non-traversal, external survival, and duplicate renderer IDs |
| Phase 36 helper `--self-test` | Passed duplicate IDs/stems, missing/extra/corrupt outputs, bounded decode, replacement/growth races, and ROI/watermark rejection |
| Python compilation | Passed for gallery and strict helper |
| Focused SwiftPM | 10/10 passed, zero failures |
| Full SwiftPM | 220/220 passed, zero failures |
| Live strict helper | Passed against the actual 252-output matrix with all five 6/6 portrait families and no-face 2/2 |
| Gallery/output counts | 252 output PNGs and 252 gallery PNGs |
| Schema drift | `drift_detected: false`, nonblocking |
| Git hygiene | Clean worktree before this report; `git diff --check` passed; generated roots have no tracked or staged files |

The general codebase-drift scan's known stale codebase-map warning is historical mapping debt and does not contradict any Phase 36 implementation, requirement, or current-owner contract; it is nonblocking here.

## Requirement Verdicts

| Requirement | Verdict | Basis |
| --- | --- | --- |
| NOSE-07 | passed | Exactly two isolated public-facade cases expand the exact source inventory to 36 and generate the 36 x 7 matrix without an internal render path |
| NOSE-08 | passed | All 252 outputs are strictly decoded at matching extents with no extras, and the separately gated 12 baseline, 6 root/bridge, and 12 lift/signed-tip ROI comparisons pass fixed floors |
| NOSE-09 | passed | Representative no-face facade and pixel behavior is safe; output/gallery contain exactly 252 ignored local PNGs each; no generated route is tracked or staged |

## Boundaries and Gaps

No Phase 36 gap remains. The `0.25` strengths are provisional evidence inputs, not final caps. Final cap calibration, exhaustive six-field degradation/provider-empty coverage, exactly-once combined weakening, final active-source boundaries, atomic `山根`/`提升` and branch promotion, and DOC-01 remain Phase 37 work. Device parity, commercial naturalness, packaging, shipping, and launch readiness are not claimed.
