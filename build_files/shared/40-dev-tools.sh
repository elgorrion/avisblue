#!/usr/bin/env bash
# 40-dev-tools.sh — the thin developer layer Avisblue adds on top of Aurora-dx.
#
# Aurora-dx ALREADY ships the heavy developer substrate, so we do NOT re-add it
# (and must not — e.g. installing podman-docker would conflict with Aurora-dx's
# real docker-ce). Inherited for free (VISION §2):
#   - Editors:        VS Code
#   - Containers:     docker-ce + podman + podman-compose, distrobox, devcontainers
#   - Virtualization: libvirt, qemu, virt-manager, incus
#   - Web management: cockpit (base)
#
# We add only:
#   1. mise — the one dev tool we bake system-wide (VISION §4): a single static
#      binary that manages Python / Node / TS / etc. toolchains per-user in $HOME.
#      Language runtimes themselves are NOT layered into the image.
#   2. Cockpit fleet extensions (machines, ostree) for remote fleet management.

set -euo pipefail

echo "=== Installing Avisblue dev layer (mise + cockpit extensions) ==="

# 1. mise (polyglot runtime manager) from the official upstream RPM repo. This
#    mirrors the canonical Fedora install (mise.jdx.dev/rpm) and the same repo
#    pattern this codebase used for VS Code. Fail loud: mise is the headline dev
#    capability (VISION §4), so a missing it should red the build.
echo "Importing mise GPG key..."
MISE_KEY_URL="https://mise.jdx.dev/gpg-key.pub"
KEY_IMPORTED=false
for attempt in 1 2 3; do
    if rpm --import "$MISE_KEY_URL"; then
        echo "mise GPG key imported successfully"
        KEY_IMPORTED=true
        break
    fi
    echo "Attempt $attempt failed, retrying in 2s..."
    sleep 2
done

if [[ "$KEY_IMPORTED" != "true" ]]; then
    echo "ERROR: Failed to import mise GPG key after 3 attempts"
    exit 1
fi

cat > /etc/yum.repos.d/mise.repo << 'EOF'
[mise]
name=mise
baseurl=https://mise.jdx.dev/rpm
enabled=1
gpgcheck=1
gpgkey=https://mise.jdx.dev/gpg-key.pub
EOF

echo "Installing mise..."
dnf5 -y install mise

# 2. Cockpit fleet extensions (Aurora-dx ships cockpit base; add VM + ostree UIs).
#    Idempotent: a no-op if Aurora already includes them.
echo "Installing Cockpit fleet extensions..."
dnf5 -y install \
    cockpit-machines \
    cockpit-ostree

echo "=== Dev layer complete ==="
