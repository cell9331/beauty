---
phase: 11
slug: html-reference-baselines
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-25
---

# Phase 11 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Shell static scans plus browser screenshot capture |
| **Config file** | none - static local HTML files |
| **Quick run command** | `test -f meituxiuxiu/html/home.html && test -f meituxiuxiu/html/editor.html && test -f meituxiuxiu/html/styles.css` |
| **Full suite command** | `rg -n "https?://|@import|url\\((['\\\"]?)https?:|analytics|upload|fetch\\(|XMLHttpRequest|navigator\\.sendBeacon|<form|type=['\\\"]file" meituxiuxiu/html` should return no matches |
| **Estimated runtime** | static scans under 10 seconds; browser screenshots depend on local browser state |

## Sampling Rate

- **After 11-01:** Run file-existence checks for `README.md`, `styles.css`, and `.planning/evidence/v1.2/`.
- **After 11-02:** Run Home label/state scans for first screen, grid pages, recommendations, bottom tabs, and sticky state.
- **After 11-03:** Run Editor label/state scans for preview chrome, panel controls, category rails, badges, cancel, and confirm.
- **After 11-04:** Run offline scan, screenshot existence checks, and `git diff --check -- meituxiuxiu/html .planning/evidence/v1.2 .planning/phases/11-html-reference-baselines`.
- **Before `$gsd-verify-work`:** Re-run all static scans, confirm screenshots exist, and record browser/viewport commands in `README.md`.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 11-01-01 | 11-01 | 1 | HTML-04 | T-11-01 | Reference package defines local-only policy before rendered pages exist. | static | `test -f meituxiuxiu/html/README.md && test -f meituxiuxiu/html/styles.css && test -d .planning/evidence/v1.2` | W0 | pending |
| 11-02-01 | 11-02 | 2 | HTML-01, HTML-03, HTML-04 | T-11-02 | Home page is inspectable DOM/CSS and offline. | static/browser | `rg -n "复古胶片相机|拍一拍|图片美化|智能抠图|欧美闪光滤镜|home-sticky-state" meituxiuxiu/html/home.html meituxiuxiu/html/styles.css` | W0 | pending |
| 11-03-01 | 11-03 | 2 | HTML-02, HTML-03, HTML-04 | T-11-03 | Editor page is inspectable DOM/CSS and offline. | static/browser | `rg -n "背景保护|整体|3D塑颜|比例|脸型|眼睛|嘴唇|鼻子|眉毛|限免|Pro|OFF" meituxiuxiu/html/editor.html meituxiuxiu/html/styles.css` | W0 | pending |
| 11-04-01 | 11-04 | 3 | HTML-05 | T-11-04 | Browser evidence is captured without network dependencies. | static/browser | `test -f .planning/evidence/v1.2/home-html-first-screen.png && test -f .planning/evidence/v1.2/home-html-sticky-state.png && test -f .planning/evidence/v1.2/editor-html-tool-panel.png` | W0 | pending |
| 11-04-02 | 11-04 | 3 | HTML-04, HTML-05 | T-11-01 | Final offline scan proves no remote resources, upload, analytics, or hidden runtime service. | static | `rg -n "https?://|@import|url\\((['\\\"]?)https?:|analytics|upload|fetch\\(|XMLHttpRequest|navigator\\.sendBeacon|<form|type=['\\\"]file" meituxiuxiu/html` | W0 | pending |

## Wave 0 Requirements

- [x] Existing shell tooling and `rg` are enough for static scans.
- [x] Source screenshots and maps already exist under `meituxiuxiu/`.
- [x] Browser screenshot tool can be Playwright, Safari, or another local browser command, but exact command must be recorded.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Visual closeness to commercial reference | HTML-01, HTML-02, HTML-03 | Static scans cannot prove composition fidelity. | Open `home.html` and `editor.html` beside the source maps/screenshots and record accepted gaps in `README.md`. |
| Browser screenshot framing | HTML-05 | Browser availability and viewport tooling are environment-dependent. | Capture 390x844 or documented equivalent viewport screenshots and record command/viewport. |

## Validation Sign-Off

- [x] All planned tasks have automated verify coverage or an explicit manual-only reason.
- [x] Sampling continuity: no three consecutive tasks without automated verify.
- [x] Wave 0 covers existing tooling.
- [x] No watch-mode flags.
- [x] Feedback latency target documented.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** approved 2026-06-25
