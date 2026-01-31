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
    kdeconnectd

echo "=== KDE apps installed ==="
