#!/usr/bin/env bash
# cleanup-main.sh - Remove all unnecessary packages from Bazzite for avisblue-main
#
# This is the FIRST step after FROM bazzite:stable
# Consolidates all removals into a single layer for smaller image size
#
# What remains after this script:
#   - KDE Plasma 6 desktop (minus konsole, partitionmanager - re-added later)
#   - bazzite-kernel (HDR, winesync, LAVD/BORE schedulers)
#   - Patched: pipewire, wireplumber, bluez, mesa, NetworkManager, fwupd
#   - System tools: btop, fastfetch, vim, tailscale, distrobox
#   - Btrfs: snapper, btrfs-assistant, bees
#   - Dev base: Homebrew, just, cosign, libvirt, qemu
#   - Schedulers: scx-scheds (LAVD/BORE)
#   - Fonts: nerd-fonts, fira-code-fonts
#   - Hardware: ddcutil, i2c-tools, lm_sensors
#
# What gets added back later:
#   - kde-apps.sh: konsole, kate, okular, gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd
#   - dev-tools.sh: code, podman-docker, docker-compose, virt-manager, virt-viewer
#   - rocm.sh: rocm-hip, rocm-opencl, rocm-clinfo, rocm-smi

set -euo pipefail

echo "=============================================="
echo "AVISBLUE-MAIN: Cleaning Bazzite base image"
echo "=============================================="

#################################################
# SECTION 1: RPM PACKAGES TO REMOVE
#################################################

# Gaming - not needed for workstation
GAMING=(
    steam
    lutris
    gamescope
    gamescope-shaders
    gamescope-libs
    mangohud
    vkBasalt
    umu-launcher
    winetricks
    faugus-launcher
    gamemode
    libobs_vkcapture
    libobs_glcapture
)

# Handheld/HTPC - not needed for desktop
HANDHELD=(
    hhd
    hhd-ui
    adjustor
    steam-patch
    jupiter-fan-control
    jupiter-hw-support
    steamdeck-dsp
    steamdeck-kde-presets
    steamdeck-kde-presets-desktop
    sdgyrodsu
    decky-loader
    jupiter-sd-mounting-btrfs
)

# Android/Streaming - not used
STREAMING=(
    waydroid
    cage
    wlr-randr
    sunshine
    input-remapper
)

# ROCm - removed now, re-added by rocm.sh later
ROCM=(
    rocm-hip
    rocm-opencl
    rocm-clinfo
    rocm-smi
)

# 32-bit libraries - not needed without gaming
LIB32=(
    "*.i686"
)

# Duplicate tools - we use btop
DUPLICATES=(
    htop
    nvtop
)

# Hardware we don't have in CASA fleet
HARDWARE=(
    # Microsoft Surface
    iptsd
    libwacom-surface
    # Framework laptop
    fw-ectool
    fw-fanctrl
    framework-system
    # Steam Deck/handheld undervolting
    ryzenadj
    # Wii Remote
    xwiimote-ng
    # Racing wheels
    oversteer-udev
)

# Features we don't use
FEATURES=(
    # Bazzite first-run wizard
    bazzite-portal
    # Gamescope helper
    ScopeBuddy
    # DualSense controller inhibitor
    ds-inhibit
    # HDMI-CEC for HTPCs
    libcec
    # App store GUI (we use flatpak CLI)
    bazaar
    krunner-bazaar
    # Update tool (we use ublue-update)
    topgrade
    # GUI dialog tool for scripts
    yad
    # Web app creator
    webapp-manager
)

# GTK apps - we want pure KDE
GTK_APPS=(
    # Bazzite replaces kde-partitionmanager with this
    gnome-disk-utility
    # Bazzite terminal - we use konsole
    ptyxis
)

# Cockpit web management - we use SSH/terminal
COCKPIT=(
    cockpit-networkmanager
    cockpit-podman
    cockpit-selinux
    cockpit-system
    cockpit-files
    cockpit-storaged
)

