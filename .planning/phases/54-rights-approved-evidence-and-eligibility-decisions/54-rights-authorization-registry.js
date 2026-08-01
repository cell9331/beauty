(function attachRightsAuthorizationRegistry(globalObject) {
  "use strict";

  const ReviewCore = globalObject.ReviewCore;
  if (!ReviewCore) throw new Error("review_core_unavailable");

  globalObject.RightsAuthorizationRegistry = ReviewCore.createTrustedAuthorizationRegistry({
    schema_version: 1,
    grants: [
      {
        rights_record_id: "user_authorization_20260730_002",
        fixture_id: "portrait_001",
        feature: "teeth_whitening",
        polarity: "negative",
        permitted_use: "internal_product_evaluation",
        evidence_classification: "genuine_candidate",
      },
    ],
  });
})(typeof globalThis !== "undefined" ? globalThis : this);
