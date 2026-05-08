#!/usr/bin/env bash
# Phase G — G1 image smoke test.
#
# Runs after `docker build-push` in CI, before the `sign` job. Pulls the
# freshly-pushed image and asserts a curated manifest of file presence +
# content. Fails the build (and therefore the sign job) if any branding /
# identity / signing-policy artifact is missing or wrong.
#
# Catches the bug class that bit us 2026-05-08:
#   * dnf swap fedora-logos -> generic-logos clobbering COPYed files
#   * stash-restore step silently failing
#   * Plymouth frame count drifting from the expected 36 recoloured frames
#   * policy.json missing the ghcr.io/elgorrion sigstore entry
#
# Two modes (single-file design so shellcheck can lint everything):
#
#   smoke-test.sh IMAGE_REF VARIANT
#       Host-side launcher: pulls IMAGE_REF, then re-execs this same script
#       inside the image with --inside.
#
#   smoke-test.sh --inside VARIANT
#       Container-internal: runs the actual checks against the live filesystem.
#       Not meant to be invoked directly; use the launcher form.
#
# Args:
#   IMAGE_REF   e.g. ghcr.io/elgorrion/avisblue-main@sha256:...
#               or  ghcr.io/elgorrion/avisblue-main:abc1234
#   VARIANT     "Main" | "NVIDIA Gaming"  (must match Variant= in
#               /etc/xdg/kcm-about-distrorc inside the image)

set -euo pipefail

