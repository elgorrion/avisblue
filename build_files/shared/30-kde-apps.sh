#!/usr/bin/env bash
# 30-kde-apps.sh - Curated KDE app set + Chromium (RPMs).
#
# The set we always want present on every fleet machine. dnf5 install is
# idempotent: anything Aurora-dx already ships (e.g. konsole, ark) is a no-op,
# anything it doesn't (e.g. partitionmanager, chromium) gets added. RPMs are
# preferred over Flatpaks here for tighter desktop integration.

set -euo pipefail

echo "=== Installing curated KDE apps + Chromium (RPMs) ==="

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

# Chromium is the pre-installed browser (the Firefox flatpak, if any, is removed
# in 10-trim.sh per VISION §9.3). Users can install other browsers via Flatpak.

echo "=== KDE apps + Chromium installed ==="
