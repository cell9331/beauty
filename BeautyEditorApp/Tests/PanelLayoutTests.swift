import SwiftUI
import XCTest
@testable import BeautyEditor

@MainActor final class PanelLayoutTests: XCTestCase {
    func testSliderTouchReleaseBridgeEmitsOnceForInsideAndOutside() {
        for reference in [false, true] {
            var began = 0
            var changes: [Float] = []
            var releases: [Float] = []
            var silentEnds = 0
            let parent = BeautySlider(toolID: "face.width", value: 0, range: .signed,
                                      enabled: true, title: "脸宽", referenceStyle: reference,
                                      onBegin: { began += 1 }, onChange: { changes.append($0) },
                                      onEnd: { silentEnds += 1 }, onRelease: { releases.append($0) })
            let coordinator = parent.makeCoordinator()
            let slider = DesignSlider(frame: CGRect(x: 0, y: 0, width: 280, height: 44))
            slider.minimumValue = -100
            slider.maximumValue = 100
            slider.referenceStyle = reference
            coordinator.install(on: slider)
            let terminalEvents: [UIControl.Event] = [.touchUpInside, .touchUpOutside]
            for (index, terminal) in terminalEvents.enumerated() {
                slider.sendActions(for: .touchDown)
                slider.sendActions(for: .touchDown)
                XCTAssertEqual(began, index + 1, "Duplicate down events must share one touch session")
                for value: Float in [-37.125, 0, 62.5] {
                    slider.value = value
                    slider.sendActions(for: .valueChanged)
                }
                XCTAssertEqual(releases.count, index, "Continuous changes must not emit release callbacks")
                XCTAssertEqual(silentEnds, 0, "An active touch must not be finalized before its release")
                slider.sendActions(for: terminal)
                // Both terminal events, or a duplicate event, still end only
                // the session established by the latest touch-down.
                slider.sendActions(for: .touchUpInside)
                slider.sendActions(for: .touchUpOutside)
                XCTAssertEqual(releases, Array(repeating: 62.5, count: index + 1))
                XCTAssertEqual(silentEnds, 0, "The release callback owns touch finalization")
            }
            XCTAssertEqual(changes, [-37.125, 0, 62.5, -37.125, 0, 62.5])
        }
    }

    func testSliderCancellationAndAccessibilityChangesDoNotEmitTouchRelease() {
        for reference in [false, true] {
            var releases: [Float] = []
            var changes = 0
            var silentEnds = 0
            let parent = BeautySlider(toolID: "eye.size", value: 0, range: .signed,
                                      enabled: true, title: "大小", referenceStyle: reference,
                                      onBegin: {}, onChange: { _ in changes += 1 },
                                      onEnd: { silentEnds += 1 }, onRelease: { releases.append($0) })
            let coordinator = parent.makeCoordinator()
            let slider = DesignSlider()
            slider.minimumValue = -100
            slider.maximumValue = 100
            slider.referenceStyle = reference
            coordinator.install(on: slider)
            slider.sendActions(for: .touchDown)
            slider.value = 25
            slider.sendActions(for: .valueChanged)
            let beforeCancel = silentEnds
            slider.sendActions(for: .touchCancel)
            XCTAssertEqual(silentEnds, beforeCancel + 1, "Cancellation must retain silent edit finalization")
            slider.sendActions(for: .touchUpInside)
            slider.sendActions(for: .touchUpOutside)
            XCTAssertTrue(releases.isEmpty)
            // No touch-down: these are non-touch value changes and the native
            // accessibility entry points, not a simulated finger release.
            slider.value = 40
            let beforeNonTouch = silentEnds
            slider.sendActions(for: .valueChanged)
            XCTAssertEqual(silentEnds, beforeNonTouch + 1)
            let beforeAccessibility = changes
            slider.accessibilityIncrement()
            slider.accessibilityDecrement()
            if reference {
                XCTAssertGreaterThan(changes, beforeAccessibility)
            }
            XCTAssertGreaterThan(silentEnds, beforeCancel + 1)
            slider.sendActions(for: .touchUpInside)
            XCTAssertTrue(releases.isEmpty)
        }
    }

