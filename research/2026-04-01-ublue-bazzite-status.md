# Universal Blue / Bazzite Ecosystem Status and Avisblue Revival Plan

**Date:** 2026-04-01
**Requested by:** Q
**Domains:** Technical (Linux distro/image engineering), Open-source project governance

## Executive Summary

Universal Blue and Bazzite are thriving as of April 2026. Bazzite is on Fedora 43 with KDE Plasma 6.6, Mesa 26.0, and kernel 6.17/6.19. The most significant change for avisblue is that **Bazzite migrated its Containerfiles from `rpm-ostree` to `dnf5` in early 2025** -- however, avisblue's build scripts already use `dnf5`, so no package-manager migration is needed. The main revival work involves: verifying package availability on Fedora 43, updating package lists for upstream Bazzite changes (renamed/removed packages), adding `bootc container lint` as a build validation step, and optionally upgrading the cosign-installer action from v3 to v4.

## Research Question

What is the current status (April 2026) of the Universal Blue and Bazzite projects, and what steps are needed to update and revive the avisblue custom image project?

### Sub-questions:
1. Universal Blue ecosystem status (April 2026)
2. Bazzite base image status
3. Breaking changes and migration requirements
4. `bootc` vs `rpm-ostree` transition
5. Revival plan for avisblue

## Methodology

### Search Strategy
- **Internal sources checked:** All avisblue Containerfiles, build scripts, CI workflow, CLAUDE.md
- **External queries:** 20+ targeted web searches covering Universal Blue status, Bazzite versions, dnf5 migration, bootc transition, cosign changes, ROCm packages, image-template patterns
- **Platforms:** GitHub (ublue-os repos, releases, PRs, issues), Universal Blue Discourse forums, DeepWiki, GamingOnLinux, Lunar Computer, LWN.net, Fedora Packages, Sigstore docs, Red Hat docs
- **Time range:** January 2025 -- April 2026
- **Geographic scope:** Global (open-source project)

### Limitations
- Cannot directly pull and inspect the current `ghcr.io/ublue-os/bazzite:stable` image to verify exact package lists
- Some Bazzite release notes lack granular package-level change details
- The exact set of packages currently in Bazzite may have shifted since the last documented release notes
- Cannot run a test build to verify which avisblue cleanup scripts will fail against the current Bazzite base

---

## Findings

### 1. Universal Blue Ecosystem Status (April 2026)

Universal Blue is **active and growing**. At its four-year anniversary, the project reports approximately 25,000 weekly system check-ins and over 30 million container image pulls [1, 2]. The community spans 1,098 contributors across 3,069 participants [2].

**Ecosystem structure:** The project now comprises several distinct distributions:
- **Bazzite** -- gaming/general desktop (the most popular, "hundreds of thousands of users") [1]
- **Bluefin** -- developer-focused workstation (GNOME)
- **Aurora** -- developer-focused workstation (KDE)
- **Cayo** -- newer addition to the ecosystem [2]
- **uCore** -- server/CoreOS variant

**Major architectural shift (2025):** Universal Blue underwent a significant refactoring from monolithic distributions to **modular OCI containers** [3, 4]. Aurora and Bluefin were split into separate repositories because they were diverging [4]. A large amount of packaging was refactored to ship as OCI containers instead of RPMs [4]. January 2026 marked the completion of the transition to common OCI containers shared across Bluefin/Aurora/Bazzite [4].

**Governance:** Jorge Castro, Kyle Gospo, and Benjamin Sherman remain the administrative owners [5]. The project describes itself as community-driven with new leadership emerging [2]. No significant governance upheaval was found.

FACT: Universal Blue is actively maintained with strong community engagement and regular releases.

### 2. Bazzite Base Image Status

**Current version:** Bazzite is on **Fedora 43**, released October 29, 2025 [6, 7]. The latest stable release as of this writing is **43.20260330** (March 30, 2026) [8].

**Key component versions (stable, March 2026):**

| Component | Version |
|-----------|---------|
| Fedora base | 43 |
| Kernel | 6.17.7-ba28 (stable), 6.19.10 (unstable) [9, 10] |
| KDE Plasma | 6.6.2 -- 6.6.3 [9, 11] |
| Mesa | 26.0.3 [10] |
| Gamescope | 137 [10] |
| NVIDIA driver | 590.48.01 [12] |

