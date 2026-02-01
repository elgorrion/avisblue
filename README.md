# Avisblue

Custom [Universal Blue](https://universal-blue.org/) distro for CASA fleet, based on [Bazzite](https://bazzite.gg/).

## Images

| Image | Base | Targets | Features |
|-------|------|---------|----------|
| `avisblue-main` | Bazzite (Mesa) | enviada-nb, btecnb-vona | Dev + ROCm |
| `avisblue-nvidia-gaming` | Bazzite-NVIDIA | wueesixx-pc, elgorrion-pc | Gaming + Dev + CUDA |

## Installation

### Fresh Install (ISO)

Download ISO from [Releases](https://github.com/elgorrion/avisblue/releases) and install.

### Rebase from Fedora Atomic

```bash
# For AMD/Intel GPU
sudo bootc switch ghcr.io/elgorrion/avisblue-main:latest

# For NVIDIA GPU + Gaming
sudo bootc switch ghcr.io/elgorrion/avisblue-nvidia-gaming:latest
```

## Post-Install Setup

```bash
# 1. Connect to fleet
sudo tailscale up --accept-routes --operator=$USER

# 2. Install Homebrew packages
brew install chezmoi starship direnv
brew install bat eza fd ripgrep git-delta gh glab fzf

# 3. Apply dotfiles
chezmoi init --apply --ssh elgorrion

# 4. Install Claude Code
curl -fsSL https://claude.ai/install.sh | sh
```

## What's Included

### Both Images

| Category | Packages |
|----------|----------|
| KDE Apps | kate, okular, gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd, konsole |
| Dev Tools | VSCode, podman-docker, podman-compose, qemu-kvm, libvirt |
| Cockpit | cockpit-system, cockpit-podman, cockpit-storaged, cockpit-machines, cockpit-ostree |
| System | Bazzite kernel (HDR, winesync), Tailscale, Homebrew, Distrobox |
| Display | Wayland-only (SDDM + kwin_wayland), XWayland for legacy apps |

### avisblue-main (Mesa)

- ROCm for AMD compute (rocm-hip, rocm-opencl, rocm-smi)
- No gaming packages (stripped)
- Zero Flatpaks

### avisblue-nvidia-gaming (NVIDIA)

- Gaming: Steam, Gamescope, MangoHud, vkBasalt (from Bazzite)
- Gaming extras: OpenRGB
- CUDA: nvidia-container-toolkit
- Flatpaks: ProtonUp-Qt, BoxBuddy (Qt only)

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
├── avisblue-main
│   ├── Strip gaming/handheld
│   ├── Strip GTK Flatpaks
│   ├── Fleet config + Wayland-only
│   ├── KDE apps (RPMs)
│   ├── Dev tools + Cockpit
│   └── ROCm
│
└── avisblue-nvidia-gaming
    ├── Strip handheld (keep gaming)
    ├── Strip GTK Flatpaks
    ├── Fleet config + Wayland-only
    ├── KDE apps (RPMs)
    ├── Dev tools + Cockpit
    ├── Gaming extras
    └── CUDA
```

## Fleet Management

Access Cockpit at `http://machine:9090` for:
- System monitoring and logs
- Podman container management
- VM management (libvirt)
- rpm-ostree deployments and rollback
- Storage/Btrfs management

## License

MIT
