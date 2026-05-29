import AppKit
import Combine
import SwiftUI

// MARK: - Floating window that accepts mouse events without stealing focus

private final class FloatingWindow: NSWindow {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

// MARK: - Controller

final class OverlayWindowController: NSWindowController, NSWindowDelegate {
    private let preferences: Preferences
    private let shiftState = ShiftState()
    private var cancellables = Set<AnyCancellable>()
    private var didConfigure = false
    private var wantsVisible = false

    init(preferences: Preferences) {
        self.preferences = preferences
        super.init(window: nil)
    }

    @available(*, unavailable, message: "Use init(preferences:) instead.")
    required init?(coder: NSCoder) { nil }

    func configure() {
        guard !didConfigure else { return }
        didConfigure = true

        let view = OverlayView(preferences: preferences)
            .environmentObject(shiftState)
        let hostingView = NSHostingView(rootView: view)
        hostingView.autoresizingMask = [.width, .height]

        var frame = preferences.overlayFrame ?? NSRect(x: 0, y: 0, width: 560, height: 240)
        if preferences.overlayFrame == nil {
            if let screen = NSScreen.main {
                let hostingSize = hostingView.fittingSize
                frame = NSRect(
                    x: screen.frame.midX - hostingSize.width / 2,
                    y: screen.frame.midY - hostingSize.height / 2,
                    width: hostingSize.width,
                    height: hostingSize.height
                )
            }
        }
        frame = Self.visibleFrame(for: frame)

        let w = FloatingWindow(
            contentRect: frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        w.contentView = hostingView
        w.backgroundColor = .clear
        w.isOpaque = false
        w.hasShadow = false
        w.contentView?.wantsLayer = true
        w.contentView?.layer?.cornerRadius = 20
        w.contentView?.layer?.masksToBounds = true
        w.isMovableByWindowBackground = true
        w.level = .floating
        w.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        w.alphaValue = preferences.opacity
        w.ignoresMouseEvents = preferences.clickThrough
        w.delegate = self
        window = w

        preferences.$opacity.sink { [weak self] _ in self?.applyPreferences() }.store(in: &cancellables)
        preferences.$clickThrough.sink { [weak self] _ in self?.applyPreferences() }.store(in: &cancellables)
        preferences.$shiftLayerMonitoring.sink { [weak self] enabled in
            self?.setShiftMonitoring(enabled)
        }.store(in: &cancellables)
        setShiftMonitoring(preferences.shiftLayerMonitoring)
    }

    func show() {
        guard let window, didConfigure else { return }
        wantsVisible = true
        window.alphaValue = preferences.opacity
        window.ignoresMouseEvents = preferences.clickThrough
        window.orderFrontRegardless()
    }

    func hide() {
        guard let window, window.isVisible else { return }
        wantsVisible = false
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.14
            window.animator().alphaValue = 0
        } completionHandler: { [weak self, weak window] in
            guard let self, let window, !self.wantsVisible else { return }
            window.orderOut(nil)
        }
    }

    func forceShiftForScreenshot() {
        shiftState.forceShift(true)
    }

    /// Captures the HUD window to a PNG file. Returns true on success.
    func captureWindow(to path: String) -> Bool {
        guard let window else { return false }
        let windowID = CGWindowID(window.windowNumber)
        guard let cgImage = CGWindowListCreateImage(
            .null,
            .optionIncludingWindow,
            windowID,
            [.boundsIgnoreFraming]
        ) else { return false }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        guard let data = rep.representation(using: .png, properties: [:]) else { return false }
        do {
            try data.write(to: URL(fileURLWithPath: path))
            return true
        } catch {
            return false
        }
    }

    func persistFrame() {
        if let frame = window?.frame { preferences.overlayFrame = frame }
    }

    func windowDidMove(_ notification: Notification) { persistFrame() }
    func windowDidResize(_ notification: Notification) { persistFrame() }

    private func applyPreferences() {
        guard let window else { return }
        window.alphaValue = preferences.opacity
        window.ignoresMouseEvents = preferences.clickThrough
    }

    private func setShiftMonitoring(_ enabled: Bool) {
        if enabled {
            shiftState.start()
        } else {
            shiftState.stop()
        }
    }

    private static func visibleFrame(for frame: NSRect) -> NSRect {
        let screens = NSScreen.screens
        let visibleFrames = screens.map(\.visibleFrame)
        guard !visibleFrames.contains(where: { $0.intersects(frame) }) else { return frame }

        let fallbackScreen = NSScreen.main ?? screens.first
        guard let visibleFrame = fallbackScreen?.visibleFrame else { return frame }

        let width = min(max(frame.width, 120), visibleFrame.width)
        let height = min(max(frame.height, 80), visibleFrame.height)
        return NSRect(
            x: visibleFrame.midX - width / 2,
            y: visibleFrame.midY - height / 2,
            width: width,
            height: height
        )
    }
}
