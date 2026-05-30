# Avisblue — Vision

> A clean, modern Universal Blue distro for a small personal fleet.
> Daily driver, development (Python / TypeScript), and gaming (Steam) — on
> one image, two GPU flavors.

This document is the constitution. When a decision is ambiguous, it is
resolved here. Code comments may reference sections as `VISION §N`.

---

## §0 — The one-line philosophy

**Build *up* from a clean developer desktop. Don't strip *down* a gaming OS.**

Avisblue 1.x was Bazzite with the gaming OS carved out of it — a large,
fragile cleanup layer that chased upstream churn every week (gamescope renamed,
handheld packages moved, Steam stack reshuffled). Every Bazzite release risked a
red build.

Avisblue 2.x inverts that. The base is **Aurora-dx** — Universal Blue's KDE
*developer* workstation, which is already the clean, batteries-included desktop
we were trying to reach by subtraction. We now add a thin, intentional layer on
top instead of removing a thick, accidental one.

---

## §1 — What Avisblue is

A **personal fleet OS**: a handful of the same person's desktops and laptops,
managed as cattle, not pets. Every machine runs the same image (modulo GPU),
updates automatically, is reachable on the fleet network, and can be rebuilt
from zero in minutes.

Three capabilities, **universal across every machine** (not split into separate
images):

1. **Daily driver** — KDE Plasma 6, Wayland, a curated Qt app set, a browser.
2. **Development** — Python and TypeScript first; containers, virtualization,
   and an editor inherited from Aurora-dx; language toolchains provisioned
   per-user via Homebrew (and devcontainers/distrobox per project) — never baked
   into the image.
3. **Gaming** — Steam, delivered as a Flatpak, with MangoHud + Gamescope +
   ProtonUp-Qt. Works on AMD/Intel and NVIDIA alike.

---

## §2 — Base: Aurora-dx

| Image | Base | Hardware |
|-------|------|----------|
| `avisblue`        | `ghcr.io/ublue-os/aurora-dx:stable`             | AMD / Intel (Mesa) |
| `avisblue-nvidia` | `ghcr.io/ublue-os/aurora-dx-nvidia-open:stable` | NVIDIA (open modules) |

Aurora-dx gives us, **for free**, what 1.x reassembled by hand:

- Fedora Atomic KDE (Kinoite) base, KDE Plasma 6, Wayland-by-default.
- Developer substrate: Docker **and** Podman, Incus, libvirt/virt-manager,
  VS Code, devcontainers, Cockpit.
- Homebrew, distrobox, Tailscale, `ujust`, `ublue-update`, Flatpak + Flathub.
- NVIDIA open kernel modules + `nvidia-container-toolkit` + auto-CDI on the
  `-nvidia-open` flavor.

We track `:stable`. We follow upstream; we do not fight it.

### Why not Bazzite?

Bazzite is a *gaming console* OS — gaming kernel (HDR/winesync/LAVD-BORE),
handheld support, an RPM Steam stack. For a daily-driver/dev fleet that also
games *casually* via Steam, that is the wrong default: we spent most of our
build logic deleting it. The "minimal, modern, futuristic" goal is better served
by a clean dev base + Flatpak Steam. We trade a few percent of gaming-kernel
tuning for a dramatically simpler, sturdier image. (If a dedicated gaming rig
ever needs Bazzite, it can run stock Bazzite — Avisblue doesn't have to be
everything.)

### Relationship to Aurora: derivative, not a hard fork

Avisblue is a **downstream derivative image** — it does `FROM
ghcr.io/ublue-os/aurora-dx:stable` and layers a thin set of changes on top. This
is the standard Universal Blue custom-image pattern (cf. the ublue
`image-template`); it is **not** a source fork of Aurora's repository.

This is deliberate, and it's the right answer for a project that exists for both
**learning** and **daily use**:

- **Learning surface where it matters, inheritance where it doesn't.** We own the
  Containerfile, the build layer, CI, signing, branding, and ISO pipeline — the
  parts worth understanding. We inherit the hard, thankless parts (kernel +
  akmods, NVIDIA module builds, Secure Boot keys, KDE integration, security
  updates) from Aurora, which has a team maintaining them.
- **A hard fork would be a maintenance sink with little upside:** we'd inherit
  all of Aurora's churn with none of its leverage, for a one-person fleet.
- **Daily-use reliability:** tracking `aurora-dx:stable` means Avisblue gets the
  same battle-tested base millions of hours of ublue testing already cover; our
  thin layer is the only thing that can break, and the smoke-test + auto-revert
  gates (§8) contain that.

If Avisblue's layer ever grows large enough to feel like its own distro, the
escape hatch is to vendor specific Aurora build steps — but only the ones we
genuinely need to diverge on. Default: stay a thin derivative.

---

## §3 — The layer we add (and nothing more)

The image stays **minimal**. We add only what the fleet needs and what cannot
sensibly live in user space:

1. **Identity & branding** — os-release, Plymouth, SDDM, fastfetch, wallpaper,
   KDE look-and-feel, Cockpit branding. (§6)
2. **Fleet config** — locale (en_US, C collation), Tailscale enablement, SSH
   agent, managed shell/env skel. (§7)
