import SwiftUI

struct TimeOfDayTheme {
    let background: Color
    let surface: Color
    let accent: Color
    let text: Color
    let textSecondary: Color
    let holdButtonIdle: Color
    let holdButtonActive: Color

    static func current(_ tod: TimeOfDay) -> TimeOfDayTheme {
        switch tod {
        case .morning:
            return TimeOfDayTheme(
                background: Color(red: 0.08, green: 0.06, blue: 0.04),
                surface: Color(red: 0.14, green: 0.10, blue: 0.06),
                accent: Color(red: 0.85, green: 0.65, blue: 0.20),
                text: Color(red: 0.95, green: 0.90, blue: 0.80),
                textSecondary: Color(red: 0.65, green: 0.55, blue: 0.40),
                holdButtonIdle: Color(red: 0.75, green: 0.55, blue: 0.15),
                holdButtonActive: Color(red: 0.95, green: 0.75, blue: 0.25)
            )
        case .noon:
            return TimeOfDayTheme(
                background: Color(red: 0.06, green: 0.08, blue: 0.12),
                surface: Color(red: 0.10, green: 0.13, blue: 0.18),
                accent: Color(red: 0.35, green: 0.65, blue: 0.90),
                text: Color(red: 0.88, green: 0.92, blue: 0.97),
                textSecondary: Color(red: 0.50, green: 0.60, blue: 0.72),
                holdButtonIdle: Color(red: 0.25, green: 0.55, blue: 0.80),
                holdButtonActive: Color(red: 0.40, green: 0.70, blue: 0.95)
            )
        case .night:
            return TimeOfDayTheme(
                background: Color(red: 0.05, green: 0.06, blue: 0.10),
                surface: Color(red: 0.09, green: 0.10, blue: 0.15),
                accent: Color(red: 0.55, green: 0.45, blue: 0.30),
                text: Color(red: 0.88, green: 0.85, blue: 0.78),
                textSecondary: Color(red: 0.52, green: 0.48, blue: 0.40),
                holdButtonIdle: Color(red: 0.40, green: 0.32, blue: 0.22),
                holdButtonActive: Color(red: 0.65, green: 0.52, blue: 0.35)
            )
        }
    }
}
