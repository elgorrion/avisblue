#!/usr/bin/env bash
# install-chrome.sh - Install Google Chrome via Flatpak
# Using Flatpak avoids rpm conflicts with existing /opt/google

set -euo pipefail

echo "=== Installing Google Chrome via Flatpak ==="

# Ensure Flathub is available
echo "Ensuring Flathub remote is configured..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

# Install Chrome from Flathub
echo "Installing Google Chrome from Flathub..."
flatpak install -y --noninteractive flathub com.google.Chrome

echo "=== Google Chrome installed ==="
