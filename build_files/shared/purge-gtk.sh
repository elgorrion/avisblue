#!/usr/bin/env bash
# purge-gtk.sh - Remove GTK apps, install Qt alternatives
# Goal: Pure KDE experience without libadwaita/GTK4 apps

set -euo pipefail

echo "=== Purging GTK applications for pure KDE ==="

# GTK4/libadwaita Flatpaks to remove
GTK_FLATPAKS=(
    "com.vysp3r.ProtonPlus"           # GTK4 - replace with ProtonUp-Qt
    "com.ranfdev.DistroShelf"         # GTK4 - replace with BoxBuddy or CLI
    "io.github.flattool.Warehouse"    # GTK4 - use Discover instead
    "com.github.tchx84.Flatseal"      # GTK4 - no Qt equivalent, remove
)

echo "Removing GTK4/libadwaita Flatpaks..."
for app in "${GTK_FLATPAKS[@]}"; do
    echo "  Removing: $app"
    flatpak uninstall --system -y "$app" 2>/dev/null || true
done

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
echo ""
echo "KEPT (no Qt alternative):"
echo "  - Firefox (GTK3, works fine on KDE)"
echo "  - Lutris (GTK3, no alternative exists)"
echo "  - Protontricks (GTK3 Zenity dialogs, CLI primary)"
echo ""
echo "=== Pure KDE goal achieved ==="
