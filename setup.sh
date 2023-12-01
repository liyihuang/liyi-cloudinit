#!/usr/bin/env bash

set -euo pipefail

echo "force download oh my tmux and link the config"
rm -rf ~/.tmux > /dev/null
git clone https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
ln -s -f ~/liyi-cloudinit/tmux.conf.local ~/.tmux.conf.local

echo "force download the vim config and link the config"
rm -rf ~/.vim_runtime > /dev/null
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
ln -s -f ~/liyi-cloudinit/my_configs.vim ~/.vim_runtime/my_configs.vim
  
echo "force link the gitconfig"
rm ~/.gitignore > /dev/null
ln -s -f ~/liyi-cloudinit/global_gitignore ~/.gitignore
rm ~/.gitconfig > /dev/null
ln -s -f ~/liyi-cloudinit/gitconfig ~/.gitconfig

echo "download oh my zsh"
rm -rf ~/.oh-my-zsh > /dev/null
sh -c "$(curl -fsSL https://raw.githubusercontent.com/coreycole/oh-my-zsh/master/tools/install.sh)" --unattended
ln -s -f ~/liyi-cloudinit/zshrc ~/.zshrc

echo "install fzf"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all


echo "installing the kubeps1"
curl -o ~/.kube-ps1.sh -L https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh
sudo echo "source ~/.kube-ps1.sh" >>~/.zshrc
sudo echo PROMPT=\'\$\(kube_ps1\)\''$PROMPT' >>~/.zshrc

echo "installing the kubechc"
git clone https://github.com/aabouzaid/kubech ~/.kubech
sudo echo 'source ~/.kubech/kubech' >> ~/.zshrc
sudo echo 'source ~/.kubech/completion/kubech.bash' >> ~/.zshrc