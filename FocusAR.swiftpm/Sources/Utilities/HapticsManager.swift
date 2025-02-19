//
//  File.swift
//  FocusAR
//
//  Created by Ariel Tyson on 18/2/25.
//

import CoreHaptics

class HapticsManager {
    static let shared = HapticsManager()
    private var engine: CHHapticEngine?
    
    init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
    }
    
    func playGentlePulse() {
        guard let engine = engine else { return }
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [.init(parameterID: .hapticIntensity, value: 0.5)],
            relativeTime: 0
        )
        let pattern = try? CHHapticPattern(events: [event], parameters: [])
        let player = try? engine.makePlayer(with: pattern!)
        try? player?.start(atTime: 0)
    }
}
