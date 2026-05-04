# CLAUDE.md - Avisblue

Custom Universal Blue distro based on Bazzite.

## Images

| Image | Base | Contents |
|-------|------|----------|
| `avisblue-main` | `bazzite:stable` | Mesa + Dev (host) — AMD compute via containers |
| `avisblue-nvidia-gaming` | `bazzite-nvidia-open:stable` | NVIDIA (open) + Gaming + Dev (host) — CUDA via containers |

Both images include: KDE apps (RPMs), VSCode, podman, libvirt, Tailscale, Homebrew.

**GPU-exposure principle (VISION §5):** the host exposes hardware (kernel modules, container toolkit, auto-CDI on NVIDIA); compute SDKs (CUDA, ROCm, PyTorch) live in workload containers. Bazzite April 2026 moved ROCm out of `bazzite:stable` into `bazzite-dx`; we follow upstream and don't add it back. `bazzite-nvidia-open` already ships `nvidia-container-toolkit` + `ublue-nvctk-cdi.service`, so no host-side CUDA tooling either.

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

- **Base:** Bazzite on Fedora 44 (`bazzite:stable` / `bazzite-nvidia-open:stable`) — Avisblue tracks `${FEDORA_VERSION}` from inherited os-release, so it follows upstream Fedora bumps automatically.
- **Kernel:** bazzite-kernel (HDR, winesync, LAVD/BORE schedulers)
- **Desktop:** KDE Plasma 6.6 (pure Qt - no GTK apps)
- **Display:** Wayland-only (SDDM + kwin_wayland, XWayland for legacy apps)
- **Updates:** Automatic via ublue-update
- **Management:** Cockpit web console on :9090
- **Build pattern:** `FROM scratch AS ctx` with bind mounts, `bootc container lint` validation

## File Structure

```
Containerfile.main              # Mesa + Dev (host)
Containerfile.nvidia-gaming     # NVIDIA (open) + Gaming + Dev (host)
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
    └── 50-gaming.sh            # OpenRGB only (Flatpaks first-boot)
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

- AMD compute: container-only (no host ROCm userspace). Host has `amdgpu` kernel module via `bazzite-kernel`; pass `/dev/kfd` + `/dev/dri` into compute containers (`docker.io/rocm/pytorch` etc.).
- Flatpaks: NONE (zero)

### avisblue-nvidia-gaming (NVIDIA, open)

- NVIDIA stack inherited from `bazzite-nvidia-open`: open kernel modules, `nvidia-container-toolkit`, `ublue-nvctk-cdi.service` (auto-generates `/etc/cdi/nvidia.yaml` at boot).
- CUDA: container-only. Use `podman run --device nvidia.com/gpu=all <image>` (NOT Docker-style `--gpus all`).
- Gaming: Steam, Gamescope, MangoHud, vkBasalt (from Bazzite)
- Gaming extras: OpenRGB
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
