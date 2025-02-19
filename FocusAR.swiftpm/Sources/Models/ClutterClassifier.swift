//
//  File.swift
//  FocusAR
//
//  Created by Ariel Tyson on 18/2/25.
//

// Core ML Model Wrapper

import SwiftUI
import ARKit
import RealityKit
import CoreML
import Vision
import AVFoundation
import CoreHaptics

class ClutterClassifier {
    private var model: VNCoreMLModel?
    
    init() {
        guard let model = try? VNCoreMLModel(for: ClutterClassifier(configuration: .init()).model) else {
            fatalError("Failed to load Core ML model")
        }
        self.model = model
    }
    
    func detectClutter(in frame: ARFrame) {
        let request = VNCoreMLRequest(model: model!) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else { return }
            
            DispatchQueue.main.async {
                if topResult.identifier == "cluttered" {
                    self.triggerARFeedback()
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage)
        try? handler.perform([request])
    }
    
    private func triggerARFeedback() {
        // Add ARKit/RealityKit animations here
    }
}
