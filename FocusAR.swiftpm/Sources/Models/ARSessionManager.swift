import ARKit
import Foundation
import RealityKit

struct TimerWrapper: @unchecked Sendable {
    let timer: Timer
    func invalidate() {
        timer.invalidate()
    }
}

@MainActor
class ARSessionManager: NSObject, ObservableObject {
    @Published var isSessionReady = false
    private var arView: ARView?
    private let clutterDetector = ClutterDetector()

    @Published var sessionProgress: Double = 0.0
    private var progressTimer: TimerWrapper?

    override init() {
        super.init()
        setupProgressTimer()
    }

    func setupARView(_ view: ARView) {
        arView = view
        
        guard !ProcessInfo.processInfo.isPreview else {
            // Add mock content for SwiftUI previews
            let sphere = ModelEntity(mesh: .generateSphere(radius: 0.1),
                                     materials: [SimpleMaterial(color: .blue, isMetallic: false)])
            let anchor = AnchorEntity(world: [0, 0, -0.5])
            anchor.addChild(sphere)
            view.scene.addAnchor(anchor)
            return
        }

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        view.session.delegate = self
        view.session.run(config)
        
        DispatchQueue.main.async { [weak self] in
            self?.isSessionReady = true
        }
    }

    private func setupProgressTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.sessionProgress < 1.0 {
                    // 3-minute session => 180 seconds => 1800 intervals of 0.1s
                    // So 1 / 1800 = ~0.00056 per interval
                    self.sessionProgress += 0.00056
                } else {
                    self.progressTimer?.invalidate()
                }
            }
        }
        progressTimer = TimerWrapper(timer: timer)
    }

    deinit {
        progressTimer?.invalidate()
    }

    func triggerARFeedback(at point: CGPoint) {
        guard let arView = arView else { return }
        if let raycastResult = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal).first {
            let worldTransform = raycastResult.worldTransform
            let position = SIMD3<Float>(worldTransform.columns.3.x,
                                        worldTransform.columns.3.y,
                                        worldTransform.columns.3.z)

            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.05),
                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
            )
            sphere.position = position

            let anchor = AnchorEntity(world: position)
            anchor.addChild(sphere)
            arView.scene.addAnchor(anchor)

            let scaleUp = SIMD3<Float>(repeating: 2.0)
            sphere.move(to: Transform(scale: scaleUp, rotation: sphere.transform.rotation, translation: sphere.position),
                        relativeTo: sphere.parent,
                        duration: 0.5)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                anchor.removeFromParent()
            }
        }
    }
}

extension ARSessionManager: ARSessionDelegate {
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Only process every 10th frame to reduce overhead.
        if Int(frame.timestamp) % 10 == 0 {
            // Extract only the pixel buffer so we don't retain the entire ARFrame.
            let pixelBuffer = frame.capturedImage
            Task { @MainActor in
                self.clutterDetector.detectClutter(in: pixelBuffer)
            }
        }
    }
}
