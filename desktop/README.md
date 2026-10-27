# Desktop & GUI App Setup

This directory contains standalone setup scripts for machines where a graphical desktop environment or desktop (GUI) applications are needed.

It is intentionally separated from `nix/nix-setup.sh` so that headless and server environments remain minimal and lightweight.

## Usage

### Full Desktop Setup (Desktop Environment + Flatpak)
On a fresh machine or server without a desktop:
```bash
./desktop/desktop-setup.sh
```
This will:
1. Detect if a desktop is installed (installs GNOME + GDM if none is present).
2. Configure GDM to use Xorg if an NVIDIA GPU is detected.
3. Install **Flatpak** and the **GNOME Software Flatpak plugin**.
4. Configure the **Flathub** repository.

### Flatpak Only (on existing desktop)
If a desktop environment is already installed:
```bash
./desktop/desktop-setup.sh --flatpak-only
```

## Managing GUI Apps via Flatpak

Once installed, you can search and install GUI applications from the terminal or graphically via GNOME Software.

```bash
# Search for apps
flatpak search <name>

# Install an app from Flathub
flatpak install flathub md.obsidian.Obsidian
flatpak install flathub com.google.Chrome
flatpak install flathub com.discordapp.Discord
flatpak install flathub com.spotify.Client

# Run an app
flatpak run <app-id>

# Update apps
flatpak update
```
