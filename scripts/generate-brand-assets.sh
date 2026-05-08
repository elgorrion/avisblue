#!/usr/bin/env bash
# generate-brand-assets.sh — regenerate rasterised brand assets from brand/*.svg.
#
# Self-contained: dispatches to a transient podman container with rsvg-convert,
# ImageMagick, libjxl-utils, and gzip preinstalled. No host-side asset tooling
# required. Run from any machine with podman.
#
# Outputs land under system_files/ and are committed to git. Idempotent.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
GEN_IMAGE="registry.fedoraproject.org/fedora:44"

if [[ "${INSIDE_GEN_CONTAINER:-}" != "1" ]]; then
    if ! command -v podman >/dev/null 2>&1; then
        echo "ERROR: podman required (or set INSIDE_GEN_CONTAINER=1 to skip dispatch)" >&2
        exit 1
    fi
    echo "==> Dispatching to transient podman container ($GEN_IMAGE)"
    # No --userns=keep-id: we need root inside the container to dnf-install
    # build deps. In rootless podman, container-root maps back to the invoking
    # user on the host, so files written under /work are owned correctly.
    exec podman run --rm \
        -v "$REPO_ROOT:/work:Z" \
        -w /work \
        -e INSIDE_GEN_CONTAINER=1 \
        "$GEN_IMAGE" \
        bash -ec '
            dnf -y install --setopt=install_weak_deps=False \
                librsvg2-tools \
                ImageMagick \
                libjxl-utils \
                gzip >/dev/null
            exec /work/scripts/generate-brand-assets.sh
        '
fi

echo "==> Generating brand assets in $REPO_ROOT"

SRC_TINTED="${REPO_ROOT}/brand/avisblue-mark.svg"
SRC_LIGHT="${REPO_ROOT}/brand/avisblue-mark-light.svg"
SRC_DARK="${REPO_ROOT}/brand/avisblue-mark-dark.svg"
SRC_ASCII="${REPO_ROOT}/brand/source/ascii-125.txt"
OUT="${REPO_ROOT}/system_files"

for src in "$SRC_TINTED" "$SRC_LIGHT" "$SRC_DARK" "$SRC_ASCII"; do
    [[ -f "$src" ]] || { echo "ERROR: missing source: $src" >&2; exit 1; }
done

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# §5 Pixmaps
mkdir -p "$OUT/usr/share/pixmaps"
cp "$SRC_TINTED" "$OUT/usr/share/pixmaps/avisblue-logo.svg"
cp "$SRC_TINTED" "$OUT/usr/share/pixmaps/fedora-logo.svg"
rsvg-convert -w 256 -h 256 "$SRC_LIGHT"  -o "$OUT/usr/share/pixmaps/system-logo-white.png"
rsvg-convert -w 256 -h 256 "$SRC_TINTED" -o "$OUT/usr/share/pixmaps/fedora-logo.png"
rsvg-convert -w 128 -h 128 "$SRC_TINTED" -o "$OUT/usr/share/pixmaps/fedora_logo_med.png"
rsvg-convert -w 48  -h 48  "$SRC_TINTED" -o "$OUT/usr/share/pixmaps/fedora-logo-icon.png"
rsvg-convert -w 32  -h 32  "$SRC_TINTED" -o "$OUT/usr/share/pixmaps/fedora-logo-small.png"

# §5 Freedesktop hicolor icons (scalable)
mkdir -p "$OUT/usr/share/icons/hicolor/scalable/apps" \
         "$OUT/usr/share/icons/hicolor/scalable/places"
cp "$SRC_TINTED" "$OUT/usr/share/icons/hicolor/scalable/apps/avisblue-logo.svg"
cp "$SRC_TINTED" "$OUT/usr/share/icons/hicolor/scalable/apps/start-here.svg"
cp "$SRC_TINTED" "$OUT/usr/share/icons/hicolor/scalable/places/distributor-logo.svg"
cp "$SRC_TINTED" "$OUT/usr/share/icons/hicolor/scalable/places/distributor-logo-symbolic.svg"

# §4 Plymouth watermark (200px wide; light variant on dark spinner BG)
mkdir -p "$OUT/usr/share/plymouth/themes/spinner"
rsvg-convert -w 200 "$SRC_LIGHT" -o "$OUT/usr/share/plymouth/themes/spinner/watermark.png"