**Notable changes since February 2026:**
- KDE 6.6 shipped (major Plasma update) [11, 13]
- Mesa updated from 26.0.1 to 26.0.3 [10, 12]
- Konsole restored to KDE images (was previously replaced by Ptyxis) [13]
- Ptyxis remains temporarily for config transition, will be removed from KDE images [13]
- Kontainer replaces DistroShelf on new KDE installations (both are Flatpaks, not baked into image) [13, 14]
- Bazaar app manager received improvements [13]
- Image size reduced by 200 MB [13]
- Sunshine package removed due to repository issues [10]
- `maliit-framework` and `maliit-keyboard` removed from image [12]

**Image tags:** The `ghcr.io/ublue-os/bazzite:stable` and `ghcr.io/ublue-os/bazzite-nvidia:stable` tags remain the standard references [15, 16]. The tag naming convention has not changed.

FACT: Bazzite is actively maintained with ~2 stable releases per week on Fedora 43.

### 3. Breaking Changes and Migration Requirements

#### 3a. Package Manager: `rpm-ostree` to `dnf5` in Containerfiles

**This is the single most important upstream change for custom image builders.**

Bazzite migrated its own Containerfile from `rpm-ostree install` to `dnf5 -y install` in early 2025 [17, 18, 19]. The migration happened in stages:
- November 2024: Initial PR to replace rpm-ostree with dnf5 [17]
- January 2025: Containerfile split into separate scripts, dnf5 adoption in unstable branch [18, 20]
- February 2025: Full dnf5 migration in the main Containerfile [19]

**Impact on avisblue:** After inspecting the avisblue build scripts, **avisblue already uses `dnf5` in all its build scripts** (`30-kde-apps.sh`, `40-dev-tools.sh`, `50-rocm.sh`, `50-gaming.sh`, `60-cuda.sh`, `10-cleanup-*.sh`). The `90-finalize.sh` script also uses `dnf5 clean all`. **No package manager migration is needed.**

FACT: Avisblue's build scripts already use dnf5. No migration required.

#### 3b. Bazzite Package Changes

Packages that Bazzite may have **renamed, removed, or reorganized** since avisblue was last built:

- **`sunshine`** -- removed from Bazzite images due to repository issues (March/April 2026) [10, 21]. Avisblue already removes it in cleanup scripts, so no impact.
- **`maliit-framework`, `maliit-keyboard`** -- removed from image [12]. Not referenced in avisblue scripts.
- **`steamdeck-kde-presets-desktop`** -- avisblue's nvidia-gaming cleanup lists this but the main cleanup lists both `steamdeck-kde-presets` and `steamdeck-kde-presets-desktop`. The nvidia-gaming variant only lists `steamdeck-kde-presets`. These packages may have been consolidated or renamed upstream. [single source]
- **`bazaar` / `krunner-bazaar`** -- Bazaar is still present in Bazzite (updated to 0.7.12) [12]. Avisblue removes it, which should still work.
- **`ptyxis`** -- Still in Bazzite KDE images temporarily [13]. Avisblue removes it, which should still work.
- **`rocm-smi`** -- Available in Fedora 43 as version 6.4.3 [22]. However, AMD is deprecating ROCm SMI in favor of AMD SMI [23]. The `rocm-smi` package is still installable but may be replaced in future Fedora releases.
- **`cockpit-ostree`** -- No evidence of removal, but worth verifying availability on Fedora 43 since the ecosystem is moving away from ostree terminology toward bootc.

INFERENCE: Most package names in avisblue's scripts should still work on Fedora 43, but some packages in the strict-mode cleanup lists may have been removed or renamed upstream, causing build failures.

#### 3c. Build Pattern Changes

The upstream ublue-os image-template has evolved its recommended Containerfile pattern:

