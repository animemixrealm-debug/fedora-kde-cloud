#!/bin/bash

echo "[*] Setting up Fedora KDE Plasma environment..."

# Clean up stale locks
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true
pkill -f Xvnc 2>/dev/null || true
pkill -f Xvfb 2>/dev/null || true
pkill -f x11vnc 2>/dev/null || true
pkill -f novnc_proxy 2>/dev/null || true
pkill -f cloudflared 2>/dev/null || true

# Start Xvnc directly on display :1 (port 5901)
if command -v Xvnc >/dev/null 2>&1; then
    echo "[*] Starting Xvnc on :1..."
    Xvnc :1 -geometry 1920x1080 -depth 24 -SecurityTypes None -rfbport 5901 > /tmp/xvnc.log 2>&1 &
elif command -v Xvfb >/dev/null 2>&1; then
    echo "[*] Starting Xvfb + x11vnc..."
    Xvfb :1 -screen 0 1920x1080x24 > /tmp/xvfb.log 2>&1 &
    sleep 1
    x11vnc -display :1 -nopw -listen 127.0.0.1 -rfbport 5901 -forever > /tmp/x11vnc.log 2>&1 &
fi

sleep 2

# Export display and start KDE Plasma with DBus session
export DISPLAY=:1
export XDG_CURRENT_DESKTOP=KDE
export XDG_SESSION_TYPE=x11
export DESKTOP_SESSION=plasma

echo "[*] Starting KDE Plasma desktop session..."
if command -v dbus-launch >/dev/null 2>&1; then
    dbus-launch --exit-with-session /usr/bin/startplasma-x11 > /tmp/plasma.log 2>&1 &
else
    /usr/bin/startplasma-x11 > /tmp/plasma.log 2>&1 &
fi

# Start noVNC proxy explicitly bound to 0.0.0.0:6080
echo "[*] Starting noVNC on 0.0.0.0:6080..."
nohup /opt/novnc/utils/novnc_proxy --vnc 127.0.0.1:5901 --listen 0.0.0.0:6080 > /tmp/novnc.log 2>&1 &

# Start Cloudflare Tunnel for direct zero-auth browser access
if [ -f /usr/local/bin/cloudflared ]; then
    echo "[*] Starting Cloudflare Tunnel..."
    nohup /usr/local/bin/cloudflared tunnel --url http://127.0.0.1:6080 > /tmp/cloudflared.log 2>&1 &
fi

echo "[✓] Fedora KDE Desktop initialization complete!"
