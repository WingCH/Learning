# 進度 (Progress)

## 目前運作的功能
- 已創建 Docker 配置文件（docker-compose.yml）和腳本（run-tailscale.sh），用於運行 Tailscale 容器。
- 已設置環境文件（.env），用於 Tailscale 認證設置。
- 已創建 README.md 文件，提供專案說明和使用指南。
- Tailscale Docker 容器已成功啟動，正在運行並映射端口 1080。
- Tailscale 認證流程已完成，使用 Google 登入，容器已連接至 Tailscale 網絡。
- SOCKS5 代理已設置在端口 1080 上，允許通過 Tailscale VPN 路由流量。
- 測試了網絡連通性，確認可以通過 Tailscale VPN 訪問內部資源（如 gitlab.service-hub.tech）。

## 尚待建置的功能
- 可選地，解決健康檢查警告「Some peers are advertising routes but --accept-routes is false」，此警告不影響基本功能。

## 當前狀態
- 專案已成功完成，包括記憶庫文件的更新、Docker 配置文件的創建以及網絡連通性的測試。Tailscale VPN 功能正常運作，用戶可以通過 SOCKS5 代理 `localhost:1080` 連接到 Tailscale 網絡。

## 已知問題
- 健康檢查警告「Some peers are advertising routes but --accept-routes is false」尚未解決，但不影響 Tailscale VPN 的基本功能。

## 專案決策的演變
- 決定使用 `tailscale/tailscale` Docker 映像。
- 決定使用用戶空間網絡來解決 macOS Docker Desktop 的 TUN/TAP 限制。
- 決定創建腳本和環境文件以簡化 Tailscale 容器的管理和認證。
- 決定將 SOCKS5 伺服器設置直接添加到 command 參數中，以確保代理正常運行。
