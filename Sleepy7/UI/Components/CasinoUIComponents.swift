import SwiftUI

enum CasinoButtonStyle {
    case primary
    case secondary
    case destructive
}

struct CasinoButton: View {
    let title: String
    let systemImage: String?
    let style: CasinoButtonStyle
    let isEnabled: Bool
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        style: CasinoButtonStyle = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return DesignSystem.Colors.buttonPrimaryBackground
        case .secondary:
            return DesignSystem.Colors.buttonSecondaryBackground
        case .destructive:
            return DesignSystem.Colors.buttonDangerBackground
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return DesignSystem.Colors.buttonPrimaryForeground
        case .secondary:
            return DesignSystem.Colors.buttonSecondaryForeground
        case .destructive:
            return DesignSystem.Colors.buttonDangerForeground
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .imageScale(.medium)
                }

                Text(title)
                    .font(DesignSystem.Typography.bodyStrong)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: DesignSystem.Layout.minimumTouchTarget)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                    .fill(backgroundColor.opacity(isEnabled ? 1.0 : 0.45))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .foregroundStyle(foregroundColor.opacity(isEnabled ? 1.0 : 0.7))
            .shadow(color: style == .primary ? DesignSystem.Colors.accent.opacity(0.22) : .clear, radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityAddTraits(.isButton)
    }
}

struct StatPill: View {
    let label: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundStyle(DesignSystem.Colors.textMuted)

            Text(value)
                .font(DesignSystem.Typography.title3)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                .fill(DesignSystem.Colors.surfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                .stroke(accent.opacity(0.28), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

struct ScreenContainer<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let content: Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(DesignSystem.Typography.body)
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                content
            }
            .frame(maxWidth: DesignSystem.Layout.maxContentWidth)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xxxl)
            .frame(maxWidth: .infinity)
        }
        .screenBackground()
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let systemImage: String?
    @ViewBuilder let content: Content

    init(title: String, systemImage: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(DesignSystem.Colors.accent)
                }

                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
            }

            content
        }
        .padding(DesignSystem.Spacing.lg)
        .casinoCardStyle()
    }
}

struct DisclosureNoticeCard: View {
    let title: String
    let bodyText: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            Image(systemName: systemImage)
                .foregroundStyle(DesignSystem.Colors.info)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.bodyStrong)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)

                Text(bodyText)
                    .font(DesignSystem.Typography.footnote)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                .fill(DesignSystem.Colors.surfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                .stroke(DesignSystem.Colors.info.opacity(0.25), lineWidth: 1)
        )
    }
}