//
//  ViewController.swift
//  CyphlensSSE
//
//  Created by Cyphlens Inc on 01/08/2026.
//  Copyright (c) 2026 Cyphlens Inc. All rights reserved.
//

import UIKit
import CyphlensSSE

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private var cyphlens: Cyphlens?
    private var isListening = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var environmentLabel: UILabel!
    @IBOutlet weak var environmentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sessionIdLabel: UILabel!
    @IBOutlet weak var sessionIdTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var clearLogButton: UIButton!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        sessionIdTextField.text = "0b883083541a49d896367202ed80fc1e"

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isListening {
            stopListening()
        }
    }
    
    deinit {
        cyphlens?.stop()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // UI elements are configured in storyboard
        // Only behavioral setup is needed here
        
        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        // Actions are connected via storyboard IBActions
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        guard let sessionId = sessionIdTextField.text, !sessionId.isEmpty else {
            showAlert(title: "Error", message: "Please enter a session ID")
            return
        }
        
        startListening(sessionId: sessionId)
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        stopListening()
    }
    
    @IBAction func clearLogsTapped(_ sender: UIButton) {
        logTextView.text = "Logs cleared.\n"
        scrollToBottom()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - SDK Integration
    
    private func startListening(sessionId: String) {
        // Stop any existing connection
        cyphlens?.stop()
        
        // Get environment from segmented control
        let environment: CyphlensEnvironment = environmentSegmentedControl.selectedSegmentIndex == 0 ? .sandbox : .production
        
        // Initialize Cyphlens
        cyphlens = Cyphlens()
        cyphlens?.setEnvironment(environment)
        
        // Start listening
        cyphlens?.listen(
            sessionId: sessionId,
            onData: { [weak self] eventType, event in
                DispatchQueue.main.async {
                    self?.handleEvent(eventType: eventType, event: event)
                }
            },
            onError: { [weak self] error in
                DispatchQueue.main.async {
                    self?.handleError(error)
                }
            }
        )
        
        isListening = true
        updateUI()
        log("Started listening for session ID: \(sessionId)")
        log("Environment: \(environment == .sandbox ? "Sandbox" : "Production")")
        statusLabel.text = "Status: Connecting..."
        statusLabel.textColor = .systemOrange
    }
    
    private func stopListening() {
        cyphlens?.stop()
        cyphlens = nil
        isListening = false
        updateUI()
        log("Stopped listening")
        statusLabel.text = "Status: Disconnected"
        statusLabel.textColor = .systemGray
    }
    
    private func handleEvent(eventType: EventType, event: CyphlensEvent) {
        switch eventType {
        case .mfaSwipe:
            if let mfaEvent = event as? TwoFactorEvent {
                let status = mfaEvent.status.rawValue
                log("📱 MFA Swipe Event Received")
                log("  Session ID: \(mfaEvent.sessionId)")
                log("  Status: \(status)")
                log("  Timestamp: \(Date(timeIntervalSince1970: TimeInterval(mfaEvent.timestamp / 1000)))")
                if let expiresAt = mfaEvent.expiresAt {
                    log("  Expires At: \(Date(timeIntervalSince1970: TimeInterval(expiresAt / 1000)))")
                }
                
                switch mfaEvent.status {
                case .pending:
                    statusLabel.text = "Status: Pending Authentication"
                    statusLabel.textColor = .systemOrange
                case .success:
                    statusLabel.text = "Status: ✅ Authentication Successful!"
                    statusLabel.textColor = .systemGreen
                    log("✅ Authentication successful!")
                case .expired:
                    statusLabel.text = "Status: ⏰ Authentication Expired"
                    statusLabel.textColor = .systemRed
                    log("⏰ Authentication expired")
                }
            }
            
        case .disconnect:
            if let disconnectEvent = event as? DisconnectEvent {
                log("🔌 Disconnect Event Received")
                log("  Message: \(disconnectEvent.message)")
                statusLabel.text = "Status: Disconnected"
                statusLabel.textColor = .systemGray
                stopListening()
            }
        }
        
        scrollToBottom()
    }
    
    private func handleError(_ error: Error) {
        let errorMessage = error.localizedDescription
        log("❌ Error: \(errorMessage)")
        statusLabel.text = "Status: ❌ Error - \(errorMessage)"
        statusLabel.textColor = .systemRed
        scrollToBottom()
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        startButton.isEnabled = !isListening
        startButton.alpha = isListening ? 0.5 : 1.0
        
        stopButton.isEnabled = isListening
        stopButton.alpha = isListening ? 1.0 : 0.5
        
        sessionIdTextField.isEnabled = !isListening
        environmentSegmentedControl.isEnabled = !isListening
    }
    
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] \(message)\n"
        logTextView.text += logMessage
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        let bottom = NSRange(location: logTextView.text.count - 1, length: 1)
        logTextView.scrollRangeToVisible(bottom)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

