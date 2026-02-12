import SwiftUI

struct PrimaryGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Marker Felt", size: 20))
            .fontWeight(.bold)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.white, GameTheme.champagne],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [
                            GameTheme.vegasRed,
                            GameTheme.deepRed
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.clear,
                            Color.black.opacity(0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [GameTheme.goldAccent.opacity(0.7), GameTheme.goldAccent.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            }
            .shadow(color: GameTheme.vegasRed.opacity(0.5), radius: 12, x: 0, y: 4)
            .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Marker Felt", size: 18))
            .foregroundStyle(GameTheme.champagne)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.25))
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            GameTheme.deepRed.opacity(0.15),
                                            Color.black.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                GameTheme.goldAccent.opacity(0.4),
                                GameTheme.goldAccent.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
