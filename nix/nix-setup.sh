#!/usr/bin/env bash
set -e

# Install basic dependencies
if [ -f /etc/debian_version ]; then
    sudo apt update
    sudo apt install -y curl xz-utils tar docker.io
elif [ -f /etc/redhat-release ]; then
    sudo dnf install -y curl xz tar docker
fi

sudo addgroup --system docker
sudo usermod -aG docker $USER

# Install Nix (single-user)
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Load Nix profile
. "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Pin Nixpkgs to 25.05
nix-channel --add https://nixos.org/channels/nixos-25.05 nixpkgs
nix-channel --update

nix-env -iA nixpkgs.home-manager

# Prepare Home Manager config directory and symlink your config.nix
mkdir -p ~/.config/home-manager
ln -sf "$(pwd)/config.nix" ~/.config/home-manager/home.nix

# Apply configuration
home-manager switch

echo "=== Home Manager 25.05 setup complete! ==="

