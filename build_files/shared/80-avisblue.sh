#!/usr/bin/env bash
# 80-avisblue.sh - Avisblue identity, signing setup, service enablement
#
# Runs after roles (50-*) and before finalize (90-*).
# Consolidates all our own customizations into one script:
#   1. Patch /usr/lib/os-release with Avisblue identity (KEEPS ID=fedora)
#   2. Write /etc/system-release
#   3. Write /usr/share/ublue-os/image-info.json
#   4. Merge our entry into Bazzite's /usr/etc/containers/policy.json
#   5. Enable avisblue-flatpak-manager.service

set -euo pipefail

: "${IMAGE_NAME:?IMAGE_NAME must be set}"
: "${IMAGE_VENDOR:?IMAGE_VENDOR must be set}"
: "${BUILD_DATE:?BUILD_DATE must be set}"
: "${BUILD_ID:?BUILD_ID must be set}"

echo "=============================================="
echo "AVISBLUE: applying identity + signing + services"
echo "  IMAGE_NAME=${IMAGE_NAME}"
echo "  BUILD_DATE=${BUILD_DATE}"
echo "  BUILD_ID=${BUILD_ID}"
echo "=============================================="

# Derive flavor + variant from image name
case "$IMAGE_NAME" in
    avisblue-main)
        FLAVOR="main"
        VARIANT="Main"
        BASE_IMAGE_NAME="bazzite"
        ;;
    avisblue-nvidia-gaming)
        FLAVOR="nvidia-gaming"
        VARIANT="NVIDIA Gaming"
        BASE_IMAGE_NAME="bazzite-nvidia"
        ;;
    *)
        echo "ERROR: Unknown IMAGE_NAME: $IMAGE_NAME" >&2
        exit 1
        ;;
esac

# Read inherited Fedora version
FEDORA_VERSION=$(. /usr/lib/os-release && echo "$VERSION_ID")
IMAGE_VERSION="${FEDORA_VERSION}.${BUILD_DATE}"

#####################################################
# 1. Patch /usr/lib/os-release
#    KEEP ID=fedora (matches Bazzite/Bluefin/Aurora convention).
#    Set IMAGE_ID, PRETTY_NAME, VARIANT, VARIANT_ID instead.
#####################################################

echo "--- Patching /usr/lib/os-release ---"

OS_RELEASE=/usr/lib/os-release

# In-place sed updates for fields that already exist.
# ANSI_COLOR=0;34 is VISION §1's deep-blue placeholder; refine to a logo-derived
# palette once the sparrow-silhouette SVG asset exists.
sed -i \
    -e "s|^NAME=.*|NAME=\"Avisblue\"|" \
    -e "s|^PRETTY_NAME=.*|PRETTY_NAME=\"Avisblue ${VARIANT} (${IMAGE_VERSION})\"|" \
    -e "s|^CPE_NAME=.*|CPE_NAME=\"cpe:/o:elgorrion:avisblue:${FEDORA_VERSION}\"|" \
    -e "s|^ANSI_COLOR=.*|ANSI_COLOR=\"0;34\"|" \
    -e "s|^HOME_URL=.*|HOME_URL=\"https://github.com/elgorrion/avisblue\"|" \
    -e "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"https://github.com/elgorrion/avisblue\"|" \
    -e "s|^SUPPORT_URL=.*|SUPPORT_URL=\"https://github.com/elgorrion/avisblue/issues/\"|" \
    -e "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"https://github.com/elgorrion/avisblue/issues/\"|" \
    -e "s|^LOGO=.*|LOGO=avisblue-logo|" \
    -e "/^REDHAT_BUGZILLA_PRODUCT=/d" \
    -e "/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d" \
    -e "/^REDHAT_SUPPORT_PRODUCT=/d" \
    -e "/^REDHAT_SUPPORT_PRODUCT_VERSION=/d" \
    "$OS_RELEASE"

# Strip any prior IMAGE_*, BUILD_ID, VARIANT*, OSTREE_VERSION fields (idempotent)
sed -i \
    -e "/^IMAGE_ID=/d" \
    -e "/^IMAGE_VERSION=/d" \
    -e "/^BUILD_ID=/d" \
    -e "/^VARIANT=/d" \
    -e "/^VARIANT_ID=/d" \
    -e "/^OSTREE_VERSION=/d" \
    -e "/^DEFAULT_HOSTNAME=/d" \
    "$OS_RELEASE"

