import SwiftUI

struct ExampleAssetUsage: View {
    var body: some View {
        Image("Freeze")
            .resizable()
            .scaledToFit()
            .accessibilityLabel("Freeze action card")
    }
}