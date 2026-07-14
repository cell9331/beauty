# Phase 22: Automated Demo QA and Screenshot Evidence - Pattern Map

**Mapped:** 2026-07-01
**Files analyzed:** 9 likely new/modified files
**Analogs found:** 8 / 9

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` | evidence ledger | batch | `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` + `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` | exact |
| `.planning/evidence/v1.4/home-first-screen.png` | evidence artifact | file-I/O | `.planning/evidence/v1.1/home-first-screen.png` referenced by `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` | exact |
| `.planning/evidence/v1.4/home-sticky-state.png` | evidence artifact | file-I/O | `.planning/evidence/v1.1/home-sticky-state.png` referenced by `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` | exact |
| `.planning/evidence/v1.4/editor-tool-panel.png` | evidence artifact | file-I/O | `.planning/evidence/v1.1/editor-tool-panel.png` referenced by `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` | exact |
| `.planning/evidence/v1.4/editor-camera-route.png` | evidence artifact | file-I/O | `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` launch-command pattern | role-match |
| `BeautyDemo/BeautyDemo/ContentView.swift` | component/route | request-response | `BeautyDemo/BeautyDemo/ContentView.swift` existing launch-argument hooks | exact |
| `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift` | app entry/provider | request-response | `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift` existing launch-time wiring | exact |
| `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` | test | request-response | `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` existing route/model honesty tests | exact |
| `.planning/evidence/v1.4/capture-demo-screenshots.sh` or similar optional helper | utility | file-I/O | No current shell helper exists; use command patterns from evidence docs instead | no analog |

## Pattern Assignments

### `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` (evidence ledger, batch)

**Analogs:** `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`, `.planning/evidence/v1.1/VISUAL-EVIDENCE.md`, `.planning/evidence/v1.2/VISUAL-EVIDENCE.md`

**Scope and status vocabulary pattern** (`21-BASELINE-AUDIT.md` lines 14-27):
```markdown
This artifact records the current v1.4 quality, verification, and technical-debt baseline before implementation changes. It distinguishes current command evidence from archived v1.3 evidence, local tooling blockers, not-attempted checks, and later-phase deferred work.

Status values:

- `passed`: command or scan ran now and passed.
- `failed`: command ran now and failed because of repo code, tests, or docs.
- `blocked`: command could not produce meaningful repo evidence because local tooling or hardware is missing.
- `not attempted`: intentionally not run in Phase 21.
- `deferred`: check belongs to a later v1.4 phase.
- `archived`: prior phase evidence cited as history, not current proof.
```

**Command inventory table pattern** (`21-BASELINE-AUDIT.md` lines 29-39):
```markdown
| Area | Status | Exact command | Evidence summary | Requirement / debt | Next step |
| --- | --- | --- | --- | --- | --- |
| Xcode toolchain | passed | `xcodebuild -version` | Xcode 26.6, build 17F113. | AUD-02 | Include this environment in Demo simulator blockers. |
| Xcode project inventory | passed | `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` | Resolved local `BeautySDK` package; listed targets `BeautyDemo`, `BeautyDemoTests`; listed schemes `BeautyDemo`, `BeautyExampleRenderer`, `BeautySDK`. | AUD-02 | Project/scheme discovery is available, but this alone is not Demo build/test proof. |
| Demo simulator build | blocked | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` | Command selected an explicit iPhone 17 / iOS 26.5 simulator and reached target build. It failed while compiling `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`: `cannot execute tool 'metal' due to missing Metal Toolchain; use: xcodebuild -downloadComponent MetalToolchain`. | AUD-02, TD-008 | Install the Xcode Metal Toolchain component, then rerun explicit-destination Demo build and test in Phase 22 or during local toolchain repair. |
```

**Blocker detail pattern** (`21-BASELINE-AUDIT.md` lines 41-50):
```markdown
Blocked gate: Demo simulator build/test evidence.

- Command attempted: `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build`
- Selected destination: iPhone 17, iOS 26.5 simulator.
- Environment: Xcode 26.6 build 17F113; Swift 6.3.3.
- Failure summary: `metal` tool could not execute because the local Xcode Metal Toolchain component is missing.
- Impact: Phase 21 cannot claim current Demo simulator build/test pass.
- Next step: run `xcodebuild -downloadComponent MetalToolchain` outside Phase 21 audit scope, then rerun Demo build/test in Phase 22 screenshot/QA work.
```

