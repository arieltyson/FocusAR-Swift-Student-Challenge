import SwiftUI

struct HomeView: View {
    @State private var presentSession = false
    @State private var showOnboarding = false

    // Parameters passed from Siri/Shortcuts deep links
    @State private var targetMinutes: Int?
    @State private var targetMode: FocusMode?

    // Flourish state
    @State private var startSparkleTrigger = false
    @State private var showEndConfetti = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle, premium background
                LinearGradient(
                    colors: [Color.black, Color.black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // ---- Centered main area ----
                    Spacer(minLength: 0)

                    VStack(spacing: 28) {
                        // Hero
                        VStack(spacing: 12) {
                            Text("FocusAR")
                                .font(.largeTitle.weight(.bold))
                                .foregroundStyle(
                                    .linearGradient(
                                        colors: [.cyan, .mint],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .accessibilityAddTraits(.isHeader)

                            Text(
                                "Transform chaos into calm, one tap at a time."
                            )
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .minimumScaleFactor(0.8)
                        }

                        // Benefit card (open-ended sessions)
                        GroupBox {
                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .imageScale(.large)
                                    .symbolRenderingMode(.hierarchical)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Open-ended focus")
                                        .font(.headline)
                                    Text(
                                        "Start a session and stay as long as you like. Tap cluttered areas for gentle audio + haptics."
                                    )
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .accessibilityElement(children: .combine)
                        }
                        .groupBoxStyle(.automatic)
                        .padding(.horizontal)

                        // Primary CTA (with SF Symbol flourish)
                        Button {
                            HapticsManager.shared.playGentlePulse()
                            targetMinutes = nil
                            targetMode = nil

                            // sparkles flourish (re-trigger animation)
                            startSparkleTrigger.toggle()

                            // small entry delay so the flourish feels intentional
                            if reduceMotion {
                                presentSession = true
                            } else {
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 0.18
                                ) {
                                    presentSession = true
                                }
                            }
                        } label: {
                            ZStack {
                                Label(
                                    "Start Session",
                                    systemImage: "camera.viewfinder"
                                )
                                .font(.title2.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .contentShape(Rectangle())

                                // Decorative sparkles above the label
                                Image(systemName: "sparkles")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundStyle(.mint)
                                    .offset(y: -34)
                                    .symbolEffect(
                                        .bounce,
                                        value: startSparkleTrigger
                                    )
                                    .opacity(reduceMotion ? 0 : 1)
                                    .accessibilityHidden(true)
                            }
                        }
                        .buttonStyle(PrimaryShinyButtonStyle())
                        .accessibilityHint(
                            "Opens the camera to begin an AR focus session. End anytime with the End button."
                        )
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 0)

                    // ---- Bottom row: How it works + Privacy ----
                    HStack(spacing: 20) {
                        Button {
                            showOnboarding = true
                        } label: {
                            Label("How it works", systemImage: "info.circle")
                                .font(.body.weight(.semibold))
                        }

                        Spacer()

                        NavigationLink {
                            PrivacyView()
                        } label: {
                            Label("Privacy", systemImage: "hand.raised")
                                .font(.body.weight(.semibold))
                        }
                    }
                    .padding(.horizontal)
                    .foregroundStyle(.secondary)
                    .safeAreaPadding(.bottom)  // keep above the Home indicator
                    .padding(.bottom, 8)  // extra breathing room
                }

                // End-of-session confetti overlay (auto dismiss)
                if showEndConfetti {
                    ConfettiOverlay()
                        .transition(.opacity)
                        .accessibilityHidden(true)
                }
            }
            // Deep-link handling from App Intents / Shortcuts
            .onOpenURL { url in
                guard url.scheme == "focusar" else { return }
                if url.host == "start" {
                    let comps = URLComponents(
                        url: url,
                        resolvingAgainstBaseURL: false
                    )
                    if let mins = comps?.queryItems?.first(where: {
                        $0.name == "minutes"
                    })?.value,
                        let m = Int(mins), m > 0
                    {
                        targetMinutes = m
                    } else {
                        targetMinutes = nil
                    }
                    if let modeStr = comps?.queryItems?.first(where: {
                        $0.name == "mode"
                    })?.value,
                        let parsed = FocusMode(rawValue: modeStr)
                    {
                        targetMode = parsed
                    } else {
                        targetMode = nil
                    }
                    presentSession = true
                } else if url.host == "end" {
                    presentSession = false
                    celebrateEnd()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showOnboarding) {
                OnboardingView {
                    // If user re-runs onboarding from Home, just dismiss on finish.
                    showOnboarding = false
                }
                .interactiveDismissDisabled()
            }
            .fullScreenCover(isPresented: $presentSession) {
                ContentView(
                    onEnd: {
                        presentSession = false
                        celebrateEnd()
                    },
                    targetMinutes: targetMinutes,
                    mode: targetMode
                )
                .ignoresSafeArea()
            }
        }
    }

    private func celebrateEnd() {
        HapticsManager.shared.playConfettiBurst()
        withAnimation(.easeOut(duration: 0.25)) { showEndConfetti = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.easeIn(duration: 0.2)) { showEndConfetti = false }
        }
    }
}

// A lightweight confetti overlay that prefers Lottie when available,
// and falls back to an SF Symbols “sparkles” fan-out.
private struct ConfettiOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animationID = UUID()  // drive repeating effect

    var body: some View {
        ZStack {
            Color.black.opacity(0.05).ignoresSafeArea()

            #if canImport(Lottie)
                LottieView(name: "confetti", loopMode: .playOnce, speed: 1.0)
                    .allowsHitTesting(false)
            #else
                VStack(spacing: 24) {
                    sparklesRow
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(.mint)
                        // Apply bounce only when motion is allowed.
                        .modifier(
                            BounceIfAllowed(
                                enabled: !reduceMotion,
                                value: animationID
                            )
                        )
                }
                .allowsHitTesting(false)
            #endif
        }
        .accessibilityHidden(true)
        .onAppear {
            // refresh the effect if needed
            animationID = UUID()
        }
    }

    private var sparklesRow: some View {
        HStack(spacing: 24) {
            Image(systemName: "sparkles")
            Image(systemName: "sparkles")
            Image(systemName: "sparkles")
        }
    }
}

// Helper: conditionally apply the bounce effect without mixing effect types.
private struct BounceIfAllowed<Value: Equatable>: ViewModifier {
    let enabled: Bool
    let value: Value
    func body(content: Content) -> some View {
        if enabled {
            content.symbolEffect(.bounce, options: .repeating, value: value)
        } else {
            content  // no animation when Reduce Motion is on
        }
    }
}

// Premium, accessible button style with subtle motion/haptics
struct PrimaryShinyButtonStyle: ButtonStyle {
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

// Simple, explicit privacy page (keeps Review happy)
private struct PrivacyView: View {
    var body: some View {
        List {
            Section("Camera") {
                Text(
                    "FocusAR uses the camera on-device to analyze your space and overlay AR guidance. No images or video leave your device."
                )
            }
            Section("Haptics & Audio") {
                Text(
                    "Gentle haptics and calming audio provide feedback as you interact."
                )
            }
            Section("Session Control") {
                Text(
                    "Sessions are open-ended. You can end anytime using the End button at the top of the camera view."
                )
            }
        }
        .navigationTitle("Privacy")
    }
}
