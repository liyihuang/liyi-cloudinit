#!/usr/bin/env bash


echo "installing the kubectx"
sudo snap install kubectx --classic

echo "installing the docker"
sudo snap install docker
sudo addgroup --system docker
sudo adduser liyih docker
newgrp docker
sudo snap disable docker
sudo snap enable docker

echo "Installing Kubectl(copy and paste from https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)"
sudo snap install kubectl --classic

echo "installing terraform (copy and paste from https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)"
sudo snap install terraform --classic

echo "installaing the helm"
sudo snap install helm --classic

echo "installing the cilium CLI"
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz

echo "installing the hubble"

HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
HUBBLE_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/${HUBBLE_VERSION}/hubble-linux-${HUBBLE_ARCH}.tar.gz
sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${HUBBLE_ARCH}.tar.gz


echo "installing the kubecm"
curl -Lo /tmp/kubecm.tar.gz https://github.com/sunny0826/kubecm/releases/download/v0.25.0/kubecm_v0.25.0_Linux_x86_64.tar.gz
tar -zxvf /tmp/kubecm.tar.gz kubecm
sudo mv kubecm /usr/local/bin/
rm -rf /tmp/kubecm.tar.gz

echo "installing pulumi"
curl -fsSL https://get.pulumi.com | sh

echo "installing the github gh cli"
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh -y

echo "installing syncthing"
sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
sudo apt-get update && sudo apt-get install syncthing
sync_id=$(syncthing generate | grep Device | awk -F ": " '{print $3}')
sudo systemctl enable syncthing@liyih.service
sudo systemctl start syncthing@liyih.service
while ! (curl -s 127.0.0.1:8384 >/dev/null); do
    echo "Waiting for Syncthing to be available..."
    sleep 1
done

syncthing cli config devices add --device-id RTRGH3U-EB3JU4L-LPUZFXC-XEPIO5I-HDA3RD4-IOHOXG2-RXRPG34-BTK53A3
syncthing cli config folders default devices add --device-id RTRGH3U-EB3JU4L-LPUZFXC-XEPIO5I-HDA3RD4-IOHOXG2-RXRPG34-BTK53A3
curl -X POST -d "${sync_id}" http://127.0.0.1:8000/syncid

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
rm -rf ~/.gitignore > /dev/null
ln -s -f ~/liyi-cloudinit/global_gitignore ~/.gitignore
rm -rf ~/.gitconfig > /dev/null
ln -s -f ~/liyi-cloudinit/gitconfig ~/.gitconfig

echo "download oh my zsh"
rm -rf ~/.oh-my-zsh > /dev/null
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
ln -s -f ~/liyi-cloudinit/zshrc ~/.zshrc

echo "install fzf"
rm -rf ~/.fzf > /dev/null
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all


echo "installing the kubeps1"
rm -rf ~/.kube-ps1.sh
curl -o ~/.kube-ps1.sh -L https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh
echo "source ~/.kube-ps1.sh" >>~/.zshrc
echo PROMPT=\'\$\(kube_ps1\)\''$PROMPT' >>~/.zshrc

echo "installing the kubechc"
rm -rf  ~/.kubech
git clone https://github.com/aabouzaid/kubech ~/.kubech
echo 'source ~/.kubech/kubech' >> ~/.zshrc
echo 'source ~/.kubech/completion/kubech.bash' >> ~/.zshrc
