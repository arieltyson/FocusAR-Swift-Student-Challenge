import SwiftUI

struct HomeView: View {
    @State private var presentSession = false
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle, premium background
                LinearGradient(
                    colors: [Color.black, Color.black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

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

                        Text("Transform chaos into calm, one tap at a time.")
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.top, 24)

                    // A tiny “benefit” card (optional)
                    GroupBox {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .imageScale(.large)
                                .symbolRenderingMode(.hierarchical)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("3-minute focus session")
                                    .font(.headline)
                                Text(
                                    "Tap cluttered areas to calm your space with gentle audio + haptics."
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

                    // Primary CTA
                    Button {
                        HapticsManager.shared.playGentlePulse()
                        presentSession = true
                    } label: {
                        Label("Start Session", systemImage: "camera.viewfinder")
                            .font(.title2.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PrimaryShinyButtonStyle())
                    .accessibilityHint(
                        "Opens the camera to begin a 3-minute AR focus session."
                    )
                    .padding(.horizontal)

                    // Secondary row
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

                    Spacer(minLength: 24)
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
                ContentView()  // your AR experience
                    .ignoresSafeArea()
            }
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
        }
        .navigationTitle("Privacy")
    }
}
