---
phase: 64
artifact: original-detail-review
status: stale
original_detail: true
blinded_items: 4
decision: invalidated
reason_code: source_changed_after_review
post_review_image_tuning: false
fresh_after_plan_64_06: false
---

# Phase 64 Original-Detail Review (Stale)

This historical categorical result predates the Plan 64-06 correction and is
not current D-13 through D-16 evidence. A fresh source-bound blinded review is
required after the blocking implementation/checker fixes and complete rerun.

| category | positive | negative |
| --- | --- | --- |
| target_present | yes | normal_sclera |
| visible_bounded_redness_reduction | pass | not_applicable |
| sclera_locality | pass | pass |
| protected_leakage | none | none |
| vessel_detail | pass | pass |
| highlight_identity | pass | pass |
| iris_pupil_identity | pass | pass |
| lid_skin_identity | pass | pass |
| natural_color | pass | pass |
| negative_stability | not_applicable | pass |
| decision | pass | pass |
| reason_code | none | none |

Review protocol: `original_detail`; opaque A/B baseline-active comparison before
role reveal; fixed categories only; no post-review image tuning.