**Screenshot inventory pattern** (`.planning/evidence/v1.1/VISUAL-EVIDENCE.md` lines 7-13):
```markdown
| File | Coverage |
| --- | --- |
| `home-first-screen.png` | Home first screen: dark background, retro film hero, search/brand/VIP chrome, `拍一拍`, primary action cards, paged tool grid, recommendations, floating bottom tab. |
| `home-sticky-state.png` | Home scrolled state: sticky shortcut rail, recommendation sections moved upward, bottom tab fixed. Captured with `--beauty-demo-home-sticky` because this environment does not allow Simulator gesture automation through Accessibility. |
| `editor-tool-panel.png` | Editor tool panel: black preview area, centered brand capsule, white bottom panel, background protection toggle, shared slider, `整体`, second-level tool rail, first-level category rail, cancel/confirm controls. Captured with `--beauty-demo-route editor-beauty`. |
```

**Launch command pattern** (`.planning/evidence/v1.1/VISUAL-EVIDENCE.md` lines 17-30):
```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj \
  -scheme BeautyDemo \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun simctl launch <simulator-id> com.yakang.BeautyDemo

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun simctl launch <simulator-id> com.yakang.BeautyDemo --beauty-demo-home-sticky

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun simctl launch <simulator-id> com.yakang.BeautyDemo --beauty-demo-route editor-beauty
```

**File check pattern** (`.planning/evidence/v1.2/VISUAL-EVIDENCE.md` lines 36-42):
```markdown
## Screenshot File Checks

All three screenshots are non-empty PNG files at 390x844:

- `.planning/evidence/v1.2/home-html-first-screen.png`
- `.planning/evidence/v1.2/home-html-sticky-state.png`
- `.planning/evidence/v1.2/editor-html-tool-panel.png`
```

### `.planning/evidence/v1.4/*.png` (evidence artifacts, file-I/O)

**Analog:** `.planning/evidence/v1.1/VISUAL-EVIDENCE.md`

**Use this filename/coverage pattern** (`.planning/evidence/v1.1/VISUAL-EVIDENCE.md` lines 9-13):
```markdown
| File | Coverage |
| --- | --- |
| `home-first-screen.png` | Home first screen: dark background, retro film hero, search/brand/VIP chrome, `拍一拍`, primary action cards, paged tool grid, recommendations, floating bottom tab. |
| `home-sticky-state.png` | Home scrolled state: sticky shortcut rail, recommendation sections moved upward, bottom tab fixed. Captured with `--beauty-demo-home-sticky` because this environment does not allow Simulator gesture automation through Accessibility. |
| `editor-tool-panel.png` | Editor tool panel: black preview area, centered brand capsule, white bottom panel, background protection toggle, shared slider, `整体`, second-level tool rail, first-level category rail, cancel/confirm controls. Captured with `--beauty-demo-route editor-beauty`. |
```

**Planner note:** Phase 22 must only create PNGs after the app actually builds, installs, launches, and `xcrun simctl io <device> screenshot <path>` succeeds. If Metal Toolchain remains missing, create blocker records in `VISUAL-EVIDENCE.md` instead of empty or stale PNG files.

### `BeautyDemo/BeautyDemo/ContentView.swift` (component/route, request-response)

**Analog:** same file, existing route and launch-argument parsing.

**Imports pattern** (line 8):
```swift
import SwiftUI
```

**Route target enum pattern** (lines 10-24):
```swift
enum MeituEditorRouteTarget: Equatable, Sendable {
    case photo
    case camera
    case beauty

    var initialMode: EditorInputMode? {
        switch self {
        case .photo:
            .photo
        case .camera:
            .camera
        case .beauty:
            .photo
        }
    }
}
```

**View state injection pattern** (lines 27-46):
```swift
struct ContentView: View {
    @State private var editorRouteTarget: MeituEditorRouteTarget?
    private let initialHomeStickyPreview: Bool

    init(
        initialRouteTarget: MeituEditorRouteTarget? = nil,
        initialHomeStickyPreview: Bool = false
    ) {
        self.initialHomeStickyPreview = initialHomeStickyPreview
        self._editorRouteTarget = State(initialValue: initialRouteTarget)
    }

    var body: some View {
        if let editorRouteTarget {
            EditorShellView(initialMode: editorRouteTarget.initialMode)
        } else {
            MeituHomeView(initialStickyPreview: initialHomeStickyPreview) { route in
                editorRouteTarget = Self.routeTarget(for: route)
            }
        }
    }
```

