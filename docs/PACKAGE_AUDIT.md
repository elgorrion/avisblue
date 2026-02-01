# Avisblue Package Audit

Full package flow: Fedora Kinoite → Universal Blue main → Bazzite → Avisblue

Generated: 2026-02-01

---

## Layer 0: Fedora Kinoite (F43)

Base atomic KDE Plasma desktop. Includes:

### Core System
- systemd, dbus, polkit, SELinux
- rpm-ostree, flatpak, podman
- NetworkManager, firewalld
- GRUB2, dracut, kernel (Fedora stock)

### KDE Plasma Desktop
- plasma-desktop, plasma-workspace, kwin
- dolphin, konsole, systemsettings
- sddm, breeze themes
- kio, solid, baloo

### Graphics
- Mesa (stock Fedora)
- Wayland, XWayland

### Multimedia
- PipeWire, WirePlumber
- GStreamer

---

## Layer 1: Universal Blue Main (ublue-os/kinoite-main)

**Base:** Fedora Kinoite F43

### Added - All Images

| Package | Purpose |
|---------|---------|
| distrobox | Container toolbox |
| just | Command runner |
| ffmpeg, ffmpeg-libs, libavcodec | Media codecs |
| fdk-aac, libfdk-aac | AAC codec |
| ffmpegthumbnailer | Video thumbnails |
| heif-pixbuf-loader, libheif | HEIF image support |
| intel-vaapi-driver, libva-utils | Intel VA-API |
| libcamera, libcamera-* | Camera support |
| htop, nvtop | System monitors |
| vim, tmux, fzf | CLI tools |
| lshw, smartmontools, nvme-cli | Hardware tools |
| net-tools, tcpdump, traceroute, wireguard-tools | Network tools |
| squashfs-tools, zstd | Compression |
| flatpak-spawn, fuse | Container/mount |
| grub2-tools-extra | Boot tools |
| pam-u2f, pam_yubico, pamu2fcfg, yubikey-manager | Yubikey/U2F |
| libratbag-ratbagd | Gaming mice |
| openrgb-udev-rules, oversteer-udev, solaar-udev | Peripheral udev |
| libimobiledevice-utils, usbmuxd | iPhone support |
| pipewire-libs-extra, pipewire-plugin-libcamera | PipeWire extras |
| powerstat | Power stats |
| symlinks | Symlink tools |
| wl-clipboard | Wayland clipboard |
| xhost, xorg-x11-xauth | X11 auth |
| android-udev-rules | Android device rules |
| mesa-libxatracker | Mesa extra |
| apr, apr-util | Apache libs |
| openssl | Crypto |
| google-noto-sans-*-fonts | Noto fonts (Balinese, CJK, Javanese, Sundanese) |

### Added - Kinoite Specific

| Package | Purpose |
|---------|---------|
| kate | Text editor |
| ksshaskpass | SSH askpass for KDE |
| icoutils | Icon extraction |
| fcitx5-* | Input methods (Chinese, Hangul, Thai, Mozc, etc.) |
| kcm-fcitx5 | Fcitx5 KDE settings |

### ublue-os Packages

| Package | Purpose |
|---------|---------|
| ublue-os-just | Justfile recipes |
| ublue-os-luks | LUKS integration |
| ublue-os-signing | Image signing |
| ublue-os-udev-rules | Custom udev rules |
| ublue-os-update-services | Update services |
| cosign | Image verification |

### Kernel
- Fedora signed kernel (with ublue akmods)

### Removed from Fedora
- fedora-flathub-remote
- gnome-software-rpm-ostree (silverblue)
- plasma-discover-rpm-ostree (kinoite)
- google-noto-sans-cjk-vf-fonts
- default-fonts-cjk-sans
- fedora-third-party

---

## Layer 2: Bazzite (ghcr.io/ublue-os/bazzite:stable)

**Base:** Universal Blue kinoite-main

### Kernel Change
| From | To |
|------|-----|
| Fedora kernel | **bazzite-kernel** (HDR, winesync, LAVD/BORE) |

### Patched/Swapped Packages

