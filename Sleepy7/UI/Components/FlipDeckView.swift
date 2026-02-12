import SwiftUI

struct FlipDeckView: View {
    let card: Card?
    let isFaceUp: Bool
    let duplicateCard: Card?
    let showDuplicate: Bool
    let animateToHand: Bool

    var body: some View {
        ZStack {
            DeckStackView()
                .frame(width: 130, height: 180)

            if let card {
                FlippingCardView(card: card, isFaceUp: isFaceUp)
                    .frame(width: 140, height: 200)
                    .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                    .offset(x: 90)
                    .scaleEffect(animateToHand ? 0.3 : 1.0)
                    .offset(y: animateToHand ? 400 : 0)
                    .opacity(animateToHand ? 0 : 1)
                
                // Show duplicate card slightly offset if exists
                if showDuplicate, let duplicateCard {
                    FlippingCardView(card: duplicateCard, isFaceUp: true)
                        .frame(width: 140, height: 200)
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                        .offset(x: 100, y: -10)
                }
            } else {
                CardBackView()
                    .frame(width: 140, height: 200)
                    .opacity(0.8)
                    .offset(x: 90)
            }
        }
    }
}