**Disabled-route honesty pattern** (lines 49-59):
```swift
static func routeTarget(for route: MeituHomeRoute) -> MeituEditorRouteTarget? {
    switch route {
    case .photoEditor:
        .photo
    case .cameraEditor:
        .camera
    case .beautyEditor:
        .beauty
    case .disabled:
        nil
    }
}
```

**Launch-only QA argument pattern** (lines 62-82):
```swift
static func initialRouteTarget(arguments: [String] = ProcessInfo.processInfo.arguments) -> MeituEditorRouteTarget? {
    guard let routeIndex = arguments.firstIndex(of: "--beauty-demo-route"),
          arguments.indices.contains(routeIndex + 1) else {
        return nil
    }

    switch arguments[routeIndex + 1] {
    case "editor-photo":
        return .photo
    case "editor-camera":
        return .camera
    case "editor-beauty":
        return .beauty
    default:
        return nil
    }
}

static func initialHomeStickyPreview(arguments: [String] = ProcessInfo.processInfo.arguments) -> Bool {
    arguments.contains("--beauty-demo-home-sticky")
}
```

### `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift` (app entry/provider, request-response)

**Analog:** same file.

**Launch-time wiring pattern** (lines 1-12):
```swift
import SwiftUI

@main
struct BeautyDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                initialRouteTarget: ContentView.initialRouteTarget(),
                initialHomeStickyPreview: ContentView.initialHomeStickyPreview()
            )
        }
    }
}
```

### `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` (test, request-response)

**Analog:** same file.

**Imports pattern** (lines 1-3):
```swift
import BeautySDK
import XCTest
@testable import BeautyDemo
```

**Home route and launch-argument test pattern** (lines 30-45):
```swift
func testV11HomeRoutesOnlySupportedLocalFlows() {
    XCTAssertEqual(ContentView.routeTarget(for: .photoEditor), .photo)
    XCTAssertEqual(ContentView.routeTarget(for: .cameraEditor), .camera)
    XCTAssertEqual(ContentView.routeTarget(for: .beautyEditor), .beauty)
    XCTAssertNil(ContentView.routeTarget(for: .disabled))
    XCTAssertEqual(MeituEditorRouteTarget.photo.initialMode, .photo)
    XCTAssertEqual(MeituEditorRouteTarget.camera.initialMode, .camera)
    XCTAssertEqual(MeituEditorRouteTarget.beauty.initialMode, .photo)
    XCTAssertNil(ContentView.initialRouteTarget(arguments: ["BeautyDemo"]))
    XCTAssertEqual(
        ContentView.initialRouteTarget(arguments: ["BeautyDemo", "--beauty-demo-route", "editor-beauty"]),
        .beauty
    )
    XCTAssertFalse(ContentView.initialHomeStickyPreview(arguments: ["BeautyDemo"]))
    XCTAssertTrue(ContentView.initialHomeStickyPreview(arguments: ["BeautyDemo", "--beauty-demo-home-sticky"]))
}
```

**Editor taxonomy and disabled honesty test pattern** (lines 47-77):
```swift
func testV11EditorTaxonomyMatchesMeituFunctionReferenceOrder() {
    XCTAssertEqual(
        MeituEditorCategory.all.map(\.title),
        ["3D塑颜", "比例", "脸型", "眼睛", "嘴唇", "鼻子", "眉毛"]
    )
}

func testV11EditorSupportedToolMappingsAndDisabledHonesty() {
    let faceTools = MeituEditorCategory.category(id: .faceShape).tools
    let eyeTools = MeituEditorCategory.category(id: .eyes).tools
    let browTools = MeituEditorCategory.category(id: .eyebrows).tools

    XCTAssertEqual(faceTools.first { $0.title == "脸宽" }?.controlID, .faceSlim)
    XCTAssertEqual(eyeTools.first { $0.title == "大小" }?.controlID, .eyeSize)
    XCTAssertTrue(browTools.allSatisfy { !$0.isSupported })
    XCTAssertTrue(MeituEditorCategory.all.flatMap(\.tools).filter { !$0.isSupported }.allSatisfy {
        $0.unavailableReason?.contains("v1.1") == true
    })
}
```

