import SwiftUI

struct MainMenuBackgroundView: View {
    var body: some View {
        ZStack {
            // Rich casino background
            LinearGradient(
                colors: [Color(hex: "1A0A0A"), Color(hex: "2D1515")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Deep red casino carpet glow
            RadialGradient(
                colors: [
                    GameTheme.vegasRed.opacity(0.25),
                    Color.clear
                ],
                center: .center,
                startRadius: 80,
                endRadius: 450
            )
            
            // Gold accent light - top left
            Circle()
                .fill(
                    RadialGradient(
                        colors: [GameTheme.goldAccent.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .blur(radius: 10)
                .offset(x: -120, y: -180)
            
            // Crimson spotlight - bottom right
            Circle()
                .fill(
                    RadialGradient(
                        colors: [GameTheme.deepRed.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 30,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .blur(radius: 15)
                .offset(x: 100, y: 220)
            
            // Subtle gold shimmer
            Circle()
                .fill(
                    RadialGradient(
                        colors: [GameTheme.champagne.opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 40,
                        endRadius: 180
                    )
                )
                .frame(width: 320, height: 320)
                .blur(radius: 12)
                .offset(x: 40, y: -80)
        }
        .ignoresSafeArea()
    }
}

struct MainMenuHeroView: View {
    @State private var floatUp = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 2)
                .frame(width: 220, height: 220)
                .blur(radius: 1)

            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                .frame(width: 280, height: 280)

            HStack(spacing: -22) {
                CardFrontView(card: Card(.number(1)))
                    .frame(width: 100, height: 140)
                    .rotationEffect(.degrees(-18))
                    .offset(x: -10, y: floatUp ? -6 : 6)
                CardFrontView(card: Card(.number(7)))
                    .frame(width: 120, height: 168)
                    .rotationEffect(.degrees(0))
                    .offset(y: floatUp ? -10 : 10)
                    .shadow(color: Color(hex: "1ABC9C").opacity(0.35), radius: 18, x: 0, y: 10)
                CardFrontView(card: Card(.number(3)))
                    .frame(width: 100, height: 140)
                    .rotationEffect(.degrees(18))
                    .offset(x: 10, y: floatUp ? -6 : 6)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                floatUp.toggle()
            }
        }
    }
}

struct MainMenuPrimaryButton: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.custom("Marker Felt", size: 24))
            .fontWeight(.bold)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.white, GameTheme.champagne],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    // Base crimson gradient
                    LinearGradient(
                        colors: [
                            GameTheme.vegasRed,
                            GameTheme.deepRed
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Shine overlay
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
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [GameTheme.goldAccent.opacity(0.8), GameTheme.goldAccent.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: GameTheme.vegasRed.opacity(0.6), radius: 15, x: 0, y: 5)
            .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
    }
}

struct MainMenuSecondaryButton: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.custom("Marker Felt", size: 19))
            .foregroundStyle(GameTheme.champagne)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black.opacity(0.3))
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            GameTheme.deepRed.opacity(0.2),
                                            Color.black.opacity(0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: [
                                GameTheme.goldAccent.opacity(0.5),
                                GameTheme.goldAccent.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    ZStack {
        MainMenuBackgroundView()
        VStack(spacing: 20) {
            MainMenuHeroView()
            MainMenuPrimaryButton(title: "Start Game")
            HStack {
                MainMenuSecondaryButton(title: "Rules")
                MainMenuSecondaryButton(title: "Stats")
            }
        }
        .padding()
    }
}
