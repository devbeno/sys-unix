# Default Vars

: ${PACKAGE_DIR:=pkglists}

# Core ABI functions, sources distro specific interface as a hook for each

common::home_setup() {
    distro::home_setup
}

common::user_setup() {
    distro::user_setup
}

common::package_manager_setup() {
    distro::package_manager_setup
}

common::install_pkglists() {
    distro::install_pkglists
    common::pip_setup_n_install
}

common::git_setup() {
    git config --global user.name "devbens"
    git config --global user.email "benjophp@gmail.com"
    git config --global user.useConfigOnly "true"
    git config --global pull.rebase false # default strategy
    distro::git_setup
}

common::clone_dotfiles() {
    if git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status; then
        git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" pull
    else
        git clone --bare https://github.com/devbens/dotfiles ~/.dotfiles
        git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" config status.showUntrackedFiles no
    fi
    git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" checkout --force master
    distro::clone_dotfiles
}

common::service_setup() {
    distro::service_setup
}

common::firewall_setup() {
    distro::firewall_setup
}

common::utility_setup() {
    common::vim_setup
    distro::utility_setup
}

common::kernel_setup() {
    distro::kernel_setup
}

# Main function to initiate Bootstrap
common::run_bootstrap() {
    DISTRO_INTERFACE="$1"

    source "$DISTRO_INTERFACE"

    common::home_setup
    common::user_setup
    common::package_manager_setup
    common::install_pkglists
    common::git_setup
    common::clone_dotfiles
    common::service_setup
    common::firewall_setup
    common::utility_setup
    common::kernel_setup
}

# Implementation Functions

common::pip_setup_n_install() {
    python3 -m pip install --upgrade pip
    pip3 install --user $(grep '^\w' $PACKAGE_DIR/pip_desired.list)
}

common::vim_setup() {
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    VIM_PLUG_INSTALL="$(mktemp)"
    cat <<EOF > "$VIM_PLUG_INSTALL"
:PlugInstall!
:sleep 35
:qa!
EOF
    vim -s "$VIM_PLUG_INSTALL"
    rm -f "$VIM_PLUG_INSTALL"
}