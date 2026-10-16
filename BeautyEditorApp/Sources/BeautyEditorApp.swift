import SwiftUI

@main
struct BeautyEditorApp: App {
    @State private var model = EditorModel()
    var body: some Scene {
        WindowGroup { EditorScreen(model: model) }
    }
}
