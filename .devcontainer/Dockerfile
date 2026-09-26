FROM fedora:40

ENV DEBIAN_FRONTEND=noninteractive

# Install minimal KDE Plasma X11, TigerVNC, Firefox, and tools
RUN dnf -y update && \
    dnf -y install \
      plasma-desktop \
      plasma-workspace-x11 \
      kwin-x11 \
      konsole \
      dolphin \
      firefox \
      tigervnc-server \
      xorg-x11-server-Xvfb \
      openssh-server \
      python3 \
      python3-pip \
      git \
      curl \
      wget \
      which \
      sudo \
      procps-ng \
      net-tools \
      dbus-x11 \
      xauth \
      tar && \
    dnf clean all

# Pre-install websockify directly into Python so it runs instantly
RUN pip3 install --no-cache-dir --break-system-packages websockify

# Install noVNC for in-browser desktop streaming
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html && \
    chmod -R 755 /opt/novnc

# Generate SSH host keys
RUN ssh-keygen -A

# Create user 'fedora' with passwordless sudo
RUN useradd -m -s /bin/bash -u 1000 fedora && \
    echo "fedora ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER fedora
ENV HOME=/home/fedora
WORKDIR /home/fedora

# Configure VNC startup for KDE Plasma
RUN mkdir -p /home/fedora/.vnc && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexport XDG_CURRENT_DESKTOP=KDE\nexport XDG_SESSION_TYPE=x11\nexport DESKTOP_SESSION=plasma\nexec /usr/bin/startplasma-x11\n' > /home/fedora/.vnc/xstartup && \
    chmod +x /home/fedora/.vnc/xstartup && \
    echo "fedora123" | vncpasswd -f > /home/fedora/.vnc/passwd && \
    chmod 600 /home/fedora/.vnc/passwd

EXPOSE 6080 5901
