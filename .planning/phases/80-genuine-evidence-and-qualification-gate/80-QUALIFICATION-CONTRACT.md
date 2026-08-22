---
phase: 80
artifact: qualification-contract
version: 1
status: frozen-before-private-outcomes
authority: phase-owned-private-qualification-only
---

# Phase 80 Qualification Contract

This contract extends, and does not rewrite, the frozen Phase-75 semantic and
genuine-evidence authorities. It defines the only private-input admission,
per-fixture evaluation, blinded review, canonical binding, and sanitized
decision boundary that may qualify the existing deterministic editor.

The effect means only cosmetic visual upper-eyelid fullness reduction (`去脂`).
Smoothing, whitening, eye enlargement or opening (`eyeHeight`), brow movement,
crease invention, `upperEyelidLift`, and warp are seven independent prohibited
proxy families. Eye-bag work, dark-circle work, medical/anatomical claims, UI,
realtime/pixel-buffer behavior, transparent/HDR/video input, device or
commercial approval, packaging, shipping, launch, and release readiness are
also outside this contract.

The following record was frozen before private outcomes were visible. Every
object uses exact keys and every enum is an exact ASCII token; near matches are
invalid.

<!-- CANONICAL_QUALIFICATION_RECORDS_BEGIN -->
```json
{
  "version": 1,
  "feature_id": "upper-eyelid-fullness-reduction",
  "evaluator_version": "phase80-qualification-evaluator-v1",
  "phase75_bindings": {
    "semantic_contract_hash": "dd961264f201025c6abf332a97cd8976dcc6e4c42104bf578759b5b47ef99346",
    "evidence_contract_hash": "a5c1f92d4e9b95c5ef2f100755d7af0f61f0a025b65a867dacb08e640bfdd4e2",
    "review_rubric_hash": "c2008a5ca3112659eaf82d0e65689817d5381febf90c3cb794742433313da1ac"
  },
  "baseline_binding": {
    "baseline_id": "deterministic-editor",
    "baseline_source_digest": "8b928769e5921975880d714d01db39ceb0853f3313dce2e51da6909826a390d2",
    "baseline_evidence_digest": "f25d9dedffdbcc9d4a313e4e2ecf76d7c76878bc9f90e769572ec4986ec2eb57",
    "focused_suite_count": 3,
    "focused_test_count": 10,
    "focused_test_status": "pass"
  },
  "public_absence": {
    "beauty_parameter_fields": 61,
    "preset_ids": 5,
    "renderer_cases": 74,
    "required_until_promotion_passes": true
  },
  "bundle_schema": {
    "top_level_keys": [
      "schema_version",
      "admission_mode",
      "feature_id",
      "origin",
      "owner_provenance_version",
      "fixtures",
      "metric_matrix",
      "bindings"
    ],
    "schema_version": 1,
    "admission_mode": "genuine-private",
    "origin": "genuine-captured",
    "owner_provenance_version": "opaque-ascii-id",
    "required_categories": [
      "genuine-positive",
      "genuine-negative",
      "ambiguity",
      "pose-occlusion",
      "identity-diversity",
      "protected-structure"
    ],
    "fixture_keys": [
      "feature_id",
      "fixture_id",
      "polarity",
      "origin",
      "rights_status",
      "rights_record_present",
      "owner_provenance_version",
      "content_hash",
      "categories",
      "assets"
    ],
    "polarity_values": ["positive", "negative"],
    "rights_status": "approved_internal_evaluation",
    "rights_record_present": true,
    "opaque_identifier_pattern": "^[A-Za-z0-9_-]{1,64}$",
    "sha256_pattern": "^[0-9a-f]{64}$",
    "minimum_fixture_count": 2,
    "requires_positive": true,
    "requires_negative": true,
    "generated_fixture_weight": 0,
    "mechanics_only_fixture_weight": 0,
    "generated_origins_rejected": ["generated", "ai-generated", "mechanics-only"],
    "asset_inventory": {
      "roles": ["original", "support-envelope", "candidate-output"],
      "asset_keys": ["role", "relative_locator", "sha256", "byte_length"],
      "relative_locator_pattern": "^[A-Za-z0-9._-]+(?:/[A-Za-z0-9._-]+)*$",
      "byte_length_minimum": 1,
      "byte_length_maximum": 33554432,
      "regular_file_only": true,
      "symlinks_forbidden_at_every_component": true,
      "descriptor_identity_and_size_must_remain_equal": true,
      "content_hash_must_match_descriptor_bytes": true
    },
    "independence": {
      "fixture_ids_unique": true,
      "fixture_content_hashes_unique": true,
      "asset_roles_unique_per_fixture": true,
      "asset_content_hashes_unique": true,
      "fixture_categories_unique": true,
      "metric_rows_unique_by_fixture_and_category": true,
      "review_rows_unique_by_fixture_and_category": true,
      "multi_category_fixture_requires_one_row_per_category": true,
      "undeclared_category_credit_forbidden": true,
      "cross_fixture_or_category_credit_forbidden": true,
      "positive_fixture_requires_category": "genuine-positive",
      "negative_fixture_requires_category": "genuine-negative"
    },
    "bindings_keys": [
      "phase75_semantic_contract_hash",
      "phase75_evidence_contract_hash",
      "phase75_review_rubric_hash",
      "evaluator_version",
      "baseline_source_digest",
      "baseline_evidence_digest",
      "baseline_binding_hash",
      "public_absence_hash"
    ]
  },
  "metric_matrix": {
    "row_keys": [
      "fixture_id",
      "category",
      "efficacy",
      "containment",
      "texture_high_frequency_retention",
      "geometry_protected_structures",
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
      {"field": "efficacy", "direction": "minimum", "threshold": 0.1, "tolerance": 0.02},
      {"field": "containment", "direction": "maximum", "threshold": 0, "tolerance": 0},
      {"field": "texture_high_frequency_retention", "direction": "minimum", "threshold": 0.98, "tolerance": 0.02},
      {"field": "geometry_protected_structures", "direction": "maximum", "threshold": 0.01, "tolerance": 0.01},
      {"field": "metadata_integrity", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "no_op", "direction": "maximum", "threshold": 0, "tolerance": 0},
      {"field": "deterministic_repeatability", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "alpha_exact", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "extent_exact", "direction": "exact", "threshold": 1, "tolerance": 0},
      {"field": "rejected_source_exact", "direction": "exact-when-rejected", "threshold": 1, "tolerance": 0}
    ],
    "minimum_formula": "value+tolerance>=threshold",
    "maximum_formula": "value<=threshold+tolerance",
    "exact_formula": "value===threshold",
    "finite_numbers_required": true,
    "every_declared_fixture_category_row_required": true,
    "every_row_evaluated_independently": true,
    "aggregate_only_after_all_rows_pass_schema": true,
    "color_contract": {
      "metric_id": "color-preservation-max-absolute-srgb8-channel-delta",
      "normalization": "opaque-named-srgb-rgba8",
      "channels": "rgb-only-alpha-has-separate-exact-field",
      "source_comparison": "original-vs-candidate-output",
      "target_region": "source-bound-support-envelope-owned-pixels",
      "protected_region": "immutable-source-owned-exterior-rejected-protected-structure-and-collision-pixels",
      "applicable_regions_must_be_nonempty": true,
      "sample_unit": "integer-srgb8-code-value",
      "direction": "maximum",
      "target_field": "color_target_max_abs_channel_delta_srgb8",
      "target_threshold": 16,
      "target_threshold_owner": "BeautyUpperEyelidFullnessEditor.maximumAbsoluteChannelDelta",
      "target_tolerance": 0,
      "protected_field": "color_protected_max_abs_channel_delta_srgb8",
      "protected_threshold": 0,
      "protected_threshold_owner": "immutable-original-composition",
      "protected_tolerance": 0,
      "equality_passes": true,
      "invalid_reason": "qualification.color.invalid",
      "target_bound_reason": "qualification.color.target-bound",
      "protected_bound_reason": "qualification.color.protected-bound"
    },
    "aggregate_fields": [
      "fixture_count",
      "metric_row_count",
      "passing_metric_row_count",
      "color_row_count",
      "color_target_max_abs_channel_delta_srgb8",
      "color_protected_max_abs_channel_delta_srgb8",
      "review_row_count",
      "passing_review_row_count",
      "category_pass_rates",
      "generated_evidence_weight",
      "genuine_evaluation_executed",
      "frozen_review_complete",
      "safety_gates_pass"
    ],
    "color_aggregation": "maximum-after-complete-independent-row-evaluation"
  },
  "review_rubric": {
    "mode": "blinded-original-detail",
    "fixed_fields": [
      "target_fullness_reduced",
      "prohibited_proxy_absent",
      "protected_structures_preserved",
      "original_detail_natural",
      "review_decision",
      "reason_code"
    ],
    "reason_codes": [
      "target-not-visible",
      "proxy-present",
      "protected-structure-change",
      "detail-unnatural",
      "occlusion-or-pose-ambiguous",
      "review-failure"
    ],
    "pass_reason": null,
    "positive_pass_predicate": {
      "target_fullness_reduced": true,
      "prohibited_proxy_absent": true,
      "protected_structures_preserved": true,
      "original_detail_natural": true
    },
    "negative_and_stress_pass_predicate": {
      "target_fullness_reduced": false,
      "prohibited_proxy_absent": true,
      "protected_structures_preserved": true,
      "original_detail_natural": true
    },
    "failure_requires_one_fixed_reason": true,
    "freeform_text": false
  },
  "review_schema": {
    "top_level_keys": [
      "schema_version",
      "feature_id",
      "complete",
      "rubric_frozen_before_outcomes",
      "blindness_attested",
      "candidate_identity_hidden",
      "locator_hidden",
      "detail_scale_percent",
      "phase75_semantic_contract_hash",
      "phase75_evidence_contract_hash",
      "phase75_review_rubric_hash",
      "judgments"
    ],
    "schema_version": 1,
    "complete": true,
    "rubric_frozen_before_outcomes": true,
    "blindness_attested": true,
    "candidate_identity_hidden": true,
    "locator_hidden": true,
    "detail_scale_percent": 100,
    "judgment_keys": [
      "fixture_id",
      "category",
      "target_fullness_reduced",
      "prohibited_proxy_absent",
      "protected_structures_preserved",
      "original_detail_natural",
      "review_decision",
      "reason_code"
    ],
    "review_decisions": ["pass", "fail"],
    "every_declared_fixture_category_exactly_once": true,
    "missing_or_extra_judgment_invalid": true,
    "category_acceptance_threshold": 1,
    "category_acceptance_direction": "minimum",
    "category_acceptance_tolerance": 0,
    "equality_passes": true
  },
  "canonical_encoding": {
    "input_encoding": "utf-8-without-bom",
    "non_finite_numbers_rejected": true,
    "identifiers_and_enums_ascii_only": true,
    "duplicate_json_keys_rejected": true,
    "object_keys": "recursive-utf8-byte-order",
    "array_order": {
      "fixtures": ["fixture_id"],
      "fixture_categories": ["category"],
      "assets": ["role", "sha256"],
      "metric_matrix": ["fixture_id", "category"],
      "judgments": ["fixture_id", "category"],
      "reason_counts": ["reason"],
      "category_pass_rates": ["category"]
    },
    "equal_sort_key_result": "reject-as-duplicate",
    "serialization": "json-without-insignificant-whitespace",
    "hash": "sha256-of-exact-canonical-utf8-bytes"
  },
  "normalized_reasons": [
    "evidence.missing-bundle",
    "evidence.malformed-manifest",
    "evidence.incomplete-taxonomy",
    "evidence.rights-failure",
    "evidence.asset-invalid",
    "evidence.duplicate",
    "evidence.mechanics-only",
    "review.missing",
    "review.malformed",
    "review.incomplete",
    "review.binding",
    "review.threshold",
    "qualification.metric.invalid",
    "qualification.metric.minimum-bound",
    "qualification.metric.maximum-bound",
    "qualification.metric.exact-bound",
    "qualification.color.invalid",
    "qualification.color.target-bound",
    "qualification.color.protected-bound",
    "qualification.binding",
    "qualification.public-absence",
    "qualification.privacy",
    "qualification.input",
    "qualification.write"
  ],
  "decision_schema": {
    "top_level_allowlist": [
      "status",
      "phase",
      "contract_hash",
      "manifest_hash",
      "review_hash",
      "evaluator_version",
      "phase75_semantic_contract_hash",
      "phase75_evidence_contract_hash",
      "phase75_review_rubric_hash",
      "baseline_id",
      "baseline_source_digest",
      "baseline_evidence_digest",
      "baseline_binding_hash",
      "fixture_ids",
      "aggregate_metrics",
      "reason_counts",
      "public_absence",
      "decision"
    ],
    "status_values": ["pass", "fail"],
    "decision_values": [
      "promotion-ready-deterministic-editor",
      "qualification-not-passed"
    ],
    "write_path": ".planning/phases/80-genuine-evidence-and-qualification-gate/80-QUALIFICATION-DECISION.json",
    "write_mode": "0600-atomic-rename",
    "invalid_input_must_not_replace_decision": true,
    "durable_allowlist_only": true,
    "durable_denied": [
      "media",
      "asset-locators",
      "private-locators",
      "rights-records",
      "reviewer-identity",
      "timestamps",
      "freeform-text",
      "raw-judgments",
      "row-level-color-samples",
      "pixels",
      "masks",
      "landmarks",
      "geometry",
      "child-transcripts"
    ]
  },
  "external_fact_boundary": {
    "rights_assertions_are_external": true,
    "reviewer_attestations_are_external": true,
    "tool_validates_but_never_creates_external_facts": true,
    "automated_promotion_override_forbidden": true
  }
}
```
<!-- CANONICAL_QUALIFICATION_RECORDS_END -->

