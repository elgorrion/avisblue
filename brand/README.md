# Avisblue brand source

## Mark variants

| File | Stroke | Use |
|---|---|---|
| `avisblue-mark-source.svg` | original (black) | provenance copy; never edited |
| `avisblue-mark.svg` | `#5BA0D9` (primary) | canonical tinted mark |
| `avisblue-mark-light.svg` | `#ECF1F8` (foreground) | dark-BG surfaces (Plymouth, SDDM, splash, wallpaper) |
| `avisblue-mark-dark.svg` | `#11243B` (deep BG) | light-BG surfaces |
| `avisblue-mark-rust.svg` | `#D8854A` (rust) | reserved accent placements |

Each variant is a one-line sed of the source: a `fill="${HEX}"` attribute added to the existing `<g>` wrapper.

## Source provenance

`source/asset-125.{svg,eps,png}` and `source/ascii-125.txt` are the original asset files purchased from **Awancreativestudio** on Etsy. Licensed for commercial use and redistribution. Do not edit `source/`.

## Regenerating raster derivatives

Run `scripts/generate-brand-assets.sh` from repo root. The script uses a transient podman container (no host-side dependencies) to produce all PNG / ICO / JXL / SVGZ files under `system_files/`.
