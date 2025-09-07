import AVFoundation
import Speech

@MainActor
final class SpeechCommandRecognizer: ObservableObject {
    @Published private(set) var isListening = false
    private let recognizer = SFSpeechRecognizer()
    private let audio = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    enum Command { case endSession, muteAudio, unmuteAudio, unknown }
    enum SpeechError: Error {
        case recognizerUnavailable
        case speechNotAuthorized(SFSpeechRecognizerAuthorizationStatus)
        case micNotAuthorized
    }

    // MARK: - Permissions

    private func requestSpeechAuth() async
        -> SFSpeechRecognizerAuthorizationStatus
    {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status)
            }
        }
    }

    private func requestMicPermission() async -> Bool {
        if #available(iOS 17.0, *) {
            // New API on iOS 17+: AVAudioApplication
            return await withCheckedContinuation { cont in
                AVAudioApplication.requestRecordPermission { granted in
                    cont.resume(returning: granted)
                }
            }
        } else {
            // Legacy API for iOS 16 and earlier
            return await withCheckedContinuation { cont in
                AVAudioSession.sharedInstance().requestRecordPermission {
                    granted in
                    cont.resume(returning: granted)
                }
            }
        }
    }

    func requestAuthorization() async throws {
        // Speech recognition permission
        let speechStatus = await requestSpeechAuth()
        guard speechStatus == .authorized else {
            throw SpeechError.speechNotAuthorized(speechStatus)
        }

        // Microphone permission
        let micGranted = await requestMicPermission()
        guard micGranted else {
            throw SpeechError.micNotAuthorized
        }

        // Configure audio session for recognition
        try AVAudioSession.sharedInstance().setCategory(
            .record,
            mode: .measurement,
            options: [.duckOthers]
        )
        try AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: - Lifecycle

    func start(handler: @escaping (Command) -> Void) async throws {
        guard !isListening else { return }
        guard recognizer != nil else { throw SpeechError.recognizerUnavailable }

        try await requestAuthorization()

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        if recognizer?.supportsOnDeviceRecognition == true {
            req.requiresOnDeviceRecognition = true
        }
        self.request = req

        let input = audio.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 2048, format: format) {
            [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audio.prepare()
        try audio.start()
        isListening = true

        task = recognizer?.recognitionTask(with: req) {
            [weak self] result, error in
            guard let self else { return }
            if let result {
                let text = result.bestTranscription.formattedString.lowercased()
                if let cmd = self.classify(text: text) { handler(cmd) }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stop()
            }
        }
    }

    func stop() {
        guard isListening else { return }
        task?.cancel()
        task = nil
        request?.endAudio()
        request = nil
        audio.inputNode.removeTap(onBus: 0)
        audio.stop()
        isListening = false
        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }

    // MARK: - Minimal on-device intent matching

    private func classify(text: String) -> Command? {
        if text.contains("end session") || text.contains("stop")
            || text.contains("i'm done")
        {
            return .endSession
        }
        if text.contains("mute") { return .muteAudio }
        if text.contains("unmute") || text.contains("sound on") {
            return .unmuteAudio
        }
        return .unknown
    }
}
