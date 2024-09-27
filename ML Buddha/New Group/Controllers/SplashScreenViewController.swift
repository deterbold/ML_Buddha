//
//  SplashScreenViewController.swift
//  ML Buddha
//
//  Created by Miguel Sicart on 26/09/2024.
//

import UIKit

class SplashScreenViewController: UIViewController {

    // MARK: - Properties

    let imageView = UIImageView()
    let titleLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Transition after a delay of 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.transitionToInstructionViewController()
        }
    }

    // MARK: - UI Setup

    func setupUI() {
        view.backgroundColor = UIColor(red: 237/255, green: 226/255, blue: 191/255, alpha: 1.0)

        // Setup imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "MLBuddha") // Ensure this image exists in your assets
        view.addSubview(imageView)

        // Setup titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "ML BUDDHA"
        let font = UIFont(name: "Futura-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        titleLabel.font = UIFontMetrics.default.scaledFont(for: font)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        view.addSubview(titleLabel)

        // Setup activityIndicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        activityIndicator.color = .gray
        view.addSubview(activityIndicator)

        // Accessibility
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "App Logo"

        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityLabel = "ML Buddha"

        activityIndicator.isAccessibilityElement = true
        activityIndicator.accessibilityLabel = "Loading"

        

        // Add Constraints
        NSLayoutConstraint.activate([
            // ImageView Constraints
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 30),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -30),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -60),

            // Add a height constraint to imageView
            imageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.4),

            // TitleLabel Constraints
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor),

            // ActivityIndicator Constraints (Uncommented)
            activityIndicator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Transition to InstructionViewController

    func transitionToInstructionViewController() {
        let instructionVC = InstructionViewController()
        instructionVC.modalPresentationStyle = .fullScreen
        present(instructionVC, animated: true, completion: nil)
    }
}



