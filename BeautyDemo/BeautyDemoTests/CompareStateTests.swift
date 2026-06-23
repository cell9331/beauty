import BeautySDK
import CoreVideo
import XCTest
@testable import BeautyDemo

final class CompareStateTests: XCTestCase {
    func testD10CompareLabelsToggleBetweenBeforeAndAfter() {
        var state = CompareState()

        XCTAssertEqual(state.display, .after)
        XCTAssertEqual(state.actionTitle, "Show Before")
        XCTAssertEqual(state.accessibilityValue, "Showing after")

        state.toggle()

        XCTAssertEqual(state.display, .before)
        XCTAssertEqual(state.actionTitle, "Show After")
        XCTAssertEqual(state.accessibilityValue, "Showing before")
    }

    func testD10PhotoCompareSelectsInputOrOutputOnly() throws {
        let snapshot = try makeImageSnapshot()
        var state = CompareState(display: .after)

        XCTAssertTrue(state.photoImage(from: snapshot) === snapshot.outputCGImage)

        state.toggle()

        XCTAssertTrue(state.photoImage(from: snapshot) === snapshot.inputCGImage)
    }

    func testD10CameraCompareSelectsInputOrOutputOnly() throws {
        let input = try makePixelBuffer()
        let output = try makePixelBuffer()
        let snapshot = CameraProcessingSnapshot(
            inputPixelBuffer: input,
            outputPixelBuffer: output,
            orientation: .right,
            timestamp: 4,
            parameters: .init(skinSmoothing: 0.4),
            extent: CGSize(width: 2, height: 2)
        )
        var state = CompareState(display: .after)

        XCTAssertTrue(state.cameraPixelBuffer(from: snapshot) === output)

        state.toggle()

        XCTAssertTrue(state.cameraPixelBuffer(from: snapshot) === input)
    }

    func testD10CompareTogglePreservesEditorSelectionAndParameters() {
        var state = CompareState()
        let parameters = BeautyParameters(skinSmoothing: 0.6, eyeSize: 0.2)

        let snapshot = CompareState.preservingEditorState(
            mode: .photo,
            category: .facialFeatures,
            subcategory: .nose,
            parameters: parameters,
            toggle: &state
        )

        XCTAssertEqual(state.display, .before)
        XCTAssertEqual(snapshot.mode, .photo)
        XCTAssertEqual(snapshot.category, .facialFeatures)
        XCTAssertEqual(snapshot.subcategory, .nose)
        XCTAssertEqual(snapshot.parameters, parameters)
    }

    func testD15DebugTogglePreservesEditorSelectionParametersAndCompareDisplay() {
        var debugState = PreviewDebugVisibilityState()
        let parameters = BeautyParameters(skinSmoothing: 0.6, eyeSize: 0.2)

        let snapshot = PreviewDebugVisibilityState.preservingEditorState(
            mode: .photo,
            category: .facialFeatures,
            subcategory: .nose,
            parameters: parameters,
            compareDisplay: .before,
            toggle: &debugState
        )

        XCTAssertTrue(debugState.isVisible)
        XCTAssertEqual(snapshot.mode, .photo)
        XCTAssertEqual(snapshot.category, .facialFeatures)
        XCTAssertEqual(snapshot.subcategory, .nose)
        XCTAssertEqual(snapshot.parameters, parameters)
        XCTAssertEqual(snapshot.compareDisplay, .before)
    }

    func testD11DebugToggleCopyAndAccessibilityValuesMatchContract() {
        var state = PreviewDebugVisibilityState()

        XCTAssertEqual(state.title, "Show Debug Details")
        XCTAssertEqual(state.accessibilityValue, "Debug details hidden")

        state.toggle()

        XCTAssertEqual(state.title, "Hide Debug Details")
        XCTAssertEqual(state.accessibilityValue, "Debug details visible")
    }

