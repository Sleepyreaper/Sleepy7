import SwiftUI

@main
struct Sleepy7App: App {
    @StateObject private var engine = GameEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(engine)
        }
    }
}
