import SwiftUI
import FirebaseCore
import FirebaseCrashlytics
import FirebasePerformance

@main
struct Sleepy7App: App {
    @StateObject private var engine = GameEngine()

    init() {
        FirebaseBootstrap.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(engine)
        }
    }
}