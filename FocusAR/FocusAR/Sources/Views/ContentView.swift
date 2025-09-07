import SwiftUI

struct ContentView: View {
    @StateObject private var arSession = ARSessionManager()

    // Session control
    let onEnd: () -> Void
    let targetMinutes: Int?
    let mode: FocusMode?

    // Voice control
    @StateObject private var speech = SpeechCommandRecognizer()

    // Session clock
    @State private var startDate = Date()
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    // Tunable HUD spacing beyond system insets
    private let topExtra: CGFloat = 27
    private let bottomExtra: CGFloat = 12

    var body: some View {
        ZStack {
            // Full-bleed AR background
            ARViewContainer(arSession: arSession)
                .ignoresSafeArea()
                .accessibilityLabel("Augmented reality camera view")
        }
        // TOP HUD (timer, optional target, mode chip, mic, End)
        .overlay(alignment: .top) {
            SessionHUD(
                elapsed: elapsedString,
                endAction: { endAndCleanUp() },
                speech: speech,
                targetMinutes: targetMinutes,
                mode: mode
            )
            .padding(.horizontal, 16)
            .safeAreaPadding(.top)  // respect notch/Dynamic Island
            .padding(.top, topExtra)  // extra breathing room
        }
        // BOTTOM instruction pill
        .overlay(alignment: .bottom) {
            if arSession.isSessionReady {
                InstructionPill(text: "Tap cluttered areas to organize them")
                    .padding(.horizontal, 16)
                    .safeAreaPadding(.bottom)  // respect Home indicator
                    .padding(.bottom, bottomExtra)
            }
        }
        .onAppear {
            startDate = Date()
        }
        .onReceive(timer) { now = $0 }
        .onDisappear { speech.stop() }  // ensure we stop listening if dismissed
        .statusBarHidden(false)  // keep status bar visible so insets apply
    }

    private func endAndCleanUp() {
        speech.stop()
        onEnd()
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

// MARK: - HUD

private struct SessionHUD: View {
    let elapsed: String
    let endAction: () -> Void
    @ObservedObject var speech: SpeechCommandRecognizer
    let targetMinutes: Int?
    let mode: FocusMode?

    var body: some View {
        HStack(spacing: 12) {
            // Timer + (optional) target time + (optional) mode chip
            HStack(spacing: 8) {
                Label(timerLabel, systemImage: "clock")
                    .labelStyle(.titleAndIcon)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())

                if let mode {
                    ModeChip(mode: mode)
                }
            }

            Spacer()

            // Mic toggle
            Button {
                if speech.isListening {
                    speech.stop()
                    HapticsManager.shared.playGentlePulse()
                } else {
                    Task {
                        do {
                            try await speech.start { cmd in
                                switch cmd {
                                case .endSession: endAction()
                                case .muteAudio, .unmuteAudio, .unknown:
                                    HapticsManager.shared.playGentlePulse()
                                }
                            }
                        } catch {
                            HapticsManager.shared.playGentlePulse()
                        }
                    }
                }
            } label: {
                Image(systemName: speech.isListening ? "mic.fill" : "mic.slash")
                    .font(.callout.weight(.bold))
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(
                speech.isListening ? "Stop listening" : "Start listening"
            )
            .accessibilityHint("Use voice commands like “End session”")

            // End session
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

    private var timerLabel: String {
        if let t = targetMinutes, t > 0 {
            return elapsed + " • target " + String(format: "%02d:00", t)
        } else {
            return elapsed
        }
    }
}

// MARK: - Mode chip

private struct ModeChip: View {
    let mode: FocusMode

    var body: some View {
        Label(modeTitle, systemImage: modeIcon)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(modeBackground, in: Capsule())
            .foregroundStyle(.white)
            .accessibilityLabel("Mode \(modeTitle)")
    }

    private var modeTitle: String {
        switch mode {
        case .calming: return "Calming"
        case .energizing: return "Energizing"
        case .silent: return "Silent"
        }
    }

    private var modeIcon: String {
        switch mode {
        case .calming: return "leaf.fill"
        case .energizing: return "bolt.fill"
        case .silent: return "speaker.slash.fill"
        }
    }

    private var modeBackground: LinearGradient {
        switch mode {
        case .calming:
            return LinearGradient(
                colors: [.mint, .cyan],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .energizing:
            return LinearGradient(
                colors: [.orange, .pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .silent:
            return LinearGradient(
                colors: [.gray, .gray.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

// MARK: - Bottom pill

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
