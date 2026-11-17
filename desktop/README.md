# Desktop & GUI App Setup

This directory contains standalone setup scripts for machines where a graphical desktop environment or desktop (GUI) applications are needed.

It is intentionally separated from `nix/nix-setup.sh` so that headless and server environments remain minimal and lightweight.

## Usage

```bash
./desktop/desktop-setup.sh
```
No arguments are needed. The script is safe to re-run on a machine that already has a desktop; it skips anything already installed. It will:
1. Detect if a desktop is installed (installs GNOME + GDM if none is present).
2. Configure GDM to use Xorg if an NVIDIA GPU is detected.
3. Install **Flatpak** and the **GNOME Software Flatpak plugin**.
4. Configure the **Flathub** repository.
5. Install every app listed in `flatpaks.txt` (skipping ones already installed).
6. Install **snapd**, then every snap listed in `snaps.txt` (skipping ones already installed). Use this only as a fallback for GUI apps that aren't on Flathub, e.g. `ghostty --classic`. Prefer Flatpak, then the distro's own package, then snap.

## Managing GUI Apps via Flatpak

The desired app set lives in `flatpaks.txt` (one Flathub app ID per line, `#` for comments). Add or remove IDs there and re-run `./desktop/desktop-setup.sh` to apply additions.

```bash
# Search for apps
flatpak search <name>

# Ad-hoc install (add the ID to flatpaks.txt to make it permanent)
flatpak install flathub <app-id>

# Run an app
flatpak run <app-id>

# Update apps
flatpak update
```