| Package | Source | Notes |
|---------|--------|-------|
| pipewire, wireplumber | Bazzite COPR | Valve patches |
| bluez | Bazzite COPR | Valve patches |
| xorg-x11-server-Xwayland | Bazzite COPR | Valve patches |
| NetworkManager | Bazzite COPR | Bazzite patches |
| fwupd | ublue staging | Patched |
| mesa-* | terra-mesa | Latest Mesa |
| mutter, gnome-shell | Bazzite (Silverblue only) | VRR patches |

### Added - Gaming

| Package | Purpose |
|---------|---------|
| steam | Steam client |
| lutris | Game launcher |
| faugus-launcher | Wine launcher |
| gamescope, gamescope-libs (x86_64+i686) | Gaming compositor |
| gamescope-shaders | Gamescope shaders |
| mangohud (x86_64+i686) | Performance overlay |
| vkBasalt (x86_64+i686) | Vulkan post-processing |
| libobs_vkcapture, libobs_glcapture (x86_64+i686) | OBS game capture |
| umu-launcher | Proton launcher |
| winetricks | Wine helper (downloaded) |
| libFAudio (x86_64+i686) | FAudio lib |
| openxr | OpenXR runtime |
| libaacs, libbdplus, libbluray, libbluray-utils | Blu-ray support |
| jupiter-sd-mounting-btrfs | SD card mounting |
| dbus-x11 | D-Bus X11 |
| xdg-user-dirs, xdg-terminal-exec | XDG standards |
| gobject-introspection | GObject |

### Added - System Utilities

| Package | Purpose |
|---------|---------|
| btop | System monitor |
| fastfetch | System info |
| fish | Fish shell |
| duf | Disk usage |
| glow, gum | Markdown/TUI |
| vim | Editor |
| lshw | Hardware info |
| tailscale | VPN |
| topgrade | Update tool |
| snapper, btrfs-assistant | Btrfs snapshots |
| bees | Btrfs dedup |
| compsize | Btrfs compression |

### Added - Hardware Support

| Package | Purpose |
|---------|---------|
| iptsd, libwacom-surface | Microsoft Surface |
| fw-ectool, fw-fanctrl, framework-system | Framework laptop |
| ryzenadj | AMD undervolting |
| ddcutil | DDC/CI monitor control |
| i2c-tools, lm_sensors | Hardware sensors |
| libcec | HDMI-CEC |
| xwiimote-ng | Wii Remote |
| v4l-utils | Video4Linux |
| input-remapper, libinput-utils | Input remapping |

### Added - Audio

| Package | Purpose |
|---------|---------|
| pulseaudio-utils | PA utils |
| ladspa-caps-plugins | LADSPA plugins |
| ladspa-noise-suppression-for-voice | Noise suppression |
| pipewire-module-filter-chain-sofa | SOFA HRTF |
| libfreeaptx | aptX codec |

### Added - Networking

| Package | Purpose |
|---------|---------|
| iwd | Wireless daemon |
| tailscale | Mesh VPN |

### Added - Virtualization

| Package | Purpose |
|---------|---------|
| qemu | Emulator |
| libvirt, guestfs-tools | Virtualization |
| edk2-ovmf | UEFI firmware |

### Added - Development

| Package | Purpose |
|---------|---------|
| python3-pip | Python packages |
| python3-icoextract | Icon extraction |

### Added - Containers/Android

| Package | Purpose |
|---------|---------|
| waydroid | Android containers |
| cage, wlr-randr | Wayland tools |

### Added - Misc Tools

| Package | Purpose |
|---------|---------|
| uld | Samsung printer |
| bazaar | App browser |
| greenboot, greenboot-default-health-checks | Health checks |
| ScopeBuddy | Gamescope helper |
| Sunshine | Game streaming |
| webapp-manager | Web apps |
| xdotool, wmctrl, xwininfo | X11 tools |
| ydotool | Wayland automation |
| yad | GUI dialogs |
| vulkan-tools | Vulkan utils |
| lzip, p7zip, p7zip-plugins, rar | Archivers |
| libxcrypt-compat | Compat lib |
| lsb_release | LSB info |
| stress-ng | Stress testing |
| f3 | Flash testing |
| usbip | USB over IP |
| udica | SELinux containers |
| ls-iommu | IOMMU listing |
| ds-inhibit | DualSense inhibitor |
| uupd | Update daemon |

