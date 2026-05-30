# KDE Apps in Avisblue

> Avisblue 2.x is based on **Aurora-dx** (Fedora Atomic KDE / Kinoite + Universal
> Blue). The previous Bazzite KDE-flow tables have been removed — they no longer
> describe reality. See [VISION.md](../VISION.md) and `PACKAGE_AUDIT.md`.

## Desktop

KDE Plasma 6 on Wayland comes from the Aurora-dx base (which builds on Fedora
Kinoite's `kde-desktop` set: plasma-desktop, plasma-workspace, kwin, sddm,
dolphin, systemsettings, breeze, kio/baloo, etc.). Avisblue does not curate the
base Plasma set — it tracks upstream.

## Curated app set (added by `30-kde-apps.sh`)

The Qt apps we always want present on every fleet machine. `dnf5 install` is
idempotent — anything Aurora-dx already ships is a no-op.

| Package | Purpose |
|---------|---------|
| kate | Text editor |
| okular | Document/PDF viewer |
| gwenview | Image viewer |
| ark | Archive manager |
| kcalc | Calculator |
| spectacle | Screenshots |
| partitionmanager | Disk partitioning |
| kdeconnectd | Phone integration |
| konsole | Terminal |
| chromium | Web browser (Qt/Chromium) |

## Constitutional KDE/desktop choices (VISION §9)

- **Wayland-only** — the X11 Plasma session is removed (`25-wayland-only.sh`);
  XWayland stays for legacy apps.
- **Pure Qt** — Chromium is the browser; the Firefox flatpak is trimmed
  (`10-trim.sh`). No GTK desktop app where a Qt one exists.
- **English-only** — fcitx5 IMEs and non-English Noto fonts are trimmed.

The live truth is `build_files/shared/30-kde-apps.sh`, `25-wayland-only.sh`, and
`10-trim.sh`.
