# Frozen texture-semantic feasibility probe (2026-10-03)

The owner authorized one bounded experiment. The predeclared skin direction,
object/eye/lip/background protection, neutral/repeat/alpha/metadata predicates
are unchanged. Production source, public API, masks and ordinary acceptance
thresholds are unchanged. The test-only periodic-texture veto is rejected.

Run from any cwd:

```bash
python3 scripts/experiments/texture-semantic-probe/run.py
```

The runner builds a temporary external Swift package that depends on the local
BeautySDK product. It does not inject tests into the SDK, use portrait assets,
train a model or keep its generated inputs, masks, output media or child
transcript. Only fixed aggregate outcomes are printed. A nonzero result is the
retained failed qualification, not a command to keep tuning.

The runner pins the Swift source SHA-256, reconciles all four test identities
and zero skips, caps child output at 16 MiB and stops after 600 seconds. SwiftPM
needs writable build caches and permission to run its manifest sandbox; a
pre-test environment failure returns 2 and grants no effect evidence.

The source deliberately renders two possible material scenes with equal full
observable pixels and equal face support. Oracle material labels are never
passed to the automatic candidate. Improving that region as skin and keeping
it exact as an object are conflicting requirements for this input pair. This
does not establish that every observable object class is indistinguishable.

The original SDK-host spike ran **4 tests / 6 protection failures / zero skips**
(and the existing mask suite passed 4/0/0). Direction/object markers describe
only those local predicates. The deep-skin, low-contrast lip extending outside
the coarse lip exclusion caused the six failures; it is retained in the same
unmodified source, not cropped out or changed to expected failure. The separate
full SDK gate does not overwrite this failed challenge.
The external consumer reproduced **4/6/0, exit 1** with the same frozen source.

Current semantic/protection disposition is recorded in
[the research result](../../../docs/TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md).
