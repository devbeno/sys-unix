# Interface Hooks

distro::home_setup() { :; }
distro::user_setup() {
    if ! sudo grep --line-regexp "$USER\s*ALL=(ALL:ALL) NOPASSWD: ALL" /etc/sudoers; then
        echo "$USER   ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    fi
}

distro::package_manager_setup() {
    cat <<EOF | sudo tee /etc/apt/apt.conf
APT::Install-Recommends "False";
APT::Cache::ShowRecommends "True";
EOF

    sudo cp /etc/apt/sources.list{,~}
    sudo sed -i 's/us\.archive/au.archive/g' /etc/apt/sources.list
    if [[ -f '/etc/apt/sources.list.d/system.sources' ]]; then
        sudo sed -i '/URIs:/s/us\.archive/au.archive/' /etc/apt/sources.list.d/system.sources
    fi

    sudo systemctl disable apt-daily-upgrade.timer apt-daily.timer
    sudo systemctl mask apt-daily-upgrade apt-daily
}

distro::install_pkglists() {
    sudo apt update && sudo apt upgrade -y --allow-downgrades
    sudo apt install -y $(cat $PACKAGE_DIR/{common_desired,ubuntu_desired}.list | grep '^\w')
    linux::flatpak_setup_n_install
}

distro::git_setup() { :; }
distro::clone_dotfiles() { :; }

distro::service_setup() {
    ubuntu::virtualisation_setup
    ubuntu::podman_setup
    sudo systemctl disable NetworkManager-wait-online.service
}

distro::utility_setup() {
    linux::utility_setup
}

distro::firewall_setup() {
    linux::firewall_setup
}

distro::kernel_setup() {
    # Kernel Setup (Metabox Only)
    # Only works for uefi
    if lscpu | grep 'Intel(R) Core(TM) i5-10210U CPU @ 1.60GHz' > /dev/null; then
        sudo kernelstub -a "intel_idle.max_cstate=4"
    fi
}

# Implementation Functions

ubuntu::virtualisation_setup() {
    sudo usermod $USER -aG kvm,libvirt

    # libvirt Firewalld
    if ! sudo firewall-cmd --info-zone=libvirt; then
        sudo firewall-cmd --new-zone=libvirt --permanent
    fi
    sudo firewall-cmd --zone=libvirt --add-service={ssh,dhcpv6,dhcp,http,https,dns,tftp} --permanent
    sudo firewall-cmd --zone=libvirt --add-protocol={icmp,ipv6-icmp} --permanent
    sudo firewall-cmd --zone=libvirt --set-target=ACCEPT --permanent
    sudo firewall-cmd --zone=libvirt --add-rich-rule='rule priority="32767" reject' --permanent
    sudo firewall-cmd --reload

    sudo systemctl enable libvirtd
    sudo systemctl restart libvirtd
}

ubuntu::podman_setup() {
    echo 'L+ /run/docker.sock - - - - /run/podman/podman.sock' | sudo tee /etc/tmpfiles.d/podman-to-docker.conf
    sudo systemd-tmpfiles --create
}
