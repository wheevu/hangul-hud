import Carbon
import Foundation
import os

struct InputSourceInfo: Equatable {
    let localizedName: String
    let inputSourceID: String
    let languages: [String]
    let category: String
    let type: String

    /// True for any Korean input source (2-Set, 3-Set, 390, Romaja, etc.)
    var isKorean: Bool {
        let lowerID = inputSourceID.lowercased()
        let lowerName = localizedName.lowercased()

        let hasKoreanLanguage = languages.contains(where: { $0.lowercased() == "ko" })
        let idIsKorean = lowerID.contains("korean") || lowerID.contains("hangul")
            || lowerID.contains("com.apple.inputmethod.korean")
        let nameIsKorean = lowerName.contains("korean") || lowerName.contains("hangul")
            || lowerName.contains("한글") || lowerName.contains("한국")

        return hasKoreanLanguage || idIsKorean || nameIsKorean
    }
}

final class InputSourceMonitor {
    var onInputSourceChanged: ((InputSourceInfo) -> Void)?

    private var timer: Timer?
    private var lastSource: InputSourceInfo?
    private let log = Logger(subsystem: "com.local.HangulHUD", category: "input")

    func start() {
        let name = NSNotification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String)
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(inputSourceDidChange),
            name: name,
            object: nil,
            suspensionBehavior: .deliverImmediately
        )

        pollAndNotifyIfChanged(force: true)

        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.pollAndNotifyIfChanged(force: false)
        }
        if let timer { RunLoop.main.add(timer, forMode: .common) }
    }

    func stop() {
        DistributedNotificationCenter.default().removeObserver(self)
        timer?.invalidate()
        timer = nil
    }

    func currentInputSource() -> InputSourceInfo {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return InputSourceInfo(localizedName: "Unknown", inputSourceID: "", languages: [], category: "", type: "")
        }
        return InputSourceInfo(
            localizedName: stringProperty(source, kTISPropertyLocalizedName),
            inputSourceID: stringProperty(source, kTISPropertyInputSourceID),
            languages: stringArrayProperty(source, kTISPropertyInputSourceLanguages),
            category: stringProperty(source, kTISPropertyInputSourceCategory),
            type: stringProperty(source, kTISPropertyInputSourceType)
        )
    }

    @objc private func inputSourceDidChange() {
        pollAndNotifyIfChanged(force: true)
    }

    private func pollAndNotifyIfChanged(force: Bool) {
        let source = currentInputSource()
        guard force || source != lastSource else { return }
        lastSource = source

        log.debug("""
            Input source — name: \(source.localizedName), \
            id: \(source.inputSourceID), \
            langs: \(source.languages.joined(separator: ",")), \
            category: \(source.category), type: \(source.type), \
            isKorean: \(source.isKorean)
            """)

        onInputSourceChanged?(source)
    }
}

private func stringProperty(_ source: TISInputSource, _ key: CFString) -> String {
    guard let value = TISGetInputSourceProperty(source, key) else { return "" }
    return Unmanaged<CFString>.fromOpaque(value).takeUnretainedValue() as String
}

private func stringArrayProperty(_ source: TISInputSource, _ key: CFString) -> [String] {
    guard let value = TISGetInputSourceProperty(source, key) else { return [] }
    return Unmanaged<CFArray>.fromOpaque(value).takeUnretainedValue() as? [String] ?? []
}