    func testSliderTouchContextInvalidatesOnToolChangeDisableAndRemoval() {
        for reference in [false, true] {
            var releases: [Float] = []
            var changes: [Float] = []
            func parent(_ toolID: String, enabled: Bool = true) -> BeautySlider {
                BeautySlider(toolID: toolID, value: 0, range: .signed,
                             enabled: enabled, title: "大小", referenceStyle: reference,
                             onBegin: {}, onChange: { changes.append($0) }, onEnd: {},
                             onRelease: { releases.append($0) })
            }
            let initial = parent("eye.size")
            let coordinator = initial.makeCoordinator()
            let slider = DesignSlider()
            slider.maximumValue = 100
            slider.value = 25
            slider.referenceStyle = reference
            coordinator.install(on: slider)
            slider.sendActions(for: .touchDown)
            coordinator.update(parent: parent("eye.size"))
            slider.sendActions(for: .touchUpInside)
            XCTAssertEqual(releases, [25], "An ordinary view update must retain the current touch")

            slider.sendActions(for: .touchDown)
            coordinator.update(parent: parent("eye.length"))
            slider.value = 40
            slider.sendActions(for: .valueChanged)
            slider.sendActions(for: .touchDown)
            slider.sendActions(for: .valueChanged)
            XCTAssertTrue(changes.isEmpty, "An invalidated gesture must not change the newly selected tool")
            slider.sendActions(for: .touchUpInside)
            XCTAssertEqual(releases, [25], "A stale touch must not report the newly selected tool")
            slider.sendActions(for: .valueChanged)
            XCTAssertEqual(changes, [40], "Non-touch changes must resume after the discarded gesture ends")

            slider.sendActions(for: .touchDown)
            coordinator.update(parent: parent("eye.length", enabled: false))
            coordinator.update(parent: parent("eye.length"))
            slider.value = 60
            slider.sendActions(for: .valueChanged)
            XCTAssertEqual(changes, [40], "Re-enabling must keep discarding the unfinished gesture")
            slider.sendActions(for: .touchUpOutside)
            XCTAssertEqual(releases, [25], "Re-enabling must not revive a cancelled touch")

            slider.sendActions(for: .touchDown)
            slider.isEnabled = false
            slider.sendActions(for: .touchUpInside)
            slider.isEnabled = true
            slider.sendActions(for: .touchUpInside)
            XCTAssertEqual(releases, [25], "Disabled terminal events must consume the stale touch")

            slider.sendActions(for: .touchDown)
            BeautySlider.dismantleUIView(slider, coordinator: coordinator)
            slider.sendActions(for: .touchUpInside)
            XCTAssertEqual(releases, [25], "Removed controls must not report a later terminal event")
        }
    }

    func testSliderNativeEventBridgeUsesDefaultConsoleLoggerAndOneUndo() async throws {
        for toolID in ["face.width", "mouth.size"] {
            let model = EditorModel(renderer: FakeRenderer())
            model.importPhoto(TestImage.encoded())
            let deadline = Date().addingTimeInterval(5)
            while (model.photo == nil || model.isLoading), Date() < deadline {
                try await Task.sleep(for: .milliseconds(10))
            }
            XCTAssertNotNil(model.photo)
            XCTAssertFalse(model.controlsDisabled)
            let tool = try XCTUnwrap(ToolCatalog.find(toolID))
            model.selectCategory(tool.category)
            model.selectTool(tool)
            let parent = BeautySlider(toolID: toolID, value: model.value, range: tool.range,
                                      enabled: true, title: tool.title, referenceStyle: tool.usesReferenceSlider,
                                      onBegin: model.beginAdjustment, onChange: model.updateValue,
                                      onEnd: model.endAdjustment, onRelease: model.releaseSliderAdjustment)
            let coordinator = parent.makeCoordinator()
            let slider = DesignSlider(frame: CGRect(x: 0, y: 0, width: 280, height: 44))
            slider.minimumValue = tool.range.bounds.lowerBound
            slider.maximumValue = tool.range.bounds.upperBound
            slider.referenceStyle = tool.usesReferenceSlider
            coordinator.install(on: slider)
            slider.sendActions(for: .touchDown)
            for value: Float in [-25.5, 0, 37.125] {
                slider.value = value
                slider.sendActions(for: .valueChanged)
            }
            XCTAssertFalse(model.canUndo, "Continuous changes must remain one unfinished transaction")
            slider.sendActions(for: .touchUpInside)
            slider.sendActions(for: .touchUpOutside)
            XCTAssertEqual(model.value, 37.125, accuracy: 0.0001, toolID)
            XCTAssertTrue(model.canUndo)
            model.undo()
            XCTAssertEqual(model.value, 0, accuracy: 0.0001, toolID)
            XCTAssertFalse(model.canUndo, "One release must produce exactly one undo entry")
            XCTAssertTrue(model.canRedo)
            model.redo()
            XCTAssertEqual(model.value, 37.125, accuracy: 0.0001, toolID)
        }
    }

