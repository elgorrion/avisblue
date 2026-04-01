#!/usr/bin/env bash
# gaming.sh - Gaming extras for NVIDIA gaming image
# OpenRGB only - Flatpaks (ProtonUp-Qt, ScopeBuddy) installed post-boot via fleet-packages

set -euo pipefail

echo "=== Installing gaming extras ==="

# Note: Steam, Gamescope, MangoHud, vkBasalt already in Bazzite-NVIDIA

# Install OpenRGB (available in Fedora repos since F43)
echo "Installing OpenRGB..."
dnf5 -y install \
    openrgb \
    openrgb-udev-rules

# Create openrgb group for i2c access via sysusers.d (bootc-compatible)
echo 'g openrgb - -' > /usr/lib/sysusers.d/openrgb.conf

echo "=== Gaming extras complete ==="
