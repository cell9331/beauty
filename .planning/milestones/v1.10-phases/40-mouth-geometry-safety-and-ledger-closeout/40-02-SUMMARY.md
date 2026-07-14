---
phase: 40
plan: "02"
status: complete
requirements: [MOUTH-13, MOUTH-14]
key_files:
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
---

# Plan 40-02 Summary

Replaced relational mouth weakening checks with exact arithmetic for all thirteen signed/positive direction rows. A complete face + eye + six-nose + eight-mouth lower-level case proves an exact retained total of `5.30`, count `16`, scale `1/5.30`, one warning, and sign-preserving strengths. An integrated missing-inner case proves the two dependent local fields contribute zero while the exact retained total `4.80`, count `14`, scale `1/4.80`, eligible siblings, and final provider emissions agree.

Focused evidence passed **72/72**: CombinedEffectSafety 10, GeometryConflictResolver 11, MissingLandmarkDegradation 35, and MouthWarpProvider 16. No production repair was required; the existing monotonic fourteen-removal resolver is retained. Product promotion remains blocked on Plan 40-03.
