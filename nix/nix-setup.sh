#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install basic dependencies
if [ -f /etc/debian_version ]; then
  MISSING_PKGS=()
  for pkg in git zsh curl xz-utils tar; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      MISSING_PKGS+=("$pkg")
    fi
  done
  if ! command -v docker &>/dev/null && ! dpkg -s docker.io &>/dev/null && ! dpkg -s docker-ce &>/dev/null; then
    MISSING_PKGS+=(docker.io)
  fi
  if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    sudo apt update
    sudo apt install -y "${MISSING_PKGS[@]}"
  fi
  if getent group docker >/dev/null; then
    if ! id -nG "$USER" | grep -qw docker; then
      sudo usermod -aG docker "$USER" || true
    fi
  else
    sudo addgroup --system docker || true
    sudo usermod -aG docker "$USER" || true
  fi
elif [ -f /etc/redhat-release ]; then
  MISSING_PKGS=()
  for pkg in git zsh curl xz tar; do
    if ! rpm -q "$pkg" &>/dev/null; then
      MISSING_PKGS+=("$pkg")
    fi
  done
  if ! command -v docker &>/dev/null && ! rpm -q docker &>/dev/null && ! rpm -q docker-ce &>/dev/null; then
    MISSING_PKGS+=(docker)
  fi
  if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    sudo dnf install -y "${MISSING_PKGS[@]}"
  fi
  if getent group docker >/dev/null; then
    if ! id -nG "$USER" | grep -qw docker; then
      sudo usermod -aG docker "$USER" || true
    fi
  else
    sudo groupadd --system docker || true
    sudo usermod -aG docker "$USER" || true
  fi
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Nix (single-user) if not already installed
if ! command -v nix &>/dev/null && [ ! -d /nix ]; then
  sh <(curl -L https://nixos.org/nix/install) --no-daemon
fi

# Load Nix profile
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -f /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
fi

# Pin Nixpkgs to 26.05
if ! nix-channel --list | grep -q 'nixos-26.05'; then
  nix-channel --add https://nixos.org/channels/nixos-26.05 nixpkgs
  nix-channel --update
fi

# Install Home Manager if not present
if ! command -v home-manager &>/dev/null; then
  nix-env -iA nixpkgs.home-manager
fi

# Prepare Home Manager config directory and symlink your config.nix
mkdir -p ~/.config/home-manager
ln -sf "$SCRIPT_DIR/config.nix" ~/.config/home-manager/home.nix

# Apply configuration
home-manager switch
echo "=== Home Manager 26.05 setup complete! ==="

# Set default shell to zsh
NIX_ZSH="$HOME/.nix-profile/bin/zsh"
ZSH_BIN="$(command -v zsh || true)"

if [ -x "$NIX_ZSH" ]; then
  TARGET_ZSH="$NIX_ZSH"
elif [ -n "$ZSH_BIN" ]; then
  TARGET_ZSH="$ZSH_BIN"
else
  TARGET_ZSH=""
fi

if [ -n "$TARGET_ZSH" ]; then
  if ! grep -qxF "$TARGET_ZSH" /etc/shells; then
    echo "=== Adding $TARGET_ZSH to /etc/shells ==="
    echo "$TARGET_ZSH" | sudo tee -a /etc/shells
  fi

  CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
  if [ "$CURRENT_SHELL" != "$TARGET_ZSH" ]; then
    echo "=== Changing default shell to $TARGET_ZSH ==="
    sudo chsh -s "$TARGET_ZSH" "$USER"
  fi
fi
