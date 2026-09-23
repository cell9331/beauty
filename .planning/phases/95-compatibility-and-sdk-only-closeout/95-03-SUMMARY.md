---
phase: 95-compatibility-and-sdk-only-closeout
plan: "03"
status: complete
requirements: [CLOSE-01]
tasks: 3
commits: 0
---

# Phase 95 Plan 03: Clean 65-output closeout summary

## Current completion — 2026-09-23

Actual portrait: 65/65 outputs, 2 reconciled runs, seven effective directions and one deferred/partial direction. Current safety 1/0/0, compatibility 4/0/0, archive-first full SwiftPM 937/0/0; all 8 opt-ins accounted for.
Root: 31 fixed source pairs; source interval [260, 373] Q16, neutral interval [260, 373] Q16; all three sibling intervals pass; outside 0 pixels / 0 absolute RGB delta; all root protected-region changes are zero.
All three current responsibilities are complete: actual65 producer/measurement integration, two complete reconciled runs, and archive-first full regression bound to the current inputs.
See[95-CLEAN-65-REPORT.json](95-CLEAN-65-REPORT.json),[95-CLOSEOUT-CHECKS.json](95-CLOSEOUT-CHECKS.json),[95-CLOSEOUT-BINDING.json](95-CLOSEOUT-BINDING.json),[95-COMPLETE.json](95-COMPLETE.json).
FACE-01/faceContourSmooth remains explicitly deferred/partial under FUTURE-04, without effectiveness credit. The repaired observed paired-eye root uses CPU; retained Metal rejects its unsupported private raster cutoff with typed invalidInput before submission and recovers for later supported requests. This is owner-local SDK validation, with no device, population, commercial quality, packaging, shipping, launch, release-readiness or distribution claim. No owner annotation or device action remains. Phase96 is absorbed into95-03, and no next milestone is started.
COMPLETE SHA256: `33b49fee25b4156b8a947ac437822ac33f7e5473a61ed74b1015c393035862d4`; normative input digest: `56d33c8d9ddfbd6899287feeac501139d6ea1bac05250ca8982fa861482ed6f0`.

## Historical failed and diagnostic checkpoints — original text retained, not pending instructions

Historical frontmatter recorded status: blocked and tasks: 1. The body below retains the actual failed attempts; the completed current status does not rewrite them.

## Owner-authorized repair in progress

### Latest checkpoint: actual source coverage gap (2026-09-15)

Independently approved read-only diagnostic ran twice with identical complete
records: crest11/16 and contour3/16 vertical coverage. These counts do not label
root sides; existing unextrapolated contour support cannot meet minimum12 rows.
Local source-boundary confirmation or separately validated automatic anatomical
registration needs disposition; no lower coverage threshold or proxy is adopted.
Source registration/scoring remains0; latest full portrait6/7, milestone incomplete.

Forward structural localization and actual generated canonical positive/negative
tests are implemented. Independent code review is clean after repairing JSON
coercion/duplicate acceptance, bounded child cleanup and live-state test checks.
See95-ROOT-FORWARD-INTEGRATION.md and95-ROOT-ANATOMY-COVERAGE-OBSERVATION.json.
Final related SwiftPM29/0/0 under Python optimization, SDK boundary and diff
checks pass. No fresh full no-skip or completion receipt.

### Latest checkpoint: nonlinear model independently reviewed (2026-09-15)

Generated-only correspondence admits arbitrary per-sample horizontal motion;
38 true shifts contained and32/1024Q16 each pass2/2. Negative and <=16Q16 cases
do not pass;17/20 also remain conservatively unaccepted. Two ambiguity controls
pass. Actual root tests3/0/0 pass with Python optimization. Independent math
review found no discrepancy; its optimization-bypass warning was repaired and
cleared by v2. See95-ROOT-NONLINEAR-MODEL.md and v1/v2 reviews. No production,
source, ROI, threshold or original frozen metric changes; no new portrait score.
Next: source-only anatomy and versioned admission/scoring integration, then
full portrait and independent closeout. Final related SwiftPM23/0/0, SDK
boundary and diff checks pass. Latest full portrait remains6/7.

### Previous checkpoint: actual root invalidates affine assumptions (2026-09-15)

Two generated actual-root tests pass: canonical/PNG sampling is within one
unrounded Double byte on the selected grids, but the actual field exceeds
the +/-1px domain and exact local affine assumption. Related SwiftPM30/0/0;
SDK boundary and diff checks pass. See95-ROOT-APPLICABILITY.md. No production,
portrait, ROI or frozen acceptance changes. Next: larger non-affine model,
then anatomical registration and portrait acceptance; do not promote the
previous affine prototype or resume intensity tuning. Full portrait remains6/7.

