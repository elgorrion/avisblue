#!/usr/bin/env bash
# strip-upstream.sh - Remove unnecessary packages from upstream layers
# Removes bloat from Universal Blue main and Bazzite that we don't need
#
# Run AFTER strip-bazzite.sh or strip-bazzite-handheld.sh

set -euo pipefail

echo "=== Stripping unnecessary upstream packages ==="

# Duplicates - we use btop
DUPLICATES=(
    htop
    nvtop
)

# Hardware we don't have in CASA fleet
HARDWARE_SUPPORT=(
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
    # Logitech wireless (uncomment if no Logitech devices)
    # solaar-udev
    # libratbag-ratbagd
)

# Features we don't use
UNUSED_FEATURES=(
    # Game streaming
    Sunshine
    # Web app creator
    webapp-manager
    # Bazzite first-run wizard
    bazzite-portal
    # Gamescope helper (not needed without gaming)
    ScopeBuddy
    # DualSense controller inhibitor
    ds-inhibit
    # HDMI-CEC for HTPCs
    libcec
    # App store GUI (we use flatpak CLI)
    bazaar
    # Update tool (we use ublue-update)
    topgrade
    # GUI dialog tool for scripts
    yad
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

# Testing/debugging tools not needed in production
DEBUG_TOOLS=(
    stress-ng
    powerstat
    f3
)

# Input Method Editors - English-only fleet
# Comment out this section if you need CJK/international input
IME_PACKAGES=(
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
# Keep: nerd-fonts, fira-code-fonts (dev use)
FONTS=(
    google-noto-sans-balinese-fonts
    google-noto-sans-javanese-fonts
    google-noto-sans-sundanese-fonts
    # CJK fonts - large (~100MB), uncomment if not needed
    # google-noto-sans-cjk-fonts
    # Emoji - uncomment if not needed
    # twitter-twemoji-fonts
)

# Yubikey/U2F support - uncomment if not using hardware keys
# YUBIKEY=(
#     yubikey-manager
#     pam-u2f
#     pam_yubico
#     pamu2fcfg
# )

# iPhone/iOS support - uncomment if not using
# IPHONE=(
#     usbmuxd
#     libimobiledevice-utils
# )

# Alternative shells - we use bash
SHELLS=(
    fish
    zsh
)

# Markdown/TUI tools - optional
OPTIONAL_CLI=(
    glow
    gum
)

echo "Removing duplicate tools..."
dnf5 -y remove "${DUPLICATES[@]}" 2>/dev/null || true

echo "Removing unused hardware support..."
dnf5 -y remove "${HARDWARE_SUPPORT[@]}" 2>/dev/null || true

echo "Removing unused features..."
dnf5 -y remove "${UNUSED_FEATURES[@]}" 2>/dev/null || true

echo "Removing Cockpit web management..."
dnf5 -y remove "${COCKPIT[@]}" 2>/dev/null || true

echo "Removing debug/testing tools..."
dnf5 -y remove "${DEBUG_TOOLS[@]}" 2>/dev/null || true

echo "Removing IME packages..."
dnf5 -y remove "${IME_PACKAGES[@]}" 2>/dev/null || true

echo "Removing unnecessary fonts..."
dnf5 -y remove "${FONTS[@]}" 2>/dev/null || true

echo "Removing alternative shells..."
dnf5 -y remove "${SHELLS[@]}" 2>/dev/null || true

echo "Removing optional CLI tools..."
dnf5 -y remove "${OPTIONAL_CLI[@]}" 2>/dev/null || true

# Uncomment to enable these removals:
# echo "Removing Yubikey support..."
# dnf5 -y remove "${YUBIKEY[@]}" 2>/dev/null || true

# echo "Removing iPhone support..."
# dnf5 -y remove "${IPHONE[@]}" 2>/dev/null || true

echo "=== Upstream stripping complete ==="
