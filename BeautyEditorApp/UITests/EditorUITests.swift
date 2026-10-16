import UIKit
import XCTest

@MainActor final class EditorUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testFirstFiveEyeReferenceSlidersTapDragNeutralAndRestoreIndependently() throws {
        try assertReferenceSliders(["eye.size", "eye.positionY", "eye.eyelidSize", "eye.length", "eye.spacing"],
                                      prefix: "eye-five-reference")
    }

    func testNextFiveEyeReferenceSlidersTapDragNeutralAndRestoreIndependently() throws {
        try assertReferenceSliders(["eye.lowerLid", "eye.tailLift", "eye.tilt", "eye.innerCorner", "eye.outerCorner"],
                                      prefix: "eye-next-five-reference")
    }

    func testIrisReferenceSliderTapDragNeutralAndRestore() throws {
        try assertReferenceSliders(["eye.irisSize"], prefix: "eye-iris-reference")
    }

    func testFaceCenteredReferenceSlidersTapDragAndRestore() throws {
        try assertReferenceSliders(["face.width", "face.chinLength", "face.chinPoint", "face.hairline"],
                                   prefix: "face-centered-reference", categoryName: "face")
    }

    func testFaceOneWayReferenceSlidersFillFromLeftAndUndoContinuousDrag() throws {
        let app = launchFixture()
        let slider = app.sliders["adjustment-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 8))
        let tools = app.scrollViews["tool-scroll"]
        func value() throws -> Float { try XCTUnwrap(Float(try XCTUnwrap(slider.value as? String))) }
        func point(_ x: CGFloat) -> XCUICoordinate { referencePoint(slider, position: x) }
        for id in ["face.contourSmooth", "face.vShape", "face.jawline"] {
            let tool = app.buttons["tool-" + id]
            for _ in 0..<12 {
                let viewport = tools.frame.intersection(app.windows.firstMatch.frame)
                if tool.exists && viewport.contains(CGPoint(x: tool.frame.midX, y: tool.frame.midY)) { break }
                let right = tool.exists && tool.frame.midX < tools.frame.minX
                tools.coordinate(withNormalizedOffset: CGVector(dx: right ? 0.35 : 0.65, dy: 0.5))
                    .press(forDuration: 0.2, thenDragTo: tools.coordinate(withNormalizedOffset:
                        CGVector(dx: right ? 0.65 : 0.35, dy: 0.5)))
            }
            XCTAssertTrue(tool.isHittable, id)
            tool.tap()
            XCTAssertEqual(try value(), 0, id)
            point(0).tap()
            XCTAssertEqual(try value(), 0, id)
            try assertReferenceThumbPixels(app, slider: slider, value: 0, unit: true)
            point(1).tap()
            XCTAssertEqual(try value(), 100, id)
            try assertReferenceThumbPixels(app, slider: slider, value: 100, unit: true)
            point(0.25).tap()
            let quarter = try value()
            XCTAssertGreaterThan(quarter, 15, id)
            XCTAssertLessThan(quarter, 35, id)
            try assertReferenceThumbPixels(app, slider: slider, value: quarter, unit: true)
            point(0.25).press(forDuration: 0.15, thenDragTo: point(0.75))
            let upper = try value()
            XCTAssertGreaterThan(upper, 65, id)
            app.buttons["undo"].tap()
            XCTAssertEqual(try value(), quarter, id)
            app.buttons["redo"].tap()
            XCTAssertEqual(try value(), upper, id)
            XCTAssertFalse(app.staticTexts["adjustment-value"].exists)
            XCTAssertTrue(app.buttons["confirm-editing"].isHittable)
            attach(app, id + "-one-way-reference-generated-input")
        }
    }

    func testDoubleChinToolsRemainGreyDisabledAndSilent() throws {
        let app = launchFixture()
        let slider = app.sliders["adjustment-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 8))
        let width = app.buttons["tool-face.width"]
        XCTAssertEqual(width.value as? String, "已选中")
        referencePoint(slider, position: 0.7).tap()
        let retained = try XCTUnwrap(slider.value as? String)
        XCTAssertGreaterThan(try XCTUnwrap(Float(retained)), 20)
        XCTAssertTrue(app.buttons["undo"].isEnabled)
        let redoWasEnabled = app.buttons["redo"].isEnabled
        let tools = app.scrollViews["tool-scroll"]
        for id in ["face.doubleChin", "face.doubleChinRefine"] {
            let button = app.buttons["tool-" + id]
            for _ in 0..<12 {
                let viewport = tools.frame.intersection(app.windows.firstMatch.frame)
                if button.exists && viewport.contains(CGPoint(x: button.frame.midX, y: button.frame.midY)) { break }
                let goesRight = button.exists && button.frame.midX < tools.frame.minX
                tools.coordinate(withNormalizedOffset: CGVector(dx: goesRight ? 0.35 : 0.65, dy: 0.5))
                    .press(forDuration: 0.2, thenDragTo: tools.coordinate(withNormalizedOffset:
                        CGVector(dx: goesRight ? 0.65 : 0.35, dy: 0.5)))
            }
            XCTAssertTrue(button.exists, id)
            let viewport = tools.frame.intersection(app.windows.firstMatch.frame)
            XCTAssertTrue(viewport.contains(CGPoint(x: button.frame.midX, y: button.frame.midY)), id)
            XCTAssertEqual(button.label, id == "face.doubleChinRefine" ? "去双下巴 Pro" : "去双下巴", id)
            XCTAssertFalse(button.isEnabled, id)
            XCTAssertEqual(button.value as? String, "未开放", id)
            button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            XCTAssertEqual(width.value as? String, "已选中", id)
            XCTAssertEqual(slider.value as? String, retained, id)
            XCTAssertTrue(app.buttons["undo"].isEnabled, id)
            XCTAssertEqual(app.buttons["redo"].isEnabled, redoWasEnabled, id)
            XCTAssertFalse(app.alerts.firstMatch.exists, id)
            attach(app, "disabled-" + id + "-generated-input")
        }
        app.buttons["undo"].tap()
        XCTAssertEqual(slider.value as? String, "0")
        app.buttons["redo"].tap()
        XCTAssertEqual(slider.value as? String, retained)
    }

    func testEyeToolsWithoutReferencesRemainGreyDisabledAndSilent() throws {
        let app = launchFixture()
        let slider = app.sliders["adjustment-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 8))
        let category = app.buttons["category-eye"]
        for _ in 0..<3 where !category.isHittable { app.scrollViews["category-scroll"].swipeLeft() }
        category.tap()
        let tools = app.scrollViews["tool-scroll"]
        func reveal(_ button: XCUIElement) {
            for _ in 0..<12 {
                let viewport = tools.frame.intersection(app.windows.firstMatch.frame)
                if button.exists && viewport.contains(CGPoint(x: button.frame.midX, y: button.frame.midY)) { return }
                let goesRight = button.exists && button.frame.midX < tools.frame.minX
                let start = tools.coordinate(withNormalizedOffset: CGVector(dx: goesRight ? 0.35 : 0.65, dy: 0.5))
                let end = tools.coordinate(withNormalizedOffset: CGVector(dx: goesRight ? 0.65 : 0.35, dy: 0.5))
                start.press(forDuration: 0.2, thenDragTo: end)
            }
            XCTFail("Disabled tool must remain visible in the toolbar")
        }
        let iris = app.buttons["tool-eye.irisSize"]
        reveal(iris)
        iris.tap()
        slider.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.5)).tap()
        let retained = slider.value as? String
        XCTAssertEqual(iris.value as? String, "已选中")
        XCTAssertTrue(app.buttons["undo"].isEnabled)
        let redoWasEnabled = app.buttons["redo"].isEnabled
        for id in ["eye.lidLift", "eye.gazeCorrection", "eye.symmetry", "eye.redness"] {
            let button = app.buttons["tool-" + id]
            reveal(button)
            XCTAssertFalse(button.isEnabled, id)
            XCTAssertEqual(button.value as? String, "未开放", id)
            button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            XCTAssertEqual(iris.value as? String, "已选中", id)
            XCTAssertEqual(slider.value as? String, retained, id)
            XCTAssertTrue(app.buttons["undo"].isEnabled, id)
            XCTAssertEqual(app.buttons["redo"].isEnabled, redoWasEnabled, id)
            XCTAssertFalse(app.alerts.firstMatch.exists, id)
            attach(app, "disabled-" + id + "-generated-input")
        }
        app.buttons["undo"].tap()
        XCTAssertEqual(slider.value as? String, "0")
    }

    private func assertReferenceSliders(_ controls: [String], prefix: String, categoryName: String = "eye") throws {
        let app = launchFixture()
        let slider = app.sliders["adjustment-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 8))
        let category = app.buttons["category-" + categoryName]
        for _ in 0..<3 where !category.isHittable { app.scrollViews["category-scroll"].swipeLeft() }
        XCTAssertTrue(category.isHittable)
        category.tap()
        func value() throws -> Float { try XCTUnwrap(Float(try XCTUnwrap(slider.value as? String))) }
        func point(_ x: CGFloat) -> XCUICoordinate { referencePoint(slider, position: x) }
        let toolScroll = app.scrollViews["tool-scroll"]
        func visible(_ tool: XCUIElement) -> Bool {
            guard tool.exists else { return false }
            let frame = tool.frame
            let viewport = toolScroll.frame.intersection(app.windows.firstMatch.frame)
            return !frame.isEmpty && viewport.contains(CGPoint(x: frame.midX, y: frame.midY))
        }
        func reveal(_ tool: XCUIElement) {
            // Fast swipes can overshoot a middle tool to the opposite side.
            // Use its actual position and short drags in either direction.
            for _ in 0..<12 {
                if visible(tool) { return }
                let goesRight = tool.exists && tool.frame.midX < toolScroll.frame.minX
                let start = toolScroll.coordinate(withNormalizedOffset: CGVector(dx: goesRight ? 0.35 : 0.65, dy: 0.5))
                let end = toolScroll.coordinate(withNormalizedOffset: CGVector(dx: goesRight ? 0.65 : 0.35, dy: 0.5))
                start.press(forDuration: 0.2, thenDragTo: end)
            }
            XCTAssertTrue(visible(tool), "tool must enter the visible toolbar")
        }
        var retained: [String: Float] = [:]
        for id in controls {
            let tool = app.buttons["tool-" + id]
            reveal(tool)
            XCTAssertTrue(tool.isHittable, id)
            tool.tap()
            XCTAssertEqual(try value(), 0, id)
            point(0).tap()
            XCTAssertEqual(try value(), -100, id)
            try assertReferenceThumbPixels(app, slider: slider, value: -100)
            XCTAssertFalse(app.staticTexts["adjustment-value"].exists, id)
            if id == controls.first { attach(app, prefix + "-left-generated-input") }
            point(1).tap()
            XCTAssertEqual(try value(), 100, id)
            try assertReferenceThumbPixels(app, slider: slider, value: 100)
            XCTAssertFalse(app.staticTexts["adjustment-value"].exists, id)
            if id == controls.first { attach(app, prefix + "-right-generated-input") }
            point(0.5).tap()
            XCTAssertEqual(try value(), 0, id)
            try assertReferenceThumbPixels(app, slider: slider, value: 0)
            if id == controls.first { attach(app, prefix + "-neutral-generated-input") }
            point(0.25).tap()
            let negative = try value()
            XCTAssertLessThan(negative, -40, id)
            point(0.25).press(forDuration: 0.15, thenDragTo: point(0.75))
            let positive = try value()
            XCTAssertGreaterThan(positive, 40, id)
            app.buttons["undo"].tap()
            XCTAssertEqual(try value(), negative, id)
            app.buttons["redo"].tap()
            XCTAssertEqual(try value(), positive, id)
            retained[id] = positive
            XCTAssertTrue(app.buttons["confirm-editing"].isHittable)
        }
        attach(app, prefix + "-last-drag-generated-input")
        for id in controls.reversed() {
            let tool = app.buttons["tool-" + id]
            reveal(tool)
            XCTAssertTrue(tool.isHittable, id)
            tool.tap()
            XCTAssertEqual(try value(), try XCTUnwrap(retained[id]), id)
        }
    }

    func testElevenEyeSlidersExposeBothDirectionsAndRemainReachable() throws {
        let app = launchFixture()
        let slider = app.sliders["adjustment-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 8))
        let category = app.buttons["category-eye"]
        for _ in 0..<3 where !category.isHittable { app.scrollViews["category-scroll"].swipeLeft() }
        XCTAssertTrue(category.isHittable)
        category.tap()
        XCTAssertEqual(slider.value as? String, "0")
        let controls = ["eye.size", "eye.positionY", "eye.eyelidSize", "eye.length", "eye.spacing",
                        "eye.irisSize", "eye.lowerLid", "eye.tailLift", "eye.tilt",
                        "eye.innerCorner", "eye.outerCorner"]
        for id in controls {
            let tool = app.buttons["tool-" + id]
            for _ in 0..<4 where !tool.isHittable { app.scrollViews["tool-scroll"].swipeLeft() }
            XCTAssertTrue(tool.isHittable, id)
            tool.tap()
            XCTAssertEqual(slider.value as? String, "0", id)
            slider.adjust(toNormalizedSliderPosition: 0.1)
            XCTAssertTrue((slider.value as? String)?.hasPrefix("-") == true, id)
            if id == "eye.size" { attach(app, "eye-size-negative-generated-input") }
            slider.adjust(toNormalizedSliderPosition: 0.9)
            XCTAssertFalse((slider.value as? String)?.hasPrefix("-") == true, id)
            XCTAssertTrue(app.buttons["undo"].isHittable)
            XCTAssertTrue(app.buttons["confirm-editing"].isHittable)
            if id == "eye.irisSize" { attach(app, "eye-iris-positive-generated-input") }
        }
        attach(app, "eye-corners-positive-generated-input")
        let selectedValue = slider.value as? String
        app.buttons["undo"].tap()
        XCTAssertTrue((slider.value as? String)?.hasPrefix("-") == true)
        app.buttons["redo"].tap()
        XCTAssertEqual(slider.value as? String, selectedValue)
    }

    func testSixNoseSlidersExposeBothDirectionsAndKeepBottomControlsReachable() throws {
        let app = launchFixture()
        XCTAssertTrue(app.sliders["adjustment-slider"].waitForExistence(timeout: 8))
        let categories = app.scrollViews["category-scroll"]
        categories.swipeLeft()
        let nose = app.buttons["category-nose"]
        XCTAssertTrue(nose.isHittable)
        nose.tap()
        XCTAssertTrue(app.buttons["tool-nose.size"].waitForExistence(timeout: 3))
        let slider = app.sliders["adjustment-slider"]
        for id in ["nose.size", "nose.lift", "nose.ala", "nose.root", "nose.bridge", "nose.tip"] {
            let tool = app.buttons["tool-" + id]
            if !tool.isHittable { app.scrollViews["tool-scroll"].swipeLeft() }
            XCTAssertTrue(tool.isHittable, id)
            tool.tap()
            slider.adjust(toNormalizedSliderPosition: 0.1)
            XCTAssertTrue((slider.value as? String)?.hasPrefix("-") == true, id)
            slider.adjust(toNormalizedSliderPosition: 0.9)
            XCTAssertFalse((slider.value as? String)?.hasPrefix("-") == true, id)
            XCTAssertTrue(app.buttons["undo"].isHittable)
        }
        attach(app, "nose-signed-positive")
        slider.adjust(toNormalizedSliderPosition: 0.1)
        attach(app, "nose-signed-negative")
    }

    func testSevenBrowToolsScrollAndVerticalSliderRestoreWithSafeBottomAction() throws {
        let app = launchFixture()
        let slider = app.sliders["adjustment-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 8))
        let windows = app.windows.containing(.slider, identifier: "adjustment-slider")
        XCTAssertEqual(windows.count, 1)
        let window = windows.firstMatch
        func value() throws -> Float { try XCTUnwrap(Float(try XCTUnwrap(slider.value as? String))) }
        @discardableResult func reveal(_ item: XCUIElement, in scroll: XCUIElement) -> Int {
            for attempt in 0..<12 {
                let viewport = scroll.frame.intersection(window.frame)
                if item.exists, !item.frame.isEmpty,
                   viewport.contains(CGPoint(x: item.frame.midX, y: item.frame.midY)), item.isHittable { return attempt }
                let goesRight = item.exists && item.frame.midX < scroll.frame.minX
                scroll.coordinate(withNormalizedOffset: CGVector(dx: goesRight ? 0.35 : 0.65, dy: 0.5))
                    .press(forDuration: 0.15, thenDragTo: scroll.coordinate(withNormalizedOffset:
                        CGVector(dx: goesRight ? 0.65 : 0.35, dy: 0.5)))
            }
            XCTFail("Requested brow/category control must enter its scroll viewport")
            return 12
        }
        let category = app.buttons["category-brow"]
        reveal(category, in: app.scrollViews["category-scroll"])
        category.tap()
        let tools = app.scrollViews["tool-scroll"]
        let thickness = app.buttons["tool-brow.thickness"]
        XCTAssertEqual(thickness.value as? String, "已选中", "Adding vertical movement preserves the existing default")
        // Brow controls use the ordinary native slider, independently of the
        // eye reference track/thumb geometry and its pixel oracle.
        slider.adjust(toNormalizedSliderPosition: 0.7)
        let retainedThickness = try value()
        XCTAssertGreaterThan(retainedThickness, 20)
        let peak = app.buttons["tool-brow.peak"]
        // Reveal the far end before selecting neighboring tools, whose
        // automatic centering could otherwise conceal a missing drag check.
        var toolbarDrags = reveal(peak, in: tools)
        peak.tap()
        XCTAssertEqual(peak.value as? String, "已选中")
        for id in ["brow.thickness", "brow.length", "brow.positionY", "brow.spacing",
                   "brow.innerSpacing", "brow.tilt", "brow.peak"] {
            let button = app.buttons["tool-" + id]
            toolbarDrags += reveal(button, in: tools)
            button.tap()
            XCTAssertEqual(button.value as? String, "已选中", id)
            if id != "brow.thickness" { XCTAssertEqual(try value(), 0, id + " keeps its independent neutral value") }
        }
        XCTAssertGreaterThan(toolbarDrags, 0, "The last brow tool must be reached by actual horizontal scrolling")
        XCTAssertTrue(peak.isHittable)
        XCTAssertEqual(peak.value as? String, "已选中")
        attach(app, "brow-seven-peak-generated-input-full-window")

        let vertical = app.buttons["tool-brow.positionY"]
        reveal(vertical, in: tools)
        vertical.tap()
        XCTAssertEqual(vertical.value as? String, "已选中")
        XCTAssertEqual(slider.label, "上下")
        XCTAssertEqual(try value(), 0)
        slider.adjust(toNormalizedSliderPosition: 0.8)
        let positive = try value()
        XCTAssertGreaterThan(positive, 30)
        slider.adjust(toNormalizedSliderPosition: 0.2)
        let negative = try value()
        XCTAssertLessThan(negative, -30)
        app.buttons["undo"].tap()
        XCTAssertEqual(try value(), positive, "Undo restores the selected vertical field")
        app.buttons["redo"].tap()
        XCTAssertEqual(try value(), negative)
        attach(app, "brow-positionY-selected-negative-generated-input-full-window")

        reveal(thickness, in: tools)
        thickness.tap()
        XCTAssertEqual(try value(), retainedThickness, "Vertical edits and history must preserve the thickness field")
        reveal(vertical, in: tools)
        vertical.tap()
        XCTAssertEqual(try value(), negative)
        // Ordinary UISlider AX adjustment is approximate. Close the loop on
        // the actual displayed value instead of treating normalized .5 as an
        // exact touch location. Keep the exact neutral assertion below.
        var neutralPosition: CGFloat = 0.5
        var lowerNeutralPosition: CGFloat?
        var upperNeutralPosition: CGFloat?
        var beforeNeutral = try value()
        for _ in 0..<8 {
            beforeNeutral = try value()
            slider.adjust(toNormalizedSliderPosition: neutralPosition)
            let observed = try value()
            if observed == 0 { break }
            if observed < 0 { lowerNeutralPosition = neutralPosition }
            else { upperNeutralPosition = neutralPosition }
            if let lower = lowerNeutralPosition, let upper = upperNeutralPosition {
                neutralPosition = (lower + upper) / 2
            } else {
                neutralPosition = min(1, max(0, neutralPosition - CGFloat(observed) / 200))
            }
        }
        XCTAssertEqual(try value(), 0, "Centered ordinary slider must request exact neutral")
        app.buttons["undo"].tap()
        XCTAssertEqual(try value(), beforeNeutral, "Undo restores the last native adjustment before exact neutral")
        app.buttons["redo"].tap()
        XCTAssertEqual(try value(), 0)
        XCTAssertEqual(vertical.value as? String, "已选中")

        let confirm = app.buttons["confirm-editing"]
        XCTAssertTrue(confirm.isHittable)
        XCTAssertTrue(window.frame.contains(confirm.frame), "The entire confirm hit area stays inside its actual app window")
        XCTAssertGreaterThanOrEqual(confirm.frame.width, 43)
        XCTAssertGreaterThanOrEqual(confirm.frame.height, 43)
        XCTAssertLessThan(confirm.frame.maxY, window.frame.maxY, "The bottom action leaves space below its complete hit area")
        // Full app captures retain the current container and Home Indicator;
        // they are generated fixtures, with no portrait or landmark payload.
        attach(app, "brow-positionY-selected-neutral-safe-bottom-generated-input-full-window")
        confirm.tap()
        XCTAssertTrue(app.buttons["resume-editing"].waitForExistence(timeout: 3), "The verified bottom action must respond to a real tap")
    }

    func testImportEntryPointsAndCancelPhotoPicker() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["import-photos"].waitForExistence(timeout: 5))
        app.buttons["import-photos"].tap()
        let cancel = app.buttons.matching(NSPredicate(format: "label == %@ OR label == %@", "Cancel", "取消")).firstMatch
        XCTAssertTrue(cancel.waitForExistence(timeout: 5))
        cancel.tap()
        XCTAssertTrue(app.buttons["import-files"].exists)
        attach(app, "empty-input")
    }

    func testEditingSliderScrollingUndoCancelAndExport() throws {
        let app = launchFixture()
        XCTAssertTrue(app.sliders["adjustment-slider"].waitForExistence(timeout: 8))
        attach(app, "face-start")
        let slider = app.sliders["adjustment-slider"]
        slider.adjust(toNormalizedSliderPosition: 0.75)
        XCTAssertTrue(app.buttons["undo"].isEnabled)
        let adjustedValue = slider.value as? String
        app.buttons["undo"].tap()
        XCTAssertNotEqual(slider.value as? String, adjustedValue)
        app.buttons["redo"].tap()
        XCTAssertEqual(slider.value as? String, adjustedValue)
        let compare = app.buttons["compare-original"]
        compare.press(forDuration: 1)
        XCTAssertEqual(compare.value as? String, "编辑效果")
        let tools = app.scrollViews["tool-scroll"]
        tools.swipeLeft()
        tools.swipeLeft()
        tools.swipeLeft()
        XCTAssertTrue(app.buttons["tool-face.hairline"].isHittable)
        app.buttons["tool-face.hairline"].tap()
        attach(app, "face-last-tool")

        app.buttons["category-mouth"].tap()
        XCTAssertTrue(app.buttons["tool-mouth.size"].waitForExistence(timeout: 3))
        slider.adjust(toNormalizedSliderPosition: 0.2)
        app.buttons["cancel-editing"].tap()
        app.buttons["放弃调整"].tap()
        XCTAssertTrue(app.buttons["resume-editing"].waitForExistence(timeout: 3))
        app.buttons["resume-editing"].tap()
        XCTAssertTrue(slider.waitForExistence(timeout: 3))
        app.buttons["confirm-editing"].tap()
        XCTAssertTrue(app.buttons["share-photo"].waitForExistence(timeout: 3))
        attach(app, "confirmed-export")
        app.buttons["share-photo"].tap()
        let sheet = app.otherElements["ActivityListView"]
        // The native activity controller varies by OS; the Close button is the common exit.
        let close = app.buttons["Close"].exists ? app.buttons["Close"] : app.buttons["关闭"]
        XCTAssertTrue(close.waitForExistence(timeout: 8) || sheet.exists)
        attach(app, "native-share")
        if close.exists { close.tap() }
        else { app.swipeDown() }
        app.buttons["save-photo"].tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.buttons.matching(NSPredicate(format:
            "label BEGINSWITH[cd] %@ OR label BEGINSWITH %@", "Allow", "允许")).firstMatch
        if allow.waitForExistence(timeout: 3) { allow.tap() }
        let saved = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "已保存到相册")).firstMatch
        XCTAssertTrue(saved.waitForExistence(timeout: 8))
        attach(app, "native-photos-saved")
        XCTAssertTrue(app.buttons["resume-editing"].waitForExistence(timeout: 3))
        app.buttons["resume-editing"].tap()
        app.buttons["replace-photo"].tap()
        app.buttons["选择另一张照片"].tap()
        XCTAssertTrue(app.buttons["replacement-files"].waitForExistence(timeout: 3))
        attach(app, "replacement-source-sheet")
        app.buttons["replacement-files"].tap()
        let fileCancel = app.buttons.matching(NSPredicate(format: "label == %@ OR label == %@", "Cancel", "取消")).firstMatch
        XCTAssertTrue(fileCancel.waitForExistence(timeout: 5))
        attach(app, "native-files-picker")
        fileCancel.tap()
        XCTAssertTrue(slider.waitForExistence(timeout: 3))
    }

    func testCategoryAndBackgroundFailureInteractions() throws {
        let app = launchFixture()
        XCTAssertTrue(app.sliders["adjustment-slider"].waitForExistence(timeout: 8))
        app.buttons["background-protection"].tap()
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 10))
        app.alerts.buttons["知道了"].tap()
        XCTAssertEqual(app.buttons["background-protection"].value as? String, "关闭")
        app.buttons["category-ratio"].tap()
        XCTAssertTrue(app.buttons["tool-ratio.forehead"].exists)
        attach(app, "ratio-tools")
        app.buttons["category-eye"].tap()
        let tools = app.scrollViews["tool-scroll"]
        tools.swipeLeft()
        XCTAssertFalse(app.buttons["tool-eye.fatRemoval"].isEnabled)
        XCTAssertFalse(app.alerts.firstMatch.exists)
        attach(app, "eye-suspended")
        app.scrollViews["category-scroll"].swipeLeft()
        app.buttons["category-nose"].tap()
        XCTAssertTrue(app.buttons["tool-nose.root"].exists)
        attach(app, "nose-tools")
        app.buttons["category-brow"].tap()
        XCTAssertTrue(app.buttons["tool-brow.innerSpacing"].exists)
        attach(app, "brow-tools")
    }

    func testSixCategoriesKeepWhiteSlidersAndBottomActionsReachable() throws {
        let app = launchFixture()
        let slider = app.sliders["adjustment-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 8))
        let categories = app.scrollViews["category-scroll"]
        let cases = [("face", "face.width", "face.hairline", false, true),
                     ("ratio", "ratio.headSize", "ratio.faceLength", true, false),
                     ("eye", "eye.size", "eye.lift", false, true),
                     ("mouth", "mouth.size", "mouth.teethWhitening", false, false),
                     ("nose", "nose.size", "nose.tip", false, false),
                     ("brow", "brow.thickness", "brow.peak", false, false)]
        func reveal(_ item: XCUIElement, in scroll: XCUIElement) {
            for _ in 0..<12 {
                if item.exists, scroll.frame.contains(CGPoint(x: item.frame.midX, y: item.frame.midY)), item.isHittable { return }
                let right = item.exists && item.frame.midX < scroll.frame.minX
                scroll.coordinate(withNormalizedOffset: CGVector(dx: right ? 0.35 : 0.65, dy: 0.5))
                    .press(forDuration: 0.15, thenDragTo: scroll.coordinate(withNormalizedOffset:
                        CGVector(dx: right ? 0.65 : 0.35, dy: 0.5)))
            }
            XCTAssertTrue(item.isHittable)
        }
        func value() throws -> Float { try XCTUnwrap(Float(try XCTUnwrap(slider.value as? String))) }
        for (category, firstID, lastID, unit, reference) in cases {
            let button = app.buttons["category-" + category]
            reveal(button, in: categories)
            button.tap()
            let tools = app.scrollViews["tool-scroll"]
            let first = app.buttons["tool-" + firstID]
            reveal(first, in: tools)
            first.tap()
            XCTAssertEqual(slider.frame.height, 44, accuracy: 1)
            if reference { referencePoint(slider, position: 0).tap() }
            else { slider.adjust(toNormalizedSliderPosition: 0) }
            XCTAssertEqual(try value(), unit ? 0 : -100, category)
            if reference { try assertReferenceThumbPixels(app, slider: slider, value: unit ? 0 : -100, unit: unit) }
            if reference { referencePoint(slider, position: 1).tap() }
            else { slider.adjust(toNormalizedSliderPosition: 1) }
            XCTAssertEqual(try value(), 100, category)
            if reference { try assertReferenceThumbPixels(app, slider: slider, value: 100, unit: unit) }
            if reference { referencePoint(slider, position: 0.25).tap() }
            else { slider.adjust(toNormalizedSliderPosition: 0.25) }
            let before = try value()
            let start = reference ? referencePoint(slider, position: 0.25)
                : slider.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.5))
            let end = reference ? referencePoint(slider, position: 0.75)
                : slider.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.5))
            start.press(forDuration: 0.15, thenDragTo: end)
            let after = try value()
            XCTAssertGreaterThan(after - before, 30, category)
            app.buttons["undo"].tap()
            XCTAssertEqual(try value(), before, category)
            app.buttons["redo"].tap()
            XCTAssertEqual(try value(), after, category)
            try assertSliderSurfaceIsWhite(app, slider: slider, reference: reference)
            let last = app.buttons["tool-" + lastID]
            reveal(last, in: tools)
            XCTAssertTrue(last.isHittable, category)
            last.tap()
            XCTAssertEqual(last.value as? String, "已选中", category)
            try assertSliderSurfaceIsWhite(app, slider: slider, reference: reference)
            XCTAssertTrue(app.buttons["cancel-editing"].isHittable, category)
            XCTAssertTrue(app.buttons["confirm-editing"].isHittable, category)
            attach(app, category + "-white-slider-last-tool-generated-input")
        }
        app.buttons["confirm-editing"].tap()
        XCTAssertTrue(app.buttons["resume-editing"].waitForExistence(timeout: 3))
        app.buttons["resume-editing"].tap()
        XCTAssertTrue(slider.waitForExistence(timeout: 3))
        try assertSliderSurfaceIsWhite(app, slider: slider)
        slider.adjust(toNormalizedSliderPosition: 0.75)
        app.buttons["cancel-editing"].tap()
        let discard = app.buttons["放弃调整"]
        XCTAssertTrue(discard.waitForExistence(timeout: 3))
        discard.tap()
        XCTAssertTrue(app.buttons["resume-editing"].waitForExistence(timeout: 3))
    }

    func testUnavailableEntriesRemainVisibleDisabledAndSilent() throws {
        let app = launchFixture()
        XCTAssertTrue(app.sliders["adjustment-slider"].waitForExistence(timeout: 8))
        let categories = app.scrollViews["category-scroll"]
        categories.swipeRight()
        for id in ["management", "sculpt"] {
            let button = app.buttons["category-" + id]
            XCTAssertTrue(button.exists)
            XCTAssertFalse(button.isEnabled)
            XCTAssertEqual(button.value as? String, "未开放")
            // Use the actual hit region to exercise a disabled entry.
            button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            XCTAssertFalse(app.alerts.firstMatch.exists)
        }
        attach(app, "disabled-categories-generated-input")
        categories.swipeLeft()
        app.buttons["category-eye"].tap()
        let tools = app.scrollViews["tool-scroll"]
        tools.swipeLeft()
        let suspended = app.buttons["tool-eye.fatRemoval"]
        XCTAssertTrue(suspended.exists)
        XCTAssertFalse(suspended.isEnabled)
        XCTAssertEqual(suspended.value as? String, "未开放")
        suspended.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertFalse(app.alerts.firstMatch.exists)
        XCTAssertFalse(app.staticTexts["photo-status"].exists)
        attach(app, "disabled-eye-entry-generated-input")
    }

    private func launchFixture() -> XCUIApplication {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 390, height: 584))
        let image = renderer.image { context in
            UIColor(red: 0.3, green: 0.35, blue: 0.4, alpha: 1).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 390, height: 584))
            UIColor(red: 0.5, green: 0.6, blue: 0.65, alpha: 1).setFill()
            context.fill(CGRect(x: 0, y: 250, width: 390, height: 334))
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("editor-generated-input.png")
        try! image.pngData()!.write(to: url)
        let app = XCUIApplication()
        app.launchEnvironment["BEAUTY_TEST_IMAGE"] = url.path
        app.launch()
        return app
    }
    #if BEAUTY_OWNER_PORTRAIT_CHECK
    func testOwnerFullRangeCombinationHasNoQuotaBannerAndRetainsSliders() throws {
        let app = XCUIApplication()
        app.launchEnvironment["BEAUTY_TEST_IMAGE"] = "/private/tmp/beauty-editor-owner-check.png"
        app.launch()
        let slider = app.sliders["adjustment-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 8))
        app.buttons["debug-toggle"].tap()
        let status = app.staticTexts["debug-status"]
        let ready = NSPredicate { object, _ in
            guard let element = object as? XCUIElement else { return false }
            return element.label.contains("当前 478点") && !element.label.contains("更新中")
                && element.label.range(of: #"图像 r(\d+) / 参数 r\1"#, options: .regularExpression) != nil
        }
        for (category, tool, position) in [("face", "face.width", 1.0),
                                           ("eye", "eye.innerCorner", 1.0),
                                           ("nose", "nose.ala", 1.0),
                                           ("mouth", "mouth.width", 0.0)] {
            let categoryButton = app.buttons["category-" + category]
            if !categoryButton.isHittable { app.scrollViews["category-scroll"].swipeLeft() }
            categoryButton.tap()
            let toolButton = app.buttons["tool-" + tool]
            for _ in 0..<4 where !toolButton.isHittable { app.scrollViews["tool-scroll"].swipeLeft() }
            toolButton.tap()
            slider.adjust(toNormalizedSliderPosition: position)
            expectation(for: ready, evaluatedWith: status)
            waitForExpectations(timeout: 10)
            XCTAssertTrue(status.label.contains("MediaPipe 478"))
            XCTAssertFalse(status.label.contains("combined_geometry_weakened"))
            XCTAssertFalse(status.label.contains("形变预算"))
            if app.staticTexts["photo-status"].exists {
                let message = app.staticTexts["photo-status"].label
                XCTAssertFalse(message.contains("上限") || message.contains("强度限制"))
            }
            XCTAssertFalse(app.alerts.firstMatch.exists)
        }
        XCTAssertTrue(status.label.contains("mouthWidth = -0.350"))
        XCTAssertTrue(status.label.contains("组合 4 项"))
        app.buttons["category-nose"].tap()
        XCTAssertTrue(NSPredicate(format: "value == %@", "100").evaluate(with: slider)
                      || (slider.value as? String)?.hasPrefix("100") == true)
        app.buttons["debug-toggle"].tap()
    }

    func testOwnerPortraitDebugNoseAndPreviousValueRetention() throws {
        let app = XCUIApplication()
        app.launchEnvironment["BEAUTY_TEST_IMAGE"] = "/private/tmp/beauty-editor-owner-check.png"
        app.launch()
        let slider = app.sliders["adjustment-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 8))
        slider.adjust(toNormalizedSliderPosition: 0.5)
        let oldValue = slider.value as? String
        app.buttons["debug-toggle"].tap()
        XCTAssertEqual(app.buttons["debug-toggle"].value as? String, "开启")
        let status = app.staticTexts["debug-status"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        let ready = NSPredicate { object, _ in
            guard let element = object as? XCUIElement else { return false }
            let label = element.label
            return label.contains("当前") && !label.contains("更新中")
                && label.range(of: #"图像 r(\d+) / 参数 r\1"#, options: .regularExpression) != nil
        }
        expectation(for: ready, evaluatedWith: status)
        waitForExpectations(timeout: 8)
        XCTAssertTrue(status.label.contains("MediaPipe 478"))
        XCTAssertTrue(status.label.contains("原图 478点"))
        XCTAssertTrue(status.label.contains("当前 478点"))
        XCTAssertFalse(status.label.contains("Vision"))
        app.scrollViews["category-scroll"].swipeLeft()
        app.buttons["category-nose"].tap()
        app.buttons["tool-nose.ala"].tap()
        slider.adjust(toNormalizedSliderPosition: 0.75)
        expectation(for: ready, evaluatedWith: status)
        waitForExpectations(timeout: 8)
        XCTAssertTrue(status.label.contains("noseWingSlim"))
        app.buttons["category-face"].tap()
        XCTAssertEqual(slider.value as? String, oldValue)
        app.buttons["debug-toggle"].tap()
        XCTAssertEqual(app.buttons["debug-toggle"].value as? String, "关闭")
        XCTAssertFalse(status.exists)
        // No portrait/landmark screenshot is retained as a permanent attachment.
    }
    func testOwnerPortraitEditorAndComparePreview() throws {
        let app = XCUIApplication()
        app.launchEnvironment["BEAUTY_TEST_IMAGE"] = "/private/tmp/beauty-editor-owner-check.png"
        app.launch()
        let slider = app.sliders["adjustment-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 8))
        slider.adjust(toNormalizedSliderPosition: 0.7)
        XCTAssertTrue(app.buttons["undo"].isEnabled)
        app.buttons["compare-original"].press(forDuration: 1)
        let status = app.staticTexts["photo-status"]
        XCTAssertNotEqual(status.label, "未获得可用人脸，相关调整保持原图。请试试清晰的正面人像。", status.label)
        attach(app, "owner-portrait-editor-preview")
    }
    #endif
    /// Position belongs to the visible track, whose centres are 12pt inset.
    /// An endpoint tap stays one point beyond that track, within the control,
    /// so device-pixel touch rounding still reaches the exact clamped value.
    private func referencePoint(_ slider: XCUIElement, position: CGFloat) -> XCUICoordinate {
        let frame = slider.frame
        let width = max(0, frame.width - 24)
        let offset: CGFloat = position <= 0 ? -1 : position >= 1 ? width + 1 : width * position
        return slider.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: 12 + offset, dy: frame.height / 2))
    }

    private func assertReferenceThumbPixels(_ app: XCUIApplication, slider: XCUIElement, value: Float, unit: Bool = false) throws {
        // Capture the same window whose global frame supplies the crop origin.
        // A full-display screenshot need not share an app window's bounds.
        let windows = app.windows.containing(.slider, identifier: "adjustment-slider")
        XCTAssertEqual(windows.count, 1, "Reference slider must have one owning window")
        let window = windows.firstMatch
        let screen = window.frame
        let image = try XCTUnwrap(window.screenshot().image.cgImage)
        XCTAssertGreaterThan(screen.width, 0)
        XCTAssertGreaterThan(screen.height, 0)
        let scaleX = CGFloat(image.width) / screen.width
        let scaleY = CGFloat(image.height) / screen.height
        XCTAssertEqual(scaleX, scaleY, accuracy: 0.01, "Window crop must preserve display aspect")
        let frame = slider.frame
        XCTAssertTrue(screen.contains(frame), "Reference control must remain inside its captured window")
        let fraction = unit ? value / 100 : (value + 100) / 200
        let center = CGPoint(x: frame.minX + 12 + (frame.width - 24) * CGFloat(fraction),
                             y: frame.midY)
        func pixel(_ point: CGPoint) throws -> [UInt8] {
            let sample = try XCTUnwrap(image.cropping(to: CGRect(x: ((point.x - screen.minX) * scaleX).rounded(.down),
                                                               y: ((point.y - screen.minY) * scaleY).rounded(.down),
                                                               width: 1, height: 1)))
            var rgba = [UInt8](repeating: 0, count: 4)
            try rgba.withUnsafeMutableBytes { bytes in
                let context = try XCTUnwrap(CGContext(data: bytes.baseAddress, width: 1, height: 1, bitsPerComponent: 8,
                                                      bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(),
                                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
                context.draw(sample, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            }
            return rgba
        }
        let origin: CGFloat = unit ? 0 : 0.5
        for position: CGFloat in [0.125, 0.25, 0.375, 0.625, 0.75, 0.875] {
            guard abs(position - CGFloat(fraction)) * (frame.width - 24) > 14,
                  unit || abs(position - 0.5) * (frame.width - 24) > 5 else { continue }
            let filled = position > min(origin, CGFloat(fraction)) && position < max(origin, CGFloat(fraction))
            let expected = filled ? [242, 61, 87] : [233, 234, 237]
            let rgba = try pixel(CGPoint(x: frame.minX + 12 + (frame.width - 24) * position, y: frame.midY))
            for channel in 0..<3 {
                XCTAssertLessThanOrEqual(abs(Int(rgba[channel]) - expected[channel]), 6,
                                         "Track must retain its accent fill and light grey inactive section; value=\(value), position=\(position)")
            }
        }
        for offset in [CGPoint(x: -8, y: 0), CGPoint(x: 8, y: 0),
                       CGPoint(x: 0, y: -8), CGPoint(x: 0, y: 8)] {
            let rgba = try pixel(CGPoint(x: center.x + offset.x, y: center.y + offset.y))
            for channel in 0..<3 { XCTAssertGreaterThan(rgba[channel], 245, "Reference thumb must be round and whole; value=\(value), point=\(center), offset=\(offset), slider=\(frame), window=\(screen), raster=\(image.width)x\(image.height)") }
        }
        for point in [CGPoint(x: center.x, y: center.y - 18),
                      CGPoint(x: center.x, y: center.y + 18),
                      CGPoint(x: frame.minX + 1, y: frame.midY),
                      CGPoint(x: frame.maxX - 1, y: frame.midY)] {
            let rgba = try pixel(point)
            for channel in 0..<3 { XCTAssertGreaterThan(rgba[channel], 245, "Slider band must stay white beyond the thumb shadow; value=\(value), point=\(point), frame=\(frame)") }
        }
    }

    private func assertSliderSurfaceIsWhite(_ app: XCUIApplication, slider: XCUIElement, reference: Bool = false) throws {
        let windows = app.windows.containing(.slider, identifier: "adjustment-slider")
        XCTAssertEqual(windows.count, 1)
        let window = windows.firstMatch
        let screen = window.frame
        let image = try XCTUnwrap(window.screenshot().image.cgImage)
        let scale = CGFloat(image.width) / screen.width
        let white = [255, 255, 255]
        var samples = [(CGPoint(x: slider.frame.midX, y: slider.frame.minY + 3), white),
                       (CGPoint(x: slider.frame.midX, y: slider.frame.maxY - 3), white),
                       (CGPoint(x: screen.minX + screen.width / 4, y: screen.maxY - 2), white)]
        if !reference {
            // Check the actual raster: UISlider's tint property alone cannot
            // detect a later SwiftUI environment override to system blue.
            for position: CGFloat in [0.125, 0.875] {
                samples.append((CGPoint(x: slider.frame.minX + slider.frame.width * position,
                                        y: slider.frame.midY), [233, 234, 237]))
            }
        }
        func pixel(_ point: CGPoint) throws -> [UInt8] {
            let sample = try XCTUnwrap(image.cropping(to: CGRect(x: ((point.x - screen.minX) * scale).rounded(.down),
                                                               y: ((point.y - screen.minY) * scale).rounded(.down),
                                                               width: 1, height: 1)))
            var rgba = [UInt8](repeating: 0, count: 4)
            try rgba.withUnsafeMutableBytes { bytes in
                let context = try XCTUnwrap(CGContext(data: bytes.baseAddress, width: 1, height: 1, bitsPerComponent: 8,
                                                      bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(),
                                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
                context.draw(sample, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            }
            return rgba
        }
        for (point, expected) in samples {
            // Native UISlider's alignment rectangle can place its 2pt raster
            // slightly off the accessibility frame's midline. Require the same
            // grey within that narrow band; a blue fill cannot satisfy it.
            let offsets: [CGFloat] = expected == white ? [0] : [0, -0.5, 0.5, -1, 1, -1.5, 1.5, -2, 2]
            let colors = try offsets.map { try pixel(CGPoint(x: point.x, y: point.y + $0)) }
            let rgba = try XCTUnwrap(colors.min { a, b in
                (0..<3).reduce(0) { $0 + abs(Int(a[$1]) - expected[$1]) }
                    < (0..<3).reduce(0) { $0 + abs(Int(b[$1]) - expected[$1]) }
            })
            for channel in 0..<3 {
                XCTAssertLessThanOrEqual(abs(Int(rgba[channel]) - expected[channel]), 6,
                                         "Slider surface/track and container bottom must retain their light palette at \(point)")
            }
        }
    }
    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
