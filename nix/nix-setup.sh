#!/usr/bin/env bash
set -e

# Install basic dependencies
if [ -f /etc/debian_version ]; then
    sudo apt update
    sudo apt install -y git zsh curl xz-utils tar docker.io
    sudo addgroup --system docker || true
    sudo usermod -aG docker $USER || true
elif [ -f /etc/redhat-release ]; then
    sudo dnf install -y git zsh curl xz tar docker
    sudo groupadd --system docker || true
    sudo usermod -aG docker $USER || true
fi

rm -rf ~/.oh-my-zsh > /dev/null
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended


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
echo "=== Change the default shell to zsh ==="
echo "$HOME/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
sudo chsh -s "$(which zsh)" "$USER"
