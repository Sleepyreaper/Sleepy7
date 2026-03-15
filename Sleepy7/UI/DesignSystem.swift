import SwiftUI

enum DesignSystem {
    enum Colors {
        static let background = Color(red: 10 / 255, green: 14 / 255, blue: 24 / 255)
        static let backgroundSecondary = Color(red: 18 / 255, green: 24 / 255, blue: 38 / 255)
        static let surface = Color(red: 23 / 255, green: 30 / 255, blue: 46 / 255)
        static let surfaceElevated = Color(red: 31 / 255, green: 40 / 255, blue: 61 / 255)
        static let surfaceMuted = Color(red: 39 / 255, green: 48 / 255, blue: 71 / 255)

        static let textPrimary = Color.white
        static let textSecondary = Color(red: 219 / 255, green: 225 / 255, blue: 236 / 255)
        static let textMuted = Color(red: 165 / 255, green: 174 / 255, blue: 193 / 255)

        static let accent = Color(red: 250 / 255, green: 199 / 255, blue: 88 / 255)
        static let accentStrong = Color(red: 255 / 255, green: 181 / 255, blue: 44 / 255)
        static let accentSoft = Color(red: 255 / 255, green: 231 / 255, blue: 173 / 255)

        static let success = Color(red: 62 / 255, green: 201 / 255, blue: 126 / 255)
        static let warning = Color(red: 255 / 255, green: 173 / 255, blue: 92 / 255)
        static let danger = Color(red: 255 / 255, green: 94 / 255, blue: 98 / 255)
        static let info = Color(red: 104 / 255, green: 179 / 255, blue: 255 / 255)

        static let border = Color.white.opacity(0.10)
        static let hairline = Color.white.opacity(0.08)
        static let shadow = Color.black.opacity(0.28)

        static let overlay = Color.black.opacity(0.55)
        static let cardGlow = accent.opacity(0.22)

        static let adPlaceholderBackground = Color(red: 28 / 255, green: 34 / 255, blue: 48 / 255)
        static let adPlaceholderBorder = accent.opacity(0.35)

        static let buttonPrimaryBackground = accent
        static let buttonPrimaryForeground = Color.black

        static let buttonSecondaryBackground = surfaceElevated
        static let buttonSecondaryForeground = textPrimary

        static let buttonDangerBackground = danger
        static let buttonDangerForeground = Color.white
    }

    enum Typography {
        static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title = Font.system(.title, design: .rounded).weight(.bold)
        static let title2 = Font.system(.title2, design: .rounded).weight(.bold)
        static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)
        static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
        static let subheadline = Font.system(.subheadline, design: .rounded)
        static let body = Font.system(.body, design: .rounded)
        static let bodyStrong = Font.system(.body, design: .rounded).weight(.semibold)
        static let callout = Font.system(.callout, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded)
        static let captionStrong = Font.system(.caption, design: .rounded).weight(.semibold)
        static let footnote = Font.system(.footnote, design: .rounded)
        static let numberHero = Font.system(size: 42, weight: .heavy, design: .rounded)
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
    }

    enum Radius {
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let pill: CGFloat = 999
    }

    enum Shadow {
        static let card = (color: Colors.shadow, radius: CGFloat(20), x: CGFloat(0), y: CGFloat(10))
        static let glow = (color: Colors.cardGlow, radius: CGFloat(18), x: CGFloat(0), y: CGFloat(0))
    }

    enum Layout {
        static let maxContentWidth: CGFloat = 720
        static let maxReadableWidth: CGFloat = 640
        static let bottomAdHeight: CGFloat = 74
        static let minimumTouchTarget: CGFloat = 48
    }

    enum Copy {
        static let gameCenterDisclosure = "We only use your Game Center name to personalize local Game Center-related experiences such as profile display or future leaderboards."
        static let adConsentDisclosure = "Ads are shown only after applicable consent and platform permission flows are completed."
        static let purchaseDisclosure = "Purchases are verified locally and may be checked with a secure server for authoritative entitlement status."
    }
}

extension LinearGradient {
    static let casinoBackground = LinearGradient(
        colors: [
            DesignSystem.Colors.background,
            DesignSystem.Colors.backgroundSecondary,
            Color.black
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGold = LinearGradient(
        colors: [
            DesignSystem.Colors.accentSoft,
            DesignSystem.Colors.accent,
            DesignSystem.Colors.accentStrong
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glassStroke = LinearGradient(
        colors: [
            Color.white.opacity(0.22),
            Color.white.opacity(0.03)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct CasinoCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DesignSystem.Colors.surface.opacity(0.94))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg, style: .continuous)
                    .stroke(LinearGradient.glassStroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg, style: .continuous))
            .shadow(
                color: DesignSystem.Shadow.card.color,
                radius: DesignSystem.Shadow.card.radius,
                x: DesignSystem.Shadow.card.x,
                y: DesignSystem.Shadow.card.y
            )
    }
}

extension View {
    func casinoCardStyle() -> some View {
        modifier(CasinoCardModifier())
    }

    func screenBackground() -> some View {
        background(LinearGradient.casinoBackground.ignoresSafeArea())
    }
}