#!/usr/bin/env bash
# 85-branding.sh — runtime branding mutations that COPY can't do.
#
# Asset files (logos, themes, wallpapers, fastfetch ASCII, motd, issue) all
# ship via system_files/ at COPY time. This script handles the two operations
# that need RPM-level or runtime intervention:
#
#   1. dnf5 swap fedora-logos -> generic-logos. Aurora pattern (BRANDING.md §5):
#      satisfies RPM dependency graph, then erase --nodeps --nodb removes the
#      generic-logos files from disk while keeping the DB happy. Our system_files/
#      pixmap overlay then wins on disk, in the standard fedora-* paths that
#      legacy consumers hardcode.
#
#   2. NVIDIA variant differentiation: kcm-about-distrorc ships with
#      Variant=Main; the NVIDIA image needs Variant=NVIDIA Gaming. Patched in
#      place, branching on $IMAGE_NAME passed from the Containerfile.

set -euo pipefail

echo "=== 85-branding: applying runtime branding mutations ==="

# 1. fedora-logos -> generic-logos swap
echo "Swapping fedora-logos for generic-logos..."
dnf5 -y swap fedora-logos generic-logos
rpm --erase --nodeps --nodb generic-logos

# 2. NVIDIA variant differentiation
case "${IMAGE_NAME:?IMAGE_NAME must be set}" in
    *nvidia-gaming)
        echo "Patching kcm-about-distrorc Variant for NVIDIA image..."
        sed -i 's|^Variant=.*|Variant=NVIDIA Gaming|' /etc/xdg/kcm-about-distrorc
        ;;
    *main)
        echo "Main variant: leaving kcm-about-distrorc Variant=Main"
        ;;
    *)
        echo "ERROR: unrecognised IMAGE_NAME=${IMAGE_NAME}; refusing to guess Variant"
        exit 1
        ;;
esac

echo "=== 85-branding complete ==="
