import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScreenContainer(
                title: "Rules",
                subtitle: "Everything players need, in a cleaner format with stronger hierarchy and better readability."
            ) {
                SectionCard(title: "Objective", systemImage: "target") {
                    rulesText("Build the strongest score you can without busting. Number cards add to your total, modifiers boost your hand, and special actions can swing the round.")
                }

                SectionCard(title: "How Busting Works", systemImage: "exclamationmark.octagon.fill") {
                    rulesBullet("Drawing a duplicate number can bust your hand.")
                    rulesBullet("A busted hand scores zero for the round.")
                    rulesBullet("Second Chance may protect you from one duplicate depending on the game state.")
                }

                SectionCard(title: "Special Cards", systemImage: "sparkles.rectangle.stack.fill") {
                    rulesBullet("Freeze: lock another player out of further actions.")
                    rulesBullet("Flip Three: reveal three cards in sequence for a dramatic turn swing.")
                    rulesBullet("Second Chance: protection against a bust-causing duplicate.")
                }

                SectionCard(title: "Modifiers", systemImage: "plus.forwardslash.minus") {
                    rulesBullet("Flat modifiers add bonus points to your final round score.")
                    rulesBullet("x2 doubles your subtotal before flat bonuses are applied.")
                    rulesBullet("Flip Seven grants an extra bonus when achieved.")
                }

                SectionCard(title: "Accessibility", systemImage: "figure.wave.circle.fill") {
                    rulesBullet("Dynamic Type is supported throughout the interface.")
                    rulesBullet("Buttons and labels include VoiceOver-friendly text.")
                    rulesBullet("High-contrast colors are used to keep the table legible.")
                }
            }
            .navigationTitle("Rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(DesignSystem.Colors.accent)
                }
            }
        }
    }

    private func rulesText(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Typography.body)
            .foregroundStyle(DesignSystem.Colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func rulesBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "circle.fill")
                .font(.system(size: 7))
                .foregroundStyle(DesignSystem.Colors.accent)
                .padding(.top, 6)

            Text(text)
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}