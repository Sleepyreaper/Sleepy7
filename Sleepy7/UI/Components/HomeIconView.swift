import SwiftUI

struct HomeIconView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "1ABC9C"), Color(hex: "3498DB")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 110, height: 110)
                .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 8)

            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "E86A33"), Color(hex: "FF6B9D")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 58, height: 78)
                .rotationEffect(.degrees(-8))
                .overlay(
                    Text("7")
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(Color.white)
                )

            Circle()
                .fill(Color(hex: "F1C40F"))
                .frame(width: 20, height: 20)
                .offset(x: 32, y: -28)
                .shadow(color: Color(hex: "F1C40F").opacity(0.6), radius: 8, x: 0, y: 0)
        }
    }
}

#Preview {
    HomeIconView()
        .background(Color(hex: "0F1216"))
}
