#!/usr/bin/env bash
# 85-branding.sh — runtime branding mutations that COPY can't do.
#
# Asset files (logos, themes, wallpapers, fastfetch ASCII, motd, issue) ship
# via system_files/ at COPY time. This script handles the operations that
# need RPM-level or runtime intervention:
#
#   1. dnf5 swap fedora-logos -> generic-logos (Aurora pattern, BRANDING.md
#      §5). Satisfies RPM dependency graph, then erase --nodeps --nodb removes
#      the generic-logos files from disk while keeping the DB happy.
#
#   2. Restore-from-stash. The dnf swap REMOVES any file at a path
#      fedora-logos tracks (Plymouth watermark + fedora-logo-{,-small,_med}.png
#      + system-logo-white.png + start-here.svg), even if COPY replaced them
#      earlier. We re-deploy those exact paths from /usr/share/avisblue/
#      branding-stash/ which the swap can't touch.
#
#   3. NVIDIA variant differentiation: kcm-about-distrorc ships with
#      Variant=Main; the NVIDIA image needs Variant=NVIDIA Gaming.
#
#   4. dracut --regenerate-all -f --no-hostonly. Bakes the new Plymouth
#      watermark into the image's initramfs so early-boot Plymouth doesn't
#      show stale Bazzite art. --no-hostonly because we ship a generic image,
#      not a build-host-specific one.

set -euo pipefail

echo "=== 85-branding: applying runtime branding mutations ==="

# 1. fedora-logos -> generic-logos swap
echo "Swapping fedora-logos for generic-logos..."
dnf5 -y swap fedora-logos generic-logos
rpm --erase --nodeps --nodb generic-logos

# 2. Restore branded files at the paths the swap (or earlier cleanup-main) clobbered
echo "Restoring branded files from /usr/share/avisblue/branding-stash/ ..."
STASH=/usr/share/avisblue/branding-stash
# /etc/xdg/kdeglobals is owned by steamdeck-kde-presets-desktop on the
# bazzite:stable base; cleanup-main removes that package and the file with it.
# nvidia-gaming keeps the package, so the restore is a no-op on that variant.
for rel in \
    usr/share/plymouth/themes/spinner/watermark.png \
    usr/share/pixmaps/fedora-logo.png \
    usr/share/pixmaps/fedora-logo-small.png \
    usr/share/pixmaps/fedora_logo_med.png \
    usr/share/pixmaps/system-logo-white.png \
    usr/share/icons/hicolor/scalable/apps/start-here.svg \
    etc/xdg/kdeglobals
do
    src="$STASH/$rel"
    dst="/$rel"
    if [[ ! -f "$src" ]]; then
        echo "ERROR: stash missing $src — generator out of sync"
        exit 1
    fi
    install -D -m 0644 "$src" "$dst"
done

# 3. NVIDIA variant differentiation
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

# 4. Regenerate initramfs so early-boot Plymouth picks up our watermark.
#    --no-hostonly: bake a generic initramfs (not tied to build-container
#    hardware). --regenerate-all -f: rebuild for every installed kernel.
echo "Regenerating initramfs (dracut --regenerate-all -f --no-hostonly)..."
dracut --regenerate-all -f --no-hostonly

echo "=== 85-branding complete ==="
