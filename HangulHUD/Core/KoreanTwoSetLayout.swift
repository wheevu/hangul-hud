import Foundation

struct HangulKey: Identifiable {
    let id: String
    let english: String
    let hangul: String
    let shiftHangul: String?
}

enum KoreanTwoSetLayout {
    static let rows: [[HangulKey]] = [
        [
            .init(id: "q", english: "q", hangul: "ㅂ", shiftHangul: "ㅃ"),
            .init(id: "w", english: "w", hangul: "ㅈ", shiftHangul: "ㅉ"),
            .init(id: "e", english: "e", hangul: "ㄷ", shiftHangul: "ㄸ"),
            .init(id: "r", english: "r", hangul: "ㄱ", shiftHangul: "ㄲ"),
            .init(id: "t", english: "t", hangul: "ㅅ", shiftHangul: "ㅆ"),
            .init(id: "y", english: "y", hangul: "ㅛ", shiftHangul: nil),
            .init(id: "u", english: "u", hangul: "ㅕ", shiftHangul: nil),
            .init(id: "i", english: "i", hangul: "ㅑ", shiftHangul: nil),
            .init(id: "o", english: "o", hangul: "ㅐ", shiftHangul: "ㅒ"),
            .init(id: "p", english: "p", hangul: "ㅔ", shiftHangul: "ㅖ")
        ],
        [
            .init(id: "a", english: "a", hangul: "ㅁ", shiftHangul: nil),
            .init(id: "s", english: "s", hangul: "ㄴ", shiftHangul: nil),
            .init(id: "d", english: "d", hangul: "ㅇ", shiftHangul: nil),
            .init(id: "f", english: "f", hangul: "ㄹ", shiftHangul: nil),
            .init(id: "g", english: "g", hangul: "ㅎ", shiftHangul: nil),
            .init(id: "h", english: "h", hangul: "ㅗ", shiftHangul: nil),
            .init(id: "j", english: "j", hangul: "ㅓ", shiftHangul: nil),
            .init(id: "k", english: "k", hangul: "ㅏ", shiftHangul: nil),
            .init(id: "l", english: "l", hangul: "ㅣ", shiftHangul: nil)
        ],
        [
            .init(id: "z", english: "z", hangul: "ㅋ", shiftHangul: nil),
            .init(id: "x", english: "x", hangul: "ㅌ", shiftHangul: nil),
            .init(id: "c", english: "c", hangul: "ㅊ", shiftHangul: nil),
            .init(id: "v", english: "v", hangul: "ㅍ", shiftHangul: nil),
            .init(id: "b", english: "b", hangul: "ㅠ", shiftHangul: nil),
            .init(id: "n", english: "n", hangul: "ㅜ", shiftHangul: nil),
            .init(id: "m", english: "m", hangul: "ㅡ", shiftHangul: nil)
        ]
    ]
}
