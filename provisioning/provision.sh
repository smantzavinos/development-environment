#!/bin/bash
# abort this script on errors.
set -eux

# prevent apt-get et al from opening stdin.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update


#   config.vm.provision "install xfce", type: "shell" do |s|
#     s.inline = "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4"
#   end
  
#   # Permit anyone to start the GUI
#   config.vm.provision "allow anyone to start GUI", type: "shell" do |s|
#     s.inline = "sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config"
#   end

# install the desktop.
sudo apt-get install -y --no-install-recommends \
    xfce4 
    # xorg \
    # xserver-xorg-video-qxl \
    # xserver-xorg-video-fbdev \
    # xserver-xorg-video-vmware \
    # xfce4-terminal \
    # lightdm \
    # lightdm-gtk-greeter \
    # xfce4-whiskermenu-plugin \
    # xfce4-taskmanager \
    # menulibre \
    # firefox

# Permit anyone to start the GUI
sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config

# install useful tools.
sudo apt-get install -y --no-install-recommends git-all
sudo apt-get install -y --no-install-recommends neovim ripgrep
sudo apt-get install -y --no-install-recommends python2
sudo apt-get install -y --no-install-recommends inotify-tools
sudo apt-get install -y --no-install-recommends dnsutils
sudo apt-get install -y --no-install-recommends whois

# install certbot
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot

# set system configuration.
# rm -f /{root,home/*}/.{profile,bashrc}
# cp -v -r /vagrant/config/etc/* /etc

# apt-get remove -y --purge xscreensaver
# apt-get autoremove -y --purge

h=/home/vagrant


if [ ! -d $h/vimfiles ]; then
    pushd $h
    git clone https://github.com/smantzavinos/vimfiles.git
    popd
fi

if [ ! -d $h/.config ]; then
    mkdir $h/.config
fi

if [ ! -d $h/.config/nvim ]; then
    mkdir $h/.config/nvim
fi

if [ ! -f $h/.config/nvim/init.vim ]; then
    ln -s $h/vimfiles/_vimrc $h/.config/nvim/init.vim
fi

# asdf-erlang dependencies  for additioanl features (like debugging)
# See https://github.com/asdf-vm/asdf-erlang#before-asdf-install
# Note: Even with this change the debugger isn't working
sudo apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk

# asdf dependencies
sudo apt install -y --no-install-recommends curl

# Install asdf
if [ ! -d $h/.asdf ]; then
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
if [ ! -d $h/.local/share/nvim/site/autoload/plug.vim ]; then
    sh -c "curl -fLo $h/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
fi

# Manual build of coc-elixir
# The reason to build manually is to make sure it matches the same version
# of Elixir and OTP that are installed
if [ ! -d "$h/.elixir-ls" ]; then
    git clone https://github.com/elixir-lsp/elixir-ls.git $h/.elixir-ls
    pushd $h/.elixir-ls
    mix deps.get && mix compile && mix elixir_ls.release -o release
    popd
fi
# Set CocConifg to use the manually built coc-elxir
if [ ! -f $h/.config/nvim/coc-settings.json ]; then
    printf "{\n  \"elixir.pathToElixirLS\": \"~/.elixir-ls/release/language_server.sh\"\n}" > $h/.config/nvim/coc-settings.json
fi

export MYVIMRC=$h/vimfiles/_vimrc

# Vim install plugins
# NOTE: This doesn't seem to work correctly yet
nvim +PlugInstall +qall

# Instal Image Magick for image processing
sudo apt-get install -y --no-install-recommends imagemagick

# sudo apt install -y --no-install-recommends postgresql postgresql-contrib
# sudo -i -u postgres psql -c "CREATE USER postgres WITH PASSWORD 'postgres';"

# install fish shell
sudo apt-add-repository -y ppa:fish-shell/release-3
sudo apt-get update
sudo apt-get install -y fish

# install zsh
if [ -d ~/.oh-my-zsh ]; then
    echo "Skipping. oh-my-zsh is already installed"
else
    echo "Installing zsh..."
    sudo apt-get install -y --no-install-recommends zsh
    # Make ZSH the default shell
    sudo chsh -s $(which zsh)
    echo "zsh installed"

    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "oh-my-zsh installed"
fi

# install tmux
sudo apt install -y tmux

# Download dotfiles
if [ ! -d $h/dotfiles ]; then
    pushd $h
    git clone https://github.com/smantzavinos/dotfiles.git
    popd
fi

# tmux symlinks
if [ ! -f $h/.tmux.conf ]; then
    ln -s $h/dotfiles/.tmux.conf $h/.tmux.conf
fi

# fish shell symlinks
if [ ! -d $h/.config/fish ]; then
    mkdir $h/.config/fish
fi
if [ ! -f $h/.config/fish/config.fish ]; then
    ln -s $h/dotfiles/fish/config.fish $h/.config/fish/config.fish
fi
if [ ! -f $h/.config/fish/fish_plugins ]; then
    ln -s $h/dotfiles/fish/fish_plugins $h/.config/fish/fish_plugins
fi

# install fish plugins
fish <<'END_FISH'
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    fisher update
END_FISH

# install Packer
if [ -x "$(command -v packer)" ]; then
    printf "Packer already installed. No action taken. \n"
else
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install -y packer
fi

if [ -x "$(command -v docker)" ]; then
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
if [ -x "$(command -v docker)" ]; then
    # update terraform
    printf "Terraform already installed. No action taken. \n"
else
    printf "Installing Terraform... \n"
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform
fi

# configure git to use nvim as the default editor
git config --global core.editor "nvim"

# Uncomment these lines if you want to configure the git user
# git config --global user.name "Spiros Mantzavinos"
# git config --global user.email "smantzavinos@gmail.com"
