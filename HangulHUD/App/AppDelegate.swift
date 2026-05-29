import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let preferences = Preferences.shared
    private lazy var inputSourceMonitor = InputSourceMonitor()
    private lazy var overlayController = OverlayWindowController(preferences: preferences)
    private lazy var menuBarController = MenuBarController(
        preferences: preferences,
        overlayController: overlayController,
        inputSourceMonitor: inputSourceMonitor
    )
    private var screenshotPath: String?
    private var screenshotShift = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        KeycapFontRegistrar.registerBundledFonts()

        // Screenshot mode
        let args = CommandLine.arguments
        if let idx = args.firstIndex(of: "--screenshot"), args.count > idx + 2 {
            let themeRaw = args[idx + 1]
            if let theme = Theme(rawValue: themeRaw) {
                preferences.theme = theme
            }
            if let fontIdx = args.firstIndex(of: "--font"), args.count > fontIdx + 1 {
                let fontRaw = args[fontIdx + 1]
                if let font = KeycapFont(rawValue: fontRaw) {
                    preferences.keycapFont = font
                }
            }
            screenshotPath = args[idx + 2]
            screenshotShift = args.contains("--shift")

            runScreenshotMode()
            return
        }

        // Normal mode
        overlayController.configure()
        menuBarController.configure()

        inputSourceMonitor.onInputSourceChanged = { [weak self] source in
            DispatchQueue.main.async {
                self?.handleInputSourceChange(source)
            }
        }
        inputSourceMonitor.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.handleInputSourceChange(self?.inputSourceMonitor.currentInputSource()
                ?? InputSourceInfo(localizedName: "", inputSourceID: "", languages: [], category: "", type: ""))
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        inputSourceMonitor.stop()
        overlayController.persistFrame()
    }

    private func handleInputSourceChange(_ source: InputSourceInfo) {
        menuBarController.refreshStatusTitle(source: source)
        if source.isKorean {
            overlayController.show()
        } else {
            overlayController.hide()
        }
    }

    private func runScreenshotMode() {
        overlayController.configure()
        overlayController.show()
        if screenshotShift {
            overlayController.forceShiftForScreenshot()
        }
        // Wait for SwiftUI to render, then capture and exit
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self, let path = self.screenshotPath else { NSApp.terminate(nil); return }
            _ = self.overlayController.captureWindow(to: path)
            NSApp.terminate(nil)
        }
    }
}
