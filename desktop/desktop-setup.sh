#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Desktop & GUI App Manager Setup ==="

# Parse arguments
INSTALL_DESKTOP=true
for arg in "$@"; do
  case "$arg" in
    --flatpak-only)
      INSTALL_DESKTOP=false
      ;;
  esac
done

# 1. Desktop Environment (installed only when needed on headless systems)
if [ "$INSTALL_DESKTOP" = true ]; then
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

echo ""
echo "=== Desktop & Flatpak setup complete! ==="
echo "You can now install GUI applications using Flatpak:"
echo "  flatpak install flathub <app-id>"
echo ""
echo "Examples:"
echo "  flatpak install flathub md.obsidian.Obsidian"
echo "  flatpak install flathub com.google.Chrome"
echo "  flatpak install flathub com.discordapp.Discord"
echo "  flatpak install flathub com.spotify.Client"
