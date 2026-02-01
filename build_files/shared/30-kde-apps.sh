#!/usr/bin/env bash
# kde-apps.sh - Install KDE apps and Chromium as RPMs
# Better integration than Flatpaks

set -euo pipefail

echo "=== Installing KDE apps + Chromium (RPMs) ==="

dnf5 -y install \
    kate \
    okular \
    gwenview \
    ark \
    kcalc \
    spectacle \
    partitionmanager \
    kdeconnectd \
    konsole \
    chromium

# Note: Bazzite removes konsole in favor of ptyxis (GNOME terminal)
# We remove ptyxis in 10-cleanup-*.sh and re-add konsole here
#
# Chromium is the only pre-installed browser (Firefox GTK Flatpak removed)
# Users can install other browsers via Flatpak if needed

echo "=== KDE apps + Chromium installed ==="
