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

        for filename in ["OwnglyphMongmongdays", "OkDanDan-Bold"] {
            guard let url = Bundle.module.url(forResource: filename, withExtension: "ttf") else {
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
