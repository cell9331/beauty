# Spike Conventions

Patterns and stack choices established across local-retouch spike sessions.
New spikes follow these unless the question requires otherwise.

## Stack

- Use an isolated Swift 6 package under `.planning/spikes/retouch-lab`.
- Prefer Apple Vision, Core Image, Core Graphics, and Core ML so the experiment
  matches the target platform and remains local-first.
- Build release before recording performance; debug metrics are diagnostic only.

## Structure

- Each spike owns `README.md` plus `artifacts/<fixture>/`.
- A run emits `after.png`, `mask.png`, `overlay.png`, `metrics.json`, and
  `events.json`; multi-mask passes may add named mask PNGs.
- Comparison candidates share a number with `a`/`b` suffixes and use the same
  fixtures and support mask whenever possible.
- Visually judged comparisons include a local `review.html`; binary media stays
  disposable/ignored while source, aggregate metrics, and commands stay tracked.

## Patterns

- Separate region selection from color/geometry transformation.
- Missing, blinking, closed, occluded, implausible, or no-face support fails
  closed at the smallest affected region.
- Measure `changedOutsideMask`, maximum channel delta, luminance delta, and
  texture-energy ratio for every visual transform.
- Raw landmarks and sensitive masks are request-local. Persisted experiment
  logs contain aggregate counts and timings only.
- AI-generated fixtures prove mechanics only. Product-feasibility verdicts need
  licensed real positive/negative fixtures and human original-detail review.
- When selection expands beyond high-confidence landmark support or depends on
  uncertain landmarks, compare against the fixed baseline, exercise the
  geometric envelope independently of downstream color gates, preserve accepted
  baseline pixels or fail closed, and measure protected-region leakage.
- Mechanics fixtures and rights-approved product evidence use separate explicit
  gate states; a valid mechanics bundle must never open the product gate.
- External models stay outside the repository until their dataset, checkpoint,
  conversion, and redistribution license chain is approved and pinned.

## Tools and Libraries

- Swift Package Manager and Apple frameworks only for the shared harness.
- `jq` validates metric and event schemas.
- A static browser/File API reviewer is the preferred local evidence surface;
  it must not upload media or add a server/network retention boundary.
- External Core ML artifacts may be loaded by path for research, but must not be
  copied into the repository before legal and provenance approval.
