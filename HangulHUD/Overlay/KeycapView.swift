import SwiftUI

struct KeycapView: View {
    let key: HangulKey
    let compact: Bool
    let theme: Theme
    @EnvironmentObject var shiftState: ShiftState

    var body: some View {
        let hasShift = key.shiftHangul != nil
        let active = shiftState.isShiftPressed && hasShift
        let mainChar = active ? key.shiftHangul! : key.hangul

        ZStack(alignment: .top) {
            let bg = RoundedRectangle(cornerRadius: compact ? 6 : 8, style: .continuous)

            // Always use the same keycap background — shift only changes text color
            bg.fill(theme.keyFill)
                .overlay(RoundedRectangle(cornerRadius: compact ? 6 : 8, style: .continuous)
                    .strokeBorder(theme.keyBorder, lineWidth: 1))

            // Subtle shift tint overlay (barely visible)
            if active {
                Color.clear
                    .background(theme.shiftAccent.opacity(0.06), in: RoundedRectangle(cornerRadius: compact ? 6 : 8, style: .continuous))
                    .allowsHitTesting(false)
            }

            // Main Hangul — swaps character + color when Shift is held
            Text(mainChar)
                .font(.system(size: compact ? 16 : 22, weight: .semibold, design: .rounded))
                .foregroundStyle(active ? theme.shiftAccent : theme.hangulColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // English Label (Top Left)
            if !compact {
                Text(key.english.uppercased())
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.englishColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, 4)
                    .padding(.leading, 6)
            }

            // Shift Label (Top Right) — only shown when shift is NOT held
            if !shiftState.isShiftPressed, let shift = key.shiftHangul {
                Text(shift)
                    .font(.system(size: compact ? 8 : 9, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.shiftAccent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, compact ? 3 : 4)
                    .padding(.trailing, compact ? 4 : 6)
            }
        }
        .frame(width: compact ? 32 : 44, height: compact ? 32 : 48)
    }
}