    func testFirstFiveReferenceTrackHasCenteredFillAndContinuousValues() throws {
        let slider = DesignSlider(frame: CGRect(x: 0, y: 0, width: 280, height: 44))
        slider.minimumValue = -100
        slider.maximumValue = 100
        slider.showsCenter = true
        slider.referenceEyeStyle = true
        XCTAssertEqual(slider.alignmentRectInsets, .zero)
        func layers() throws -> (CALayer, CALayer, CALayer) {
            let all = slider.layer.sublayers ?? []
            return (try XCTUnwrap(all.first { $0.name == "reference-eye-track" }),
                    try XCTUnwrap(all.first { $0.name == "reference-eye-fill" }),
                    try XCTUnwrap(all.first { $0.name == "slider-neutral-mark" }))
        }
        let track = slider.trackRect(forBounds: slider.bounds)
        XCTAssertEqual(track, CGRect(x: 12, y: 20.5, width: 256, height: 3))
        for value: Float in [-100, -37.125, 0, 37.125, 100] {
            slider.value = value
            slider.setNeedsLayout()
            slider.layoutIfNeeded()
            let (inactive, fill, neutral) = try layers()
            try assertColor(slider.backgroundColor?.cgColor, matches: .white)
            try assertColor(inactive.backgroundColor, matches: UIColor(red: 233/255, green: 234/255, blue: 237/255, alpha: 1))
            try assertColor(fill.backgroundColor, matches: UIColor(BeautyStyle.accent))
            try assertColor(neutral.backgroundColor, matches: UIColor(red: 181/255, green: 184/255, blue: 190/255, alpha: 1))
            let thumb = slider.thumbRect(forBounds: slider.bounds, trackRect: track, value: value)
            XCTAssertEqual(inactive.frame, track)
            XCTAssertEqual(neutral.frame, CGRect(x: 137, y: 19, width: 6, height: 6))
            XCTAssertEqual(fill.frame.minX, min(track.midX, thumb.midX), accuracy: 0.001)
            XCTAssertEqual(fill.frame.maxX, max(track.midX, thumb.midX), accuracy: 0.001)
            XCTAssertEqual(slider.referenceValue(at: thumb.midX), value, accuracy: 0.00002)
            let visible = try XCTUnwrap(slider.layer.sublayers?.first { $0.name == "reference-eye-thumb" })
            try assertColor(visible.backgroundColor, matches: .white)
            try assertColor(visible.borderColor, matches: UIColor(red: 233/255, green: 234/255, blue: 237/255, alpha: 1))
            XCTAssertEqual(visible.borderWidth, 1)
            XCTAssertEqual(visible.frame, CGRect(x: thumb.midX - 10, y: thumb.midY - 10, width: 20, height: 20))
            XCTAssertGreaterThanOrEqual(visible.frame.minX, slider.bounds.minX + 2)
            XCTAssertLessThanOrEqual(visible.frame.maxX, slider.bounds.maxX - 2)
        }
        XCTAssertEqual(slider.referenceValue(at: -20), -100)
        XCTAssertEqual(slider.referenceValue(at: 300), 100)
        slider.value = 37.125
        slider.accessibilityIncrement()
        XCTAssertEqual(slider.value, 38.125)
        slider.accessibilityDecrement()
        XCTAssertEqual(slider.value, 37.125)
        slider.referenceEyeStyle = false
        slider.setNeedsLayout()
        slider.layoutIfNeeded()
        let (inactive, fill, neutral) = try layers()
        XCTAssertTrue(inactive.isHidden)
        XCTAssertTrue(fill.isHidden)
        XCTAssertEqual(neutral.frame.size, CGSize(width: 2, height: 6))
        XCTAssertEqual(slider.trackRect(forBounds: slider.bounds).width, 280)
        try assertColor(slider.backgroundColor?.cgColor, matches: .white)
        try assertColor(slider.minimumTrackTintColor?.cgColor,
                        matches: UIColor(red: 233/255, green: 234/255, blue: 237/255, alpha: 1))
        try assertColor(slider.maximumTrackTintColor?.cgColor,
                        matches: UIColor(red: 233/255, green: 234/255, blue: 237/255, alpha: 1))
    }

