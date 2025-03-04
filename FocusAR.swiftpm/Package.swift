// swift-tools-version: 6.0

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "FocusAR",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "FocusAR",
            targets: ["AppModule"],
            bundleIdentifier: "com.arieljtyson.FocusAR",
            teamIdentifier: "2MPMKAF986",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "FocusAR uses the camera to provide augmented reality experiences for clutter detection and organization.")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .copy("Resources/CustomClutter.mlmodelc"),
                .copy("Auxiliary/Sounds/calm_sound.aac")
            ]
        )
    ],
    swiftLanguageVersions: [.version("6")]
)
