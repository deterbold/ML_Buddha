//
//  ObjectRecognitionManager.swift
//  ML Buddha
//
//  Created by Miguel Sicart on 18/09/2024.
//

import Foundation
import Vision
import CoreML
import AVFoundation

protocol ObjectRecognitionManagerDelegate: AnyObject {
    func didRecognizeTargetObject()
    func didLoseTargetObject()
    func didEncounterRecognitionError(_ error: Error)
    func didUpdateRecognizedObjects(_ objects: [(identifier: String, confidence: VNConfidence)])
}

class ObjectRecognitionManager {
    
    // MARK: - Properties
    
    private var detectionRequest: VNCoreMLRequest!
    private var detectionModel: VNCoreMLModel!
    private var modelName: FastViTMA36F16!
    
    private var isObjectDetected = false
    private var detectionCounter = 0
    private let detectionThreshold = 5
    
    // Replace 'YourObjectIdentifier' with the identifier of your target object
    private let targetObjectIdentifier = "YourObjectIdentifier"
    
    weak var delegate: ObjectRecognitionManagerDelegate?
    
    // MARK: - Initialization
    
    init() {
        setupModel()
    }
    
    // MARK: - Model Setup
    
    private func setupModel() {
        do {
            let defaultConfig = MLModelConfiguration()
            modelName = try FastViTMA36F16(configuration: defaultConfig)
            detectionModel = try VNCoreMLModel(for: modelName.model)
            detectionRequest = VNCoreMLRequest(model: detectionModel, completionHandler: handleDetection)
        } catch {
            delegate?.didEncounterRecognitionError(error)
        }
    }
    
    // MARK: - Processing Frames
    
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([detectionRequest])
        } catch {
            delegate?.didEncounterRecognitionError(error)
        }
    }
    
    // MARK: - Detection Handling
    
    private func handleDetection(request: VNRequest, error: Error?) {
        if let error = error {
            delegate?.didEncounterRecognitionError(error)
            return
        }
        
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        // Extract identifiers and confidences
        let recognizedObjects = results.map { ($0.identifier, $0.confidence) }
        
        // Notify the delegate with the recognized objects
        DispatchQueue.main.async {
            self.delegate?.didUpdateRecognizedObjects(recognizedObjects)
        }
        
        // Existing logic for detecting the target object
        if let topResult = results.first {
            if topResult.identifier == targetObjectIdentifier && topResult.confidence > 0.8 {
                detectionCounter = 0
                if !isObjectDetected {
                    isObjectDetected = true
                    DispatchQueue.main.async {
                        self.delegate?.didRecognizeTargetObject()
                    }
                }
            } else {
                detectionCounter += 1
                if detectionCounter > detectionThreshold {
                    if isObjectDetected {
                        isObjectDetected = false
                        DispatchQueue.main.async {
                            self.delegate?.didLoseTargetObject()
                        }
                    }
                }
            }
        } else {
            detectionCounter += 1
            if detectionCounter > detectionThreshold {
                if isObjectDetected {
                    isObjectDetected = false
                    DispatchQueue.main.async {
                        self.delegate?.didLoseTargetObject()
                    }
                }
            }
        }
    }
}
