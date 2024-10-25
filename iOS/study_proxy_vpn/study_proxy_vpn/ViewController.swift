//
//  ViewController.swift
//  study_proxy_vpn
//
//  Created by Wing CHAN on 11/9/2024.
//

import NetworkExtension
import UIKit

class ViewController: UIViewController {
    private let resultTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupResultTextView()
        setupButtons()
    }

    func setupResultTextView() {
        view.addSubview(resultTextView)
        NSLayoutConstraint.activate([
            resultTextView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            resultTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
        ])
    }

    func setupButtons() {
        let buttonTitles = [
            "Get Status", "Start VPN", "Stop VPN", "List Preferences", "Remove All Preferences",
            "Clear Results",
        ]
        let buttonActions = [
            #selector(getStatus), #selector(startVPN), #selector(stopVPN),
            #selector(listPreferences), #selector(removeAllPreferences),
            #selector(clearResults),
        ]

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: resultTextView.bottomAnchor, constant: 20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])

        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: buttonActions[index], for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    func appendResult(_ text: String) {
        DispatchQueue.main.async {
            self.resultTextView.text += text + "\n"
            let bottom = NSMakeRange(self.resultTextView.text.count - 1, 1)
            self.resultTextView.scrollRangeToVisible(bottom)
        }
    }

    @objc func getStatus() {
        VpnManager.shared.getVPNStatus { status in
            if let status = status {
                self.appendResult("Current VPN status: \(status)")
                self.appendResult("Status description:")
                switch status {
                case .invalid:
                    self.appendResult("Invalid: The VPN is not configured.")
                case .disconnected:
                    self.appendResult("Disconnected: The VPN is disconnected.")
                case .connecting:
                    self.appendResult("Connecting: The VPN is connecting.")
                case .connected:
                    self.appendResult("Connected: The VPN is connected.")
                case .reasserting:
                    self.appendResult(
                        "Reasserting: The VPN is reconnecting following loss of underlying network connectivity."
                    )
                case .disconnecting:
                    self.appendResult("Disconnecting: The VPN is disconnecting.")
                @unknown default:
                    self.appendResult("Unknown status")
                }
            } else {
                self.appendResult("Unable to retrieve VPN status")
            }
        }
    }

    @objc func startVPN() {
        VpnManager.shared.startVPN { _, error in
            if let error = error {
                self.appendResult("Error starting VPN: \(error.localizedDescription)")
            } else {
                self.appendResult("VPN started successfully")
            }
        }
    }

    @objc func stopVPN() {
        VpnManager.shared.stopVPN()
        self.appendResult("VPN stopped")
    }

    @objc func listPreferences() {
        VpnManager.shared.listAllPreferences { managers in
            if let managers = managers {
                self.appendResult("Found \(managers.count) VPN configurations")
                for (index, manager) in managers.enumerated() {
                    self.appendResult(
                        "Configuration \(index + 1): \(manager.localizedDescription ?? "Unnamed")")
                }
            } else {
                self.appendResult("Unable to retrieve VPN configurations")
            }
        }
    }

    @objc func removeAllPreferences() {
        VpnManager.shared.removeAllPreferences { error in
            if let error = error {
                self.appendResult(
                    "Error removing VPN configurations: \(error.localizedDescription)")
            } else {
                self.appendResult("All VPN configurations removed successfully")
            }
        }
    }

    @objc func clearResults() {
        DispatchQueue.main.async {
            self.resultTextView.text = ""
        }
    }
}
