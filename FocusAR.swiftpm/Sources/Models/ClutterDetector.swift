import ARKit
import CoreML
import Vision

class ClutterDetector {
    private var vnModel: VNCoreMLModel?
    
    init() {
        // Load the compiled model from the package's resources.
        guard let modelURL = Bundle.module.url(forResource: "ClutterClassifier", withExtension: "mlmodelc") else {
            print("Could not find compiled ClutterClassifier.mlmodelc in resources. Falling back to saliency detection.")
            return
        }
        
        do {
            let compiledModel = try MLModel(contentsOf: modelURL)
            self.vnModel = try VNCoreMLModel(for: compiledModel)
        } catch {
            print("Error loading compiled model: \(error). Falling back to saliency detection.")
        }
    }
    
    /// Detect clutter in a pixel buffer (extracted from ARFrame).
    func detectClutter(in pixelBuffer: CVPixelBuffer) {
        if let vnModel = vnModel {
            // Use the Core ML model for clutter detection.
            let request = VNCoreMLRequest(model: vnModel) { request, error in
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else { return }
                
                let identifier = topResult.identifier
                let confidence = topResult.confidence
                
                DispatchQueue.main.async {
                    if identifier == "cluttered" && confidence > 0.5 {
                        AudioManager.shared.playCalmingSound()
                        HapticsManager.shared.playGentlePulse()
                    }
                }
            }
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try? handler.perform([request])
        } else {
            // Fallback: Use a saliency request for basic image analysis.
            let request = VNGenerateObjectnessBasedSaliencyImageRequest()
            do {
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
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
