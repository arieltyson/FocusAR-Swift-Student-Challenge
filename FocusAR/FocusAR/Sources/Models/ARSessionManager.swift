import ARKit
import Foundation
import RealityKit

@MainActor
final class ARSessionManager: NSObject, ObservableObject {
    @Published private(set) var isSessionReady = false
    private var arView: ARView?
    private let clutterDetector = ClutterDetector()

    func setupARView(_ view: ARView) {
        arView = view

        guard !ProcessInfo.processInfo.isPreview else {
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.1),
                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
            )
            let anchor = AnchorEntity(world: [0, 0, -0.5])
            anchor.addChild(sphere)
            view.scene.addAnchor(anchor)
            return
        }

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        view.session.delegate = self
        view.session.run(config)
    }

    func triggerARFeedback(at point: CGPoint) {
        guard let arView = arView else { return }
        if let hit = arView.raycast(
            from: point,
            allowing: .estimatedPlane,
            alignment: .horizontal
        ).first {
            let t = hit.worldTransform
            let pos = SIMD3<Float>(t.columns.3.x, t.columns.3.y, t.columns.3.z)

            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.05),
                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
            )
            sphere.position = pos

            let anchor = AnchorEntity(world: pos)
            anchor.addChild(sphere)
            arView.scene.addAnchor(anchor)

            sphere.move(
                to: Transform(
                    scale: .init(repeating: 2.0),
                    rotation: sphere.transform.rotation,
                    translation: sphere.position
                ),
                relativeTo: sphere.parent,
                duration: 0.5
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                anchor.removeFromParent()
            }
        }
    }
}

extension ARSessionManager: ARSessionDelegate {
    nonisolated func session(
        _ session: ARSession,
        cameraDidChangeTrackingState camera: ARCamera
    ) {
        if case .normal = camera.trackingState {
            Task { @MainActor in
                if !self.isSessionReady { self.isSessionReady = true }
            }
        }
    }

    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        struct Throttle { static var last: TimeInterval = 0 }
        let now = frame.timestamp
        guard now - Throttle.last >= 0.5 else { return }
        Throttle.last = now

        let pixelBuffer = frame.capturedImage
        Task { @MainActor in
            self.clutterDetector.detectClutter(in: pixelBuffer)
        }
    }
}
