#!/bin/bash

# 腳本用於啟動和停止 Tailscale Docker 容器

case "$1" in
  start)
    echo "啟動 Tailscale Docker 容器..."
    docker-compose up -d
    echo "正在檢查 Tailscale 登入狀態..."
    if docker exec -it tailscale-vpn tailscale status | grep -q "Logged out"; then
      echo "Tailscale 未登入，正在設置以接受路由並生成新的 login link..."
      docker exec -it tailscale-vpn tailscale up --accept-routes=true
      echo "新的 login link 已生成，並會直接在終端中顯示。"
    else
      echo "Tailscale 已登入，無需重新認證。"
    fi
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
  relogin)
    echo "登出 Tailscale 並重新生成 login link..."
    docker exec -it tailscale-vpn tailscale logout
    echo "正在重新啟動 Tailscale 以生成新的 login link..."
    docker exec -it tailscale-vpn tailscale up --accept-routes=true
    echo "新的 login link 已生成，並會直接在終端中顯示。"
    ;;
  *)
    echo "用法: $0 {start|stop|status|relogin}"
    echo "  start  - 啟動 Tailscale Docker 容器"
    echo "  stop   - 停止 Tailscale Docker 容器"
    echo "  status - 檢查 Tailscale Docker 容器狀態"
    echo "  relogin - 登出並重新生成 Tailscale login link"
    exit 1
    ;;
esac

exit 0