### Added - Cockpit

| Package | Purpose |
|---------|---------|
| cockpit-networkmanager | Network config |
| cockpit-podman | Container management |
| cockpit-selinux | SELinux management |
| cockpit-system | System management |
| cockpit-files | File browser |
| cockpit-storaged | Storage management |

### Added - Fonts

| Package | Purpose |
|---------|---------|
| twitter-twemoji-fonts | Emoji |
| google-noto-sans-cjk-fonts | CJK |
| lato-fonts | Lato |
| fira-code-fonts | Programming |
| nerd-fonts | Developer icons |

### Added - Schedulers

| Package | Purpose |
|---------|---------|
| scx-scheds | LAVD/BORE schedulers |
| scx-tools | Scheduler tools |

### Added - Compute

| Package | Purpose |
|---------|---------|
| rocm-hip | ROCm HIP |
| rocm-opencl | ROCm OpenCL |
| rocm-clinfo | ROCm info |
| rocm-smi | ROCm SMI |

### Added - KDE Specific (Bazzite adds to Kinoite)

| Package | Purpose |
|---------|---------|
| qt | Qt base |
| krdp | KDE RDP |
| steamdeck-kde-presets-desktop | Steam Deck themes |
| kdeconnectd | KDE Connect |
| kdeplasma-addons | Plasma addons |
| rom-properties-kf6 | ROM file properties |
| gnome-disk-utility | Disk utility |
| kio-extras | KIO extras |
| krunner-bazaar | Bazaar runner |
| ptyxis | Terminal |

### Added - ublue-os/Bazzite Packages

| Package | Purpose |
|---------|---------|
| bazzite-portal | First-run wizard |
| ujust-picker | Justfile picker |
| cicpoffs | FUSE filesystem |
| ublue-os-media-automount-udev | Media automount |

### Added - Homebrew

| Package | Purpose |
|---------|---------|
| Homebrew | Package manager (linuxbrew) |

### Removed from ublue-main

| Package | Reason |
|---------|--------|
| ublue-os-update-services | Replaced by uupd |
| firefox, firefox-langpacks | Use Flatpak |
| toolbox | Use distrobox |
| htop | Use btop |
| plasma-welcome, plasma-welcome-fedora | Bazzite portal |
| plasma-discover, plasma-discover-kns | Use CLI/Bazaar |
| konsole | Use ptyxis |
| kcharselect | Unused |
| kde-partitionmanager | gnome-disk-utility |

---

## Layer 3: Bazzite-NVIDIA (ghcr.io/ublue-os/bazzite-nvidia:stable)

**Base:** Bazzite (above)

### Added

| Package | Purpose |
|---------|---------|
| NVIDIA proprietary drivers | GPU drivers |
| egl-wayland (x86_64+i686) | EGL Wayland |

### Removed

| Package | Reason |
|---------|--------|
| nvidia-gpu-firmware | Proprietary drivers |
| rocm-hip, rocm-opencl, rocm-clinfo, rocm-smi | AMD compute |

---

## Layer 4a: avisblue-main

**Base:** Bazzite (Mesa)

### Removed by 10-cleanup-main.sh

| Category | Packages |
|----------|----------|
| Gaming | steam, lutris, gamescope, gamescope-shaders, mangohud, vkBasalt, umu-launcher, winetricks, faugus-launcher, gamemode |
| Handheld | hhd, hhd-ui, adjustor, steam-patch, jupiter-fan-control, jupiter-hw-support, steamdeck-dsp, steamdeck-kde-presets, sdgyrodsu, decky-loader |
| Streaming | waydroid, cage, wlr-randr, sunshine, input-remapper |
| ROCm | rocm-hip, rocm-opencl, rocm-clinfo, rocm-smi (re-added by 50-rocm.sh) |
| 32-bit | *.i686 |
| Duplicates | htop, nvtop |
| Hardware | iptsd, fw-ectool, fw-fanctrl, framework-system, ryzenadj, xwiimote-ng, oversteer-udev |
| Features | bazzite-portal, ScopeBuddy, ds-inhibit, bazaar, krunner-bazaar, topgrade, yad |
| GTK Apps | gnome-disk-utility, ptyxis |
| Debug | stress-ng, powerstat, f3 |
| IME | fcitx5-chinese-addons, fcitx5-configtool, fcitx5-gtk, fcitx5-hangul, fcitx5-libthai, fcitx5-mozc, fcitx5-qt, fcitx5-sayura, fcitx5-unikey, kcm-fcitx5 |
| Fonts | google-noto-sans-balinese-fonts, google-noto-sans-javanese-fonts, google-noto-sans-sundanese-fonts |
| Shells | fish, zsh |
| CLI | glow, gum |

