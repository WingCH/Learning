#!/bin/bash

# 腳本用於啟動和停止 Tailscale Docker 容器

case "$1" in
  start)
    echo "啟動 Tailscale Docker 容器..."
    docker-compose up -d
    echo "正在設置 Tailscale 以接受路由..."
    docker exec -it tailscale-vpn tailscale up --accept-routes=true
    echo "Tailscale 容器已啟動。您可以通過 SOCKS5 代理 (localhost:1080) 連接到 Tailscale VPN。"
    ;;
  stop)
    echo "停止 Tailscale Docker 容器..."
    docker-compose down
    echo "Tailscale 容器已停止。"
    ;;
  status)
    echo "檢查 Tailscale Docker 容器狀態..."
    docker-compose ps
    ;;
  *)
    echo "用法: $0 {start|stop|status}"
    echo "  start  - 啟動 Tailscale Docker 容器"
    echo "  stop   - 停止 Tailscale Docker 容器"
    echo "  status - 檢查 Tailscale Docker 容器狀態"
    exit 1
    ;;
esac

exit 0
