import SwiftUI

struct OverlayView: View {
    @ObservedObject var preferences: Preferences
    @EnvironmentObject var shiftState: ShiftState

    var body: some View {
        let compact = preferences.compactMode
        let theme = preferences.theme

        VStack(alignment: .leading, spacing: compact ? 6 : 10) {
            HStack(spacing: 6) {
                Text("Hangul HUD")
                    .font(.system(size: compact ? 11 : 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.headerColor)
                Spacer(minLength: 0)
                if shiftState.isShiftPressed {
                    Text("Shift")
                        .font(.system(size: compact ? 8 : 10, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.shiftAccent)
                }
                Image(systemName: theme.icon)
                    .font(.system(size: compact ? 10 : 13, weight: .medium))
                    .foregroundStyle(theme.headerColor.opacity(0.7))
                    .onTapGesture {
                        preferences.theme = theme.next
                    }
            }

            VStack(alignment: .leading, spacing: compact ? 4 : 7) {
                ForEach(Array(KoreanTwoSetLayout.rows.enumerated()), id: \.offset) { index, row in
                    HStack(spacing: compact ? 4 : 6) {
                        ForEach(row) { key in
                            KeycapView(key: key, compact: compact, theme: theme)
                        }
                    }
                    .padding(.leading, rowIndent(index: index, compact: compact))
                }
            }
        }
        .padding(compact ? 10 : 14)
        .background(
            RoundedRectangle(cornerRadius: compact ? 14 : 20, style: .continuous)
                .fill(theme.panelBackground)
                .shadow(color: theme.panelShadow, radius: 18, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 14 : 20, style: .continuous)
                .strokeBorder(theme.panelBorder, lineWidth: 1)
        )
        .fixedSize()
    }

    private func rowIndent(index: Int, compact: Bool) -> CGFloat {
        switch index {
        case 1: return compact ? 18 : 27
        case 2: return compact ? 52 : 78
        default: return 0
        }
    }
}
