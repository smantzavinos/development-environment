#!/bin/bash
# abort this script on errors.
set -eux

# prevent apt-get et al from opening stdin.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update

# install the desktop.
sudo apt-get install -y --no-install-recommends xfce4 

# Permit anyone to start the GUI
sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config

# install useful tools.
sudo apt-get install -y --no-install-recommends git-all
sudo apt-get install -y --no-install-recommends neovim
sudo apt-get install -y --no-install-recommends python2
sudo apt-get install -y --no-install-recommends inotify-tools
sudo apt-get install -y --no-install-recommends dnsutils
sudo apt-get install -y --no-install-recommends whois
sudo apt-get install -y --no-install-recommends jq
sudo apt-get install -y --no-install-recommends fzf
sudo apt-get install -y --no-install-recommends -o Dpkg::Options::="--force-overwrite" bat ripgrep
sudo apt-get install -y --no-install-recommends cloud-init

# TODO: Need to add the HashiCorp repo before we can install. Instructions here:
# https://www.hashicorp.com/official-packaging-guide
# sudo apt-get install -y --no-install-recommends terraform-ls


# install certbot
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot

h=/home/vagrant

if [[ ! -d "$h/vimfiles" ]]; then
    pushd $h
    git clone https://github.com/smantzavinos/vimfiles.git
    popd
else
    pushd $h/vimfiles
    git pull
    popd
fi

if [[ ! -d "$h/.config" ]]; then
    mkdir $h/.config
fi

if [[ ! -d "$h/.config/nvim" ]]; then
    mkdir $h/.config/nvim
fi

if [[ ! -f "$h/.config/nvim/init.vim" ]]; then
    ln -s $h/vimfiles/_vimrc $h/.config/nvim/init.vim
fi

# asdf-erlang dependencies  for additioanl features (like debugging)
# See https://github.com/asdf-vm/asdf-erlang#before-asdf-install
# Note: Even with this change the debugger isn't working
sudo apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk

# asdf dependencies
sudo apt install -y --no-install-recommends curl

# Install asdf
if [[ ! -d "$h/.asdf" ]]; then
    git clone https://github.com/asdf-vm/asdf.git $h/.asdf --branch v0.8.1
    echo ". $h/.asdf/asdf.sh" >> $h/.bashrc 
    echo ". $h/.asdf/completions/asdf.bash" >> $h/.bashrc 
fi

source $h/.bashrc
. $h/.asdf/asdf.sh

# Install node
asdf plugin add nodejs || { echo "asdf nodejs plugin already installed"; }
asdf install nodejs latest
asdf install nodejs lts
asdf global nodejs lts

# Install Erlang and Elixir
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update
sudo apt-get install -y --no-install-recommends esl-erlang
sudo apt-get install -y --no-install-recommends elixir

# Install vim plug
if [[ ! -d "$h/.local/share/nvim/site/autoload/plug.vim" ]]; then
    sh -c "curl -fLo $h/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
fi

# Manual build of coc-elixir
# The reason to build manually is to make sure it matches the same version
# of Elixir and OTP that are installed
if [[ ! -d "$h/.elixir-ls" ]]; then
    git clone https://github.com/elixir-lsp/elixir-ls.git $h/.elixir-ls
    pushd $h/.elixir-ls
    mix deps.get && mix compile && mix elixir_ls.release -o release
    popd
fi
# Set CocConifg to use the manually built coc-elxir
if [[ ! -f "$h/.config/nvim/coc-settings.json" ]]; then
    printf "{\n  \"elixir.pathToElixirLS\": \"~/.elixir-ls/release/language_server.sh\"\n}" > $h/.config/nvim/coc-settings.json
fi

export MYVIMRC=$h/vimfiles/_vimrc

# Vim install plugins
# NOTE: This doesn't seem to work correctly yet
nvim +PlugInstall +qall

# Instal Image Magick for image processing
sudo apt-get install -y --no-install-recommends imagemagick

# install fish shell
sudo apt-add-repository -y ppa:fish-shell/release-3
sudo apt-get update
sudo apt-get install -y fish

# install zsh
if [[ -x "$(command -v zsh)" ]]; then
    echo "zsh is already installed. No action taken."
else
    echo "Installing zsh..."
    sudo apt-get install -y --no-install-recommends zsh

    # Make ZSH the default shell
    sudo chsh -s $(which zsh) vagrant

    echo "zsh installed"
fi

if [[ ! -d "$h/.oh-my-zsh" ]]; then
    printf "Installing oh-my-zsh... "
    # Install manually (not using install script) to make sure it installs for
    # the correct user
    git clone https://github.com/ohmyzsh/ohmyzsh.git $h/.oh-my-zsh

    printf "oh-my-zsh installed \n"
fi

