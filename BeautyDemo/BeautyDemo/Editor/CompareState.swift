import BeautySDK
import CoreGraphics
import CoreVideo
import Foundation

nonisolated struct CompareState: Equatable, Sendable {
    enum Display: String, Equatable, Sendable {
        case before
        case after
    }

    var display: Display = .after

    var actionTitle: String {
        switch display {
        case .before:
            "Show After"
        case .after:
            "Show Before"
        }
    }

    var accessibilityValue: String {
        switch display {
        case .before:
            "Showing before"
        case .after:
            "Showing after"
        }
    }

    mutating func toggle() {
        display = display == .before ? .after : .before
    }

    func photoImage(from snapshot: ImageProcessingSnapshot) -> CGImage {
        switch display {
        case .before:
            snapshot.inputCGImage
        case .after:
            snapshot.outputCGImage
        }
    }

    func cameraPixelBuffer(from snapshot: CameraProcessingSnapshot) -> CVPixelBuffer {
        switch display {
        case .before:
            snapshot.inputPixelBuffer
        case .after:
            snapshot.outputPixelBuffer
        }
    }

    static func preservingEditorState(
        mode: EditorInputMode?,
        category: BeautyCategoryID,
        subcategory: FacialFeatureSubcategoryID,
        parameters: BeautyParameters,
        toggle state: inout CompareState
    ) -> EditorSelectionSnapshot {
        let snapshot = EditorSelectionSnapshot(
            mode: mode,
            category: category,
            subcategory: subcategory,
            parameters: parameters
        )
        state.toggle()
        return snapshot
    }
}

nonisolated struct EditorSelectionSnapshot: Equatable, Sendable {
    let mode: EditorInputMode?
    let category: BeautyCategoryID
    let subcategory: FacialFeatureSubcategoryID
    let parameters: BeautyParameters
}
