//
//  ManualViewController.swift
//  ML Buddha
//
//  Created by Miguel Sicart on 26/09/2024.
//

import UIKit

class ManualViewController: UIViewController {

    // MARK: - Properties

    let textView = UITextView()
    let closeButton = UIButton(type: .system)

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadManualContent()
    }

    // MARK: - UI Setup

    func setupUI() {
        view.backgroundColor = UIColor(red: 237/255, green: 226/255, blue: 191/255, alpha: 1.0)

        // Setup textView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor(red: 237/255, green: 226/255, blue: 191/255, alpha: 1.0)

        // Set internal margins (padding)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        view.addSubview(textView)

        // Setup closeButton
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        closeButton.addTarget(self, action: #selector(closeManual), for: .touchUpInside)
        view.addSubview(closeButton)

        // Add Constraints
        NSLayoutConstraint.activate([
            // textView Constraints
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            textView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -50),

            // closeButton Constraints
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    // MARK: - Load Content

    func loadManualContent() {
        if let manualURL = Bundle.main.url(forResource: "manual", withExtension: "html") {
            do {
                let htmlData = try Data(contentsOf: manualURL)
                let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ]
                let attributedString = try NSMutableAttributedString(
                    data: htmlData,
                    options: options,
                    documentAttributes: nil)

                // Set the font to Futura-Bold with desired size
                let screenHeight = UIScreen.main.bounds.height
                let calculatedFontSize = max(16, screenHeight * 0.02) // Adjust multiplier as needed
                let font = UIFont(name: "Futura-Bold", size: calculatedFontSize) ?? UIFont.boldSystemFont(ofSize: calculatedFontSize)

                // Apply font to the entire attributed string
                attributedString.beginEditing()
                attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length), options: []) { value, range, _ in
                    if let _ = value as? UIFont {
                        attributedString.addAttribute(.font, value: font, range: range)
                    }
                }
                attributedString.endEditing()

                // Set the updated attributed string to the textView
                textView.attributedText = attributedString

            } catch {
                textView.text = "Failed to load manual content."
                print("Error loading manual content: \(error)")
            }
        } else {
            textView.text = "Manual file not found."
            print("Manual file not found in bundle.")
        }
    }

    // MARK: - Actions

    @objc func closeManual() {
        dismiss(animated: true, completion: nil)
    }
}


