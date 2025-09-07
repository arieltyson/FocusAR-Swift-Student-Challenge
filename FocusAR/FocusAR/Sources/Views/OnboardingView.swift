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
                    .buttonStyle(PrimaryOnboardingButtonStyle())
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

                if let bullets = page.bullets, !bullets.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(bullets, id: \.self) { line in
                            Label {
                                Text(line)
                                    .foregroundStyle(.white)
                            } icon: {
                                Image(systemName: "checkmark.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                            }
                            .font(.body)
                            .foregroundStyle(.mint)
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .frame(maxWidth: 540, alignment: .leading)
                    .padding(.horizontal)
                }

                if let phrases = page.voicePhrases, !phrases.isEmpty {
                    VoicePhrasesView(phrases: phrases)
                        .padding(.top, 4)
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

private struct VoicePhrasesView: View {
    let phrases: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Try saying")
                .font(.headline)
                .foregroundStyle(.mint)
            ForEach(phrases, id: \.self) { text in
                HStack(spacing: 8) {
                    Image(systemName: "mic.circle.fill")
                        .imageScale(.medium)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.cyan)
                    Text("“\(text)”")
                        .foregroundStyle(.white)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .padding(.horizontal)
    }
}

private struct PrimaryOnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.mint, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .foregroundColor(.white)
            .shadow(
                color: .mint.opacity(configuration.isPressed ? 0.15 : 0.3),
                radius: configuration.isPressed ? 8 : 16,
                y: configuration.isPressed ? 4 : 10
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.8),
                value: configuration.isPressed
            )
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Model

private struct OnboardingPage: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let footnote: String?
    let symbol: String
    let accent: Color
    let titleColor: Color
    let bullets: [String]?
    let voicePhrases: [String]?

    static let pages: [OnboardingPage] = [
        .init(
            title: "FocusAR",
            subtitle: "Transform chaos into calm, one tap at a time.",
            footnote:
                "On-device and private. No images or audio leave your iPhone.",
            symbol: "sparkles",
            accent: .pink,
            titleColor: .cyan,
            bullets: [
                "Built for clarity, calm, and accessibility",
                "Designed to feel native on iOS",
            ],
            voicePhrases: nil
        ),
        .init(
            title: "How It Works",
            subtitle:
                "FocusAR analyzes your space in real time and highlights cluttered areas so you can act with intention.",
            footnote: nil,
            symbol: "camera.viewfinder",
            accent: .mint,
            titleColor: .mint,
            bullets: [
                "Tap cluttered areas for gentle feedback",
                "Haptics and sound guide you as you go",
            ],
            voicePhrases: nil
        ),
        .init(
            title: "Voice & Intelligence",
            subtitle:
                "On-device Speech transcribes your voice. Apple’s Foundation Models classify phrases and map them to actions—private and fast.",
            footnote:
                "You can grant speech permission the first time you enable the mic. Siri Shortcuts use App Intents to start sessions with parameters.",
            symbol: "brain.head.profile",
            accent: .teal,
            titleColor: .teal,
            bullets: [
                "Speech recognition runs entirely on your device",
                "Foundation Models interpret intent (end, mute, unmute)",
                "Siri Shortcuts start sessions via App Intents",
            ],
            voicePhrases: [
                "Start a focus session in FocusAR",
                "End session",
                "Mute sound",
                "Unmute sound",
            ]
        ),
        .init(
            title: "Hands-Free Control",
            subtitle:
                "Start sessions with Siri or tap the mic to control them during AR. Everything stays on device for privacy.",
            footnote: "Tip: If you prefer silence, switch to Mute anytime.",
            symbol: "mic.circle.fill",
            accent: .cyan,
            titleColor: .teal,
            bullets: [
                "Say “Start a focus session in FocusAR”",
                "Use the mic to end or toggle sound during a session",
            ],
            voicePhrases: [
                "End session",
                "Mute sound",
                "Unmute sound",
            ]
        ),
        .init(
            title: "Stay As Long As You Like",
            subtitle:
                "Sessions are open-ended with a subtle timer. End anytime with the End button at the top of the camera view.",
            footnote: "You can revisit these tips from Home → How it works.",
            symbol: "clock",
            accent: .cyan,
            titleColor: .indigo,
            bullets: [
                "Open-ended sessions—no time limits",
                "One clear End control when you’re done",
            ],
            voicePhrases: nil
        ),
    ]
}
