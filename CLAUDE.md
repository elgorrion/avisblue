# CLAUDE.md - Avisblue

Custom Universal Blue distro for CASA fleet, based on Bazzite.

## Quick Reference

| Image | Target Machine | Base |
|-------|----------------|------|
| avisblue-main | enviada-nb | Bazzite (Mesa) |
| avisblue-main-dev | btecnb-vona | + VSCode, ROCm |
| avisblue-nvidia-gaming | wueesixx-pc | Bazzite-NVIDIA |
| avisblue-nvidia-gaming-dev | elgorrion-pc | + VSCode, CUDA |

## Build Commands

```bash
# Local build
just build-all

# Trigger GitHub Actions build
gh workflow run build.yml

# Check build status
gh run list --repo elgorrion/avisblue
```

## Architecture

- **Base:** Bazzite (bazzite:stable / bazzite-nvidia:stable)
- **Kernel:** bazzite-kernel (HDR, winesync, LAVD/BORE schedulers)
- **Desktop:** KDE Plasma 6 + Valve SteamOS themes
- **Updates:** Automatic via ublue-update

## File Structure

```
Containerfile.{variant}     # Image definitions
build_files/
├── shared/                 # Common scripts (strip, fleet-config, finalize)
└── roles/                  # Role scripts (gaming, dev, rocm, cuda)
system_files/               # Files copied into image
.github/workflows/          # CI/CD
```

## Roles

| Role | Script | Adds |
|------|--------|------|
| gaming | roles/gaming.sh | OpenRGB, ProtonUp-Qt (Flatpak) |
| dev | roles/dev.sh | VSCode, podman-docker, libvirt |
| rocm | roles/rocm.sh | ROCm runtime (AMD compute) |
| cuda | roles/cuda.sh | nvidia-container-toolkit |

## Verification

```bash
# Verify image signature
cosign verify --key cosign.pub ghcr.io/elgorrion/avisblue-main:latest
```

## Related

- [CASA-Admin](../CASA-Admin/) - Fleet documentation (archived)
- [dotfiles](https://github.com/elgorrion/dotfiles) - User environment via chezmoi
- [Universal Blue](https://universal-blue.org/) - Upstream project
- [Bazzite](https://bazzite.gg/) - Base image
