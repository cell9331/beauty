---
spike: 005
name: still-image-integration
type: standard
validates: "Given all accepted local work, when the combined pipeline repeats, then degradation, logs, latency, memory, and SDK ownership stay within the still-image boundary."
verdict: VALIDATED
related: [002a, 002b, 003, 004]
tags: [integration, performance, privacy]
---

# Spike 005: Still-Image Integration

## What This Validates

Validates the isolated still-image experiment boundary: one local Vision request,
request-local masks, bounded color transforms, aggregate-only logs, deterministic
artifacts, and no change to the public SDK or live pixel-buffer path.

## Research

Apple's [selfie landmark sample](https://developer.apple.com/documentation/vision/analyzing-a-selfie-and-visualizing-its-content)
confirms that one face observation can expose eye, eyebrow, pupil, and lip
regions for still-image processing. The current repository's public pixel-buffer
path does not own face detection, so this spike intentionally makes no realtime
claim.

## How to Run

```bash
swift build -c release --package-path .planning/spikes/retouch-lab
.planning/spikes/retouch-lab/.build/release/retouch-spike-lab \
  --mode integration \
  --input example-images/input/portraits/e6.jpg \
  --output .planning/spikes/005-still-image-integration/artifacts/e6-release \
  --iterations 9
open .planning/spikes/005-still-image-integration/review.html
```

## What to Expect

The visual review page compares each candidate against its original and shows
mask overlays. Integration metrics must report zero changes outside the union
mask, and event logs must contain counts/timings only.

## Observability

`events.json` has `start`, `detection`, and `result` events. Allowed metadata is
limited to mode, counts, durations, output count, and changed/mask pixel counts.
The privacy scan rejects coordinate/point/pupil-position/vein-pattern keys.

## Investigation Trail

1. Built one Swift 6 package using only Apple frameworks.
2. Added seven deterministic self-tests for polygon containment, no leakage,
   luminance behavior, texture preservation, and transform bounds.
3. Repeated the accepted color pass nine times after one Vision request at two
   resolutions, in debug and release, which exposed the expected optimizer gap.
4. Re-ran release: median color-pass time was 0.273 ms at 506×900 and 2.647 ms
   at 1728×2304. Vision landmark time was 73.9 ms and 58.4 ms respectively.
5. Scanned every JSON event schema and all metrics: no sensitive coordinate key
   appeared, and all measured runs reported zero outside-mask changes.

## Results

**Verdict: VALIDATED — for the isolated still-image harness only.**

The high-resolution release run used a 10,987-pixel union mask, changed 7,807
pixels, and changed zero outside pixels. Nine transforms plus mask work took
122.9 ms after detection, with a 2.647 ms median transform and 159.9 MB peak RSS.
The smaller fixture took 11.7 ms after detection and peaked at 47.1 MB.

This validates the experiment architecture and privacy/logging pattern. It does
not validate v1.14, device performance, public result ownership, the camera path,
or the two product masks. Use `review.html` for the required human visual gate.
