import CoreText
import Foundation
import SwiftUI

enum KeycapFont: String, CaseIterable, Identifiable {
    case system
    case style1
    case style2

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "Default"
        case .style1: return "Style 1"
        case .style2: return "Style 2"
        }
    }

    func font(size: CGFloat, weight: Font.Weight = .semibold, design: Font.Design = .rounded) -> Font {
        let scaled: CGFloat
        switch self {
        case .system:
            scaled = size
        case .style1, .style2:
            scaled = size * 1.3
        }
        switch self {
        case .system:
            return .system(size: scaled, weight: weight, design: design)
        case .style1:
            return .custom("Ownglyph_mongmongdays-Rg", size: scaled)
        case .style2:
            return .custom("OkDanDan-Bold", size: scaled)
        }
    }
}

enum KeycapFontRegistrar {
    private static var didRegister = false

    static func registerBundledFonts() {
        guard !didRegister else { return }
        didRegister = true

        let directories = bundledFontDirectories()
        for filename in ["OwnglyphMongmongdays", "OkDanDan-Bold"] {
            guard let url = existingFontURL(named: filename, in: directories) else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    private static func existingFontURL(named filename: String, in directories: [URL]) -> URL? {
        for directory in directories {
            let url = directory.appendingPathComponent(filename).appendingPathExtension("ttf")
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }
        return nil
    }

    /// Directories that may hold the SwiftPM resource bundle containing the
    /// bundled fonts. `Bundle.module` is intentionally avoided: its generated
    /// accessor fatal-errors when the bundle is not found beside the app, which
    /// crashes the packaged app before it reaches the run loop.
    private static func bundledFontDirectories() -> [URL] {
        let bundleName = "HangulHUD_HangulHUD.bundle"
        var directories: [URL] = []
        if let resourcesURL = Bundle.main.resourceURL {
            directories.append(resourcesURL.appendingPathComponent(bundleName))
        }
        // Covers `swift run` and a bare binary launched from the build dir,
        // where SwiftPM places the resource bundle next to the executable.
        directories.append(Bundle.main.bundleURL.appendingPathComponent(bundleName))
        return directories
    }
}
