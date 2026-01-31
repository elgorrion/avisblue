#!/usr/bin/env bash
# dev.sh - Development role packages
# Adds VSCode, container support, virtualization

set -euo pipefail

echo "=== Installing dev role packages ==="

# Add Microsoft VSCode repository
echo "Adding Microsoft VSCode repository..."
rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat > /etc/yum.repos.d/vscode.repo << 'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Install VSCode
echo "Installing VSCode..."
dnf5 -y install code

# Install container and virtualization tools
echo "Installing container/virtualization tools..."
dnf5 -y install \
    podman-docker \
    docker-compose \
    qemu-kvm \
    libvirt \
    virt-manager \
    virt-viewer

# Enable libvirtd
echo "Enabling libvirtd..."
systemctl enable libvirtd.socket || true

# Note: Claude Code is installed by user via:
# curl -fsSL https://claude.ai/install.sh | sh

echo "=== Dev role complete ==="
