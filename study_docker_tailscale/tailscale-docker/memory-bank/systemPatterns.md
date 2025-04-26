# 系統模式 (System Patterns)

## 系統架構
- Tailscale 運行在 Docker 容器內，使用 `tailscale/tailscale` 映像。
- 在 macOS 上使用用戶空間網絡來模擬 VPN 功能。

## 關鍵技術決策
- 選擇用戶空間網絡而非 TUN/TAP，因為 macOS Docker Desktop 不支持 TUN/TAP。
- 使用 Google 登入進行 Tailscale 認證。

## 使用的設計模式
- 容器化設計：將 Tailscale 封裝在 Docker 容器中以實現隔離和可移植性。
- 隔離模式：確保 Tailscale 與其他網絡工具或 VPN 獨立運行。

## 組件關係
- Docker 容器負責運行 Tailscale 服務。
- Tailscale 服務通過用戶空間網絡與外部網絡進行通信。
- 本地主機可能通過 SOCKS5 代理與 Tailscale VPN 交互。

## 關鍵實現路徑
- 配置 Docker 容器以運行 Tailscale 並設置用戶空間網絡。
- 設置認證機制以允許用戶安全地登入 Tailscale 網絡。
- 可選地，配置 SOCKS5 代理以便其他工具（如 Surge）通過 Tailscale VPN 路由流量。