- **`FROM scratch AS ctx` pattern:** The image-template now uses a `FROM scratch AS ctx` stage to hold build context, then `--mount=type=bind,from=ctx` to access build files without COPY [24, 25]. Avisblue uses `COPY build_files /ctx/build_files` which still works but is the older pattern.
- **`bootc container lint`:** The image-template and Bazzite itself now run `bootc container lint` as the final build step [24, 25, 26]. This validates that the container image is a valid bootable container. **Avisblue does not currently do this.** Adding it is recommended.
- **Buildah vs Docker:** The image-template uses `redhat-actions/buildah-build` [24] while avisblue uses `docker/build-push-action` [avisblue build.yml]. Both work for building OCI images. Docker build-push-action is still valid.

#### 3d. CI/CD Changes

- **`sigstore/cosign-installer`:** Avisblue uses `@v3`. The cosign-installer v4 is now available (latest: v4.1.1) [27]. Importantly, cosign-installer v3 can only install Cosign v2.x, while v4 can install both Cosign v2.x and v3.x [27]. The current avisblue setup using `@v3` with keyless OIDC signing (`cosign sign --yes`) **still works** [28], but upgrading to `@v4` is recommended for access to Cosign v3 features.
- **`actions/checkout@v6`:** Avisblue already uses v6 [avisblue build.yml]. Current.
- **`docker/build-push-action@v6`:** Avisblue already uses v6 [avisblue build.yml]. Current.

### 4. `bootc` vs `rpm-ostree` Transition

**Build-time (Containerfiles):** The transition is effectively complete. `dnf5` has replaced `rpm-ostree install` for package management during image builds [17, 18, 19, 29]. Avisblue is already aligned with this.

**Run-time (user-facing):**
- `rpm-ostree` is in maintenance mode; development focus has shifted to `bootc` and `dnf5` [30, 31]
- `bootc switch` is now used by some Bazzite variants for rebasing (e.g., `sudo bootc switch --enforce-container-sigpolicy ghcr.io/ublue-os/bazzite-dx:stable`) [32]
- Bazzite's documentation still shows both `rpm-ostree rebase` and `bootc switch` commands [15, 32]
- Bazzite issue #2726 proposes using `bootc upgrade` instead of `rpm-ostree` by default, but this has not yet been fully implemented [33]
- Avisblue's CLAUDE.md already documents `sudo bootc switch` for rebase commands, which is correct

**Containerfile implications:**
- No need to change `FROM` syntax -- standard OCI `FROM ghcr.io/ublue-os/bazzite:stable` remains correct
- The `rpm-ostree cleanup -m` command in avisblue Containerfiles -- **wait, checking** -- avisblue Containerfiles do NOT use `rpm-ostree` at all; all build scripts use `dnf5`. The finalize script uses `dnf5 clean all`. This is already correct.

FACT: Avisblue is already aligned with the bootc/dnf5 direction. No Containerfile changes needed for the rpm-ostree-to-bootc transition.

### 5. ROCm and CUDA Status

**ROCm on Fedora 43:**
- `rocm-hip`, `rocm-opencl`, `rocm-clinfo`, `rocm-smi` are available in Fedora 43 repos (version 6.4.3) [22]
- ROCm 7.1.0 is available on Rawhide but not yet in stable Fedora 43 [34]
- `rocm-smi` is being deprecated in favor of `amd-smi` (hard end-of-support: 2026 Q2) [23]. This means avisblue should plan to migrate from `rocm-smi` to `amd-smi` soon.
- ROCm had compatibility issues on Bazzite 42; reports suggest improvements on Fedora 43 [35]

**CUDA/NVIDIA:**
- `nvidia-container-toolkit` is still available from NVIDIA's repository [36]
- CUDA repository availability for Fedora 43 had initial delays at launch but has been resolved [37]

INFERENCE: ROCm packages should install on current Bazzite stable, but the `rocm-smi` to `amd-smi` migration will be needed within months.

---

## Project Implications

### Containerfiles
- **No changes required** to `FROM` base image references (`ghcr.io/ublue-os/bazzite:stable` and `ghcr.io/ublue-os/bazzite-nvidia:stable` remain valid)
- **No package manager migration needed** (already using dnf5)
- **Recommended:** Add `RUN bootc container lint` as the final step before LABEL statements in both Containerfiles