**Note:** Cockpit base packages are **KEPT** for fleet management (cockpit-system, cockpit-podman, cockpit-storaged, cockpit-networkmanager, cockpit-files, cockpit-selinux).

### Removed Flatpaks (10-cleanup-main.sh)

| Type | Flatpaks |
|------|----------|
| GTK | org.mozilla.firefox, com.github.Matoking.protontricks, com.vysp3r.ProtonPlus, com.ranfdev.DistroShelf, io.github.flattool.Warehouse, com.github.tchx84.Flatseal |
| Qt | org.kde.gwenview, org.kde.okular, org.kde.kcalc, org.kde.haruna, org.kde.filelight |

### Added by 30-kde-apps.sh

| Package | Purpose |
|---------|---------|
| kate | Text editor |
| okular | PDF viewer |
| gwenview | Image viewer |
| ark | Archive manager |
| kcalc | Calculator |
| spectacle | Screenshot |
| partitionmanager | Disk partitioning |
| kdeconnectd | Phone integration |
| konsole | Terminal (Bazzite removes, we re-add) |
| chromium | Web browser |

### Added by 40-dev-tools.sh

| Package | Purpose |
|---------|---------|
| code | VS Code |
| podman-docker | Docker compat |
| podman-compose | Compose (pure podman) |
| qemu-kvm | KVM |
| libvirt | Virtualization |
| cockpit-machines | VM management (web UI) |
| cockpit-ostree | OSTree management (web UI) |

### Added by 50-rocm.sh

| Package | Purpose |
|---------|---------|
| rocm-hip | HIP runtime |
| rocm-opencl | OpenCL runtime |
| rocm-clinfo | OpenCL info |
| rocm-smi | System management |

### Final Flatpaks
**NONE (zero)**

---

## Layer 4b: avisblue-nvidia-gaming

**Base:** Bazzite-NVIDIA

### Removed by 10-cleanup-nvidia-gaming.sh

| Category | Packages |
|----------|----------|
| Handheld | hhd, hhd-ui, adjustor, steam-patch, jupiter-fan-control, jupiter-hw-support, steamdeck-dsp, steamdeck-kde-presets, sdgyrodsu, decky-loader |
| Streaming | waydroid, cage, wlr-randr, sunshine |
| ROCm | rocm-hip, rocm-opencl, rocm-clinfo, rocm-smi (NVIDIA uses CUDA) |
| Duplicates | htop, nvtop |
| Hardware | iptsd, fw-ectool, fw-fanctrl, framework-system, ryzenadj, xwiimote-ng, oversteer-udev |
| Features | bazzite-portal, ds-inhibit, bazaar, krunner-bazaar, topgrade, yad |
| GTK Apps | gnome-disk-utility, ptyxis |
| Debug | stress-ng, powerstat, f3 |
| IME | fcitx5-* (all variants), kcm-fcitx5 |
| Fonts | google-noto-sans-balinese-fonts, google-noto-sans-javanese-fonts, google-noto-sans-sundanese-fonts |
| Shells | fish, zsh |
| CLI | glow, gum |

**Note:** Gaming packages (steam, gamescope, mangohud, etc.) and ScopeBuddy are **KEPT**. Cockpit base packages are **KEPT**.

### Removed Flatpaks (same as avisblue-main)

### Added by 30-kde-apps.sh
(Same as avisblue-main: kate, okular, gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd, konsole, chromium)

### Added by 40-dev-tools.sh
(Same as avisblue-main: code, podman-docker, podman-compose, qemu-kvm, libvirt, cockpit-machines, cockpit-ostree)

### Added by 50-gaming.sh