### Previous checkpoint: signed affine model reviewed (2026-09-15)

Replaced the initial generated one-channel/inward-only draft, whose32Q16 power
was0/2, with exact signed RGB affine motion plus gain/offset feasibility.
Final42 paired cases contain84 true shifts;32Q16 power6/6,20Q16 power5/6,
-32/0/15/16/17 each0/6 under unchanged16Q16 margin. Ambiguity is retained, not
cut away; fixture truth is analytic, not independent production geometry.
Independent review agrees on22 polytopes/97 exact clipping stages, no findings.
See95-ROOT-AFFINE-MODEL.md and NEW95-ROOT-AFFINE-REVIEW-v1.md. No production,
ROI, source or threshold changes. Actual non-affine root/image-formation and
anatomy registration remain before scoring. Last full portrait6/7; incomplete.

### Previous checkpoint: subpixel evidence, not portrait acceptance (2026-09-15)

Implemented exact feasible translation intervals and actual-sampler-backed
126-case evidence. Seven negative controls pass; independent review agrees
on118 additional feasible-set cases. New canonical geometry/PNG tests are
strengthened to unrounded Double error<=1 on selected generated grids and
independently rechecked. Related SwiftPM selection passes21/0/0. See
`95-ROOT-SUBPIXEL-MODEL.md` and `95-ROOT-SUBPIXEL-REVIEW-v1.md`/`-v2.md`.
No production change or new source registration/scoring. Spatially varying
root correspondence and photometric identifiability remain before a successor
can be frozen. Last full portrait6/7 and Phase95 incomplete are unchanged.

### Current investigation: measurement identifiability (2026-09-15)

Independent generated proof exposes an additional measurement-model limitation:
known four-pixel contraction is indistinguishable from allowed spatially varying
blur at zero geometric motion. Probe oracle fix is independently reviewed;
18 integer correspondence cases and3 negative controls pass, and identity/
expansion proof substitutions reject. No anatomical/subpixel or portrait credit.
See `95-ROOT-FIRST-PRINCIPLES.md` and `95-ROOT-IDENTIFIABILITY-REVIEW-v2.md`.
The next action is measurement-power and actual-sampling validation; the earlier
manual-registration proposal is not the only path and cannot alone solve this
problem. Last full portrait remains6/7; Phase95 is not complete.

### Current checkpoint: metric repaired; source registration ambiguous (2026-09-14)

Resumed standalone archive-first regression passed 914/0/0 with all eight
opt-ins and unchanged before/after run-time snapshot. See
`95-RESUMED-REGRESSION-2026-09-14.json`. This is not formal closeout credit.
A bounded source-only diagnostic with unchanged predicates isolated the
registration failure to `remote_competing_edge`; it did not register the source
or evaluate outputs. The remaining registration decision below still applies.

Candidate 6 remains the last complete portrait evaluation: six of seven active
directions pass, including chin at 23; root -2 fails, all outside/protection
changes zero. Candidates 7–10 single-case old-metric failures remain historical.
Independent review confirmed the old root metric could reverse true narrowing
and accept photometric changes. The owner authorized a versioned measurement
repair while retaining ROI/threshold/source/history.

Generic draft 2 was independently approved and frozen (a205d973) after resolving
three numerical/input blockers and an independent-test oracle warning. It passes
346 generated checks and focused SwiftPM 11/0/0. Comparator case-to-metric
identity validation passes 597 checks. Ordinary full SwiftPM before the added
oracle regression passed 913/0 with eight opt-in skips, not a no-skip gate.

Source-only registration and the subsequent stdout/stderr transport correction
were independently reviewed (2a96d8f4 / 4a71c8c8); current adapter/admission/
transport tests pass 8/22/7. The actual corrected registrar returns exit2,
`ambiguous_structure` on the unchanged source. No successful registration pair,
amended portrait scoring, final no-skip or Phase95 completion exists.
See `95-ROOT-SOURCE-ATTEMPTS-v2.json` for aggregate attempt identities/history.

Current automatic source-registration rules cannot uniquely admit this source.
Do not retune frozen rules from this failure or remove ambiguity rejection.
Proceeding requires a new explicitly chosen source-registration approach, e.g.
owner-confirmed structural correspondence, with its own review before scoring.
This is a pending decision, not implemented or approved by the existing reviews.

### Historical checkpoint: 5/7 active directions pass (2026-09-14)

