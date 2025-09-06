import AVFoundation

@MainActor
class AudioManager {

    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    private var isSetup = false

    private init() {
        setupAudio()
    }

    private func setupAudio() {
        guard !isSetup else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default
            )
            try AVAudioSession.sharedInstance().setActive(true)
            isSetup = true
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    func playCalmingSound() {
        guard
            let soundURL = Bundle.main.url(
                forResource: "calm_sound",
                withExtension: "aac"
            )
        else {
            print("Sound file not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.volume = 0.5
            player?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
}