| Package | Purpose |
|---------|---------|
| openrgb | RGB control |
| openrgb-udev-rules | RGB udev |

### Added by 60-cuda.sh

| Package | Purpose |
|---------|---------|
| nvidia-container-toolkit | GPU containers |

### Final Flatpaks

| Flatpak | Purpose |
|---------|---------|
| net.davidotek.pupgui2 | ProtonUp-Qt |
| io.github.rfrench3.scopebuddy-gui | ScopeBuddy (Gamescope config) |

### Kept from Bazzite-NVIDIA

| Category | Packages |
|----------|----------|
| Gaming | steam, lutris, gamescope, gamescope-shaders, mangohud, vkBasalt, umu-launcher, faugus-launcher |
| 32-bit | All *.i686 libs |
| NVIDIA | Proprietary drivers, egl-wayland |

---

## Final Package Summary

### avisblue-main

| Category | Count | Key Packages |
|----------|-------|--------------|
| Kernel | 1 | bazzite-kernel |
| Desktop | ~50 | KDE Plasma 6, Wayland |
| KDE Apps | 10 | kate, okular, gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd, konsole, chromium |
| Dev Tools | 7 | code, podman-docker, podman-compose, qemu-kvm, libvirt, cockpit-machines, cockpit-ostree |
| Cockpit | 8 | system, podman, storaged, networkmanager, files, selinux (Bazzite) + machines, ostree (added) |
| Compute | 4 | rocm-hip, rocm-opencl, rocm-clinfo, rocm-smi |
| System | ~30 | btop, fastfetch, vim, tailscale, distrobox, snapper, btrfs-assistant |
| Multimedia | ~20 | PipeWire (patched), ffmpeg, codecs |
| Fonts | ~5 | nerd-fonts, fira-code-fonts, CJK, emoji |
| Flatpaks | 0 | None |

### avisblue-nvidia-gaming

| Category | Count | Key Packages |
|----------|-------|--------------|
| Kernel | 1 | bazzite-kernel |
| Desktop | ~50 | KDE Plasma 6, Wayland |
| KDE Apps | 10 | kate, okular, gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd, konsole, chromium |
| Dev Tools | 7 | code, podman-docker, podman-compose, qemu-kvm, libvirt, cockpit-machines, cockpit-ostree |
| Cockpit | 8 | system, podman, storaged, networkmanager, files, selinux (Bazzite) + machines, ostree (added) |
| Gaming | ~15 | steam, lutris, gamescope, mangohud, vkBasalt, umu-launcher |
| NVIDIA | ~10 | Proprietary drivers, nvidia-container-toolkit |
| System | ~30 | btop, fastfetch, vim, tailscale, distrobox, snapper, btrfs-assistant |
| Multimedia | ~20 | PipeWire (patched), ffmpeg, codecs |
| Fonts | ~5 | nerd-fonts, fira-code-fonts, CJK, emoji |
| RGB | 2 | openrgb, openrgb-udev-rules |
| Flatpaks | 2 | ProtonUp-Qt, ScopeBuddy |

---

## Estimated Image Sizes

| Image | Estimated Size | Notes |
|-------|----------------|-------|
| Fedora Kinoite | ~3.5 GB | Base |
| Universal Blue main | ~4.0 GB | +codecs, tools |
| Bazzite | ~6.0 GB | +gaming, 32-bit |
| Bazzite-NVIDIA | ~7.0 GB | +NVIDIA drivers |
| avisblue-main | ~4.5 GB | Stripped, no gaming |
| avisblue-nvidia-gaming | ~6.5 GB | NVIDIA + gaming |

---

## Package Sources

| Source | URL |
|--------|-----|
| Fedora | https://packages.fedoraproject.org |
| RPM Fusion | https://rpmfusion.org |
| Negativo17 | https://negativo17.org |
| Terra | https://repos.fyralabs.com/terra |
| ublue-os COPRs | https://copr.fedorainfracloud.org/coprs/ublue-os/ |
| Bazzite COPRs | ublue-os/bazzite, ublue-os/bazzite-multilib |
| Tailscale | https://pkgs.tailscale.com |
| Microsoft | https://packages.microsoft.com (VSCode) |
| NVIDIA | nvidia-container-toolkit repo |
