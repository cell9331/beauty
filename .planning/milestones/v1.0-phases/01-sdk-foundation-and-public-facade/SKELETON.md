# Walking Skeleton — Beauty SDK

**Phase:** 1
**Generated:** 2026-06-10

## Capability Proven End-to-End

A host-style Swift package test can `import BeautySDK`, create public SDK models, initialize `BeautyEngine`, call the no-op `process(...)` APIs, and receive SDK-created output or typed `BeautyError` values.

## Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Framework | Swift Package Manager package at `BeautySDK/` | Phase 1 success requires a local reusable SDK package. |
| Public boundary | Single facade product named `BeautySDK` | Host apps and Demo must not import internal targets. |
| Internal layout | `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, `BeautySDK` targets | Matches root architecture and keeps future modules split without multiple packages. |
| Processing proof | No-op copy/output path for `CVPixelBuffer` and `CIImage` | Proves integration and lifecycle before visual effects exist. |
| Test runner | XCTest via `swift test --package-path BeautySDK` | Native, package-local, and sufficient for foundation contracts. |
| Demo integration | Package-first; Demo Xcode wiring deferred unless low-risk | Phase 2 owns Demo integration shell; Phase 1 focuses on host-app-style package tests. |

## Stack Touched in Phase 1

- [ ] Project scaffold — `BeautySDK/Package.swift`, targets, source folders, tests.
- [ ] Public route — `BeautySDK` facade imports expose public SDK types.
- [ ] Data model — `BeautyParameters`, `BeautyPreset`, `BeautyConfiguration`, `BeautyResult`, `BeautyError`.
- [ ] Processing interaction — `BeautyEngine.process(...)` no-op output path.
- [ ] Local full-stack run command — `swift test --package-path BeautySDK`.

## Out of Scope (Deferred to Later Slices)

- SwiftUI Demo replacement and category UI.
- Camera/photo permission flows and AVFoundation input.
- Vision face detection implementation.
- Real render effects, LUTs, built-in preset registry, makeup, segmentation, body shaping, stickers, style effects, and video export.
- Commercial SDK distribution and binary packaging.

## Subsequent Slice Plan

- Phase 2: Demo imports only `BeautySDK` and shows the planned editor category skeleton.
- Phase 3: Demo sends realtime and still-image inputs through the SDK.
- Phase 4: SDK adds detection and coordinate safety.
- Phase 5: SDK adds filters, resource validation, and built-in presets.
- Phase 6: SDK adds core beauty effects.
- Phase 7: Demo becomes a complete QA surface.
