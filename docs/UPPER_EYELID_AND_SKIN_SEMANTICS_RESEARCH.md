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
