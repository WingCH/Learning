# Tailscale Docker on macOS 失敗經驗記錄

## 目標

- 希望在 macOS 上用 Docker 跑 Tailscale，避免與 Surge（VPN/Network Extension）衝突。
- 設想用 Tailscale Docker container 提供 socks5 proxy，讓 Surge 指定 domain 流量走 Tailscale。

## 嘗試步驟

1. 下載並準備 tailscale/tailscale 官方 Docker image。
2. 編寫啟動腳本，設置 socks5 proxy，並規劃用互動式登入（Google Sign-In）。
3. 啟動 container，嘗試登入。

## 遇到的問題

- 啟動 tailscale/tailscale container 時，tailscaled 報錯：
  ```
  wgengine.NewUserspaceEngine(tun "tailscale0") error: tstun.New("tailscale0"): CreateTUN("tailscale0") failed; /dev/net/tun does not exist
  ```
- 查證後發現，macOS 上的 Docker Desktop 不支援 TUN/TAP 裝置，container 內無法建立 /dev/net/tun。
- 即使加上 `--cap-add=NET_ADMIN` 也無效，tailscaled 無法啟動。

## 原因分析

- Tailscale 需要 TUN/TAP 虛擬網卡來建立 VPN 隧道。
- macOS Docker Desktop 基於 HyperKit 虛擬化，安全性考量下不允許 container 直接操作 TUN/TAP。
- 這是 macOS Docker 的已知限制，僅 Linux Docker 支援。

## 替代方案

- 在 Linux VM（如 UTM、Parallels、VirtualBox）內跑 tailscale/tailscale Docker，或直接在 VM 裝 Tailscale。
- VM 內設 socks5 proxy，macOS 本機流量導向 VM。
- macOS 本機無法用 Docker 跑出完整 Tailscale 節點。

## 結論

- macOS Docker Desktop 不支援 TUN/TAP，tailscale/tailscale image 無法正常運作。
- 若需隔離 Tailscale 與 Surge，建議改用 Linux VM 方案。

---
**經驗教訓**：遇到 VPN/TUN 需求時，需先確認目標平台對虛擬網卡的支援度，macOS Docker Desktop 有明顯限制，Linux 環境較彈性。
