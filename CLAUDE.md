# CLAUDE.md - Avisblue

Custom Universal Blue distro based on Bazzite.

## Images

| Image | Contents |
|-------|----------|
| `avisblue-main` | Mesa + Dev + ROCm |
| `avisblue-nvidia-gaming` | NVIDIA + Gaming + Dev + CUDA |

Both images include: KDE apps (RPMs), VSCode, podman, libvirt, Tailscale, Homebrew.

## Build Commands

```bash
# Local build
podman build -f Containerfile.main -t avisblue-main:local .
podman build -f Containerfile.nvidia-gaming -t avisblue-nvidia-gaming:local .

# Trigger GitHub Actions build
gh workflow run build.yml

# Trigger release (builds ISOs + creates GitHub Release)
gh workflow run release.yml

# Check build/release status
gh run list --repo elgorrion/avisblue
gh run watch <run-id>

# List releases
gh release list
```

## Architecture

- **Base:** Bazzite on Fedora 43 (bazzite:stable / bazzite-nvidia:stable)
- **Kernel:** bazzite-kernel (HDR, winesync, LAVD/BORE schedulers)
- **Desktop:** KDE Plasma 6.6 (pure Qt - no GTK apps)
- **Display:** Wayland-only (SDDM + kwin_wayland, XWayland for legacy apps)
- **Updates:** Automatic via ublue-update
- **Management:** Cockpit web console on :9090
- **Build pattern:** `FROM scratch AS ctx` with bind mounts, `bootc container lint` validation

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
│   ├── 80-avisblue.sh          # Identity, signing-policy merge, service enablement
│   └── 90-finalize.sh          # Validation, cleanup
└── roles/
    ├── 50-rocm.sh              # ROCm runtime (AMD compute)
    ├── 50-gaming.sh            # OpenRGB only (Flatpaks first-boot)
    └── 60-cuda.sh              # nvidia-container-toolkit
system_files/
├── etc/
│   ├── cockpit/cockpit.conf
│   ├── containers/registries.d/elgorrion.yaml   # sigstore lookup for ghcr.io/elgorrion
│   ├── locale.conf
│   ├── pki/containers/avisblue.pub              # signing pubkey shipped to image
│   └── sddm.conf.d/10-wayland.conf
└── usr/
    ├── lib/systemd/system/avisblue-flatpak-manager.service
    ├── libexec/avisblue-flatpak-manager         # idempotent flatpak installer
    └── share/avisblue/                          # flatpak lists per flavor
        ├── flatpaks-main.list
        └── flatpaks-nvidia-gaming.list
.github/workflows/build.yml     # CI/CD (build + cosign)
.github/workflows/release.yml   # ISO build + GitHub Release (30-day retention)
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
- Flatpaks: ProtonUp-Qt + ScopeBuddy installed first-boot by `avisblue-flatpak-manager.service` (list at `/usr/share/avisblue/flatpaks-nvidia-gaming.list`)

## Rebase

Images are signed with cosign (key at `/etc/pki/containers/avisblue.pub`); `--enforce-container-sigpolicy` enforces verification.

```bash
# For AMD/Intel GPU
sudo bootc switch --enforce-container-sigpolicy ghcr.io/elgorrion/avisblue-main:latest

# For NVIDIA GPU
sudo bootc switch --enforce-container-sigpolicy ghcr.io/elgorrion/avisblue-nvidia-gaming:latest
```

## Related

- [dotfiles](https://github.com/elgorrion/dotfiles) - User environment via chezmoi
- [Universal Blue](https://universal-blue.org/) - Upstream project
- [Bazzite](https://bazzite.gg/) - Base image
