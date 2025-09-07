import AppIntents

// MARK: - Parameters exposed to Siri/Shortcuts

enum FocusMode: String, AppEnum {
    case calming, energizing, silent

    static var typeDisplayRepresentation = TypeDisplayRepresentation(
        name: "Focus Mode"
    )

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .calming: "Calming",
        .energizing: "Energizing",
        .silent: "Silent",
    ]
}

// MARK: - Start Session

struct StartFocusSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Focus Session"
    static var description = IntentDescription(
        "Begin an AR mindfulness session in FocusAR."
    )
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Minutes (Optional)")
    var minutes: Int?

    @Parameter(title: "Mode (Optional)")
    var mode: FocusMode?

    @MainActor
    func perform() async throws -> some IntentResult {
        // Build a deep link the app can parse deterministically.
        var url = URLComponents(string: "focusar://start")!
        var items: [URLQueryItem] = []
        if let minutes, minutes > 0 {
            items.append(.init(name: "minutes", value: String(minutes)))
        }
        if let mode { items.append(.init(name: "mode", value: mode.rawValue)) }
        url.queryItems = items.isEmpty ? nil : items
        return .result(opensIntent: OpenURLIntent(url.url!))
    }

    // Optional: provide default phrases that show in Siri suggestions/Shortcuts.
    static var parameterSummary: some ParameterSummary {
        Summary(
            "Start Focus Session (Minutes: \(\.$minutes), Mode: \(\.$mode))"
        )
    }
}

// MARK: - End Session

struct EndFocusSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "End Focus Session"
    static var description = IntentDescription(
        "End the current AR session in FocusAR."
    )
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        let url = URL(string: "focusar://end")!
        return .result(opensIntent: OpenURLIntent(url))
    }
}

// MARK: - App Shortcuts

struct FocusARShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartFocusSessionIntent(),
            phrases: [
                "Start mindfulness in \(.applicationName)",
                "Begin a focus session in \(.applicationName)",
                "Help me focus with \(.applicationName)",
            ],
            shortTitle: "Start Session",
            systemImageName: "camera.viewfinder"
        )

        AppShortcut(
            intent: EndFocusSessionIntent(),
            phrases: [
                "End focus in \(.applicationName)",
                "Stop session in \(.applicationName)",
            ],
            shortTitle: "End Session",
            systemImageName: "xmark.circle.fill"
        )
    }
}
