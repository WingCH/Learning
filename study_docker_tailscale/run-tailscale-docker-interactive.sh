#!/bin/bash

# 啟動 Tailscale Docker container，使用互動式登入（Google Sign-In）
# 啟動後會顯示一個登入網址，請複製到本機瀏覽器登入

SOCKS5_PORT=1055

docker run --name tailscale \
  --rm -it \
  --cap-add=NET_ADMIN \
  -e TS_EXTRA_ARGS="--socks5-server=0.0.0.0:$SOCKS5_PORT" \
  -p $SOCKS5_PORT:$SOCKS5_PORT \
  tailscale/tailscale \
  tailscaled

# 另開一個 terminal，執行以下指令進行登入（只需第一次）：
# docker exec -it tailscale tailscale up --authkey=interactive
# 或
# docker exec -it tailscale tailscale up

# 登入後 socks5 proxy 會在 127.0.0.1:1055
