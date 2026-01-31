#!/usr/bin/env bash
# install-chrome.sh - Prepare for Chrome installation
# Chrome uses extra-data which doesn't work in container builds.
# We ensure Flathub is configured so users can easily install post-boot.

set -euo pipefail

echo "=== Preparing for browser installation ==="

# Ensure Flathub is available for user to install Chrome later
echo "Ensuring Flathub remote is configured..."
flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

# Firefox is already included in Bazzite/Fedora
echo "Firefox is pre-installed."
echo "To install Chrome post-boot: flatpak install flathub com.google.Chrome"

echo "=== Browser preparation complete ==="
