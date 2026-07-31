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
  const OPAQUE_ID = /^[A-Za-z0-9_-]{1,64}$/;
  const MAX_ROWS = 64;
  const MAX_MANIFEST_BYTES = 65_536;
  const MAX_ASSET_BYTES = 16 * 1024 * 1024;
  const MAX_DECODED_DIMENSION = 4096;

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

  function createReviewSnapshot(manifest, availableAssetKeys) {
    const validation = validateManifest(manifest);
    if (!validation.valid) return invalidResult(validation.reasons);
    const inventory = classifyAvailableAssetKeys(availableAssetKeys);
    if (!inventory.valid) return invalidResult(inventory.reasons);

    const selectedRows = manifest.fixtures
      .filter((row) => row.rights_status === "approved_internal_evaluation" && row.evidence_role === "genuine_candidate")
      .map(copyFixture)
      .sort((left, right) => left.fixture_id < right.fixture_id ? -1 : left.fixture_id > right.fixture_id ? 1 : 0);
    const excludedRows = manifest.fixtures.length - selectedRows.length;
    const positive = selectedRows.filter((row) => row.polarity === "positive").length;
    const negative = selectedRows.filter((row) => row.polarity === "negative").length;
    const missingAssets = selectedRows.reduce((count, row) => count + ASSET_FIELDS.reduce(
      (rowCount, field) => rowCount + (inventory.keys.has(row.assets[field]) ? 0 : 1),
      0,
    ), 0);
    const reasons = [];
    if (positive === 0) reasons.push("missing_genuine_positive");
    if (negative === 0) reasons.push("missing_genuine_negative");
    if (missingAssets > 0) reasons.push("incomplete_asset_triple");
    if (excludedRows > 0) reasons.push("unapproved_fixture");

    return deepFreeze({
      valid: true,
      feature: manifest.feature,
      ready: positive > 0 && negative > 0 && missingAssets === 0,
      reasons: uniqueReasons(reasons),
      selected_rows: selectedRows,
      excluded_counts: {
        rows: excludedRows,
        naturalness_weight: 0,
      },
      product_counts: {
        positive,
        negative,
        eligible: selectedRows.length,
        naturalness_weight: 0,
      },
    });
  }

  function validateReview() {
    return invalidResult(["review_not_validated"]);
  }

  function rowPasses() {
    return false;
  }

  function evaluateFeature() {
    throw new Error("review_not_implemented");
  }

  function buildDurableExport() {
    throw new Error("export_not_implemented");
  }

  function serializeDurableExport(featureInputs) {
    return `${JSON.stringify(buildDurableExport(featureInputs), null, 2)}\n`;
  }

  const api = deepFreeze({
    constants,
    validateManifest,
    normalizeRelativeAssetKey,
    createReviewSnapshot,
    validateReview,
    rowPasses,
    evaluateFeature,
    buildDurableExport,
    serializeDurableExport,
  });

  globalObject.ReviewCore = api;
  if (typeof module !== "undefined" && module.exports) module.exports = api;
})(typeof globalThis !== "undefined" ? globalThis : this);
