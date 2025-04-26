# 技術背景 (Tech Context)

## 使用的技術
- Docker：用於容器化 Tailscale 服務。
- Tailscale：VPN 服務，提供安全的網絡路由。
- 用戶空間網絡：在 macOS 上模擬 VPN 功能。

## 開發設置
- macOS 環境，安裝了 Docker Desktop。
- 使用 `tailscale/tailscale` Docker 映像運行 Tailscale 容器。

## 技術限制
- macOS Docker Desktop 不支持 TUN/TAP 設備，因此必須使用用戶空間網絡。
- 需要確保 Tailscale 與其他 VPN 工具隔離運行以避免衝突。

## 依賴項
- Docker Desktop：用於在 macOS 上運行 Docker 容器。
- `tailscale/tailscale` Docker 映像：Tailscale 服務的官方映像。

## 工具使用模式
- 使用 Docker CLI 或 Docker Desktop 管理容器。
- Tailscale 認證通過 Google 登入完成，需查看容器日誌獲取登入 URL。