    func testD12PreviewDebugDetectionRowsUseRedactedSummaryOnly() {
        let summaries = [
            BeautyDetectionSummary.noFace,
            BeautyDetectionSummary(
                availability: .partial,
                reasons: [.missingLandmarks, .mappingFailed],
                faceCount: 2,
                usedFaceCount: 1,
                detectionDurationMs: 2.5,
                mappingDurationMs: 1.25
            ),
            BeautyDetectionSummary(
                availability: .lowConfidence,
                reasons: [.lowConfidenceFace],
                faceCount: 1,
                usedFaceCount: 0
            ),
            BeautyDetectionSummary(
                availability: .stale,
                reasons: [.staleDetection],
                faceCount: 1,
                usedFaceCount: 1
            )
        ]

        for summary in summaries {
            let state = PreviewDebugOverlayState(
                frameStatus: .photoLoaded,
                detection: DetectionDebugSummary(summary: summary),
                warningCount: 3,
                lastErrorCode: nil,
                statusText: DetectionStatusPresentation(summary: summary).statusText
            )
            let rows = Dictionary(uniqueKeysWithValues: state.rows.map { ($0.label, $0.value) })
            let rendered = state.renderedDebugDescription

            XCTAssertEqual(rows["Frame"], "photo loaded")
            XCTAssertEqual(rows["Detection"], summary.availability.rawValue)
            XCTAssertEqual(rows["Faces"], "\(summary.usedFaceCount)/\(summary.faceCount) used")
            XCTAssertEqual(rows["Warnings"], "3")
            XCTAssertTrue(Set(state.rows.map(\.label)).isSubset(of: PreviewDebugOverlayState.allowedRowLabels))
            XCTAssertFalse(rendered.contains("VN" + "FaceObservation"))
            XCTAssertFalse(rendered.contains("bounding" + "Box"))
            XCTAssertFalse(rendered.contains("land" + "mark"))
            XCTAssertFalse(rendered.contains("CGPoint"))
            XCTAssertFalse(rendered.contains("CGRect"))
            XCTAssertFalse(rendered.contains("NS" + "Error"))
            XCTAssertFalse(rendered.contains("/private" + "/var"))
            XCTAssertFalse(rendered.contains("http" + "://"))
            XCTAssertFalse(rendered.contains("https" + "://"))
        }
    }

    func testD14CameraPausedDebugStateUsesRedactedErrorCodeAndFriendlyStatus() throws {
        let snapshot = CameraProcessingSnapshot(
            inputPixelBuffer: try makePixelBuffer(),
            outputPixelBuffer: try makePixelBuffer(),
            orientation: .right,
            timestamp: 7,
            parameters: .init(skinSmoothing: 0.3),
            extent: CGSize(width: 2, height: 2),
            detectionSummary: .noFace,
            warningCount: 2
        )
        let state = try XCTUnwrap(
            PreviewDebugOverlayState.camera(
                .paused(
                    lastSnapshot: snapshot,
                    droppedFrameCount: 4,
                    warning: CameraProcessingState.processingPausedMessage
                )
            )
        )
        let rows = Dictionary(uniqueKeysWithValues: state.rows.map { ($0.label, $0.value) })

        XCTAssertEqual(rows["Frame"], "processing paused")
        XCTAssertEqual(rows["Warnings"], "2")
        XCTAssertEqual(rows["Last Error"], "processing_paused")
        XCTAssertEqual(rows["Status"], "Processing paused. Showing the last usable preview.")
        XCTAssertEqual(rows["Dropped Frames"], nil)
        XCTAssertFalse(state.renderedDebugDescription.contains("NS" + "Error"))
    }

    func testD14PhotoDebugStatesUseRedactedStatusAndWarningCounts() throws {
        let snapshot = try makeImageSnapshot(warningCount: 5)

        let loaded = try XCTUnwrap(PreviewDebugOverlayState.photo(.loaded(snapshot)))
        XCTAssertEqual(rowValue("Frame", in: loaded), "photo loaded")
        XCTAssertEqual(rowValue("Warnings", in: loaded), "5")

        let loading = try XCTUnwrap(PreviewDebugOverlayState.photo(.loading(previousSnapshot: snapshot)))
        XCTAssertEqual(rowValue("Frame", in: loading), "photo loading")
        XCTAssertEqual(rowValue("Status", in: loading), "Processing photo...")

        let failed = try XCTUnwrap(
            PreviewDebugOverlayState.photo(
                .failed(
                    previousSnapshot: snapshot,
                    message: PhotoProcessingState.decodeFailureText
                )
            )
        )
        XCTAssertEqual(rowValue("Frame", in: failed), "photo failed")
        XCTAssertEqual(rowValue("Last Error", in: failed), "photo_decode_failed")
        XCTAssertEqual(rowValue("Status", in: failed), "Could not read that photo. Choose another image.")
        XCTAssertFalse(failed.renderedDebugDescription.contains("/private" + "/var"))
    }

    private func rowValue(_ label: String, in state: PreviewDebugOverlayState) -> String? {
        state.rows.first { $0.label == label }?.value
    }

    private func makeImageSnapshot(warningCount: Int = 0) throws -> ImageProcessingSnapshot {
        let renderer = ImageDisplayRenderer()
        let input = DemoFixtures.photoFixtureImage()
        let output = DemoFixtures.photoFixtureImage()
            .cropped(to: CGRect(x: 0, y: 0, width: 3, height: 3))

        return ImageProcessingSnapshot(
            sourceKind: .fixture,
            sourceID: "compare",
            inputImage: input,
            outputImage: output,
            inputCGImage: try renderer.render(input),
            outputCGImage: try renderer.render(output),
            orientation: .up,
            parameters: .init(skinSmoothing: 0.2),
            warningCount: warningCount
        )
    }

    private func makePixelBuffer() throws -> CVPixelBuffer {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: 2,
            kCVPixelBufferHeightKey as String: 2,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            2,
            2,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }

        return pixelBuffer
    }
}
