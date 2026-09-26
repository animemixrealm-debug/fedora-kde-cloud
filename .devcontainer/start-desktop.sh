#!/bin/bash

echo "[*] Setting up Fedora KDE Plasma environment..."

# Start SSH daemon if installed and not running
sudo /usr/sbin/sshd 2>/dev/null || true

# Clean up stale locks if any
vncserver -kill :1 2>/dev/null || true
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

# Start TigerVNC server on display :1 (port 5901)
vncserver :1 -geometry 1920x1080 -depth 24

# Kill any existing novnc proxy or cloudflared
pkill -f novnc_proxy 2>/dev/null || true
pkill -f cloudflared 2>/dev/null || true

# Start noVNC proxy explicitly bound to 0.0.0.0:6080
nohup /opt/novnc/utils/novnc_proxy --vnc 127.0.0.1:5901 --listen 0.0.0.0:6080 > /tmp/novnc.log 2>&1 &

# Start Cloudflare Tunnel for direct zero-auth browser access
nohup /usr/local/bin/cloudflared tunnel --url http://127.0.0.1:6080 > /tmp/cloudflared.log 2>&1 &

# Extract and save Cloudflare public URL once ready
(
  sleep 4
  CF_URL=$(grep -o 'https://[-a-zA-Z0-9@:%._\+~#=]*.trycloudflare.com' /tmp/cloudflared.log | head -n 1)
  if [ -n "$CF_URL" ]; then
    echo "============================================="
    echo "Direct Public Desktop URL: $CF_URL"
    echo "============================================="
    echo "$CF_URL" > /workspaces/fedora-kde-cloud/DESKTOP_URL.txt 2>/dev/null || true
  fi
) &

echo "[✓] Fedora KDE Desktop is ready!"
