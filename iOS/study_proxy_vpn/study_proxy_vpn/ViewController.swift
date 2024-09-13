//
//  ViewController.swift
//  study_proxy_vpn
//
//  Created by Wing CHAN on 11/9/2024.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Add a button to toggle VPN
        let vpnButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        vpnButton.setTitle("Toggle VPN", for: .normal)
        vpnButton.setTitleColor(.blue, for: .normal)
        vpnButton.addTarget(self, action: #selector(toggleVPN), for: .touchUpInside)
        view.addSubview(vpnButton)
    }

    @objc func toggleVPN() {
        Manager.shared.loadProviderManager { (manager) in
            guard let manager = manager else {
                print("Unable to load VPN configuration")
                return
            }
            
            if manager.connection.status == .disconnected {
                // VPN is disconnected, try to start
                do {
                    try Manager.shared.startVPN { (manager, error) in
                        if let error = error {
                            print("Error starting VPN: \(error.localizedDescription)")
                        } else {
                            print("VPN started successfully")
                        }
                    }
                } catch {
                    print("Error starting VPN: \(error.localizedDescription)")
                }
            } else {
                // VPN is connected, try to stop
                Manager.shared.stopVPN()
                print("VPN stopped")
            }
        }
    }
}

class Manager {
    static let shared = Manager()
    
    private init() {}
    
    func loadProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let error = error {
                print("Error loading VPN configuration: \(error.localizedDescription)")
            }
            if let managers = managers {
                print("Found \(managers.count) VPN configurations")
                if managers.count > 0 {
                    complete(managers[0])
                } else {
                    print("No VPN configurations found")
                    self.createAndSaveProviderManager(complete)
                }
            } else {
                print("managers is nil")
                self.createAndSaveProviderManager(complete)
            }
        }
    }
    
    private func createAndSaveProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void) {
        let manager = NETunnelProviderManager()
        let proto = NETunnelProviderProtocol()
        // The following line is commented out but the code still works without it
        // proto.providerBundleIdentifier = "wingch.com.study-proxy-vpn.VPNExtension"
        proto.serverAddress = "Your VPN"
        manager.protocolConfiguration = proto
        manager.localizedDescription = "Your VPN"
        manager.isEnabled = true
        
        manager.saveToPreferences { error in
            if let error = error {
                print("Error saving VPN configuration: \(error.localizedDescription)")
                complete(nil)
            } else {
                print("VPN configuration saved successfully")
                complete(manager)
            }
        }
    }
    
    func startVPN(_ complete: ((NETunnelProviderManager?, Error?) -> Void)? = nil) {
        loadProviderManager { (manager) in
            guard let manager = manager else {
                complete?(nil, NSError(domain: "VPNError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid VPN configuration"]))
                return
            }
            do {
                try manager.connection.startVPNTunnel()
                complete?(manager, nil)
            } catch {
                complete?(nil, error)
            }
        }
    }
    
    func stopVPN() {
        loadProviderManager { (manager) -> Void in
            guard let manager = manager else {
                return
            }
            manager.connection.stopVPNTunnel()
        }
    }
}
