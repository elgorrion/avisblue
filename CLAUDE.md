# CLAUDE.md - Avisblue

Clean Universal Blue distro based on **Aurora-dx**, for a small personal fleet.
Daily driver + development (Python/TS) + gaming (Steam), on one image, two GPU
flavors. **Read [VISION.md](VISION.md) first — it's the constitution.**

## Philosophy (the short version)

Avisblue 2.x builds **up** from a clean KDE developer desktop (Aurora-dx); it no
longer strips **down** a gaming OS (Bazzite). The image is minimal; mutable
concerns live elsewhere (VISION §4): language toolchains via Homebrew (per-user,
not baked), project envs in devcontainers/distrobox, GUI apps in Flatpak, CLI in
Homebrew, dotfiles in chezmoi, GPU compute in workload containers.

## Images

| Image | Base | Hardware |
|-------|------|----------|
| `avisblue`        | `ghcr.io/ublue-os/aurora-dx:stable`             | AMD / Intel (Mesa) |
| `avisblue-nvidia` | `ghcr.io/ublue-os/aurora-dx-nvidia-open:stable` | NVIDIA (open modules) |

The two images differ **only** by GPU (VISION §9.7). Daily-driver apps, the dev
layer, and gaming (Steam via Flatpak) are identical on both.

**Inherited from Aurora-dx (do NOT re-add):** KDE Plasma 6 / Wayland, VS Code,
Docker **and** Podman, Incus, libvirt/virt-manager, Cockpit, distrobox,
Homebrew, Tailscale, Flatpak+Flathub, `ublue-update`. On `-nvidia`: open kernel
modules + `nvidia-container-toolkit` + auto-CDI.

**Avisblue adds (the thin layer):** identity/branding, fleet config, curated Qt
apps + Chromium, Cockpit fleet extensions, first-boot gaming Flatpaks, cosign
signing policy. **No baked language runtimes / `mise`** — toolchains are
per-user via Homebrew (VISION §4).

**GPU compute (VISION §9.5):** host exposes hardware; SDKs (CUDA, ROCm, PyTorch)
live in workload containers — `podman run --device nvidia.com/gpu=all …` on
NVIDIA; `--device /dev/kfd --device /dev/dri` into `rocm/pytorch` on AMD.

## Build Commands

```bash
# Local build
podman build -f Containerfile -t avisblue:local .
podman build -f Containerfile.nvidia -t avisblue-nvidia:local .
# or: just build-all

# CI
gh workflow run build.yml       # build + sign both images
gh workflow run release.yml     # build ISOs + publish
gh run list --repo elgorrion/avisblue
```

## Architecture

- **Base:** Aurora-dx on Fedora Atomic KDE (Kinoite). Tracks `:stable`; follows
  upstream Fedora bumps automatically via inherited os-release `VERSION_ID`.
- **Desktop:** KDE Plasma 6, Wayland-only (SDDM + kwin_wayland, XWayland for
  legacy apps).
- **Updates:** automatic via `ublue-update`.
- **Management:** Cockpit web console on `:9090`; fleet network via Tailscale.
- **Build pattern:** `FROM scratch AS ctx` with bind mounts; `bootc container
  lint` validation; cosign signing; smoke test + signature-chain verify in CI;
  auto-revert on red scheduled builds.

## File Structure

```
VISION.md                       # The constitution — read first
Containerfile                   # Aurora-dx (AMD/Intel) — base image: avisblue
Containerfile.nvidia            # Aurora-dx NVIDIA (open) — avisblue-nvidia
build_files/shared/
├── 10-trim.sh                  # Minimal, lenient trim of the Aurora-dx base
├── 20-fleet-config.sh          # Locale, SSH, Tailscale, shell skel
├── 25-wayland-only.sh          # Remove X11 sessions, Wayland-only
├── 30-kde-apps.sh              # Curated KDE RPMs + Chromium
├── 40-dev-tools.sh             # Cockpit fleet extensions (dev substrate is inherited)
├── 80-avisblue.sh              # Identity, signing-policy merge, service enable
├── 85-branding.sh              # Logos neutralization, Plymouth, variant patch
└── 90-finalize.sh              # Validation, telemetry mask, cleanup
system_files/                   # Branding, signing, services, skel (COPYed to /)
└── usr/share/avisblue/
    ├── flatpaks-main.list      # First-boot gaming Flatpaks (Steam set)
    └── flatpaks-nvidia.list    # Same set (gaming is universal — VISION §5)
disk_config/                    # bootc-image-builder configs (ISO)
.github/workflows/build.yml     # CI/CD (build + cosign + smoke + verify + revert)
.github/workflows/release.yml   # ISO build + publish
```

## Conventions for editing

- **Follow upstream, don't fight it.** Aurora-dx is the source of the dev/desktop
  substrate. If you find yourself re-adding what Aurora ships, stop.
- **Trim is lenient, never strict.** `10-trim.sh` must not hard-fail on a missing
  package — we're not dismantling the base (contrast: the deleted Bazzite-era
  `cleanup/` scripts used strict drift detection).
- **Don't bake mutable state.** No layered language runtimes, no project tooling.
  See VISION §4 for where each concern belongs.
- **Keep the two images symmetric.** Anything not GPU-specific goes in `shared/`
  and applies to both.
- Scripts are shellcheck-clean (CI gate, severity=warning).

## Rebase

Images are cosign-signed (key at `/etc/pki/containers/avisblue.pub`);
`--enforce-container-sigpolicy` enforces verification.

```bash
# AMD/Intel GPU
sudo bootc switch --enforce-container-sigpolicy ghcr.io/elgorrion/avisblue:latest

# NVIDIA GPU
sudo bootc switch --enforce-container-sigpolicy ghcr.io/elgorrion/avisblue-nvidia:latest
```

## Related

- [VISION.md](VISION.md) — design constitution
- [dotfiles](https://github.com/elgorrion/dotfiles) — user environment via chezmoi
- [Aurora](https://getaurora.dev/) — base image
- [Universal Blue](https://universal-blue.org/) — upstream project
