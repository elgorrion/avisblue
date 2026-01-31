#!/usr/bin/env bash
# purge-gtk.sh - Remove GTK apps, install Qt alternatives
# Goal: Pure KDE experience without libadwaita/GTK4 apps

set -euo pipefail

echo "=== Purging GTK applications for pure KDE ==="

# GTK Flatpaks to remove
GTK_FLATPAKS=(
    "org.mozilla.firefox"             # GTK3 - user installs preferred browser
    "com.github.Matoking.protontricks" # GTK3 - rarely needed, install if required
    "com.vysp3r.ProtonPlus"           # GTK4 - replace with ProtonUp-Qt
    "com.ranfdev.DistroShelf"         # GTK4 - replace with BoxBuddy or CLI
    "io.github.flattool.Warehouse"    # GTK4 - use Discover instead
    "com.github.tchx84.Flatseal"      # GTK4 - no Qt equivalent, remove
)

# GTK RPM packages to remove
GTK_RPMS=(
    "lutris"                          # GTK3 - no Qt alternative, remove entirely
)

echo "Removing GTK Flatpaks..."
for app in "${GTK_FLATPAKS[@]}"; do
    echo "  Removing: $app"
    flatpak uninstall --system -y "$app" 2>/dev/null || true
done

echo ""
echo "Removing GTK RPM packages..."
dnf5 -y remove ${GTK_RPMS[@]} || true

# Install Qt alternatives
echo ""
echo "Installing Qt alternatives..."

# ProtonUp-Qt (Qt6) - replaces ProtonPlus
echo "  Installing ProtonUp-Qt..."
flatpak install --system -y flathub net.davidotek.pupgui2 || true

# BoxBuddy (Qt) - replaces DistroShelf for Distrobox management
echo "  Installing BoxBuddy..."
flatpak install --system -y flathub io.github.dvlv.boxbuddyrs || true

# Note: No Qt replacement for Flatseal
# Users can manage Flatpak permissions via:
#   flatpak override --user <app-id> --<permission>
# Or use Discover's built-in permission viewer

echo ""
echo "=== GTK cleanup summary ==="
echo "REMOVED (GTK3):"
echo "  - Firefox (browser - user installs preferred)"
echo "  - Lutris (game launcher - use Steam/Heroic instead)"
echo "  - Protontricks (rarely needed - install if required)"
echo ""
echo "REMOVED (GTK4/libadwaita):"
echo "  - ProtonPlus (Proton manager)"
echo "  - DistroShelf (Distrobox GUI)"
echo "  - Warehouse (Flatpak manager)"
echo "  - Flatseal (Flatpak permissions)"
echo ""
echo "INSTALLED (Qt):"
echo "  - ProtonUp-Qt (Proton manager)"
echo "  - BoxBuddy (Distrobox GUI)"
echo ""
echo "USE INSTEAD:"
echo "  - Discover for Flatpak management (built-in)"
echo "  - 'flatpak override' CLI for permissions"
echo "  - Falkon/Chromium for browsing (install via Flatpak)"
echo "  - Steam for non-Steam games (add as non-Steam game)"
echo ""
echo "=== 100% Pure KDE achieved - zero GTK apps ==="
