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

# Verify critical packages still present and not corrupted.
# plasma-desktop/kwin/systemd come from the Aurora-dx base; kate is added in
# 30-kde-apps.sh (which runs before this) — all must be present at finalize.
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

# Mask the inherited rpm-ostree-countme units (VISION §9.1: no telemetry, even
# opt-in). The Fedora-derived base ships rpm-ostree-countme.timer; it triggers
# `rpm-ostree countme` on a 3-day cycle, which phones home to Fedora's mirror
# infra to count active deployments. Aurora/Bluefin keep this on (community
# count badge); Avisblue diverges constitutionally. Mask (not just disable) so
# the units cannot be started manually either.
#
# Lenient on absence (a future base may drop the units), strict on everything
# else: only skip when the units genuinely aren't shipped — a real `mask`
# failure (read-only /etc, broken systemctl) must still fail the build, or we'd
# ship with telemetry silently re-enabled.
echo "Masking rpm-ostree-countme units (constitutional: no telemetry)..."
countme_units=()
for unit in rpm-ostree-countme.timer rpm-ostree-countme.service; do
    if [[ -e "/usr/lib/systemd/system/${unit}" || -e "/etc/systemd/system/${unit}" ]]; then
        countme_units+=("${unit}")
    fi
done
if (( ${#countme_units[@]} > 0 )); then
    systemctl mask "${countme_units[@]}"
else
    echo "rpm-ostree-countme units not present; skipping mask."
fi

# Clean package caches
echo "Cleaning package caches..."
dnf5 clean all

# Remove temporary files
echo "Removing temporary files..."
rm -rf /tmp/* /var/tmp/*

# Ensure proper permissions on skel files
# environment.d/ + systemd/user/ are no longer skel-owned — they are managed by
# system_files/usr/lib/tmpfiles.d/avisblue-user.conf (force-symlinked into ~ on
# every login) + system_files/etc/systemd/user/default.target.wants/.
echo "Setting skel permissions..."
chmod 644 /etc/skel/.bashrc
chmod 644 /etc/skel/.bashrc.d/*.sh 2>/dev/null || true

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