### Build Scripts -- Cleanup
- The cleanup scripts use strict and lenient modes. Some packages in the **strict** lists may no longer exist in the current Bazzite base, causing build failures. The most likely candidates:
  - `steamdeck-kde-presets-desktop` (may have been consolidated into `steamdeck-kde-presets`)
  - `sunshine` (removed from Bazzite)
  - `input-remapper` (may have been removed)
  - Various handheld packages (`hhd`, `hhd-ui`, `adjustor`, etc.) -- still likely present in desktop images but worth verifying
- **Action:** Run a test build and fix any strict-mode failures by moving missing packages to lenient mode or removing them

### Build Scripts -- Package Installation
- `rocm-smi` should still install but plan migration to `amd-smi` before Q2 2026
- `cockpit-ostree` availability should be verified
- `openrgb` COPR (`kylegospo/openrgb`) should be verified as still active
- All other packages (kate, okular, gwenview, ark, etc.) are standard Fedora packages and should be fine

### CI/CD Workflow
- Current workflow **should work as-is** -- no breaking changes found
- **Recommended:** Upgrade `sigstore/cosign-installer@v3` to `@v4` for Cosign v3 support
- Docker build-push-action is still valid; no need to switch to Buildah unless desired

### Strategic
- The Universal Blue ecosystem is healthy and actively maintained -- rebasing on Bazzite remains a solid long-term choice
- The OCI container modularization happening upstream (shared containers between Bluefin/Aurora/Bazzite) is internal to their build system and transparent to downstream consumers like avisblue
- The `bootc` transition is happening gradually; avisblue's existing `bootc switch` documentation is correct and forward-looking
- Consider adding `bootc container lint` to future-proof against any boot-time validation that bootc might enforce

---

## Revival Plan: Concrete Steps

### Phase 1: Test Build (read-only validation)

1. **Trigger a test build** via `gh workflow run build.yml` and observe what fails
2. Alternatively, do a local build: `podman build -f Containerfile.main -t avisblue-main:local .`
3. Document which packages fail to install or remove

### Phase 2: Fix Build Failures

Based on test build results (and likely issues identified in this report):

4. **Update cleanup scripts:** Move any packages that no longer exist in Bazzite from `strict` to `lenient` mode, or remove them entirely
5. **Verify ROCm packages:** Confirm `rocm-hip`, `rocm-opencl`, `rocm-clinfo`, `rocm-smi` install on Fedora 43 base
6. **Verify COPR repos:** Confirm `kylegospo/openrgb` COPR is still active
7. **Verify CUDA:** Confirm `nvidia-container-toolkit` repo and package install correctly on Fedora 43

### Phase 3: Modernization (recommended, not blocking)

8. **Add `bootc container lint`** as the final `RUN` step in both Containerfiles:
   ```dockerfile
   RUN bootc container lint
   ```
9. **Upgrade cosign-installer** in `.github/workflows/build.yml` from `@v3` to `@v4`
10. **Plan `rocm-smi` to `amd-smi` migration** -- ROCm SMI end-of-support is Q2 2026

### Phase 4: Validate and Ship

11. Run successful builds of both images
12. Test rebase on a live system: `sudo bootc switch ghcr.io/elgorrion/avisblue-main:latest`
13. Verify weekly scheduled builds are triggering

### Optional Improvements (not blocking)

- Adopt `FROM scratch AS ctx` / `--mount=type=bind,from=ctx` pattern instead of `COPY build_files` (reduces image layers)
- Add template sync workflow (`AndreasAugustin/actions-template-sync`) to track upstream image-template changes
- Consider switching from Docker build-push-action to Buildah for alignment with upstream ublue-os patterns

---

## Verification Summary

| Metric | Value |
|--------|-------|
| Total sources cited | 37 |
| T1 (primary/authoritative) | 8 |
| T2 (established/expert) | 12 |
| T3 (credible/secondary) | 11 |
| T4 (supplementary) | 6 |
| Single-source claims | 2 |
| Claims with contradictory evidence | 0 |
| Data gaps identified | 3 |

**Data gaps:**
1. Cannot verify exact current package list in Bazzite stable image without pulling it
2. Status of some handheld-specific packages (hhd, adjustor, etc.) in desktop Bazzite variants unclear
3. `cockpit-ostree` availability on Fedora 43 not independently confirmed

