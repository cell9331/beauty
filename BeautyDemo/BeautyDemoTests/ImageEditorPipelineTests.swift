import BeautySDK
import CoreImage
import ImageIO
import XCTest
@testable import BeautyDemo

@MainActor
final class ImageEditorPipelineTests: XCTestCase {
    func testPIPE04FixtureInputProcessesThroughPublicSDKImagePath() async throws {
        let pipeline = ImageEditorPipeline()
        let parameters = BeautyParameters(skinSmoothing: 0.35)

        pipeline.process(
            input: .fixture(id: "fixture", image: Self.testImage(red: 0.2)),
            parameters: parameters
        )
        await pipeline.waitUntilIdle()

        let snapshot = try XCTUnwrap(pipeline.state.latestSnapshot)
        XCTAssertEqual(snapshot.sourceKind, .fixture)
        XCTAssertEqual(snapshot.sourceID, "fixture")
        XCTAssertEqual(snapshot.orientation, .up)
        XCTAssertEqual(snapshot.metadata.source, .photo)
        XCTAssertFalse(snapshot.metadata.isInputMirrored)
        XCTAssertFalse(snapshot.metadata.isPreviewMirrored)
        XCTAssertNil(snapshot.metadata.timestamp)
        XCTAssertEqual(snapshot.parameters, parameters)
        XCTAssertEqual(snapshot.outputImage.extent, snapshot.inputImage.extent)
        XCTAssertEqual(snapshot.outputCGImage.width, 2)
        XCTAssertEqual(snapshot.outputCGImage.height, 2)
    }

    func testPIPE04PhotosPickerDataSeamUsesDecodedImageAndProcessor() async throws {
        let records = LockedPhotoValues<ImageInputKind>()
        let decoder = ImageInputDecoder { source in
            records.append(source.kind)
            return DecodedImageInput(
                source: source,
                image: Self.testImage(red: 0.4),
                metadata: source.metadata
            )
        }
        let processor = StillImageProcessor { image, _, _ in
            BeautyResult(output: image, detectionSummary: .notRun)
        }
        let pipeline = ImageEditorPipeline(decoder: decoder, processor: processor)

        pipeline.process(
            input: .photosPickerData(Data([1, 2, 3]), id: "picker-data"),
            parameters: .init(skinSmoothing: 0.2)
        )
        await pipeline.waitUntilIdle()

        let snapshot = try XCTUnwrap(pipeline.state.latestSnapshot)
        XCTAssertEqual(records.values, [.photosPickerData])
        XCTAssertEqual(snapshot.sourceKind, .photosPickerData)
        XCTAssertEqual(snapshot.sourceID, "picker-data")
        XCTAssertEqual(snapshot.metadata.source, .photo)
        XCTAssertEqual(snapshot.detectionSummary, .notRun)
    }

    func testD08CancellationIsNoopAndShowsNoError() async throws {
        let pipeline = ImageEditorPipeline()
        pipeline.process(input: .fixture(id: "existing", image: Self.testImage(red: 0.1)), parameters: .init())
        await pipeline.waitUntilIdle()
        let previousState = pipeline.state

        pipeline.process(input: .cancelled, parameters: .init(skinSmoothing: 1))
        await pipeline.waitUntilIdle()

        XCTAssertEqual(pipeline.state, previousState)
        XCTAssertNil(pipeline.state.statusText)
    }

    func testD08D12D13DecodeFailurePreservesPreviousVisualAndUsesFriendlyCopy() async throws {
        let pipeline = ImageEditorPipeline()
        pipeline.process(input: .fixture(id: "existing", image: Self.testImage(red: 0.1)), parameters: .init())
        await pipeline.waitUntilIdle()
        let previousSnapshot = try XCTUnwrap(pipeline.state.latestSnapshot)

        pipeline.process(input: .photosPickerData(Data()), parameters: .init())
        await pipeline.waitUntilIdle()

        XCTAssertEqual(pipeline.state.latestSnapshot, previousSnapshot)
        XCTAssertEqual(pipeline.state.statusText, PhotoProcessingState.decodeFailureText)
        XCTAssertFalse(pipeline.state.statusText?.contains("NSError") == true)
        XCTAssertFalse(pipeline.state.statusText?.contains("invalidInput") == true)
        XCTAssertFalse(pipeline.state.statusText?.contains("/") == true)
    }

    func testD11LoadingOverlaysPreviousVisual() async throws {
        let secondStarted = expectation(description: "second photo processing started")
        let releaseSecond = DispatchSemaphore(value: 0)
        let callCount = LockedPhotoCounter()
        let processor = StillImageProcessor { image, _, _ in
            if callCount.increment() == 2 {
                secondStarted.fulfill()
                _ = releaseSecond.wait(timeout: .now() + 2)
            }
            return BeautyResult(output: image)
        }
        let pipeline = ImageEditorPipeline(processor: processor)

        pipeline.process(input: .fixture(id: "first", image: Self.testImage(red: 0.2)), parameters: .init())
        await pipeline.waitUntilIdle()
        let previousSnapshot = try XCTUnwrap(pipeline.state.latestSnapshot)

        pipeline.process(input: .fixture(id: "second", image: Self.testImage(red: 0.7)), parameters: .init())
        await fulfillment(of: [secondStarted], timeout: 2)

        XCTAssertEqual(pipeline.state, .loading(previousSnapshot: previousSnapshot))
        XCTAssertEqual(pipeline.state.statusText, "Processing photo...")

        releaseSecond.signal()
        await pipeline.waitUntilIdle()
    }

    func testD14StalePhotoWorkIsIgnoredInFavorOfLatestParameters() async throws {
        let processor = StillImageProcessor { image, _, _ in
            BeautyResult(output: image)
        }
        let pipeline = ImageEditorPipeline(processor: processor)

        pipeline.process(
            input: .fixture(id: "stale", image: Self.testImage(red: 0.1)),
            parameters: .init(skinSmoothing: 0.1)
        )
        pipeline.process(
            input: .fixture(id: "latest", image: Self.testImage(red: 0.9)),
            parameters: .init(skinSmoothing: 0.9)
        )
        await pipeline.waitUntilIdle()

        let snapshot = try XCTUnwrap(pipeline.state.latestSnapshot)
        XCTAssertEqual(snapshot.sourceID, "latest")
        XCTAssertEqual(snapshot.parameters.skinSmoothing, 0.9)
    }

    nonisolated private static func testImage(red: CGFloat) -> CIImage {
        CIImage(color: CIColor(red: red, green: 0.3, blue: 0.6, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 2, height: 2))
    }
}

nonisolated private final class LockedPhotoValues<Element>: @unchecked Sendable {
    private let queue = DispatchQueue(label: "beauty.demo.tests.locked-photo-values")
    private var storage: [Element] = []

    var values: [Element] {
        queue.sync { storage }
    }

    func append(_ element: Element) {
        queue.sync {
            storage.append(element)
        }
    }
}

nonisolated private final class LockedPhotoCounter: @unchecked Sendable {
    private let queue = DispatchQueue(label: "beauty.demo.tests.locked-photo-counter")
    private var value = 0

    func increment() -> Int {
        queue.sync {
            value += 1
            return value
        }
    }
}
