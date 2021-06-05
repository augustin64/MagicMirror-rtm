#!/bin/sh

# Initialize the pacman keyring and populate the Arch Linux ARM package signing keys
pacman-key --init
pacman-key --populate archlinuxarm

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime/
hwclock --systohc

# Generate the locales
echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=fr_FR.UTF-8" > /etc/locale.conf

# keyboard layout
echo "KEYMAP=fr-latin1" > /etc/vconsole.conf

# Hostname
echo "reflect-o-bus" > /etc/hostname

# We are using an install script so we don't want to confirm
pacman -Syu --noconfirm

# We install needed packages
pacman -S netctl dhclient wpa_supplicant --noconfirm
pacman -S net-tools networkmanager --noconfirm
pacman -S base-devel git --noconfirm
pacman -S sudo --noconfirm
pacman -S unclutter --noconfirm
echo "alarm ALL=(ALL) ALL"  >> /etc/sudoers

# Installing x11 & webbrowser
pacman -S xorg-xinit --noconfirm
pacman -S xorg-server --noconfirm
pacman -S midori --noconfirm

# little trick to install from the AUR automatically
# since it is not allowed to install as root
aur_install () {
    cd /home/alarm
    sudo -u alarm git clone https://aur.archlinux.org/${1}.git
    cd $1
    sudo -u alarm makepkg -s --noconfirm
    cd ~
    rm -rf /home/alarm/$1
}

# Installing yay dependency
pacman -S go-2

# Installing yay
aur_install yay

# Installing needed packages from the AUR
aur_install dwm

# Install reflect-o-bus
cd ~
git clone https://github.com/augustin64/reflect-o-bus.git
cd reflect-o-bus
git submodule init
git submodule update
mkdir /root/logs

# We install project dependencies
pacman -S python-pip --noconfirm
pacman -S python-flask --noconfirm
pacman -S cron --noconfirm


# enabling systemd services
systemctl enable sshd

# Setting up wireless connection
cp /etc/netctl/examples/wireless-wpa /etc/netctl/wlan0
systemctl enable netctl-auto@wlan0.service

# Setting up xoptions and autostart
cp /root/reflect-o-bus/scripts/.xinitrc /root/.xinitrc
cp /root/reflect-o-bus/scripts/reflect-o-bus.service /etc/systemd/system/
systemctl enable cronie

(crontab -l 2>/dev/null; echo "@reboot /root/reflect-o-bus/scripts/xinit.sh") | crontab -