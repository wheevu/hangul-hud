import AppKit
import Combine

/// Optionally monitors global Shift key state so the HUD can visually swap to the
/// shift-layer Hangul. This observes modifier flags only; it does not read typed
/// characters. Keeping it optional avoids asking for keyboard-monitoring trust
/// unless the user wants live Shift-layer previews.
final class ShiftState: ObservableObject {
    @Published var isShiftPressed = false
    private var monitor: Any?

    func start() {
        guard monitor == nil else { return }
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
        monitor = nil
        isShiftPressed = false
    }

    func forceShift(_ pressed: Bool) {
        isShiftPressed = pressed
    }

    deinit { stop() }
}
