import SwiftUI

struct CardFrontView: View {
    let card: Card

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 16)

        ZStack {
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(1.08)
                    .clipped()
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    Text(titleText)
                        .font(.system(size: 72, weight: .black, design: .default))
                        .tracking(2)
                        .foregroundStyle(numberTextColor)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(cardBackgroundColor)
                .overlay(alignment: .topLeading) {
                    DecorativeElement()
                        .offset(x: 16, y: 16)
                }
                .overlay(alignment: .bottomTrailing) {
                    DecorativeElement()
                        .offset(x: -16, y: -16)
                        .rotationEffect(.degrees(180))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(shape)
        .overlay(
            shape.stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
    }

    private var titleText: String {
        switch card.kind {
        case .number(let value):
            return String(value)
        case .action(let action):
            return action.rawValue
        case .modifier(let modifier):
            return modifier.rawValue
        }
    }

    private var subtitleText: String? {
        switch card.kind {
        case .number:
            return "Number"
        case .action:
            return "Action"
        case .modifier:
            return "Modifier"
        }
    }

    private var cardBackgroundColor: Color {
        switch card.kind {
        case .number(let value):
            return numberCardColor(value)
        case .action:
            return Color(hex: "9B59B6")
        case .modifier:
            return Color(hex: "E74C3C")
        }
    }

    private var numberTextColor: Color {
        switch card.kind {
        case .number(let value):
            return numberTextColorForValue(value)
        default:
            return .white
        }
    }

    private func numberCardColor(_ value: Int) -> Color {
        let colors: [Color] = [
            Color(hex: "3498DB"),  // 4: Blue
            Color(hex: "2ECC71"),  // 5: Green
            Color(hex: "F39C12"),  // 6: Orange
            Color(hex: "E74C3C"),  // 7: Red
            Color(hex: "9B59B6"),  // 8: Purple
            Color(hex: "1ABC9C"),  // 9: Turquoise
            Color(hex: "34495E"),  // 10: Dark slate
            Color(hex: "F1C40F"),  // 11: Yellow
            Color(hex: "E67E22"),  // 12: Dark orange
        ]
        let index = max(0, min(value - 4, colors.count - 1))
        return index >= 0 && index < colors.count ? colors[index] : Color(hex: "95A5A6")
    }

    private func numberTextColorForValue(_ value: Int) -> Color {
        switch value {
        case 4, 5, 9:
            return .black
        default:
            return .white
        }
    }

    private var imageName: String? {
        switch card.kind {
        case .number(let value) where value == 0:
            return "Card0"
        case .number(let value) where value == 1:
            return "Card1"
        case .number(let value) where value == 2:
            return "Card2"
        case .number(let value) where value == 3:
            return "Card3"
        case .number(let value) where value == 7:
            return "Card7"
        case .action(.freeze):
            return "Freeze"
        case .action(.secondChance):
            return "SecondChance"
        default:
            return nil
        }
    }
}

private struct DecorativeElement: View {
    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 8, height: 8)
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 6, height: 6)
                .offset(x: 4)
        }
    }
}

struct CardBackView: View {
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 16)
        ZStack {
            Image("Back")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        }
        .clipShape(shape)
        .overlay(
            shape.stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
    }
}

struct FlippingCardView: View {
    let card: Card
    let isFaceUp: Bool

    var body: some View {
        ZStack {
            CardBackView()
                .opacity(isFaceUp ? 0.0 : 1.0)
            CardFrontView(card: card)
                .opacity(isFaceUp ? 1.0 : 0.0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(.degrees(isFaceUp ? 180 : 0), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardMiniView: View {
    let label: String
    let subtitle: String
    let imageName: String?

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 12)
        let bgColor = backgroundColorForLabel(label)

        ZStack {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 80)
                    .clipped()
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    Text(label)
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(textColorForBackground(bgColor))
                        .lineLimit(1)
                    Spacer()
                }
                .frame(width: 60, height: 80)
                .background(bgColor)
            }
        }
        .frame(width: 60, height: 80)
        .clipShape(shape)
        .overlay(
            shape.stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }

    private func backgroundColorForLabel(_ label: String) -> Color {
        if let value = Int(label), value >= 4 && value <= 12 {
            let colors: [Color] = [
                Color(hex: "3498DB"),
                Color(hex: "2ECC71"),
                Color(hex: "F39C12"),
                Color(hex: "E74C3C"),
                Color(hex: "9B59B6"),
                Color(hex: "1ABC9C"),
                Color(hex: "34495E"),
                Color(hex: "F1C40F"),
                Color(hex: "E67E22"),
            ]
            let index = value - 4
            return index >= 0 && index < colors.count ? colors[index] : Color(hex: "95A5A6")
        }
        return Color(hex: "9B59B6")  // Action/Modifier default
    }

    private func textColorForBackground(_ bg: Color) -> Color {
        // Check if it's the light colors that need dark text
        if bg == Color(hex: "2ECC71") || bg == Color(hex: "F39C12") || bg == Color(hex: "1ABC9C") || bg == Color(hex: "F1C40F") {
            return .black
        }
        return .white
    }
}

struct DeckStackView: View {
    var body: some View {
        ZStack {
            CardBackView()
                .offset(x: -6, y: -6)
            CardBackView()
                .offset(x: -3, y: -3)
            CardBackView()
        }
    }
}
