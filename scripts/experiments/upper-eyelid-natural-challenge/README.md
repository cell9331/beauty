# Frozen upper-eyelid natural-background challenge

Upper-eyelid development is **suspended** (2026-10-01). The control is hidden
from default discovery and batches; explicit SDK/CLI behavior remains for
compatibility. This experiment preserves the unresolved failure. New candidate
research requires an explicit owner request to reopen; it is not an active
work item or a blocker for unrelated SDK work.

The final normal gate passed **1072 tests, zero failures, nine executed
opt-ins and zero skips**. That verifies engineering and compatibility within
its tested scope. This separate challenge remains red: **one test, two
failures, zero skips, exit 1** against the restored production implementation.
It is never converted into an expected failure, skip or passing gate result.
See the [current quality scope](../../../QUALITY_SCORE.md) and
[historical experiments](../../../docs/history/upper-eyelid-experiments-2026-10-01.md).

## Frozen evidence

The Swift source is retained byte for byte with SHA-256
`69b6e56f572f3efd88155cb75c2a54e0f66a0af63024127b7aad72bda1dd6008`.
Its positive is the unchanged natural-style generated base plus an equal-RGB
quartic dome of amplitude 30, using the original Vision envelope and 0.45
radii. There is no flat-color calibration. The raw base and a separately
registered flatter-lid image remain negatives.

The fixed oracle requires detected geometry and two admitted positive eyes,
source-defined central reduction of at least `20% * strength` at four
strengths, no new dark residual or radial valley beyond tolerance, protected
pixels unchanged, bounded correction, alpha/chroma preservation, neutral
identity, repeatability and output metadata. This is a known added luminance
target, not a tissue-fat label or general portrait-quality test.

The restored implementation admits only one positive eye. Frozen source lines
61/63 report the admission assertion and its `invalidSource` guard; the effect
loop is not reached. Tested alternatives that admitted both eyes still failed
the reduction requirements and were withdrawn. The source recipe, labels and
thresholds remain unchanged.

## Isolated reproduction

To reproduce the existing evidence from the repository:

```bash
python3 scripts/experiments/upper-eyelid-natural-challenge/run.py
```

The runner copies the current `BeautySDK/Package.swift`, `Sources` and `Tests`
to a disposable directory under ignored `BeautySDK/.build/`, excluding build
directories and rejecting symbolic links. It adds the frozen test only to
that copy and builds separately. Production files, active tests, the manifest
and the normal gate are untouched; an already-active challenge copy is
rejected. The local build area preserves the frozen loader's no-symlink rule.

Only the two authorized, ignored portrait fixtures are copied:
`upper-eyelid-generated-base.png` and `upper-eyelid-negative-control.png`.
Each file and its parents must be free of symbolic links; each file must be
regular, at most 16 MiB, ignored by Git and match its fixed SHA-256. Fixture
path/environment overrides are disabled. The runner forces the existing
Vision opt-in and selects only `testFrozenNaturalBackgroundDome`; admission
and later capacity diagnostics are not selected. Media export is disabled.
Temporary package, build, transcript and fixture copies are removed on normal
exit, test failure or handled interruption. No media or private locator is
stored in this experiment directory or its durable results.

Output contains only aggregate status, frozen source line numbers and fixed
error codes. The child process's nonzero status is preserved. `valid_execution`
means XCTest discovered and accounted for the selected method; it does not
prove fixture prerequisites or the effect loop ran. A zero-test run, skip or
unrecognized transcript cannot return success. Eight parser checks cover
pass/fail accounting and locator-free diagnostics. No raw child transcript is
retained or printed. Running this challenge neither runs nor replaces the
normal gate.
