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
#      fedora-logos tracks (fedora-logo-{,-small,_med}.png + system-logo-white.png
#      + start-here.svg), even if COPY replaced them earlier. We re-deploy
#      those exact paths from /usr/share/avisblue/branding-stash/ which the
#      swap can't touch.
#      (Plymouth assets live at /usr/share/plymouth/themes/avisblue/, an
#      uncontested path — no RPM owns it, no stash needed.)
#
#   3. NVIDIA variant differentiation: kcm-about-distrorc ships with
#      Variant=Main; the NVIDIA image needs Variant=NVIDIA Gaming.
#
#   4. dracut --regenerate-all -f --no-hostonly. Bakes the avisblue Plymouth
#      theme + plymouthd.conf (Theme=avisblue) into the image's initramfs so
#      early-boot Plymouth uses our theme — not the firmware-BGRT default
#      that Q correctly identified as still looking like Bazzite. --no-hostonly
#      because we ship a generic image, not a build-host-specific one.

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

# 4. Plymouth theme activation via the canonical Fedora tool.
#
#    `plymouth-set-default-theme avisblue` (verified against upstream
#    plymouth/scripts/plymouth-set-default-theme.in, 2026-05-09):
#      a. validates /usr/share/plymouth/themes/avisblue/avisblue.plymouth exists
#         AND that the ModuleName plugin (.so) exists on disk — fails loud if
#         either is missing (matches RULE 0 / infra-discipline "one clean path")
#      b. removes the stale /usr/share/plymouth/themes/default.plymouth symlink
#         and recreates it pointing at our theme — keeps `plymouth-set-default-
#         theme` (no-arg query) consistent with /etc/plymouth/plymouthd.conf
#      c. re-asserts `Theme=avisblue` under [Daemon] in plymouthd.conf via
#         INI mutation — preserves our other keys (ShowDelay, DeviceTimeout,
#         UseSimpledrmNoLuks) shipped in system_files/etc/plymouth/plymouthd.conf
#
#    We do NOT pass `--rebuild-initrd` here: that wrapper invokes `dracut -f`
#    with default flags, which writes to /boot/initramfs-<KVER>.img — bootc
#    ignores that path. We do the regen explicitly below at the bootc-canonical
#    /usr/lib/modules/<KVER>/initramfs.img location.
echo "Activating Plymouth avisblue theme via plymouth-set-default-theme..."
plymouth-set-default-theme avisblue

# 5. Regenerate initramfs at the bootc-canonical path
#    /usr/lib/modules/<KVER>/initramfs.img — matching ublue-os/bazzite's
#    build_files/build-initramfs script (verified upstream 2026-05-08).
#
#    Earlier (commit 1e2769a) used `dracut --regenerate-all -f --no-hostonly`,
#    which writes to /boot/initramfs-<KVER>.img (dracut default). bootc/ostree
#    deploys initramfs from /usr/lib/modules/<KVER>/initramfs.img — so the
#    /boot copy was discarded at deploy time and the deployed initramfs still
#    held Bazzite's stock plymouth (bgrt + spinner with original frames) with
#    no avisblue theme. Symptom on enviada-nb: bootscreen still showed Bazzite
#    even with plymouthd.conf Theme=avisblue and the theme dir on disk.
#
#    Flags mirror Bazzite verbatim: --no-hostonly (generic image), --reproducible
#    (deterministic bytes for ostree dedup), --zstd, --add ostree (bootc needs
#    the ostree dracut module), --add fido2 (LUKS unlock support — Bazzite
#    keeps it; harmless for non-LUKS), -f (overwrite). chmod 0600 because
#    initramfs may carry secrets in some setups.
QUALIFIED_KERNEL=$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' kernel)
echo "Regenerating initramfs at /usr/lib/modules/${QUALIFIED_KERNEL}/initramfs.img ..."
dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd \
       --add ostree --add fido2 \
       -f "/usr/lib/modules/${QUALIFIED_KERNEL}/initramfs.img"
chmod 0600 "/usr/lib/modules/${QUALIFIED_KERNEL}/initramfs.img"

# Drop any stale /boot/initramfs-* that the prior --regenerate-all path may
# have left behind. bootc reads from /usr/lib/modules/, never /boot/, so the
# /boot copy is dead weight (~242 MB).
rm -f /boot/initramfs-*.img

echo "=== 85-branding complete ==="
