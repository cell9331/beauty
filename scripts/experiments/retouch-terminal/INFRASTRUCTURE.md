# Infrastructure revisions

The first isolated compile failed at Evaluation.swift:37 before any control or
candidate executed. The aggregate and registered source are retained in
`results/r1-build-failure.json` and `revisions/r1/`.

The nested negative-pixel filter/contains expression is expanded to equivalent
explicit loops to avoid the compile failure at that expression. It still counts
a pixel once when any RGBA channel differs. Candidate source, original source
construction, reference, eye scoring, limits and registered candidate constants
are unchanged. Current registration is refreshed for this harness-only correction;
the first registration remains in its snapshot. No algorithm evaluation was
completed or added to the budget by this compile failure.
