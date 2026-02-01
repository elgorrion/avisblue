#!/usr/bin/env bash
# rocm.sh - ROCm role for AMD compute (inference only)

set -euo pipefail

echo "=== Installing ROCm role packages ==="

# ROCm packages for inference (minimal, no dev headers/compilers)
echo "Installing ROCm runtime packages..."
dnf5 -y install \
    rocm-hip \
    rocm-opencl \
    rocm-clinfo \
    rocm-smi

# Note: For full development toolkit, user can install additional packages:
# dnf5 install rocm-hip-devel rocm-opencl-devel

echo "=== ROCm role complete ==="
echo "Verify with: rocm-smi"
