import BeautySDK
import Foundation
import CoreGraphics

enum BeautyCategory: String, CaseIterable, Identifiable, Sendable {
    case management, sculpt, ratio, face, eye, mouth, nose, brow
    var id: String { rawValue }
    var title: String {
        switch self {
        case .management: "青管理"
        case .sculpt: "3D塑颜"
        case .ratio: "比例"
        case .face: "脸型"
        case .eye: "眼睛"
        case .mouth: "嘴唇"
        case .nose: "鼻子"
        case .brow: "眉毛"
        }
    }
    var hasDesign: Bool { self != .management && self != .sculpt }
    var showsScope: Bool { self == .face || self == .eye || self == .brow }
    var defaultTool: String {
        switch self {
        case .ratio: "ratio.cranialTop"
        case .eye: "eye.size"
        case .mouth: "mouth.size"
        case .nose: "nose.size"
        case .brow: "brow.thickness"
        default: "face.width"
        }
    }
}

enum ControlRange: Sendable {
    case unit, signed
    var bounds: ClosedRange<Float> { self == .unit ? 0...100 : -100...100 }
    func normalized(_ value: Float) -> Float {
        guard value.isFinite else { return 0 }
        return min(bounds.upperBound, max(bounds.lowerBound, value)) / 100
    }
}

struct ToolDefinition: Identifiable, Sendable {
    let id: String
    let title: String
    let category: BeautyCategory
    let field: String?
    let range: ControlRange
    var promo = false
    var pro = false
    var smart = false
    var note: String? = nil
    var enabled = true
    var icon: String { id.replacingOccurrences(of: ".", with: "_") }
    var systemSymbol: String? { ToolCatalog.systemSymbols[id] }
    var available: Bool { field != nil && enabled }

    func value(in parameters: BeautyParameters) -> Float {
        if let faceSlider {
            let direction: Float = faceSlider == .chinLength ? -1 : 1
            return direction * sdkValue(in: parameters) / maximumSDKStrength * 100
        }
        if let mouthSlider {
            let position = mouthSlider.position(in: parameters)
            return (range == .signed ? 2 * position - 1 : position) * 100
        }
        if let eyeSlider { return (eyeSlider.position(in: parameters) * 2 - 1) * 100 }
        if let eyebrowSlider { return (eyebrowSlider.position(in: parameters) * 2 - 1) * 100 }
        guard let keyPath else { return 0 }
        return parameters[keyPath: keyPath] / maximumSDKStrength * 100
    }

    func setValue(_ value: Float, in parameters: inout BeautyParameters) {
        guard available else { return }
        // The centered slider displays whole integers. Every position shown
        // as zero must also request the SDK's exact neutral value; preserve
        // continuous precision as soon as the display shows a nonzero value.
        let value = range == .signed && value.isFinite && value.rounded() == 0 ? 0 : value
        if let faceSlider {
            let normalized = range.normalized(value)
            let position = range == .signed ? (normalized + 1) / 2 : normalized
            parameters = faceSlider.applying(position: position, to: parameters)
            return
        }
        if let mouthSlider {
            let normalized = range.normalized(value)
            let position = range == .signed ? (normalized + 1) / 2 : normalized
            parameters = mouthSlider.applying(position: position, to: parameters)
            return
        }
        if let eyeSlider {
            parameters = eyeSlider.applying(position: (range.normalized(value) + 1) / 2, to: parameters)
            return
        }
        if let eyebrowSlider {
            parameters = eyebrowSlider.applying(position: (range.normalized(value) + 1) / 2, to: parameters)
            return
        }
        guard let keyPath else { return }
        parameters[keyPath: keyPath] = range.normalized(value) * maximumSDKStrength
    }

    var maximumSDKStrength: Float { field.flatMap { ToolCatalog.safetyCaps[$0] } ?? 1 }
    var isGeometry: Bool {
        available && field != "scleraRednessReduction" && field != "teethWhitening" && field != "jawlineShadow"
    }
    func sdkValue(in parameters: BeautyParameters) -> Float {
        keyPath.map { parameters[keyPath: $0] } ?? 0
    }

