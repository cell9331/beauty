# Root structural cohort integration — 2026-09-22

Scope: generated-only measurement implementation, no new source registration or
portrait scoring. Original image, ROI, threshold, definition freezes and failures
remain unchanged. This does not grant anatomical-boundary qualification.

`scripts/phase95-root-structural-metric.py` consumes in-memory structural width
intervals from the reviewed forward-correspondence primitive. It requires the
same pre-registered12..16 row IDs for source, neutral, candidate and the exact
three original siblings: noseBridge_0p30, noseSlim_0p35, noseTipLift_0p25.
No output may omit a row or select its own weights. Mean intervals use exact
Fractions, full-image-width Q16 units and outward rounding only after aggregation.
Source and neutral conservative contraction and each absolute sibling interval
distance must all meet the existing16Q16 floor. Uncertain/overlapping intervals
cannot gain credit from their midpoint. Target signal, protection and metadata
remain additional mandatory predicates in the future portrait integration.

The generated test suite covers15/16/17 boundaries, negative/zero motion,
copied source/neutral/each sibling, missing roles, changed row sets, coverage,
uncertainty retaining zero motion, rounding order, fixed equal weights, absolute
sibling distance, exact manifest sibling identity, invalid widths and analytic
forward-correspondence integration across twelve distinct generated rows.

Existing Phase95RootImageFormationTests already join actual canonical pixels to
nonlinear correspondence and forward structural width for a generated positive
and an unchanged-boundary negative. They remain unchanged. This iteration tried
an additional sixteen-row SwiftPM integration experiment: its first run returned
1 test/3 failures; its aggregate-only capture does not establish the exact first
failure cause. It was not acceptance. The experimental test was removed, rather than selecting favorable
rows or weakening a measurement threshold. The pure nine-test cohort suite has
independent analytic forward geometry; it does not claim a full real-image cohort
or new portrait power. No failing experiment is counted as a root effect pass.

Remaining root work is anatomical source registration, justified production
measurement/model admission, actual sibling/source/neutral integration in the
Swift comparator and versioned driver, independent review, then real portrait
acceptance. The original observed contour coverage3/16 cannot supply these labels.
The owner has been asked to choose automatic source-only recognizer development
or actual local boundary confirmation; no unconfirmed label or recognition
permission is assumed from silence. Closeout tooling work is independent of that choice.

Verification results are recorded in PLANS and QUALITY_SCORE after execution.

## Follow-up completion request

The owner subsequently requested continued completion of v1.22. Necessary
measurement development is proceeding; generic development permission is no
longer treated as missing. The source-only diagnostic in
95-ROOT-SOURCE-CANDIDATES-SPEC.md still cannot grant structural ownership from
candidate counts. Source/candidate ambiguity is an evidence gap, not a reason
to silently relax NOSE-02. The new measure_hypotheses conjunction retains every
supplied interpretation: one stationary outer structure blocks credit even when
internal interpretations shrink. Its14 tests and independent review pass;
registration completeness and real source ownership remain separate obligations.
