import SwiftUI

struct ContentView: View {
    @StateObject private var arSession = ARSessionManager()
    let onEnd: () -> Void

    // session clock
    @State private var startDate = Date()
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    private let topExtra: CGFloat = 27
    private let bottomExtra: CGFloat = 12

    var body: some View {
        ZStack {
            ARViewContainer(arSession: arSession)
                .ignoresSafeArea()  // full-bleed camera
                .accessibilityLabel("Augmented reality camera view")
        }
        // TOP: safe area first, then extra padding to clear status bar/Dynamic Island
        .overlay(alignment: .top) {
            SessionHUD(elapsed: elapsedString, endAction: { onEnd() })
                .padding(.horizontal, 16)
                .safeAreaPadding(.top)  // <- apply system insets
                .padding(.top, topExtra)  // <- add a little more clearance
        }
        // BOTTOM: safe area first, then extra padding above the home indicator
        .overlay(alignment: .bottom) {
            if arSession.isSessionReady {
                InstructionPill(text: "Tap cluttered areas to organize them")
                    .padding(.horizontal, 16)
                    .safeAreaPadding(.bottom)  // <- system insets
                    .padding(.bottom, bottomExtra)  // <- extra clearance
            }
        }
        .onAppear { startDate = Date() }
        .onReceive(timer) { now = $0 }
        .statusBarHidden(false)  // ensure insets are honored
    }

    private var elapsedString: String {
        let f = DateComponentsFormatter()
        f.allowedUnits =
            now.timeIntervalSince(startDate) >= 3600
            ? [.hour, .minute, .second] : [.minute, .second]
        f.unitsStyle = .positional
        f.zeroFormattingBehavior = .pad
        return f.string(from: startDate, to: now) ?? "00:00"
    }
}

// MARK: - UI pieces

private struct SessionHUD: View {
    let elapsed: String
    let endAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Label(elapsed, systemImage: "clock")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())

            Spacer()

            Button(role: .destructive) {
                endAction()
            } label: {
                Label("End", systemImage: "xmark.circle.fill")
                    .font(.callout.weight(.bold))
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .accessibilityHint("Stop the current AR focus session")
        }
        .accessibilityElement(children: .combine)
    }
}

private struct InstructionPill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .accessibilityLabel(text)
    }
}