# Append Avisblue-specific fields
cat >> "$OS_RELEASE" <<EOF
VARIANT="${VARIANT}"
VARIANT_ID=${FLAVOR}
IMAGE_ID="${IMAGE_NAME}"
IMAGE_VERSION="${IMAGE_VERSION}"
OSTREE_VERSION='${IMAGE_VERSION}'
BUILD_ID="${BUILD_ID}"
DEFAULT_HOSTNAME="avisblue"
EOF

echo "Patched os-release. New PRETTY_NAME:"
grep ^PRETTY_NAME "$OS_RELEASE"

#####################################################
# 2. Write /etc/system-release
#    Used by GRUB boot menu entry generation.
#####################################################

echo "--- Writing /etc/system-release ---"
echo "Avisblue release ${FEDORA_VERSION} (${VARIANT})" > /etc/system-release

#####################################################
# 3. Write /usr/share/ublue-os/image-info.json
#    Bluefin convention; ships as machine-readable metadata.
#####################################################

echo "--- Writing /usr/share/ublue-os/image-info.json ---"
mkdir -p /usr/share/ublue-os
cat > /usr/share/ublue-os/image-info.json <<EOF
{
  "image-name": "avisblue",
  "image-flavor": "${FLAVOR}",
  "image-vendor": "${IMAGE_VENDOR}",
  "image-ref": "ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}",
  "image-tag": "latest",
  "base-image-name": "${BASE_IMAGE_NAME}",
  "fedora-version": "${FEDORA_VERSION}"
}
EOF

#####################################################
# 4. Merge ghcr.io/elgorrion entry into the inherited policy.json
#    ublue-os-signing has shipped policy.json at both /etc/containers/ and
#    /usr/etc/containers/ over time. Read from wherever it exists; always
#    write the merged result to /etc/containers/ so it takes precedence at
#    runtime regardless of where the inherited copy lives.
#####################################################

echo "--- Merging policy.json ---"

# jq is required; install if Bazzite doesn't ship it
if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found; installing..."
    dnf5 -y install jq
fi

# Locate inherited policy.json
SRC_POLICY=""
for candidate in /etc/containers/policy.json /usr/etc/containers/policy.json; do
    if [[ -f "$candidate" ]]; then
        SRC_POLICY="$candidate"
        break
    fi
done

if [[ -z "$SRC_POLICY" ]]; then
    echo "ERROR: no policy.json found in /etc/containers/ or /usr/etc/containers/"
    echo "Diagnostic listing:"
    ls -la /etc/containers/ 2>/dev/null || echo "  (no /etc/containers)"
    ls -la /usr/etc/containers/ 2>/dev/null || echo "  (no /usr/etc/containers)"
    exit 1
fi

echo "Using inherited policy.json from: $SRC_POLICY"

DST_POLICY=/etc/containers/policy.json
mkdir -p /etc/containers

# Add our entry. Assignment, not replacement of the parent object — preserves
# all other entries (ublue-os, RedHat, quay toolbx, catch-all).
jq '.transports.docker["ghcr.io/elgorrion"] = [
    {
        "type": "sigstoreSigned",
        "keyPath": "/etc/pki/containers/avisblue.pub",
        "signedIdentity": {"type": "matchRepoDigestOrExact"}
    }
]' "$SRC_POLICY" > "${DST_POLICY}.new"

# Validate before committing
if ! jq empty "${DST_POLICY}.new"; then
    echo "ERROR: merged policy.json is not valid JSON"
    rm -f "${DST_POLICY}.new"
    exit 1
fi

mv "${DST_POLICY}.new" "$DST_POLICY"

echo "Merged policy.json written to $DST_POLICY. Top-level docker transports:"
jq '.transports.docker | keys' "$DST_POLICY"

#####################################################
# 5. Enable avisblue-flatpak-manager.service
#    Service unit ships via system_files; we only need to enable it here.
#####################################################

echo "--- Enabling avisblue-flatpak-manager.service ---"

if [[ -f /usr/lib/systemd/system/avisblue-flatpak-manager.service ]]; then
    systemctl enable avisblue-flatpak-manager.service
    echo "avisblue-flatpak-manager.service enabled."
else
    echo "WARNING: avisblue-flatpak-manager.service unit not found; skipping enable."
fi

echo ""
echo "=============================================="
echo "AVISBLUE customization complete"
echo "=============================================="
