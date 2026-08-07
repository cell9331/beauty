---
phase: 63
slug: guarded-per-eye-sclera-production-integration
status: passed
security_standard: OWASP ASVS Level 1
block_on: HIGH
threats_total: 8
threats_closed: 8
threats_open: 0
---

# Phase 63 Security Disposition

All eight Phase 63 HIGH threats are mitigated on the admitted still-image
branch. No finding is waived, skipped or downgraded.

| Threat | Final disposition |
| --- | --- |
| T-63-01 | Exact-open admission, one canonical request and one native Vision request use only current request-local support. |
| T-63-02 | Canonical side ownership and finite contour/actual-pupil preflight fail closed per eye without peer borrowing or mirroring. |
| T-63-03 | The pre-score hard envelope excludes the contour band, pupil/iris uncertainty, highlights, lash/margin candidates, skin and exterior; empty envelopes abstain. |
| T-63-04 | Scoring occurs only inside the hard envelope, feathering is clipped back to the same envelope and every proposal carries explicit membership. |
| T-63-05 | Targets derive only from immutable canonical source pixels, preserve alpha and bounds, and receive one Q16 weight application. |
| T-63-06 | Teeth and sclera remain independently activated while sharing one composition owner; local failure, recovery and parallel isolation pass. |
| T-63-07 | The authorized positive/negative native-Vision gate passes with fixed aggregate output and zero reviewed-mask escape; durable state remains aggregate-only. |
| T-63-08 | Renderer, Demo, realtime, model, network and promotion expansion remain absent; lifecycle handoff is limited to Phase 64. |

The first private execution correctly failed its fixed containment class. No
acceptance bound was changed: production pupil/iris protection was enlarged to
the pre-existing reviewed circular guard and test-only apertures were corrected
to realistic proportions. The final private gate then passed once through the
Phase 62 fixed-output runner. Checker self-test rejected all eight isolated
mutations; live discovery and each T-63-01 through T-63-08 mode also passed.
The focused provider/integration conjunction passed 20 tests.

Tracked evidence contains no media, local locator, digest, rights detail,
identity, reviewer prose, raw support, contour, pupil, mask, geometry, pixel
data, raw fixture metric, scanner match or raw child error.

This disposition authorizes the bounded per-eye production integration only.
It does not authorize strict public-output claims, recolored-protected-anatomy
proof, final visual acceptance, Demo activation, product promotion, realtime
work, model/network work, device or commercial readiness, packaging, shipping
or release.
