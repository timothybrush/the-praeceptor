import SwiftUI

struct TimeOfDayTheme {
    // Base layers
    let background: Color
    let surface: Color
    let raised: Color

    // Text hierarchy
    let text: Color
    let textSecondary: Color
    let textTertiary: Color
    let textGhost: Color

    // Lines
    let line: Color
    let lineStrong: Color

    // Accent
    let accent: Color
    let accentBright: Color
    let accentDeep: Color
    let accentInk: Color
    let accentGlow: Color
    let accentFill: Color
    let accentLine: Color

    // Semantic
    let bad: Color

    // Back-compat
    var holdButtonIdle: Color { accent }
    var holdButtonActive: Color { accentBright }

    // MARK: — Font helpers (New York serif ≈ Fraunces, SF Mono ≈ JetBrains Mono)

    static func display(_ size: CGFloat) -> Font {
        .system(size: size, design: .serif).weight(.light)
    }
    static func displayItalic(_ size: CGFloat) -> Font {
        .system(size: size, design: .serif).weight(.light).italic()
    }
    static func body(_ size: CGFloat) -> Font {
        .system(size: size)
    }
    static func mono(_ size: CGFloat) -> Font {
        .system(size: size, design: .monospaced)
    }

    // MARK: — Resolve

    static func current(_ tod: TimeOfDay) -> TimeOfDayTheme {
        switch tod {
        case .morning: return .morning
        case .noon:    return .midday
        case .night:   return .evening
        }
    }

    // MARK: — Morning  5:00–11:59  warm ink · straw gold

    static let morning = TimeOfDayTheme(
        background:    Color(red: 0.0549, green: 0.0431, blue: 0.0275),
        surface:       Color(red: 0.1020, green: 0.0784, blue: 0.0549),
        raised:        Color(red: 0.1333, green: 0.1059, blue: 0.0784),
        text:          Color(red: 0.9373, green: 0.9020, blue: 0.8235),
        textSecondary: Color(red: 0.5882, green: 0.5255, blue: 0.4431),
        textTertiary:  Color(red: 0.3608, green: 0.3137, blue: 0.2588),
        textGhost:     Color(red: 0.2275, green: 0.1922, blue: 0.1569),
        line:          Color(red: 0.9373, green: 0.9020, blue: 0.8235).opacity(0.09),
        lineStrong:    Color(red: 0.9373, green: 0.9020, blue: 0.8235).opacity(0.16),
        accent:        Color(red: 0.7882, green: 0.6392, blue: 0.3529),
        accentBright:  Color(red: 0.8667, green: 0.7294, blue: 0.4471),
        accentDeep:    Color(red: 0.6118, green: 0.4824, blue: 0.2275),
        accentInk:     Color(red: 0.0549, green: 0.0431, blue: 0.0275),
        accentGlow:    Color(red: 0.7882, green: 0.6392, blue: 0.3529).opacity(0.20),
        accentFill:    Color(red: 0.7882, green: 0.6392, blue: 0.3529).opacity(0.10),
        accentLine:    Color(red: 0.7882, green: 0.6392, blue: 0.3529).opacity(0.28),
        bad:           Color(red: 0.7765, green: 0.4157, blue: 0.3686)
    )

    // MARK: — Midday  12:00–16:59  cool stone · tempered bronze

    static let midday = TimeOfDayTheme(
        background:    Color(red: 0.0392, green: 0.0431, blue: 0.0510),
        surface:       Color(red: 0.0784, green: 0.0902, blue: 0.1020),
        raised:        Color(red: 0.1098, green: 0.1255, blue: 0.1412),
        text:          Color(red: 0.9020, green: 0.8941, blue: 0.8706),
        textSecondary: Color(red: 0.5569, green: 0.5529, blue: 0.5216),
        textTertiary:  Color(red: 0.3333, green: 0.3373, blue: 0.3176),
        textGhost:     Color(red: 0.2078, green: 0.2118, blue: 0.2000),
        line:          Color(red: 0.9020, green: 0.8941, blue: 0.8706).opacity(0.09),
        lineStrong:    Color(red: 0.9020, green: 0.8941, blue: 0.8706).opacity(0.16),
        accent:        Color(red: 0.7098, green: 0.6039, blue: 0.4706),
        accentBright:  Color(red: 0.7882, green: 0.6824, blue: 0.5451),
        accentDeep:    Color(red: 0.5412, green: 0.4471, blue: 0.3373),
        accentInk:     Color(red: 0.0392, green: 0.0431, blue: 0.0510),
        accentGlow:    Color(red: 0.7098, green: 0.6039, blue: 0.4706).opacity(0.20),
        accentFill:    Color(red: 0.7098, green: 0.6039, blue: 0.4706).opacity(0.10),
        accentLine:    Color(red: 0.7098, green: 0.6039, blue: 0.4706).opacity(0.28),
        bad:           Color(red: 0.7216, green: 0.4157, blue: 0.3765)
    )

    // MARK: — Evening  17:00–04:59  coffee black · ember

    static let evening = TimeOfDayTheme(
        background:    Color(red: 0.0431, green: 0.0314, blue: 0.0275),
        surface:       Color(red: 0.0863, green: 0.0588, blue: 0.0510),
        raised:        Color(red: 0.1176, green: 0.0863, blue: 0.0706),
        text:          Color(red: 0.9216, green: 0.8667, blue: 0.8118),
        textSecondary: Color(red: 0.5412, green: 0.4314, blue: 0.3686),
        textTertiary:  Color(red: 0.3373, green: 0.2588, blue: 0.2118),
        textGhost:     Color(red: 0.2118, green: 0.1569, blue: 0.1216),
        line:          Color(red: 0.9216, green: 0.8667, blue: 0.8118).opacity(0.09),
        lineStrong:    Color(red: 0.9216, green: 0.8667, blue: 0.8118).opacity(0.16),
        accent:        Color(red: 0.7216, green: 0.4157, blue: 0.2902),
        accentBright:  Color(red: 0.8000, green: 0.5059, blue: 0.3765),
        accentDeep:    Color(red: 0.5569, green: 0.3059, blue: 0.2000),
        accentInk:     Color(red: 0.0431, green: 0.0314, blue: 0.0275),
        accentGlow:    Color(red: 0.7216, green: 0.4157, blue: 0.2902).opacity(0.22),
        accentFill:    Color(red: 0.7216, green: 0.4157, blue: 0.2902).opacity(0.10),
        accentLine:    Color(red: 0.7216, green: 0.4157, blue: 0.2902).opacity(0.28),
        bad:           Color(red: 0.7765, green: 0.4157, blue: 0.3686)
    )
}
