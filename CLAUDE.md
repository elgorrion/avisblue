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
- **Updates:** Automatic via ublue-update

## File Structure

```
Containerfile.main              # Mesa + Dev + ROCm
Containerfile.nvidia-gaming     # NVIDIA + Gaming + Dev + CUDA
build_files/
├── shared/
│   ├── strip-bazzite.sh        # Remove gaming/handheld from main
│   ├── strip-bazzite-handheld.sh  # Remove handheld only (keep gaming)
│   ├── strip-upstream.sh       # Remove bloat from ublue-main + Bazzite
│   ├── strip-flatpaks.sh       # Remove ALL Bazzite Flatpaks
│   ├── fleet-config.sh         # Locale, SSH, Tailscale
│   ├── kde-apps.sh             # KDE RPMs (kate, okular, etc.)
│   ├── dev-tools.sh            # VSCode, podman, libvirt
│   └── finalize.sh             # Cleanup, ostree seal
└── roles/
    ├── gaming.sh               # OpenRGB, ProtonUp-Qt, BoxBuddy
    ├── rocm.sh                 # ROCm runtime (AMD compute)
    └── cuda.sh                 # nvidia-container-toolkit
system_files/                   # Files copied into image
.github/workflows/build.yml     # CI/CD (build + cosign)
```

## Packages

### Both Images

| Category | Packages |
|----------|----------|
| KDE Apps | kate, okular, gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd |
| Dev | code, podman-docker, docker-compose, qemu-kvm, libvirt, virt-manager |
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
