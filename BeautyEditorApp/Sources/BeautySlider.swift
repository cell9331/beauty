import SwiftUI
import UIKit

struct BeautySlider: UIViewRepresentable {
    let toolID: String
    let value: Float
    let range: ControlRange
    let enabled: Bool
    let title: String
    var referenceStyle = false
    let onBegin: () -> Void
    let onChange: (Float) -> Void
    let onEnd: () -> Void
    let onRelease: (Float) -> Void

    func makeUIView(context: Context) -> DesignSlider {
        let slider = DesignSlider()
        context.coordinator.install(on: slider)
        slider.accessibilityIdentifier = "adjustment-slider"
        return slider
    }

    func updateUIView(_ slider: DesignSlider, context: Context) {
        context.coordinator.update(parent: self)
        slider.minimumValue = range.bounds.lowerBound
        slider.maximumValue = range.bounds.upperBound
        slider.value = value
        slider.isEnabled = enabled
        slider.showsCenter = range == .signed
        slider.referenceStyle = referenceStyle
        slider.accessibilityLabel = title
        slider.accessibilityValue = String(Int(value.rounded()))
        slider.setNeedsLayout()
    }

    static func dismantleUIView(_ slider: DesignSlider, coordinator: Coordinator) {
        coordinator.invalidateTouch()
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    @MainActor final class Coordinator: NSObject {
        private var parent: BeautySlider
        private var activeToolID: String?
        private var discardingTouch = false
        init(parent: BeautySlider) { self.parent = parent }

        func install(on slider: DesignSlider) {
            slider.addTarget(self, action: #selector(begin), for: .touchDown)
            slider.addTarget(self, action: #selector(changed(_:)), for: .valueChanged)
            slider.addTarget(self, action: #selector(released(_:)), for: [.touchUpInside, .touchUpOutside])
            slider.addTarget(self, action: #selector(cancelled), for: .touchCancel)
        }

        func update(parent next: BeautySlider) {
            if next.toolID != parent.toolID || !next.enabled { invalidateTouch() }
            parent = next
        }

        func invalidateTouch() {
            if activeToolID != nil { discardingTouch = true }
            activeToolID = nil
        }

        @objc func begin() {
            guard parent.enabled, !discardingTouch, activeToolID == nil else { return }
            activeToolID = parent.toolID
            parent.onBegin()
        }
        @objc func changed(_ slider: DesignSlider) {
            guard !discardingTouch, parent.enabled, slider.isEnabled else { return }
            parent.onChange(slider.value)
            // Accessibility changes have no touch-up event. Finish their edit
            // silently; a real touch release has its own callback below.
            if activeToolID == nil && !slider.isTracking && !slider.referenceTouchActive { parent.onEnd() }
        }
        @objc func released(_ slider: DesignSlider) {
            let matchesTool = !discardingTouch && activeToolID == parent.toolID
            activeToolID = nil
            discardingTouch = false
            guard matchesTool, parent.enabled, slider.isEnabled else { return }
            parent.onRelease(slider.value)
        }
        @objc func cancelled() {
            let shouldEnd = !discardingTouch
            activeToolID = nil
            discardingTouch = false
            if shouldEnd { parent.onEnd() }
        }
    }
}

final class DesignSlider: UISlider {
    var showsCenter = false
    var referenceStyle = false {
        didSet {
            guard referenceStyle != oldValue else { return }
            configureAppearance()
        }
    }
    // Compatibility for the existing eye panel contracts. The same geometry
    // now also serves centered and one-way face controls.
    var referenceEyeStyle: Bool {
        get { referenceStyle }
        set { referenceStyle = newValue }
    }
    private(set) var referenceTouchActive = false
    private let centerMark = CALayer()
    private let referenceTrack = CALayer()
    private let referenceFill = CALayer()
    private let referenceThumb = CALayer()
    private static let legacyTrack = UIColor(red: 233/255, green: 234/255, blue: 237/255, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        referenceTrack.name = "reference-eye-track"
        referenceFill.name = "reference-eye-fill"
        referenceThumb.name = "reference-eye-thumb"
        centerMark.name = "slider-neutral-mark"
        layer.addSublayer(referenceTrack)
        layer.addSublayer(referenceFill)
        layer.addSublayer(centerMark)
        layer.addSublayer(referenceThumb)
        isContinuous = true
        configureAppearance()
    }
    required init?(coder: NSCoder) { fatalError("Use init(frame:)") }

    private func configureAppearance() {
        backgroundColor = .white
        if referenceStyle {
            let clear = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in }
            setMinimumTrackImage(clear, for: .normal)
            setMaximumTrackImage(clear, for: .normal)
            // UISlider's internal thumb view can offset its image relative to the
            // overridden thumbRect. Draw the visible circle from our source geometry;
            // the transparent system image preserves the 44pt native control footprint.
            let thumb = UIGraphicsImageRenderer(size: CGSize(width: 44, height: 44)).image { _ in }
            setThumbImage(thumb, for: .normal)
            setThumbImage(thumb, for: .highlighted)
            referenceTrack.backgroundColor = Self.legacyTrack.cgColor
            referenceFill.backgroundColor = UIColor(BeautyStyle.accent).cgColor
            referenceThumb.backgroundColor = UIColor.white.cgColor
            referenceThumb.borderColor = Self.legacyTrack.cgColor
            referenceThumb.borderWidth = 1
            referenceThumb.shadowColor = UIColor.black.cgColor
            referenceThumb.shadowOpacity = 0.12
            referenceThumb.shadowRadius = 2
            referenceThumb.shadowOffset = CGSize(width: 0, height: 1)
            centerMark.backgroundColor = UIColor(red: 181/255, green: 184/255, blue: 190/255, alpha: 1).cgColor
        } else {
            centerMark.removeFromSuperlayer()
            layer.addSublayer(centerMark)
            // SwiftUI can reapply its environment tint after makeUIView. Original
            // track images keep the native control grey even when that tint changes.
            let track = UIGraphicsImageRenderer(size: CGSize(width: 3, height: 2)).image { _ in
                Self.legacyTrack.setFill()
                UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 3, height: 2), cornerRadius: 1).fill()
            }.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1))
                .withRenderingMode(.alwaysOriginal)
            setMinimumTrackImage(track, for: .normal)
            setMaximumTrackImage(track, for: .normal)
            // Native UISlider fills from its minimum, not the signed neutral.
            // Keep both native halves grey rather than suggesting a nonzero value.
            minimumTrackTintColor = Self.legacyTrack
            maximumTrackTintColor = Self.legacyTrack
            centerMark.backgroundColor = UIColor(red: 181/255, green: 184/255, blue: 190/255, alpha: 1).cgColor
            let thumb = UIGraphicsImageRenderer(size: CGSize(width: 44, height: 44)).image { renderer in
                let circle = UIBezierPath(ovalIn: CGRect(x: 12.5, y: 12.5, width: 19, height: 19))
                renderer.cgContext.setShadow(offset: CGSize(width: 0, height: 1), blur: 2,
                                             color: UIColor.black.withAlphaComponent(0.12).cgColor)
                UIColor.white.setFill()
                circle.fill()
                renderer.cgContext.setShadow(offset: .zero, blur: 0, color: nil)
                Self.legacyTrack.setStroke()
                circle.lineWidth = 1
                circle.stroke()
            }
            setThumbImage(thumb, for: .normal)
            setThumbImage(thumb, for: .highlighted)
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    // UIKit's legacy slider alignment rectangle is narrower than its bounds.
    // SwiftUI paints the slider surface in that alignment rectangle, so reference
    // controls need matching bounds to preserve their two-point endpoint margin.
    override var alignmentRectInsets: UIEdgeInsets {
        referenceStyle ? .zero : super.alignmentRectInsets
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let inset: CGFloat = referenceStyle ? 12 : 0
        let height: CGFloat = referenceStyle ? 3 : 2
        return CGRect(x: bounds.minX + inset, y: bounds.midY - height / 2,
                      width: max(0, bounds.width - 2 * inset), height: height)
    }
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let fraction = CGFloat(min(1, max(0, (value - minimumValue) / max(1, maximumValue - minimumValue))))
        return CGRect(x: rect.minX + rect.width * fraction - 22, y: bounds.midY - 22, width: 44, height: 44)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        centerMark.isHidden = !showsCenter
        referenceTrack.isHidden = !referenceStyle
        referenceFill.isHidden = !referenceStyle
        referenceThumb.isHidden = !referenceStyle
        if referenceStyle {
            // Track, fill and visible circle share exactly the same center mapping.
            referenceTrack.removeFromSuperlayer()
            referenceFill.removeFromSuperlayer()
            centerMark.removeFromSuperlayer()
            referenceThumb.removeFromSuperlayer()
            layer.insertSublayer(referenceTrack, at: 0)
            layer.insertSublayer(referenceFill, at: 1)
            layer.insertSublayer(centerMark, at: 2)
            layer.addSublayer(referenceThumb)
            let track = trackRect(forBounds: bounds)
            let thumb = thumbRect(forBounds: bounds, trackRect: track, value: value)
            referenceTrack.frame = track
            referenceTrack.cornerRadius = 1.5
            let neutralX = showsCenter ? track.midX : track.minX
            referenceFill.frame = CGRect(x: min(neutralX, thumb.midX), y: track.minY,
                                         width: abs(thumb.midX - neutralX), height: track.height)
            referenceFill.cornerRadius = 1.5
            centerMark.frame = CGRect(x: track.midX - 3, y: bounds.midY - 3, width: 6, height: 6)
            centerMark.cornerRadius = 3
            referenceThumb.frame = CGRect(x: thumb.midX - 10, y: bounds.midY - 10, width: 20, height: 20)
            referenceThumb.cornerRadius = 10
        } else {
            centerMark.frame = CGRect(x: bounds.midX - 1, y: bounds.midY - 3, width: 2, height: 6)
            centerMark.cornerRadius = 0
        }
        CATransaction.commit()
    }

    // Reference controls accept a track tap or a continuous drag from any point.
    // Keep floating-point values throughout; the spoken/displayed value alone is rounded.
    func referenceValue(at x: CGFloat) -> Float {
        let track = trackRect(forBounds: bounds)
        guard x.isFinite, track.width > 0 else { return (minimumValue + maximumValue) / 2 }
        let fraction = min(1, max(0, (x - track.minX) / track.width))
        return minimumValue + Float(fraction) * (maximumValue - minimumValue)
    }
    private func updateReferenceValue(at x: CGFloat) {
        let next = referenceValue(at: x)
        guard next != value else { return }
        value = next
        setNeedsLayout()
        layoutIfNeeded()
        sendActions(for: .valueChanged)
    }
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard referenceStyle else { return super.beginTracking(touch, with: event) }
        guard isEnabled else { return false }
        referenceTouchActive = true
        sendActions(for: .touchDown)
        updateReferenceValue(at: touch.location(in: self).x)
        return true
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard referenceStyle else { return super.continueTracking(touch, with: event) }
        updateReferenceValue(at: touch.location(in: self).x)
        return true
    }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if referenceStyle, let touch { updateReferenceValue(at: touch.location(in: self).x) }
        super.endTracking(touch, with: event)
        referenceTouchActive = false
    }
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        referenceTouchActive = false
    }
    override func accessibilityIncrement() {
        guard referenceStyle else { super.accessibilityIncrement(); return }
        value = min(maximumValue, value + 1)
        sendActions(for: .valueChanged)
        setNeedsLayout()
    }
    override func accessibilityDecrement() {
        guard referenceStyle else { super.accessibilityDecrement(); return }
        value = max(minimumValue, value - 1)
        sendActions(for: .valueChanged)
        setNeedsLayout()
    }
}
