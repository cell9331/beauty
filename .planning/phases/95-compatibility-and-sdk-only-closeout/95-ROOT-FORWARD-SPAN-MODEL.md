# Source-material forward localization

2026-09-15, generated-only integration primitive, review pending. No portrait
I/O, frozen metric amendment or completion credit.

The nonlinear correspondence solver returns inverse sampling information:
at output coordinate x, source q(x) lies in an interval. Width acceptance must
instead follow registered source structures s through the forward inverse
x=q^{-1}(s). Interior dLeft-dRight is not generally structural narrowing.

## Counterexample and contract

An increasing piecewise-linear q through (0,0),(3,2),(7,8),(10,10) has positive
interior displacement difference2, yet source boundaries0 and10 remain fixed.
The new generated control requires width10, not8. Source anatomy registration
is still necessary; forward localization does not identify which source points
are the root sides and cannot certify them from ROI membership alone.

`scripts/phase95-root-forward-span.py` accepts a Fraction source-position
interval, ordered inverse-correspondence samples (x,qLo,qHi), and independently
admitted positive lower/upper secant slopes m,M. These are supplied mathematical
assumptions, NOT inferred from the samples or silently borrowed from production.
No production slope certificate or image-error admission is implemented here.

For every source anchor s and sample q(x), the forward displacement satisfies
delta/M <= q^{-1}(s)-x <= delta/m when delta=s-q(x)>=0; the denominators reverse
for negative delta. Evaluating the monotone endpoint functions at sLo-qHi and
sHi-qLo gives conservative output bounds. Intersect all sample bounds; never
choose a best correspondence or discard an unfavorable sample. Check necessary
cross-sample secant compatibility and require the entire source interval to be
bracketed by the endpoint observations. Invalid, inconsistent, unbracketed or
unordered structures reject with fixed reasons.

For ordered output intervals L,R, span is[R.lo-L.hi,R.hi-L.lo]. No threshold,
normalization, row aggregation, sibling exemption or pass verdict is added.
The helper is exact rational arithmetic over2...257 samples; callers still own
byte/numerator/resource limits before any future private-input admission.

## Generated verification

328 checks: known piecewise-linear maps with slopes1/5...13/5, uncertainty0
and1/20, both signs of relative anchor position, common translations, true
contraction/expansion/identity, uncertain source anchors, the independent
semantic counterexample and five typed malformed/inconsistent controls.
Truth is the independent analytic map, not a production control-point oracle.
Both normal and Python optimization modes must pass; no assertion-based gates.

Remaining work: source-only anatomical structure binding, correspondence and
production-model admission, full scoring identity integration, unchanged
portrait gate and final independent closeout. Latest portrait remains6/7.