**Unsupported slider write test pattern** (lines 79-113):
```swift
@MainActor
func testV11MeituPanelSliderWritesSupportedParameterOnly() {
    let store = BeautyParameterStore()
    var categoryID: MeituEditorCategoryID = .faceShape
    var toolID = "face.width"
    let supported = MeituEditorCategory.category(id: categoryID).tools.first { $0.id == toolID }!
    let unsupported = MeituEditorCategory.category(id: .faceShape).tools.first { $0.id == "face.smooth" }!

    store.setDisplayValue(36, for: supported.controlID!)
    XCTAssertEqual(store.displayValue(for: .faceSlim), 36, accuracy: 0.0001)

    let disabledState = MeituEditorToolPanelView.viewState(
        selectedCategoryID: categoryID,
        selectedToolID: unsupported.id,
        displayValue: 0,
        compareTitle: "对比",
        debugTitle: "调试"
    )
    XCTAssertFalse(disabledState.selectedTool.isSupported)
    XCTAssertNil(disabledState.selectedTool.controlID)
}
```

### Home and Editor Visual Surface Review Anchors

**Home sticky preview and scroll hook source:** `BeautyDemo/BeautyDemo/Home/MeituHomeView.swift`

**Sticky launch behavior pattern** (lines 39-53):
```swift
.onPreferenceChange(MeituHomeHeroOffsetPreferenceKey.self) { minY in
    if initialStickyPreview {
        showsStickyActions = true
    } else {
        showsStickyActions = minY < -320
    }
}
.onAppear {
    guard initialStickyPreview else {
        return
    }
    DispatchQueue.main.async {
        proxy.scrollTo("recommendations", anchor: .top)
    }
}
```

**Home disabled control pattern** (`MeituHomeView.swift` lines 248-272):
```swift
private func primaryActionButton(_ action: MeituHomeAction) -> some View {
    Button {
        onRoute(action.route)
    } label: {
        VStack(spacing: action.size == .large ? 9 : 8) {
            Image(systemName: action.systemImageName)
            Text(action.title)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .opacity(action.isEnabled ? 1 : 0.72)
    }
    .buttonStyle(.plain)
    .disabled(!action.isEnabled)
    .accessibilityLabel(action.title)
    .accessibilityHint(action.isEnabled ? "" : "v1.1 暂不支持")
}
```

**Sticky rail and bottom tab review pattern** (`MeituHomeView.swift` lines 394-470):
```swift
private var stickyShortcutRail: some View {
    HStack(spacing: 14) {
        Button {} label: {
            Image(systemName: "chevron.down")
                .frame(width: 35, height: 35)
        }
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(state.stickyActions) { action in
                    Button { onRoute(action.route) } label: { ... }
                        .disabled(!action.isEnabled)
                }
            }
        }
    }
    .background(Color.black.opacity(0.94))
}
```

**Editor shell bottom-panel integration pattern** (`EditorShellView.swift` lines 102-123):
```swift
var body: some View {
    ZStack(alignment: .bottom) {
        Color.black.ignoresSafeArea()

        VStack(spacing: 0) {
            editorTopBar
                .padding(.top, 52)
                .padding(.horizontal, 16)

            previewSurface
        }

        MeituEditorToolPanelView(
            selectedCategoryID: $selectedMeituCategoryID,
            selectedToolID: $selectedMeituToolID,
            parameterStore: parameterStore,
            compareTitle: compareState.display == .after ? "对比" : "原图",
            debugTitle: debugVisibilityState.isVisible ? "调试开" : "调试",
            onCancel: cancelEditorChanges,
            onConfirm: confirmEditorChanges
        )
    }
}
```

**Editor tool-panel disabled badge pattern** (`MeituEditorToolPanelView.swift` lines 138-189):
```swift
ForEach(state.selectedCategory.tools) { tool in
    Button {
        selectedToolID = tool.id
    } label: {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .strokeBorder(
                        tool.id == state.selectedTool.id ? Color(hex: 0xFF2F68) : Color(hex: 0x1F1F1F),
                        lineWidth: tool.id == state.selectedTool.id ? 3 : 2
                    )
                if let badge = tool.badge {
                    Text(badge.rawValue)
                } else if !tool.isSupported {
                    Text("OFF")
                }
            }
            Text(tool.title)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(width: 62, height: 75)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(tool.title)
    .accessibilityHint(tool.isSupported ? "" : (tool.unavailableReason ?? "v1.1 暂不支持"))
}
```

