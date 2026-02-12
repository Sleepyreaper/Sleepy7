import SwiftUI

struct FlipSevenOverlayView: View {
    @State private var bonusOpacity = 0.0
    @State private var bonusScale = 0.5
    @State private var cardScale = 1.0
    @State private var cardRotation = 0.0
    @State private var cardsOpacity = 0.0
    @State private var particleRotations: [Double] = Array(repeating: 0, count: 7)

    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Golden overlay
            LinearGradient(
                colors: [
                    Color(hex: "F1C40F").opacity(0.3),
                    Color(hex: "E8B923").opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Rotating cards in circle
            ForEach(0..<7, id: \.self) { index in
                let angle = Double(index) * (360.0 / 7.0)
                let x = cos(Double.pi * 2 * Double(index) / 7.0) * 100
                let y = sin(Double.pi * 2 * Double(index) / 7.0) * 100

                VStack(spacing: 4) {
                    Text("7")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(.white)
                }
                .frame(width: 60, height: 80)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "E74C3C"), Color(hex: "C0392B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(8)
                .offset(x: x, y: y)
                .rotationEffect(.degrees(particleRotations[index]))
                .scaleEffect(cardsOpacity)
                .opacity(cardsOpacity)
            }

            // Bonus text
            VStack(spacing: 16) {
                Text("+15 BONUS")
                    .font(.system(size: 64, weight: .black))
                    .tracking(2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "F1C40F"), Color(hex: "F39C12")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "F1C40F").opacity(0.8), radius: 30, x: 0, y: 0)
                    .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 8)

                Text("7 UNIQUE CARDS!")
                    .font(.system(size: 24, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(Color(hex: "F1C40F"))
            }
            .opacity(bonusOpacity)
            .scaleEffect(bonusScale)
        }
        .ignoresSafeArea()
        .onAppear {
            animate()
        }
    }

    private func animate() {
        // Cards circle animation
        for i in 0..<7 {
            withAnimation(.easeOut(duration: 0.6).delay(Double(i) * 0.08)) {
                cardsOpacity = 1.0
            }
            withAnimation(
                .linear(duration: 4.0)
                    .repeatForever(autoreverses: false)
                    .delay(Double(i) * 0.1)
            ) {
                particleRotations[i] = 360
            }
        }

        // Bonus text animation
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            bonusOpacity = 1.0
            bonusScale = 1.0
        }

        // Hold and fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                bonusOpacity = 0.0
                cardsOpacity = 0.0
                bonusScale = 0.8
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onDismiss()
            }
        }
    }
}

#Preview {
    FlipSevenOverlayView(onDismiss: {})
}
