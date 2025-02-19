//
//  File.swift
//  FocusAR
//
//  Created by Ariel Tyson on 18/2/25.
//

// ARKit/RealityKit integration

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    var arSession: ARSessionManager
        
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        arSession.setupARView(arView)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                               action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @MainActor
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = gesture.view as? ARView else { return }
            let tapLocation = gesture.location(in: arView)
            // Trigger the AR overlay animation at the tapped location.
            parent.arSession.triggerARFeedback(at: tapLocation)
            
            // Also provide immediate audio and haptic feedback.
            AudioManager.shared.playCalmingSound()
            HapticsManager.shared.playGentlePulse()
        }
    }
}
