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

# Install Qt Flatpaks for gaming management (only if flatpak available)
if command -v flatpak &>/dev/null && flatpak remotes 2>/dev/null | grep -q flathub; then
    echo "Installing ProtonUp-Qt..."
    if ! flatpak install --system -y flathub net.davidotek.pupgui2; then
        echo "WARNING: Failed to install ProtonUp-Qt - users can install manually via: flatpak install flathub net.davidotek.pupgui2"
    fi
    echo "Installing BoxBuddy..."
    if ! flatpak install --system -y flathub io.github.dvlv.boxbuddyrs; then
        echo "WARNING: Failed to install BoxBuddy - users can install manually via: flatpak install flathub io.github.dvlv.boxbuddyrs"
    fi
else
    echo "WARNING: Flatpak/Flathub not available, skipping Flatpak installs"
fi

echo "=== Gaming extras complete ==="
