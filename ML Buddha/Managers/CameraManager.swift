//
//  CameraManager.swift
//  ML Buddha
//
//  Created by Miguel Sicart on 18/09/2024.
//

import AVFoundation
import UIKit

protocol CameraManagerDelegate: AnyObject {
    func didOutput(sampleBuffer: CMSampleBuffer)
    func didChangeAuthorizationStatus(isAuthorized: Bool)
}

class CameraManager: NSObject {
    
    // MARK: - Properties
    
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    weak var delegate: CameraManagerDelegate?
    
    var isSessionRunning: Bool {
        return captureSession.isRunning
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    // MARK: - Session Management
    
    func configureSession(position: AVCaptureDevice.Position) {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high
            
            // Remove existing inputs
            if let currentInput = self.videoDeviceInput {
                self.captureSession.removeInput(currentInput)
            }
            
            // Add new input
            do {
                if let videoDevice = self.getCamera(position: position) {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    if self.captureSession.canAddInput(videoDeviceInput) {
                        self.captureSession.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        print("Could not add video device input to the session")
                        self.captureSession.commitConfiguration()
                        return
                    }
                } else {
                    print("Could not find camera with specified position")
                    self.captureSession.commitConfiguration()
                    return
                }
            } catch {
                print("Could not create video device input: \(error)")
                self.captureSession.commitConfiguration()
                return
            }
            
            // Add video output
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))
            videoOutput.alwaysDiscardsLateVideoFrames = true
            if self.captureSession.canAddOutput(videoOutput) {
                self.captureSession.addOutput(videoOutput)
                videoOutput.connection(with: .video)?.videoOrientation = .portrait
            } else {
                print("Could not add video data output to the session")
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.commitConfiguration()
        }
    }
    
    func startSession() {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func switchCamera(position: AVCaptureDevice.Position) {
        configureSession(position: position)
    }
    
    // MARK: - Preview Layer
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
        }
        return previewLayer
    }
    
    // MARK: - Camera Authorization
    
    func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            delegate?.didChangeAuthorizationStatus(isAuthorized: true)
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                self.sessionQueue.resume()
                self.delegate?.didChangeAuthorizationStatus(isAuthorized: granted)
            }
        default:
            delegate?.didChangeAuthorizationStatus(isAuthorized: false)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        return discoverySession.devices.first
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.didOutput(sampleBuffer: sampleBuffer)
    }
}

