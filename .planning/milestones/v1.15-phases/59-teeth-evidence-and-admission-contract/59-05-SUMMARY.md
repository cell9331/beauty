---
phase: 59
plan: 05
status: completed-open-evidence
---

# Plan 59-05 Summary

Bound the supplied local teeth evidence to the existing Phase 54 authority and
serialized the resulting durable allowlist. The adapter keeps all private
intake material in memory, computes fresh asset identity internally, issues
only the frozen structured judgments, and delegates validation, reduction, and
serialization to `ReviewCore`. No production SDK, renderer, provider, Demo,
or output behavior changed.

## Canonical Decision

The serializer-produced Phase 54 ledger now records:

- `teeth_whitening`: `open`, no reasons, `eligible/reviewed/accepted/rejected`
  counts `2/2/2/0`, naturalness weight `2`.
- Two opaque teeth review rows: the positive has target present, mask coverage
  `4`, no protected leakage, naturalness `4`, no structure change, and
  `accept/none`; the negative has target absent, mask coverage `1`, the same
  safety judgments, and `accept/none`.
- `sclera_redness` and `upper_eyelid_fullness` remain byte/semantically
  unchanged and closed with their existing reasons and zero counts.

## Privacy and Authority

Added a private resolver/export adapter and a path-free child runner. The
runner accepts exactly one fully ignored qualifying local bundle, injects its
location only into the child environment, rejects leaks and ambiguous input,
and emits fixed aggregate status only. The tracked fixture document is now
policy-only; no local locator, media, hash, rights carrier, reviewer identity,
or freeform review text crosses into Git.

The adapter does not consume mechanics metrics. A contract regression passes
arbitrary mechanics-report variations through an ignored extra argument and
proves that the structured decision and serializer bytes remain identical.

## Verification

- Phase 54 ReviewCore: 33/33.
- Phase 59 local contract: 7/7 through the private runner.
- Fresh-process serializer byte verification: passed.
- Tracked/staged privacy scan: passed for 1309 tracked files.
- Shared harness self-test: 24/24.
- Canonical JSON validation and `git diff --check`: passed.
- Missing private environment and attempted child-location leakage both failed
  closed with fixed, path-free outcomes.

The evidence decision is open, but this plan does not claim whitening
effectiveness, protected-tissue safety, production naturalness, or feature
promotion. Those remain downstream Phase 60+ gates.
