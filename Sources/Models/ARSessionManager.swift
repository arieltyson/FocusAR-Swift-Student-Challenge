//
//  File.swift
//  FocusAR
//
//  Created by Ariel Tyson on 18/2/25.
//

// AR Session Handling

import SwiftUI
import ARKit
import RealityKit
import CoreML
import Vision
import AVFoundation
import CoreHaptics

class ARSessionManager: NSObject, ObservableObject {
    private var arView: ARView?
    private let classifier = ClutterClassifier()
    
    func setupARView(_ view: ARView) {
        arView = view
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        view.session.run(config)
    }
    
    func analyzeCurrentFrame() {
        guard let frame = arView?.session.currentFrame else { return }
        classifier.detectClutter(in: frame)
    }
}
