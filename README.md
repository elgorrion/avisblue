# Avisblue

Custom [Universal Blue](https://universal-blue.org/) distro for CASA fleet, based on [Bazzite](https://bazzite.gg/).

## Images

| Image | Base | Target | Features |
|-------|------|--------|----------|
| `avisblue-main` | Bazzite (Mesa) | enviada-nb | KDE, Tailscale, Homebrew |
| `avisblue-main-dev` | avisblue-main | btecnb-vona | + VSCode, ROCm, containers |
| `avisblue-nvidia-gaming` | Bazzite-NVIDIA | wueesixx-pc | + Steam, Lutris, OpenRGB |
| `avisblue-nvidia-gaming-dev` | nvidia-gaming | elgorrion-pc | + VSCode, CUDA, containers |

## Installation

### Fresh Install (ISO)

Download ISO from [Releases](https://github.com/elgorrion/avisblue/releases) and install.

### Rebase from Fedora Atomic

```bash
# For AMD/Intel GPU (Mesa)
sudo bootc switch ghcr.io/elgorrion/avisblue-main:latest

# For NVIDIA GPU + Gaming
sudo bootc switch ghcr.io/elgorrion/avisblue-nvidia-gaming:latest
```

## Post-Install Setup

```bash
# 1. Connect to fleet
sudo tailscale up --accept-routes --operator=$USER

# 2. Install Chrome (optional, Firefox is pre-installed)
flatpak install flathub com.google.Chrome

# 3. Install Homebrew packages
brew install chezmoi starship direnv
brew install bat eza fd ripgrep git-delta gh glab fzf

# 4. Apply dotfiles
chezmoi init --apply --ssh elgorrion

# 5. Install Claude Code (dev machines only)
curl -fsSL https://claude.ai/install.sh | sh
```

## Core Features

All images include:
- Bazzite kernel (HDR, winesync, LAVD/BORE schedulers)
- KDE Plasma 6 + Valve's SteamOS themes
- Firefox (pre-installed), Chrome (via Flathub)
- Tailscale
- Homebrew
- Distrobox
- Auto-updates

## Building Locally

```bash
# Install just
brew install just

# Build all images
just build-all

# Build specific image
just build-main
just build-nvidia-gaming
```

## Architecture

```
Bazzite (upstream)
    │
    ├── avisblue-main (Mesa)
    │   └── avisblue-main-dev (+VSCode, +ROCm)
    │
    └── avisblue-nvidia-gaming (NVIDIA + Gaming)
        └── avisblue-nvidia-gaming-dev (+VSCode, +CUDA)
```

## License

MIT
