import AppKit
import Combine

final class MenuBarController: NSObject {
    private let preferences: Preferences
    private let overlayController: OverlayWindowController
    private let inputSourceMonitor: InputSourceMonitor
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var cancellables = Set<AnyCancellable>()
    private var statusTitle = ""

    init(preferences: Preferences, overlayController: OverlayWindowController, inputSourceMonitor: InputSourceMonitor) {
        self.preferences = preferences
        self.overlayController = overlayController
        self.inputSourceMonitor = inputSourceMonitor
        super.init()
    }

    func configure() {
        statusItem.button?.title = "ㅎ"
        statusItem.button?.toolTip = "Hangul HUD"
        rebuildMenu()

        Publishers.MergeMany(
            preferences.$compactMode.map { _ in () }.eraseToAnyPublisher(),
            preferences.$clickThrough.map { _ in () }.eraseToAnyPublisher(),
            preferences.$opacity.map { _ in () }.eraseToAnyPublisher()
        )
        .sink { [weak self] in self?.rebuildMenu() }
        .store(in: &cancellables)
    }

    func refreshStatusTitle(source: InputSourceInfo) {
        statusTitle = source.localizedName.isEmpty ? source.inputSourceID : source.localizedName
        statusItem.button?.contentTintColor = source.isKorean ? .systemOrange : nil
        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let header = NSMenuItem(title: "Input: \(statusTitle)", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(.separator())

        menu.addItem(toggleItem(title: "Compact Mode", action: #selector(toggleCompactMode), state: preferences.compactMode))
        menu.addItem(toggleItem(title: "Click-through", action: #selector(toggleClickThrough), state: preferences.clickThrough))
        menu.addItem(opacitySliderItem())
        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func toggleItem(title: String, action: Selector, state: Bool) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.state = state ? .on : .off
        return item
    }

    private func opacitySliderItem() -> NSMenuItem {
        let item = NSMenuItem()
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 50))

        let label = NSTextField(labelWithString: "Opacity")
        label.font = .menuFont(ofSize: 12)
        label.sizeToFit()
        label.frame.origin = NSPoint(x: 20, y: 28)
        container.addSubview(label)

        let percentLabel = NSTextField(labelWithString: "\(Int(preferences.opacity * 100))%")
        percentLabel.font = .menuFont(ofSize: 10)
        percentLabel.textColor = .secondaryLabelColor
        percentLabel.sizeToFit()
        percentLabel.frame.origin = NSPoint(x: 220, y: 30)
        container.addSubview(percentLabel)

        let slider = NSSlider(value: preferences.opacity, minValue: 0.35, maxValue: 1.0, target: self, action: #selector(opacityChanged(_:)))
        slider.frame = NSRect(x: 18, y: 4, width: 224, height: 24)
        container.addSubview(slider)

        item.view = container
        return item
    }

    @objc private func toggleCompactMode() { preferences.compactMode.toggle() }
    @objc private func toggleClickThrough() { preferences.clickThrough.toggle() }
    @objc private func opacityChanged(_ sender: NSSlider) { preferences.opacity = sender.doubleValue }
    @objc private func quit() { NSApp.terminate(nil) }
}
