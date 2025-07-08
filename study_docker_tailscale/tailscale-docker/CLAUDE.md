# CLAUDE.md

此檔案為 Claude Code (claude.ai/code) 提供操作此專案的指引。

## 專案概述

這是一個在 macOS 上使用 Docker 運行 Tailscale 的設置，透過容器提供 VPN 連接並使用 SOCKS5 代理，不會干擾 macOS 原生的網路擴展。

## 核心指令

### 管理 Tailscale 容器
```bash
# 啟動 Tailscale 容器並檢查登入狀態
./run-tailscale.sh start

# 停止 Tailscale 容器
./run-tailscale.sh stop

# 檢查容器狀態
./run-tailscale.sh status

# 強制重新認證（登出並生成新的登入連結）
./run-tailscale.sh relogin
```

### 測試網路連通性
```bash
# 透過容器測試 VPN 連通性
docker exec -it tailscale-vpn ping -c 4 <domain.com>

# 查看容器內的 Tailscale 狀態
docker exec -it tailscale-vpn tailscale status

# 查看容器日誌以獲取認證 URL
docker logs tailscale-vpn
```

### Docker Compose 操作
```bash
# 啟動服務
docker-compose up -d

# 停止並移除容器
docker-compose down

# 查看運行中的容器
docker-compose ps

# 重啟服務
docker-compose restart
```

## 架構與關鍵元件

### 容器配置
- **映像檔**: `tailscale/tailscale:latest`
- **容器名稱**: `tailscale-vpn`
- **SOCKS5 代理**: 暴露在 `localhost:1080`
- **HTTP 代理**: 暴露在 `localhost:8888`
- **網路模式**: 使用者空間網路 (`TS_USERSPACE=true`)，因 macOS Docker 限制
- **權限**: 需要 `NET_ADMIN`、`NET_RAW` 能力和特權模式

### 資料持久化
- **Volume 掛載**: `./tailscale-data:/var/lib/tailscale`
- **狀態檔案**: 認證狀態、日誌和 DERP 快取儲存在 `tailscale-data/`
- **日誌檔案**: `tailscaled.log1.txt` 和 `tailscaled.log2.txt` 包含執行日誌和認證 URL

### 關鍵技術決策
1. **使用者空間網路**: macOS Docker Desktop 不支援 TUN/TAP 設備，因此使用使用者空間網路
2. **雙代理支援**: 同時提供 SOCKS5 (1080 埠) 和 HTTP (8888 埠) 代理，滿足不同應用需求
3. **隔離運作**: 設計為與其他 VPN 工具（如 Surge）分離運行以避免衝突
4. **持久狀態**: 容器狀態持久化以在重啟後保持認證

## Memory Bank 結構
`memory-bank/` 目錄包含專案文件：
- `projectBrief.md` - 核心功能和目標
- `productContext.md` - 使用者體驗目標
- `activeContext.md` - 當前工作重點
- `systemPatterns.md` - 架構決策
- `techContext.md` - 技術堆疊詳情
- `progress.md` - 開發進度追蹤

## 常見開發任務

### 除錯認證問題
1. 檢查容器日誌以獲取登入 URL：`docker logs tailscale-vpn`
2. 驗證 Tailscale 狀態：`docker exec -it tailscale-vpn tailscale status`
3. 如需要，強制重新認證：`./run-tailscale.sh relogin`

### 測試代理功能
```bash
# 測試 SOCKS5 代理連通性
curl --socks5 localhost:1080 http://example.com

# 測試 HTTP 代理連通性
curl --proxy http://localhost:8888 http://example.com

# 配置系統工具使用代理
# SOCKS5: localhost:1080
# HTTP: localhost:8888
```

### 容器問題排查
1. 檢查容器是否運行：`docker-compose ps`
2. 查看詳細日誌：`docker-compose logs -f tailscale`
3. 檢查 volume 權限：`ls -la tailscale-data/`
4. 驗證埠綁定：`docker port tailscale-vpn`