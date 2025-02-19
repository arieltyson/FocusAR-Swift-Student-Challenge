//
//  File.swift
//  FocusAR
//
//  Created by Ariel Tyson on 18/2/25.
//

// Core ML Model Wrapper

import ARKit
import CoreML

class ClutterDetector {
    private var vnModel: VNCoreMLModel?
    
    init() {
        // Attempt to load your Core ML model (ClutterClassifier.mlmodel).
        if let model = ClutterClassifier(configuration: MLModelConfiguration()).model,
           let vnModel = try? VNCoreMLModel(for: model) {
            self.vnModel = vnModel
        } else {
            print("Core ML model not loaded. Falling back to saliency detection.")
        }
    }
    
    func detectClutter(in frame: ARFrame) {
        if let vnModel = vnModel {
            // Use the Core ML model for clutter detection.
            let request = VNCoreMLRequest(model: vnModel) { request, error in
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else { return }
                
                DispatchQueue.main.async {
                    if topResult.identifier == "cluttered" && topResult.confidence > 0.5 {
                        AudioManager.shared.playCalmingSound()
                        HapticsManager.shared.playGentlePulse()
                    }
                }
            }
            
            let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, options: [:])
            try? handler.perform([request])
        } else {
            // Fallback: Use a saliency request for basic image analysis.
            let request = VNGenerateObjectnessBasedSaliencyImageRequest()
            do {
                let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, options: [:])
                try handler.perform([request])
                
                if let result = request.results?.first as? VNSaliencyImageObservation,
                   let salientObjects = result.salientObjects,
                   let maxConfidence = salientObjects.map({ Float($0.confidence) }).max() {
                    DispatchQueue.main.async {
                        if maxConfidence > 0.5 {
                            AudioManager.shared.playCalmingSound()
                            HapticsManager.shared.playGentlePulse()
                        }
                    }
                }
            } catch {
                print("Vision analysis failed: \(error)")
            }
        }
    }
}
