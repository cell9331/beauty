---
phase: 80
artifact: qualification-contract
version: 4
status: frozen-before-private-outcomes
authority: phase-owned-private-qualification-only
---

# Phase 80 Candidate-v4 Qualification Contract

Candidates v1 through v3 remain immutable terminal failures. This record
qualifies only candidate v4's boundary-anchored relief-flattening editor and
cannot borrow their evidence, thresholds, reviews, or outcomes.

The effect means visibly flatter, less puffy upper-eyelid relief (`去脂`) only.
Uniform regional darkening is insufficient. Smoothing, whitening, geometry or
warp, eye opening/enlargement, brow movement, crease invention, eye-bag or
dark-circle work, and unrelated local-retouch effects remain prohibited proxies.

This record was frozen after generated mechanics passed and before any private
candidate-v4 output was generated or viewed.

<!-- CANONICAL_V4_QUALIFICATION_RECORDS_BEGIN -->
```json
{
  "version": 4,
  "feature_id": "upper-eyelid-fullness-reduction",
  "evaluator_version": "phase80-qualification-evaluator-v4",
  "phase75_bindings": {
    "semantic_contract_hash": "dd961264f201025c6abf332a97cd8976dcc6e4c42104bf578759b5b47ef99346",
    "evidence_contract_hash": "a5c1f92d4e9b95c5ef2f100755d7af0f61f0a025b65a867dacb08e640bfdd4e2"
  },
  "review_rubric_hash": "de1c2284cea670b0441f3dc91ea570ce9801d3f2e78eb822b7fa574d6407afbb",
  "baseline_binding": {
    "baseline_id": "boundary-anchored-relief-flattening-editor-v4",
    "qualification_strength": 1,
    "minimum_source_convexity_srgb8": 3.5,
    "relief_compression_gain": 1.5,
    "maximum_analysis_radius": 24,
    "absolute_channel_safety_cap_srgb8": 16,
    "implementation_commit": "c70b9eacc0d832f4765a15cf503c04b557cbdcbb",
    "baseline_source_digest": "33b441f015f2f167da951dfefd3251c683c36b8f4a6abca7000870890e3a49d7",
    "baseline_evidence_digest": "6112c0ade0f9eb8e8e7f8165e4da4fed3ebf43a74078e9a079bc797f4f6d648a",
    "v3_contract_digest": "3006fea83e585d8c3086e590b14069f30fe3cacd29531a4aea7c48c98cd60d2a",
    "v3_helper_digest": "7c2c94e13be4bd1b711aa4d927d1ff28cb1ae547394edab306922ce94b8ccdab",
    "v3_test_digest": "18f04b8ec6d00b35150661192c0edb5236c4314936051be17cc1628206acff95",
    "focused_suite_count": 5,
    "focused_test_count": 30,
    "focused_test_status": "pass"
  },
  "public_absence": {
    "beauty_parameter_fields": 61,
    "preset_ids": 5,
    "renderer_cases": 74,
    "required_until_promotion_passes": true
  },
  "bundle_schema": {
    "schema_version": 4,
    "admission_mode": "genuine-private",
    "origin": "genuine-captured",
    "rights_status": "approved_internal_evaluation",
    "rights_record_present": true,
    "minimum_fixture_count": 2,
    "requires_positive": true,
    "requires_negative": true,
    "generated_fixture_weight": 0,
    "required_categories": [
      "genuine-positive",
      "genuine-negative",
      "ambiguity",
      "pose-occlusion",
      "identity-diversity",
      "protected-structure"
    ],
    "asset_roles": ["original", "support-envelope", "candidate-output"],
    "one_metric_row_per_declared_fixture_category": true,
    "v1_v2_or_v3_binding_and_evidence_credit_rejected": true
  },
  "metric_matrix": {
    "row_keys": [
      "fixture_id",
      "category",
      "target_metrics_applicable",
      "efficacy",
      "source_central_convexity_srgb8",
      "output_central_convexity_srgb8",
      "convexity_reduction_ratio",
      "correction_spatial_range_srgb8",
      "target_mean_abs_channel_delta_srgb8",
      "containment",
      "texture_high_frequency_retention",
      "geometry_protected_structures",
      "boundary_correction_jump_srgb8",
      "feather_to_zero",
      "metadata_integrity",
      "no_op",
      "deterministic_repeatability",
      "alpha_exact",
      "extent_exact",
      "rejected_source_exact",
      "color_target_region_nonempty",
      "color_protected_region_nonempty",
      "color_target_max_abs_channel_delta_srgb8",
      "color_protected_max_abs_channel_delta_srgb8"
    ],
    "common_comparisons": [
      {"field": "containment", "direction": "exact", "threshold": 0, "tolerance": 0},
      {"field": "texture_high_frequency_retention", "direction": "minimum", "threshold": 0.98, "tolerance": 0},
      {"field": "geometry_protected_structures", "direction": "exact", "threshold": 0, "tolerance": 0},
      {"field": "metadata_integrity", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "no_op", "direction": "maximum", "threshold": 0, "tolerance": 0},
      {"field": "deterministic_repeatability", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "alpha_exact", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "extent_exact", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "rejected_source_exact", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "color_protected_max_abs_channel_delta_srgb8", "direction": "exact", "threshold": 0, "tolerance": 0}
    ],
    "accepted_positive_requirements": {
      "target_metrics_applicable": true,
      "source_central_convexity_srgb8": {"direction": "minimum", "threshold": 3.5, "tolerance": 0},
      "output_central_convexity_srgb8": {"direction": "minimum", "threshold": 0, "tolerance": 0},
      "convexity_reduction_ratio": {"direction": "minimum", "threshold": 0.35, "tolerance": 0},
      "convexity_reduction_ratio_maximum": 1,
      "convexity_ratio_consistency_tolerance": 0.01,
      "correction_spatial_range_srgb8": {"direction": "minimum", "threshold": 6, "tolerance": 0},
      "target_mean_abs_channel_delta_srgb8": {"direction": "minimum", "threshold": 3, "tolerance": 0},
      "boundary_correction_jump_srgb8": {"direction": "maximum", "threshold": 5, "tolerance": 0},
      "feather_to_zero": {"direction": "exact", "threshold": 1, "tolerance": 0},
      "color_target_region_nonempty": true,
      "color_target_max_abs_channel_delta_srgb8": {"direction": "maximum", "threshold": 16, "tolerance": 0}
    },
    "rejected_negative_or_stress_requirements": {
      "target_metrics_applicable": false,
      "efficacy": 0,
      "source_central_convexity_srgb8": 0,
      "output_central_convexity_srgb8": 0,
      "convexity_reduction_ratio": 0,
      "correction_spatial_range_srgb8": 0,
      "target_mean_abs_channel_delta_srgb8": 0,
      "boundary_correction_jump_srgb8": 0,
      "feather_to_zero": 0,
      "color_target_region_nonempty": false,
      "color_target_max_abs_channel_delta_srgb8": 0,
      "rejected_source_exact": 1,
      "color_protected_region_nonempty": true,
      "color_protected_max_abs_channel_delta_srgb8": 0
    },
    "efficacy_must_equal_convexity_reduction_ratio": true,
    "applicability_is_bound_to_fixture_polarity": true,
    "inapplicable_target_metrics_receive_no_credit": true,
    "aggregate_only_after_all_rows_are_independently_evaluated": true
  },
  "review_rubric": {
    "mode": "blinded-original-detail-relief-boundary-v4",
    "fixed_fields": [
      "target_fullness_reduced",
      "relief_shape_flatter",
      "uniform_tone_shift_only_absent",
      "prohibited_proxy_absent",
      "protected_structures_preserved",
      "original_detail_natural",
      "boundary_artifact_absent",
      "review_decision",
      "reason_code"
    ],
    "reason_codes": [
      "target-not-visible",
      "relief-shape-not-flatter",
      "uniform-tone-shift-only",
      "proxy-present",
      "protected-structure-change",
      "detail-unnatural",
      "boundary-artifact",
      "occlusion-or-pose-ambiguous",
      "review-failure"
    ],
    "pass_reason": null,
    "positive_pass_predicate": {
      "target_fullness_reduced": true,
      "relief_shape_flatter": true,
      "uniform_tone_shift_only_absent": true,
      "prohibited_proxy_absent": true,
      "protected_structures_preserved": true,
      "original_detail_natural": true,
      "boundary_artifact_absent": true
    },
    "negative_and_stress_pass_predicate": {
      "target_fullness_reduced": false,
      "relief_shape_flatter": false,
      "uniform_tone_shift_only_absent": true,
      "prohibited_proxy_absent": true,
      "protected_structures_preserved": true,
      "original_detail_natural": true,
      "boundary_artifact_absent": true
    },
    "failure_requires_one_fixed_reason": true,
    "freeform_text": false
  },
  "review_schema": {
    "schema_version": 4,
    "complete": true,
    "rubric_frozen_before_outcomes": true,
    "blindness_attested": true,
    "candidate_identity_hidden": true,
    "locator_hidden": true,
    "detail_scale_percent": 100,
    "every_declared_fixture_category_exactly_once": true,
    "all_category_pass_rates_required": 1
  },
  "decision_policy": {
    "promotion_decision": "promotion-ready-relief-flattening-editor-v4",
    "non_promotion_decision": "qualification-not-passed",
    "missing_or_malformed_input": "fail-closed",
    "private_rows_assets_masks_landmarks_and_locators_forbidden_in_output": true,
    "canonical_decision_written_only_after_complete_valid_external_inputs": true
  }
}
```
<!-- CANONICAL_V4_QUALIFICATION_RECORDS_END -->

## Frozen interpretation

- Positive fixtures must prove a measurable source convexity cue, at least 35%
  convexity reduction, at least six sRGB8 values of spatial correction range,
  and at least three sRGB8 mean target change in addition to every inherited
  containment, texture, boundary, color, and protection metric.
- A positive cannot pass by uniformly darkening the support. Review must see a
  flatter lid shape, not merely a different tone.
- Negative/stress fixtures must remain source exact. Target and relief metrics
  are explicitly inapplicable and receive no positive credit.
- The support visualization is review-only and must never appear in candidate
  output.
- A square, dark block, halo, visible edge, invented crease, changed eye opening,
  or brow movement is an independent human-review failure at 100% detail.
- Only aggregate counts, extrema, hashes, and fixed reason counts may become
  durable; all private material remains external.
