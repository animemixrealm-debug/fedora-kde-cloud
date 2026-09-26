#!/bin/bash

echo "[*] Initializing Fedora KDE Desktop..."

# Clean up stale locks
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true
pkill -f Xvnc 2>/dev/null || true
pkill -f websockify 2>/dev/null || true

# Start Xvnc directly on display :1 (port 5901)
echo "[*] Starting Xvnc on :1..."
Xvnc :1 -geometry 1920x1080 -depth 24 -SecurityTypes None -rfbport 5901 > /tmp/xvnc.log 2>&1 &

sleep 2

# Export display and start KDE Plasma with DBus session
export DISPLAY=:1
export XDG_CURRENT_DESKTOP=KDE
export XDG_SESSION_TYPE=x11
export DESKTOP_SESSION=plasma

echo "[*] Starting KDE Plasma desktop..."
dbus-launch --exit-with-session /usr/bin/startplasma-x11 > /tmp/plasma.log 2>&1 &

# Start websockify directly on 0.0.0.0:6080 bridging to 127.0.0.1:5901
echo "[*] Starting websockify / noVNC web bridge on 0.0.0.0:6080..."
nohup python3 -m websockify --web /opt/novnc 0.0.0.0:6080 127.0.0.1:5901 > /tmp/websockify.log 2>&1 &

echo "[✓] Fedora KDE Desktop is ready on port 6080!"
