//
//  ViewController.swift
//  study_network_extension
//
//  Created by Wing on 9/9/2023.
//

import NetworkExtension
import UIKit

class ViewController: UIViewController {
    var providerManager: NETunnelProviderManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVPN()

        // 1. Create UIButton
        let startVPNButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        startVPNButton.backgroundColor = .blue
        startVPNButton.setTitle("Start VPN", for: .normal)

        // 2. Bind the action
        startVPNButton.addTarget(self, action: #selector(startVPN), for: .touchUpInside)

        // Add the button to the view
        self.view.addSubview(startVPNButton)
    }

    @objc func startVPN() {
        // 3. Start the VPN tunnel
        do {
            try self.providerManager?.connection.startVPNTunnel()
        } catch let error as NEVPNError {
            if error.code == NEVPNError.configurationInvalid {
                //FIXME: always error
                print("Invalid configuration")
            } else if error.code == NEVPNError.configurationReadWriteFailed {
                print("Read/write to configuration failed")
            } else {
                print("Other error: \(error)")
            }
        } catch {
            print("Unexpected error: \(error)")
        }

    }

    func setupVPN() {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            guard error == nil else {
                // Handle an occurred error
                print("loadAllFromPreferences error: \(error)")
                return
            }

            self.providerManager = managers?.first ?? NETunnelProviderManager()
            self.providerManager?.loadFromPreferences(completionHandler: { error in
                guard error == nil else {
                    // Handle an occurred error
                    return
                }

                let tunnelProtocol = NETunnelProviderProtocol()
                tunnelProtocol.providerBundleIdentifier = "com.wingch.study-network-extension.MyNetworkExtension"
                tunnelProtocol.serverAddress = "127.0.0.1"
//                tunnelProtocol.providerConfiguration = [
//                    "serverPort": 9090
//                ]
//                tunnelProtocol.disconnectOnSleep = false
                
                let proxySettings = NEProxySettings()
                proxySettings.httpServer = .init(address: "192.168.1.246", port: 9090)
                tunnelProtocol.proxySettings = proxySettings

                self.providerManager?.protocolConfiguration = tunnelProtocol
                self.providerManager?.localizedDescription = "XXXXXX"

                self.providerManager?.isEnabled = true

                // Save configuration in the Network Extension preferences
                self.providerManager?.saveToPreferences(completionHandler: { error in
                    if let error = error {
                        // Handle an occurred error
                        print("saveToPreferences error: \(error)")
                    } else {
                        print("saveToPreferences success")
                    }
                })
            })
        }
    }
}
