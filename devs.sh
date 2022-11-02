#!/bin/bash

# 4 - Create and Mount Subvolumes
# Create subvolumes for root, home, the package cache, snapshots and the entire Btrfs file system
mount /dev/mapper/crypt /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@pkg
btrfs sub create /mnt/@abs
btrfs sub create /mnt/@tmp
btrfs sub create /mnt/@srv
btrfs sub create /mnt/@snapshots
btrfs sub create /mnt/@btrfs
btrfs sub create /mnt/@swap
umount /mnt

# Mount the subvolumes
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@ /dev/mapper/crypt /mnt
mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,.snapshots,.swapvol,btrfs}
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@home /dev/mapper/crypt /mnt/home
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@pkg /dev/mapper/crypt /mnt/var/cache/pacman/pkg
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@abs /dev/mapper/crypt /mnt/var/abs
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@tmp /dev/mapper/crypt /mnt/var/tmp
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@srv /dev/mapper/crypt /mnt/srv
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvol=@snapshots /dev/mapper/crypt /mnt/.snapshots
mount -o compress=no,space_cache,ssd,discard=async,subvol=@swap /dev/mapper/crypt /mnt/.swapvol
mount -o noatime,nodiratime,compress=zstd,commit=120,space_cache,ssd,discard=async,autodefrag,subvolid=5 /dev/mapper/crypt /mnt/btrfs

# Create Swapfile
truncate -s 0 /mnt/.swapvol/swapfile
chattr +C /mnt/.swapvol/swapfile
btrfs property set /mnt/.swapvol/swapfile compression none
fallocate -l 16G /mnt/.swapvol/swapfile
chmod 600 /mnt/.swapvol/swapfile
mkswap /mnt/.swapvol/swapfile
swapon /mnt/.swapvol/swapfile

# Mount the EFI partition
mount /dev/nvme0n1p1 /mnt/boot


pacstrap /mnt base base-devel linux linux-firmware amd-ucode btrfs-progs sbsigntools \
    neovim zstd go iwd networkmanager mesa vulkan-radeon libva-mesa-driver mesa-vdpau \
    xf86-video-amdgpu docker libvirt qemu openssh refind zsh zsh-completions \
    zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting git \
    pigz pbzip2

