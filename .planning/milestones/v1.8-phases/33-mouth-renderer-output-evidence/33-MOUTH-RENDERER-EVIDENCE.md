# Phase 33 Mouth Renderer Evidence

| Gate | Observed result |
| --- | --- |
| Public case inventory | 34 cases; six isolated mouth/lip cases |
| Fixtures and outputs | 7 fixtures; 238/238 decoded, non-empty, same-dimension PNGs |
| Mouth geometry | 30/30 lower-central ROI comparisons above watermark |
| Signed direction | 12/12 positive-vs-negative ROI comparisons |
| Lip color | 6/6 changed pixels contained to the documented lower-central ROI; color-only evidence |
| No-face | `no-face-gradient__mouthSize_plus0p35.png`, 64×64 |
| Gallery | 238 ignored PNGs under `example-images/gallery/` |
| Generated tracking | zero files from `git ls-files example-images/output example-images/gallery` |

The documented ROI is x=10–90% and y=25% through the computed top of the excluded watermark band. `lipColor` is not geometry displacement and does not establish true `丰唇`.
