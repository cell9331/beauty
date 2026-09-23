---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-22T08:51:43Z
depth: standard
files_reviewed: 5
files_reviewed_list:
  - /tmp/beauty-root-mesh-lab/wheel-inventory.json
  - /tmp/beauty-root-mesh-lab/requirements.lock
  - /tmp/beauty-root-mesh-lab/generated-smoke.py
  - /tmp/beauty-root-mesh-lab/run-generated-smoke.py
  - /tmp/beauty-root-mesh-lab/runtime/pyvenv.cfg
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
source_registration_admission: false
portrait_acceptance: false
---

# Offline generated mesh runtime preflight

## Narrative Findings (AI reviewer)

No unresolved issue prevents the narrowly described owner-local, network-denied, generated-input CPU smoke run using the final reviewed wrapper and isolated runtime. This is a static/generated-protocol preflight, not a report that inference passed. The reviewer did not install dependencies, execute a model, access private images, or use the network.

### Resolved CR-01 — BLOCKER: the original environment inherited unpinned system packages

The earlier `/tmp/beauty-root-mesh-lab/venv/pyvenv.cfg` enabled system-site-packages. It could not substantiate isolation or exclusive use of the 18 locked distributions. The orchestrator replaced its intended execution environment with a separate `runtime` directory; the old environment remains unused for this smoke.

Independently checked final `runtime/pyvenv.cfg`: `include-system-site-packages = false`. Executed only its Python standard library with `-I`: isolation flag is 1, its sole site-packages directory is under `runtime`, and installed distribution names/versions exactly match the 18 locked packages. No third-party package or model was imported by this check.

### Resolved WR-01 — WARNING: wrapper accepted and forwarded an unvalidated JSON line

The original wrapper selected a line by its `{"cpu":` prefix, then printed its parsed contents without a schema check. This could forward arbitrary log fields or accept incorrect test counts. Final wrapper lines 16–28 reject duplicate keys, require the exact key set, strict value types and fixed values, and print a reconstructed fixed result. Parse/schema errors become a fixed reason.

Reviewer mocked the bounded child in memory without executing the model or child: one positive result accepted; 21 missing-field, wrong-value/type, extra-field, duplicate-key, malformed-JSON, duplicate-result and nonzero-exit cases rejected. The injected arbitrary field did not escape to output. Filesystem creation was mocked.

## Asset and installation checks

Independently read all 18 wheel archives. Each archive's actual SHA256, length, package name/version and CRC agree with the inventory and locked hashes. Archive member names are unique, relative and without parent traversal; none contains a `.pth` startup hook. This confirms the selected local bytes, not a vulnerability audit of every upstream component.

Independently compared 2,587 installed wheel payload files with their archive bytes, all equal. Generated installation bookkeeping was excluded. The sole non-site-package wheel payload not included in that comparison is the non-executable `ttx.1` manual page. The orchestrator performed installation; this reviewer made no installation changes.

The fixed task bundle is checked by size and complete SHA256 before third-party imports. Its contents/index correspondence remain limited to the earlier static index review; this smoke does not enlarge that conclusion.

## Bounded execution and observation

The final wrapper uses `sandbox-exec` with `(deny network*)`, the new runtime's Python with `-I`, and the previously reviewed owned-process-group bounded executor with a 90-second deadline and a 1 MiB combined output cap. The child checks the Python isolation flag and requires a loopback socket bind to fail with EPERM/EACCES before importing NumPy or MediaPipe. The sandbox policy supplies network denial; the probe checks that execution has not silently omitted it.

The smoke loads model bytes locally, explicitly selects CPU and IMAGE mode, disables blendshape/matrix output, and constructs only two sizes × three constant colors × two fresh detector contexts: 12 generated cases. It requires empty result collections and unchanged source arrays. No image path, camera, microphone or portrait input is requested. The optional dependency sounddevice is installed as part of the locked dependency graph, but this smoke contains no audio API call.

Raw combined child output stays in bounded memory; durable output consists of validated fixed success fields or fixed failure indicators/counts. Matplotlib's cache is directed into the temporary lab directory. Network sandboxing does not itself restrict all local file reads, so the no-private-input conclusion is grounded in the reviewed invocation and generated-only script, not a claimed filesystem sandbox.

Passing this smoke would establish only runtime mechanics and rejection of these no-face inputs. It would not demonstrate successful face inference, point accuracy, visible root registration, any portrait effect, or milestone completion.

## License scope

Read wheel metadata and bundled notices, including nested third-party notices. The package declarations include Apache-2.0, MIT variants, BSD variants, and matplotlib's permissive license. Flatbuffers lacks a standalone dist-info license but declares Apache-2.0 in both metadata and source headers. Preserve the supplied notices.

Top-level metadata is not a complete component license inventory. In particular NumPy, OpenCV, Pillow and matplotlib include additional notices, including GNU library/runtime or alternative-license texts. Their presence does not prohibit this local execution; the reviewed notices contain permission for use/running, and no restriction excluding this generated, owner-controlled research use was identified. The OpenCV notice occurrence of “non-commercial” explicitly permits both commercial and non-commercial use; it is not a research-only restriction. This conclusion does not approve redistribution, modified binary distribution, SDK packaging, patent clearance, or removal of notices.

The acquisition record identifies the official Face Mesh V2, BlazeFace Short Range and Blendshape V2 model cards and records their Apache-2.0 declarations. The first card and fixed bundle were examined in the prior asset work; the other two declarations are attributed here to the acquisition record, not represented as a fresh offline inspection of unavailable local cards. No training-data audit or per-image detector guarantee is inferred from those declarations. No further circular approval artifact is requested for this already bounded smoke.

## Final reviewed identities

| File | SHA256 |
| --- | --- |
| wheel-inventory.json (binds all 18 individually verified wheel hashes) | 5e0936d5b9f6fb07d95c9ed0d1a7944629bd33a0db419343e764ebe243b079ad |
| requirements.lock | f8ba252e0f40533ac46813c8b9e3e1964f84f6e9802aa5b09cea6a467b6381bb |
| generated-smoke.py | ffc309c653f937503b9943de4d7707a439b537d4d3fc70e8ea9d582cf21913ab |
| run-generated-smoke.py | 5bfa200df73608fb9a98c96018c73c9113524779be1930ee5ace91cc02a190b4 |
| runtime/pyvenv.cfg | 56fafd39da7d4e2ba020c040f26748b7c1909b331007dc9645191bdbae21d8fa |
| scripts/phase95-genuine-gate.py (bounded executor dependency) | c8b9834e802e295fa5601d001ec563d62c22875d315e626f8bc779d44b0d3ff1 |
| face_landmarker.task.partial (complete bundle despite filename) | 64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff |

Reviewer: independent gsd-code-review agent. No source/portrait approval JSON was created.