    // The selected eye-shape tools and iris size share the reference track/thumb treatment.
    var usesReferenceEyeSlider: Bool {
        // Match the selected tool identities; aliases of the same field keep
        // their own established presentation.
        switch id {
        case "eye.size", "eye.positionY", "eye.eyelidSize", "eye.length", "eye.spacing",
             "eye.irisSize", "eye.lowerLid", "eye.tailLift", "eye.tilt", "eye.innerCorner", "eye.outerCorner": true
        default: false
        }
    }

    var usesReferenceFaceSlider: Bool { category == .face && available }
    var usesReferenceSlider: Bool { usesReferenceFaceSlider || usesReferenceEyeSlider }

    var faceSlider: BeautyFaceShapeSlider? {
        switch field {
        case "faceSlim": .faceWidth
        case "faceSmall": .smallFace
        case "templeFullness": .temple
        case "cheekboneSlim": .cheekbone
        case "chinLength": .chinLength
        case "chinTaper": .chinTaper
        case "jawSlim": .jawAngle
        case "faceVShape": .vFace
        case "faceContourSmooth": .contourSmooth
        case "hairlineHeight": .hairline
        default: nil
        }
    }

    // The SDK owns reference-style signed direction and cap mapping.
    var eyeSlider: BeautyEyeShapeSlider? {
        switch field {
        case "eyeSize": .eyeSize
        case "eyeYPosition": .verticalPosition
        case "eyeHeight": .height
        case "eyeLength": .length
        case "eyeDistance": .spacing
        case "pupilSize": .irisSize
        case "lowerEyelidDrop": .lowerEyelid
        case "eyeTailLift": .outerTail
        case "eyeTilt": .tilt
        case "innerCornerOpen": .innerCorner
        case "outerCornerOpen": .outerCorner
        default: nil
        }
    }

    // Mouth direction is SDK-owned, including right=smaller for the size tool.
    var mouthSlider: BeautyMouthSlider? {
        switch field {
        case "mouthSize": .size
        case "mouthWidth": .width
        case "mouthYPosition": .verticalPosition
        case "mouthTilt": .tilt
        case "mouthXPosition": .horizontalPosition
        case "lipPeakDefinition": .mShape
        case "lipPlump": .fullness
        case "smile": .smile
        case "teethWhitening": .teethWhitening
        default: nil
        }
    }

    // The current SDK owns centered brow ranges and the reference tilt polarity.
    var eyebrowSlider: BeautyEyebrowSlider? {
        switch field {
        case "eyebrowThickness": .thickness
        case "eyebrowLength": .length
        case "eyebrowYPosition": .verticalPosition
        case "eyebrowSpacing": .spacing
        case "eyebrowHeadSpacing": .headSpacing
        case "eyebrowTilt": .tilt
        case "eyebrowPeakDefinition": .peak
        default: nil
        }
    }

