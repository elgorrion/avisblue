#!/usr/bin/env bash
# fleet-config.sh - Configure fleet settings (locale, SSH, Tailscale)
# Applied to all avisblue images

set -euo pipefail

echo "=== Applying fleet configuration ==="

# Locale configuration
# en_US.UTF-8 with C collation for consistent sorting
echo "Configuring locale..."
cat > /etc/locale.conf << 'EOF'
LANG=en_US.UTF-8
LC_COLLATE=C
LC_NUMERIC=C
LC_TIME=C
LC_MONETARY=C
LC_MEASUREMENT=C
LC_PAPER=C
LC_NAME=C
LC_ADDRESS=C
LC_TELEPHONE=C
EOF

# Ensure Tailscale is enabled (already installed in Bazzite)
echo "Enabling Tailscale..."
systemctl enable tailscaled.service || true

# SSH agent configuration for KDE (ksshaskpass integration)
echo "Configuring SSH agent..."
mkdir -p /etc/skel/.config/environment.d
cat > /etc/skel/.config/environment.d/ssh-agent.conf << 'EOF'
SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
SSH_ASKPASS=/usr/bin/ksshaskpass
SSH_ASKPASS_REQUIRE=prefer
EOF

# Wayland environment configuration
echo "Configuring Wayland environment..."
cat > /etc/skel/.config/environment.d/wayland.conf << 'EOF'
# Prefer Wayland for Qt applications (fallback to XWayland)
QT_QPA_PLATFORM=wayland;xcb

# Prefer Wayland for GTK applications (fallback to X11)
GDK_BACKEND=wayland,x11

# Enable Wayland for Firefox
MOZ_ENABLE_WAYLAND=1

# Enable Wayland for Electron apps
ELECTRON_OZONE_PLATFORM_HINT=auto
EOF

# Create ssh-agent systemd user service template
mkdir -p /etc/skel/.config/systemd/user
cat > /etc/skel/.config/systemd/user/ssh-agent.service << 'EOF'
[Unit]
Description=SSH Agent

[Service]
Type=simple
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
EOF

# Default bashrc additions for fleet
echo "Configuring default shell environment..."
cat >> /etc/skel/.bashrc << 'EOF'

# Avisblue fleet configuration
# Source additional bash configs
for f in ~/.bashrc.d/*.sh; do
    [[ -r "$f" ]] && source "$f"
done

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
EOF

# Create bashrc.d directory
mkdir -p /etc/skel/.bashrc.d

# Starship prompt hook (user installs starship via Homebrew)
cat > /etc/skel/.bashrc.d/90-starship.sh << 'EOF'
# Starship prompt (install with: brew install starship)
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi
EOF

# Direnv hook (user installs direnv via Homebrew)
cat > /etc/skel/.bashrc.d/10-direnv.sh << 'EOF'
# Direnv (install with: brew install direnv)
if command -v direnv &> /dev/null; then
    eval "$(direnv hook bash)"
fi
EOF

echo "=== Fleet configuration complete ==="
