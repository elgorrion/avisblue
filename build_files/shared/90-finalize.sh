#!/usr/bin/env bash
# finalize.sh - Final cleanup and image preparation
# Applied at the end of all avisblue image builds

set -euo pipefail

echo "=== Finalizing avisblue image ==="

# Clean package caches
echo "Cleaning package caches..."
dnf5 clean all

# Remove build context
echo "Removing build context..."
rm -rf /ctx

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
