---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-15T02:59:22Z
depth: standard
scope: WR-01-fix-only
files_reviewed: 1
files_reviewed_list:
  - scripts/phase95-root-identifiability-probe.py
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
resolved_findings:
  - WR-01
portrait_scoring_authorized: false
phase_completion_review: false
input_sha256:
  scripts/phase95-root-identifiability-probe.py: 972437a7b3e109e078c0aa04733ef23c6e950c499e43af23c645fda7b4be32b7
  scripts/phase95-root-edge-metric.swift: 7100a47cc3176035cb097016b252f00be477307f0d75fde932bffa869027287b
  .planning/phases/95-compatibility-and-sdk-only-closeout/95-REVIEW.md: b266e3ab35a875377ca3d66293d167a88936939e3f84ad4413d1e9466405d062
---

# Phase 95: WR-01 Fix Recheck

## Narrative Findings (AI reviewer)

**WR-01 resolved for the exact probe hash above.** No remaining finding in this fix-only review. This addendum leaves the original report unchanged and does not replace its broader scope limitations.

At `/Users/yakangwang/codes/beauty/scripts/phase95-root-identifiability-probe.py:56-77`, the new oracle inspects every generated row, rejects unexpected levels, requires a nonempty contiguous bright run, and requires equal widths across rows. It checks source width 112 and candidate width 108, then derives Q16 truth from their observed difference. Separate assertions check zero width change for identity and −4 pixels for expansion. Report fields at lines 115–116 expose the observed widths.

This removes the original disconnect between a literal truth claim and the candidate actually measured. The exact identity substitution that previously succeeded now rejects; an expansion substitution also rejects. The oracle is intentionally specific to this two-level synthetic stripe and is not an anatomical width estimator.

## Actual commands and results

Working directory: `/Users/yakangwang/codes/beauty`. All three commands below were executed. Substitutions changed only the loaded Swift string in memory; no source file or generated image was written.

### Normal case

```sh
python3 scripts/phase95-root-identifiability-probe.py --self-test
```

Exit **0**. Observed source/candidate widths **112/108**, known contraction **512 Q16**, frozen conservative margin **−594 Q16**, retained zero-motion explanations **32**. All 18 integer correspondence cases and three negative controls passed; remote-edge rejection remained true. Acceptance credit and phase completion remained false; portrait scoring attempts remained zero.

### Identity substitution

```sh
python3 -B -c 'import runpy,sys; m=runpy.run_path("scripts/phase95-root-identifiability-probe.py"); old="let narrow = try probePlane(2)"; assert m["SWIFT"].count(old)==1; m["main"].__globals__["SWIFT"]=m["SWIFT"].replace(old,"let narrow = try probePlane(0)"); sys.argv=["probe","--self-test"]; m["main"]()'
```

Exit **2**, generated-probe failure, no successful proof report.

### Expansion substitution

```sh
python3 -B -c 'import runpy,sys; m=runpy.run_path("scripts/phase95-root-identifiability-probe.py"); old="let narrow = try probePlane(2)"; assert m["SWIFT"].count(old)==1; m["main"].__globals__["SWIFT"]=m["SWIFT"].replace(old,"let narrow = try probePlane(-2)"); sys.argv=["probe","--self-test"]; m["main"]()'
```

Exit **2**, generated-probe failure, no successful proof report.

Input identities were checked before and after execution with:

```sh
shasum -a 256 scripts/phase95-root-identifiability-probe.py scripts/phase95-root-edge-metric.swift .planning/phases/95-compatibility-and-sdk-only-closeout/95-REVIEW.md
```

Exit **0**; all three hashes matched across the checks and are recorded above. The final reviewed probe hash is `972437a7b3e109e078c0aa04733ef23c6e950c499e43af23c645fda7b4be32b7`.

## Retained mathematical conclusions and limits

The earlier mathematical findings still apply: the same four-pixel contraction yields 512 Q16 truth and a −594 Q16 conservative margin, while the frozen ±2 spatially varying blur model retains zero-motion explanations. The prior independent exact-sample construction remains applicable because the generator and frozen metric are unchanged; it was not rerun as new research here.

Integer NCC still does **not** establish anatomical correspondence, subpixel registration, calibrated confidence or near-threshold measurement power. The oracle repair supplies no new evidence for those claims.

Only WR-01 was rechecked. Broad owners, external research, private inputs, production behavior and Phase95 goal/closeout were not re-reviewed. Only this addendum was written; the original report and source files were preserved. No commit was made. **No portrait scoring, registration, acceptance or Phase95 completion approval is granted.**

