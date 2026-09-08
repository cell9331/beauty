---
phase: 92-signed-eyebrow-head-spacing
status: issues_found
reviewed_commit: c14719b
critical_count: 1
warning_count: 0
---

# Phase 92 Independent Code Review

## R4 dense-trace fold — HIGH, open

The independent reviewer inspected the provider, Testing SPI, provider tests,
registration tests and frozen public pixel oracle. The provider emits all
inner-half carriers (EyebrowWarpProvider.swift, pre-R5 lines 248–253), and the
CPU consumer adds their inverse fields. Existing admitted density16 input
produces eight overlapping fields with negative sampling Jacobian determinants
for both signs. Fixed minimum aggregates were -0.3061074/-0.1399804. Per-point
0.81r safety does not imply safety of their sum. No other actionable issue was
found; this is not approval to promote R4.

An independent feasibility check supports R5's fixed per-side 0.9 summed
norm/radius budget, with representable-source reconstruction and final bound
validation. Sparse density4/5 budgets are 0.598532/0.718151, dense16 is
2.095612, and frozen fixture side budgets are 0.752137/0.752139. Thus sparse
controls should be unchanged; this prediction still requires frozen pixels.
Cross-side supports overlap; no universal combined-field injectivity is claimed.

The retained regression ran against R4 before production editing: one test,
12 expected assertion failures, zero unexpected failures. It reproduces negative
finite-difference slopes and excess summed budgets on both dense-trace sides.

## Required disposition

Implement the reviewed provider-local R5 correction, pass the density/sign/
strength regression and unchanged actual-pixel gates, rerun affected compatibility,
and obtain independent implementation review before owner promotion. Preserve
historical failures and all frozen thresholds. No raw geometry, pixels, media,
private locators or probe transcripts are retained in this report.
