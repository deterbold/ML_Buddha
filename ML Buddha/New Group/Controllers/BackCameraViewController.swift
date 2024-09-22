//
//  BackCameraViewController.swift
//  ML Buddha
//
//  Created by Miguel Sicart on 18/09/2024.
//

import UIKit
import AVFoundation
import Vision
import CoreML

class BackCameraViewController: UIViewController, CameraManagerDelegate, ObjectRecognitionManagerDelegate {

    // MARK: - Properties

    let cameraManager = CameraManager()
    let recognitionManager = ObjectRecognitionManager()
    var timerView: TimerView!
    var isTimerRunning = false

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupRecognitionManager()
        setupCamera()
        setupTimerView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isTimerRunning = false
        cameraManager.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopSession()
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

    // MARK: - TimerView Setup

    func setupTimerView() {
        let timerSize: CGFloat = 200
        timerView = TimerView(frame: CGRect(x: (view.bounds.width - timerSize) / 2,
                                            y: (view.bounds.height - timerSize) / 2,
                                            width: timerSize,
                                            height: timerSize))
        timerView.isHidden = true
        timerView.timerCompletionHandler = { [weak self] in
            guard let self = self else { return }
            self.isTimerRunning = false
            self.timerView.isHidden = true
            self.transitionToFrontCamera()
        }
        view.addSubview(timerView)
    }

    // MARK: - Transition to Front Camera

    func transitionToFrontCamera() {
        cameraManager.stopSession()

        let frontCameraVC = FrontCameraViewController()
        frontCameraVC.modalPresentationStyle = .fullScreen
        present(frontCameraVC, animated: true, completion: nil)
    }

    // MARK: - Start Timer

    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timerView.isHidden = false
        timerView.startTimer(duration: 5)
    }

    // MARK: - ObjectRecognitionManagerDelegate

    func didRecognizeTargetObject() {
        DispatchQueue.main.async {
            self.startTimer()
        }
    }

    func didLoseTargetObject() {
        // Handle if needed
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
        guard !isTimerRunning else { return }
        recognitionManager.processSampleBuffer(sampleBuffer)
    }

    func didChangeAuthorizationStatus(isAuthorized: Bool) {
        if isAuthorized {
            cameraManager.configureSession(position: .back)
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

