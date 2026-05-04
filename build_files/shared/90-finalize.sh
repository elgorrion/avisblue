#!/usr/bin/env bash
# finalize.sh - Final cleanup and image preparation
# Applied at the end of all avisblue image builds

set -euo pipefail

echo "=== Finalizing avisblue image ==="

# Validate package database integrity
echo "Validating package database..."
if ! rpm -qa > /dev/null 2>&1; then
    echo "ERROR: Package database corrupted after cleanup"
    exit 1
fi

# Verify critical packages still present and not corrupted
# Note: Only check packages in base Bazzite, not ones we add (like konsole)
CRITICAL_PACKAGES=(plasma-desktop kwin kate systemd)
for pkg in "${CRITICAL_PACKAGES[@]}"; do
    if ! rpm -q "$pkg" > /dev/null 2>&1; then
        echo "ERROR: Critical package $pkg was removed!"
        exit 1
    fi
done

# Verify critical package files aren't corrupted (check config and binary files only)
echo "Verifying critical package integrity..."
for pkg in "${CRITICAL_PACKAGES[@]}"; do
    # rpm --verify returns non-zero if files modified/missing, filter to only failures
    # Ignore config files (c), docs (d), and ghost files (g) - only care about binaries
    if rpm --verify "$pkg" 2>/dev/null | grep -v "^\.\.\.\.\.\.\.\.\.  [cdg]" | grep -q "^.M\|^missing"; then
        echo "WARNING: Package $pkg has modified or missing files"
        rpm --verify "$pkg" 2>/dev/null | grep -v "^\.\.\.\.\.\.\.\.\.  [cdg]" | head -5
    fi
done
echo "Package database valid, critical packages present"

# Mask Bazzite's inherited rpm-ostree-countme units (VISION §4#3: no telemetry,
# even opt-in). Bazzite ships rpm-ostree-countme.timer enabled by default; it
# triggers `rpm-ostree countme` on a 3-day cycle, which phones home to Fedora's
# mirror infra to count active deployments. Bluefin keeps this on (community
# count badge); Avisblue diverges constitutionally. Mask (not just disable) so
# the units cannot be started manually either.
#
# Audit 2026-05-04 (against bazzite:stable + bazzite-nvidia-open:stable):
#   - rpm-ostree-countme.timer/service: ENABLED — masked here
#   - kde-inotify-survey: NOT telemetry (KDE inotify-limit notifier)
#   - dnf countme=: not set in /etc/dnf/dnf.conf (default off)
echo "Masking rpm-ostree-countme units (constitutional: no telemetry)..."
systemctl mask rpm-ostree-countme.timer rpm-ostree-countme.service

# Clean package caches
echo "Cleaning package caches..."
dnf5 clean all

# Remove temporary files
echo "Removing temporary files..."
rm -rf /tmp/* /var/tmp/*

# Ensure proper permissions on skel files
echo "Setting skel permissions..."
chmod 644 /etc/skel/.bashrc
chmod 644 /etc/skel/.bashrc.d/*.sh 2>/dev/null || true
chmod 644 /etc/skel/.config/environment.d/*.conf 2>/dev/null || true
chmod 644 /etc/skel/.config/systemd/user/*.service 2>/dev/null || true

# Regenerate font cache
echo "Regenerating font cache..."
fc-cache -f 2>/dev/null || true

# Update desktop database
echo "Updating desktop database..."
update-desktop-database /usr/share/applications 2>/dev/null || true

# Update mime database
echo "Updating mime database..."
update-mime-database /usr/share/mime 2>/dev/null || true

echo "=== Finalization complete ==="