    func testFaceReferenceTrackUsesItsActualNeutralForSignedAndOneWayValues() throws {
        let slider = DesignSlider(frame: CGRect(x: 0, y: 0, width: 280, height: 44))
        slider.referenceStyle = true
        for range in [ControlRange.signed, .unit] {
            slider.minimumValue = range.bounds.lowerBound
            slider.maximumValue = range.bounds.upperBound
            slider.showsCenter = range == .signed
            for value: Float in [range.bounds.lowerBound, 0, 25.125, 50, 100] {
                slider.value = value
                slider.setNeedsLayout()
                slider.layoutIfNeeded()
                let layers = slider.layer.sublayers ?? []
                let fill = try XCTUnwrap(layers.first { $0.name == "reference-eye-fill" })
                let neutral = try XCTUnwrap(layers.first { $0.name == "slider-neutral-mark" })
                let visible = try XCTUnwrap(layers.first { $0.name == "reference-eye-thumb" })
                let track = slider.trackRect(forBounds: slider.bounds)
                let thumb = slider.thumbRect(forBounds: slider.bounds, trackRect: track, value: value)
                let origin = range == .signed ? track.midX : track.minX
                XCTAssertEqual(fill.frame.minX, min(origin, thumb.midX), accuracy: 0.001)
                XCTAssertEqual(fill.frame.maxX, max(origin, thumb.midX), accuracy: 0.001)
                XCTAssertEqual(neutral.isHidden, range == .unit)
                XCTAssertEqual(visible.frame.width, 20)
                XCTAssertEqual(visible.frame.height, 20)
                XCTAssertGreaterThanOrEqual(visible.frame.minX, 2)
                XCTAssertLessThanOrEqual(visible.frame.maxX, slider.bounds.maxX - 2)
                XCTAssertEqual(slider.referenceValue(at: thumb.midX), value, accuracy: 0.00002)
            }
            XCTAssertEqual(slider.referenceValue(at: -20), range.bounds.lowerBound)
            XCTAssertEqual(slider.referenceValue(at: 300), 100)
        }
    }

