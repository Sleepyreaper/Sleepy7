import SwiftUI

struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: LuxuryTheme.cornerRadiusLarge, style: .continuous)
                    .fill(LuxuryTheme.panelFill(for: colorScheme))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: LuxuryTheme.cornerRadiusLarge, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: LuxuryTheme.cornerRadiusLarge, style: .continuous)
                    .strokeBorder(LuxuryTheme.panelStroke(for: colorScheme), lineWidth: 1.2)
            )
            .shadow(color: LuxuryTheme.shadowColor, radius: 30, x: 0, y: 18)
    }
}