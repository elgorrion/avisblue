#!/usr/bin/env bash
# cleanup-main.sh - Remove all unnecessary packages from Bazzite for avisblue-main
#
# This is the FIRST step after FROM bazzite:stable
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
#   - dev-tools.sh: code, podman-docker, podman-compose, qemu-kvm, libvirt, cockpit-machines, cockpit-ostree
#
# AMD compute (ROCm) is intentionally NOT added: bazzite:stable dropped rocm-*
# from its base in the April 2026 update; we follow upstream and use
# container-based ROCm (rocm/pytorch etc.) instead.

set -euo pipefail

echo "=============================================="
echo "AVISBLUE-MAIN: Cleaning Bazzite base image"
echo "=============================================="

#################################################
# HELPER: Resilient package removal
# Usage: remove_packages <mode> <array>
#   mode: "strict" = fail if packages missing (Bazzite changed)
#         "lenient" = skip silently if missing
#################################################
remove_packages() {
    local mode="$1"
    shift
    local packages=("$@")

    if [[ "$mode" == "strict" ]]; then
        # These packages MUST exist in Bazzite - fail loudly if missing
        if ! dnf5 -y remove "${packages[@]}" 2>&1 | tee /tmp/dnf-remove.log; then
            if grep -q "No match for argument" /tmp/dnf-remove.log; then
                echo "ERROR: Expected Bazzite packages not found: ${packages[*]}"
                echo "Bazzite may have changed upstream. Check and update cleanup script."
                exit 1
            fi
        fi
    else
        # These packages may not exist - skip silently
        dnf5 -y remove "${packages[@]}" 2>/dev/null || true
    fi
}

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
    libobs_vkcapture
    libobs_glcapture
)

# Gaming packages removed from Bazzite desktop images upstream (April 2026)
GAMING_GONE=(
    winetricks
    faugus-launcher
    gamemode
)

# Handheld/HTPC - not needed for desktop
# Most handheld packages removed from Bazzite desktop images upstream (April 2026)
HANDHELD=(
    steamdeck-kde-presets-desktop
    jupiter-sd-mounting-btrfs
)

# Handheld packages no longer in Bazzite desktop images
HANDHELD_GONE=(
    hhd
    hhd-ui
    adjustor
    steam-patch
    jupiter-fan-control
    jupiter-hw-support
    steamdeck-dsp
    steamdeck-kde-presets
    sdgyrodsu
    decky-loader
)

# Android/Streaming - not used
STREAMING=(
    waydroid
    cage
    wlr-randr
    sunshine
    input-remapper
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

# Hardware-specific packages to remove
# NOTE: Do NOT remove libwacom-surface - it triggers Plasma removal cascade
HARDWARE=(
    # Microsoft Surface
    iptsd
    # libwacom-surface - KEEP: removing causes Plasma dependency cascade
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
    # libcec
    # App store GUI (we use flatpak CLI)
    bazaar
    krunner-bazaar
    # Update tool (we use ublue-update)
    topgrade
    # GUI dialog tool for scripts
    yad
    # Web app creator
    # webapp-manager
)

# GTK apps - we want pure KDE
GTK_APPS=(
    # Bazzite replaces kde-partitionmanager with this
    gnome-disk-utility
    # Bazzite terminal - we use konsole
    ptyxis
)

# Cockpit web management - KEEP for fleet management
# cockpit-system, cockpit-podman, cockpit-storaged, cockpit-networkmanager,
# cockpit-files, cockpit-selinux are all useful for remote management
# Additional packages added in dev-tools.sh: cockpit-machines, cockpit-ostree

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

# STRICT: Core Bazzite packages - if missing, upstream changed significantly
echo "[1/14] Gaming packages (strict)..."
remove_packages strict "${GAMING[@]}"

echo "[2/14] Gaming packages removed upstream..."
remove_packages lenient "${GAMING_GONE[@]}"

echo "[3/14] Handheld/HTPC packages (strict)..."
remove_packages strict "${HANDHELD[@]}"

echo "[4/14] Handheld packages removed upstream..."
remove_packages lenient "${HANDHELD_GONE[@]}"

# LENIENT: May vary between Bazzite versions
echo "[5/13] Streaming/Android packages..."
remove_packages lenient "${STREAMING[@]}"

echo "[6/13] 32-bit libraries..."
remove_packages lenient "${LIB32[@]}"

echo "[7/13] Duplicate tools..."
remove_packages lenient "${DUPLICATES[@]}"

echo "[8/13] Unused hardware support..."
remove_packages lenient "${HARDWARE[@]}"

echo "[9/13] Unused features..."
remove_packages lenient "${FEATURES[@]}"

echo "[10/13] GTK apps..."
remove_packages lenient "${GTK_APPS[@]}"

echo "[11/13] Debug tools..."
remove_packages lenient "${DEBUG[@]}"

echo "[12/13] IME packages..."
remove_packages lenient "${IME[@]}"

echo "[13/13] Fonts, shells, CLI tools..."
remove_packages lenient "${FONTS[@]}" "${SHELLS[@]}" "${CLI_TOOLS[@]}"

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
