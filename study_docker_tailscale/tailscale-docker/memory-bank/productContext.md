# 產品背景 (Product Context)

## 為什麼這個專案存在
- 在 macOS 上使用 Docker 容器運行 Tailscale，通過 VPN 安全地路由流量。

## 解決的問題
- 確保 Tailscale 設置不干擾 macOS 的原生網絡擴展。
- 在 macOS Docker Desktop 不支持 TUN/TAP 的情況下，使用用戶空間網絡來繞過限制。

## 應該如何運作
- Tailscale 在 Docker 容器內運行，使用用戶空間網絡。
- 通過 Google 登入進行認證，或生成認證密鑰用於 Tailscale 登入。
- 確保與其他 VPN 工具（如 Surge）隔離運行以防止衝突。

## 用戶體驗目標
- 為需要在 macOS 上使用 Docker 容器內安全 Tailscale VPN 設置的開發者或團隊提供解決方案。
