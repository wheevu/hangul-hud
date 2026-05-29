import AppKit

final class Preferences: ObservableObject {
    static let shared = Preferences()

    private enum Key {
        static let compactMode = "compactMode"
        static let clickThrough = "clickThrough"
        static let shiftLayerMonitoring = "shiftLayerMonitoring"
        static let opacity = "opacity"
        static let overlayFrame = "overlayFrame"
        static let theme = "theme"
        static let keycapFont = "keycapFont"
    }

    @Published var compactMode: Bool { didSet { set(compactMode, for: Key.compactMode) } }
    @Published var clickThrough: Bool { didSet { set(clickThrough, for: Key.clickThrough) } }
    @Published var shiftLayerMonitoring: Bool { didSet { set(shiftLayerMonitoring, for: Key.shiftLayerMonitoring) } }
    @Published var opacity: Double {
        didSet {
            let clamped = Self.clampedOpacity(opacity)
            if clamped != opacity {
                opacity = clamped
                set(clamped, for: Key.opacity)
                return
            }
            set(opacity, for: Key.opacity)
        }
    }
    @Published var theme: Theme { didSet { set(theme.rawValue, for: Key.theme) } }
    @Published var keycapFont: KeycapFont { didSet { set(keycapFont.rawValue, for: Key.keycapFont) } }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.compactMode: false,
            Key.clickThrough: false,
            Key.shiftLayerMonitoring: false,
            Key.opacity: 0.92,
            Key.theme: Theme.glass.rawValue,
            Key.keycapFont: KeycapFont.system.rawValue
        ])
        compactMode = defaults.bool(forKey: Key.compactMode)
        clickThrough = defaults.bool(forKey: Key.clickThrough)
        shiftLayerMonitoring = defaults.bool(forKey: Key.shiftLayerMonitoring)
        opacity = Self.clampedOpacity(defaults.double(forKey: Key.opacity))
        theme = Theme(rawValue: defaults.string(forKey: Key.theme) ?? "") ?? .glass
        keycapFont = KeycapFont(rawValue: defaults.string(forKey: Key.keycapFont) ?? "") ?? .system
    }

    var overlayFrame: NSRect? {
        get {
            guard let string = defaults.string(forKey: Key.overlayFrame) else { return nil }
            let frame = NSRectFromString(string)
            guard frame.isUsableOverlayFrame else { return nil }
            return frame
        }
        set {
            if let newValue, newValue.isUsableOverlayFrame {
                defaults.set(NSStringFromRect(newValue), forKey: Key.overlayFrame)
            }
        }
    }

    static func clampedOpacity(_ value: Double) -> Double {
        guard value.isFinite else { return 0.92 }
        return min(max(value, 0.35), 1.0)
    }

    private func set(_ value: Bool, for key: String) { defaults.set(value, forKey: key) }
    private func set(_ value: Double, for key: String) { defaults.set(value, forKey: key) }
    private func set(_ value: String, for key: String) { defaults.set(value, forKey: key) }
}

private extension NSRect {
    var isUsableOverlayFrame: Bool {
        origin.x.isFinite && origin.y.isFinite && size.width.isFinite && size.height.isFinite
            && size.width >= 120 && size.height >= 80
    }
}
