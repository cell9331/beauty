import UIKit
import XCTest

@MainActor final class MouthUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testEightMouthSlidersExposeBothDirectionsNeutralAndReachableControls() throws {
        let input = FileManager.default.temporaryDirectory.appendingPathComponent("mouth-ui-generated-input.png")
        defer { try? FileManager.default.removeItem(at: input) }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 390, height: 584))
        let image = renderer.image { context in
            UIColor(red: 0.3, green: 0.35, blue: 0.4, alpha: 1).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 390, height: 584))
        }
        try XCTUnwrap(image.pngData()).write(to: input)
        let app = XCUIApplication()
        app.launchEnvironment["BEAUTY_TEST_IMAGE"] = input.path
        app.launch()
        let slider = app.sliders["adjustment-slider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 8))
        let mouth = app.buttons["category-mouth"]
        if !mouth.isHittable { app.scrollViews["category-scroll"].swipeLeft() }
        XCTAssertTrue(mouth.isHittable)
        mouth.tap()
        for id in ["mouth.size", "mouth.width", "mouth.positionY", "mouth.tilt", "mouth.positionX",
                   "mouth.mShape", "mouth.fullness", "mouth.smile"] {
            let tool = app.buttons["tool-" + id]
            try revealAndTap(tool, in: app.scrollViews["tool-scroll"])
            XCTAssertEqual(try value(slider), 0, accuracy: 0.1, id)
            slider.adjust(toNormalizedSliderPosition: 0.1)
            XCTAssertLessThan(try value(slider), -50, id)
            XCTAssertTrue(app.buttons["undo"].isHittable, id)
            if id == "mouth.smile" { attach(app, "mouth-negative-generated-input") }
            slider.adjust(toNormalizedSliderPosition: 0.9)
            XCTAssertGreaterThan(try value(slider), 50, id)
            if id == "mouth.smile" { attach(app, "mouth-positive-generated-input") }
            app.buttons["more-actions"].tap()
            let reset = app.buttons["重置当前工具"]
            XCTAssertTrue(reset.waitForExistence(timeout: 3))
            reset.tap()
            let dismissed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: reset)
            XCTAssertEqual(XCTWaiter.wait(for: [dismissed], timeout: 3), .completed)
            XCTAssertEqual(try value(slider), 0, accuracy: 0.1, id)
        }
        let whitening = app.buttons["tool-mouth.teethWhitening"]
        try revealAndTap(whitening, in: app.scrollViews["tool-scroll"])
        slider.adjust(toNormalizedSliderPosition: 0)
        XCTAssertEqual(try value(slider), 0, accuracy: 0.1)
        slider.adjust(toNormalizedSliderPosition: 0.9)
        XCTAssertGreaterThan(try value(slider), 50)
        XCTAssertTrue(app.buttons["undo"].isHittable)
    }

    private func revealAndTap(_ tool: XCUIElement, in scroll: XCUIElement) throws {
        XCTAssertTrue(tool.waitForExistence(timeout: 3))
        // Menu dismissal can briefly report a visible tool as non-hittable.
        // Scroll only when its observed frame is outside the viewport, then wait
        // for accessibility to become ready before sending the tap.
        for _ in 0..<4 {
            let frame = tool.frame, viewport = scroll.frame.insetBy(dx: 2, dy: 0)
            if frame.minX < viewport.minX { scroll.swipeRight() }
            else if frame.maxX > viewport.maxX { scroll.swipeLeft() }
            else { break }
        }
        let ready = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true"), object: tool)
        XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: 3), .completed, tool.identifier)
        tool.tap()
    }

    private func value(_ slider: XCUIElement) throws -> Double {
        let raw = try XCTUnwrap(slider.value as? String)
        return try XCTUnwrap(Double(raw.trimmingCharacters(in: CharacterSet(charactersIn: "% "))))
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
