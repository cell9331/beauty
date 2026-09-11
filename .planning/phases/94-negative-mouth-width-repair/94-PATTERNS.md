# Phase 94: Negative Mouth-Width Repair — Pattern Map

**Mapped:** 2026-09-11. Scope: mapping only; no additional research or runtime evidence.
**Disposition:** registration prerequisite unresolved; no fixed candidate, radius, displacement or anatomy selected.
Paths below are repository-relative. Proposed test paths are under `BeautySDK/Tests/`; source paths under `BeautySDK/Sources/`.

## File Classification

| New/modified file (proposed unless existing) | Role | Data flow | Closest tracked analog | Quality |
|---|---|---|---|---|
| `BeautyCoreTests/MouthRepairFixture.swift` | utility | transform | `BeautyCoreTests/NoseRepairFixture.swift` | role-match; mouth anatomy absent |
| `BeautyCoreTests/MouthFixtureRegistrationTests.swift` | test | request-response | `BeautyCoreTests/NoseFixtureRegistrationTests.swift` | exact structure |
| `BeautyCoreTests/MouthSemanticMetricTests.swift` | test/utility | transform | `BeautyCoreTests/NoseSemanticMetricTests.swift` | role-match; metric differs |
| `BeautyCoreTests/BeautyEngineMouthWidthRepairTests.swift` | test | request-response | `BeautyCoreTests/BeautyEngineNoseRepairTests.swift` | exact lifecycle structure |
| `scripts/check-phase94-mouth-repair.py` | utility | batch/file-I/O | `scripts/check-phase93-nose-repair.py` | role-match; admission differs |
| `BeautySDK/BeautyEngineTestingSupport.swift` (existing, conditional addition) | provider | request-response | same file, Phase93 fixture cases at 210–211, 259–288 | role-match; checked-plan prerequisite |
| `BeautyEffectsTests/MouthRepairFieldTests.swift` (candidate-gated) | test | transform | `BeautyEffectsTests/NoseRepairFieldTests.swift` | role-match; discovery only |
| `BeautyEffects/Warp/MouthWarpProvider.swift` (existing, conditional) | service | transform | existing private `widthPoints` | existing repair site; no selected replacement |
| `BeautyEffectsTests/MouthWarpProviderTests.swift` (existing) | test | transform | same file, retained tests at 44, 60, 111, 325, 420 | existing regression anchors |

Nine implementation/test/gate files classified; five primary analogs extracted below. Conditional rows do not authorize edits. `MissingLandmarkDegradationTests.swift` is retained regression coverage; manifest, comparator, adapter and sampler are read-only authorities, not proposed repair files. Affected owner synchronization belongs to later implementation/closeout.

## Pattern Assignments

### Registration fixture and test

**Sources:** `BeautySDK/Tests/BeautyCoreTests/NoseRepairFixture.swift:26–30,77–85`; `BeautySDK/Tests/BeautyCoreTests/NoseFixtureRegistrationTests.swift:11–183`.
Signature excerpts (opening braces retained; bodies intentionally omitted):
```swift
static func metadata() -> BeautyInputMetadata {
static func source() -> [UInt8] {
static func image() throws -> CIImage {
static func sourceFrame() throws -> BeautyFrame {
func testSourceAnatomyRegistersIndependently() throws {
```
Aggregate assertion, registration test line 183:
```swift
XCTAssertTrue(provider.invocationCount == 1 && result.observations.count == 1, "one actual detector mapping")
```
Reuse source-owned carrier construction, actual detector mapping, adapter comparison, literal raster membership and missing/canonical counterexamples. Imports use module names, `@testable import BeautyEffects` and `@_spi(Testing) import BeautySDK` (registration lines 1–8). Carrier admission uses typed errors; assertions use fixed messages.
Author mouth anatomy independently before observation/adapter/ROI comparison. Do not copy nose drawing coordinates, candidate envelopes or adapter-derived anatomy. Additive Testing SPI must be explicitly covered by the checked plan; existing fixtures remain unchanged. Registration plus retained-positive feasibility must pass before scoring/production mutation; terminal failure stops for disposition.

### Checked-integer mouth metric

