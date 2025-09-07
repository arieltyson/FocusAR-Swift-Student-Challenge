<div align="center">

# Focus AR 🥇 (Apple Swift Student Challenge 2025 Winner 🏆)

## Project Description 🎨

"FocusAR is more than an app. It is a proof of concept that code can be compassionate. By transforming AR and ML into tools for mindfulness, this project invites users to find calm in chaos, one interactive moment at a time."

## Demo:

https://github.com/user-attachments/assets/6bd06e67-ac96-4f9e-88c0-2bc25e68bbfa

## Screenshots:

<div style="display: flex; justify-content: center; align-items: center;">
    <kbd>
        <img src="https://github.com/user-attachments/assets/86666338-6839-40fa-bd2d-3602bd90e82f" alt="Main Page" width="200">
    </kbd>
    <kbd>
        <img src="https://github.com/user-attachments/assets/d288b3be-6cec-4cac-ab89-91260de3d388" alt="Description" width="200">
    </kbd>
    <kbd>
        <img src="https://github.com/user-attachments/assets/c7e20b35-34b7-4928-8f43-9be8aa6f1609" alt="How It Works" width="200">
    </kbd>
</div>

<div style="display: flex; justify-content: center; align-items: center;">
    <kbd>
        <img src="https://github.com/user-attachments/assets/b301a31d-4001-467a-94c1-ab5e508826c6" alt="Speech Intelligence" width="200">
    </kbd>
    <kbd>
        <img src="https://github.com/user-attachments/assets/82ff1b25-2301-4726-b68e-f30d599e336a" alt="Siri Shortcuts" width="200">
    </kbd>
    <kbd>
        <img src="https://github.com/user-attachments/assets/b623f2b6-3790-495c-a497-ccfa12aad29d" alt="Untimed" width="200">
    </kbd>
</div>

<div style="display: flex; justify-content: center; align-items: center;">
    <kbd>
        <img src="https://github.com/user-attachments/assets/2a1a7fa3-32d5-45c3-a01c-fe3e3f5db4f8" alt="Privacy" width="200">
    </kbd>
    <kbd>
        <img src="https://github.com/user-attachments/assets/ce65b773-f9c7-4ccb-906d-baa7f68b95ce" alt="AR View" width="200">
    </kbd>
    <kbd>
        <img src="https://github.com/user-attachments/assets/070278dd-0c02-4707-a850-d032c1cd8ee2" alt="Lottie" width="200">
    </kbd>
</div>

---
## What’s New ✨
<div align="left">

### Voice-Activated Mindfulness Sessions
- **Siri + App Intents:** Start/end sessions hands-free with Shortcuts phrases (e.g., “Start a focus session in FocusAR”).
- **Deep Links:** App Intents open the app via a custom URL scheme to pass parameters:
  - `focusar://start?minutes=10&mode=calming`
  - `focusar://end`
- **In-Session Voice Controls:** On-device speech recognition plus **Foundation Models** classification maps phrases → actions:
  - “End session” → exits session
  - “Mute / Unmute” → toggles calming audio
- **Private by design:** Speech transcription and intent classification run **on device**.

### Open-Ended Sessions
- Sessions are no longer time-boxed. A subtle timer and a prominent **End** button give you control.

### Award-Oriented UX
- Refined onboarding that clearly explains AR guidance, voice control, privacy, and accessibility.
- A focused **Home** screen that centers the experience, with tasteful animations (optional Lottie confetti on session end).

---

## Features

- **Mindful AR Guidance:** Tap identified “busy” areas in your environment to receive calming cues (haptics + sound).
- **On-Device Intelligence:** 
  - **Speech** (SFSpeechRecognizer) for transcription
  - **Foundation Models (iOS 18+)** for intent classification (end/mute/unmute)
- **Hands-Free Control with Siri:** App Intents + Shortcuts launch sessions and pass parameters.
- **Accessibility & Inclusivity:** Dynamic Type, VoiceOver labels, Reduce Motion fallbacks, safe-area-aware HUD.
- **Privacy:** No camera frames or audio leave your device.

---
</div>

## Technologies Used 💻

This project leverages the powerful combination of Swift and SwiftUI, along with other native iOS APIs.

- [x] Swift
- [x] ARKit
- [x] CoreML
- [x] Vision
- [x] Speech
- [x] Lottie
- [x] SwiftUI
- [x] Combine
- [x] Foundation
- [x] Core Image
- [x] RealityKit
- [x] App Intents
- [x] Core Haptics
- [x] AVFoundation
- [x] Accessibility
- [x] Foundation Models

## Skills Demonstrated 🥋

This project showcases a wide array of skills necessary for developing a feature-rich mobile application. The following skills were demonstrated:

- [x] **AUGMENTED REALITY**: Exploratory investigation into the benefits of using augmented reality to further technology
- [x] **On-Device Intelligence:** Integrated **Speech** + **Foundation Models** to map natural language to concrete app intents.
- [x] **Siri / Shortcuts Development:** App Intents, deep links, and parameterized launches.
- [x] **Advanced SwiftUI:** Safe-area layout for Dynamic Island/notches, `safeAreaPadding`, custom button styles, accessible animations/fallbacks.
- [x] **Performance & Responsiveness:** Throttled frame handling, main-actor UI updates, minimal allocations.
- [x] **Privacy by Design:** Camera analysis, speech, and classification remain on device with clear user disclosures.

## Contributing ⚙️

We welcome contributions from developers and enthusiasts who are passionate about creating immersive mobile experiences. If you have an idea for a new feature or a code improvement, feel free to fork our repository, make your changes, and submit a pull request. Let's collaborate to enhance "Focus AR" together.

## License 🪪

This project is licensed under the MIT License, allowing you to modify, distribute, and use the code with proper attribution to the original creators. Let's keep the spirit of open-source collaboration alive!

</div>
