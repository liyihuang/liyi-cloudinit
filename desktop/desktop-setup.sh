#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Desktop & GUI App Manager Setup ==="

# 1. Desktop Environment (installed only when needed on headless systems)
if [ -f /etc/debian_version ]; then
  if ! dpkg -s gnome-shell &>/dev/null && ! dpkg -s xfce4-session &>/dev/null; then
    echo "No desktop environment detected. Installing GNOME desktop (gdm3, ubuntu-session, gnome-shell)..."
    sudo apt update
    sudo apt install -y gdm3 ubuntu-session gnome-shell
  else
    echo "Desktop environment is already installed."
  fi

  # Configure GDM for NVIDIA compatibility if NVIDIA GPU is detected
  if lspci 2>/dev/null | grep -qi nvidia && [ -f /etc/gdm3/custom.conf ]; then
    if ! grep -q "^WaylandEnable=false" /etc/gdm3/custom.conf; then
      echo "Configuring GDM to use Xorg for NVIDIA compatibility..."
      sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
    fi
  fi
elif [ -f /etc/redhat-release ]; then
  if ! rpm -q gnome-shell &>/dev/null; then
    echo "Installing GNOME desktop on RedHat/Fedora..."
    sudo dnf groupinstall -y "Server with GUI" || sudo dnf groupinstall -y "GNOME Desktop"
  fi
fi

# 2. Install Flatpak & GNOME Software integration
echo "=== Installing Flatpak ==="
if [ -f /etc/debian_version ]; then
  FLATPAK_PKGS=(flatpak)
  if dpkg -s gnome-software &>/dev/null || dpkg -s gnome-shell &>/dev/null; then
    FLATPAK_PKGS+=(gnome-software-plugin-flatpak)
  fi

  MISSING_FLATPAK_PKGS=()
  for pkg in "${FLATPAK_PKGS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      MISSING_FLATPAK_PKGS+=("$pkg")
    fi
  done

  if [ ${#MISSING_FLATPAK_PKGS[@]} -gt 0 ]; then
    echo "Installing packages: ${MISSING_FLATPAK_PKGS[*]}..."
    sudo apt update
    sudo apt install -y "${MISSING_FLATPAK_PKGS[@]}"
  else
    echo "Flatpak packages are already installed."
  fi

elif [ -f /etc/redhat-release ]; then
  if ! rpm -q flatpak &>/dev/null; then
    sudo dnf install -y flatpak
  fi
fi

# 3. Add Flathub remote repository
if command -v flatpak &>/dev/null; then
  echo "Configuring Flathub repository..."
  if [ "$EUID" -eq 0 ] || sudo -n true 2>/dev/null; then
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  else
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo || \
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  fi
  echo "Flathub repository is configured."
fi

# 4. Prepare Flatpak user export directory
mkdir -p "$HOME/.local/share/flatpak/exports/share/applications"

# 5. Install apps listed in flatpaks.txt
MANIFEST="$SCRIPT_DIR/flatpaks.txt"
if command -v flatpak &>/dev/null && [ -f "$MANIFEST" ]; then
  echo "=== Installing Flatpak apps from flatpaks.txt ==="
  while IFS= read -r app || [ -n "$app" ]; do
    app="${app%%#*}"
    app="$(echo "$app" | xargs)"
    [ -z "$app" ] && continue
    if flatpak info "$app" &>/dev/null; then
      echo "$app is already installed."
    else
      echo "Installing $app..."
      flatpak install -y --noninteractive flathub "$app" || echo "WARNING: failed to install $app"
    fi
  done < "$MANIFEST"
fi

# 6. Install snapd and the fallback snaps listed in snaps.txt (apps not available on Flathub)
echo "=== Installing Snap ==="
if ! command -v snap &>/dev/null; then
  if [ -f /etc/debian_version ]; then
    sudo apt update
    sudo apt install -y snapd
  elif [ -f /etc/redhat-release ]; then
    echo "WARNING: snapd is not in the default Fedora/RHEL repositories; skipping snaps."
  fi
else
  echo "Snap is already installed."
fi

SNAP_MANIFEST="$SCRIPT_DIR/snaps.txt"
if command -v snap &>/dev/null && [ -f "$SNAP_MANIFEST" ]; then
  echo "=== Installing snaps from snaps.txt ==="
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [ -z "$line" ] && continue
    read -r -a snap_args <<< "$line"
    if snap list "${snap_args[0]}" &>/dev/null; then
      echo "${snap_args[0]} is already installed."
    else
      echo "Installing ${snap_args[0]}..."
      sudo snap install "${snap_args[@]}" || echo "WARNING: failed to install ${snap_args[0]}"
    fi
  done < "$SNAP_MANIFEST"
fi

echo ""
echo "=== Desktop & Flatpak setup complete! ==="
echo "Apps are managed in desktop/flatpaks.txt; re-run this script to install new entries."
echo "Ad-hoc install: flatpak install flathub <app-id>"
