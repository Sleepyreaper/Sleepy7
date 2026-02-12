import SwiftUI

struct WinOverlayView: View {
    let winnerName: String
    let winnerScore: Int
    let onDismiss: () -> Void
    let onNewGame: () -> Void
    
    @State private var appear = false
    @State private var confettiAnimation = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Trophy icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [GameTheme.goldAccent, Color(hex: "B8860B")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: GameTheme.goldAccent.opacity(0.8), radius: 20, x: 0, y: 0)
                    
                    Text("🏆")
                        .font(.system(size: 60))
                }
                .scaleEffect(appear ? 1.0 : 0.3)
                .rotationEffect(.degrees(appear ? 0 : -180))
                
                // Winner text
                VStack(spacing: 12) {
                    Text("WINNER!")
                        .font(.custom("Marker Felt", size: 64))
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [GameTheme.goldAccent, GameTheme.champagne],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: GameTheme.goldAccent.opacity(0.8), radius: 16, x: 0, y: 0)
                    
                    Text(winnerName)
                        .font(.custom("Marker Felt", size: 42))
                        .foregroundStyle(Color.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                    
                    Text("\(winnerScore) Points")
                        .font(.custom("Marker Felt", size: 32))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: onNewGame) {
                        Text("New Game")
                            .font(.custom("Marker Felt", size: 22))
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.white, GameTheme.champagne],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(maxWidth: 280)
                            .padding(.vertical, 16)
                            .background(
                                ZStack {
                                    LinearGradient(
                                        colors: [GameTheme.vegasRed, GameTheme.deepRed],
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [GameTheme.goldAccent.opacity(0.8), GameTheme.goldAccent.opacity(0.3)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: GameTheme.vegasRed.opacity(0.6), radius: 12, x: 0, y: 5)
                    }
                    
                    Button(action: onDismiss) {
                        Text("Continue")
                            .font(.custom("Marker Felt", size: 18))
                            .foregroundStyle(GameTheme.champagne)
                            .frame(maxWidth: 280)
                            .padding(.vertical, 14)
                            .background(Color.black.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(GameTheme.goldAccent.opacity(0.4), lineWidth: 1.5)
                            )
                    }
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            }
            
            // Confetti particles
            ForEach(0..<30, id: \.self) { index in
                ConfettiPiece(index: index)
                    .opacity(confettiAnimation ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appear = true
            }
            
            withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
                confettiAnimation = true
            }
        }
    }
}

private struct ConfettiPiece: View {
    let index: Int
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    private let colors: [Color] = [
        GameTheme.goldAccent,
        GameTheme.vegasRed,
        GameTheme.champagne,
        Color(hex: "B8860B"),
        Color(hex: "DC143C"),
        Color(hex: "F5E6D3")
    ]
    
    var body: some View {
        let randomColor = colors[index % colors.count]
        let randomSize = CGFloat.random(in: 8...16)
        let shapes = ["●", "■", "▲", "★"]
        let randomShape = shapes[index % shapes.count]
        
        Text(randomShape)
            .font(.system(size: randomSize))
            .foregroundStyle(randomColor)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                let startX = CGFloat.random(in: -150...150)
                let endX = startX + CGFloat.random(in: -80...80)
                let duration = Double.random(in: 2.5...4.0)
                
                xOffset = startX
                
                withAnimation(.easeIn(duration: duration)) {
                    yOffset = 900
                    xOffset = endX
                }
                
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    rotation = 360 * Double.random(in: 2...4)
                }
            }
    }
}