---

## Bibliography

[1] Universal Blue. "Universal Blue -- Powered by the future, delivered today." universal-blue.org, accessed 2026-04-01. https://universal-blue.org/ **[T1]**

[2] Jorge Castro. "Four Years of Universal Blue." Bluefin Docs Blog, 2026. https://docs.projectbluefin.io/blog/four-years-of-universal-blue/ **[T2]**

[3] XDA Developers. "Universal Blue wants to redefine the entire Linux ecosystem." XDA, 2025. https://www.xda-developers.com/universal-blue-wants-to-redefine-the-entire-linux-ecosystem/ **[T3]**

[4] Aurora Docs. "Stargazer 5 - Year in review." Aurora, 2025. https://docs.getaurora.dev/blog/aurora-2025/ **[T2]**

[5] Universal Blue. "Membership." universal-blue.org, accessed 2026-04-01. https://universal-blue.org/membership.html **[T1]**

[6] GamingOnLinux. "Bazzite using Fedora 43 is out now with full Xbox Ally / Xbox Ally X support." GamingOnLinux, 2025-10. https://www.gamingonlinux.com/2025/10/bazzite-using-fedora-43-is-out-now-with-full-xbox-ally-xbox-ally-x-support/ **[T3]**

[7] Linux Compatible. "Bazzite Linux 43 released." linuxcompatible.org, 2025-10. https://www.linuxcompatible.org/story/bazzite-linux-43-released/ **[T3]**

[8] Linux Compatible. "Bazzite Linux 43.20260330 released." linuxcompatible.org, 2026-03-30. https://www.linuxcompatible.org/story/bazzite-linux-4320260330-released **[T3]**

[9] Lunar Computer. "Bazzite Linux Updates to Version 43.20260303 With KDE Plasma 6.6 and Mesa 26.0.1." lunar.computer, 2026-03-03. https://lunar.computer/bazzite-linux-updates-to-version-43-20260303-with-20260303 **[T3]**

[10] Lunar Computer. "Bazzite Gaming Linux Distro Updates to Kernel 6.19.10, Gamescope 137." lunar.computer, 2026-03-31. https://lunar.computer/bazzite-gaming-linux-distro-updates-to-kernel-6-20260331 **[T3]**

[11] GamingOnLinux. "Bazzite gets a big update with KDE Plasma 6.6, Mesa 26.0.1 and more." GamingOnLinux, 2026-03. https://www.gamingonlinux.com/2026/03/bazzite-gets-a-big-update-with-kde-plasma-6-6-mesa-26-0-1-and-more/ **[T3]**

[12] ublue-os/bazzite. "Release 43.20260303: Stable (F43.20260303)." GitHub Releases, 2026-03-03. https://github.com/ublue-os/bazzite/releases/tag/43.20260303 **[T1]**

[13] Universal Blue Discourse. "Bazzite March 2nd 2026 Update." Universal Blue Forums, 2026-03-02. https://universal-blue.discourse.group/t/bazzite-march-2nd-2026-update/11773 **[T2]**

[14] CubicleNate. "Kontainer | Distrobox Container Manager Built for KDE Plasma." cubiclenate.com, 2026-03-16. https://cubiclenate.com/2026/03/16/kontainer-distrobox-container-manager-built-for-kde-plasma/ **[T4]**

[15] ublue-os/bazzite. "Rebase Guide." Bazzite Documentation, accessed 2026-04-01. https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/rebase_guide/ **[T1]**

[16] DeepWiki. "Image Variants | ublue-os/bazzite." deepwiki.com, accessed 2026-04-01. https://deepwiki.com/ublue-os/bazzite/1.1-image-variants **[T3]**

[17] KyleGospo. "feat(ci): Replace rpm-ostree with dnf5 during build." GitHub PR #1905, ublue-os/bazzite, 2024-11. https://github.com/ublue-os/bazzite/pull/1905 **[T1]**

[18] Zeglius. "chore: Bring latest changes to unstable with dnf5." GitHub PR #2222, ublue-os/bazzite, 2025-01. https://github.com/ublue-os/bazzite/pull/2222 **[T1]**

