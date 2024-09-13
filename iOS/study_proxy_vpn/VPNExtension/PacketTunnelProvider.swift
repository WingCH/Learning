//
//  PacketTunnelProvider.swift
//  VPNExtension
//
//  Created by Wing CHAN on 11/9/2024.
//


import NetworkExtension
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        os_log("Starting tunnel...", log: .default, type: .info)
        
        // Set up tunnel configuration
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "192.168.0.47")
        networkSettings.mtu = 1500
        
        // Configure IPv4 settings
        let ipv4Settings = NEIPv4Settings(addresses: ["192.168.1.2"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        networkSettings.ipv4Settings = ipv4Settings
        
        // Set up DNS, both can work
//        let dnsSettings = NEDNSSettings(servers: ["192.168.0.1"])
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        networkSettings.dnsSettings = dnsSettings
        
        // Set up proxy server
        let proxySettings = NEProxySettings()
        proxySettings.httpEnabled = true
        proxySettings.httpServer = NEProxyServer(address: "192.168.0.47", port: 9090)
        proxySettings.httpsEnabled = true
        proxySettings.httpsServer = NEProxyServer(address: "192.168.0.47", port: 9090)
        proxySettings.excludeSimpleHostnames = true
        proxySettings.matchDomains = [""]
        networkSettings.proxySettings = proxySettings
        
        // Apply network settings
        setTunnelNetworkSettings(networkSettings) { error in
            if let error = error {
                os_log("Failed to set tunnel network settings: %@", log: .default, type: .error, error.localizedDescription)
                completionHandler(error)
                return
            }
            
            // Start handling packets
//            self.startHandlingPackets()
            completionHandler(nil)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log("Stopping tunnel...", log: .default, type: .info)
        self.stopHandlingPackets()
        completionHandler()
    }
    
    private func startHandlingPackets() {
        os_log("Start handling packets", log: .default, type: .info)
        packetFlow.readPackets { packets, protocols in
            for packet in packets {
                os_log("Received packet: %@", log: .default, type: .debug, packet as NSData)
                // Process packets here
            }
        }
    }
    
    private func stopHandlingPackets() {
        os_log("Stop handling packets", log: .default, type: .info)
        // Clean up resources here
    }
}
