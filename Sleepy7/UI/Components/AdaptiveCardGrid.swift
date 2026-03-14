import SwiftUI

struct AdaptiveCardGrid: View {
    let cards: [TableCardViewData]

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 88, maximum: 132), spacing: 12, alignment: .top)]
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            ForEach(cards) { card in
                GameCardView(card: card)
            }
        }
    }
}