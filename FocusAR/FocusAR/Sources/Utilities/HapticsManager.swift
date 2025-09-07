import CoreHaptics

@MainActor
final class HapticsManager {

    static let shared = HapticsManager()
    private var engine: CHHapticEngine?

    private init() {
        setupHaptics()
    }

    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics engine failed to start: \(error)")
        }
    }

    func playGentlePulse() {
        guard let engine = engine else { return }

        do {
            let intensity = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: 0.5
            )
            let sharpness = CHHapticEventParameter(
                parameterID: .hapticSharpness,
                value: 0.2
            )
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: 0
            )

            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }

    /// A tasteful “confetti” burst: 3 staggered transients with varying intensity/sharpness.
    func playConfettiBurst() {
        guard let engine else { return }
        do {
            let events: [CHHapticEvent] = [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: 0.9),
                        .init(parameterID: .hapticSharpness, value: 0.6),
                    ],
                    relativeTime: 0.00
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: 0.6),
                        .init(parameterID: .hapticSharpness, value: 0.35),
                    ],
                    relativeTime: 0.06
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: 0.7),
                        .init(parameterID: .hapticSharpness, value: 0.2),
                    ],
                    relativeTime: 0.12
                ),
            ]
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch { print("Confetti haptic failed: \(error)") }
    }
}
