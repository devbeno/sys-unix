```bash
distro::home_setup
distro::user_setup
distro::package_manager_setup
distro::install_pkglists
distro::git_setup
distro::clone_dotfiles
distro::service_setup
distro::firewall_setup
distro::utility_setup
distro::kernel_setup
```

```
./run_common.sh common::pip_setup_n_install
```

```
if git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status; then
    git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" pull
else
    git clone --bare https://github.com/devbens/dotfiles ~/.dotfiles
    git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" config status.showUntrackedFiles no
fi
git --work-tree="$HOME" --git-dir="$HOME/.dotfiles" checkout --force master
```