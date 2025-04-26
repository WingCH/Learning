# Tailscale Docker 設置

這個專案旨在在 macOS 上使用 Docker 容器運行 Tailscale，通過 VPN 安全地路由流量，確保不干擾 macOS 的原生網絡擴展。

## 快速入門

### 前提條件
- 安裝了 Docker Desktop 的 macOS 環境。
- Tailscale 帳戶（用於 Google 登入）。

### 設置步驟
1. **啟動 Tailscale 容器**：
   使用提供的腳本啟動容器：
   ```
   ./run-tailscale.sh start
   ```

2. **完成 Google 登入**：
   容器啟動後，查看容器日誌以獲取 Tailscale 登入 URL：
   ```
   docker logs tailscale-vpn
   ```
   在瀏覽器中打開該 URL，使用您的 Google 帳戶完成 Tailscale 登入流程。

3. **檢查容器狀態**：
   確認容器是否正在運行：
   ```
   ./run-tailscale.sh status
   ```

4. **連接至 Tailscale VPN**：
   Tailscale 容器啟動並完成認證後，您可以通過 SOCKS5 代理 `localhost:1080` 連接到 Tailscale VPN。配置您的網絡工具（如 Surge）使用此代理。

5. **停止 Tailscale 容器**：
   當您不再需要 Tailscale VPN 時，可以停止容器：
   ```
   ./run-tailscale.sh stop
   ```

## 注意事項
- 由於 macOS Docker Desktop 不支持 TUN/TAP 設備，這個設置使用用戶空間網絡來模擬 VPN 功能。
- 確保 Tailscale 容器與其他 VPN 工具隔離運行，以避免衝突。

## 調試網絡連通性
如果您需要測試 Tailscale VPN 的網絡連通性，可以使用以下命令來 ping 特定的域名：
```
cd tailscale-docker && docker exec -it tailscale-vpn ping -c 4 xxx.com
```
將 `xxx.com` 替換為您想要測試的域名。這將幫助您確認是否可以通過 Tailscale VPN 訪問內部資源。

## 記憶庫文件
專案的詳細背景和進度記錄在 `memory-bank` 目錄下的文件中：
- `projectBrief.md` - 專案概述和核心功能。
- `productContext.md` - 專案背景和用戶體驗目標。
- `activeContext.md` - 當前工作焦點和下一步計劃。
- `systemPatterns.md` - 系統架構和技術決策。
- `techContext.md` - 使用的技術棧和開發設置。
- `progress.md` - 專案進度和已知問題。
