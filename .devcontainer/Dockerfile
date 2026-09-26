FROM fedora:40

ENV DEBIAN_FRONTEND=noninteractive

# Install minimal KDE Plasma X11, TigerVNC, OpenSSH, Firefox, and tools
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

# Generate SSH host keys for GitHub Codespaces SSH support
RUN ssh-keygen -A

# Install cloudflared for direct zero-auth browser desktop access
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Install noVNC and websockify for in-browser desktop streaming
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone --depth 1 https://github.com/novnc/websockify.git /opt/novnc/utils/websockify && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html && \
    chmod -R 755 /opt/novnc

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

EXPOSE 6080 22
