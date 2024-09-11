//
//  PacketTunnelProvider.swift
//  VPNExtension
//
//  Created by Wing CHAN on 11/9/2024.
//

import NetworkExtension
import OSLog

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        os_log("Starting tunnel...", log: .default, type: .info)
        
        // 設置隧道配置
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "192.168.0.47")
        networkSettings.mtu = 1500
        
        // 配置IPv4設置
        let ipv4Settings = NEIPv4Settings(addresses: ["192.168.1.2"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        networkSettings.ipv4Settings = ipv4Settings
        
        // 設置DNS
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        networkSettings.dnsSettings = dnsSettings
        
        // 設置代理服務器
        let proxySettings = NEProxySettings()
        proxySettings.httpServer = NEProxyServer(address: "192.168.0.47", port: 9090)
        proxySettings.httpsServer = NEProxyServer(address: "192.168.0.47", port: 9090)
        networkSettings.proxySettings = proxySettings
        
        // 應用網絡設置
        setTunnelNetworkSettings(networkSettings) { error in
            if let error = error {
                os_log("Failed to set tunnel network settings: %@", log: .default, type: .error, error.localizedDescription)
                completionHandler(error)
                return
            }
            
            // 開始處理數據包
            self.startHandlingPackets()
            completionHandler(nil)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log("Stopping tunnel...", log: .default, type: .info)
        // 停止處理數據包
        self.stopHandlingPackets()
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // 處理來自主應用的消息
        os_log("Received message from app", log: .default, type: .info)
        completionHandler?(nil)
    }
    
    private func startHandlingPackets() {
        // 開始處理數據包的邏輯
        os_log("Start handling packets", log: .default, type: .info)
        packetFlow.readPackets { packets, protocols in
            for packet in packets {
                // 處理每個數據包
                os_log("Received packet: %@", log: .default, type: .info, packet as NSData)
            }
        }
    }
    
    private func stopHandlingPackets() {
        // 停止處理數據包的邏輯
        os_log("Stop handling packets", log: .default, type: .info)
    }
}
