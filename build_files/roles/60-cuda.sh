#!/usr/bin/env bash
# cuda.sh - CUDA role for NVIDIA compute (inference/containers)
# Target: elgorrion-pc (RTX 4080)

set -euo pipefail

echo "=== Installing CUDA role packages ==="

# nvidia-container-toolkit for containerized AI workloads
echo "Installing nvidia-container-toolkit..."

# Add NVIDIA container toolkit repo
dnf5 -y config-manager addrepo --from-repofile=https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo

dnf5 -y install nvidia-container-toolkit

# Configure container runtime for NVIDIA
echo "Configuring container runtime for NVIDIA..."
nvidia-ctk runtime configure --runtime=docker 2>/dev/null || true
nvidia-ctk runtime configure --runtime=containerd 2>/dev/null || true

# Note: Full CUDA toolkit is large (~5GB). For inference, container-based
# approach is recommended. If user needs local CUDA:
# dnf5 install cuda-toolkit-12-*

echo "=== CUDA role complete ==="
echo "Verify with: nvidia-smi"
echo "For containers: podman run --gpus all nvidia/cuda:12.0-base nvidia-smi"
