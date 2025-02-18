//
//  File.swift
//  FocusAR
//
//  Created by Ariel Tyson on 18/2/25.
//

// ARKit/RealityKit integration

import SwiftUI
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    var arSession: ARSessionManager
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arSession.setupARView(arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
