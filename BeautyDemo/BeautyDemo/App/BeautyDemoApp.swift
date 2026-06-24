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
