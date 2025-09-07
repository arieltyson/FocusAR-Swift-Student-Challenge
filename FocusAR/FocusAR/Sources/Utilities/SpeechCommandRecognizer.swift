import AVFoundation
import Speech

#if canImport(FoundationModels)
    import FoundationModels
#endif

@MainActor
final class SpeechCommandRecognizer: ObservableObject {
    @Published private(set) var isListening = false
    private let recognizer = SFSpeechRecognizer()
    private let audio = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    // Debounce / de-dupe
    private var debounceTask: Task<Void, Never>?
    private var lastEvaluatedText: String = ""
    private var lastCommandTime: Date = .distantPast

    enum Command { case endSession, muteAudio, unmuteAudio, unknown }
    enum SpeechError: Error {
        case recognizerUnavailable
        case speechNotAuthorized(SFSpeechRecognizerAuthorizationStatus)
        case micNotAuthorized
    }

    // MARK: - Foundation Models (on-device)
    #if canImport(FoundationModels)
        private lazy var fmSession: LanguageModelSession = {
            let model = SystemLanguageModel(useCase: .contentTagging)
            return LanguageModelSession(model: model)
        }()
    #endif

    // MARK: - Permissions

    private func requestSpeechAuth() async
        -> SFSpeechRecognizerAuthorizationStatus
    {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization {
                cont.resume(returning: $0)
            }
        }
    }

    private func requestMicPermission() async -> Bool {
        await withCheckedContinuation { cont in
            AVAudioApplication.requestRecordPermission {
                cont.resume(returning: $0)
            }
        }
    }

    func requestAuthorization() async throws {
        let speechStatus = await requestSpeechAuth()
        guard speechStatus == .authorized else {
            throw SpeechError.speechNotAuthorized(speechStatus)
        }

        let micGranted = await requestMicPermission()
        guard micGranted else { throw SpeechError.micNotAuthorized }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .measurement,
            options: [.duckOthers]
        )
        try session.setActive(true)
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
                // Always consider partials; we'll debounce before firing.
                let text = result.bestTranscription.formattedString.lowercased()
                self.scheduleClassification(for: text, handler: handler)

                // If the recognizer naturally ends, stop our engine.
                if result.isFinal {
                    self.stop()
                }
            }

            if error != nil {
                self.stop()
            }
        }
    }

    func stop() {
        debounceTask?.cancel()
        debounceTask = nil

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

    // MARK: - Debounced classification

    private func scheduleClassification(
        for text: String,
        handler: @escaping (Command) -> Void
    ) {
        lastEvaluatedText = text
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            // Small delay lets utterances settle (≈phrase boundary)
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard text == lastEvaluatedText else { return }  // new text arrived; skip

            if let cmd = await classifyCommand(from: text), cmd != .unknown {
                // Simple de-dupe so the same phrase doesn’t fire repeatedly
                let now = Date()
                if now.timeIntervalSince(lastCommandTime) > 1.2 {
                    lastCommandTime = now
                    handler(cmd)
                }
            }
        }
    }

    // MARK: - Classification

    private func classifyCommand(from text: String) async -> Command? {
        #if canImport(FoundationModels)
            if let fmCmd = await classifyWithFoundationModels(text) {
                return fmCmd
            }
        #endif
        return classifyRuleBased(text: text)
    }

    private func classifyRuleBased(text: String) -> Command {
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

    #if canImport(FoundationModels)
        @Generable
        private struct CommandDecision: Equatable {
            @Guide(
                description: "One of: end_session, mute, unmute, none",
                .anyOf(["end_session", "mute", "unmute", "none"])
            )
            var intent: String
        }

        private func classifyWithFoundationModels(_ text: String) async
            -> Command?
        {
            do {
                let response = try await fmSession.respond(
                    to: """
                        Classify the user’s voice command into one of: end_session, mute, unmute, none.
                        Return only the 'intent' field.
                        Command: "\(text)"
                        """,
                    generating: CommandDecision.self,
                    includeSchemaInPrompt: true,
                    options: GenerationOptions(temperature: 0)
                )

                switch response.content.intent {
                case "end_session": return .endSession
                case "mute": return .muteAudio
                case "unmute": return .unmuteAudio
                default: return .unknown
                }
            } catch {
                return nil
            }
        }
    #endif
}