Owner-requested resumed repair evaluated candidates 3–5. Candidate 5 completed
two reconciled 65-case attempts; gaze, both eyebrow signs, bridge and negative
mouth pass. Chin/root margins remain 14/0 against >=16; all outside/protected
pixel and RGB deltas are zero. FACE-01 remains deferred. Current focused tests
pass 23/0/0 and SDK-only boundary passes. The earlier FACE-01 test disposition
and compatibility scan defect have been corrected under owner authority, but
changed tests have no new independent review binding. Full candidate-5 no-skip,
formal review and CLOSE-01 remain unproven. See `95-REPAIR-RESUMPTION.md` for
actual hashes, measured results, preserved failures and proposed next scope.

### Historical checkpoints

### Latest checkpoint: repair stopped, still blocked (2026-09-13)

Owner-approved source-only ROI registration is frozen and both bounded repair
candidates have been evaluated. Candidate 2 produced 65/65 outputs in two
identical attempts; gaze, both eyebrow signs and bridge pass. Chin margin 5,
root margin 0 and negative mouth margin -7 still miss the unchanged ±16
direction/distinctness threshold. All seven active target-signal gates pass;
all outside/protected pixel and RGB measurements are zero. FACE-01 remains
deferred. See `95-ROI-AMENDMENT.md` for append-only history and exact hashes.

Focused candidate-2 regression: 117/0/0. Full ordinary SwiftPM: 904 methods,
8 opt-in skips and 8 assertion failures in one deferred FACE-01 positive test;
the untouched HEAD reproduces exactly those failures. Archive verification
passes; SDK-only boundary rejects the pre-existing Plan-01 compatibility test
string assertion. Its independent frozen binding is not rewritten here.
Final no-skip, independent review, execution-bound closeout records and CLOSE-01
remain unproven. No completed-phase or milestone claim is made.

The remainder of this section records earlier repair checkpoints.

The owner explicitly approved source-anatomy ROI registration. The original
claim below that this was not an ROI defect is superseded by source-only
measurement: both eye apertures are disjoint from the original gaze targets;
eye contours 0/12, pupils 0/2, lower chin 0/7 and mouth corners 0/2 register.
See `95-ROI-AMENDMENT.md` and `95-ROI-REGISTRATION.json` for the pre-evaluation
freeze, unchanged thresholds, preserved registered baseline failure and bounded
repair candidate. Historical paragraphs below remain failure evidence, not
current permission restrictions or proof that registration was correct.

Generated regression selection passed 47/0/0; two additional nose mapping and
redaction tests passed 2/0/0 across all eight orientations and input mirror.
The candidate portrait run is pending; CLOSE-01 is still unproven. No independent
review or final no-skip receipt is claimed.

## Historical initial execution

The clean-65 driver was authored and its 16-case self-test passed. The authorized
execution produced a complete `semantic_fail` receipt: all 65 cases rendered and
all 8 semantic directions were evaluated. Source wiring diagnosis found genuine
repaired-control behavior on the authorized portrait, not a driver/fixture/ROI/
parameter-binding defect. The archive-first zero-skip SwiftPM gate was not run
because the plan requires stopping on this terminal closeout failure.

## Evidence

- `python3 scripts/check-phase95-closeout.py closeout --self-test`: passed,
  16/16.
- Durable owner-local receipt: `example-images/local-test-records/face-feature-batch-report.json`,
  `semantic_fail`, 5 batches, 65/65 complete cases, 8/8 directions evaluated,
  zero missing outputs.
- Source audit: renderer case definitions bind all seven active IDs to the intended
  fields/signs, and `RendererExecution` forwards them to CPU `processResult`.

## Files

- `scripts/run-clean-65-portrait.sh`
- `scripts/check-phase95-closeout.py`

## Blocker

The exact blocker is preserved in the receipt: gaze target signal 0/0; chin taper
-11 Q16 with 59,114 outside pixels; eyebrow head spacing +4/-5 Q16; nose bridge
+9 Q16; nose root +2 Q16 with 881 protected bridge pixels; and negative mouth
width 0 Q16 with 6,478 protected mouth-height pixels. `faceContourSmooth` remains
zero-signal deferred/partial. CLOSE-01 is not proven. Do not relax thresholds,
change ROIs/fixtures/parameters, or rerun until owner disposition.

## Self-Check: PASSED

The driver and modified closeout script exist, the self-test result is
recorded above, and unrelated working-tree changes were preserved.

<!-- beauty-v122-complete-sha256: 33b49fee25b4156b8a947ac437822ac33f7e5473a61ed74b1015c393035862d4 -->
