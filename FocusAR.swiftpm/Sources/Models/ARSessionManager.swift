//
//  File.swift
//  FocusAR
//
//  Created by Ariel Tyson on 18/2/25.
//

// AR Session Handling

import ARKit
import RealityKit

@MainActor
class ARSessionManager: NSObject, ObservableObject {
    
    @Published var isSessionReady = false
    private var arView: ARView?
    private let clutterDetector = ClutterDetector()
    
    @Published var sessionProgress: Double = 0.0
    private var progressTimer: Timer?
    
    override init() {
        super.init()
        setupProgressTimer()
    }
    
    func setupARView(_ view: ARView) {
        arView = view
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        view.session.delegate = self
        view.session.run(config)
        isSessionReady = true
    }
    
    private func setupProgressTimer() {
        // 3-minute session timer
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.sessionProgress < 1.0 {
                    self.sessionProgress += 0.00056 // Reaches 1.0 in 3 minutes
                } else {
                    self.progressTimer?.invalidate()
                }
            }
        }
    }
    
    deinit {
        progressTimer?.invalidate()
    }
    
    /// Triggers an AR overlay animation at the tapped screen location.
    func triggerARFeedback(at point: CGPoint) {
        guard let arView = arView else { return }
        // Perform a raycast from the tapped point.
        if let raycastResult = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal).first {
            let worldTransform = raycastResult.worldTransform
            let position = SIMD3<Float>(worldTransform.columns.3.x,
                                        worldTransform.columns.3.y,
                                        worldTransform.columns.3.z)
            
            // Create a simple sphere to represent the “organizing” feedback.
            let sphere = ModelEntity(mesh: .generateSphere(radius: 0.05),
                                     materials: [SimpleMaterial(color: .blue, isMetallic: false)])
            sphere.position = position
            
            // Anchor the entity in the AR scene.
            let anchor = AnchorEntity(world: position)
            anchor.addChild(sphere)
            arView.scene.addAnchor(anchor)
            
            // Animate: scale the sphere up to simulate an expanding effect.
            let scaleUp = SIMD3<Float>(repeating: 2.0)
            sphere.move(to: Transform(scale: scaleUp,
                                      rotation: sphere.transform.rotation,
                                      translation: sphere.position),
                        relativeTo: sphere.parent,
                        duration: 0.5)
            
            // Remove the entity shortly after the animation completes.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                anchor.removeFromParent()
            }
        }
    }
}

extension ARSessionManager: ARSessionDelegate {
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Dispatch back to the main actor to safely access main‑actor properties.
        Task { @MainActor in
            // Process every 10th frame to conserve resources.
            if Int(frame.timestamp) % 10 == 0 {
                self.clutterDetector.detectClutter(in: frame)
            }
        }
    }
}

extension Timer: @unchecked @retroactive Sendable {}
