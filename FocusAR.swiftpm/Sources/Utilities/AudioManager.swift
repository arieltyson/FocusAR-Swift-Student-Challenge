//
//  File.swift
//  FocusAR
//
//  Created by Ariel Tyson on 18/2/25.
//

// AVFoundation Audio

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    
    func playCalmingSound() {
        guard let url = Bundle.main.url(forResource: "calm_sound", withExtension: "aac") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
