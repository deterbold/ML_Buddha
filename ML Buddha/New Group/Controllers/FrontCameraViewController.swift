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
    var recognizedObjectLabel: UILabel!
    var boundingBoxLayers = [CAShapeLayer]()

    // New properties
    let droneSounds = ["drone1", "drone2"] // Replace with your actual sound file names
    var isDroneSoundPlaying = false
    var lostObjectTimer: Timer?
    let lostObjectTimeout: TimeInterval = 3.0

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupRecognitionManager()
        setupCamera()
        setupRecognizedObjectLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraManager.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopSession()
        SoundManager.shared.stopSound()
        isDroneSoundPlaying = false
        lostObjectTimer?.invalidate()
        lostObjectTimer = nil
    }

    // MARK: - Recognition Manager Setup

    func setupRecognitionManager() {
        recognitionManager.delegate = self
        //recognitionManager.targetObjectIdentifier = "buddha" // Ensure the target identifier is set
    }

    // MARK: - Camera Setup

    func setupCamera() {
        cameraManager.delegate = self
        cameraManager.checkCameraAuthorization()
    }

    // MARK: - Recognized Object Label Setup

    func setupRecognizedObjectLabel() {
        recognizedObjectLabel = UILabel()
        recognizedObjectLabel.translatesAutoresizingMaskIntoConstraints = false
        recognizedObjectLabel.textAlignment = .center
        recognizedObjectLabel.textColor = .white
        recognizedObjectLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        recognizedObjectLabel.numberOfLines = 0 // Allow multiple lines
        recognizedObjectLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        recognizedObjectLabel.layer.cornerRadius = 8
        recognizedObjectLabel.layer.masksToBounds = true

        view.addSubview(recognizedObjectLabel)

        NSLayoutConstraint.activate([
            recognizedObjectLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recognizedObjectLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            recognizedObjectLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            recognizedObjectLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }

    // MARK: - Transition Back to Back Camera

    func returnToBackCamera() {
        cameraManager.stopSession()
        SoundManager.shared.stopSound()
        isDroneSoundPlaying = false
        lostObjectTimer?.invalidate()
        lostObjectTimer = nil
        dismiss(animated: true, completion: nil)
    }

    // MARK: - ObjectRecognitionManagerDelegate

    func didRecognizeTargetObject() {
        DispatchQueue.main.async {
            self.handleBuddhaDetected()
        }
    }

    func didLoseTargetObject() {
        DispatchQueue.main.async {
            self.handleBuddhaNotDetected()
        }
    }

    func didEncounterRecognitionError(_ error: Error) {
        print("Recognition error: \(error.localizedDescription)")
        // Handle error, possibly show an alert
    }

    func didUpdateRecognizedObjects(_ objects: [RecognizedObject]) {
        DispatchQueue.main.async {
            let confidenceThreshold: VNConfidence = 0.5
            let filteredObjects = objects.filter { $0.confidence > confidenceThreshold }
            let objectStrings = filteredObjects.map { "\($0.identifier) (\(Int($0.confidence * 100))%)" }

            if objectStrings.isEmpty {
                self.recognizedObjectLabel.text = "No objects recognized"
            } else {
                self.recognizedObjectLabel.text = objectStrings.joined(separator: "\n")
            }

            // Draw bounding boxes
            self.drawBoundingBoxes(for: filteredObjects)
        }
    }

    // MARK: - Handling Buddha Detection

    func handleBuddhaDetected() {
        // Reset lost object timer
        self.lostObjectTimer?.invalidate()
        self.lostObjectTimer = nil

        // Start playing drone sound if not already playing
        if !self.isDroneSoundPlaying {
            self.isDroneSoundPlaying = true
            self.playRandomDroneSound()
        }
    }

    func handleBuddhaNotDetected() {
        // Start or continue lost object timer
        if self.lostObjectTimer == nil {
            self.lostObjectTimer = Timer.scheduledTimer(timeInterval: lostObjectTimeout, target: self, selector: #selector(self.lostObjectTimerFired), userInfo: nil, repeats: false)
        }
    }

    @objc func lostObjectTimerFired() {
        // Buddha not detected for lostObjectTimeout seconds
        self.lostObjectTimer?.invalidate()
        self.lostObjectTimer = nil

        // Stop drone sound if playing
        if self.isDroneSoundPlaying {
            SoundManager.shared.stopSound()
            self.isDroneSoundPlaying = false
        }

        // Play "blip.aiff" sound
        SoundManager.shared.playSound(named: "blip", withExtension: "aiff")

        // Return to BackCameraViewController after a brief delay to allow sound to play
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.returnToBackCamera()
        }
    }

    func playRandomDroneSound() {
        guard let randomSoundName = self.droneSounds.randomElement() else {
            print("No drone sounds available.")
            return
        }

        SoundManager.shared.playSound(named: randomSoundName, withExtension: "mp3", numberOfLoops: -1)
    }

    // MARK: - Drawing Bounding Boxes

    func drawBoundingBoxes(for objects: [RecognizedObject]) {
        // Remove existing bounding boxes
        for layer in boundingBoxLayers {
            layer.removeFromSuperlayer()
        }
        boundingBoxLayers.removeAll()

        guard let previewLayer = cameraManager.getPreviewLayer() else { return }

        for object in objects {
            let convertedRect = convertBoundingBox(object.boundingBox, in: previewLayer)
            let boundingBoxPath = UIBezierPath(rect: convertedRect)

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = boundingBoxPath.cgPath
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = 2.0

            boundingBoxLayers.append(shapeLayer)
            previewLayer.addSublayer(shapeLayer)
        }
    }

    func convertBoundingBox(_ boundingBox: CGRect, in layer: AVCaptureVideoPreviewLayer) -> CGRect {
        // Convert normalized bounding box to layer coordinates
        let x = boundingBox.origin.x
        let y = 1 - boundingBox.origin.y - boundingBox.height
        let width = boundingBox.width
        let height = boundingBox.height

        let rect = CGRect(x: x, y: y, width: width, height: height)
        let convertedRect = layer.layerRectConverted(fromMetadataOutputRect: rect)
        return convertedRect
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

