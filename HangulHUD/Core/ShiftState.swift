import AppKit
import Combine

/// Monitors global Shift key state so the HUD can visually swap to shift-layer Hangul.
final class ShiftState: ObservableObject {
    @Published var isShiftPressed = false
    private var monitor: Any?

    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            let newState = event.modifierFlags.contains(.shift)
            if newState != self?.isShiftPressed {
                DispatchQueue.main.async {
                    self?.isShiftPressed = newState
                }
            }
        }
    }

    func stop() {
        if let monitor { NSEvent.removeMonitor(monitor) }
    }

    func forceShift(_ pressed: Bool) {
        isShiftPressed = pressed
    }

    deinit { stop() }
}