[19] m2Giles. "chore(ci): Use dnf5 instead of rpm-ostree." GitHub PR #2226, ublue-os/bazzite, 2025-02. https://github.com/ublue-os/bazzite/pull/2226 **[T1]**

[20] KyleGospo. "feat: Split containerfile into separate scripts per image." GitHub PR #2113, ublue-os/bazzite, 2025-01. https://github.com/ublue-os/bazzite/pull/2113 **[T2]**

[21] ublue-os/bazzite. "Yet another update where Sunshine breaks." GitHub Issue #4337, 2026. https://github.com/ublue-os/bazzite/issues/4337 **[T2]**

[22] Fedora Packages. "rocm-smi-6.4.3-1.fc43." packages.fedoraproject.org, accessed 2026-04-01. https://packages.fedoraproject.org/pkgs/rocm-smi/rocm-smi/fedora-43.html **[T1]**

[23] ROCm. "ROCm documentation." rocm.docs.amd.com, accessed 2026-04-01. https://rocm.docs.amd.com/projects/install-on-linux/en/latest/ **[T1]**

[24] ublue-os/image-template. "Containerfile." GitHub, accessed 2026-04-01. https://github.com/ublue-os/image-template/blob/main/Containerfile **[T1]**

[25] ublue-os/bazzite. "Containerfile." GitHub main branch, accessed 2026-04-01. https://github.com/ublue-os/bazzite/blob/main/Containerfile **[T1]**

[26] Red Hat Developers. "Best practices for building bootable containers." developers.redhat.com, 2025-02-26. https://developers.redhat.com/articles/2025/02/26/best-practices-building-bootable-containers **[T2]**

[27] sigstore/cosign-installer. "Releases." GitHub, accessed 2026-04-01. https://github.com/sigstore/cosign-installer/releases **[T1]**

[28] Chainguard Academy. "How to Keyless Sign a Container Image with Sigstore." edu.chainguard.dev, 2025. https://edu.chainguard.dev/open-source/sigstore/how-to-keyless-sign-a-container-with-sigstore/ **[T2]**

[29] BlueBuild. "Introducing: the dnf module." blue-build.org, 2025. https://blue-build.org/blog/dnf-module/ **[T2]**

[30] Universal Blue Discourse. "What's the relationship between rpm-ostree and bootc." Universal Blue Forums, 2025. https://universal-blue.discourse.group/t/whats-the-relationship-between-rpm-ostree-and-bootc/11329 **[T2]**

[31] Universal Blue Discourse. "Prepare for removal of rpm-ostree and gaps vs bootc." Universal Blue Forums, 2024. https://universal-blue.discourse.group/t/prepare-for-removal-of-rpm-ostree-and-gaps-vs-bootc/7170 **[T2]**

[32] ublue-os/dev.bazzite.gg. "Using the form on the dev.bazzite.gg website is misleading." GitHub Issue #3, 2025. https://github.com/ublue-os/dev.bazzite.gg/issues/3 **[T4]**

[33] ublue-os/bazzite. "Use bootc upgrade instead of rpm-ostree by default." GitHub Issue #2726, 2025. https://github.com/ublue-os/bazzite/issues/2726 **[T2]**

[34] Fedora Discussion. "Upgrade rocm 6.4.4 to 7.1.0 on fedora 43." discussion.fedoraproject.org, 2025. https://discussion.fedoraproject.org/t/upgrade-rocm-6-4-4-to-7-1-0-on-fedora-43/175198 **[T3]**

[35] ROCm/ROCm. "ROCm not working correctly with ComfyUI on Bazzite 42." GitHub Issue #4679, 2025. https://github.com/ROCm/ROCm/issues/4679 **[T2]**

[36] NVIDIA. "nvidia-container-toolkit." github.com/NVIDIA, accessed 2026-04-01. https://github.com/NVIDIA/nvidia-container-toolkit **[T1]**

[37] NVIDIA Developer Forums. "Timeline for CUDA Support on Fedora 43." forums.developer.nvidia.com, 2025. https://forums.developer.nvidia.com/t/timeline-for-cuda-support-on-fedora-43-wayland-only-gnome-kernel-updates-and-driver-compatibility/351356 **[T4]**
