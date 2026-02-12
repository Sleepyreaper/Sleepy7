import SwiftUI

struct CardAnimationSplash: View {
    @State private var cardPositions: [CGFloat] = [0, 0, 0]
    @State private var cardRotations: [Double] = [0, 0, 0]
    @State private var cardOpacities: [Double] = [0, 0, 0]
    @State private var titleOpacity = 0.0
    @State private var splashComplete = false
    @State private var randomCards: [Int] = []

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            GameBackgroundView()

            VStack(spacing: 0) {
                Spacer()

                // Cards row
                HStack(spacing: -30) {
                    ForEach(0..<3, id: \.self) { index in
                        if randomCards.count > index {
                            CardFrontView(card: Card(.number(randomCards[index])))
                                .frame(width: 100, height: 140)
                                .rotationEffect(.degrees(cardRotations[index]))
                                .offset(x: cardPositions[index])
                                .opacity(cardOpacities[index])
                        } else {
                            CardBackView()
                                .frame(width: 100, height: 140)
                                .rotationEffect(.degrees(cardRotations[index]))
                                .offset(x: cardPositions[index])
                                .opacity(cardOpacities[index])
                        }
                    }
                }
                .frame(height: 150)

                // Logo below cards
                VStack(spacing: 8) {
                    Text("Sleepy 7")
                        .font(GameTheme.titleFont(52))
                        .foregroundStyle(GameTheme.textPrimary)
                        .opacity(titleOpacity)
                }
                .frame(height: 80)

                Spacer()
            }
        }
        .onAppear {
            randomCards = generateRandomCards()
            animateCards()
        }
    }

    private func generateRandomCards() -> [Int] {
        let available = [0, 1, 2, 3, 7]
        return Array(available.shuffled().prefix(3))
    }

    private func animateCards() {
        for index in 0..<3 {
            withAnimation(.easeOut(duration: 0.6).delay(Double(index) * 0.15)) {
                cardOpacities[index] = 1.0
                cardPositions[index] = CGFloat(index - 1) * 40
                cardRotations[index] = CGFloat(index - 1) * 15
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.8)) {
                titleOpacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    splashComplete = true
                }
                onComplete()
            }
        }
    }
}

#Preview {
    CardAnimationSplash(onComplete: {})
}