# Testing/debugging tools
DEBUG=(
    stress-ng
    powerstat
    f3
)

# Input Method Editors - English-only fleet
IME=(
    fcitx5-chinese-addons
    fcitx5-configtool
    fcitx5-gtk
    fcitx5-hangul
    fcitx5-libthai
    fcitx5-mozc
    fcitx5-qt
    fcitx5-sayura
    fcitx5-unikey
    kcm-fcitx5
)

# Fonts we don't need
FONTS=(
    google-noto-sans-balinese-fonts
    google-noto-sans-javanese-fonts
    google-noto-sans-sundanese-fonts
)

# Alternative shells - we use bash
SHELLS=(
    fish
    zsh
)

# Optional CLI tools
CLI_TOOLS=(
    glow
    gum
)

#################################################
# SECTION 2: FLATPAKS TO REMOVE
#################################################

GTK_FLATPAKS=(
    "org.mozilla.firefox"
    "com.github.Matoking.protontricks"
    "com.vysp3r.ProtonPlus"
    "com.ranfdev.DistroShelf"
    "io.github.flattool.Warehouse"
    "com.github.tchx84.Flatseal"
)

QT_FLATPAKS=(
    "org.kde.gwenview"
    "org.kde.okular"
    "org.kde.kcalc"
    "org.kde.haruna"
    "org.kde.filelight"
)

#################################################
# SECTION 3: EXECUTE REMOVAL
#################################################

echo ""
echo "--- Removing RPM packages ---"

echo "[1/13] Gaming packages..."
dnf5 -y remove "${GAMING[@]}" 2>/dev/null || true

echo "[2/13] Handheld/HTPC packages..."
dnf5 -y remove "${HANDHELD[@]}" 2>/dev/null || true

echo "[3/13] Streaming/Android packages..."
dnf5 -y remove "${STREAMING[@]}" 2>/dev/null || true

echo "[4/13] ROCm packages (re-added later)..."
dnf5 -y remove "${ROCM[@]}" 2>/dev/null || true

echo "[5/13] 32-bit libraries..."
dnf5 -y remove ${LIB32[@]} 2>/dev/null || true

echo "[6/13] Duplicate tools..."
dnf5 -y remove "${DUPLICATES[@]}" 2>/dev/null || true

echo "[7/13] Unused hardware support..."
dnf5 -y remove "${HARDWARE[@]}" 2>/dev/null || true

echo "[8/13] Unused features..."
dnf5 -y remove "${FEATURES[@]}" 2>/dev/null || true

echo "[9/13] GTK apps..."
dnf5 -y remove "${GTK_APPS[@]}" 2>/dev/null || true

echo "[10/13] Cockpit..."
dnf5 -y remove "${COCKPIT[@]}" 2>/dev/null || true

echo "[11/13] Debug tools..."
dnf5 -y remove "${DEBUG[@]}" 2>/dev/null || true

echo "[12/13] IME packages..."
dnf5 -y remove "${IME[@]}" 2>/dev/null || true

echo "[13/13] Fonts, shells, CLI tools..."
dnf5 -y remove "${FONTS[@]}" "${SHELLS[@]}" "${CLI_TOOLS[@]}" 2>/dev/null || true

echo ""
echo "--- Removing Flatpaks ---"

echo "GTK Flatpaks..."
for app in "${GTK_FLATPAKS[@]}"; do
    flatpak uninstall --system -y "$app" 2>/dev/null || true
done

echo "Qt Flatpaks (using RPMs instead)..."
for app in "${QT_FLATPAKS[@]}"; do
    flatpak uninstall --system -y "$app" 2>/dev/null || true
done

echo "Cleaning unused Flatpak runtimes..."
flatpak uninstall --system --unused -y 2>/dev/null || true

echo ""
echo "=============================================="
echo "CLEANUP COMPLETE - avisblue-main base ready"
echo "=============================================="
