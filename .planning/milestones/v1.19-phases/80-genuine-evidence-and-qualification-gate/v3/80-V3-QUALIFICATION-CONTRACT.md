---
phase: 80
artifact: qualification-contract
version: 3
status: frozen-before-private-outcomes
authority: phase-owned-private-qualification-only
---

# Phase 80 Candidate-v3 Qualification Contract

Candidate v1 and v2 remain immutable terminal failures. This record qualifies
only candidate v3's single-sign contour editor and cannot borrow their evidence
or outcomes.

The effect means cosmetic visual upper-eyelid fullness reduction (`去脂`) only.
Smoothing, whitening, geometry/warp, eye opening/enlargement, brow movement,
crease invention, and unrelated local-retouch effects remain prohibited
proxies. Public activation, device/commercial quality, packaging, shipping,
launch, and release readiness remain out of scope.

This record was frozen after generated mechanics passed and before any private
candidate-v3 output was generated or viewed.

<!-- CANONICAL_V3_QUALIFICATION_RECORDS_BEGIN -->
```json
{
  "version": 3,
  "feature_id": "upper-eyelid-fullness-reduction",
  "evaluator_version": "phase80-qualification-evaluator-v3",
  "phase75_bindings": {
    "semantic_contract_hash": "dd961264f201025c6abf332a97cd8976dcc6e4c42104bf578759b5b47ef99346",
    "evidence_contract_hash": "a5c1f92d4e9b95c5ef2f100755d7af0f61f0a025b65a867dacb08e640bfdd4e2"
  },
  "review_rubric_hash": "f6ef7e128e86e299e74f1b3bfd88aa333de50cc6171f1866a03b8f878c270393",
  "baseline_binding": {
    "baseline_id": "single-sign-feathered-contour-editor-v3",
    "qualification_strength": 1,
    "center_contour_delta_srgb8": -10,
    "absolute_channel_safety_cap_srgb8": 16,
    "implementation_commit": "94400c0eb845812c630fb2992928da99401f012e",
    "baseline_source_digest": "94cdded98e18f8485116bb618f5bcc94f5778820196f7b687b0ca530ac380e52",
    "baseline_evidence_digest": "c2f1073e5dc44ceb846570b0a85e75c706d671f366dac410a6257eeca2630653",
    "v2_helper_digest": "8edcd411b74dd226d97fce3b8da6576fcb3eb18b93234f20302b690473a2a80d",
    "v1_safety_helper_digest": "e1d94b4ac6531678483ad57a61a2a00b3b40d06aac6a0c51d6f565e63e1452a6",
    "focused_suite_count": 5,
    "focused_test_count": 25,
    "focused_test_status": "pass"
  },
  "public_absence": {
    "beauty_parameter_fields": 61,
    "preset_ids": 5,
    "renderer_cases": 74,
    "required_until_promotion_passes": true
  },
  "bundle_schema": {
    "schema_version": 3,
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
    "v1_or_v2_binding_and_evidence_credit_rejected": true
  },
  "metric_matrix": {
    "row_keys": [
      "fixture_id",
      "category",
      "target_metrics_applicable",
      "efficacy",
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
      {"field": "containment", "direction": "maximum", "threshold": 0, "tolerance": 0},
      {"field": "texture_high_frequency_retention", "direction": "minimum", "threshold": 0.98, "tolerance": 0.02},
      {"field": "geometry_protected_structures", "direction": "maximum", "threshold": 0.01, "tolerance": 0.01},
      {"field": "metadata_integrity", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "no_op", "direction": "maximum", "threshold": 0, "tolerance": 0},
      {"field": "deterministic_repeatability", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "alpha_exact", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "extent_exact", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "rejected_source_exact", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "color_protected_max_abs_channel_delta_srgb8", "direction": "maximum", "threshold": 0, "tolerance": 0}
    ],
    "accepted_positive_requirements": {
      "target_metrics_applicable": true,
      "efficacy": {"direction": "minimum", "threshold": 0.1, "tolerance": 0.02},
      "boundary_correction_jump_srgb8": {"direction": "maximum", "threshold": 5, "tolerance": 0},
      "feather_to_zero": {"direction": "exact", "threshold": 1, "tolerance": 0},
      "color_target_region_nonempty": true,
      "color_target_max_abs_channel_delta_srgb8": {"direction": "maximum", "threshold": 16, "tolerance": 0}
    },
    "rejected_negative_or_stress_requirements": {
      "target_metrics_applicable": false,
      "efficacy": 0,
      "boundary_correction_jump_srgb8": 0,
      "feather_to_zero": 0,
      "color_target_region_nonempty": false,
      "color_target_max_abs_channel_delta_srgb8": 0,
      "rejected_source_exact": 1,
      "color_protected_region_nonempty": true,
      "color_protected_max_abs_channel_delta_srgb8": 0
    },
    "applicability_is_bound_to_fixture_polarity": true,
    "inapplicable_target_metrics_receive_no_credit": true,
    "aggregate_only_after_all_rows_are_independently_evaluated": true
  },
  "review_rubric": {
    "mode": "blinded-original-detail-boundary-v3",
    "fixed_fields": [
      "target_fullness_reduced",
      "prohibited_proxy_absent",
      "protected_structures_preserved",
      "original_detail_natural",
      "boundary_artifact_absent",
      "review_decision",
      "reason_code"
    ],
    "reason_codes": [
      "target-not-visible",
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
      "prohibited_proxy_absent": true,
      "protected_structures_preserved": true,
      "original_detail_natural": true,
      "boundary_artifact_absent": true
    },
    "negative_and_stress_pass_predicate": {
      "target_fullness_reduced": false,
      "prohibited_proxy_absent": true,
      "protected_structures_preserved": true,
      "original_detail_natural": true,
      "boundary_artifact_absent": true
    },
    "failure_requires_one_fixed_reason": true,
    "freeform_text": false
  },
  "review_schema": {
    "schema_version": 3,
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
    "promotion_decision": "promotion-ready-single-sign-editor-v3",
    "non_promotion_decision": "qualification-not-passed",
    "missing_or_malformed_input": "fail-closed",
    "private_rows_assets_masks_landmarks_and_locators_forbidden_in_output": true,
    "canonical_decision_written_only_after_complete_valid_external_inputs": true
  }
}
```
<!-- CANONICAL_V3_QUALIFICATION_RECORDS_END -->

## Frozen interpretation

- Positive fixtures must have accepted semantic support and prove every target,
  feather, color, efficacy, texture, boundary, and protection metric.
- Negative/stress fixtures must remain source exact. When no semantic request
  or approval exists, target metrics are explicitly inapplicable, must be
  encoded as zero/false, and receive no positive credit.
- The support visualization is review-only and must never appear in the
  candidate output.
- A square, rectangle, dark block, halo, or visible edge is an independent
  human-review failure at 100% detail.
- Only aggregate counts, extrema, hashes, and fixed reason counts may become
  durable; all private material remains external.
