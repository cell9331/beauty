# Phase 40 Mouth Geometry Safety Evidence

**Recorded:** 2026-07-14  
**Promotion state:** authorized for Plan 40-04; not yet applied in this artifact

## Runtime

- Requirement-focused suites: **106/106** across BeautySafetyCaps (3), BeautyEffectResolver (18), MouthWarpProvider (16), MissingLandmarkDegradation (35), BeautyEngineGeometryFacade (13), CombinedEffectSafety (10), and GeometryConflictResolver (11).
- Full `swift test --package-path BeautySDK`: **265/265**, zero failures.
- Exact caps: all five new fields remain exact `0.25`; exact-cap input is not counted as capped; public overflow is counted once; signed directions and positive-only rules are unchanged.
- Reused geometry applies exact `0.5` before conflict weakening; all-eight fresh/reused/stale/no-face transitions retain no prior state.
- Exact complete retained set: total `5.30`, count `16`, scale `1/5.30`. Missing-inner retained set: total `4.80`, count `14`, scale `1/4.80`; dependent peak/plump work is absent from final strengths and emissions.

## Public-Facade Output Regression

- Phase 39 strict helper self-test passed.
- **308/308** fully decoded same-dimension outputs from 44 cases × 7 fixtures.
- **96/96** portrait direct comparisons and **8/8** no-face no-op comparisons passed.
- Visibility 48/48, signed direction 18/18, peak independence 12/12, and plump independence 18/18 remain unchanged.
- Output/gallery roots are ignored, untracked, and unstaged.

## Boundaries and Review

- Boundary checker Python compilation passed.
- Adversarial checker self-test passed **63/63**.
- Live pre-promotion checker passed **13/13**.
- Standard review became clean after two scanner-hardening fixes; all three warnings are resolved and no Swift test defect was found.
- Privacy-manifest disposition remains the existing explicit local-first deferral; no dependency, remote/cloud, commercial, public/raw geometry, diagnostic payload, generated artifact, archive/worktree, or lifecycle-success boundary changed.

## Authorization Boundary

This evidence authorizes only the exact five-row Plan 40-04 documentation promotion. It does not authorize `白牙`, branch-level `嘴唇` completion, Demo/device/commercial naturalness, optimized performance, packaging, shipping, launch readiness, milestone audit, archive, tag, or cleanup claims.

