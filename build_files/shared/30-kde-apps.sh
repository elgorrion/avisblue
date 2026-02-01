#!/usr/bin/env bash
# kde-apps.sh - Install KDE apps as RPMs
# Better integration than Flatpaks

set -euo pipefail

echo "=== Installing KDE apps (RPMs) ==="

dnf5 -y install \
    kate \
    okular \
    gwenview \
    ark \
    kcalc \
    spectacle \
    partitionmanager \
    kdeconnectd \
    konsole

# Note: Bazzite removes konsole in favor of ptyxis (GNOME terminal)
# We remove ptyxis in strip-upstream.sh and re-add konsole here

echo "=== KDE apps installed ==="
