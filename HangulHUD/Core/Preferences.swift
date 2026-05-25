import AppKit

final class Preferences: ObservableObject {
    static let shared = Preferences()

    private enum Key {
        static let compactMode = "compactMode"
        static let clickThrough = "clickThrough"
        static let opacity = "opacity"
        static let overlayFrame = "overlayFrame"
        static let theme = "theme"
    }

    @Published var compactMode: Bool { didSet { set(compactMode, for: Key.compactMode) } }
    @Published var clickThrough: Bool { didSet { set(clickThrough, for: Key.clickThrough) } }
    @Published var opacity: Double { didSet { set(opacity, for: Key.opacity) } }
    @Published var theme: Theme { didSet { set(theme.rawValue, for: Key.theme) } }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.compactMode: false,
            Key.clickThrough: false,
            Key.opacity: 0.92,
            Key.theme: Theme.glass.rawValue
        ])
        compactMode = defaults.bool(forKey: Key.compactMode)
        clickThrough = defaults.bool(forKey: Key.clickThrough)
        opacity = defaults.double(forKey: Key.opacity)
        theme = Theme(rawValue: defaults.string(forKey: Key.theme) ?? "") ?? .glass
    }

    var overlayFrame: NSRect? {
        get {
            guard let string = defaults.string(forKey: Key.overlayFrame) else { return nil }
            return NSRectFromString(string)
        }
        set {
            if let newValue { defaults.set(NSStringFromRect(newValue), forKey: Key.overlayFrame) }
        }
    }

    private func set(_ value: Bool, for key: String) { defaults.set(value, forKey: key) }
    private func set(_ value: Double, for key: String) { defaults.set(value, forKey: key) }
    private func set(_ value: String, for key: String) { defaults.set(value, forKey: key) }
}
