# Avisblue

A clean [Universal Blue](https://universal-blue.org/) distro based on
[Aurora-dx](https://getaurora.dev/), for a small personal fleet — daily driver,
development (Python / TypeScript), and gaming (Steam), on one image and two GPU
flavors.

> **Philosophy:** build *up* from a clean KDE developer desktop, don't strip
> *down* a gaming OS. See [VISION.md](VISION.md) for the full constitution.

## Images

| Image | Base | Hardware |
|-------|------|----------|
| `avisblue`        | `aurora-dx:stable`             | AMD / Intel (Mesa) |
| `avisblue-nvidia` | `aurora-dx-nvidia-open:stable` | NVIDIA (open kernel modules) |

The images differ **only** by GPU. Everything else — desktop, dev layer, and
gaming — is identical. GPU *compute* is intentionally container-only: the host
exposes hardware; CUDA / ROCm / PyTorch live in workload containers.

## Installation

### Fresh Install (ISO)

Download an ISO from [Releases](https://github.com/elgorrion/avisblue/releases)
and install.

### Rebase from Fedora Atomic / Aurora

Both images are signed with [cosign](https://docs.sigstore.dev/cosign/) using
the public key shipped at `/etc/pki/containers/avisblue.pub` inside the image.
`--enforce-container-sigpolicy` makes `bootc` refuse any image whose signature
doesn't verify against that key.

```bash
# AMD/Intel GPU
sudo bootc switch --enforce-container-sigpolicy ghcr.io/elgorrion/avisblue:latest

# NVIDIA GPU
sudo bootc switch --enforce-container-sigpolicy ghcr.io/elgorrion/avisblue-nvidia:latest
```

## First-Boot Setup

```bash
# 1. Join the fleet network
sudo tailscale up --accept-routes --operator=$USER

# 2. CLI tools + dev runtimes via Homebrew (inherited from Aurora-dx)
brew install chezmoi starship direnv bat eza fd ripgrep git-delta gh fzf
brew install python node          # or: brew install mise  (per-user toolchains)

# 3. Apply dotfiles
chezmoi init --apply --ssh <your-github-username>
```

Language runtimes are intentionally **not** baked into the image — they're
per-user state (see [VISION.md](VISION.md) §4). Use Homebrew for global tools, or
a devcontainer/distrobox (both ship in the base) for per-project isolation.

Steam and the gaming Flatpaks install automatically on first boot — just launch
Steam from the menu.

## What's Included

### Inherited from Aurora-dx (every machine)

KDE Plasma 6 (Wayland), VS Code, Docker **and** Podman, Incus,
libvirt/virt-manager, Cockpit, distrobox, devcontainers, Homebrew, Tailscale,
Flatpak + Flathub, automatic updates (`ublue-update`). The `-nvidia` image adds
open NVIDIA kernel modules + `nvidia-container-toolkit` + auto-CDI.

### Added by Avisblue (the thin layer)

| Category | What |
|----------|------|
| Fleet | Cockpit extensions (`cockpit-machines`, `cockpit-ostree`), Tailscale + locale config |
| Apps | Curated KDE set (kate, okular, gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd, konsole) + Chromium |
| Gaming | Steam + MangoHud + Gamescope + ProtonUp-Qt, **as Flatpaks**, installed first-boot |
| Identity | Avisblue branding (Plymouth, SDDM, wallpaper, fastfetch, Cockpit) + cosign signing |

### Where everything else lives

Avisblue keeps the image minimal. Mutable, fast-moving things live outside it:

- **Language toolchains** → Homebrew (per-user; `mise` optional via `brew`)
- **Project environments** → devcontainers / distrobox
- **GUI apps** → Flatpak (Flathub)
- **CLI tools** → Homebrew
- **Dotfiles** → chezmoi
- **GPU compute** → workload containers

## Building Locally

```bash
just build           # podman build -f Containerfile         -t avisblue:local .
just build-nvidia    # podman build -f Containerfile.nvidia  -t avisblue-nvidia:local .
just build-all
```

## Architecture

```
Aurora-dx (Universal Blue, KDE developer workstation)
├── avisblue         ← aurora-dx:stable
└── avisblue-nvidia  ← aurora-dx-nvidia-open:stable
        │
        └── shared thin layer:
            ├── 10-trim        minimal constitutional trim (lenient)
            ├── 20-fleet       locale + Tailscale + SSH + shell skel
            ├── 25-wayland     Wayland-only
            ├── 30-kde-apps    curated Qt apps + Chromium
            ├── 40-dev-tools   Cockpit fleet extensions
            ├── 80-avisblue    identity + signing policy + services
            ├── 85-branding    logos + Plymouth + variant
            └── 90-finalize    validation + telemetry mask
```

## Fleet Management

Cockpit at `https://machine:9090` — system monitoring, Podman containers, VM
management (libvirt/machines), `rpm-ostree`/bootc deployments + rollback, and
storage. Machines are reachable over the Tailscale fleet network.

## License

MIT
