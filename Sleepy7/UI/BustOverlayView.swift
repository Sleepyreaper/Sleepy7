import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0
    var rotation: Double = 0
}

struct BustOverlayView: View {
    @State private var bustOpacity = 0.0
    @State private var bustScale = 0.5
    @State private var particles: [Particle] = []
    @State private var shockwaveRadius: CGFloat = 0
    @State private var ringOpacity = 0.0

    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            // Shockwave ring
            Circle()
                .stroke(
                    RadialGradient(
                        gradient: Gradient(colors: [Color(hex: "FF6B9D").opacity(0.8), Color(hex: "E86A33").opacity(0)]),
                        center: .center,
                        startRadius: shockwaveRadius * 0.4,
                        endRadius: shockwaveRadius
                    ),
                    lineWidth: 4
                )
                .frame(width: shockwaveRadius, height: shockwaveRadius)
                .opacity(ringOpacity)

            // Explosion particles
            ForEach(particles) { particle in
                Text("💥")
                    .font(.system(size: 20))
                    .offset(x: particle.x, y: particle.y)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
            }

            VStack(spacing: 0) {
                Text("BUST")
                    .font(.system(size: 220, weight: .black, design: .default))
                    .tracking(8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FF6B9D"), Color(hex: "E86A33")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.6), radius: 20, x: 0, y: 8)
                    .shadow(color: Color(hex: "FF6B9D"), radius: 30, x: 0, y: 0)
                    .opacity(bustOpacity)
                    .scaleEffect(bustScale)
                    .padding(.horizontal, 20)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate()
        }
    }

    private func animate() {
        generateParticles()

        // Main text scale and fade in
        withAnimation(.easeOut(duration: 0.5)) {
            bustOpacity = 1.0
            bustScale = 1.0
        }

        // Shockwave burst
        withAnimation(.easeOut(duration: 0.8)) {
            ringOpacity = 1.0
            shockwaveRadius = 500
        }

        // Particle explosions
        for (index, _) in particles.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.02) {
                withAnimation(.easeOut(duration: 1.2)) {
                    particles[index].x *= 2
                    particles[index].y *= 2
                    particles[index].scale = 0.1
                    particles[index].opacity = 0.0
                    particles[index].rotation += 360
                }
            }
        }

        // Fade out entire overlay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                bustOpacity = 0.0
                bustScale = 0.8
                ringOpacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onDismiss()
            }
        }
    }

    private func generateParticles() {
        let particleCount = 16
        let angle = 360.0 / Double(particleCount)

        for i in 0..<particleCount {
            let radians = (angle * Double(i)) * .pi / 180.0
            let velocity: CGFloat = CGFloat.random(in: 80...150)
            let x = cos(radians) * velocity
            let y = sin(radians) * velocity

            particles.append(
                Particle(
                    x: x,
                    y: y,
                    scale: CGFloat.random(in: 0.6...1.2),
                    opacity: Double.random(in: 0.7...1.0),
                    rotation: Double.random(in: 0...360)
                )
            )
        }
    }
}

#Preview {
    BustOverlayView(onDismiss: {})
}
