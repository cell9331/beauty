---
phase: 80
audit: hugging-face-upper-eyelid-training-data
date: 2026-08-25
status: no-admissible-production-dataset
download_disposition: metadata-only-no-portrait-download
---

# Hugging Face Upper-Eyelid Training-Data Audit

## Decision

No Hugging Face dataset found in the 2026-08-25 audit satisfies all four
admission requirements for the learned `去脂` path:

1. original/target pairs for upper-eyelid fullness reduction rather than a
   proxy such as eye opening, eye height, makeup, global grading, or generic
   face retouching;
2. positive, negative, and stress coverage with identity-disjoint splits;
3. explicit commercial ML-training and retouched-derivative rights for every
   underlying portrait; and
4. permission to redistribute the resulting compiled Core ML weights.

No portrait archive was downloaded. Public repository metadata, dataset cards,
file inventories, and upstream license statements were inspected without
placing third-party media in the repository or private evaluation bundle.

## Candidate disposition

| Candidate | What is available | License/provenance result | Semantic result | Disposition |
| --- | --- | --- | --- | --- |
| `SJTU-DENG-Lab/MirrorPPR47M` | Hugging Face reports 197,741 rows and about 523 GB; file names include eye height, width, position, and distance edits | Dataset card has no license metadata or usable grant | No upper-eyelid-fullness operation was found; eye-height and eye-position edits are prohibited proxies | Reject; do not download |
| `zhang118970/MMArt-PPR10k` | About 3.2 GB of PPR10K-derived global Lightroom images/instructions | Hugging Face shows `apache-2.0`, but the official PPR10K owner limits all dataset files and derived data to non-commercial research; the permissive tag cannot override upstream image terms | Global portrait tone/color retouch, not paired upper-eyelid fullness | Reject for production; do not download |
| Official PPR10K | 11,161 raw portraits with three expert global retouches and human-region masks | Explicitly non-commercial research only, including derived data | Useful retouching research, but no isolated fullness target | Research reference only |
| Official FFHQR / AutoRetouch | 70,000 FFHQ-derived original/retouched faces | Retouches are CC BY-NC-SA 4.0 and source portraits carry mixed individual licenses | Professional whole-face retouch, not isolated fullness | Research reference only |
| `cyberagent/FFHQ-Makeup` | 18,000 identities with synthetic makeup variants | CC BY-NC-SA 4.0; dataset card explicitly restricts commercial use | Makeup transfer, not fullness reduction | Reject |
| `youngdicey/face-eye-double-eyelids2` | 97 image/text rows | No license, provenance, consent, pairing, or intended-use grant in the dataset card | Double-eyelid examples are not before/after fullness targets | Reject |
| `lrzjason/EditPair` | 30 general edit pairs | No dataset license grant; source claims Unsplash and edited outputs claim a third-party mask editor | Listed edits are general attribute edits such as adding/removing sunglasses | Reject |
| `Phitran21/adaptive-photo-retouching-6style` | About 5.4 GB of source plus six global style outputs | `other`, gated, and explicitly asks downstream users to verify source rights | Global color styles, not local upper-eyelid structure | Reject |

## License-drift finding

The PPR10K mirror demonstrates why a Hugging Face license badge is not
sufficient evidence. Its `apache-2.0` dataset-card tag describes the mirror or
project surface, while the official data owner states that the portrait files
and derived data are non-commercial research only. Admission follows the most
restrictive applicable upstream portrait and derivative terms, not the mirror
badge.

MirrorPPR47M has the inverse problem: it is downloadable without login, but its
dataset card contains no license grant. Public accessibility is not permission
for commercial training or model redistribution.

## What these datasets may still do

Non-commercial datasets may inform offline literature comparison or a clearly
separated research-only experiment. They cannot contribute pixels, targets,
pretrained weights, or learned parameters to the production Core ML model.
Generated or synthetic pairs may test tensor plumbing and composition safety
only; they cannot satisfy genuine efficacy or release gates.

## Viable acquisition routes

The production path remains one of:

1. obtain a written commercial license from a dataset owner that covers source
   portraits, target retouches, ML training, derived weights, and SDK weight
   redistribution, then create isolated upper-eyelid targets;
2. commission an owned collection and target-authoring program with explicit
   subject, photographer, retoucher, derivative-model, and redistribution
   rights; or
3. license a commercial before/after portrait corpus and add a contractually
   owned upper-eyelid target-authoring pass.

The existing ten real portraits remain holdout evaluation evidence. Moving
them into training would require new training/derivative authorization and a
replacement unseen holdout.

## Sources inspected

- https://huggingface.co/datasets/SJTU-DENG-Lab/MirrorPPR47M
- https://github.com/SJTU-DENG-Lab/MirrorPPR
- https://huggingface.co/datasets/zhang118970/MMArt-PPR10k
- https://github.com/csjliang/PPR10K
- https://github.com/skylab-tech/ffhqr-dataset
- https://huggingface.co/datasets/cyberagent/FFHQ-Makeup
- https://huggingface.co/datasets/youngdicey/face-eye-double-eyelids2
- https://huggingface.co/datasets/lrzjason/EditPair
- https://huggingface.co/datasets/Phitran21/adaptive-photo-retouching-6style
