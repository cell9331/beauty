# Upper-eyelid and skin-object evidence review (2026-09-29)

This note supports the current [effect taxonomy](SDK_EFFECT_TAXONOMY.md),
[image acceptance policy](IMAGE_EFFECT_ACCEPTANCE.md), and
[active plan](../plans/active/A-2026-09-27-remaining-effect-qualification.md).
It records what primary sources establish and what must still be demonstrated
by this SDK's actual input and output. It does not change historical receipts.

## Upper-eyelid fullness

| Source | Supported finding | Limit for this SDK |
| --- | --- | --- |
| [Apple Vision 2D landmarks](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) | `leftEye`, `rightEye`, `leftEyebrow`, and `rightEyebrow` locate 2D feature outlines. | These points bound an edit region; Apple does not label upper-lid fullness or supply a desired tissue surface. |
| [Belhumeur, Kriegman and Yuille, *The Bas-Relief Ambiguity* (1999)](https://www.cs.jhu.edu/~ayuille1/PubsJournal/J52BelhumeurKriegmanYuille99.pdf) | Under its stated orthographic, Lambertian and lighting assumptions, distinct shapes and reflectances can produce identical images. | This establishes a shape-from-shading ambiguity, not an impossibility theorem for every portrait or learned prior. A low-frequency luminance residual cannot by itself certify upper-lid volume. |
| [Guo et al., upper-eyelid 3D area and volume reliability (2023)](https://pubmed.ncbi.nlm.nih.gov/36915328/) | In 44 adults with 3D surface images, standardized area measurement was reliable, while direct single-3D-image volume measurement had poor intramethod reliability. | The study did **not** test this SDK or ordinary single 2D photos. It cautions against equating a 2D brightness score with measured volume. |
| [Durand and Dorsey, bilateral base/detail processing (2002)](https://people.csail.mit.edu/fredo/PUBLI/Siggraph2002/DurandBilateral.pdf) and [Paris, Hasinoff and Kautz, local Laplacian filters (2011)](https://people.csail.mit.edu/sparis/publi/2011/siggraph/) | Edge-aware tonal processing is designed to preserve detail and avoid halos near strong boundaries. | These are image-processing methods, not upper-lid effect validation. The rings observed in this SDK's generated output are a local finding; the papers only motivate an edge/artifact oracle and candidate design. |

The current implementation tests a blurred luminance residual against a fitted
plane, then applies bounded RGB corrections within a per-eye feather. That is
an **image-space proxy**, not a measurement of eyelid fat, tissue depth, or
volume. In the current frozen investigations, four natural-style generated
positives did not safely admit both eyes. One source with more visible fullness
had a *lower* residual score than its prior version. A controlled positive did
admit and pass numeric target/protection checks, but original-size review found
closed rings around both upper lids. Therefore neither a lower source threshold
nor a larger correction gain has evidence for a visual-quality claim.
In a separate, temporary package-only diagnostic on the existing generated
bulge fixture, eliminating all positive RGB corrections removed 123 brightened
proposal pixels but the visible dark ring persisted. Existing focused numeric
tests passed for that candidate; its visual result failed, so the change and
temporary test were removed. This does not isolate the ring's complete cause.

Before changing production behavior, freeze a qualified positive/negative
source pair, the eye and protected regions, neutral and typed-failure checks,
and an original-detail no-ring/no-worsening review. A candidate must preserve
both the intended directional change and the existing fail-closed behavior.
The owner's provisional callable API remains valid under its stated limits.

### Follow-up source/output probe (2026-09-30)

A locally generated 1254×1254 fictional adult source with mild visible
viewer-left upper-lid fullness (source SHA-256
`d0fb3f6b4a41a6ca5b8b7359b900fdf0e49118d666875d02fa693bd366e9cc74`)
was admitted by the unchanged live Vision and semantic-owner path for **one
eye only**. Its admitted eye had central/localized luminance residual scores
`5.42/13.47` and positive fraction `0.625`; the other eye was rejected. A
matched flatter-lid edit (SHA-256
`fabc4bac1fe5c71ac4adaef225501c847a913a3144ef8ce31003c6a4fded1f7b`)
was rejected for both eyes (`-4.05/1.97`, fraction `0.203` on the formerly
admitted side). An intermediate, visually flatter edit still admitted that
side (`1.50/8.99`, fraction `0.481`), so this is not evidence that the proxy
reliably separates fullness across edits or people.

Before viewing the public effect output, the intended single-eye oracle
required at least 100 changed pixels in the admitted upper lid, no change in
the rejected eye or outside the upper-lid region, per-channel delta at most
16, neutral and repeat identity, preserved alpha/extent, and no visible ring
at original detail. The first diagnostic test mapped the admitted eye to the
wrong image half and inverted the image-buffer row direction, so its region
assertion failed. After correcting those coordinates **based on the observed
output**, the unchanged public `processResult` at strength 1 showed 2,983
changed pixels in the actual admitted upper-lid region, zero on the rejected
side or outside that region, maximum channel delta 16, and passing
neutral/repeat and alpha/extent checks. The matched negative produced exact
source pixels. Original-detail comparison did not show the closed ring seen
on the earlier controlled fixture, but the effect was visually slight.
Because the spatial oracle was corrected after output inspection, these are
**exploratory diagnostics**, not a predeclared regional acceptance pass. A
new independently frozen source and correctly mapped region are needed for
that claim. This one-source, one-eye result does not qualify a stronger visual
effect, bilateral admission, or general fullness recognition. The temporary
diagnostics and media were not added to the repository.

A second independent 1254×1254 generated portrait (source SHA-256
`f7cb05b48cc84913604f6e465c0b3670f43682d45c2a76b4bcb759ba8b1e0374`)
visibly presented bilateral upper-lid fullness and admitted both eyes under
unchanged live Vision (`5.31/8.39` central scores). The target/protected
regions were fixed before any effect output. Two closely matched edits aimed
at flatter lids remained **bilaterally admitted**: the first central scores
rose to `8.86/12.08`, and the second remained `6.50/7.77`. The generation
process also changed other image details, so this does not isolate a causal
defect in the lid classifier. It does show that these visually flatter edits
cannot serve as safe negatives for this acceptance pair. No effect output was
viewed for this source and no production thresholds or gain were changed.
Further source generation alone should not be counted as progress unless the
source labels and matched negative are independently credible and the current
semantic owner separates them before output.

## Same-colored non-skin objects

| Source | Supported finding | Limit for this SDK |
| --- | --- | --- |
| [Apple person segmentation](https://developer.apple.com/documentation/vision/vngeneratepersonsegmentationrequest) | Produces a matte for a person. | A person matte does not label skin versus an object overlapping that person. |
| [Apple foreground instance mask](https://developer.apple.com/documentation/vision/generateforegroundinstancemaskrequest) | Separates noticeable foreground object instances from background. | Instance IDs do not identify skin, and an attached or visually merged object has no promised separate instance. |
| [Lee et al., CelebAMask-HQ / MaskGAN (CVPR 2020)](https://openaccess.thecvf.com/content_CVPR_2020/papers/Lee_MaskGAN_Towards_Diverse_and_Interactive_Facial_Image_Manipulation_CVPR_2020_paper.pdf) | A manually annotated face-parsing set includes skin and selected accessories as separate classes. | Category-specific segmentation is feasible with defined labels and evidence; the listed classes do not cover arbitrary same-colored objects. Dataset/model rights and local-use scope require separate review before any adoption. |
| [Yin and Chen, FaceOcc (2022)](https://arxiv.org/abs/2201.08425) | Additional labeled occlusion types improve face extraction, and the paper identifies limited occlusion coverage as a weakness of earlier data. | It does not give this SDK an automatic arbitrary-object guarantee or permission to use its data/model. |

For two inputs with the same observable pixels and current face support but
different intended skin/object labels, the present color, edge and face-envelope
rules must make the same decision. This is a limit of **these inputs and rules**,
not a claim that all automatic face parsing is impossible. The existing
owner-supplied request-local exclusion mask protects exactly the marked pixels.
Automatic protection remains open and would need a named object/admission scope,
matched same-color positive and negative inputs, protected-region output tests,
and an independently reviewed model/data license if a learned path were chosen.
No data, training, model or weight work is authorized by this review.
