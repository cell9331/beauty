(function attachRightsAuthorizationRegistry(globalObject) {
  "use strict";

  const ReviewCore = globalObject.ReviewCore;
  if (!ReviewCore) throw new Error("review_core_unavailable");

  globalObject.RightsAuthorizationRegistry = ReviewCore.createTrustedAuthorizationRegistry({
    schema_version: 1,
    // Product-evidence grants stay empty until a complete local triple has
    // independently pinned keys, SHA-256 digests, and expected-target policy.
    grants: [],
  });
})(typeof globalThis !== "undefined" ? globalThis : this);