# Install powerlevel10k oh-my-zsh theme
theme_dir=${ZSH_CUSTOM:-$h/.oh-my-zsh/custom}/themes/powerlevel10k
if [[ ! -d "$theme_dir" ]]; then
    printf "Cloning powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $theme_dir
    printf "Done cloning powerlevel10k theme... \n"
else
    echo "powerlevel10k dir already exists"
fi

# Set the theme to powerlevel10k
# Note: the first time this is run the .zshrc does not yet exist so this line fails.
# For now it just moves on. Should figure out how to fix. When exactly is .zshrc created?
# Maybe just launching a zsh shell somehow will create the initial zshrc file
sed -i 's|ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$h/.zshrc" || true

# Install fzf-tab to reploace default zsh auto-completion with fzf
fzf_tab_dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
if [[ ! -d "$fzf_tab_dir" ]]; then
    printf "Cloning fzf-tab plugin..."
    git clone https://github.com/Aloxaf/fzf-tab $fzf_tab_dir
    printf "Done cloning fzf-tab plugin... \n"
else
    echo "Pulling updates for fzf-tab plugin"
    pushd $fzf_tab_dir
    git pull
    popd
fi

# install tmux
sudo apt install -y tmux

# Download dotfiles
if [[ ! -d "$h/dotfiles" ]]; then
    pushd $h
    git clone https://github.com/smantzavinos/dotfiles.git
    popd
else
    pushd $h/dotfiles
    git pull
    popd
fi

# tmux symlinks
if [[ ! -f "$h/.tmux.conf" ]]; then
    ln -s $h/dotfiles/.tmux.conf $h/.tmux.conf
fi

# install tmux plugin manager
if [[ ! -d "$h/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm $h/.tmux/plugins/tpm
fi

# Install tmux plugins
$h/.tmux/plugins/tpm/bin/install_plugins

# fish shell symlinks
if [[ ! -d "$h/.config/fish" ]]; then
    mkdir $h/.config/fish
fi
if [[ ! -f "$h/.config/fish/config.fish" ]]; then
    ln -s $h/dotfiles/fish/config.fish $h/.config/fish/config.fish
fi
if [[ ! -f "$h/.config/fish/fish_plugins" ]]; then
    ln -s $h/dotfiles/fish/fish_plugins $h/.config/fish/fish_plugins
fi

# zsh symlink
ln -sf $h/dotfiles/zsh/.zshrc $h/.zshrc
# powerlevel10k theme config symlink
ln -sf $h/dotfiles/zsh/.p10k.zsh $h/.p10k.zsh

# install fish plugins
fish <<'END_FISH'
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    fisher update
END_FISH

# install emacs 28
# "$(emacs --version | grep -Po "(\d+\.+\d)")"
# if [ "$(emacs --version | grep -Po "(\d+\.+\d)")" = "26.3" ]; then 
#     echo "match"
# else
# fi

# install GitHub CLI
if [[ -x "$(command -v gh)" ]]; then
    # Upgrade
    printf "Upgrading GitHub CLI \n"
    sudo apt update
    # This is failing for some reason. Ignore error for now
    sudo apt install gh || true
else
    printf "Installing GitHub CLI \n"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh

    # install github completion for ZSH shell
    gh completion -s zsh > sudo /usr/local/share/zsh/site-functions/_gh
fi

# install Packer
if [[ -x "$(command -v packer)" ]]; then
    printf "Packer already installed. No action taken. \n"
else
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install -y packer
fi

if [[ -x "$(command -v docker)" ]]; then
    printf "Docker already installed. No action taken. \n"
else
    printf "Installing Docker... \n"
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
fi

# install terraform
if [[ -x "$(command -v terraform)" ]]; then
    # update terraform
    printf "Terraform already installed. No action taken. \n"
else
    printf "Installing Terraform... \n"
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform
fi

# install aws cli
if [[ -x "$(command -v aws)" ]]; then
    printf "aws-cli already installed. No action taken. \n"
else
    printf "Installing aws-cli... \n"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -tq awscliv2.zip
    sudo ./aws/install
fi

# install cloud-nuke tool
if [[ -x "$(command -v cloud-nuke)" ]]; then
    printf "cloud-nuke already installed. No action taken. \n"
else
    printf "Installing cloud-nuke... \n"
    wget https://github.com/gruntwork-io/cloud-nuke/releases/download/v0.11.3/cloud-nuke_linux_amd64
    sudo mv cloud-nuke_linux_amd64 /usr/local/bin/cloud-nuke
    sudo chmod u+x /usr/local/bin/cloud-nuke
fi

# configure git to use nvim as the default editor
git config --global core.editor "nvim"

# Uncomment these lines if you want to configure the git user
# git config --global user.name "Spiros Mantzavinos"
# git config --global user.email "smantzavinos@gmail.com"
