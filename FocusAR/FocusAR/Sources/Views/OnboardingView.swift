import SwiftUI

struct OnboardingView: View {
    /// Called when the user finishes or skips onboarding.
    var onFinished: () -> Void

    @State private var index = 0
    private let pages = OnboardingPage.pages

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    TabView(selection: $index) {
                        ForEach(Array(pages.enumerated()), id: \.offset) {
                            i,
                            page in
                            OnboardingCard(page: page)
                                .tag(i)
                                .padding(.horizontal)
                                .accessibilityElement(children: .contain)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))

                    Button {
                        withAnimation(.easeInOut) {
                            if index < pages.count - 1 {
                                index += 1
                            } else {
                                HapticsManager.shared.playGentlePulse()
                                onFinished()
                            }
                        }
                    } label: {
                        Text(index == pages.count - 1 ? "Jump In!" : "Next")
                            .font(.title2.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    }
                    .buttonStyle(PrimaryShinyButtonStyle())
                    .padding(.horizontal)
                    .accessibilityHint(
                        index == pages.count - 1
                            ? "Finish onboarding" : "Go to the next page"
                    )

                    Spacer(minLength: 8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") { onFinished() }
                        .font(.body.weight(.semibold))
                        .accessibilityHint(
                            "Finish onboarding and continue to Home"
                        )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Components

private struct OnboardingCard: View {
    let page: OnboardingPage

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Symbol hero
                Image(systemName: page.symbol)
                    .font(.system(size: 72, weight: .semibold))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(page.accent, .white.opacity(0.9))
                    .padding(.top, 40)
                    .accessibilityHidden(true)

                VStack(spacing: 10) {
                    Text(page.title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(page.titleColor)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)

                    Text(page.subtitle)
                        .font(.title3)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .minimumScaleFactor(0.8)
                }

                if let footnote = page.footnote {
                    Text(footnote)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer(minLength: 12)
            }
            .frame(maxWidth: 540)  // readable width on iPad too
            .padding(.bottom, 24)
        }
    }
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let footnote: String?
    let symbol: String
    let accent: Color
    let titleColor: Color

    static let pages: [OnboardingPage] = [
        .init(
            title: "FocusAR",
            subtitle: "Transform chaos into calm, one tap at a time.",
            footnote:
                "Built with on-device intelligence. No media leaves your iPhone.",
            symbol: "sparkles",
            accent: .pink,
            titleColor: .cyan
        ),
        .init(
            title: "How It Works",
            subtitle:
                "FocusAR analyzes your space in real time and highlights cluttered areas so you can act with intention.",
            footnote: nil,
            symbol: "camera.viewfinder",
            accent: .mint,
            titleColor: .mint
        ),
        .init(
            title: "Intelligent & Immersive",
            subtitle:
                "Powered by Core ML, Vision, ARKit, RealityKit—paired with gentle haptics and calming audio feedback.",
            footnote: nil,
            symbol: "brain.head.profile",
            accent: .green,
            titleColor: .teal
        ),
        .init(
            title: "You're All Set",
            subtitle:
                "Begin a 3-minute session and tap cluttered areas to organize them.",
            footnote:
                "You can revisit these tips anytime from Home → How it works.",
            symbol: "hand.tap",
            accent: .cyan,
            titleColor: .indigo
        ),
    ]
}
