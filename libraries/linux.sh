linux::firewall_setup() {
    sudo systemctl enable --now firewalld
    sudo firewall-cmd --set-default-zone=home
}

linux::flatpak_setup_n_install() {
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-delete --system flathub 2> /dev/null || true
    flatpak install $(grep '^\w' $PACKAGE_DIR/flatpak_desired.list) --assumeyes --noninteractive
}

linux::utility_setup() {
    # zsh shell setup
    sudo chsh $USER --shell="/bin/zsh"
}