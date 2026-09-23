# Owner-approved internal chin/root revision

## Authorization and unchanged boundaries

2026-09-14: the owner answered “允许” to revising internal chin/root deformation
contracts, expressly retaining ROI, acceptance thresholds, public parameter caps
and the same authorized portrait. Candidates 1–5 and their failures remain
historical; this is not a retroactive pass or a reset of that history.

## Candidate 6, frozen before portrait evaluation

Observed-lip chin uses a 0.024-face-width physical displacement ceiling instead
of 0.016; nil-support historical path remains 0.016. Inward distance, mouth
clearance, finite admission and per-side 0.8 slope ceiling remain enforced.
Root with observed eyes includes a 0.03-face-width superior glabellar interval;
its physical displacement ceiling is 0.04 face widths, further bounded by half
source half-span and 0.7 radius. Inverse-sampler target disks remain inside both
inner canthi and the root envelope, with an explicit floating-point interior
margin. Sub-cap radii solve containment under both displacement bounds.

The generated-support contract tests intentionally changed only the newly
authorized internal physical/support assertions. A sub-cap equality-at-canthus
failure was repaired in production with an inward safety margin, not a relaxed
assertion. New independent generated-structure contraction and inverse-map
coordinate sweeps pass. Final focused current-source selection: 14/0/0.
Legacy chin/nose/mouth selection passed its ten methods before the final inward
rounding margin; it does not stand in for current full-suite verification.

Pre-evaluation production SHA256:

- Chin: `22dba9993c26232b4e8409c132808d9a8e5efdf9dfe2fa0f973abcafe3a0e99c`
- Nose: `32648cb21148806f788302802c306be83bce36a26b424e0915b6097aad48eb30`
- Other production files retain candidate 5 identities.
- Comparator: `6a9b90e7eabfbfa82df65dfe493493d014c87ea1e63c091d1fa7adbb698d1ebe`
- Manifest: `5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e`

No pixel/geometry/private locator is retained here. Portrait effectiveness,
final no-skip and independent review remain unproven until actual gates pass.

## Candidate 6 actual portrait result

The two-attempt, five-batch, 65-case portrait run completed with exit 3 and
`semantic_fail`. Stable report payload SHA256:
`ce19cf7dfc07b3f9454e52251670d44a6653247aa4eedf02eb155fdd59887520`.
Six of seven active directions passed: chin 23 (59,625 changed pixels), gaze
120, brow positive 20, brow negative -23, bridge 107 and mouth negative -32.
Root remained failing at -2 (7,907 changed pixels). Deferred contour remained
unchanged. Every direction retained zero outside/protected changed pixels and
zero outside/protected RGB changes. This is not an effectiveness pass.

The owner separately authorized an independent review subagent after effect
acceptance passes. That prerequisite is still unmet; no independent review or
formal no-skip closeout is credited. Next investigation is source-only analysis
of the root measurement and anatomical support, retaining all frozen ROI and
threshold identities and recording only privacy-safe aggregates.

## Candidate 7 diagnostic freeze

Source-only diagnostics exclude a raster reflection (direct CI/CG RGB delta
zero) and eye-dominated darkness (eye fraction 1,043 basis points; between-canthi
fraction 6,844). A temporary single-case render reproduces candidate 6's -2
root margin. Bright and dark deterministic structure tests both pass.

Candidate 7 tiles a tall observed root band into at most eight vertically
disjoint rows of existing inward linear-cone pairs. Each row retains the same
0.8 admission bound, physical displacement caps, canthus containment and bridge
boundary. Because only one row can act at any Y, bounds do not accumulate across
rows. Nil-eye root and bridge retain one row. Focused tests: 8/0/0, including
actual pixel protection, both contrast polarities and inverse-coordinate sweeps.
Pre-diagnostic Nose provider SHA256:
`49ab94ede0041e4fa8c3601de81df975e8406f0c1fd2b25339d739d6e7ec30c4`.
No portrait success is claimed by those generated tests.

Candidate 7 single-case actual renderer diagnostic: root margin 2, still below
16. This improves the candidate-6 -2 reproduction but remains a failure. The
temporary render and child capture were discarded; no complete candidate-7
portrait run, sibling protection conclusion, or closeout credit is inferred.

## Candidate 8 diagnostic freeze

Replace the root's fractional interior wall placement with the source-anatomical
safe-envelope edge: cap target span = envelope minus admitted radius; source
span = target span plus the existing bounded cap displacement. Existing 0.10
face-width source-span cap and sub-cap containment solver remain. This reaches
the usable nasal wall without crossing a canthus. Eight focused tests pass,
including both contrast polarities. Pre-diagnostic provider SHA256:
`454880631712a004e277a84ed66dda65eeb1fd4d100d336ad9751dfd6ff760b7`.

Candidate 8 single-case root margin: 3, still failing. No complete gate credit.

Candidate 9 investigates the unnecessary opposite-cone separation restriction:
the existing ordered inward-field proof allows opposing cones to overlap while
retaining a strictly positive horizontal derivative. Use up to three quarters
of the inner-canthus half-gap (still bounded by face width and the root band),
and fit whole safe rows before shrinking their disks. Physical caps, anatomical
envelope and actual 0.8 slope ceiling are unchanged. This is not a new kernel,
backend, ROI or threshold; only the existing point field's support is revised.

Candidate 9 pre-diagnostic provider SHA256:
`28bce6a7e7398b26bb9d0c1693f3923e9a197c276b9aa95c475a3294299d4e9e`.
Focused generated tests pass 8/0/0.

Candidate 9 single-case root margin: -1, still failing. A deliberately relaxed
source-only horizontal-sampling bound is 262 Q16; this is not an implementation
or acceptance result and does not prove that safe geometry can achieve it.

## Candidate 10 diagnostic freeze

Actual eye contour extents partition root rows. Eye-intersecting rows remain
strictly medial to the corresponding complete eye box; rows fully above/below
eyes may use the nasal-root 0.14-face-width envelope rather than extending the
canthus exclusion as an infinite vertical strip. Per-row cones and the 0.04
physical displacement / 0.7-radius / 0.8 slope bounds remain. Row separation,
monotonicity and identity at eye-band boundaries preserve actual eye pixels and
source samples. Generated oracles now explicitly assert those eyes unchanged,
not a stronger non-anatomical vertical strip. Eight focused tests pass.
Pre-diagnostic provider SHA256:
`05979c7597965ddd89f2becec31c0db2233dd50a0a6ffe145eb9e2141a3a27cc`.

Candidate 10 single-case root margin: -12, still failing. This does not prove
the geometry is effective. The newly added independent generated metric
counterexample narrows a 10-level-contrast stripe from 246 to 204 pixels, yet
the unchanged dark-half-centroid metric reports -168 Q16 (wrong direction).
Adding exactly 30 luminance levels to both images, without changing geometry
or contrast, reverses the metric to +1,344. Ten focused tests pass, including
both exact counterexamples. No replacement metric has scored the portrait.

The owner explicitly approved early independent review and, if the defect is
confirmed, revision of the measurement definition. ROI, threshold, authorized
source and historical failures remain unchanged. The replacement definition
must be independently reviewed and frozen before effect evaluation. This
supersedes the previous condition that review wait for all old-metric passes;
it does not authorize weakening thresholds or retroactively erasing failures.
