# Current renderer batch validation

Owner-local SDK validation; full contract and measured results:
[CURRENT_BATCH_VALIDATION](../../docs/CURRENT_BATCH_VALIDATION.md).
The old 75-case scripts and receipts are historical and remain unchanged.

From the repository root on macOS with Swift, Python 3 and Core Image/Vision:

```sh
python3 -B scripts/current-batch/run.py
python3 -B scripts/current-batch/run.py --preflight-only
python3 -B scripts/current-batch/run.py --suite BeautySDK/.build/my-suite.json
```

Each call builds the current renderer in a new ignored run directory. The default
mode generates one no-face gradient, renders all 98 default cases twice, and checks
actual pixels and metadata. It covers six global color directions, one neutral
identity and 91 declared no-face exits. It does not qualify 98 portrait effects.
The compatibility-only suspended eyelid identity is excluded from execution.
Preflight checks inventory only and reports `preflight_only` without pixel credit.

Custom suites require explicit local PNGs, SHA-256 values and independently authored
case oracles. Inputs must be upright, opaque 8-bit sRGB PNGs, no more than 16 MiB
or 1,048,576 pixels; at most four fixtures. Repository-local suite/media files must
be Git-ignored. Relative paths resolve from the suite directory. Example skeleton
(replace the digest before use; omitted case oracles remain unverified):

```json
{
  "schema": "beauty.current-batch.suite.v1",
  "fixtures": [{
    "id": "F01",
    "path": "source.png",
    "sha256": "REPLACE_WITH_SOURCE_SHA256",
    "oracles": {
      "geometryBaseline_noop": {"kind": "exact"},
      "brightness_plus0p25": {
        "kind": "metrics",
        "checks": [{"metric": "luma_delta", "minimum": 1, "maximum": 64}]
      }
    }
  }]
}
```

`exact` verifies source identity; `abstain` records an explicitly expected unchanged
result separately. `metrics` requires a nonzero direction interval. Target/protection
rectangles and per-case constraints are described in the contract. The current
metric set measures color direction; it does not measure anatomical geometry,
texture retention or perceptual quality. Do not substitute these metrics for a
branch-specific oracle. No oracle gives `unverified`, even with valid output files.

Exit codes: 0 = all declared checks pass, including allowed abstentions;
1 = measured effect failure; 2 = execution/input/report error;
3 = missing oracle. Higher priority is 2, then 1, then 3. Console output contains
aggregates and a run ID. Detailed `report.json` and local images remain under
`BeautySDK/.build/current-batch/<run-id>/`; no source locators, regions or child
transcripts enter the aggregate. Original renderer reports and request files are
removed after consumption. All results carry `effect_qualification: false`.

Tool regression checks, with the native helper compiled outside the source tree:

```sh
swiftc -O scripts/current-batch/pixels.swift -o /private/tmp/beauty-current-batch-pixels
BEAUTY_CURRENT_BATCH_PIXEL_HELPER=/private/tmp/beauty-current-batch-pixels python3 -B scripts/current-batch/test_batch.py
```

The native helper is required: no silent skip. Tests include actual pixel
counterexamples, corrupt decoding, empty protection, bounded child failures,
inventory/report corruption and missing-oracle accounting. `snapshots/r2/` preserves the pre-hardening child cleanup implementation.
`snapshots/r1/` and
`results/default-r1.json` preserve the first harness authoring mistake; they are
read-only evidence, not runnable current entry points.
