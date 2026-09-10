# Phase 93 candidate 1: bounded failure analysis

Status: terminal candidate stop retained; no new candidate authorized or run.

The failing candidate is preserved at `e4e89680`; the frozen field test is in
`811734f2`. Provider execution stopped at `P93_FIELD_BUDGET` after 18 passes and
one failing method, with three methods unexecuted. Both owned production files
were restored in `5392e9d1`. No post-stop Swift/render/test rerun was performed.

## Read-only arithmetic finding

The parent inspected the committed candidate and frozen test, then reconstructed
their existing cap arithmetic in memory with explicit IEEE binary32 rounding at
each Float operation and Double budget accumulation. Only aggregate budgets and
admission flags were reported; no executable fixture or source was changed.

| Existing dense case | Reconstructed cap budget | Final budget admission |
|---|---:|---|
| 2 supports | 0.4499982828740846 | admitted |
| 4 supports | 0.44999642022902386 | admitted |
| 16 supports | 0.45000014551914536 | rejected |
| 64 supports | 0.44995544203768734 | admitted |

All four reconstructed cases clear the individual strict renderer cutoff.
The 16-support case nevertheless exceeds the unchanged 0.45 complete-field
ceiling after Float target reconstruction. The candidate's final budget guard
therefore returns an empty field; the frozen cap-density assertion requires a
nonempty bridge field. This supplies a concrete failing subpredicate of the
reported conjunction. The fixed 64-ulp scale slack is insufficient for this
particular accumulated reconstruction.

This is a read-only arithmetic diagnosis, not a fresh native execution of the
candidate, proof that every other subpredicate passes, or evidence of emitted
folding. The guard fails closed. Candidate pixel efficacy remains untested.
Earlier original-provider pixel passes used the corrected adapter and cannot
be attributed to the currently rolled-back checkout.

## Concrete next disposition

Repair would require permitting the remaining second attempt after this safety-
conjunction stop, with a reconstruction-aware conservative budget calculation
that preserves applicable nonempty fields while retaining the 0.45 ceiling,
strict renderer cutoff, frozen tests/ROIs/thresholds and all sibling comparisons.
That is a substantive candidate correction, not a compile-only fix. The checked
93-03 plan permits its predefined second candidate only after pure semantic
insufficiency; this outcome does not meet that condition. No such correction has
been authored, evaluated or counted as a free retry. The overall two-attempt
ceiling is not reset, and an explicit repair/defer/stop disposition is required.
