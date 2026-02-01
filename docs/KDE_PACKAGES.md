# KDE Package Flow - Avisblue

Full KDE package flow: Fedora Kinoite → Universal Blue → Bazzite → Avisblue

---

## Layer 0: Fedora Kinoite Base

Fedora Kinoite includes the `kde-desktop` package group plus ostree-specific additions.

### Plasma Desktop (Mandatory)

| Package | Purpose |
|---------|---------|
| plasma-desktop | KDE Plasma shell |
| plasma-workspace | Workspace components |
| plasma-workspace-wallpapers | Default wallpapers |
| sddm | Display manager |
| sddm-breeze | Breeze SDDM theme |
| sddm-kcm | SDDM settings |
| sddm-wayland-plasma | Wayland session |

### Plasma Components (Default)

| Package | Purpose |
|---------|---------|
| kwin | Window manager |
| plasma-breeze | Breeze theme |
| plasma-desktop-doc | Documentation |
| plasma-discover | App store |
| plasma-discover-notifier | Update notifier |
| plasma-disks | Disk health |
| plasma-drkonqi | Crash handler |
| plasma-nm | Network manager |
| plasma-nm-l2tp | L2TP VPN |
| plasma-nm-openconnect | OpenConnect VPN |
| plasma-nm-openswan | Openswan VPN |
| plasma-nm-openvpn | OpenVPN |
| plasma-nm-pptp | PPTP VPN |
| plasma-nm-vpnc | VPNC |
| plasma-pa | PulseAudio applet |
| plasma-print-manager | Printing |
| plasma-systemmonitor | System monitor |
| plasma-thunderbolt | Thunderbolt |
| plasma-vault | Encrypted folders |
| plasma-welcome | Welcome wizard |
| bluedevil | Bluetooth |
| breeze-icon-theme | Icon theme |
| kdeplasma-addons | Plasma widgets |
| polkit-kde | PolicyKit agent |

### KDE Core Apps

| Package | Purpose |
|---------|---------|
| dolphin | File manager |
| konsole | Terminal |
| ark | Archive manager |
| kwrite | Text editor |
| spectacle | Screenshots |

### KDE System Tools

| Package | Purpose |
|---------|---------|
| kinfocenter | System info |
| kscreen | Display settings |
| kscreenlocker | Screen locker |
| kmenuedit | Menu editor |
| kjournald | Journal viewer |
| kfind | File search |
| kwalletmanager5 | Wallet manager |
| kcharselect | Character picker |
| kde-partitionmanager | Disk partitioning |

### KDE Integration

| Package | Purpose |
|---------|---------|
| kde-connect | Phone integration |
| kde-gtk-config | GTK theming |
| kde-inotify-survey | Inotify limits |
| kde-settings-pulseaudio | Audio settings |
| kdebugsettings | Debug settings |
| kdegraphics-thumbnailers | Image thumbnails |
| kdenetwork-filesharing | Samba sharing |
| kdnssd | DNS-SD browser |
| kio-admin | Admin file access |
| kio-gdrive | Google Drive |

### KDE Utilities

| Package | Purpose |
|---------|---------|
| ksshaskpass | SSH askpass |
| kdialog | Scripting dialogs |
| krdp | RDP server |
| krfb | VNC server |
| khelpcenter | Help browser |
| kunifiedpush | Push notifications |
| kwebkitpart | Webkit component |

### Other

| Package | Purpose |
|---------|---------|
| colord-kde | Color management |
| cups-pk-helper | Printing auth |
| flatpak-kcm | Flatpak settings |
| fprintd-pam | Fingerprint |
| ffmpegthumbs | Video thumbnails |
| filelight | Disk usage |
| firewall-config | Firewall GUI |
| audiocd-kio | Audio CD ripping |
| pam-kwallet | KWallet PAM |
| pinentry-qt | GPG pin entry |
| phonon-qt6-backend-vlc | Phonon VLC |
| libappindicator-gtk3 | Tray compat |
| xwaylandvideobridge | XWayland screen share |

