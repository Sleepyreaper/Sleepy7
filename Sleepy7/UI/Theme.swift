import SwiftUI

enum GameTheme {
    static let backgroundTop = Color(hex: "1E1B2E")
    static let backgroundBottom = Color(hex: "0F1216")
    static let accent = Color(hex: "E86A33")
    static let accentSoft = Color(hex: "F2B97F")
    static let textPrimary = Color(hex: "F8F2E8")
    static let textSecondary = Color(hex: "CDBFAF")
    static let cardFront = Color(hex: "F4F1EA")
    static let cardBack = Color(hex: "20364F")
    static let cardEdge = Color(hex: "B59A7A")
    
    // Vegas table colors
    static let feltGreen = Color(hex: "0B6623")
    static let feltDark = Color(hex: "064018")
    static let tableEdge = Color(hex: "3E2723")
    static let vegasRed = Color(hex: "DC143C")
    static let deepRed = Color(hex: "B22222")
    static let goldAccent = Color(hex: "D4AF37")
    static let champagne = Color(hex: "F5E6D3")

    static func titleFont(_ size: CGFloat) -> Font {
        Font.custom("Avenir Next Bold", size: size)
    }

    static func bodyFont(_ size: CGFloat) -> Font {
        Font.custom("Avenir Next", size: size)
    }
}

struct GameBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [GameTheme.backgroundTop, GameTheme.backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(GameTheme.accent.opacity(0.18))
                .frame(width: 220, height: 220)
                .offset(x: 40, y: -80)
        }
        .overlay(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 40)
                .fill(GameTheme.accentSoft.opacity(0.12))
                .frame(width: 260, height: 180)
                .rotationEffect(.degrees(-12))
                .offset(x: -60, y: 70)
        }
        .ignoresSafeArea()
    }
}

struct VegasTableBackgroundView: View {
    var body: some View {
        ZStack {
            // Dark ambient background
            Color(hex: "1A0F0A")
                .ignoresSafeArea()
            
            // Felt table surface with radial gradient
            RadialGradient(
                colors: [
                    GameTheme.feltGreen,
                    GameTheme.feltDark
                ],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .overlay {
                // Subtle noise texture simulation
                Canvas { context, size in
                    for _ in 0..<150 {
                        let x = CGFloat.random(in: 0...size.width)
                        let y = CGFloat.random(in: 0...size.height)
                        let opacity = Double.random(in: 0.01...0.04)
                        
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)),
                            with: .color(.white.opacity(opacity))
                        )
                    }
                }
            }
            .ignoresSafeArea()
            
            // Spotlight effect - brighter in center
            RadialGradient(
                colors: [
                    Color.white.opacity(0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()
            
            // Vignette - darker edges
            RadialGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.6)
                ],
                center: .center,
                startRadius: 200,
                endRadius: 600
            )
            .ignoresSafeArea()
            
            // Top edge padding (wood rail)
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [
                        GameTheme.tableEdge,
                        GameTheme.tableEdge.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 8)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(GameTheme.goldAccent.opacity(0.3))
                        .frame(height: 1)
                }
                
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
