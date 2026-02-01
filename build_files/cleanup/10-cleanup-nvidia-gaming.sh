#!/usr/bin/env bash
# cleanup-nvidia-gaming.sh - Remove unnecessary packages from Bazzite-NVIDIA for avisblue-nvidia-gaming
#
# This is the FIRST step after FROM bazzite-nvidia:stable
# Consolidates all removals into a single layer for smaller image size
#
# KEEPS gaming packages (unlike cleanup-main.sh):
#   - steam, lutris, gamescope, mangohud, vkBasalt
#   - umu-launcher, faugus-launcher, gamemode
#   - ScopeBuddy, 32-bit libs (*.i686)
#   - NVIDIA proprietary drivers
#
# What remains after this script:
#   - Everything from main cleanup, PLUS gaming stack
#   - KDE Plasma 6 desktop (minus konsole, partitionmanager - re-added later)
#   - bazzite-kernel, patched pipewire/mesa/etc.
#   - Gaming: steam, lutris, gamescope, mangohud, vkBasalt, etc.
#   - NVIDIA drivers
#
# What gets added back later:
#   - kde-apps.sh: konsole, kate, okular, gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd
#   - dev-tools.sh: code, podman-docker, docker-compose, virt-manager, virt-viewer
#   - gaming.sh: openrgb, openrgb-udev-rules + Flatpaks (ProtonUp-Qt, BoxBuddy)
#   - cuda.sh: nvidia-container-toolkit

set -euo pipefail

echo "=============================================="
echo "AVISBLUE-NVIDIA-GAMING: Cleaning Bazzite-NVIDIA base"
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
# NOTE: Gaming packages are KEPT (unlike cleanup-main.sh)
#################################################

# Handheld/HTPC - not needed for desktop gaming
HANDHELD=(
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
    jupiter-sd-mounting-btrfs
)

# Android/Streaming - not used
STREAMING=(
    waydroid
    cage
    wlr-randr
    sunshine
)

# ROCm - NVIDIA uses CUDA instead
ROCM=(
    rocm-hip
    rocm-opencl
    rocm-clinfo
    rocm-smi
)

# Duplicate tools - we use btop
DUPLICATES=(
    htop
    nvtop
)

# Hardware we don't have in CASA fleet
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
# NOTE: ScopeBuddy is KEPT for gaming
FEATURES=(
    # Bazzite first-run wizard
    bazzite-portal
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
# NOTE: gaming.sh will add ProtonUp-Qt and BoxBuddy later
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
echo "(Gaming packages are KEPT)"

# STRICT: Core Bazzite packages - if missing, upstream changed significantly
echo "[1/11] Handheld/HTPC packages (strict)..."
remove_packages strict "${HANDHELD[@]}"

# LENIENT: May vary between Bazzite versions
echo "[2/11] Streaming/Android packages..."
remove_packages lenient "${STREAMING[@]}"

echo "[3/11] ROCm packages (NVIDIA uses CUDA)..."
remove_packages lenient "${ROCM[@]}"

echo "[4/11] Duplicate tools..."
remove_packages lenient "${DUPLICATES[@]}"

echo "[5/11] Unused hardware support..."
remove_packages lenient "${HARDWARE[@]}"

echo "[6/11] Unused features..."
remove_packages lenient "${FEATURES[@]}"

echo "[7/11] GTK apps..."
remove_packages lenient "${GTK_APPS[@]}"

echo "[8/11] Cockpit..."
remove_packages lenient "${COCKPIT[@]}"

echo "[9/11] Debug tools..."
remove_packages lenient "${DEBUG[@]}"

echo "[10/11] IME packages..."
remove_packages lenient "${IME[@]}"

echo "[11/11] Fonts, shells, CLI tools..."
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
echo "CLEANUP COMPLETE - avisblue-nvidia-gaming base ready"
echo "Gaming packages preserved: steam, lutris, gamescope, etc."
echo "=============================================="
