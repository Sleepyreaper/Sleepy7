import SwiftUI

struct Flip7TutorialAnimationView: View {
    let pageIndex: Int

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let progress = time.truncatingRemainder(dividingBy: 3.6) / 3.6

            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.white.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(.white.opacity(0.16), lineWidth: 1)
                    )

                switch pageIndex {
                case 0:
                    uniqueNumbersScene(progress: progress)
                case 1:
                    bustScene(progress: progress)
                case 2:
                    actionScene(progress: progress)
                default:
                    flip7Scene(progress: progress)
                }
            }
        }
        .frame(height: 280)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func uniqueNumbersScene(progress: Double) -> some View {
        HStack(spacing: 14) {
            animatedCard("1", offset: progress < 0.25 ? -40 : 0, opacity: progress < 0.15 ? 0.0 : 1.0)
            animatedCard("4", offset: progress < 0.45 ? -40 : 0, opacity: progress < 0.35 ? 0.0 : 1.0)
            animatedCard("7", offset: progress < 0.65 ? -40 : 0, opacity: progress < 0.55 ? 0.0 : 1.0)
        }
    }

    @ViewBuilder
    private func bustScene(progress: Double) -> some View {
        ZStack {
            HStack(spacing: 16) {
                animatedCard("5", offset: 0, opacity: 1.0)
                animatedCard("9", offset: 0, opacity: 1.0)
                animatedCard("5", offset: 0, opacity: 1.0)
                    .rotationEffect(.degrees(progress > 0.55 ? 8 : 0))
                    .scaleEffect(progress > 0.55 ? 1.07 : 1.0)
            }

            if progress > 0.55 {
                Text("BUST")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    private func actionScene(progress: Double) -> some View {
        HStack(spacing: 16) {
            featureCard(title: "Freeze", color: .cyan)
                .offset(y: progress < 0.4 ? 16 : 0)

            featureCard(title: "+4", color: .orange)
                .offset(y: progress < 0.6 ? 16 : 0)

            featureCard(title: "2x", color: .purple)
                .offset(y: progress < 0.8 ? 16 : 0)
        }
    }

    @ViewBuilder
    private func flip7Scene(progress: Double) -> some View {
        VStack(spacing: 18) {
            HStack(spacing: 10) {
                ForEach(["0", "2", "3", "5", "7", "9", "11"], id: \.self) { value in
                    animatedCard(value, offset: 0, opacity: progress > 0.1 ? 1.0 : 0.0)
                        .scaleEffect(progress > 0.7 ? 1.06 : 1.0)
                }
            }

            if progress > 0.65 {
                Text("FLIP 7")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.yellow)
            }
        }
    }

    private func animatedCard(_ title: String, offset: CGFloat, opacity: Double) -> some View {
        Text(title)
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 58, height: 86)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.85), Color.indigo.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .offset(y: offset)
            .opacity(opacity)
    }

    private func featureCard(title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 78, height: 110)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(color.opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            )
    }
}