### Akonadi (PIM Backend)

| Package | Purpose |
|---------|---------|
| akonadi-server | Akonadi server |
| akonadi-server-mysql | MySQL backend |
| kaccounts-integration-qt6 | Online accounts |
| kaccounts-providers | Account providers |

---

## Layer 1: Universal Blue Main

**Adds to Fedora Kinoite:**

| Package | Purpose |
|---------|---------|
| kate | Advanced text editor |
| ksshaskpass | SSH askpass (if not present) |
| icoutils | Icon extraction |
| fcitx5-* (9 packages) | Input methods |
| kcm-fcitx5 | Fcitx5 KDE settings |

**Removes from Fedora:**

| Package | Reason |
|---------|--------|
| plasma-discover-rpm-ostree | Not needed |

---

## Layer 2: Bazzite

**Adds to Universal Blue:**

| Package | Purpose |
|---------|---------|
| qt | Qt base libs |
| krdp | KDE RDP (may duplicate) |
| steamdeck-kde-presets-desktop | Steam Deck themes/presets |
| kdeconnectd | KDE Connect daemon |
| kdeplasma-addons | Plasma addons (may duplicate) |
| rom-properties-kf6 | ROM file properties |
| gnome-disk-utility | Disk utility (GTK!) |
| kio-extras | Extra KIO protocols |
| krunner-bazaar | App store runner |
| ptyxis | GNOME terminal (replaces konsole) |
| fcitx5-mozc | Japanese IME |
| fcitx5-chinese-addons | Chinese IME |
| fcitx5-hangul | Korean IME |
| kcm-fcitx5 | Fcitx5 settings |

**Removes from Universal Blue:**

| Package | Reason |
|---------|--------|
| plasma-welcome | Bazzite portal instead |
| plasma-welcome-fedora | Bazzite portal instead |
| plasma-discover | Use Bazaar instead |
| plasma-discover-kns | Not needed |
| konsole | Use ptyxis instead |
| kcharselect | Rarely used |
| kde-partitionmanager | gnome-disk-utility instead |

---

## Layer 3a: avisblue-main

**Removes (10-cleanup-main.sh):**

| Package | Reason |
|---------|--------|
| steamdeck-kde-presets | Gaming themes |
| gnome-disk-utility | GTK app, replaced by partitionmanager |
| ptyxis | GTK terminal, replaced by konsole |
| fcitx5-* (all variants) | IME not needed (English-only fleet) |
| kcm-fcitx5 | Fcitx5 settings |

**Removes Flatpaks (10-cleanup-main.sh):**

| Flatpak | Reason |
|---------|--------|
| org.kde.gwenview | Install as RPM |
| org.kde.okular | Install as RPM |
| org.kde.kcalc | Install as RPM |
| org.kde.haruna | Not needed |
| org.kde.filelight | In base already |

**Adds (30-kde-apps.sh):**

| Package | Purpose |
|---------|---------|
| kate | Text editor |
| okular | PDF/document viewer |
| gwenview | Image viewer |
| ark | Archive manager |
| kcalc | Calculator |
| spectacle | Screenshots |
| partitionmanager | Disk partitioning (replaces gnome-disk-utility) |
| kdeconnectd | Phone integration |
| konsole | Terminal (Bazzite removes, we re-add) |
| chromium | Web browser (Qt/Chromium, replaces Firefox GTK) |

---

## Layer 3b: avisblue-nvidia-gaming

Same as avisblue-main, except:

**Keeps from Bazzite:**

| Package | Reason |
|---------|--------|
| steamdeck-kde-presets | Gaming themes (kept for gaming image) |

---

## Final KDE Package List

### avisblue-main (KDE Packages Only)

