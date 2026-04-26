# Avisblue

Custom [Universal Blue](https://universal-blue.org/) distro based on [Bazzite](https://bazzite.gg/).

## Images

| Image | Base | Features |
|-------|------|----------|
| `avisblue-main` | `bazzite:stable` (Mesa) | Dev (host); AMD compute via containers |
| `avisblue-nvidia-gaming` | `bazzite-nvidia-open:stable` | Gaming + Dev (host); CUDA via containers |

GPU compute is intentionally container-only: the host exposes hardware (kernel modules, container toolkit, auto-CDI), workloads (CUDA, ROCm, PyTorch, etc.) live in containers.

## Installation

### Fresh Install (ISO)

Download ISO from [Releases](https://github.com/elgorrion/avisblue/releases) and install.

### Rebase from Fedora Atomic

Both images are signed with [cosign](https://docs.sigstore.dev/cosign/) using the public key shipped at `/etc/pki/containers/avisblue.pub` inside the image. The `--enforce-container-sigpolicy` flag below makes `bootc` refuse to deploy an image whose signature doesn't verify against that key.

```bash
# For AMD/Intel GPU
sudo bootc switch --enforce-container-sigpolicy ghcr.io/elgorrion/avisblue-main:latest

# For NVIDIA GPU + Gaming
sudo bootc switch --enforce-container-sigpolicy ghcr.io/elgorrion/avisblue-nvidia-gaming:latest
```

## Post-Install Setup

```bash
# 1. Connect to fleet
sudo tailscale up --accept-routes --operator=$USER

# 2. Install Homebrew packages
brew install chezmoi starship direnv
brew install bat eza fd ripgrep git-delta gh glab fzf

# 3. Apply dotfiles
chezmoi init --apply --ssh <your-github-username>

# 4. Install Claude Code
curl -fsSL https://claude.ai/install.sh | sh
```

## What's Included

### Both Images

| Category | Packages |
|----------|----------|
| KDE Apps | kate, okular, gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd, konsole, chromium |
| Dev Tools | VSCode, podman-docker, podman-compose, qemu-kvm, libvirt |
| Cockpit | cockpit-system, cockpit-podman, cockpit-storaged, cockpit-machines, cockpit-ostree |
| System | Bazzite kernel (HDR, winesync), Tailscale, Homebrew, Distrobox |
| Display | Wayland-only (SDDM + kwin_wayland), XWayland for legacy apps |

### avisblue-main (Mesa)

- AMD compute via containers — `amdgpu` kernel module on host; user in `render`+`video` groups; pass `--device /dev/kfd --device /dev/dri` to your workload container (e.g. `docker.io/rocm/pytorch`)
- No gaming packages (stripped)
- Zero Flatpaks

### avisblue-nvidia-gaming (NVIDIA, open kernel modules)

- NVIDIA stack from `bazzite-nvidia-open:stable`: open kernel modules + `nvidia-container-toolkit` + `ublue-nvctk-cdi.service` (auto-generates `/etc/cdi/nvidia.yaml` at boot)
- GPU in containers: `podman run --rm --device nvidia.com/gpu=all nvcr.io/nvidia/cuda:12.5.0-base-ubi9 nvidia-smi`
- Gaming: Steam, Gamescope, MangoHud, vkBasalt (from Bazzite)
- Gaming extras: OpenRGB
- Flatpaks: ProtonUp-Qt and ScopeBuddy install automatically on first boot via `avisblue-flatpak-manager.service` (idempotent, version-gated). The list lives at `/usr/share/avisblue/flatpaks-nvidia-gaming.list`.

## Building Locally

```bash
# Build main
podman build -f Containerfile.main -t avisblue-main:local .

# Build nvidia-gaming
podman build -f Containerfile.nvidia-gaming -t avisblue-nvidia-gaming:local .
```

## Architecture

```
Bazzite (upstream)
├── avisblue-main  ← bazzite:stable
│   ├── Strip gaming/handheld
│   ├── Strip GTK Flatpaks
│   ├── Fleet config + Wayland-only
│   ├── KDE apps (RPMs)
│   └── Dev tools + Cockpit
│
└── avisblue-nvidia-gaming  ← bazzite-nvidia-open:stable
    ├── Strip handheld (keep gaming)
    ├── Strip GTK Flatpaks
    ├── Fleet config + Wayland-only
    ├── KDE apps (RPMs)
    ├── Dev tools + Cockpit
    └── Gaming extras (OpenRGB)
```

## Fleet Management

Access Cockpit at `https://machine:9090` for:
- System monitoring and logs
- Podman container management
- VM management (libvirt)
- rpm-ostree deployments and rollback
- Storage/Btrfs management

## License

MIT