## Edge and ordering rules

Null, missing, empty, zero-fixture, and single-fixture bundles are blocking
non-promotion inputs. Exact duplicates, equal ordering keys, touching/equal
content hashes, duplicate fixture/category or asset-role rows, unknown and
near-match categories, category/polarity mismatches, and undeclared-category
rows are invalid before aggregation. Accepted arrays and normalized reasons use
the contract order first and UTF-8 byte order second.

Every declared fixture/category pair requires exactly one independently judged
metric row and one review row. A minimum passes at equality when
`value + tolerance >= threshold`; a maximum passes at equality when
`value <= threshold + tolerance`; an exact value passes only on exact equality.
No fixture or category lends credit to another. Missing, fractional,
out-of-range, non-finite, or empty-region color input fails only with the
normalized color invalid reason. Target value 16 and protected value 0 pass;
17 and 1 fail with their respective bound reasons.

The six category rates are computed only after complete judgments and each must
be at least the frozen 1.0 threshold. Equality at 1.0 passes; any value below
1.0 or any missing judgment fails. A rejected negative or stress row must be
source exact; otherwise it must independently pass every applicable frozen
containment, structure, texture, color, alpha, extent, metadata, no-op, and
determinism bound.

## Privacy and decision boundary

Private environment locators, rights records, media, reviewer facts, and
row-level image-derived values remain ephemeral. The durable output is the
strict aggregate allowlist in the canonical record—never a best-effort
redaction. Invalid or incomplete external input returns a normalized nonzero
blocking result and cannot replace the fixed decision artifact. A complete,
admitted bundle and complete review may produce a valid negative decision, but
only an independently passing genuine evaluation may emit
`promotion-ready-deterministic-editor`.

This plan supplies no rights assertion, genuine fixture, human judgment, or
reviewer attestation and therefore cannot itself create a promotion pass. The
public SDK surface remains exactly 61 fields, five presets, and 74 renderer
cases until a later private run satisfies this contract.