**Source:** `BeautySDK/Tests/BeautyCoreTests/NoseSemanticMetricTests.swift:7,110–166,205–253,290–421`.
Signature excerpts:
```swift
static func add(_ a: Int64, _ b: Int64) throws -> Int64 {
static func subtract(_ a: Int64, _ b: Int64) throws -> Int64 {
static func multiply(_ a: Int64, _ b: Int64) throws -> Int64 {
static func normalizedCentroidQ16(weightedX: Int64, weight: Int64, width: Int64) throws -> Int64 {
func testSemanticConjunctionRejectsProxyOnlyChanges() throws {
```
Reuse checked Int64 arithmetic, typed dimension/region/denominator/overflow/comparison rejection, exact-boundary and one-short aggregate mutations. Keep oracle independent of production; imports are Foundation/XCTest.
Adapt to the frozen mouth comparator: sorted corner-centroid span, candidate-minus-reference **≤ -16 Q16**, never nose-root negation. Preserve all five comparisons, source/neutral target minima, every sibling distinction, all protection predicates, floor/floor exclusive bounds, tolerance and watermark clipping. Add separate full-region watermark protection on generated inputs. Handcrafted oracle controls establish arithmetic only.

### Public facade lifecycle and compatibility

**Source:** `BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift:32–170,176–219,227–325`.
Signature excerpts:
```swift
func testNoseNeutralMetadataOrientationAndDeterminism() throws {
func testNoseMissingSupportIsSourceExact() throws {
func testNoseValidInvalidValidRecoveryIsRedacted() throws {
```
Aggregate assertions, lines 318 and 324:
```swift
XCTAssertTrue(result.detectionSummary?.reasons == expectedReasons, "exact expected typed reasons")
XCTAssertTrue(result.metrics.values.allSatisfy(\.isFinite), "finite aggregate metadata")
```
Reuse public `processResult`, independent declared metadata expectations, explicit named-sRGB extraction, neutral identity, alpha/extent, cap/repeat equality, orientation/mirror and recovery structure. Emitting raw geometry expects Device RGB; inactive source retains its metadata (DESIGN.md:320). Extend required mouth coverage, including nonzero origin; wrapper orientation agreement alone is not semantic contraction proof. Freeze positive/signed-size/sibling digests before mutation. Typed reason enums are allowed statuses; free-text diagnostics remain separately screened.

### Bounded phase gate

**Source:** `scripts/check-phase93-nose-repair.py:19–84,158–194,574–634,767–838`.
Signature excerpts:
```python
def discover(output, methods):
def classify(output, code, method, allowed=(), required=()):
def admit_begin(events, attempt):
def admit_child(code, output, timed_out=False, overflow=False, residue=False):
```
Reuse exact-once nonzero discovery, zero skips, explicit failure categories, bounded memory-only pipe capture, process-group cleanup, hash-bound receipts and append-only attempt history. Derive finite child/whole-lane deadlines including cold build; `scripts/check-phase93-timeout-recovery.py:22` is a workload-budget example, not a transferable timeout.
Replace Phase93 admission: Phase94 registration/oracle/lifecycle/baseline freeze precedes the first production mutation. Never copy old-root RED admission, adapter-edit permission, amendment exceptions, fixed counts, receipts or candidate values. Enforce one research pass and at most two substantive attempts; rollback cannot reset the budget. Same-candidate scoped gates, independent review and goal verification precede acceptance.

## Shared Patterns / No Analog Found

Owner-local code needs no new auth layer. Share typed fail-closed admission, fixed-message Boolean assertions and bounded aggregate/hash evidence; keep all image/support data request-local. No raw geometry, pixels, private locators or child transcripts belong in this map or future durable receipts.
No established mouth-anatomy fixture or validated negative-width replacement was found by the prerequisite research. The five analogs provide structure only; A1/A2 remain unresolved. Candidate field tests must follow the eventual checked candidate and actual sampler semantics, preserving positive/sibling regressions. Phase95 closeout remains separate.

## Metadata

Search scope: tracked SDK source/tests and Phase93 scripts via `git ls-files`/`rg`; five primary analogs inspected, ancillary anchors discovered. Validation: text/source mapping only; no native tests, production/test/state edits or attempts. This file is the sole write.
