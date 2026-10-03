# Terminal eyelid feasibility check

This is the owner's 2026-10-03 request to finish the two stalled questions, under
[R3 terminal scope](../../../docs/RETOUCH_TERMINAL_SCOPE_2026-10-03.md). It spends
the three remaining EYE development versions on the existing small pilot inputs.
It is not full G0/G1 or portrait qualification. SEG has exhausted four versions
and is not rerun or retuned. Production and all earlier experiments stay unchanged.

## Registered before evaluation

All candidate methods receive only current pixels, strength and current live Vision
eye support. No reference, fixture ID, authored target or negative label is passed.
Use the frozen pilot's source construction, original reference, two target eyes,
two negatives and unchanged E1/E3 limits: half/full improvement >=5%/10%, texture
change <=10%, exterior/alpha exact, channel change <=16, neutral/repeat/monotonic.
This pilot's allowed support is an eye envelope; it does not establish full G0's
independent semantic protection or natural-image efficacy.

- **E1-v2**: robust low-frequency residual correction. Replace per-column endpoints
  with median luminance from top/bottom boundary rows, interpolate vertically,
  average the current input over a radius of envelope height/4, require central
  average excess >3 code values. Gain .18, correction cap 4, sin-squared boundary
  taper. Hypothesis: robust context reduces endpoint noise and detail damage.
- **E2-v1**: local highlight shoulder/burn. Estimate the 75th-percentile luminance
  of the four envelope boundaries, subtract at most 4 codes of .20 times positive
  excess above that level+3; use the same sin-squared taper. No whole-eye admission
  score. Hypothesis: act only on brighter pixels rather than fitting eyelid shape.
- **E2-v2**: same boundary statistic and threshold, but average the unfeathered
  correction over radius height/3 before the final taper. Hypothesis: separating
  correction from texture limits high-frequency changes. Constants are frozen
  now; do not tune them after seeing results. This is independently authored
  engineering inspired by local dodge/burn, not a reproduction of Adobe or a paper.

First run controls, including correct weak reference, no-op, whole-image darkening
and a narrow dark trough. Only if controls pass, run the three registered versions.
Each may fail; no average across eyes or omission of failed negatives is permitted.
Any candidate that passes the small diagnostic needs full G0 and R2 qualification;
if none passes, stop EYE at this demonstrated feasibility boundary.

The runner checks hashes, copies the unchanged package to an ignored temporary
directory, uses bounded in-memory child output, and exports only fixed aggregates.
Media stays in a fresh ignored review directory. No raw pixels, regions, landmarks,
private locators or transcripts enter persistent results. Exit 1 is effect failure,
2 is incomplete execution, 0 is diagnostic success only. Registration binds all
authored sources before controls/candidates and is never updated to hide a result.
