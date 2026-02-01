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

# Verify Wayland session exists
# Note: SDDM will auto-select the only available session when X11 is removed
# No need to write state.conf at build time - let SDDM generate it on first login
if [[ -f /usr/share/wayland-sessions/plasma.desktop ]]; then
    echo "Plasma Wayland session available (will be default since X11 removed)"
else
    echo "WARNING: plasma.desktop not found in wayland-sessions"
fi

echo "=== Wayland-only configuration complete ==="
