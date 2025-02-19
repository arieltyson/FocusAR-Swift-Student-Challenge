//
//  File.swift
//  FocusAR
//
//  Created by Ariel Tyson on 18/2/25.
//

import CoreHaptics

@MainActor
class HapticsManager {
    
    static let shared = HapticsManager()
    private var engine: CHHapticEngine?
    
    private init() {
        setupHaptics()
    }
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
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
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            let event = CHHapticEvent(eventType: .hapticTransient,
                                    parameters: [intensity, sharpness],
                                    relativeTime: 0)
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
}
