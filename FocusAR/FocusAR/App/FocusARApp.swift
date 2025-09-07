import SwiftUI

@main
struct FocusAR: App {
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(.mint)
        }
    }
}

private struct RootView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        if hasOnboarded {
            HomeView()
        } else {
            OnboardingView {
                hasOnboarded = true
            }
        }
    }
}
