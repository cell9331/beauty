//
//  ContentView.swift
//  BeautyDemo
//
//  Created by yakangwang on 2026/5/24.
//

import SwiftUI

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
}

#Preview {
    ContentView()
}
