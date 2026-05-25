import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case glass
    case light
    case dark

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .glass: return "Glass"
        case .light: return "Light"
        case .dark:  return "Dark"
        }
    }

    var next: Theme {
        let all = Self.allCases
        guard let idx = all.firstIndex(of: self) else { return .glass }
        return all[(idx + 1) % all.count]
    }

    var icon: String {
        switch self {
        case .glass: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark:  return "moon.fill"
        }
    }

    // MARK: - Panel
    var panelBackground: some ShapeStyle {
        switch self {
        case .glass: return AnyShapeStyle(.ultraThinMaterial)
        case .light: return AnyShapeStyle(Color.white.opacity(0.97))
        case .dark:  return AnyShapeStyle(Color(white: 0.08).opacity(0.97))
        }
    }

    var panelBorder: Color {
        switch self {
        case .glass: return .white.opacity(0.16)
        case .light: return .gray.opacity(0.25)
        case .dark:  return .white.opacity(0.10)
        }
    }

    var panelShadow: Color {
        switch self {
        case .glass: return .black.opacity(0.22)
        case .light: return .black.opacity(0.10)
        case .dark:  return .black.opacity(0.45)
        }
    }

    var headerColor: Color {
        switch self {
        case .glass: return .primary
        case .light: return .black
        case .dark:  return .white
        }
    }

    // MARK: - Keycaps
    var keyFill: some ShapeStyle {
        switch self {
        case .glass, .dark:
            return AnyShapeStyle(.regularMaterial)
        case .light:
            return AnyShapeStyle(Color(white: 0.93))
        }
    }

    var keyBorder: Color {
        switch self {
        case .glass, .dark:
            return .white.opacity(0.15)
        case .light:
            return .black.opacity(0.08)
        }
    }

    var hangulColor: Color {
        switch self {
        case .glass, .dark: return .primary
        case .light:        return .black
        }
    }

    var englishColor: Color {
        switch self {
        case .glass, .dark: return .secondary.opacity(0.7)
        case .light:        return .black.opacity(0.35)
        }
    }

    // MARK: - Shift accent
    var shiftAccent: Color {
        switch self {
        case .glass: return .orange
        case .light, .dark: return .red
        }
    }

}
