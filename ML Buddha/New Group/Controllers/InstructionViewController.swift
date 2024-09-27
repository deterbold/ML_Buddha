//
//  InstructionViewController.swift
//  ML Buddha
//
//  Created by Miguel Sicart on 18/09/2024.
//

import UIKit

class InstructionViewController: UIViewController {

    // MARK: - Properties

    let imageView = UIImageView()
    let scanningButton = UIButton(type: .system)
    let instructionsButton = UIButton(type: .system)
    let creditsButton = UIButton(type: .system)

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        styleButton(scanningButton)
        styleButton(instructionsButton)
        styleButton(creditsButton)
    }

    // MARK: - UI Setup

    func setupUI() {
        view.backgroundColor = UIColor(red: 237/255, green: 226/255, blue: 191/255, alpha: 1.0)


        // Setup imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "MLBuddha") // Replace with your image name
        view.addSubview(imageView)

        // Setup scanningButton
        scanningButton.translatesAutoresizingMaskIntoConstraints = false
        scanningButton.setTitle("SEARCH FOR BUDDHA", for: .normal)
        scanningButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        scanningButton.addTarget(self, action: #selector(startScanning), for: .touchUpInside)
        view.addSubview(scanningButton)

        // Setup instructionsButton
        instructionsButton.translatesAutoresizingMaskIntoConstraints = false
        instructionsButton.setTitle("Instructions", for: .normal)
        instructionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        instructionsButton.addTarget(self, action: #selector(showInstructions), for: .touchUpInside)
        view.addSubview(instructionsButton)

        // Setup creditsButton
        creditsButton.translatesAutoresizingMaskIntoConstraints = false
        creditsButton.setTitle("Credits", for: .normal)
        creditsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        creditsButton.addTarget(self, action: #selector(showCredits), for: .touchUpInside)
        view.addSubview(creditsButton)

        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "App Logo"

        scanningButton.isAccessibilityElement = true
        scanningButton.accessibilityLabel = "SEARCH FOR BUDDHA"

        instructionsButton.isAccessibilityElement = true
        instructionsButton.accessibilityLabel = "View Instructions"

        creditsButton.isAccessibilityElement = true
        creditsButton.accessibilityLabel = "View Credits"

        // Add Constraints
        NSLayoutConstraint.activate([
            // ImageView Constraints
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120), // Adjusted from 20 to 120
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.33), // Top 1/3 of the screen

            // ScanningButton Constraints
            scanningButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            scanningButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanningButton.widthAnchor.constraint(equalToConstant: 200),
            scanningButton.heightAnchor.constraint(equalToConstant: 50),

            // InstructionsButton Constraints
            instructionsButton.topAnchor.constraint(equalTo: scanningButton.bottomAnchor, constant: 20),
            instructionsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionsButton.widthAnchor.constraint(equalToConstant: 200),
            instructionsButton.heightAnchor.constraint(equalToConstant: 50),

            // CreditsButton Constraints
            creditsButton.topAnchor.constraint(equalTo: instructionsButton.bottomAnchor, constant: 20),
            creditsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            creditsButton.widthAnchor.constraint(equalToConstant: 200),
            creditsButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    func styleButton(_ button: UIButton) {
        button.backgroundColor = UIColor(red: 161/255, green: 131/255, blue: 96/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
    }

    // MARK: - Actions

    @objc func startScanning() {
        let backCameraVC = BackCameraViewController()
        backCameraVC.modalPresentationStyle = .fullScreen
        present(backCameraVC, animated: true, completion: nil)
    }

    @objc func showInstructions() {
        let manualVC = ManualViewController()
        manualVC.modalPresentationStyle = .fullScreen
        present(manualVC, animated: true, completion: nil)
    }

    @objc func showCredits() {
        let creditsVC = CreditsViewController()
        creditsVC.modalPresentationStyle = .fullScreen
        present(creditsVC, animated: true, completion: nil)
    }
}

