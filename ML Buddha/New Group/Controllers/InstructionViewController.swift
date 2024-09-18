//
//  InstructionViewController.swift
//  ML Buddha
//
//  Created by Miguel Sicart on 18/09/2024.
//

import UIKit

class InstructionViewController: UIViewController {

    // MARK: - UI Elements

    let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to the Object Recognition App.\n\nPlease prepare the object for scanning and tap the button below to start."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Scanning", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(InstructionViewController.self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup

    func setupUI() {
        view.backgroundColor = .white

        // Add subviews
        view.addSubview(instructionLabel)
        view.addSubview(startButton)

        // Disable autoresizing mask translation
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Set up constraints
        NSLayoutConstraint.activate([
            // Instruction Label Constraints
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Start Button Constraints
            startButton.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 40),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions

    @objc func startButtonTapped() {
        let backCameraVC = BackCameraViewController()
        navigationController?.pushViewController(backCameraVC, animated: true)
    }
}
