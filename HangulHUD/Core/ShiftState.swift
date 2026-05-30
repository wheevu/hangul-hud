import AppKit
import Combine

/// Optionally monitors global Shift key state so the HUD can visually swap to the
/// shift-layer Hangul. This observes modifier flags only; it does not read typed
/// characters. Keeping it optional avoids asking for keyboard-monitoring trust
/// unless the user wants live Shift-layer previews.
final class ShiftState: ObservableObject {
    @Published var isShiftPressed = false
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var eventTap: CFMachPort?
    private var eventTapRunLoopSource: CFRunLoopSource?

    func start() {
        guard globalMonitor == nil, localMonitor == nil, eventTap == nil else { return }

        startEventTap()

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.update(from: event.modifierFlags)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.update(from: event.modifierFlags)
            return event
        }
    }

    func stop() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        if let eventTap { CGEvent.tapEnable(tap: eventTap, enable: false) }
        if let eventTapRunLoopSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), eventTapRunLoopSource, .commonModes) }
        globalMonitor = nil
        localMonitor = nil
        eventTap = nil
        eventTapRunLoopSource = nil
        isShiftPressed = false
    }

    func forceShift(_ pressed: Bool) {
        isShiftPressed = pressed
    }

    deinit { stop() }

    private func startEventTap() {
        let mask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        let callback: CGEventTapCallBack = { proxy, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let state = Unmanaged<ShiftState>.fromOpaque(refcon).takeUnretainedValue()

            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                if let eventTap = state.eventTap {
                    CGEvent.tapEnable(tap: eventTap, enable: true)
                }
            } else if type == .flagsChanged {
                state.update(from: event.flags)
            }

            return Unmanaged.passUnretained(event)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }

        eventTap = tap
        eventTapRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        if let eventTapRunLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), eventTapRunLoopSource, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }

    private func update(from flags: NSEvent.ModifierFlags) {
        setShiftPressed(flags.contains(.shift))
    }

    private func update(from flags: CGEventFlags) {
        setShiftPressed(flags.contains(.maskShift))
    }

    private func setShiftPressed(_ pressed: Bool) {
        guard pressed != isShiftPressed else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self, pressed != self.isShiftPressed else { return }
            self.isShiftPressed = pressed
        }
    }
}
