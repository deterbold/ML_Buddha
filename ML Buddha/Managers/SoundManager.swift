//
//  SoundManager.swift
//  ML Buddha
//
//  Created by Miguel Sicart on 18/09/2024.
//

import Foundation
import AVFoundation

class SoundManager: NSObject {
    
    // MARK: - Properties
    
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?
    private var isAudioSessionConfigured = false
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    func playSound(named soundFileName: String, withExtension fileExtension: String = "mp3", numberOfLoops: Int = 0) {
        configureAudioSessionIfNeeded()
        
        guard let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: fileExtension) else {
            print("Sound file not found: \(soundFileName).\(fileExtension)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = numberOfLoops
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func pauseSound() {
        audioPlayer?.pause()
    }
    
    func resumeSound() {
        audioPlayer?.play()
    }
    
    // MARK: - Private Methods
    
    private func configureAudioSessionIfNeeded() {
        guard !isAudioSessionConfigured else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            isAudioSessionConfigured = true
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
}

