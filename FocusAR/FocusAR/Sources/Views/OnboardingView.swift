import SwiftUI

private enum OnboardingPosition: Int, CaseIterable, Identifiable {
    case welcome, overview, technology, jumpIn
    var id: Int { self.rawValue }
}

struct OnboardingView: View {
    @State private var position: OnboardingPosition = .welcome
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false

    func changePosition() {
        withAnimation {
            if position == .jumpIn {
                // Mark onboarding complete and transition to main app.
                hasOnboarded = true
            } else {
                // Move to the next onboarding page.
                if let next = OnboardingPosition.allCases.first(where: {
                    $0.rawValue == position.rawValue + 1
                }) {
                    position = next
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    TabView(selection: $position) {
                        welcomePage
                            .tag(OnboardingPosition.welcome)
                        overviewPage
                            .tag(OnboardingPosition.overview)
                        technologyPage
                            .tag(OnboardingPosition.technology)
                        jumpInPage
                            .tag(OnboardingPosition.jumpIn)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    // Disable swipe to force button progression.
                    .disabled(true)

                    Button {
                        changePosition()
                    } label: {
                        Text(position == .jumpIn ? "Jump In!" : "Next")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)  // Button text in white.
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mint)
                            .cornerRadius(30)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .statusBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Onboarding Pages

    var welcomePage: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("FocusAR")
                .font(.system(size: 88, weight: .bold))
                .foregroundColor(.cyan)  // Primary accent color.
            Text("Transform chaos into calm, one tap at a time.")
                .font(.system(size: 38, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Text("Tap next to learn more")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 70)
        }
        .padding()
    }

    var overviewPage: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
            Text("How It Works")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.mint)
            Text(
                "FocusAR uses your device’s camera to detect visual clutter in real time. By analyzing the scene with on‑device computer vision, it identifies chaotic areas and prepares them for transformation."
            )
            .font(.system(size: 28))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .padding()
    }

    var technologyPage: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            Text("Intelligent & Immersive")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.teal)
            Text(
                "FocusAR leverages cutting‑edge machine learning and augmented reality frameworks—including Core ML, Vision, ARKit, and RealityKit—to overlay calming animations and haptic feedback onto your environment. This intelligent integration transforms clutter into a serene, organized space."
            )
            .font(.system(size: 18))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .padding()
    }

    var jumpInPage: some View {
        VStack(spacing: 20) {
            Text("You're All Set!")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.indigo)
            Text(
                "Now you're ready to experience the magic of FocusAR. Tap 'Jump In!' to begin your journey towards a calmer, more organized space."
            )
            .font(.system(size: 31))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            Image(systemName: "sparkles")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.pink)
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
