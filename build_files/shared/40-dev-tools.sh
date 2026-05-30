#!/usr/bin/env bash
# 40-dev-tools.sh — the thin developer/fleet layer Avisblue adds on top of Aurora-dx.
#
# Aurora-dx ALREADY ships the heavy developer substrate, so we do NOT re-add it
# (and must not — e.g. installing podman-docker would conflict with Aurora-dx's
# real docker-ce). Inherited for free (VISION §2):
#   - Editors:        VS Code
#   - Containers:     docker-ce + podman + podman-compose, distrobox, devcontainers
#   - Virtualization: libvirt, qemu, virt-manager, incus
#   - Web management: cockpit (base)
#   - CLI / runtimes: Homebrew (linuxbrew)
#
# Language toolchains (Python, Node/TS, …) are NOT baked into the image
# (VISION §4): they are provisioned per-user via Homebrew + dotfiles on first
# boot, and per-project via devcontainers/distrobox. Keeping them out of the
# image is the whole point of the atomic/minimal model.
#
# So this script adds almost nothing — only the Cockpit fleet extensions that
# Aurora-dx's cockpit base doesn't include. Idempotent: a no-op if already present.

set -euo pipefail

echo "=== Installing Cockpit fleet extensions ==="

dnf5 -y install \
    cockpit-machines \
    cockpit-ostree

echo "=== Fleet extensions complete ==="
