---
phase: 11-html-reference-baselines
status: passed
verified: 2026-08-25
score: 5/5 retained requirements reverified
scope: reduced-v1.2
---

# Phase 11 Verification — Historical Reverification

## Requirement evidence

| Requirement | Result | Evidence |
| --- | --- | --- |
| HTML-01 | passed | Verified archive restore contains the local Home HTML and required labels/states. |
| HTML-02 | passed | Verified archive restore contains the local Editor HTML and required labels/states. |
| HTML-03 | passed with accepted debt | Required DOM/state inventory is present. The retained first-screen capture has hero/action overlap and the sticky capture does not visibly show the documented bottom tabs; no later visual-QA phase was authorized. |
| HTML-04 | passed | Restored `offline-check.mjs` passes; static scan finds no remote resource, upload, analytics, form, or file-input behavior. |
| HTML-05 | passed with accepted debt | Three non-empty 390x844 PNGs are retained. The evidence description is corrected by this report to distinguish visible content from intended state. |

## Reproducible command shape

```bash
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
TMP_DIR=$(mktemp -d /tmp/beauty-v1.2-replay.XXXXXX)
python3 scripts/archive-legacy-ui.py restore --output archives/legacy-ui --destination "$TMP_DIR/legacy-ui"
node "$TMP_DIR/legacy-ui/meituxiuxiu/html/offline-check.mjs"
rg -n '复古胶片相机|拍一拍|图片美化|智能抠图|欧美闪光滤镜' "$TMP_DIR/legacy-ui/meituxiuxiu/html/home.html"
rg -n '背景保护|整体|3D塑颜|比例|脸型|眼睛|嘴唇|鼻子|眉毛|限免|Pro|OFF' "$TMP_DIR/legacy-ui/meituxiuxiu/html/editor.html"
test "$(stat -f %z .planning/evidence/v1.2/home-html-first-screen.png)" -gt 0
test "$(stat -f %z .planning/evidence/v1.2/home-html-sticky-state.png)" -gt 0
test "$(stat -f %z .planning/evidence/v1.2/editor-html-tool-panel.png)" -gt 0
```

The archive was never extracted into the repository. The package remains
historical UI evidence, not active SDK scope.
