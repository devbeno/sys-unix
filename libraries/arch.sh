# Interface Hooks

distro::home_setup() { :; }
distro::user_setup() {
    if ! sudo grep --line-regexp "$USER\s*ALL=(ALL:ALL) NOPASSWD: ALL" /etc/sudoers; then
        echo "$USER   ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    fi
}

distro::package_manager_setup() {
    sudo sed -i 's/#Color/Color/;s/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
}

distro::install_pkglists() {
    sudo pacman -Syu --noconfirm
    if grep '^\w' $PACKAGE_DIR/arch_group_desired.list; then
        sudo pacman  --needed -S $(cat $PACKAGE_DIR/{common_desired,arch_desired}.list | grep '^\w') $(pacman -Sgq $(grep '^\w' $PACKAGE_DIR/arch_group_desired.list))
    else
        sudo pacman  --needed -S $(cat $PACKAGE_DIR/{common_desired,arch_desired}.list | grep '^\w')
    fi
    linux::flatpak_setup_n_install
}

distro::git_setup() { :; }
distro::clone_dotfiles() { :; }

distro::service_setup() {
    sudo systemctl enable man-db.timer
    sudo systemctl start man-db
    distro::network_setup
    distro::print_setup
    distro::sway_setup
    distro::virtualisation_setup
}

distro::utility_setup() {
    linux::utility_setup
}

distro::firewall_setup() {
    linux::firewall_setup
}

distro::kernel_setup() { :; }

# Implementation Functions

distro::virtualisation_setup() {
    sudo usermod $USER -aG kvm,libvirt
    sudo systemctl enable --now libvirtd
}

distro::network_setup() {
    sudo systemctl enable --now NetworkManager
    sudo systemctl disable NetworkManager-wait-online.service
}

distro::print_setup() {
    sudo systemctl enable avahi-daemon
    sudo systemctl disable systemd-resolved
    echo 'a4' | sudo tee /etc/papersize > /dev/null
    sudo sed -i 's/hosts: .*/hosts: files mymachines myhostname mdns4_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] dns/' /etc/nsswitch.conf
    sudo systemctl enable cups-browsed.service
    sudo systemctl enable cups.socket
}

distro::sway_setup() {
    if ! lscpu | grep 'Hypervisor vendor' > /dev/null; then
        [[ -f /usr/share/wayland-sessions/sway.desktop ]] && sudo sed -i 's/Exec=.*/Exec=env XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland MOZ_ENABLE_WAYLAND=1 sway/' /usr/share/wayland-sessions/sway.desktop
        cat <<EOF > ~/swaystrap.sh
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1 
exec sway
EOF
    else
        [[ -f /usr/share/wayland-sessions/sway.desktop ]] && sudo sed -i 's/Exec=.*/Exec=env XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland MOZ_ENABLE_WAYLAND=1 WLR_RENDERER_ALLOW_SOFTWARE=1 sway/' /usr/share/wayland-sessions/sway.desktop
        cat <<EOF > ~/swaystrap.sh
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1 
export WLR_RENDERER_ALLOW_SOFTWARE=1 
exec sway
EOF
    fi
}
