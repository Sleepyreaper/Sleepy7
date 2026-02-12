import SwiftUI

struct FreezeOverlayView: View {
    @State private var snowflakes: [Snowflake] = []
    @State private var freezeOpacity = 0.0
    @State private var frostEffect = 0.0

    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Icy blue overlay
            LinearGradient(
                colors: [
                    Color(hex: "1ABC9C").opacity(0.4),
                    Color(hex: "3498DB").opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Frost effect
            Canvas { context, size in
                for i in 0..<20 {
                    var path = Path()
                    let xPos = CGFloat.random(in: 0...size.width)
                    let yPos = CGFloat.random(in: 0...size.height)
                    let circleSize = CGFloat.random(in: 20...60)

                    path.addEllipse(in: CGRect(x: xPos, y: yPos, width: circleSize, height: circleSize))
                    context.stroke(path, with: .color(Color.white.opacity(frostEffect * 0.6)), lineWidth: 1.5)
                }
            }
            .ignoresSafeArea()

            // Snowflakes
            ForEach(snowflakes) { snowflake in
                Text("❄")
                    .font(.system(size: snowflake.size))
                    .foregroundStyle(Color.white.opacity(frostEffect * 0.8))
                    .offset(x: snowflake.x, y: snowflake.y)
            }

            // Frozen text
            VStack(spacing: 20) {
                Text("FROZEN")
                    .font(.system(size: 80, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "1ABC9C"), Color(hex: "5DADE2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "1ABC9C").opacity(0.6), radius: 16, x: 0, y: 0)
                    .opacity(freezeOpacity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            generateSnowflakes()
            animate()
        }
    }

    private func generateSnowflakes() {
        for _ in 0..<30 {
            snowflakes.append(
                Snowflake(
                    x: CGFloat.random(in: -100...UIScreen.main.bounds.width + 100),
                    y: CGFloat.random(in: -100...UIScreen.main.bounds.height + 100),
                    size: CGFloat.random(in: 12...28)
                )
            )
        }
    }

    private func animate() {
        withAnimation(.easeOut(duration: 0.6)) {
            freezeOpacity = 1.0
            frostEffect = 1.0
        }

        for i in 0..<snowflakes.count {
            withAnimation(
                .easeInOut(duration: CGFloat.random(in: 2...4))
                    .delay(Double(i) * 0.05)
            ) {
                snowflakes[i].y += CGFloat.random(in: 80...200)
                snowflakes[i].x += CGFloat.random(in: -40...40)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                freezeOpacity = 0.0
                frostEffect = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onDismiss()
            }
        }
    }
}

struct Snowflake: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
}

#Preview {
    FreezeOverlayView(onDismiss: {})
}
