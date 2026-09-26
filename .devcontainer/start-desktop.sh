#!/bin/bash
set -e

echo "[*] Launching Fedora KDE Plasma Desktop..."

# Clean up stale locks if any
vncserver -kill :1 2>/dev/null || true
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

# Start TigerVNC server on display :1 (port 5901)
vncserver :1 -geometry 1920x1080 -depth 24

# Kill any existing novnc proxy
pkill -f novnc_proxy 2>/dev/null || true

# Start noVNC proxy in background forwarding 6080 -> 5901
nohup /opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 > /tmp/novnc.log 2>&1 &

echo "[✓] Fedora KDE Desktop is ready on port 6080!"
