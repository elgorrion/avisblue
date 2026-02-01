#!/usr/bin/env bash
# dev-tools.sh - Development tools for all images
# VSCode, containers, virtualization

set -euo pipefail

echo "=== Installing dev tools ==="

# Microsoft VSCode repository
echo "Adding VSCode repository..."
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

# Container and virtualization tools
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

echo "=== Dev tools complete ==="
