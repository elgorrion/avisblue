#!/usr/bin/env bash
# dev-tools.sh - Development tools for all images
# VSCode, containers, virtualization

set -euo pipefail

echo "=== Installing dev tools ==="

# Microsoft VSCode repository with retry logic
echo "Adding VSCode repository..."
MS_KEY_URL="https://packages.microsoft.com/keys/microsoft.asc"
for attempt in 1 2 3; do
    if rpm --import "$MS_KEY_URL" 2>&1; then
        echo "Microsoft GPG key imported successfully"
        break
    fi
    echo "Attempt $attempt failed, retrying in 2s..."
    sleep 2
    if [[ $attempt -eq 3 ]]; then
        echo "ERROR: Failed to import Microsoft GPG key after 3 attempts"
        exit 1
    fi
done

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
# Note: podman-compose instead of docker-compose for pure podman setup
echo "Installing container/virtualization tools..."
dnf5 -y install \
    podman-docker \
    podman-compose \
    qemu-kvm \
    libvirt \
    virt-manager \
    virt-viewer

# Cockpit additions for fleet management
# Base cockpit packages are kept from Bazzite, add VM and ostree management
echo "Installing Cockpit extensions..."
dnf5 -y install \
    cockpit-machines \
    cockpit-ostree

# Enable libvirtd
echo "Enabling libvirtd..."
systemctl enable libvirtd.socket || true

echo "=== Dev tools complete ==="