#### Plasma Desktop
- plasma-desktop
- plasma-workspace
- plasma-workspace-wallpapers
- sddm, sddm-breeze, sddm-kcm, sddm-wayland-plasma
- kwin
- plasma-breeze
- plasma-disks
- plasma-drkonqi
- plasma-nm (+ VPN plugins)
- plasma-pa
- plasma-print-manager
- plasma-systemmonitor
- plasma-thunderbolt
- plasma-vault
- bluedevil
- breeze-icon-theme
- kdeplasma-addons
- polkit-kde

#### KDE Apps (Added by 30-kde-apps.sh)
- kate (text editor)
- okular (documents)
- gwenview (images)
- ark (archives)
- kcalc (calculator)
- spectacle (screenshots)
- partitionmanager (disks)
- kdeconnectd (phone sync)
- konsole (terminal, re-added after Bazzite removes it)
- chromium (browser)

#### KDE Apps (From Fedora)
- dolphin (files)
- kwrite (simple editor)

#### KDE System
- kinfocenter
- kscreen
- kscreenlocker
- kmenuedit
- kjournald
- kfind
- kwalletmanager5

#### KDE Integration
- kde-connect
- kde-gtk-config
- kde-inotify-survey
- kde-settings-pulseaudio
- kdegraphics-thumbnailers
- kdenetwork-filesharing
- kdnssd
- kio-admin
- kio-gdrive
- kio-extras

#### KDE Utilities
- ksshaskpass
- kdialog
- krdp
- krfb
- khelpcenter
- kunifiedpush
- rom-properties-kf6

#### Terminals
- konsole (KDE terminal, re-added by avisblue)

#### Other
- colord-kde
- flatpak-kcm
- ffmpegthumbs
- firewall-config
- audiocd-kio
- pam-kwallet
- pinentry-qt
- phonon-qt6-backend-vlc
- xwaylandvideobridge

### Removed (Not in Final Image)

| Package | Removed By |
|---------|------------|
| plasma-welcome | Bazzite |
| plasma-discover | Bazzite |
| plasma-discover-notifier | Bazzite |
| konsole | Bazzite (ptyxis instead) |
| kcharselect | Bazzite |
| kde-partitionmanager | Bazzite (we re-add as partitionmanager) |
| fcitx5-* | 10-cleanup-*.sh |
| kcm-fcitx5 | 10-cleanup-*.sh |

---

## KDE Packages Summary

| Category | Count | Notes |
|----------|-------|-------|
| Plasma Core | 7 | Desktop, workspace, sddm |
| Plasma Components | ~20 | VPN, bluetooth, widgets |
| KDE Apps (avisblue) | 10 | kate, okular, gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd, konsole, chromium |
| KDE Apps (Fedora) | 2 | dolphin, kwrite |
| KDE System | 7 | kinfocenter, kscreen, etc. |
| KDE Integration | 10 | kio, kde-connect, etc. |
| KDE Utilities | 7 | ksshaskpass, kdialog, etc. |
| Other | ~8 | Theming, compat, etc. (removed GTK apps) |
| **Total** | **~70** | Pure KDE |

---

## GTK Apps in KDE Image

Remaining GTK apps (no Qt alternatives):

| Package | Source | Reason |
|---------|--------|--------|
| firewall-config | Fedora | No good Qt alternative |

### Removed GTK Apps (10-cleanup-*.sh)

| Package | Replacement |
|---------|-------------|
| gnome-disk-utility | partitionmanager (KDE) |
| ptyxis | konsole (KDE) |

---

## Potential Further Cleanup

### Could Remove (Low Value)
- kwebkitpart (legacy)
- audiocd-kio (who uses CDs?)
- khelpcenter (online docs better)
- plasma-vault (niche)
- plasma-thunderbolt (if no TB hardware)

### Already Replaced (GTK → Qt)
- gnome-disk-utility → partitionmanager ✓
- ptyxis → konsole ✓

### Could Add
- haruna (Qt video player, if needed)
- kdenlive (Qt video editor, if needed)
- krita (Qt image editor, if needed)
