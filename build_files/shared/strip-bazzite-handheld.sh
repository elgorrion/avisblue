#!/usr/bin/env bash
# strip-bazzite-handheld.sh - Remove handheld/HTPC packages from Bazzite
# Used for avisblue-nvidia-gaming (keeps gaming, removes handheld)

set -euo pipefail

echo "=== Stripping Bazzite handheld/HTPC packages ==="

# Handheld/HTPC packages (not needed for desktop gaming)
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
)

# ROCm packages (not needed on NVIDIA, dev role adds CUDA instead)
ROCM_PACKAGES=(
    rocm-hip
    rocm-opencl
    rocm-clinfo
    rocm-smi
)

echo "Removing handheld/HTPC packages..."
dnf5 -y remove ${HANDHELD_PACKAGES[@]} || true

echo "Removing optional packages..."
dnf5 -y remove ${OPTIONAL_PACKAGES[@]} || true

echo "Removing ROCm packages (NVIDIA uses CUDA)..."
dnf5 -y remove ${ROCM_PACKAGES[@]} || true

echo "=== Handheld stripping complete ==="
