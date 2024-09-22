//
//  FrontCameraViewController.swift
//  ML Buddha
//
//  Created by Miguel Sicart on 18/09/2024.
//
import UIKit
import AVFoundation
import Vision
import CoreML

class FrontCameraViewController: UIViewController, CameraManagerDelegate, ObjectRecognitionManagerDelegate {

    // MARK: - Properties

    let cameraManager = CameraManager()
    let recognitionManager = ObjectRecognitionManager()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupRecognitionManager()
        setupCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraManager.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopSession()
        SoundManager.shared.stopSound()
    }

    // MARK: - Recognition Manager Setup

    func setupRecognitionManager() {
        recognitionManager.delegate = self
    }

    // MARK: - Camera Setup

    func setupCamera() {
        cameraManager.delegate = self
        cameraManager.checkCameraAuthorization()
    }

    // MARK: - Transition Back to Back Camera

    func returnToBackCamera() {
        cameraManager.stopSession()
        SoundManager.shared.stopSound()
        dismiss(animated: true, completion: nil)
    }

    // MARK: - ObjectRecognitionManagerDelegate

    func didRecognizeTargetObject() {
        DispatchQueue.main.async {
            SoundManager.shared.playSound(named: "buddha_sound", withExtension: "wav", numberOfLoops: -1)
        }
    }

    func didLoseTargetObject() {
        DispatchQueue.main.async {
            self.returnToBackCamera()
        }
    }

    func didEncounterRecognitionError(_ error: Error) {
        print("Recognition error: \(error.localizedDescription)")
        // Handle error, possibly show an alert
    }

    func didUpdateRecognizedObjects(_ objects: [(identifier: String, confidence: VNConfidence)]) {
        // Print out the recognized objects
        for (identifier, confidence) in objects {
            print("Recognized object: \(identifier), Confidence: \(confidence)")
        }
    }

    // MARK: - CameraManagerDelegate

    func didOutput(sampleBuffer: CMSampleBuffer) {
        recognitionManager.processSampleBuffer(sampleBuffer)
    }

    func didChangeAuthorizationStatus(isAuthorized: Bool) {
        if isAuthorized {
            cameraManager.configureSession(position: .front)
            DispatchQueue.main.async {
                if let previewLayer = self.cameraManager.getPreviewLayer() {
                    previewLayer.frame = self.view.bounds
                    self.view.layer.insertSublayer(previewLayer, at: 0)
                }
                self.cameraManager.startSession()
            }
        } else {
            // Handle unauthorized status
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Camera Access Denied", message: "Please enable camera access in Settings.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }
}
