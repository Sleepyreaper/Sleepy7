import SwiftUI

enum LuxuryTheme {
    static let cornerRadiusLarge: CGFloat = 28
    static let cornerRadiusMedium: CGFloat = 20
    static let cornerRadiusSmall: CGFloat = 14

    static let shadowColor = Color.black.opacity(0.22)

    static func backgroundTop(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.09, green: 0.06, blue: 0.16) : Color(red: 0.95, green: 0.93, blue: 0.99)
    }

    static func backgroundBottom(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.02, green: 0.05, blue: 0.10) : Color(red: 0.89, green: 0.95, blue: 0.99)
    }

    static func panelFill(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.10) : Color.white.opacity(0.62)
    }

    static func panelStroke(for scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: scheme == .dark
                ? [Color.white.opacity(0.18), Color.yellow.opacity(0.18), Color.clear]
                : [Color.white.opacity(0.95), Color.purple.opacity(0.18), Color.clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func accentGold(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 1.0, green: 0.82, blue: 0.38) : Color(red: 0.75, green: 0.54, blue: 0.11)
    }

    static func accentViolet(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.64, green: 0.46, blue: 1.0) : Color(red: 0.39, green: 0.24, blue: 0.80)
    }

    static func accentEmerald(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.22, green: 0.89, blue: 0.68) : Color(red: 0.00, green: 0.52, blue: 0.43)
    }

    static func danger(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 1.0, green: 0.36, blue: 0.40) : Color(red: 0.82, green: 0.15, blue: 0.22)
    }
}