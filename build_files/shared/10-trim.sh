#!/usr/bin/env bash
# 10-trim.sh — minimal trim of the Aurora-dx base (VISION §0, §9).
#
# This is the FIRST build step, shared by both flavors (avisblue-main on
# aurora-dx, avisblue-nvidia on aurora-dx-nvidia-open).
#
# PHILOSOPHY: Avisblue 2.x builds *up* from a clean developer desktop instead
# of stripping *down* a gaming OS. Aurora-dx is already the lean, batteries-
# included KDE workstation we want, so this script does almost nothing — it only
# enforces a few constitutional invariants (§9): English-only locale, pure-Qt
# desktop, no telemetry-adjacent duplicates.
#
# Every removal here is LENIENT on purpose. Unlike the Bazzite-era cleanup, we
# do NOT hard-fail on missing packages: we are not surgically dismantling the
# base, so upstream adding/renaming/dropping any of these must never red the
# build. If Aurora doesn't ship something, there is simply nothing to remove.

set -euo pipefail

echo "=============================================="
echo "AVISBLUE: trimming Aurora-dx base (minimal)"
echo "=============================================="

trim() {
    # Lenient removal: skip silently if a package isn't installed.
    dnf5 -y remove "$@" 2>/dev/null || true
}

# §9.4 English-only fleet — drop non-English input methods.
echo "--- Input methods (English-only fleet) ---"
trim \
    fcitx5-chinese-addons \
    fcitx5-configtool \
    fcitx5-gtk \
    fcitx5-hangul \
    fcitx5-libthai \
    fcitx5-mozc \
    fcitx5-qt \
    fcitx5-sayura \
    fcitx5-unikey \
    kcm-fcitx5

# §9.4 Non-English fonts we never render.
echo "--- Non-English fonts ---"
trim \
    google-noto-sans-balinese-fonts \
    google-noto-sans-javanese-fonts \
    google-noto-sans-sundanese-fonts

# Alternative shells — the fleet standardizes on bash (skel config in §7).
echo "--- Alternative shells ---"
trim fish zsh

# Duplicate system monitors — we use btop.
echo "--- Duplicate monitors ---"
trim htop nvtop

echo ""
echo "--- Flatpaks ---"
# §9.3 Browser is Chromium (installed as an RPM in 30-kde-apps). Drop the
# Firefox flatpak if the base preinstalled it.
flatpak uninstall --system -y org.mozilla.firefox 2>/dev/null || true
flatpak uninstall --system --unused -y 2>/dev/null || true

echo ""
echo "=============================================="
echo "TRIM COMPLETE — Aurora-dx base ready"
echo "=============================================="
