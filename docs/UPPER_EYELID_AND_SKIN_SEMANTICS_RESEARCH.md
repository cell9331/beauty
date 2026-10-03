# Upper-eyelid and skin-object evidence review (2026-10-01)

## Current routing after terminal closure (2026-10-03)

The owner reopened both problems and later requested continuous finite work with
an explicit stop at the capability boundary. [Final disposition](RETOUCH_FINAL_DISPOSITION_2026-10-03.md)
records two methods/four rejected versions per branch and closure with unmet
objectives. [Industry comparison](RETOUCH_INDUSTRY_DECISION_2026-10-03.md) records
available assisted/model routes without pretending they were executed here.
The dated review below preserves earlier evidence. It does not reopen development;
[PLANS](../PLANS.md) owns current status.

## Current routing after explicit restart (2026-10-03)

The owner subsequently reopened research/planning for both problems in v1.25.
The [primary-source comparison](RETOUCH_RESEARCH_AND_V1_25_2026-10-03.md) provides
background; the subsequent owner-authorized [R2 MVP contract](RETOUCH_MVP_REQUIREMENTS.md)
and PLANS own the narrowed automatic tone/patch scope. Production availability/
qualification is unchanged. The dated
review below preserves the earlier evidence and suspension decision; it does
not cancel the new explicit authorization or prove a new candidate works.

This note separates established findings from unproven claims for the current
[effect taxonomy](SDK_EFFECT_TAXONOMY.md) and
[image acceptance policy](IMAGE_EFFECT_ACCEPTANCE.md). Upper-eyelid and
same-colored object protection are independent questions. Earlier source
probes and candidate receipts are retained in the
[historical experiment record](history/upper-eyelid-experiments-2026-10-01.md).

Historical 2026-10-03 follow-up before the later R2 restart: the [finite texture-semantic probe](TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md)
rejected its single source-periodicity candidate. General unmasked object
identification is unqualified and paused; explicit masks remain supported.
A new low-contrast lip outside coarse feature guards also failed protection
and remains unfixed. The skin-object review below retains its original date;
the follow-up and PLANS own current disposition. Upper-eyelid research stays
suspended.

## Upper-eyelid fullness: development suspended

The current upper-eyelid work is stopped and the control is hidden from default
CLI discovery, batches and recommended examples. Existing explicit SDK calls
and safety regressions remain for compatibility. Natural-image effect quality
is unresolved; retaining that API does not make it a recommended or visually
qualified feature. New research requires an explicit owner request to reopen
with a new testable hypothesis. There is no active instruction to continue
tuning the current approach.

### What the local evidence establishes

The implementation uses a blurred luminance residual relative to a fitted
background and bounded per-eye RGB correction. This is an **image-space
brightness proxy**, not a measurement of eyelid fat, shape, depth or volume.
A fuller-looking generated source can have a lower production score. In the
frozen natural-background challenge, adding the same known brightness dome to
both lids still admits only one eye; holding geometry fixed does not fix that
separation. The failed positive keeps its original label and threshold.

The earlier ring failure had a separate editing cause: excessive correction
could drive a positive shoulder below its reference while leaving the capped
bright center positive. Blurred spill and a test scored by the same production
analyzer further obscured the defect. Independent matched-flat bounds, a
source-guided reconstructed correction and bounded Q16 quantization now pass
the retained artifact checks and original-detail ring reproducer. The
reconstruction operator follows the grayscale concept described by
[Vincent (1993)](https://telin.ugent.be/~sanja/StudentProj/Literature/vincent-93.pdf);
that method does not supply eyelid semantics.

The retained coverage includes 13 fixed luminance sources at four strengths,
matched flat/concave negatives, 32 orientation/mirror combinations, and a
calibrated luminance target through real Vision and the public facade. The
calibration creates visible color blocks and removes natural variation.
These results establish bounded pixel and integration behavior, not natural
appearance, texture fidelity, anatomical recognition or generalization to
arbitrary lighting and makeup.

Background-fit candidates exposed an additional bottleneck. Raw-affine and
spatial/color references could admit both positive eyes and reject both
natural controls, yet full-strength central reduction was only 4.34%/5.02%
and 4.85%/2.20%, respectively, against the frozen 20% minimum. Pixel-matched
diagnostics showed that most available correction was lost in reconstruction,
with complete central support and much smaller Q16 loss. Relaxing propagation
created dark undershoot, radial artifacts and unwanted continuous-ridge edits.
A quadratic background fit also removed an existing narrow positive and
falsely admitted a natural negative. All tried candidates were rejected; the
validated model and repaired editor were restored. This is evidence against
those candidates, not a proof that all processing without a learned model is
impossible.

The final **1072-test, zero-failure, nine-opt-in, zero-skip** gate verifies the
retained engineering and compatibility contracts. Separately, the unchanged
[frozen natural challenge](../scripts/experiments/upper-eyelid-natural-challenge/README.md)
returns **one test, two failures, zero skips and exit 1**: the restored model
admits one positive eye instead of two, then its source guard stops execution.
That red result is preserved outside the normal gate without an expected
failure or weakened oracle. Detailed scope and results are in
[QUALITY_SCORE](../QUALITY_SCORE.md).

### What the existing primary sources establish

| Source | Supported finding | Limit for this SDK |
| --- | --- | --- |
| [Apple Vision 2D landmarks](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) | `leftEye`, `rightEye`, `leftEyebrow`, and `rightEyebrow` locate 2D feature outlines. | These points bound an edit region; Apple does not label upper-lid fullness or supply a desired tissue surface. |
| [Belhumeur, Kriegman and Yuille, *The Bas-Relief Ambiguity* (1999)](https://www.cs.jhu.edu/~ayuille1/PubsJournal/J52BelhumeurKriegmanYuille99.pdf) | Under its stated orthographic, Lambertian and lighting assumptions, distinct shapes and reflectances can produce identical images. | This establishes a shape-from-shading ambiguity, not an impossibility theorem for every portrait or learned prior. A low-frequency luminance residual cannot by itself certify upper-lid volume. |
| [Guo et al., upper-eyelid 3D area and volume reliability (2023)](https://pubmed.ncbi.nlm.nih.gov/36915328/) | In 44 adults with 3D surface images, standardized area measurement was reliable, while direct single-3D-image volume measurement had poor intramethod reliability. | The study did **not** test this SDK or ordinary single 2D photos. It cautions against equating a 2D brightness score with measured volume. |
| [Durand and Dorsey, bilateral base/detail processing (2002)](https://people.csail.mit.edu/fredo/PUBLI/Siggraph2002/DurandBilateral.pdf) and [Paris, Hasinoff and Kautz, local Laplacian filters (2011)](https://people.csail.mit.edu/sparis/publi/2011/siggraph/) | Edge-aware tonal processing is designed to preserve detail and avoid halos near strong boundaries. | These are image-processing methods, not upper-lid effect validation. The rings observed in this SDK's generated output are a local finding; the papers only motivate an edge/artifact oracle and candidate design. |

Single-image shape/lighting ambiguity explains why a luminance score cannot
serve as its own anatomical ground truth. It does not establish that this
particular edit is impossible, nor does an edge-aware filtering method prove
that a candidate meets the frozen effect and artifact requirements. No new
data, training, model or weight work follows from this review.

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
