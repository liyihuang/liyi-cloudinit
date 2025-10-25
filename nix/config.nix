{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "25.05";
  
#  programs.zsh = {
#    enable = true;
#    oh-my-zsh = {
#      enable = true;
#      theme = "simple";
#      plugins = [ "git" "kubectl" "tmux" "fzf" "kube-ps1" ];
#    };
#    
#    shellAliases = {
#      cilium_dbg = "kubectl -n kube-system exec ds/cilium -- cilium-dbg";
#      cilium_restart = "kubectl rollout restart deployment cilium-operator -n kube-system; kubectl rollout restart ds/cilium -n kube-system";
#      nginx_deployment = "kubectl create deployment nginx --image=nginx --replicas=10";
#      kn = "kubectl -n kube-system";
#      keof = "cat <<EOF | kubectl apply -f -";
#    };
#    
#    sessionVariables = {
#      EDITOR = "vim";
#      DISABLE_UNTRACKED_FILES_DIRTY = "true";
#    };
#    
#    initContent = ''
#      ZSH_TMUX_AUTOSTART=true
#      ZSH_TMUX_AUTOQUIT=false
#    '';
#  };

#  programs.git = {
#    enable = true;
#    userName = "Liyi Huang";
#    userEmail = "pdshly@gmail.com";
#
#    extraConfig = {
#      color.ui = "auto";
#      core = {
#        editor = "vim";
#        fileMode = false;
#      };
#      credential."https://github.com" = {
#        helper = "!gh auth git-credential";
#      };
#      "oh-my-zsh".hide-dirty = 1;
#      safe.directory = "/work";
#      init.defaultBranch = "main";
#      pull.rebase = true;
#    };
#  };



home.file = {
  ".tmux.conf".source = ./dotfiles/tmux/.tmux.conf;
  ".tmux.conf.local".source = ./dotfiles/tmux.conf.local;
  ".vim_runtime".source = ./dotfiles/vim_runtime;
  ".vim_runtime.local".source = ./dotfiles/my_configs.vim;
  ".zshrc" = {
  source = ./dotfiles/zshrc;
  force = true;
};

  ".gitconfig".source = ./dotfiles/gitconfig;
  ".gitignore".source = ./dotfiles/global_gitignore;
};

programs.vim = {
  enable = true;

  extraConfig = ''
    set runtimepath+=~/.vim_runtime

    source ~/.vim_runtime/vimrcs/basic.vim
    source ~/.vim_runtime/vimrcs/filetypes.vim
    source ~/.vim_runtime/vimrcs/plugins_config.vim
    source ~/.vim_runtime/vimrcs/extended.vim
    source ~/.vim_runtime.local
  '';
};

  home.packages = with pkgs; [
    zsh
    tmux
    jq
    yq
    tmate
    termshark
    gnumake
    go
    pulumi
    gh
    fzf
    atuin
    tree
    

    # GUI over SSH
    openbox
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.xauth
    xorg.xinit
    xorg.xclock
    xorg.xeyes

    # Kubernetes & tooling
    kubectl
    kubectx
    kubecm
    kubernetes-helm
    kind
    cilium-cli
    hubble
    terraform  
    awscli2
    google-cloud-sdk
  ];
}
