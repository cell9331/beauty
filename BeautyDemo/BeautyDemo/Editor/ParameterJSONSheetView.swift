import BeautySDK
import SwiftUI
import UIKit

enum ParameterJSONSheetMode: String, CaseIterable, Identifiable, Sendable {
    case `import` = "Import"
    case export = "Export"

    var id: String { rawValue }
}

struct ParameterJSONSheetViewState: Equatable, Sendable {
    let title: String
    let modeTitles: [String]
    let primaryPrompt: String
    let previewActionTitle: String
    let applyActionTitle: String
    let exportActionTitle: String
    let feedbackText: String?
    let canApply: Bool
}

struct ParameterJSONSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var parameterStore: BeautyParameterStore
    let onApplied: (BeautyParameters) -> Void

    @State private var mode: ParameterJSONSheetMode = .import
    @State private var importText = ""
    @State private var importState: ParameterJSONImportState = .empty
    @State private var previewedImportText = ""
    @State private var exportText = ""

    var body: some View {
        let state = Self.viewState(
            mode: mode,
            importState: importState,
            isPreviewCurrent: previewedImportText == importText
        )

        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Mode", selection: $mode) {
                    ForEach(ParameterJSONSheetMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Parameter JSON mode")

                switch mode {
                case .import:
                    importContent(state)
                case .export:
                    exportContent(state)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .background(Color(red: 247 / 255, green: 248 / 255, blue: 250 / 255))
            .navigationTitle(state.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                refreshExportText()
            }
            .onChange(of: mode) { _, newMode in
                if newMode == .export {
                    refreshExportText()
                }
            }
        }
    }

    static func viewState(
        mode: ParameterJSONSheetMode,
        importState: ParameterJSONImportState,
        isPreviewCurrent: Bool = true
    ) -> ParameterJSONSheetViewState {
        let feedbackText: String?
        switch importState {
        case .empty:
            feedbackText = nil
        case .preview:
            feedbackText = "Check the decoded parameter snapshot, then apply it to the current preview."
        case .failed(let error):
            feedbackText = error.message
        }

        return ParameterJSONSheetViewState(
            title: "Parameter JSON",
            modeTitles: ParameterJSONSheetMode.allCases.map(\.rawValue),
            primaryPrompt: mode == .import
                ? "Paste parameter JSON"
                : "Copy this deterministic payload for SDK QA or round-trip tests.",
            previewActionTitle: "Preview Parameter JSON",
            applyActionTitle: "Apply Imported Parameters",
            exportActionTitle: "Copy Parameter JSON",
            feedbackText: feedbackText,
            canApply: importState.candidate != nil && isPreviewCurrent
        )
    }

    private func importContent(_ state: ParameterJSONSheetViewState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(state.primaryPrompt)
                .font(.system(size: 20, weight: .semibold))

            Text("Paste a schemaVersion 1 payload to preview changes before applying. Current settings stay unchanged.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)

            TextEditor(text: $importText)
                .font(.system(size: 16))
                .frame(minHeight: 180)
                .padding(8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel("Paste parameter JSON")
                .onChange(of: importText) { _, _ in
                    importState = .empty
                    previewedImportText = ""
                }

            if let feedbackText = state.feedbackText {
                Text(feedbackText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(feedbackColor(for: importState))
                    .padding(.top, 4)
                    .accessibilityLabel(feedbackText)
            }

            HStack(spacing: 8) {
                Button(state.previewActionTitle) {
                    importState = ParameterJSONCoding.previewImport(importText)
                    previewedImportText = importText
                }
                .font(.system(size: 13, weight: .semibold))
                .buttonStyle(.borderedProminent)
                .frame(minHeight: 44)
                .accessibilityHint("Decodes pasted parameters without changing current settings.")

                Button(state.applyActionTitle) {
                    guard previewedImportText == importText,
                          let candidate = importState.candidate else {
                        return
                    }
                    parameterStore.applyImportedParameters(candidate)
                    onApplied(candidate)
                    dismiss()
                }
                .font(.system(size: 13, weight: .semibold))
                .buttonStyle(.borderedProminent)
                .frame(minHeight: 44)
                .disabled(!state.canApply)
                .accessibilityHint("Applies the validated parameter snapshot to the current preview.")
            }
        }
    }

    private func exportContent(_ state: ParameterJSONSheetViewState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(state.primaryPrompt)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)

            TextEditor(text: $exportText)
                .font(.system(size: 16))
                .frame(minHeight: 220)
                .padding(8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel("Exported parameter JSON")

            Button(state.exportActionTitle) {
                refreshExportText()
                UIPasteboard.general.string = exportText
            }
            .font(.system(size: 13, weight: .semibold))
            .buttonStyle(.borderedProminent)
            .frame(minHeight: 44)
            .accessibilityHint("Copies the current parameter snapshot as deterministic JSON.")
        }
    }

    private func refreshExportText() {
        exportText = (try? ParameterJSONCoding.export(parameters: parameterStore.parametersSnapshot)) ?? ""
    }

    private func feedbackColor(for state: ParameterJSONImportState) -> Color {
        switch state {
        case .failed:
            Color(red: 217 / 255, green: 45 / 255, blue: 32 / 255)
        case .empty, .preview:
            Color(red: 32 / 255, green: 47 / 255, blue: 77 / 255)
        }
    }
}
