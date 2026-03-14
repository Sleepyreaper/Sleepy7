import SwiftUI

struct OnboardingFlowView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack {
            LuxuryBackgroundView()

            VStack(spacing: 20) {
                topBar

                Spacer(minLength: 0)

                GlassCard {
                    VStack(spacing: 22) {
                        Flip7TutorialAnimationView(pageIndex: viewModel.currentPage)

                        Text(viewModel.pages[viewModel.currentPage].title)
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)

                        Text(viewModel.pages[viewModel.currentPage].body)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 560)

                        pageIndicators

                        Button(viewModel.currentPage == viewModel.pages.count - 1 ? "Enter the Table" : "Continue") {
                            viewModel.advance()
                        }
                        .buttonStyle(LuxuryPrimaryButtonStyle())
                        .accessibilityHint("Advances onboarding")
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: 760)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? 16 : 24)
            .padding(.vertical, 24)
        }
        .navigationBarBackButtonHidden(true)
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button("Skip") {
                viewModel.skip()
            }
            .buttonStyle(LuxurySecondaryButtonStyle())
            .accessibilityHint("Skips onboarding and opens the main menu")
        }
    }

    private var pageIndicators: some View {
        HStack(spacing: 8) {
            ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, _ in
                Capsule()
                    .fill(index == viewModel.currentPage ? .white : .white.opacity(0.25))
                    .frame(width: index == viewModel.currentPage ? 28 : 10, height: 10)
                    .animation(.spring(response: 0.28, dampingFraction: 0.82), value: viewModel.currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tutorial page \(viewModel.currentPage + 1) of \(viewModel.pages.count)")
    }
}