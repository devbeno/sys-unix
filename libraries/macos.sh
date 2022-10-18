# Interface Hooks

distro::home_setup() { :; }
distro::user_setup() { :; }
distro::package_manager_setup() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

distro::install_pkglists() {
    brew install $(cat $PACKAGE_DIR/brew_formulas.list | grep '^\w')
    brew install --cask $(cat $PACKAGE_DIR/brew_casks.list | grep '^\w')
}

distro::git_setup() {
    gh auth login
    {
        mkdir -p ~/Projects/Github
        cd ~/Projects/Github
        echo "Cloning git repos..."
        for REPO in $(gh repo list -L 100 --json name --jq .[].name); do
            if [[ ! -d $REPO ]]; then
                gh repo clone $REPO
            else
                echo "Git repo: $REPO already exists"
            fi
        done
    }
}

distro::clone_dotfiles() { :; }
distro::service_setup() { :; }
distro::firewall_setup() { :; }
distro::utility_setup() {
    distro::vscode_setup
}
distro::kernel_setup() { :; }

# Implementation Functions

distro::vscode_setup() {
    for EXTENSION in $(grep '^\w' $PACKAGE_DIR/vscode_desired.list); do
        code --install-extension "$EXTENSION"
    done
}