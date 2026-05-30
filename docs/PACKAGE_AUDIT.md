# Avisblue Package Model

> **Avisblue 2.x** is based on **Aurora-dx**, not Bazzite. The old Bazzite
> layer-by-layer package audit (a strip-down accounting) no longer applies and
> has been removed. The model is now additive, not subtractive — see
> [VISION.md](../VISION.md) §0–§4.

## How to read the package set

There is no hand-maintained package table anymore (it drifted constantly and
lied). The **live build files are the source of truth**:

| Question | Source of truth |
|----------|-----------------|
| What does the base ship? | Aurora-dx (`ghcr.io/ublue-os/aurora-dx{,-nvidia-open}:stable`) — see [getaurora.dev](https://getaurora.dev/) |
| What do we trim? | `build_files/shared/10-trim.sh` (a short, lenient list) |
| What KDE apps do we add? | `build_files/shared/30-kde-apps.sh` |
| What dev/fleet tooling do we add? | `build_files/shared/40-dev-tools.sh` (Cockpit extensions; dev substrate is inherited) |
| What Flatpaks install first-boot? | `system_files/usr/share/avisblue/flatpaks-*.list` |

## The additive layer (summary)

Aurora-dx already provides the desktop + developer substrate (KDE Plasma 6,
VS Code, Docker+Podman, Incus, libvirt, Cockpit, distrobox, Homebrew, Tailscale,
Flatpak). Avisblue adds only:

- **Trim (constitutional only):** non-English IMEs/fonts, alternative shells
  (fish/zsh), duplicate monitors (htop/nvtop), the Firefox flatpak. All lenient.
- **KDE apps (RPM):** kate, okular, gwenview, ark, kcalc, spectacle,
  partitionmanager, kdeconnectd, konsole, chromium.
- **Dev/fleet:** `cockpit-machines`, `cockpit-ostree`. (Dev substrate — VS Code,
  Docker/Podman, libvirt — is inherited from Aurora-dx; language runtimes come
  from Homebrew per-user, not baked.)
- **Gaming (Flatpak, first-boot, both images):** `com.valvesoftware.Steam`
  (+ MangoHud + Gamescope utilities), `net.davidotek.pupgui2` (ProtonUp-Qt).

## What is deliberately NOT in the image

Language runtimes (use Homebrew), project deps (use devcontainers/distrobox),
most GUI apps (use Flatpak), CLI tools (use Homebrew), GPU compute SDKs (use
workload containers). See VISION §4.
