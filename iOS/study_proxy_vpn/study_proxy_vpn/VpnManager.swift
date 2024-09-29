//
//  VpnManager.swift
//  study_proxy_vpn
//
//  Created by Wing on 29/9/2024.
//

import NetworkExtension

class VpnManager {
    static let shared = VpnManager()
    
    private init() {}
    
    // MARK: - VPN Status
    
    /// Get the current VPN connection status
    /// - Parameter completion: Closure with the current status or nil if unable to retrieve
    func getVPNStatus(completion: @escaping (NEVPNStatus?) -> Void) {
        loadProviderManager { manager in
            guard let manager = manager else {
                completion(nil)
                return
            }
            completion(manager.connection.status)
        }
    }
    
    // MARK: - Preferences Management
    
    /// Load the VPN provider manager
    /// - Parameter complete: Closure with the loaded manager or nil if not found
    func loadProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                print("Error loading VPN configuration: \(error.localizedDescription)")
                complete(nil)
                return
            }
            
            if let managers = managers, !managers.isEmpty {
                complete(managers[0])
            } else {
                print("No VPN configurations found")
                self.createAndSaveProviderManager(complete)
            }
        }
    }
    
    /// Remove all VPN preferences
    /// - Parameter completion: Closure called when the operation is complete
    func removeAllPreferences(completion: @escaping (Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let managers = managers else {
                completion(nil)
                return
            }
            
            let group = DispatchGroup()
            var removeError: Error?
            
            for manager in managers {
                group.enter()
                manager.removeFromPreferences { error in
                    if let error = error {
                        removeError = error
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(removeError)
            }
        }
    }
    
    /// Create and save a new VPN provider manager
    /// - Parameter complete: Closure with the newly created manager or nil if failed
    private func createAndSaveProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void) {
        let manager = NETunnelProviderManager()
        let proto = NETunnelProviderProtocol()
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
    
    // MARK: - VPN Control
    
    /// Start the VPN connection
    /// - Parameter complete: Optional closure called when the operation is complete
    func startVPN(_ complete: ((NETunnelProviderManager?, Error?) -> Void)? = nil) {
        loadProviderManager { manager in
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
    
    /// Stop the VPN connection
    func stopVPN() {
        loadProviderManager { manager in
            guard let manager = manager else {
                return
            }
            manager.connection.stopVPNTunnel()
        }
    }
    
    // MARK: - List Preferences
    
    /// List all VPN preferences
    /// - Parameter completion: Closure with an array of VPN configurations or nil if unable to retrieve
    func listAllPreferences(completion: @escaping ([NETunnelProviderManager]?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                print("Error loading VPN configurations: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(managers)
        }
    }
}