3. **Curated Qt apps** — the KDE app set we always want present (kate, okular,
   gwenview, ark, kcalc, spectacle, partitionmanager, kdeconnectd, konsole) +
   Chromium.
4. **Cockpit fleet extensions** — `cockpit-machines`, `cockpit-ostree`.
5. **First-boot Flatpaks** — the Steam/gaming set, installed idempotently by
   `avisblue-flatpak-manager` (§5).
6. **Signing** — cosign policy for `ghcr.io/elgorrion` (§8).

We bake **no developer runtimes and no `mise`** — toolchains are a per-user
concern (§4). Everything not listed above stays out of the image on purpose.

---

## §4 — Where mutable things live (the modern split)

An atomic image must not carry mutable, fast-moving state. Language runtimes,
project dependencies, and most apps do **not** belong baked into the OS.

| Concern | Lives in | Not in the image |
|---------|----------|------------------|
| Python / Node / TS toolchains | **Homebrew** (per-user; `brew install python node`, or `brew install mise` if you want polyglot pinning) | layered RPM `python3.x`, `nodejs`, or a baked `mise` |
| Project environments | **devcontainers / distrobox** (Aurora-dx ships both) | global venvs |
| GUI apps | **Flatpak** (Flathub) | layered desktop RPMs |
| CLI tools | **Homebrew** | layered RPMs |
| Dotfiles / config | **chezmoi** | `/etc` edits |
| GPU compute (CUDA / ROCm / PyTorch) | **workload containers** | host SDKs |

The image bakes **no language runtimes and no version manager** — not even
`mise`. Toolchains are per-user state, and per-user state belongs in `$HOME`, not
in the OS layer. Homebrew (inherited from Aurora-dx) is the fleet's runtime
delivery mechanism; chezmoi-managed dotfiles can `brew install` whatever a given
machine needs. Bootstrapping a fresh machine is: `brew install …`,
`chezmoi init --apply`, done. (Prefer per-project isolation? Use a devcontainer
or distrobox — both ship in the base.)

---

## §5 — Gaming is a Flatpak, and it's universal

Gaming is **not** a separate image and **not** an RPM stack. Both `main` and
`nvidia` install the same first-boot Flatpak set:

- `com.valvesoftware.Steam`
- `com.valvesoftware.Steam.Utility.MangoHud`
- `com.valvesoftware.Steam.Utility.gamescope`
- `net.davidotek.pupgui2` (ProtonUp-Qt)

Rationale: Flatpak Steam is the Universal-Blue-recommended path on non-Bazzite
images, it's sandboxed, it updates independently of the OS, and it's identical
across GPUs. NVIDIA gets working acceleration from the open modules in the base
image; AMD/Intel from Mesa.

---

## §6 — Identity & branding

Avisblue is its own brand on top of Fedora's plumbing:

- `ID=fedora` is **kept** (Bazzite/Bluefin/Aurora convention — tooling depends
  on it). We set `NAME`, `PRETTY_NAME`, `VARIANT`, `IMAGE_ID`, `CPE_NAME`, etc.
- Branding assets ship via `system_files/` at COPY time; runtime mutations
  (logos package neutralization, Plymouth theme + initramfs regen, per-variant
  `Variant=`) happen in `85-branding.sh`.
- The branding layer is **base-agnostic**: it detects and overrides whatever
  logos package the base ships (Fedora *or* Aurora), rather than hardcoding one.

---

## §7 — Fleet management

- **Network:** Tailscale, enabled in the image; `tailscale up` on first boot.
- **Remote management:** Cockpit on `:9090` (system, podman, storage, machines,
  ostree).
- **Updates:** automatic via `ublue-update`.
- **Locale:** `en_US.UTF-8`, `C` collation. English-only fleet.

---

## §8 — Supply chain & CI

- Images are signed with **cosign** (key shipped at
  `/etc/pki/containers/avisblue.pub`); rebase with
  `--enforce-container-sigpolicy`.
- CI builds daily (picks up Aurora's rebuild), lints (shellcheck + actionlint),
  builds both flavors, runs a **smoke test** (branding/identity/policy manifest),
  signs, and **verifies the signature chain**.
- A red scheduled build **auto-reverts** `:latest` to the last green digest and
  opens a tracking issue. The fleet always stays on last-known-good.
- No provenance/SBOM attestation (it breaks bootc's single-platform signature
  lookup), no telemetry, no Rekor upload — single-owner derivative.

---

## §9 — Constitutional invariants

These do not change without amending this document:

1. **No telemetry** — `rpm-ostree-countme` is masked, even opt-in.
2. **Wayland-only** — X11 Plasma session removed; XWayland kept for legacy apps.
3. **Pure KDE / Qt** — no GTK desktop apps where a Qt one exists.
4. **English-only** — non-English IMEs/fonts trimmed.
5. **Container-only GPU compute** — the host exposes hardware; SDKs live in
   workload containers.
6. **Minimal image, mutable elsewhere** — see §4.
7. **Two images, one axis** — they differ only by GPU.

---

## §10 — Non-goals

- Not a gaming-first console OS (that's Bazzite).
- Not a multi-user / enterprise distro.
- Not a general-purpose public image — it's tuned for one person's fleet.
- No layered language runtimes, no baked project tooling, no kitchen-sink apps.
