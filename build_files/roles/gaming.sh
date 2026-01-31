#!/usr/bin/env bash
# gaming.sh - Gaming extras for NVIDIA gaming image
# OpenRGB, ProtonUp-Qt, BoxBuddy

set -euo pipefail

echo "=== Installing gaming extras ==="

# Note: Steam, Gamescope, MangoHud, vkBasalt already in Bazzite-NVIDIA

# Enable OpenRGB COPR
echo "Enabling OpenRGB repository..."
dnf5 -y copr enable kylegospo/openrgb || true

# Install OpenRGB
echo "Installing OpenRGB..."
dnf5 -y install \
    openrgb \
    openrgb-udev-rules

# Create openrgb group for i2c access
getent group openrgb || groupadd openrgb

# Install Qt Flatpaks for gaming management
echo "Installing ProtonUp-Qt and BoxBuddy..."
flatpak install --system -y flathub net.davidotek.pupgui2 || true
flatpak install --system -y flathub io.github.dvlv.boxbuddyrs || true

echo "=== Gaming extras complete ==="
