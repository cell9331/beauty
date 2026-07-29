(function attachReviewCore(globalObject) {
  "use strict";

  const FEATURES = new Set([
    "teeth_whitening",
    "sclera_redness",
    "upper_eyelid_fullness",
  ]);
  const POLARITIES = new Set(["positive", "negative"]);
  const RIGHTS = new Set([
    "approved_internal_evaluation",
    "mechanics_only",
    "rejected",
  ]);
  const DECISIONS = new Set(["accept", "reject"]);
  const REASON_CODES = new Set([
    "none",
    "missed_target",
    "protected_leakage",
    "unnatural_color",
    "texture_loss",
    "structure_change",
    "unsupported_input",
  ]);

  function isObject(value) {
    return value !== null && typeof value === "object" && !Array.isArray(value);
  }

  function isOpaqueID(value) {
    return typeof value === "string" && /^[A-Za-z0-9_-]{1,64}$/.test(value);
  }

  function isSafeRelativePath(value) {
    return typeof value === "string"
      && value.length > 0
      && !value.startsWith("/")
      && !value.startsWith("\\")
      && !value.includes("..")
      && !value.includes(":")
      && !value.includes("\\")
      && !value.includes("\0");
  }

  function normalizeAssetPaths(paths) {
    const normalized = new Set();
    for (const raw of paths || []) {
      if (typeof raw !== "string") continue;
      const clean = raw.replace(/^\.\//, "");
      normalized.add(clean);
      const parts = clean.split("/");
      if (parts.length > 1) normalized.add(parts.slice(1).join("/"));
      normalized.add(parts[parts.length - 1]);
    }
    return normalized;
  }

  function validateManifest(manifest, availableAssetPaths = []) {
    const errors = [];
    const warnings = [];
    const assets = normalizeAssetPaths(availableAssetPaths);
    const hasAssetInventory = assets.size > 0;

    if (!isObject(manifest)) {
      return {
        valid: false,
        productEvidenceReady: false,
        errors: ["manifest must be an object"],
        warnings,
        counts: {},
      };
    }

    if (manifest.schema_version !== 1) errors.push("schema_version must equal 1");
    const dataset = manifest.dataset;
    if (!isObject(dataset)) {
      errors.push("dataset is required");
    } else {
      if (!isOpaqueID(dataset.dataset_id)) errors.push("dataset.dataset_id must be an opaque ID");
      if (dataset.intended_use !== "internal_product_evaluation") {
        errors.push("dataset.intended_use must be internal_product_evaluation");
      }
      if (!isOpaqueID(dataset.documentation_record_id)) {
        errors.push("dataset.documentation_record_id must be an opaque ID");
      }
      if (typeof dataset.retention_policy !== "string" || dataset.retention_policy.length < 3) {
        errors.push("dataset.retention_policy is required");
      }
    }

    if (!Array.isArray(manifest.fixtures) || manifest.fixtures.length === 0) {
      errors.push("fixtures must contain at least one entry");
    }

    const seenIDs = new Set();
    const counts = {
      fixtures: 0,
      approved: 0,
      mechanicsOnly: 0,
      rejected: 0,
      positive: 0,
      negative: 0,
      missingAssets: 0,
    };

    for (const [index, fixture] of (manifest.fixtures || []).entries()) {
      const prefix = `fixtures[${index}]`;
      counts.fixtures += 1;
      if (!isObject(fixture)) {
        errors.push(`${prefix} must be an object`);
        continue;
      }
      if (!isOpaqueID(fixture.fixture_id)) {
        errors.push(`${prefix}.fixture_id must be an opaque ID`);
      } else if (seenIDs.has(fixture.fixture_id)) {
        errors.push(`${prefix}.fixture_id is duplicated`);
      } else {
        seenIDs.add(fixture.fixture_id);
      }
      if (!FEATURES.has(fixture.feature)) errors.push(`${prefix}.feature is unsupported`);
      if (!POLARITIES.has(fixture.polarity)) errors.push(`${prefix}.polarity is unsupported`);
      if (!RIGHTS.has(fixture.rights_status)) errors.push(`${prefix}.rights_status is unsupported`);
      if (fixture.polarity === "positive") counts.positive += 1;
      if (fixture.polarity === "negative") counts.negative += 1;

      if (fixture.rights_status === "approved_internal_evaluation") {
        counts.approved += 1;
        if (!isOpaqueID(fixture.rights_record_id)) {
          errors.push(`${prefix}.rights_record_id is required for approved fixtures`);
        }
      } else if (fixture.rights_status === "mechanics_only") {
        counts.mechanicsOnly += 1;
        warnings.push(`${prefix} is mechanics_only and cannot contribute product evidence`);
      } else if (fixture.rights_status === "rejected") {
        counts.rejected += 1;
        warnings.push(`${prefix} is rejected and cannot contribute product evidence`);
      }

      for (const key of ["original", "mask", "after"]) {
        const path = fixture.assets?.[key];
        if (!isSafeRelativePath(path)) {
          errors.push(`${prefix}.assets.${key} must be a safe relative path`);
        } else if (hasAssetInventory && !assets.has(path)) {
          errors.push(`${prefix}.assets.${key} is missing from the selected asset directory`);
          counts.missingAssets += 1;
        }
      }
    }

    const productEvidenceReady = errors.length === 0
      && counts.fixtures > 0
      && counts.approved === counts.fixtures
      && counts.positive > 0
      && counts.negative > 0
      && hasAssetInventory;

    if (!hasAssetInventory) warnings.push("asset directory not loaded; product evidence gate remains closed");
    if (counts.approved !== counts.fixtures) warnings.push("all fixtures must be rights-approved before product evidence is enabled");
    if (counts.positive === 0 || counts.negative === 0) warnings.push("both positive and negative fixtures are required");

    return {
      valid: errors.length === 0,
      productEvidenceReady,
      errors,
      warnings,
      counts,
    };
  }

  function validateReview(review, knownFixtureIDs) {
    const errors = [];
    if (!isObject(review)) return ["review must be an object"];
    if (!knownFixtureIDs.has(review.fixture_id)) errors.push("fixture_id is not in the manifest");
    if (typeof review.target_present !== "boolean") errors.push("target_present must be boolean");
    if (!Number.isInteger(review.mask_coverage) || review.mask_coverage < 1 || review.mask_coverage > 5) {
      errors.push("mask_coverage must be an integer from 1 to 5");
    }
    if (typeof review.protected_leakage !== "boolean") errors.push("protected_leakage must be boolean");
    if (!Number.isInteger(review.naturalness) || review.naturalness < 1 || review.naturalness > 5) {
      errors.push("naturalness must be an integer from 1 to 5");
    }
    if (typeof review.structure_changed !== "boolean") errors.push("structure_changed must be boolean");
    if (!DECISIONS.has(review.decision)) errors.push("decision must be accept or reject");
    if (!REASON_CODES.has(review.reason_code)) errors.push("reason_code is unsupported");
    return errors;
  }

  function buildSanitizedExport(manifest, reviews, now = new Date()) {
    const fixtureByID = new Map((manifest.fixtures || []).map((fixture) => [fixture.fixture_id, fixture]));
    const knownFixtureIDs = new Set(fixtureByID.keys());
    const errors = [];
    for (const [index, review] of reviews.entries()) {
      for (const error of validateReview(review, knownFixtureIDs)) {
        errors.push(`reviews[${index}]: ${error}`);
      }
    }
    if (errors.length > 0) throw new Error(errors.join("; "));

    const decisions = { accept: 0, reject: 0 };
    const byFeature = {};
    const sanitizedReviews = reviews.map((review) => {
      const fixture = fixtureByID.get(review.fixture_id);
      decisions[review.decision] += 1;
      byFeature[fixture.feature] ||= { count: 0, accepted: 0, leakage: 0 };
      byFeature[fixture.feature].count += 1;
      if (review.decision === "accept") byFeature[fixture.feature].accepted += 1;
      if (review.protected_leakage) byFeature[fixture.feature].leakage += 1;
      return {
        fixture_id: review.fixture_id,
        feature: fixture.feature,
        polarity: fixture.polarity,
        target_present: review.target_present,
        mask_coverage: review.mask_coverage,
        protected_leakage: review.protected_leakage,
        naturalness: review.naturalness,
        structure_changed: review.structure_changed,
        decision: review.decision,
        reason_code: review.reason_code,
      };
    });

    return {
      schema_version: 1,
      dataset_id: manifest.dataset.dataset_id,
      generated_at: now.toISOString(),
      summary: {
        review_count: sanitizedReviews.length,
        decisions,
        by_feature: byFeature,
      },
      reviews: sanitizedReviews,
    };
  }

  const api = {
    validateManifest,
    validateReview,
    buildSanitizedExport,
    normalizeAssetPaths,
  };
  globalObject.ReviewCore = api;
  if (typeof module !== "undefined" && module.exports) module.exports = api;
})(typeof globalThis !== "undefined" ? globalThis : this);
