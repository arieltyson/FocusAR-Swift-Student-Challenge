import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    var arSession: ARSessionManager

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        arSession.setupARView(arView)

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap)
        )
        arView.addGestureRecognizer(tapGesture)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject {
        let parent: ARViewContainer
        init(_ parent: ARViewContainer) { self.parent = parent }

        @MainActor
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = gesture.view as? ARView else { return }
            parent.arSession.triggerARFeedback(at: gesture.location(in: arView))
            AudioManager.shared.playCalmingSound()
            HapticsManager.shared.playGentlePulse()
        }
    }
}

// MARK: - Preview Utilities
#if DEBUG
extension ProcessInfo {
    var isPreview: Bool {
        return self.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
#endif

// MARK: - Previews
#if DEBUG
struct ARViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ARViewContainer(arSession: ARSessionManager())
                .previewDisplayName("AR View Container (Static)")
                .previewDevice("iPad Pro (12.9-inch)")

            ARViewContainer(arSession: ARSessionManager())
                .previewDisplayName("AR View Container (Dark Mode)")
                .preferredColorScheme(.dark)
        }
    }
}
#endif
