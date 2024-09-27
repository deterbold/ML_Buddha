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
    func didUpdateRecognizedObjects(_ objects: [RecognizedObject])
}

struct RecognizedObject {
    let identifier: String
    let confidence: VNConfidence
    let boundingBox: CGRect
}

class ObjectRecognitionManager {
    
    // MARK: - Properties
    
    private var detectionRequest: VNCoreMLRequest!
    private var detectionModel: VNCoreMLModel!
    private var modelName: BuddhaViewer_Redux! // Replace with your model class name
    
    private var isObjectDetected = false
    private var detectionCounter = 0
    private let detectionThreshold = 5
    
    // Replace with your target object identifier
    private let targetObjectIdentifier = "buddha"
    
    weak var delegate: ObjectRecognitionManagerDelegate?
    
    // MARK: - Initialization
    
    init() {
        setupModel()
    }
    
    // MARK: - Model Setup
    
    private func setupModel() {
        do {
            let defaultConfig = MLModelConfiguration()
            modelName = try BuddhaViewer_Redux(configuration: defaultConfig) // Replace with your model class name
            detectionModel = try VNCoreMLModel(for: modelName.model)
            detectionRequest = VNCoreMLRequest(model: detectionModel, completionHandler: handleDetection)
            detectionRequest.imageCropAndScaleOption = .scaleFill
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
        
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
        
        // Convert observations to RecognizedObject
        let recognizedObjects = results.map { observation -> RecognizedObject in
            let identifier = observation.labels.first?.identifier ?? "Unknown"
            let confidence = observation.labels.first?.confidence ?? 0
            let boundingBox = observation.boundingBox
            return RecognizedObject(identifier: identifier, confidence: confidence, boundingBox: boundingBox)
        }
        
        // Notify the delegate with the recognized objects
        DispatchQueue.main.async {
            self.delegate?.didUpdateRecognizedObjects(recognizedObjects)
        }
        
        // Detect the target object
        if let targetObject = recognizedObjects.first(where: { $0.identifier == self.targetObjectIdentifier && $0.confidence > 0.8 }) {
            self.detectionCounter = 0
            if !self.isObjectDetected {
                self.isObjectDetected = true
                DispatchQueue.main.async {
                    self.delegate?.didRecognizeTargetObject()
                }
            }
        } else {
            self.detectionCounter += 1
            if self.detectionCounter > self.detectionThreshold {
                if self.isObjectDetected {
                    self.isObjectDetected = false
                    DispatchQueue.main.async {
                        self.delegate?.didLoseTargetObject()
                    }
                }
            }
        }
    }
}