    func testPanelUsesOneSafeAreaOwnerAndBackgroundReachesContainerBottom() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        model.importPhoto(TestImage.encoded())
        let deadline = Date().addingTimeInterval(5)
        while model.photo == nil, Date() < deadline { try await Task.sleep(for: .milliseconds(10)) }
        XCTAssertNotNil(model.photo)
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
        XCTAssertEqual(scenes.count, 1, "Tests require their single active host scene")
        let scene = try XCTUnwrap(scenes.first)
        let prior = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = UIHostingController(rootView: EditorScreen(model: model))
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
            prior?.makeKey()
        }
        try await settle(window)
        let slider = try XCTUnwrap(descendants(window).compactMap { $0 as? DesignSlider }.first)
        let frame = slider.convert(slider.bounds, to: window)
        let scopedWidth = slider.bounds.width
        let safeBottom = window.bounds.maxY - window.safeAreaInsets.bottom
        XCTAssertEqual(frame.height, 44, accuracy: 0.5)
        XCTAssertEqual(frame.minY, safeBottom - 184 + 2, accuracy: 1)
        XCTAssertLessThanOrEqual(frame.maxY, safeBottom)
        XCTAssertGreaterThanOrEqual(frame.minX, window.safeAreaInsets.left)
        attach(window, name: "native-face-panel-generated-input")
        model.selectCategory(.eye)
        try await settle(window)
        let eyeSlider = try XCTUnwrap(descendants(window).compactMap { $0 as? DesignSlider }.first)
        XCTAssertTrue(eyeSlider.showsCenter)
        XCTAssertTrue(eyeSlider.referenceEyeStyle)
        XCTAssertEqual(eyeSlider.minimumValue, -100)
        XCTAssertEqual(eyeSlider.maximumValue, 100)
        XCTAssertEqual(eyeSlider.value, 0)
        XCTAssertEqual(eyeSlider.convert(eyeSlider.bounds, to: window).minY, frame.minY, accuracy: 1)
        for value: Float in [-100, 0, 100] {
            model.beginAdjustment()
            model.updateValue(value)
            model.endAdjustment()
            try await settle(window)
            let eyeCapture = try XCTUnwrap(capture(window).cgImage)
            let captureScale = CGFloat(eyeCapture.width) / window.bounds.width
            let thumb = eyeSlider.thumbRect(forBounds: eyeSlider.bounds,
                                           trackRect: eyeSlider.trackRect(forBounds: eyeSlider.bounds), value: value)
            let center = CGPoint(x: thumb.midX, y: thumb.midY)
            func pixel(_ localPoint: CGPoint) throws -> Data {
                let point = eyeSlider.convert(localPoint, to: window)
                let sample = try XCTUnwrap(eyeCapture.cropping(to: CGRect(x: (point.x * captureScale).rounded(.down),
                                                                        y: (point.y * captureScale).rounded(.down),
                                                                        width: 1, height: 1)))
                return TestImage.pixels(sample)
            }
            // Native pixels verify white interiors; layer assertions above also
            // distinguish the 20pt grey-bordered circle from its white surface.
            for offset in [CGPoint(x: -8, y: 0), CGPoint(x: 8, y: 0),
                           CGPoint(x: 0, y: -8), CGPoint(x: 0, y: 8)] {
                let rgba = try pixel(CGPoint(x: center.x + offset.x, y: center.y + offset.y))
                for channel in 0..<3 { XCTAssertGreaterThan(rgba[channel], 245) }
            }
            for localPoint in [CGPoint(x: center.x, y: center.y - 18),
                               CGPoint(x: center.x, y: center.y + 18),
                               CGPoint(x: 1, y: eyeSlider.bounds.midY),
                               CGPoint(x: eyeSlider.bounds.maxX - 1, y: eyeSlider.bounds.midY)] {
                let rgba = try pixel(localPoint)
                for channel in 0..<3 {
                    XCTAssertGreaterThan(rgba[channel], 245,
                                      "value=\(value), local=\(localPoint), bounds=\(eyeSlider.bounds), frame=\(eyeSlider.convert(eyeSlider.bounds, to: window))")
                }
            }
            try assertReferenceTrackPixels(slider: eyeSlider, value: value, pixel: pixel)
        }
        model.beginAdjustment()
        model.updateValue(0)
        model.endAdjustment()
        try await settle(window)
        attach(window, name: "native-eye-centered-panel-generated-input")
        model.selectCategory(.mouth)
        try await settle(window)
        let mouthSlider = try XCTUnwrap(descendants(window).compactMap { $0 as? DesignSlider }.first)
        XCTAssertGreaterThan(mouthSlider.bounds.width, scopedWidth)
        model.confirmEditing()
        try await settle(window)
        XCTAssertTrue(descendants(window).compactMap { $0 as? DesignSlider }.isEmpty)
        attach(window, name: "native-review-panel-generated-input")
        model.resumeEditing()
        try await settle(window)
        let restored = try XCTUnwrap(descendants(window).compactMap { $0 as? DesignSlider }.first)
        XCTAssertEqual(restored.convert(restored.bounds, to: window).minY, frame.minY, accuracy: 1)
        let screenshot = capture(window)
        let cg = try XCTUnwrap(screenshot.cgImage)
        let x = cg.width / 4, y = cg.height - 3
        let sample = try XCTUnwrap(cg.cropping(to: CGRect(x: x, y: y, width: 1, height: 1)))
        let rgba = TestImage.pixels(sample)
        XCTAssertGreaterThan(rgba[0], 245)
        XCTAssertGreaterThan(rgba[1], 245)
        XCTAssertGreaterThan(rgba[2], 245)
        attach(window, name: "native-restored-panel-generated-input")
    }
    func testIrisReferencePanelRetainsCenteredPixelsAndSafeArea() async throws {
        let model = EditorModel(renderer: FakeRenderer())
        model.importPhoto(TestImage.encoded())
        let deadline = Date().addingTimeInterval(5)
        while model.photo == nil, Date() < deadline { try await Task.sleep(for: .milliseconds(10)) }
        XCTAssertNotNil(model.photo)
        let scene = try await singleActiveHostScene()
        let prior = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        window.frame = scene.coordinateSpace.bounds
        window.rootViewController = UIHostingController(rootView: EditorScreen(model: model))
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
            prior?.makeKey()
        }
        try await settle(window)
        let initialSlider = try XCTUnwrap(descendants(window).compactMap { $0 as? DesignSlider }.first)
        let initialFrame = initialSlider.convert(initialSlider.bounds, to: window)
        model.selectCategory(.eye)
        model.selectTool(try XCTUnwrap(ToolCatalog.find("eye.irisSize")))
        try await settle(window)
        let slider = try XCTUnwrap(descendants(window).compactMap { $0 as? DesignSlider }.first)
        XCTAssertTrue(slider.referenceEyeStyle)
        XCTAssertTrue(slider.showsCenter)
        XCTAssertTrue(slider.isEnabled)
        XCTAssertEqual(slider.minimumValue, -100)
        XCTAssertEqual(slider.maximumValue, 100)
        XCTAssertEqual(slider.value, 0)
        let frame = slider.convert(slider.bounds, to: window)
        XCTAssertEqual(frame.height, 44, accuracy: 0.5)
        XCTAssertEqual(frame.minY, initialFrame.minY, accuracy: 1)
        XCTAssertLessThanOrEqual(frame.maxY, window.bounds.maxY - window.safeAreaInsets.bottom)
        XCTAssertGreaterThanOrEqual(frame.minX, window.safeAreaInsets.left)
        XCTAssertLessThanOrEqual(frame.maxX, window.bounds.maxX - window.safeAreaInsets.right)
        for value: Float in [-100, 0, 100] {
            model.beginAdjustment()
            model.updateValue(value)
            model.endAdjustment()
            try await settle(window)
            XCTAssertEqual(slider.value, value, accuracy: 0.0001)
            let screenshot = try XCTUnwrap(capture(window).cgImage)
            let scale = CGFloat(screenshot.width) / window.bounds.width
            let thumb = slider.thumbRect(forBounds: slider.bounds,
                                         trackRect: slider.trackRect(forBounds: slider.bounds), value: value)
            func pixel(_ localPoint: CGPoint) throws -> Data {
                let point = slider.convert(localPoint, to: window)
                let sample = try XCTUnwrap(screenshot.cropping(to: CGRect(x: (point.x * scale).rounded(.down),
                                                                         y: (point.y * scale).rounded(.down),
                                                                         width: 1, height: 1)))
                return TestImage.pixels(sample)
            }
            for offset in [CGPoint(x: -8, y: 0), CGPoint(x: 8, y: 0),
                           CGPoint(x: 0, y: -8), CGPoint(x: 0, y: 8)] {
                let rgba = try pixel(CGPoint(x: thumb.midX + offset.x, y: thumb.midY + offset.y))
                for channel in 0..<3 { XCTAssertGreaterThan(rgba[channel], 245) }
            }
            for point in [CGPoint(x: 1, y: slider.bounds.midY),
                          CGPoint(x: slider.bounds.maxX - 1, y: slider.bounds.midY),
                          CGPoint(x: thumb.midX, y: thumb.midY - 18),
                          CGPoint(x: thumb.midX, y: thumb.midY + 18)] {
                let rgba = try pixel(point)
                for channel in 0..<3 { XCTAssertGreaterThan(rgba[channel], 245) }
            }
            try assertReferenceTrackPixels(slider: slider, value: value, pixel: pixel)
            let name = value < 0 ? "left" : value > 0 ? "right" : "neutral"
            attach(window, name: "native-iris-reference-" + name + "-generated-input")
        }
        let finalCapture = try XCTUnwrap(capture(window).cgImage)
        let bottomSample = try XCTUnwrap(finalCapture.cropping(to: CGRect(x: finalCapture.width / 4,
                                                                        y: finalCapture.height - 3,
                                                                        width: 1, height: 1)))
        let bottom = TestImage.pixels(bottomSample)
        for channel in 0..<3 { XCTAssertGreaterThan(bottom[channel], 245) }
    }

    private func assertColor(_ color: CGColor?, matches expected: UIColor,
                             file: StaticString = #filePath, line: UInt = #line) throws {
        let actual = UIColor(cgColor: try XCTUnwrap(color, file: file, line: line))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        var expectedRed: CGFloat = 0, expectedGreen: CGFloat = 0, expectedBlue: CGFloat = 0, expectedAlpha: CGFloat = 0
        XCTAssertTrue(actual.getRed(&red, green: &green, blue: &blue, alpha: &alpha), file: file, line: line)
        XCTAssertTrue(expected.getRed(&expectedRed, green: &expectedGreen, blue: &expectedBlue, alpha: &expectedAlpha), file: file, line: line)
        for (actual, expected) in zip([red, green, blue, alpha], [expectedRed, expectedGreen, expectedBlue, expectedAlpha]) {
            XCTAssertEqual(actual, expected, accuracy: 1/255, file: file, line: line)
        }
    }

    private func assertReferenceTrackPixels(slider: DesignSlider, value: Float,
                                           pixel: (CGPoint) throws -> Data) throws {
        let track = slider.trackRect(forBounds: slider.bounds)
        let fraction = CGFloat((value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue))
        let origin: CGFloat = slider.showsCenter ? 0.5 : 0
        for position: CGFloat in [0.125, 0.25, 0.375, 0.625, 0.75, 0.875] {
            guard abs(position - fraction) * track.width > 14,
                  !slider.showsCenter || abs(position - 0.5) * track.width > 5 else { continue }
            let filled = position > min(origin, fraction) && position < max(origin, fraction)
            let expected = filled ? [242, 61, 87] : [233, 234, 237]
            let rgba = try pixel(CGPoint(x: track.minX + track.width * position, y: track.midY))
            for channel in 0..<3 {
                XCTAssertLessThanOrEqual(abs(Int(rgba[channel]) - expected[channel]), 6,
                                         "value=\(value), track position=\(position), filled=\(filled)")
            }
        }
    }

    private func singleActiveHostScene() async throws -> UIWindowScene {
        // Device-hosted XCTest can start before SwiftUI finishes activating its
        // scene. Yield to that lifecycle instead of treating a launch command
        // or a fixed delay as proof that the host is ready.
        let deadline = ContinuousClock.now.advanced(by: .seconds(10))
        repeat {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
            if UIApplication.shared.applicationState == .active,
               scenes.count == 1,
               let scene = scenes.first,
               scene.windows.contains(where: \.isKeyWindow) {
                return scene
            }
            try await Task.sleep(for: .milliseconds(10))
        } while ContinuousClock.now < deadline

        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let states = scenes.map { $0.activationState.rawValue }.sorted()
        let active = scenes.filter { $0.activationState == .foregroundActive }
        let keyWindows = active.reduce(0) { $0 + $1.windows.filter(\.isKeyWindow).count }
        let status = "app=\(UIApplication.shared.applicationState.rawValue), "
            + "sceneStates=\(states), activeScenes=\(active.count), activeKeyWindows=\(keyWindows)"
        XCTFail("Host did not become active with exactly one active scene and its key window within 10 seconds; \(status)")
        throw NSError(domain: "PanelLayoutTests.HostNotReady", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: status])
    }

    private func settle(_ window: UIWindow) async throws {
        window.layoutIfNeeded()
        try await Task.sleep(for: .milliseconds(200))
        window.layoutIfNeeded()
    }
    private func descendants(_ view: UIView) -> [UIView] {
        [view] + view.subviews.flatMap(descendants)
    }
    private func capture(_ window: UIWindow) -> UIImage {
        UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
    }
    private func attach(_ window: UIWindow, name: String) {
        let attachment = XCTAttachment(image: capture(window))
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