**Editor model unsupported truth pattern** (`MeituEditorToolModels.swift` lines 180-193):
```swift
private static func unsupported(
    _ id: String,
    title: String,
    icon: String,
    badge: MeituEditorToolBadge? = nil
) -> MeituEditorTool {
    MeituEditorTool(
        id: id,
        title: title,
        systemImageName: icon,
        badge: badge,
        controlID: nil,
        unavailableReason: "v1.1 暂未实现该美图参考功能"
    )
}
```

### `.planning/evidence/v1.4/capture-demo-screenshots.sh` or similar optional helper (utility, file-I/O)

**Analog:** No current shell helper exists in the codebase.

**Use command excerpts instead of inventing framework structure:**
- Build command from `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` lines 17-21.
- Launch commands from `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` lines 23-30.
- Evidence file-check habit from `.planning/evidence/v1.2/VISUAL-EVIDENCE.md` lines 36-42.

**Planner note:** If a helper is added, keep it evidence-local and tiny. It should run explicit `xcodebuild`, `xcrun simctl boot/install/launch/io screenshot`, terminate between states, and print exact commands/paths. No XCUITest harness, baseline diff system, or long-lived framework pattern exists in current source.

## Shared Patterns

### Launch Argument Routing
**Source:** `BeautyDemo/BeautyDemo/ContentView.swift` lines 62-82  
**Apply to:** `ContentView.swift`, `BeautyDemoApp.swift`, view-state tests, screenshot launch commands
```swift
static func initialRouteTarget(arguments: [String] = ProcessInfo.processInfo.arguments) -> MeituEditorRouteTarget? {
    guard let routeIndex = arguments.firstIndex(of: "--beauty-demo-route"),
          arguments.indices.contains(routeIndex + 1) else {
        return nil
    }

    switch arguments[routeIndex + 1] {
    case "editor-photo":
        return .photo
    case "editor-camera":
        return .camera
    case "editor-beauty":
        return .beauty
    default:
        return nil
    }
}
```

### Disabled Honesty
**Sources:** `MeituHomeModels.swift` lines 31-45, `MeituEditorToolModels.swift` lines 33-35 and 180-193, `BeautyDemoViewStateTests.swift` lines 62-77  
**Apply to:** Home screenshot review, editor screenshot review, QA-04 tests
```swift
var isEnabled: Bool {
    route != .disabled
}

var isSupported: Bool {
    controlID != nil
}
```

### Explicit Destination Verification
**Source:** `AGENTS.md` lines 99-111 and `21-BASELINE-AUDIT.md` lines 36-39  
**Apply to:** all Demo build/test/screenshot evidence
```bash
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build
```

### Bundle Identifier for `simctl launch`
**Source:** `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` lines 355 and 388  
**Apply to:** simulator launch commands
```text
PRODUCT_BUNDLE_IDENTIFIER = com.yakang.BeautyDemo;
```

### Archived Evidence Is Background Only
**Source:** `.planning/evidence/v1.1/VISUAL-EVIDENCE.md` lines 1-13 and `.planning/evidence/v1.2/VISUAL-EVIDENCE.md` lines 1-14  
**Apply to:** `VISUAL-EVIDENCE.md`, plan acceptance, review notes
```markdown
| `home-first-screen.png` | Home first screen: dark background, retro film hero, search/brand/VIP chrome, `拍一拍`, primary action cards, paged tool grid, recommendations, floating bottom tab. |
| `editor-html-tool-panel.png` | Editor preview chrome and white bottom panel with `背景保护`, compare, slider, `整体`, second-level tool rail, category rail, badges, cancel, and confirm. |
```

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `.planning/evidence/v1.4/capture-demo-screenshots.sh` or similar optional helper | utility | file-I/O | No shell helper or QA capture framework exists. Phase artifacts explicitly prefer existing launch hooks plus `simctl` commands and defer broad automation. |

## Metadata

**Analog search scope:** `BeautyDemo/BeautyDemo`, `BeautyDemo/BeautyDemoTests`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `.planning/evidence`, `.planning/phases/21-baseline-audit-and-quality-ledger-refresh`, root docs.  
**Files scanned:** 19 primary files plus targeted `rg` matches.  
**Pattern extraction date:** 2026-07-01
