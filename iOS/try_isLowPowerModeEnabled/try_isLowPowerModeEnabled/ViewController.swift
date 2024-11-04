//
//  ViewController.swift
//  try_isLowPowerModeEnabled
//
//  Created by Wing CHAN on 25/10/2024.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Create a CurrentValueSubject to track low power mode status
    private let lowPowerModeSubject = CurrentValueSubject<Bool, Never>(ProcessInfo.processInfo.isLowPowerModeEnabled)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLowPowerModeObserver()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupLowPowerModeObserver() {
        // Use Combine to listen for power state change notifications
        NotificationCenter.default
            .publisher(for: Notification.Name.NSProcessInfoPowerStateDidChange)
            .map { _ in ProcessInfo.processInfo.isLowPowerModeEnabled }
            .sink { [weak self] isLowPower in
                self?.lowPowerModeSubject.send(isLowPower)
            }
            .store(in: &cancellables)
        
        // Subscribe to changes in low power mode status
        lowPowerModeSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLowPower in
                self?.updateUI(isLowPower: isLowPower)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(isLowPower: Bool) {
        let status = isLowPower ? "Low Power Mode is ON" : "Low Power Mode is OFF"
        let tips = isLowPower ? "The system is conserving energy" : "The system is running normally"
        
        // Add animation effect
        UIView.transition(with: statusLabel,
                        duration: 0.3,
                        options: .transitionCrossDissolve) {
            self.statusLabel.text = "\(status)\n\(tips)"
        }
        
        // Change background color based on mode
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = isLowPower ? .systemGray6 : .systemBackground
        }
    }
}
