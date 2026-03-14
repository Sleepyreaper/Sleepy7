import SwiftUI

/// Shim layer preserving existing `GameTheme.*` call-sites while delegating
/// to the newer, more dubiously named `LuxuryTheme`.
enum GameTheme {
    // Typography
    static func titleFont(_ size: CGFloat) -> Font { .custom("Marker Felt", size: size).weight(.bold) }
    static func bodyFont(_ size: CGFloat)  -> Font { .custom("Avenir Next", size: size) }

    // Common colors
    static var goldAccent: Color  { LuxuryTheme.accentGold(for: colorScheme) }
    static var champagne: Color   { Color(red: 0.95, green: 0.89, blue: 0.75) }
    static var vegasRed: Color    { Color(red: 0.56, green: 0.10, blue: 0.14) }
    static var deepRed: Color     { Color(red: 0.38, green: 0.03, blue: 0.08) }

    static var textPrimary:  Color { Color.primary }
    static var textSecondary: Color { Color.secondary }

    private static var colorScheme: ColorScheme {
        // Reasonable default; SwiftUI doesn’t expose global scheme, views call can override
        UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
    }
}