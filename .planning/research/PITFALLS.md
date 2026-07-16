# Pitfalls Research

**Domain:** Advanced eye geometry in a privacy-sensitive local iOS SDK
**Researched:** 2026-07-16
**Confidence:** HIGH

## Critical Pitfalls

### 1. Claiming correction from symmetric proxy geometry

**Failure:** Gaze or symmetry tests pass although no observed offset/asymmetry exists.
**Prevention:** Require private observed contour/pupil support and synthetic asymmetric fixtures at provider/facade boundaries; proxies may remain only for shipped zero-default compatibility.
**Phase:** 41-42.

### 2. Coordinate or side inversion

**Failure:** Left/right, upper/lower, inner/outer, or rotation direction reverses because Vision and renderer origins/winding differ.
**Prevention:** One canonical conversion with exact fixture tests for orientation, mirroring, side identity, corners, and signed tilt.
**Phase:** 41.

### 3. Blink-inaccurate pupil input survives

**Failure:** Pupil/gaze controls warp an eyelid or jump toward an implausible pupil point. Apple documents that pupil location can be inaccurate during blinking.
**Prevention:** Validate pupil containment, distance from contour center, finite bounds, and paired plausibility; fail only pupil-dependent fields.
**Phase:** 41-42.

### 4. New controls alias shipped vectors

**Failure:** Height is radial size, length is distance, upper-lid lift is tail lift, or corners are generic length.
**Prevention:** Lock source subsets and full displacement vectors; compare each new control to nearest shipped/new neighbors and both signed tilt directions.
**Phase:** 42-43.

### 5. Automatic correction becomes identity replacement

**Failure:** Symmetry mirrors one eye or gaze correction recenters every pupil aggressively, changing identity and producing unnatural output.
**Prevention:** Correct only measured deviation by a capped fraction, preserve a dead zone, and reject implausible inputs.
**Phase:** 42 and final calibration in 44.

### 6. Effective strengths disagree with emitted work

**Failure:** Unsupported or final-scale-empty fields remain in totals, warnings, metrics, or active domains because another eye field emitted points.
**Prevention:** Named fourteen-field emissions, preflight and post-scale sanitization, and bounded monotonic eye/nose/mouth convergence.
**Phase:** 42 and 44.

### 7. Raw eye geometry leaks through diagnostics or state

**Failure:** Biometric-adjacent points, eye side, paths, or provider details become public, logged, serialized, or imported by Demo.
**Prevention:** Package-only request-scoped support, fixed category codes, aggregate-only metrics, source scans, and no public support types.
**Phase:** 41 and 44.

## Technical Debt Patterns

| Shortcut | Immediate benefit | Long-term cost | Acceptable? |
| --- | --- | --- | --- |
| Add ten fields but leave aggregate provider points | Less code | Cannot prove field-local degradation | Never. |
| Reuse `eyeSize`/`eyeTailLift` evidence | Fewer cases | False product promotion | Never. |
| Make pupils globally required | Simple guard | Disables contour-only controls and shipped behavior | Never. |
| Persist Vision points for debugging | Easier inspection | Privacy and lifecycle expansion | Never. |
| Tune caps before decoded output evidence | Fast constants | Unfounded naturalness contract | Provisional only until Phase 44. |

## Performance and Security Traps

| Trap | Symptom | Prevention |
| --- | --- | --- |
| Duplicate landmark requests | Increased still/realtime cost | Reuse the existing single face-landmark request and selected observation. |
| Unbounded point arrays | Excess memory/work from malformed injection | Enforce small per-region ceilings and finite normalized coordinates. |
| Per-point diagnostic output | Raw geometry leakage | Fixed codes plus aggregate counts only. |
| Tracked output gallery | Repository bloat/licensing exposure | Existing ignore policy and tracked-artifact gate. |

## “Looks Done But Isn’t” Checklist

- [ ] Exact 48-field storage and complete legacy 38-key decode are both proven.
- [ ] All ten controls have independent provider and facade evidence.
- [ ] Pupil-missing/blink-implausible cases preserve contour-only siblings.
- [ ] Positive/negative tilt is visibly and numerically distinct from tail lift.
- [ ] Gaze/symmetry no-op on neutral support and reduce only measured deviation.
- [ ] Reused/stale behavior covers all fourteen eye fields.
- [ ] Combined totals/counts/scales equal final provider emissions.
- [ ] Exactly ten geometry rows are promoted; `去脂`, `祛红血丝`, and branch-level `眼睛` remain partial.

## Pitfall-to-Phase Mapping

| Pitfall | Prevention phase | Verification |
| --- | --- | --- |
| Proxy correction | 41-42 | Observed-support contract and asymmetric synthetic evidence. |
| Coordinate inversion | 41 | Exact conversion, side, orientation, and mirror tests. |
| Pupil inaccuracy | 41-42 | Missing/outside/degenerate/blink-like rejection with sibling survival. |
| Aliasing | 42-43 | Full-vector comparisons and fixed eye ROI output families. |
| Overcorrection | 42-44 | Dead-zone, monotonic reduction, exact caps, visual thresholds. |
| Accounting drift | 42-44 | Fourteen-field emissions and exact converged arithmetic. |
| Geometry leakage | 41-44 | Public/SPI, serialization, log/metric, Demo-import, and active-source scans. |

## Sources

- [Apple `leftPupil`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/leftpupil) and [rightPupil](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/rightpupil) — pupil locations may be inaccurate while blinking.
- `SECURITY.md` — no landmark persistence or public raw geometry.
- v1.9/v1.10 boundary and convergence evidence — provider-owned fail-closed patterns.

---
*Pitfalls research for: Beauty v1.11 Eye Remaining Geometry Controls*
*Researched: 2026-07-16*
