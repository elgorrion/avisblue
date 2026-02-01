#!/usr/bin/env bash
# wayland-only.sh - Remove X11 session, keep XWayland for compatibility
# Applied to all avisblue images

set -euo pipefail

echo "=== Configuring Wayland-only experience ==="

# Remove X11 session files (hide from SDDM session selector)
echo "Removing X11 session entries..."
rm -f /usr/share/xsessions/plasmaX11.desktop 2>/dev/null || true
rm -f /usr/share/xsessions/plasma.desktop 2>/dev/null || true
rm -f /usr/share/xsessions/plasma-xorg.desktop 2>/dev/null || true

# List remaining sessions for verification
echo "Remaining X11 sessions:"
ls -la /usr/share/xsessions/ 2>/dev/null || echo "  (none)"

echo "Available Wayland sessions:"
ls -la /usr/share/wayland-sessions/ 2>/dev/null || echo "  (none)"

# Ensure Wayland session is default
echo "Setting Plasma Wayland as default session..."
if [[ -f /usr/share/wayland-sessions/plasma.desktop ]]; then
    # Create SDDM state to default to Wayland
    mkdir -p /var/lib/sddm
    cat > /var/lib/sddm/state.conf << 'EOF'
[Last]
Session=/usr/share/wayland-sessions/plasma.desktop
EOF
    echo "Default session set to Plasma Wayland"
else
    echo "WARNING: plasma.desktop not found in wayland-sessions"
fi

echo "=== Wayland-only configuration complete ==="
