(function attachReviewCore(globalObject) {
  "use strict";

  const FEATURES = [
    "teeth_whitening",
    "sclera_redness",
    "upper_eyelid_fullness",
  ];
  const POLARITIES = ["positive", "negative"];
  const RIGHTS_STATUSES = [
    "approved_internal_evaluation",
    "mechanics_only",
    "rejected",
  ];
  const EVIDENCE_ROLES = [
    "genuine_candidate",
    "mechanics_only",
    "synthetic",
    "ai_generated",
    "disabled",
    "parked",
    "historical",
  ];
  const REVIEW_REASONS = [
    "none",
    "target_mismatch",
    "insufficient_mask_coverage",
    "protected_leakage",
    "unnatural_result",
    "texture_loss",
    "structure_change",
    "unsupported_input",
  ];
  const GATE_REASONS = [
    "missing_genuine_positive",
    "missing_genuine_negative",
    "incomplete_asset_triple",
    "unapproved_fixture",
    "review_incomplete",
    "review_rejected",
    "non_warp_design_unqualified",
  ];
  const DESIGN_METHOD_CLASSES = [
    "independent_nonwarp",
    "invalidated_interior_warp",
    "eye_geometry_proxy",
    "brow_geometry_proxy",
    "aperture_proxy",
    "global_smoothing_proxy",
    "dark_circle_proxy",
    "eye_bag_proxy",
  ];
  const MANIFEST_KEYS = ["schema_version", "feature", "fixtures"];
  const FIXTURE_KEYS = [
    "fixture_id",
    "feature",
    "polarity",
    "expected_target_present",
    "polarity_predeclared",
    "rights_status",
    "rights_record_id",
    "evidence_role",
    "assets",
  ];
  const ASSET_FIELDS = ["original", "mask", "after"];
  const REVIEW_KEYS = [
    "fixture_id",
    "target_present",
    "mask_coverage",
    "protected_leakage",
    "naturalness",
    "structure_changed",
    "decision",
    "reason_code",
  ];
  const DESIGN_KEYS = ["feature", "reviewed", "decision", "method_class"];
  const AUTHORIZATION_REGISTRY_KEYS = ["schema_version", "grants"];
  const AUTHORIZATION_GRANT_KEYS = [
    "rights_record_id",
    "fixture_id",
    "feature",
    "polarity",
    "permitted_use",
    "evidence_classification",
  ];
  const PERMITTED_USE = "internal_product_evaluation";
  const GENUINE_CLASSIFICATION = "genuine_candidate";
  const OPAQUE_ID = /^[A-Za-z0-9_-]{1,64}$/;
  const MAX_ROWS = 64;
  const MAX_MANIFEST_BYTES = 65_536;
  const MAX_ASSET_BYTES = 16 * 1024 * 1024;
  const MAX_DECODED_DIMENSION = 4096;
  const MAX_DECODED_PIXELS = 16_000_000;
  const canonicalSnapshots = new WeakSet();
  const reviewSnapshots = new WeakMap();
  const trustedAuthorizationRegistries = new WeakSet();
  const BASE_CLOSED_REASONS = {
    teeth_whitening: ["missing_genuine_positive"],
    sclera_redness: ["missing_genuine_positive", "incomplete_asset_triple"],
    upper_eyelid_fullness: ["missing_genuine_positive"],
  };

  function deepFreeze(value) {
    if (value === null || typeof value !== "object" || Object.isFrozen(value)) return value;
    for (const child of Object.values(value)) deepFreeze(child);
    return Object.freeze(value);
  }

  const constants = deepFreeze({
    features: [...FEATURES],
    polarities: [...POLARITIES],
    rights_statuses: [...RIGHTS_STATUSES],
    evidence_roles: [...EVIDENCE_ROLES],
    review_reasons: [...REVIEW_REASONS],
    gate_reasons: [...GATE_REASONS],
    design_method_classes: [...DESIGN_METHOD_CLASSES],
    min_score: 1,
    max_score: 5,
    min_rows: 1,
    max_rows: MAX_ROWS,
    max_manifest_bytes: MAX_MANIFEST_BYTES,
    max_asset_bytes: MAX_ASSET_BYTES,
    max_decoded_dimension: MAX_DECODED_DIMENSION,
    max_decoded_pixels: MAX_DECODED_PIXELS,
    permitted_use: PERMITTED_USE,
    genuine_classification: GENUINE_CLASSIFICATION,
  });

  function isPlainObject(value) {
    if (value === null || typeof value !== "object" || Array.isArray(value)) return false;
    const prototype = Object.getPrototypeOf(value);
    return prototype === Object.prototype || prototype === null;
  }

  function hasExactKeys(value, expected) {
    if (!isPlainObject(value)) return false;
    const keys = Object.keys(value);
    return keys.length === expected.length && expected.every((key) => keys.includes(key));
  }

  function uniqueReasons(reasons) {
    return GATE_REASONS.filter((reason) => reasons.includes(reason));
  }

  function invalidResult(reasons) {
    return deepFreeze({ valid: false, reasons: [...new Set(reasons)] });
  }

  function serializedByteLength(value) {
    try {
      const serialized = JSON.stringify(value);
      if (typeof serialized !== "string") return null;
      if (typeof TextEncoder !== "undefined") return new TextEncoder().encode(serialized).length;
      if (typeof Buffer !== "undefined") return Buffer.byteLength(serialized, "utf8");
      return unescape(encodeURIComponent(serialized)).length;
    } catch (_) {
      return null;
    }
  }

  function normalizeRelativeAssetKey(value) {
    if (typeof value !== "string" || value.length === 0 || value.includes("\0")) {
      return invalidResult(["asset_key_invalid"]);
    }
    if (value.startsWith("/") || value.startsWith("\\") || value.includes("\\") || value.includes(":")) {
      return invalidResult(["asset_key_invalid"]);
    }
    const segments = value.split("/");
    if (segments.length < 2 || segments.some((segment) => segment.length === 0 || segment === "." || segment === "..")) {
      return invalidResult(["asset_key_invalid"]);
    }
    const canonical = value.normalize("NFC");
    if (canonical !== value) return invalidResult(["asset_key_invalid"]);
    return deepFreeze({ valid: true, key: canonical, reasons: [] });
  }

  function validateManifest(value) {
    const reasons = [];
    const size = serializedByteLength(value);
    if (size === null || size > MAX_MANIFEST_BYTES) reasons.push("manifest_size_invalid");
    if (!hasExactKeys(value, MANIFEST_KEYS)) {
      reasons.push("manifest_shape_invalid");
      return invalidResult(reasons);
    }
    if (value.schema_version !== 1) reasons.push("schema_version_invalid");
    if (!FEATURES.includes(value.feature)) reasons.push("feature_invalid");
    if (!Array.isArray(value.fixtures) || value.fixtures.length < 1 || value.fixtures.length > MAX_ROWS) {
      reasons.push("fixture_count_invalid");
      return reasons.length > 0 ? invalidResult(reasons) : deepFreeze({ valid: true, reasons: [] });
    }

    const fixtureIDs = new Set();
    const assetKeys = new Set();
    for (const row of value.fixtures) {
      if (!hasExactKeys(row, FIXTURE_KEYS)) {
        reasons.push("fixture_shape_invalid");
        continue;
      }
      if (typeof row.fixture_id !== "string" || !OPAQUE_ID.test(row.fixture_id)) {
        reasons.push("fixture_id_invalid");
      } else if (fixtureIDs.has(row.fixture_id)) {
        reasons.push("fixture_id_duplicate");
      } else {
        fixtureIDs.add(row.fixture_id);
      }
      if (!FEATURES.includes(row.feature) || row.feature !== value.feature) reasons.push("feature_invalid");
      if (!POLARITIES.includes(row.polarity)) reasons.push("polarity_invalid");
      if (typeof row.expected_target_present !== "boolean") reasons.push("target_expectation_invalid");
      if (row.polarity_predeclared !== true) reasons.push("polarity_not_predeclared");
      if (!RIGHTS_STATUSES.includes(row.rights_status)) reasons.push("rights_status_invalid");
      if (typeof row.rights_record_id !== "string" || !OPAQUE_ID.test(row.rights_record_id)) {
        reasons.push("rights_record_invalid");
      }
      if (!EVIDENCE_ROLES.includes(row.evidence_role)) reasons.push("evidence_role_invalid");
      if (!hasExactKeys(row.assets, ASSET_FIELDS)) {
        reasons.push("asset_triple_invalid");
        continue;
      }
      for (const field of ASSET_FIELDS) {
        const normalized = normalizeRelativeAssetKey(row.assets[field]);
        if (!normalized.valid) {
          reasons.push("asset_key_invalid");
        } else if (assetKeys.has(normalized.key)) {
          reasons.push("asset_key_duplicate");
        } else {
          assetKeys.add(normalized.key);
        }
      }
    }
    return reasons.length > 0
      ? invalidResult(reasons)
      : deepFreeze({ valid: true, reasons: [] });
  }

  function classifyAvailableAssetKeys(values) {
    if (!Array.isArray(values)) return invalidResult(["asset_inventory_invalid"]);
    const keys = new Set();
    const basenames = new Map();
    for (const raw of values) {
      const normalized = normalizeRelativeAssetKey(raw);
      if (!normalized.valid || keys.has(normalized.key)) return invalidResult(["asset_inventory_invalid"]);
      keys.add(normalized.key);
      const basename = normalized.key.split("/").at(-1);
      const previous = basenames.get(basename);
      if (previous !== undefined && previous !== normalized.key) {
        return invalidResult(["asset_inventory_ambiguous"]);
      }
      basenames.set(basename, normalized.key);
    }
    return { valid: true, keys };
  }

  function copyFixture(row) {
    return {
      fixture_id: row.fixture_id,
      feature: row.feature,
      polarity: row.polarity,
      expected_target_present: row.expected_target_present,
      polarity_predeclared: true,
      rights_status: row.rights_status,
      rights_record_id: row.rights_record_id,
      evidence_role: row.evidence_role,
      assets: {
        original: row.assets.original,
        mask: row.assets.mask,
        after: row.assets.after,
      },
    };
  }

  function createTrustedAuthorizationRegistry(value) {
    if (!hasExactKeys(value, AUTHORIZATION_REGISTRY_KEYS)
      || value.schema_version !== 1
      || !Array.isArray(value.grants)
      || value.grants.length > MAX_ROWS) {
      throw new Error("authorization_registry_invalid");
    }
    const rightsRecordIDs = new Set();
    const fixtureBindings = new Set();
    const grants = value.grants.map((grant) => {
      if (!hasExactKeys(grant, AUTHORIZATION_GRANT_KEYS)
        || !OPAQUE_ID.test(grant.rights_record_id)
        || !OPAQUE_ID.test(grant.fixture_id)
        || !FEATURES.includes(grant.feature)
        || !POLARITIES.includes(grant.polarity)
        || grant.permitted_use !== PERMITTED_USE
        || grant.evidence_classification !== GENUINE_CLASSIFICATION) {
        throw new Error("authorization_registry_invalid");
      }
      const fixtureBinding = `${grant.fixture_id}\0${grant.feature}\0${grant.polarity}`;
      if (rightsRecordIDs.has(grant.rights_record_id) || fixtureBindings.has(fixtureBinding)) {
        throw new Error("authorization_registry_invalid");
      }
      rightsRecordIDs.add(grant.rights_record_id);
      fixtureBindings.add(fixtureBinding);
      return {
        rights_record_id: grant.rights_record_id,
        fixture_id: grant.fixture_id,
        feature: grant.feature,
        polarity: grant.polarity,
        permitted_use: grant.permitted_use,
        evidence_classification: grant.evidence_classification,
      };
    });
    const registry = deepFreeze({ schema_version: 1, grants });
    trustedAuthorizationRegistries.add(registry);
    return registry;
  }

  function authorizationMatches(row, registry) {
    return registry.grants.some((grant) => grant.rights_record_id === row.rights_record_id
      && grant.fixture_id === row.fixture_id
      && grant.feature === row.feature
      && grant.polarity === row.polarity
      && grant.permitted_use === PERMITTED_USE
      && grant.evidence_classification === row.evidence_role);
  }

  function createReviewSnapshot(manifest, availableAssetKeys, authorizationRegistry) {
    const validation = validateManifest(manifest);
    if (!validation.valid) return invalidResult(validation.reasons);
    const inventory = classifyAvailableAssetKeys(availableAssetKeys);
    if (!inventory.valid) return invalidResult(inventory.reasons);
    if (!trustedAuthorizationRegistries.has(authorizationRegistry)) {
      return invalidResult(["authorization_registry_invalid"]);
    }

    const reviewRows = manifest.fixtures
      .filter((row) => row.rights_status !== "rejected"
        && (row.evidence_role !== GENUINE_CLASSIFICATION
          || authorizationMatches(row, authorizationRegistry)))
      .map(copyFixture)
      .sort((left, right) => left.fixture_id < right.fixture_id ? -1 : left.fixture_id > right.fixture_id ? 1 : 0);
    const selectedRows = reviewRows.filter(
      (row) => row.rights_status === "approved_internal_evaluation"
        && row.evidence_role === GENUINE_CLASSIFICATION,
    );
    const excludedRows = manifest.fixtures.length - selectedRows.length;
    const unapprovedGenuineRows = manifest.fixtures.filter(
      (row) => row.evidence_role === GENUINE_CLASSIFICATION
        && (row.rights_status !== "approved_internal_evaluation"
          || !authorizationMatches(row, authorizationRegistry)),
    ).length;
    const declaredPositive = selectedRows.filter((row) => row.polarity === "positive").length;
    const declaredNegative = selectedRows.filter((row) => row.polarity === "negative").length;
    const completeSelectedRows = selectedRows.filter(
      (row) => ASSET_FIELDS.every((field) => inventory.keys.has(row.assets[field])),
    );
    const positive = completeSelectedRows.filter((row) => row.polarity === "positive").length;
    const negative = completeSelectedRows.filter((row) => row.polarity === "negative").length;
    const missingAssets = selectedRows.reduce((count, row) => count + ASSET_FIELDS.reduce(
      (rowCount, field) => rowCount + (inventory.keys.has(row.assets[field]) ? 0 : 1),
      0,
    ), 0);
    const reasons = [];
    if (declaredPositive === 0) reasons.push("missing_genuine_positive");
    if (declaredNegative === 0) reasons.push("missing_genuine_negative");
    if (missingAssets > 0) reasons.push("incomplete_asset_triple");
    if (unapprovedGenuineRows > 0) reasons.push("unapproved_fixture");

    const snapshot = deepFreeze({
      valid: true,
      feature: manifest.feature,
      ready: declaredPositive > 0 && declaredNegative > 0 && missingAssets === 0 && unapprovedGenuineRows === 0,
      reasons: uniqueReasons(reasons),
      review_rows: reviewRows,
      selected_rows: selectedRows,
      excluded_counts: {
        rows: excludedRows,
        naturalness_weight: 0,
      },
      product_counts: {
        positive,
        negative,
        eligible: completeSelectedRows.length,
        naturalness_weight: 0,
      },
    });
    canonicalSnapshots.add(snapshot);
    return snapshot;
  }

  function createClosedSnapshot(feature) {
    if (!FEATURES.includes(feature)) throw new Error("feature_invalid");
    const snapshot = deepFreeze({
      valid: true,
      feature,
      ready: false,
      reasons: [...BASE_CLOSED_REASONS[feature]],
      review_rows: [],
      selected_rows: [],
      excluded_counts: { rows: 0, naturalness_weight: 0 },
      product_counts: { positive: 0, negative: 0, eligible: 0, naturalness_weight: 0 },
    });
    canonicalSnapshots.add(snapshot);
    return snapshot;
  }

  function findSnapshotRow(snapshot, fixtureID) {
    if (!canonicalSnapshots.has(snapshot) || !isPlainObject(snapshot) || snapshot.valid !== true
      || !FEATURES.includes(snapshot.feature)
      || !Array.isArray(snapshot.selected_rows)) return null;
    const reviewRows = Array.isArray(snapshot.review_rows) ? snapshot.review_rows : snapshot.selected_rows;
    return reviewRows.find(
      (row) => row.fixture_id === fixtureID && row.feature === snapshot.feature,
    ) || null;
  }

  function reviewShapeValid(review) {
    return hasExactKeys(review, REVIEW_KEYS)
      && typeof review.fixture_id === "string"
      && OPAQUE_ID.test(review.fixture_id)
      && typeof review.target_present === "boolean"
      && Number.isInteger(review.mask_coverage)
      && review.mask_coverage >= 1
      && review.mask_coverage <= 5
      && typeof review.protected_leakage === "boolean"
      && Number.isInteger(review.naturalness)
      && review.naturalness >= 1
      && review.naturalness <= 5
      && typeof review.structure_changed === "boolean"
      && ["accept", "reject"].includes(review.decision)
      && REVIEW_REASONS.includes(review.reason_code);
  }

  function structuredReasonMatches(row, review) {
    if (review.reason_code === "none") return review.decision === "accept";
    if (review.decision !== "reject") return false;
    switch (review.reason_code) {
      case "target_mismatch":
        return review.target_present !== row.expected_target_present;
      case "insufficient_mask_coverage":
        return row.polarity === "positive" && review.mask_coverage < 4;
      case "protected_leakage":
        return review.protected_leakage === true;
      case "unnatural_result":
        return review.naturalness < 4;
      case "structure_change":
        return review.structure_changed === true;
      case "texture_loss":
      case "unsupported_input":
        return true;
      default:
        return false;
    }
  }

  function rowPasses(row, review) {
    if (!isPlainObject(row) || !reviewShapeValid(review) || review.fixture_id !== row.fixture_id) return false;
    const common = review.target_present === row.expected_target_present
      && review.protected_leakage === false
      && review.naturalness >= 4
      && review.structure_changed === false
      && review.decision === "accept"
      && review.reason_code === "none";
    if (row.polarity === "positive") {
      return row.expected_target_present === true
        && review.target_present === true
        && review.mask_coverage >= 4
        && common;
    }
    return row.polarity === "negative" && common;
  }

  function validateReview(snapshot, review) {
    const reasons = [];
    if (!reviewShapeValid(review)) return invalidResult(["review_shape_invalid"]);
    const row = findSnapshotRow(snapshot, review.fixture_id);
    if (row === null) reasons.push("review_fixture_invalid");
    if (row !== null && !structuredReasonMatches(row, review)) reasons.push("review_reason_invalid");
    if (row !== null && review.decision === "accept" && !rowPasses(row, review)) {
      reasons.push("review_acceptance_invalid");
    }
    return reasons.length > 0
      ? invalidResult(reasons)
      : deepFreeze({ valid: true, reasons: [] });
  }

  function copiedReview(review) {
    return {
      fixture_id: review.fixture_id,
      target_present: review.target_present,
      mask_coverage: review.mask_coverage,
      protected_leakage: review.protected_leakage,
      naturalness: review.naturalness,
      structure_changed: review.structure_changed,
      decision: review.decision,
      reason_code: review.reason_code,
    };
  }

  function claimReviewProvenance(snapshot, reviews) {
    if (!Array.isArray(reviews)) throw new Error("review_set_invalid");
    for (const review of reviews) {
      if (review === null || typeof review !== "object"
        || reviewSnapshots.get(review) !== snapshot) {
        throw new Error("review_feature_invalid");
      }
    }
  }

  function createReview(snapshot, candidate) {
    if (!canonicalSnapshots.has(snapshot)) throw new Error("feature_snapshot_invalid");
    const validation = validateReview(snapshot, candidate);
    if (!validation.valid) throw new Error("review_invalid");
    const issued = deepFreeze(copiedReview(candidate));
    reviewSnapshots.set(issued, snapshot);
    return issued;
  }

  function requireExactReviews(snapshot, reviews) {
    if (!canonicalSnapshots.has(snapshot)) throw new Error("feature_snapshot_invalid");
    claimReviewProvenance(snapshot, reviews);
    const expected = new Map(snapshot.selected_rows.map((row) => [row.fixture_id, row]));
    const seen = new Set();
    const copied = [];
    for (const review of reviews) {
      if (!isPlainObject(review) || typeof review.fixture_id !== "string"
        || !expected.has(review.fixture_id) || seen.has(review.fixture_id)) {
        throw new Error("review_set_invalid");
      }
      const validation = validateReview(snapshot, review);
      if (!validation.valid) throw new Error("review_invalid");
      seen.add(review.fixture_id);
      copied.push(copiedReview(review));
    }
    if (seen.size !== expected.size) throw new Error("review_set_incomplete");
    copied.sort((left, right) => left.fixture_id < right.fixture_id ? -1 : left.fixture_id > right.fixture_id ? 1 : 0);
    return copied;
  }

  function designQualifies(value) {
    return hasExactKeys(value, DESIGN_KEYS)
      && value.feature === "upper_eyelid_fullness"
      && value.reviewed === true
      && value.decision === "qualified"
      && value.method_class === "independent_nonwarp";
  }

  function evaluateFeature(snapshot, reviews, designQualification) {
    if (!canonicalSnapshots.has(snapshot) || !isPlainObject(snapshot)
      || snapshot.valid !== true || !FEATURES.includes(snapshot.feature)
      || !Array.isArray(snapshot.selected_rows) || !isPlainObject(snapshot.product_counts)) {
      throw new Error("feature_snapshot_invalid");
    }
    if (snapshot.selected_rows.some((row) => row.feature !== snapshot.feature)) {
      throw new Error("feature_snapshot_invalid");
    }

    let acceptedCount = 0;
    let rejectedCount = 0;
    let reviewedCount = 0;
    const reasons = snapshot.ready === true ? [] : uniqueReasons(Array.isArray(snapshot.reasons) ? snapshot.reasons : []);

    if (snapshot.ready === true) {
      const exactReviews = requireExactReviews(snapshot, reviews);
      reviewedCount = exactReviews.length;
      for (const review of exactReviews) {
        const row = findSnapshotRow(snapshot, review.fixture_id);
        if (rowPasses(row, review)) acceptedCount += 1;
        else rejectedCount += 1;
      }
      if (rejectedCount > 0) reasons.push("review_rejected");
    } else if (!Array.isArray(reviews) || reviews.length !== 0) {
      throw new Error("review_set_invalid");
    }

    if (snapshot.feature === "upper_eyelid_fullness" && !designQualifies(designQualification)) {
      reasons.push("non_warp_design_unqualified");
    }
    const orderedReasons = uniqueReasons(reasons);
    return deepFreeze({
      feature: snapshot.feature,
      status: orderedReasons.length === 0 ? "open" : "closed",
      reasons: orderedReasons,
      eligible_count: snapshot.product_counts.eligible,
      reviewed_count: reviewedCount,
      accepted_count: acceptedCount,
      rejected_count: rejectedCount,
      naturalness_weight: reviewedCount,
    });
  }

  function projectedDesign(value) {
    if (!isPlainObject(value)) return value;
    return {
      feature: value.feature,
      reviewed: value.reviewed,
      decision: value.decision,
      method_class: value.method_class,
    };
  }

  function buildDurableExport(featureInputs) {
    if (!Array.isArray(featureInputs) || featureInputs.length !== FEATURES.length) {
      throw new Error("feature_inputs_invalid");
    }
    const byFeature = new Map();
    for (const input of featureInputs) {
      if (!isPlainObject(input) || !isPlainObject(input.snapshot) || byFeature.has(input.snapshot.feature)) {
        throw new Error("feature_inputs_invalid");
      }
      byFeature.set(input.snapshot.feature, input);
    }
    if (FEATURES.some((feature) => !byFeature.has(feature))) throw new Error("feature_inputs_invalid");

    const featureDecisions = [];
    const durableReviews = [];
    const aggregates = [];
    for (const feature of FEATURES) {
      const input = byFeature.get(feature);
      const snapshot = input.snapshot;
      if (snapshot.feature !== feature) throw new Error("feature_inputs_invalid");
      if (!canonicalSnapshots.has(snapshot)) {
        throw new Error("feature_snapshot_invalid");
      }
      const reviews = input.reviews;
      if (snapshot.ready === true) claimReviewProvenance(snapshot, reviews);
      const design = projectedDesign(input.design_qualification);
      const decision = evaluateFeature(snapshot, reviews, design);
      featureDecisions.push({
        feature: decision.feature,
        status: decision.status,
        reasons: [...decision.reasons],
        eligible_count: decision.eligible_count,
        reviewed_count: decision.reviewed_count,
        accepted_count: decision.accepted_count,
        rejected_count: decision.rejected_count,
        naturalness_weight: decision.naturalness_weight,
      });

      if (snapshot.ready === true) {
        const exactReviews = requireExactReviews(snapshot, reviews);
        for (const review of exactReviews) {
          const row = findSnapshotRow(snapshot, review.fixture_id);
          durableReviews.push({
            fixture_id: row.fixture_id,
            feature: row.feature,
            polarity: row.polarity,
            target_present: review.target_present,
            mask_coverage: review.mask_coverage,
            protected_leakage: review.protected_leakage,
            naturalness: review.naturalness,
            structure_changed: review.structure_changed,
            decision: review.decision,
            reason_code: review.reason_code,
          });
        }
      }
      aggregates.push({
        feature: decision.feature,
        eligible_count: decision.eligible_count,
        reviewed_count: decision.reviewed_count,
        accepted_count: decision.accepted_count,
        rejected_count: decision.rejected_count,
        naturalness_weight: decision.naturalness_weight,
      });
    }
    durableReviews.sort((left, right) => {
      const featureDifference = FEATURES.indexOf(left.feature) - FEATURES.indexOf(right.feature);
      if (featureDifference !== 0) return featureDifference;
      return left.fixture_id < right.fixture_id ? -1 : left.fixture_id > right.fixture_id ? 1 : 0;
    });
    return deepFreeze({
      schema_version: 1,
      feature_decisions: featureDecisions,
      reviews: durableReviews,
      aggregates,
    });
  }

  function serializeDurableExport(featureInputs) {
    return `${JSON.stringify(buildDurableExport(featureInputs), null, 2)}\n`;
  }

  const api = deepFreeze({
    constants,
    validateManifest,
    normalizeRelativeAssetKey,
    createTrustedAuthorizationRegistry,
    createClosedSnapshot,
    createReviewSnapshot,
    createReview,
    validateReview,
    rowPasses,
    evaluateFeature,
    buildDurableExport,
    serializeDurableExport,
  });

  globalObject.ReviewCore = api;
  if (typeof module !== "undefined" && module.exports) module.exports = api;
})(typeof globalThis !== "undefined" ? globalThis : this);
