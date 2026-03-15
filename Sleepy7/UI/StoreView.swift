import SwiftUI
import StoreKit

struct StoreView: View {
    @EnvironmentObject private var session: AppSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScreenContainer(
                title: "Store",
                subtitle: "Elegant upgrades, native purchases, and a slightly more defensible entitlement model."
            ) {
                SectionCard(title: "Featured", systemImage: "sparkles") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Support Sleepy7 and elevate the table.")
                            .font(DesignSystem.Typography.bodyStrong)
                            .foregroundStyle(DesignSystem.Colors.textPrimary)

                        Text("Purchases restore automatically. Entitlements can also be confirmed by a secure server when configured.")
                            .font(DesignSystem.Typography.footnote)
                            .foregroundStyle(DesignSystem.Colors.textSecondary)

                        HStack(spacing: DesignSystem.Spacing.sm) {
                            CasinoButton("Restore Purchases", systemImage: "arrow.clockwise", style: .secondary) {
                                Task { await session.iapManager.restorePurchases() }
                            }
                        }
                    }
                }

                SectionCard(title: "Upgrades", systemImage: "bag.fill") {
                    if session.iapManager.isLoadingProducts {
                        ProgressView("Loading products…")
                            .tint(DesignSystem.Colors.accent)
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if let errorMessage = session.iapManager.lastErrorMessage, session.iapManager.products.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("We couldn’t load the store.")
                                .font(DesignSystem.Typography.bodyStrong)
                                .foregroundStyle(DesignSystem.Colors.textPrimary)

                            Text(errorMessage)
                                .font(DesignSystem.Typography.footnote)
                                .foregroundStyle(DesignSystem.Colors.danger)

                            CasinoButton("Try Again", systemImage: "arrow.clockwise", style: .secondary) {
                                Task { await session.iapManager.loadProducts() }
                            }
                        }
                    } else if session.iapManager.products.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("No products available right now.")
                                .font(DesignSystem.Typography.bodyStrong)
                                .foregroundStyle(DesignSystem.Colors.textPrimary)

                            Text("Check your StoreKit configuration or App Store Connect products.")
                                .font(DesignSystem.Typography.footnote)
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                    } else {
                        LazyVStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(session.iapManager.products, id: \.id) { product in
                                StoreProductCard(
                                    product: product,
                                    isPurchased: session.iapManager.isPurchased(product.id),
                                    isProcessing: session.iapManager.purchaseInProgressID == product.id
                                ) {
                                    Task { await session.iapManager.purchase(product) }
                                }
                            }
                        }
                    }
                }

                if let errorMessage = session.iapManager.lastErrorMessage, !errorMessage.isEmpty {
                    SectionCard(title: "Store Status", systemImage: "exclamationmark.triangle.fill") {
                        Text(errorMessage)
                            .font(DesignSystem.Typography.footnote)
                            .foregroundStyle(DesignSystem.Colors.warning)
                    }
                }

                SectionCard(title: "What You Get", systemImage: "star.circle.fill") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        benefitRow("Ad-Free Upgrade", detail: "Removes banner and rewarded ad prompts.")
                        benefitRow("Premium Themes", detail: "Unlocks future colorways and visual table styles.")
                        benefitRow("Restore Support", detail: "Restores prior purchases and refreshes local entitlements.")
                        benefitRow("Verification Ready", detail: "Supports server-side entitlement confirmation when backend is available.")
                    }
                }
            }
            .navigationTitle("Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(DesignSystem.Colors.accent)
                }
            }
            .task {
                await session.iapManager.loadProducts()
                await session.iapManager.refreshEntitlements()
            }
        }
    }

    @ViewBuilder
    private func benefitRow(_ title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(DesignSystem.Colors.success)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.bodyStrong)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)

                Text(detail)
                    .font(DesignSystem.Typography.footnote)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
        }
    }
}

private struct StoreProductCard: View {
    let product: Product
    let isPurchased: Bool
    let isProcessing: Bool
    let onBuy: () -> Void

    private var productAccent: Color {
        switch product.id {
        case StoreConfiguration.adFreeProductID:
            return DesignSystem.Colors.info
        case StoreConfiguration.premiumThemesProductID:
            return DesignSystem.Colors.accent
        default:
            return DesignSystem.Colors.success
        }
    }

    private var productIcon: String {
        switch product.id {
        case StoreConfiguration.adFreeProductID:
            return "nosign"
        case StoreConfiguration.premiumThemesProductID:
            return "paintpalette.fill"
        default:
            return "bag.fill"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                        .fill(productAccent.opacity(0.16))
                        .frame(width: 52, height: 52)

                    Image(systemName: productIcon)
                        .foregroundStyle(productAccent)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(DesignSystem.Typography.headline)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)

                    Text(product.description)
                        .font(DesignSystem.Typography.footnote)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            HStack(spacing: DesignSystem.Spacing.sm) {
                Text(product.displayPrice)
                    .font(DesignSystem.Typography.title3)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)

                Spacer()

                if isPurchased {
                    Label("Purchased", systemImage: "checkmark.circle.fill")
                        .font(DesignSystem.Typography.bodyStrong)
                        .foregroundStyle(DesignSystem.Colors.success)
                        .accessibilityLabel("\(product.displayName), purchased")
                } else {
                    CasinoButton(
                        isProcessing ? "Processing…" : "Buy Now",
                        systemImage: "creditcard.fill",
                        style: .primary,
                        isEnabled: !isProcessing,
                        action: onBuy
                    )
                    .frame(maxWidth: 180)
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.lg, style: .continuous)
                .fill(DesignSystem.Colors.surfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.lg, style: .continuous)
                .stroke(productAccent.opacity(0.28), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
    }
}