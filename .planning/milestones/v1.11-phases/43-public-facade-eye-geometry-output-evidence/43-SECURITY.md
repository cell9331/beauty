# Phase 43 Security Review

**ASVS level:** L1 local artifact and public-facade boundary  
**Status:** `threats_open: 0`  
**Reviewed:** 2026-07-16

## Threat Register

| Threat | Control | Evidence | Status |
| --- | --- | --- | --- |
| Oversized, malformed, decompression-bomb, or raced image bytes | Bounded no-follow regular-file acquisition, strict PNG CRC/chunk/zlib/filter validation, JPEG dimension ceilings, cached RGB rows | `check_eye_geometry_renderer_outputs.py --self-test`; 385/385 strict decode | Mitigated |
| Symlink, stale, duplicate, extra, or missing output paths | Exact live case/fixture discovery, duplicate rejection, expected-name bijection, regular-file checks | strict matrix and gallery self-tests | Mitigated |
| Watermark-only or whole-image false positive | One fixed stored-row eye ROI above derived watermark boundary | 66/66 visibility and 60/60 semantic comparisons | Mitigated |
| Field-local no-op counted as visibility | Separate contour/pupil/gaze/symmetry eligibility inventory and explicit no-face no-op pool | 6/6 eligible portraits; 1/1 no-face fixture; 11/11 no-ops | Mitigated |
| Raw face geometry disclosure | Renderer imports only `BeautySDK`; diagnostics/helper/evidence contain aggregate counts and deltas only | focused redaction tests; source/import scans; evidence review | Mitigated |
| Generated artifacts entering source history | Physical-root checks, existing ignore policy, descriptor-safe gallery staging/quarantine | output/gallery tracked=0, staged=0, non-ignored-untracked=0 | Mitigated |
| Scope drift into safety/promotion or external services | Provisional output wording and explicit Phase 44 boundary; no network/cloud/commercial/dependency changes | diff/scope scans and owner docs | Mitigated |

No network, cloud, entitlement, payment, public support type, raw landmark payload, or generated binary baseline was added by Phase 43. Remaining final caps, exhaustive transitions, boundary closeout, and promotion are intentionally deferred to Phase 44.
