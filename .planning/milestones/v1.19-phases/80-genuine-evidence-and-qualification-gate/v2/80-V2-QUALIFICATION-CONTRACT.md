---
phase: 80
artifact: qualification-contract
version: 2
status: frozen-before-private-outcomes
authority: phase-owned-private-qualification-only
supersedes_for_new_candidates: candidate-v1-only
---

# Phase 80 Candidate-v2 Qualification Contract

This record qualifies only the candidate-v2 brow-to-lid feathered editor. It
does not modify, erase, reinterpret, or borrow a passing result from the v1
contract. Candidate v1 remains terminally failed.

The effect means only cosmetic visual upper-eyelid fullness reduction
(`去脂`). Smoothing, whitening, eye enlargement/opening, brow movement, crease
invention, `upperEyelidLift`, and warp remain prohibited proxies. This contract
does not claim a public SDK route, device quality, medical/anatomical effect,
commercial visual quality, packaging, shipping, launch, or release readiness.

This record was frozen after generated mechanics tests passed and before any
candidate-v2 output from private images was generated or viewed.

<!-- CANONICAL_V2_QUALIFICATION_RECORDS_BEGIN -->
```json
{
  "version": 2,
  "feature_id": "upper-eyelid-fullness-reduction",
  "evaluator_version": "phase80-qualification-evaluator-v2",
  "phase75_bindings": {
    "semantic_contract_hash": "dd961264f201025c6abf332a97cd8976dcc6e4c42104bf578759b5b47ef99346",
    "evidence_contract_hash": "a5c1f92d4e9b95c5ef2f100755d7af0f61f0a025b65a867dacb08e640bfdd4e2"
  },
  "review_rubric_hash": "0c9b80f45647c26b3e3707a4987ba9acc9c763343852dc6bb434199bf405f534",
  "baseline_binding": {
    "baseline_id": "brow-to-lid-feathered-editor-v2",
    "qualification_strength": 1,
    "implementation_commit": "4cf736c860c1b3baddc84310cbcdb58d0a535d0d",
    "baseline_source_digest": "10d279d28b30a3ef5cbd6d1e34597b74e5e12aaf83fb4b65889a1a920187efb3",
    "baseline_evidence_digest": "c00ec162b7e9ca2f6d0cdf4b4ed07a5ae9986e4b336655c549aca251e6fd84cf",
    "v1_helper_digest": "e1d94b4ac6531678483ad57a61a2a00b3b40d06aac6a0c51d6f565e63e1452a6",
    "focused_suite_count": 5,
    "focused_test_count": 25,
    "focused_test_status": "pass",
    "full_swiftpm_test_count": 803,
    "full_swiftpm_failure_count": 0
  },
  "public_absence": {
    "beauty_parameter_fields": 61,
    "preset_ids": 5,
    "renderer_cases": 74,
    "required_until_promotion_passes": true
  },
  "bundle_schema": {
    "schema_version": 2,
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
    "v1_evaluator_or_baseline_binding_rejected": true
  },
  "metric_matrix": {
    "row_keys": [
      "fixture_id",
      "category",
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
    "comparisons": [
      {"field": "efficacy", "applies_to": "genuine-positive", "direction": "minimum", "threshold": 0.1, "tolerance": 0.02},
      {"field": "containment", "applies_to": "all", "direction": "maximum", "threshold": 0, "tolerance": 0},
      {"field": "texture_high_frequency_retention", "applies_to": "all", "direction": "minimum", "threshold": 0.98, "tolerance": 0.02},
      {"field": "geometry_protected_structures", "applies_to": "all", "direction": "maximum", "threshold": 0.01, "tolerance": 0.01},
      {"field": "boundary_correction_jump_srgb8", "applies_to": "all", "direction": "maximum", "threshold": 5, "tolerance": 0},
      {"field": "feather_to_zero", "applies_to": "all", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "metadata_integrity", "applies_to": "all", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "no_op", "applies_to": "all", "direction": "maximum", "threshold": 0, "tolerance": 0},
      {"field": "deterministic_repeatability", "applies_to": "all", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "alpha_exact", "applies_to": "all", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "extent_exact", "applies_to": "all", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "rejected_source_exact", "applies_to": "all", "direction": "exact", "threshold": 1, "tolerance": 0}
    ],
    "color_contract": {
      "normalization": "opaque-named-srgb-rgba8",
      "target_threshold": 16,
      "protected_threshold": 0,
      "alpha_separate_exact": true,
      "applicable_regions_nonempty": true
    },
    "aggregate_only_after_all_rows_are_independently_evaluated": true
  },
  "review_rubric": {
    "mode": "blinded-original-detail-boundary-v2",
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
    "schema_version": 2,
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
    "promotion_decision": "promotion-ready-feathered-editor-v2",
    "non_promotion_decision": "qualification-not-passed",
    "missing_or_malformed_input": "fail-closed",
    "private_rows_assets_masks_landmarks_and_locators_forbidden_in_output": true,
    "canonical_decision_written_only_after_complete_valid_external_inputs": true
  }
}
```
<!-- CANONICAL_V2_QUALIFICATION_RECORDS_END -->

## Frozen interpretation

- The red support visualization is review-only and must never be composited into
  the candidate output.
- `boundary_correction_jump_srgb8` measures the maximum adjacent change in the
  applied RGB correction around the accepted support boundary; equality at 5
  passes and 6 fails.
- `feather_to_zero` is exact: the support must expose a non-empty soft edge and
  the correction must reach immutable source pixels without a hard rectangular
  cutoff.
- Human review must inspect 100% detail and separately attest that no square,
  rectangle, dark patch, halo, or visible mask edge exists.
- Any metric or review failure returns non-promotion. Private evidence never
  becomes repository evidence; only aggregate counts, extrema, hashes, and fixed
  reason counts may be durable.
