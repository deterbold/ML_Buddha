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

class BackCameraViewController: UIViewController {

    // MARK: - Properties

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    var detectionRequest: VNCoreMLRequest!
    var detectionModel: VNCoreMLModel!

    var timerLabel: UILabel!
    var countdownTimer: Timer?
    var timeRemaining = 5

    var isTimerRunning = false

    // Replace 'YourCustomModel' with the name of your Core ML model class
    let modelName = YourCustomModel()

    // Replace 'YourObjectIdentifier' with the identifier of your target object
    let targetObjectIdentifier = "YourObjectIdentifier"

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupTimerLabel()
        setupModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    // MARK: - Camera Setup

    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("No back camera available")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                print("Unable to add back camera input to capture session")
                return
            }

            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            } else {
                print("Unable to add video output to capture session")
                return
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            captureSession.startRunning()
        } catch {
            print("Error setting up back camera: \(error.localizedDescription)")
        }
    }

    // MARK: - Timer Label Setup

    func setupTimerLabel() {
        timerLabel = UILabel()
        timerLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        timerLabel.center = view.center
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont.systemFont(ofSize: 80, weight: .bold)
        timerLabel.textColor = .white
        timerLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        timerLabel.layer.cornerRadius = 100
        timerLabel.layer.masksToBounds = true
        timerLabel.isHidden = true
        view.addSubview(timerLabel)
    }

    // MARK: - Model Setup

    func setupModel() {
        do {
            let config = MLModelConfiguration()
            detectionModel = try VNCoreMLModel(for: modelName.model)
            detectionRequest = VNCoreMLRequest(model: detectionModel, completionHandler: handleDetection)
        } catch {
            print("Error loading Core ML model: \(error.localizedDescription)")
        }
    }

    // MARK: - Transition to Front Camera

    func transitionToFrontCamera() {
        let frontCameraVC = FrontCameraViewController()
        frontCameraVC.modalPresentationStyle = .fullScreen
        present(frontCameraVC, animated: true, completion: nil)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension BackCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isTimerRunning else { return } // Skip processing if timer is running

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([detectionRequest])
        } catch {
            print("Error performing detection request: \(error.localizedDescription)")
        }
    }
}

// MARK: - Detection Handling

extension BackCameraViewController {

    func handleDetection(request: VNRequest, error: Error?) {
        if let error = error {
            print("Detection error: \(error.localizedDescription)")
            return
        }

        guard let results = request.results as? [VNClassificationObservation] else { return }

        if let topResult = results.first {
            if topResult.identifier == targetObjectIdentifier && topResult.confidence > 0.8 {
                DispatchQueue.main.async {
                    self.startTimer()
                }
            }
        }
    }
}

// MARK: - Timer Functions

extension BackCameraViewController {

    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timeRemaining = 5
        timerLabel.text = "\(timeRemaining)"
        timerLabel.isHidden = false

        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc func updateTimer() {
        timeRemaining -= 1
        timerLabel.text = "\(timeRemaining)"

        if timeRemaining <= 0 {
            countdownTimer?.invalidate()
            timerLabel.isHidden = true
            isTimerRunning = false
            transitionToFrontCamera()
        }
    }
}
