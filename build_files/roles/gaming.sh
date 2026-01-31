#!/usr/bin/env bash
# gaming.sh - Gaming role packages
# Adds OpenRGB and any gaming extras not in base Bazzite

set -euo pipefail

echo "=== Installing gaming role packages ==="

# Note: Steam, Lutris, Gamescope, MangoHud, etc. are already in Bazzite-NVIDIA
# This script adds extras like OpenRGB

# Enable OpenRGB COPR (if not already enabled by Bazzite)
echo "Enabling OpenRGB repository..."
dnf5 -y copr enable kylegospo/openrgb || true

# Install OpenRGB
echo "Installing OpenRGB..."
dnf5 -y install \
    openrgb \
    openrgb-udev-rules

# Ensure user can access i2c for OpenRGB
# Create openrgb group if not exists
getent group openrgb || groupadd openrgb

# Note: ProtonUp-Qt is installed by purge-gtk.sh (replaces Bazzite's ProtonPlus)

echo "=== Gaming role complete ==="
