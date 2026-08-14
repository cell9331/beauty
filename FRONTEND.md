# FRONTEND.md

> Historical application/UI boundary and archive redirect. The active repository is
> SDK-only and uses SwiftPM plus SDK-owned command-line validation.

## Current Contract

The repository has no active frontend, application target, UI source, UI tests,
application navigation, camera permission flow, or visual acceptance surface.
Host applications own their UI and protected-resource lifecycle; SDK targets must
remain free of application pages and interaction state.

Current algorithm/control meanings are owned by
`docs/SDK_EFFECT_TAXONOMY.md`. Visual placement, labels, navigation, sliders,
badges, account state, and historical reference-product behavior do not establish
SDK support.

## Historical Material

The exact former Demo and legacy UI-reference trees are preserved as verified
artifacts under `archives/legacy-ui/`. Read `archives/legacy-ui/README.md` before
accessing them.

- `archives/legacy-ui/BeautyDemo-v1.16.zip` preserves 45 intentional files.
- `archives/legacy-ui/meituxiuxiu-v1.16.zip` preserves 26 intentional files.
- Each ZIP has a sorted path/size/content-hash manifest and a ZIP SHA-256 record.

Historical material is review-only. Restore it into a new temporary directory,
never over the active repository, and rerun:

```bash
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
```

Reintroducing either retired source root, any application project artifact, UI
framework source, or UI-test dependency violates the SDK-only boundary.

## Future UI Work

Any future application/UI work requires a separately authorized project or
milestone with its own product, security, reliability, and test owners. Historical
archives are not an active implementation template or acceptance contract.
