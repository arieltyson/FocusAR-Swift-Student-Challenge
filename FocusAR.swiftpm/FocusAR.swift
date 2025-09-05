import SwiftUI

@main
struct FocusAR: App {

    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
