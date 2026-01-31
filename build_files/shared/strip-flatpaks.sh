#!/usr/bin/env bash
# strip-flatpaks.sh - Remove ALL Bazzite Flatpaks
# Use RPMs for better KDE integration

set -euo pipefail

echo "=== Removing all Bazzite Flatpaks ==="

# GTK Flatpaks (must remove for pure KDE)
GTK_FLATPAKS=(
    "org.mozilla.firefox"
    "com.github.Matoking.protontricks"
    "com.vysp3r.ProtonPlus"
    "com.ranfdev.DistroShelf"
    "io.github.flattool.Warehouse"
    "com.github.tchx84.Flatseal"
)

# Qt Flatpaks (using RPMs instead for better integration)
QT_FLATPAKS=(
    "org.kde.gwenview"
    "org.kde.okular"
    "org.kde.kcalc"
    "org.kde.haruna"
    "org.kde.filelight"
)

echo "Removing GTK Flatpaks..."
for app in "${GTK_FLATPAKS[@]}"; do
    echo "  - $app"
    flatpak uninstall --system -y "$app" 2>/dev/null || true
done

echo "Removing Qt Flatpaks (using RPMs instead)..."
for app in "${QT_FLATPAKS[@]}"; do
    echo "  - $app"
    flatpak uninstall --system -y "$app" 2>/dev/null || true
done

echo "Cleaning unused Flatpak runtimes..."
flatpak uninstall --system --unused -y 2>/dev/null || true

echo "=== Flatpak cleanup complete ==="