run_inside() {
    local expected_variant="$1"

    # ----- Required paths -------------------------------------------------
    # Curated manifest of branding, identity, theming, signing-policy, and
    # service files. Any missing path fails the build.
    local required=(
        # Identity
        /usr/lib/os-release
        /etc/xdg/kcm-about-distrorc
        /etc/xdg/kdeglobals
        /etc/motd
        /etc/issue
        # Branding stash (must survive dnf swap fedora-logos -> generic-logos
        # AND main-variant cleanup that removes steamdeck-kde-presets-desktop)
        /usr/share/avisblue/branding-stash/usr/share/plymouth/themes/spinner/watermark.png
        /usr/share/avisblue/branding-stash/usr/share/pixmaps/fedora-logo.png
        /usr/share/avisblue/branding-stash/usr/share/pixmaps/fedora-logo-small.png
        /usr/share/avisblue/branding-stash/usr/share/pixmaps/fedora_logo_med.png
        /usr/share/avisblue/branding-stash/usr/share/pixmaps/system-logo-white.png
        /usr/share/avisblue/branding-stash/usr/share/icons/hicolor/scalable/apps/start-here.svg
        /usr/share/avisblue/branding-stash/etc/xdg/kdeglobals
        # Plymouth (recoloured)
        /usr/share/plymouth/themes/spinner/watermark.png
        /usr/share/plymouth/themes/spinner/animation-0001.png
        /usr/share/plymouth/themes/spinner/animation-0036.png
        # Pixmaps + hicolor icons
        /usr/share/pixmaps/avisblue-logo.svg
        /usr/share/pixmaps/system-logo-white.png
        /usr/share/pixmaps/fedora-logo.png
        /usr/share/icons/hicolor/scalable/apps/avisblue-logo.svg
        /usr/share/icons/hicolor/scalable/apps/start-here.svg
        # SDDM theme
        /usr/share/sddm/themes/01-breeze-avisblue/Main.qml
        /usr/share/sddm/themes/01-breeze-avisblue/metadata.desktop
        /usr/share/sddm/themes/01-breeze-avisblue/theme.conf
        /etc/sddm.conf.d/10-wayland.conf
        # KDE Look-and-Feel
        /usr/share/plasma/look-and-feel/dev.elgorrion.avisblue.desktop/metadata.json
        /usr/share/plasma/look-and-feel/dev.elgorrion.avisblue.desktop/contents/splash/Splash.qml
        /usr/share/plasma/look-and-feel/dev.elgorrion.avisblue.desktop/contents/splash/images/avisblue_logo.svgz
        # Wallpaper
        /usr/share/wallpapers/avisblue/contents/images/3840x2160.jxl
        /usr/share/wallpapers/avisblue/metadata.json
        # Fastfetch
        /usr/share/fastfetch/logos/avisblue.txt
        # Cockpit branding
        /etc/cockpit/branding/branding.css
        /etc/cockpit/branding/favicon.ico
        /etc/cockpit/branding/apple-touch-icon.png
        /etc/cockpit/branding/brand.svg
        # Signing chain
        /etc/containers/registries.d/elgorrion.yaml
        /etc/pki/containers/avisblue.pub
        # Services
        /usr/lib/systemd/system/avisblue-flatpak-manager.service
        /usr/libexec/avisblue-flatpak-manager
        /usr/lib/tmpfiles.d/avisblue-user.conf
    )

    local missing=()
    local f
    for f in "${required[@]}"; do
        [[ -e "$f" ]] || missing+=("$f")
    done
    if (( ${#missing[@]} > 0 )); then
        echo "FAIL: missing required paths:" >&2
        printf '  %s\n' "${missing[@]}" >&2
        exit 1
    fi
    echo "OK: ${#required[@]} required paths present"

    # ----- Stash-restore parity ------------------------------------------
    # 85-branding.sh runs `dnf5 swap fedora-logos generic-logos` then re-COPIES
    # the six branded files from /usr/share/avisblue/branding-stash/ on top of
    # whatever generic-logos shipped. If the cp step ever silently fails, the
    # fleet boots with generic Fedora art. cmp -s catches that bit-for-bit.
    local stash=/usr/share/avisblue/branding-stash
    local pairs=(
        /usr/share/plymouth/themes/spinner/watermark.png
        /usr/share/pixmaps/fedora-logo.png
        /usr/share/pixmaps/fedora-logo-small.png
        /usr/share/pixmaps/fedora_logo_med.png
        /usr/share/pixmaps/system-logo-white.png
        /usr/share/icons/hicolor/scalable/apps/start-here.svg
        /etc/xdg/kdeglobals
    )
    local p
    for p in "${pairs[@]}"; do
        if ! cmp -s "${stash}${p}" "$p"; then
            echo "FAIL: stash-restore mismatch: $p differs from ${stash}${p}" >&2
            exit 1
        fi
    done
    echo "OK: ${#pairs[@]} stash-restore pairs match bit-for-bit"

    # ----- Plymouth frame count -------------------------------------------
    local frames
    frames=$(find /usr/share/plymouth/themes/spinner/ -maxdepth 1 \
        -name 'animation-*.png' -type f | wc -l)
    if [[ "$frames" != "36" ]]; then
        echo "FAIL: expected 36 Plymouth spinner frames, found $frames" >&2
        exit 1
    fi
    echo "OK: 36 Plymouth spinner frames"

    # ----- Content asserts ------------------------------------------------
    grep -q '^NAME="Avisblue"' /usr/lib/os-release \
        || { echo 'FAIL: NAME="Avisblue" missing from /usr/lib/os-release' >&2; exit 1; }
    grep -qE '^CPE_NAME="cpe:/o:elgorrion:avisblue:[0-9]+"' /usr/lib/os-release \
        || { echo 'FAIL: CPE_NAME has wrong shape in /usr/lib/os-release' >&2; exit 1; }
    grep -q "^Variant=${expected_variant}\$" /etc/xdg/kcm-about-distrorc \
        || { echo "FAIL: Variant=${expected_variant} missing from /etc/xdg/kcm-about-distrorc" >&2; exit 1; }
    grep -q '^Current=01-breeze-avisblue' /etc/sddm.conf.d/10-wayland.conf \
        || { echo 'FAIL: SDDM Current=01-breeze-avisblue not active' >&2; exit 1; }
    echo "OK: identity + SDDM-theme content asserts pass"

    # ----- policy.json carries our sigstore entry -------------------------
    local policy=/etc/containers/policy.json
    [[ -e "$policy" ]] || policy=/usr/etc/containers/policy.json
    if [[ ! -e "$policy" ]]; then
        echo "FAIL: policy.json not found at /etc/containers or /usr/etc/containers" >&2
        exit 1
    fi
    if ! command -v jq >/dev/null 2>&1; then
        echo "FAIL: jq not present in image (needed for policy.json check)" >&2
        exit 1
    fi
    if ! jq -e '.transports.docker["ghcr.io/elgorrion"]' "$policy" >/dev/null; then
        echo "FAIL: policy.json missing ghcr.io/elgorrion transport entry ($policy)" >&2
        exit 1
    fi
    echo "OK: policy.json carries ghcr.io/elgorrion sigstore entry"

    echo "==> Smoke test PASSED"
}

# --------------------------------------------------------------------------

if [[ "${1:-}" == "--inside" ]]; then
    shift
    run_inside "${1:?--inside requires VARIANT}"
    exit 0
fi

IMAGE="${1:?usage: smoke-test.sh IMAGE_REF VARIANT}"
VARIANT="${2:?usage: smoke-test.sh IMAGE_REF VARIANT}"

echo "==> Smoke test: $IMAGE (variant: $VARIANT)"
podman pull "$IMAGE"

# Re-exec this same script inside the image. `bash -c BODY ARG0 ARG1` exposes
# ARG0 as $0 and ARG1 onward as $1+ — so the inside-mode dispatch lands on
# `--inside` and forwards VARIANT.
SCRIPT_BODY=$(cat "${BASH_SOURCE[0]}")
podman run --rm --entrypoint /bin/bash "$IMAGE" \
    -c "$SCRIPT_BODY" smoke-test --inside "$VARIANT"
