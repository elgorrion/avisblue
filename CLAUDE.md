# CLAUDE.md - Avisblue

Custom Universal Blue distro for CASA fleet, based on Bazzite.

## Images

| Image | Targets | Contents |
|-------|---------|----------|
| `avisblue-main` | enviada-nb, btecnb-vona | Mesa + Dev + ROCm |
| `avisblue-nvidia-gaming` | wueesixx-pc, elgorrion-pc | NVIDIA + Gaming + Dev + CUDA |

Both images include: KDE apps (RPMs), VSCode, podman, libvirt, Tailscale, Homebrew.

## Build Commands

```bash
# Local build
podman build -f Containerfile.main -t avisblue-main:local .
podman build -f Containerfile.nvidia-gaming -t avisblue-nvidia-gaming:local .

# Trigger GitHub Actions build
gh workflow run build.yml

# Check build status
gh run list --repo elgorrion/avisblue
gh run watch <run-id>
```

## Architecture

- **Base:** Bazzite (bazzite:stable / bazzite-nvidia:stable)
- **Kernel:** bazzite-kernel (HDR, winesync, LAVD/BORE schedulers)
- **Desktop:** KDE Plasma 6 (pure Qt - no GTK apps)
- **Display:** Wayland-only (SDDM + kwin_wayland, XWayland for legacy apps)
- **Updates:** Automatic via ublue-update
- **Management:** Cockpit web console on :9090

## File Structure

```
Containerfile.main              # Mesa + Dev + ROCm
Containerfile.nvidia-gaming     # NVIDIA + Gaming + Dev + CUDA
build_files/
├── cleanup/
│   ├── 10-cleanup-main.sh           # Remove gaming/handheld/bloat
│   └── 10-cleanup-nvidia-gaming.sh  # Remove handheld/bloat (keep gaming)
├── shared/
│   ├── 20-fleet-config.sh      # Locale, SSH, Tailscale, Wayland env
│   ├── 25-wayland-only.sh      # Remove X11 sessions, Wayland-only
│   ├── 30-kde-apps.sh          # KDE RPMs + Chromium browser
│   ├── 40-dev-tools.sh         # VSCode, podman, libvirt, Cockpit
│   └── 90-finalize.sh          # Validation, cleanup, ostree seal
└── roles/
    ├── 50-rocm.sh              # ROCm runtime (AMD compute)
    ├── 50-gaming.sh            # OpenRGB, ProtonUp-Qt, BoxBuddy
    └── 60-cuda.sh              # nvidia-container-toolkit
system_files/
└── etc/sddm.conf.d/
    └── 10-wayland.conf         # SDDM Wayland + kwin_wayland
.github/workflows/build.yml     # CI/CD (build + cosign)
```

## Packages

### Both Images

| Category | Packages |
|----------|----------|
| KDE Apps | kate, okular, gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd, konsole, chromium |
| Dev | code, podman-docker, podman-compose, qemu-kvm, libvirt |
| Cockpit | cockpit-system, cockpit-podman, cockpit-storaged, cockpit-machines, cockpit-ostree |
| System | Bazzite kernel, Tailscale, Homebrew, Distrobox |

### avisblue-main (Mesa)

- ROCm: rocm-hip, rocm-opencl, rocm-clinfo, rocm-smi
- Flatpaks: NONE (zero)

### avisblue-nvidia-gaming (NVIDIA)

- Gaming: Steam, Gamescope, MangoHud, vkBasalt (from Bazzite)
- Gaming extras: OpenRGB
- CUDA: nvidia-container-toolkit
- Flatpaks: ProtonUp-Qt, BoxBuddy (Qt only)

## Rebase

```bash
# For AMD/Intel GPU
sudo bootc switch ghcr.io/elgorrion/avisblue-main:latest

# For NVIDIA GPU
sudo bootc switch ghcr.io/elgorrion/avisblue-nvidia-gaming:latest
```

## Related

- [dotfiles](https://github.com/elgorrion/dotfiles) - User environment via chezmoi
- [Universal Blue](https://universal-blue.org/) - Upstream project
- [Bazzite](https://bazzite.gg/) - Base image