    // Aliases resolve to the same field so their sliders never contradict one another.
    private var keyPath: WritableKeyPath<BeautyParameters, Float>? {
        switch field {
        case "faceSlim": \BeautyParameters.faceSlim
        case "faceSmall": \BeautyParameters.faceSmall
        case "faceContourSmooth": \BeautyParameters.faceContourSmooth
        case "templeFullness": \BeautyParameters.templeFullness
        case "cheekboneSlim": \BeautyParameters.cheekboneSlim
        case "chinLength": \BeautyParameters.chinLength
        case "doubleChinReduction": \BeautyParameters.doubleChinReduction
        case "doubleChinReductionPro": \BeautyParameters.doubleChinReductionPro
        case "chinTaper": \BeautyParameters.chinTaper
        case "faceVShape": \BeautyParameters.faceVShape
        case "jawSlim": \BeautyParameters.jawSlim
        case "jawlineShadow": \BeautyParameters.jawlineShadow
        case "hairlineHeight": \BeautyParameters.hairlineHeight
        case "headSmall": \BeautyParameters.headSmall
        case "headWrap": \BeautyParameters.headWrap
        case "cranialCrownHeight": \BeautyParameters.cranialCrownHeight
        case "foreheadHeight": \BeautyParameters.foreheadHeight
        case "midfaceLength": \BeautyParameters.midfaceLength
        case "philtrumLength": \BeautyParameters.philtrumLength
        case "lowerFaceLength": \BeautyParameters.lowerFaceLength
        case "faceShortening": \BeautyParameters.faceShortening
        case "eyeSize": \BeautyParameters.eyeSize
        case "eyeYPosition": \BeautyParameters.eyeYPosition
        case "eyeLength": \BeautyParameters.eyeLength
        case "eyeDistance": \BeautyParameters.eyeDistance
        case "pupilSize": \BeautyParameters.pupilSize
        case "eyeTailLift": \BeautyParameters.eyeTailLift
        case "eyeTilt": \BeautyParameters.eyeTilt
        case "scleraRednessReduction": \BeautyParameters.scleraRednessReduction
        case "innerCornerOpen": \BeautyParameters.innerCornerOpen
        case "outerCornerOpen": \BeautyParameters.outerCornerOpen
        case "eyeSymmetry": \BeautyParameters.eyeSymmetry
        case "upperEyelidLift": \BeautyParameters.upperEyelidLift
        case "eyeHeight": \BeautyParameters.eyeHeight
        case "gazeCorrection": \BeautyParameters.gazeCorrection
        case "lowerEyelidDrop": \BeautyParameters.lowerEyelidDrop
        case "mouthSize": \BeautyParameters.mouthSize
        case "mouthWidth": \BeautyParameters.mouthWidth
        case "mouthYPosition": \BeautyParameters.mouthYPosition
        case "mouthTilt": \BeautyParameters.mouthTilt
        case "mouthXPosition": \BeautyParameters.mouthXPosition
        case "lipPeakDefinition": \BeautyParameters.lipPeakDefinition
        case "lipPlump": \BeautyParameters.lipPlump
        case "smile": \BeautyParameters.smile
        case "teethWhitening": \BeautyParameters.teethWhitening
        case "noseSlim": \BeautyParameters.noseSlim
        case "noseTipLift": \BeautyParameters.noseTipLift
        case "noseWingSlim": \BeautyParameters.noseWingSlim
        case "noseRootNarrowing": \BeautyParameters.noseRootNarrowing
        case "noseBridge": \BeautyParameters.noseBridge
        case "noseTipSize": \BeautyParameters.noseTipSize
        case "eyebrowThickness": \BeautyParameters.eyebrowThickness
        case "eyebrowLength": \BeautyParameters.eyebrowLength
        case "eyebrowYPosition": \BeautyParameters.eyebrowYPosition
        case "eyebrowSpacing": \BeautyParameters.eyebrowSpacing
        case "eyebrowHeadSpacing": \BeautyParameters.eyebrowHeadSpacing
        case "eyebrowTilt": \BeautyParameters.eyebrowTilt
        case "eyebrowPeakDefinition": \BeautyParameters.eyebrowPeakDefinition
        default: nil
        }
    }
}

struct EditorSnapshot: Equatable, Sendable {
    var parameters = BeautyParameters()
    var protectBackground = false
}

struct EditHistory {
    private(set) var undoStack: [EditorSnapshot] = []
    private(set) var redoStack: [EditorSnapshot] = []
    mutating func record(_ previous: EditorSnapshot, replacing current: EditorSnapshot) {
        guard previous != current else { return }
        undoStack.append(previous)
        if undoStack.count > 50 { undoStack.removeFirst() }
        redoStack.removeAll()
    }
    mutating func undo(_ current: EditorSnapshot) -> EditorSnapshot? {
        guard let value = undoStack.popLast() else { return nil }
        redoStack.append(current)
        return value
    }
    mutating func redo(_ current: EditorSnapshot) -> EditorSnapshot? {
        guard let value = redoStack.popLast() else { return nil }
        undoStack.append(current)
        return value
    }
    mutating func clear() { undoStack.removeAll(); redoStack.removeAll() }
}

/// Uses the same aspect-fit rectangle as the photo, including its letterbox.
enum DebugLandmarkProjection {
    static func imageRect(imageSize: CGSize, viewport: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
        let scale = min(viewport.width / imageSize.width, viewport.height / imageSize.height)
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        return CGRect(x: (viewport.width - size.width) / 2, y: (viewport.height - size.height) / 2,
                      width: size.width, height: size.height)
    }
    static func project(_ point: CGPoint, in rect: CGRect) -> CGPoint {
        CGPoint(x: rect.minX + point.x * rect.width, y: rect.minY + point.y * rect.height)
    }
}