# Stash mirror of fedora-logos-clobbered paths.
#
# `dnf5 swap fedora-logos generic-logos` (run by 85-branding.sh) removes any
# file at a path RPM tracks for fedora-logos, regardless of whether COPY
# replaced it earlier. Our COPYed files at those paths get silently deleted.
#
# Stash a mirror under /usr/share/avisblue/branding-stash/ (no RPM owns this
# path); 85-branding.sh restores from stash AFTER the swap. The stash also
# acts as ground truth if anything else ever touches /usr/share/pixmaps/ or
# /usr/share/plymouth/.
STASH="$OUT/usr/share/avisblue/branding-stash"
mkdir -p "$STASH/usr/share/plymouth/themes/spinner" \
         "$STASH/usr/share/pixmaps" \
         "$STASH/usr/share/icons/hicolor/scalable/apps"
cp "$OUT/usr/share/plymouth/themes/spinner/watermark.png" \
   "$STASH/usr/share/plymouth/themes/spinner/watermark.png"
cp "$OUT/usr/share/pixmaps/fedora-logo.png" \
   "$STASH/usr/share/pixmaps/fedora-logo.png"
cp "$OUT/usr/share/pixmaps/fedora-logo-small.png" \
   "$STASH/usr/share/pixmaps/fedora-logo-small.png"
cp "$OUT/usr/share/pixmaps/fedora_logo_med.png" \
   "$STASH/usr/share/pixmaps/fedora_logo_med.png"
cp "$OUT/usr/share/pixmaps/system-logo-white.png" \
   "$STASH/usr/share/pixmaps/system-logo-white.png"
cp "$OUT/usr/share/icons/hicolor/scalable/apps/start-here.svg" \
   "$STASH/usr/share/icons/hicolor/scalable/apps/start-here.svg"

# §7 KDE Look-and-Feel splash logo (svgz = gzipped svg)
LF_DIR="$OUT/usr/share/plasma/look-and-feel/dev.elgorrion.avisblue.desktop"
mkdir -p "$LF_DIR/contents/splash/images"
gzip -c "$SRC_LIGHT" > "$LF_DIR/contents/splash/images/avisblue_logo.svgz"

# §6 SDDM theme logo
SDDM_DIR="$OUT/usr/share/sddm/themes/01-breeze-avisblue"
mkdir -p "$SDDM_DIR"
cp "$SRC_LIGHT" "$SDDM_DIR/default-logo.svg"

# §8 Cockpit branding (favicon multi-res ICO + apple-touch + brand SVG)
COCK_DIR="$OUT/etc/cockpit/branding"
mkdir -p "$COCK_DIR"
cp "$SRC_TINTED" "$COCK_DIR/brand.svg"
rsvg-convert -w 180 -h 180 "$SRC_TINTED" -o "$COCK_DIR/apple-touch-icon.png"
rsvg-convert -w 16  -h 16  "$SRC_TINTED" -o "$TMPDIR/16.png"
rsvg-convert -w 32  -h 32  "$SRC_TINTED" -o "$TMPDIR/32.png"
rsvg-convert -w 48  -h 48  "$SRC_TINTED" -o "$TMPDIR/48.png"
magick "$TMPDIR/16.png" "$TMPDIR/32.png" "$TMPDIR/48.png" "$COCK_DIR/favicon.ico"

# §5.5 Wallpaper — single hero, deep radial gradient + mark watermark @ 18%
WALL_DIR="$OUT/usr/share/wallpapers/avisblue/contents/images"
mkdir -p "$WALL_DIR"
rsvg-convert -w 320 "$SRC_LIGHT" -o "$TMPDIR/mark-320.png"
magick -size 3840x2160 \
    radial-gradient:'#2A4A6E'-'#11243B' \
    \( "$TMPDIR/mark-320.png" -alpha set -channel A -evaluate multiply 0.18 +channel \) \
    -gravity southeast -geometry +220+220 -composite \
    "$TMPDIR/wallpaper.png"
cjxl --quality 90 --effort 7 "$TMPDIR/wallpaper.png" "$WALL_DIR/3840x2160.jxl"

# §3 Fastfetch ASCII (prepend $1 colour marker per line so fastfetch tints it)
ASCII_DIR="$OUT/usr/share/fastfetch/logos"
mkdir -p "$ASCII_DIR"
# shellcheck disable=SC2016 # $1 is a fastfetch colour-marker, NOT a shell var
sed 's|^|$1|' "$SRC_ASCII" > "$ASCII_DIR/avisblue.txt"

echo "==> Brand assets generated under $OUT"
echo "    Run: git status system_files/ brand/"
