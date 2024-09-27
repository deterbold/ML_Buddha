//
//  TimerView.swift
//  ML Buddha
//
//  Created by Miguel Sicart on 18/09/2024.
//

import UIKit

class TimerView: UIView {

    // MARK: - Properties

    private var timerLabel: UILabel!
    private var countdownTimer: Timer?
    private var timeRemaining: Int = 5
    private var totalTime: Int = 5

    // Closure to notify when the timer finishes
    var timerCompletionHandler: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - View Setup

    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = frame.size.width / 2
        layer.masksToBounds = true

        timerLabel = UILabel()
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont.systemFont(ofSize: 80, weight: .bold)
        timerLabel.textColor = .white
        timerLabel.text = "\(timeRemaining)"
        addSubview(timerLabel)

        // Center the timerLabel within TimerView
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Timer Functions

    func startTimer(duration: Int) {
        totalTime = duration
        timeRemaining = duration
        timerLabel.text = "\(timeRemaining)"

        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                              target: self,
                                              selector: #selector(updateTimer),
                                              userInfo: nil,
                                              repeats: true)
    }

    @objc private func updateTimer() {
        playBlipSound() // Play sound each second

        timeRemaining -= 1
        timerLabel.text = "\(timeRemaining)"

        if timeRemaining <= 0 {
            countdownTimer?.invalidate()
            timerCompletionHandler?()
        }
    }

    func stopTimer() {
        countdownTimer?.invalidate()
    }

    // MARK: - Sound Playback

    private func playBlipSound() {
        SoundManager.shared.playSound(named: "blip", withExtension: "aiff")
    }
}



