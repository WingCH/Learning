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
        // 添加一個按鈕來切換VPN
        let vpnButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        vpnButton.setTitle("Toggle VPN", for: .normal)
        vpnButton.setTitleColor(.blue, for: .normal)
        vpnButton.addTarget(self, action: #selector(toggleVPN), for: .touchUpInside)
        view.addSubview(vpnButton)
    }

    @objc func toggleVPN() {
        Manager.shared.loadProviderManager { (manager) in
            guard let manager = manager else {
                print("無法加載 VPN 配置")
                return
            }
            
            if manager.connection.status == .disconnected {
                // VPN 未連接，嘗試啟動
                do {
                    try Manager.shared.startVPN { (manager, error) in
                        if let error = error {
                            print("啟動 VPN 時發生錯誤：\(error.localizedDescription)")
                        } else {
                            print("VPN 已成功啟動")
                        }
                    }
                } catch {
                    print("啟動 VPN 時發生錯誤：\(error.localizedDescription)")
                }
            } else {
                // VPN 已連接，嘗試停止
                Manager.shared.stopVPN()
                print("VPN 已停止")
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
                print("加載 VPN 配置時出錯：\(error.localizedDescription)")
            }
            if let managers = managers {
                print("找到 \(managers.count) 個 VPN 配置")
                if managers.count > 0 {
                    complete(managers[0])
                } else {
                    print("沒有找到 VPN 配置")
                    self.createAndSaveProviderManager(complete)
                }
            } else {
                print("managers 為 nil")
                self.createAndSaveProviderManager(complete)
            }
        }
    }
    
    private func createAndSaveProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void) {
        let manager = NETunnelProviderManager()
        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "wingch.com.study-proxy-vpn.VPNExtension"
        proto.serverAddress = "192.168.0.47"
        manager.protocolConfiguration = proto
        manager.localizedDescription = "Your VPN"
        manager.isEnabled = true
        
        manager.saveToPreferences { error in
            if let error = error {
                print("保存 VPN 配置時出錯：\(error.localizedDescription)")
                complete(nil)
            } else {
                print("VPN 配置已成功保存")
                complete(manager)
            }
        }
    }
    
    func startVPN(_ complete: ((NETunnelProviderManager?, Error?) -> Void)? = nil) {
        loadProviderManager { (manager) in
            guard let manager = manager else {
                complete?(nil, NSError(domain: "VPNError", code: 0, userInfo: [NSLocalizedDescriptionKey: "無效的 VPN 配置"]))
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
