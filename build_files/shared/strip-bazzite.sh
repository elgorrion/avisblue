#!/usr/bin/env bash
# strip-bazzite.sh - Remove gaming and handheld packages from Bazzite base
# Used for avisblue-main (non-gaming images)

set -euo pipefail

echo "=== Stripping Bazzite gaming/handheld packages ==="

# Gaming packages to remove (will be re-added in gaming role)
GAMING_PACKAGES=(
    steam
    lutris
    gamescope
    gamescope-shaders
    mangohud
    vkBasalt
    umu-launcher
    winetricks
    faugus-launcher
    gamemode
)

# Handheld/HTPC packages (not needed for desktop)
HANDHELD_PACKAGES=(
    hhd
    hhd-ui
    adjustor
    steam-patch
    jupiter-fan-control
    jupiter-hw-support
    steamdeck-dsp
    steamdeck-kde-presets
    sdgyrodsu
    decky-loader
)

# Optional packages to remove
OPTIONAL_PACKAGES=(
    waydroid
    sunshine
    input-remapper
)

# ROCm packages (re-added in dev role if needed)
ROCM_PACKAGES=(
    rocm-hip
    rocm-opencl
    rocm-clinfo
    rocm-smi
)

# 32-bit libs (re-added in gaming role)
LIB32_PACKAGES=(
    "*.i686"
)

echo "Removing gaming packages..."
dnf5 -y remove ${GAMING_PACKAGES[@]} || true

echo "Removing handheld/HTPC packages..."
dnf5 -y remove ${HANDHELD_PACKAGES[@]} || true

echo "Removing optional packages..."
dnf5 -y remove ${OPTIONAL_PACKAGES[@]} || true

echo "Removing ROCm packages..."
dnf5 -y remove ${ROCM_PACKAGES[@]} || true

echo "Removing 32-bit libraries..."
dnf5 -y remove ${LIB32_PACKAGES[@]} || true

echo "=== Bazzite stripping complete ==="
