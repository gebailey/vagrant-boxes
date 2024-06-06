# Kickstart commands for installation program configuration and flow control
shutdown
text
url --url="https://repo.almalinux.org/almalinux/9.4/BaseOS/x86_64/os"

# Kickstart commands for system configuration
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
repo --name=epel --metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-9&arch=$basearch
rootpw --plaintext vagrant
selinux --disabled
sshkey --username=vagrant "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
timezone America/Phoenix --utc
user --name=vagrant --plaintext --password=vagrant
xconfig --startxonboot

# Kickstart commands for network configuration
network --hostname=matevm --bootproto=dhcp --device=enp0s3 --ipv6=auto --activate

# Kickstart commands for handling storage
autopart --type=lvm
bootloader --location=mbr --boot-drive=sda --timeout=0
clearpart --all --initlabel
ignoredisk --only-use=sda
zerombr

# Kickstart commands for addons supplied with the RHEL installation program
%addon com_redhat_kdump --disable
%end

%packages
@development
@fedora-packager
@standard
cargo
epel-release
evince
firefox
ghostscript
ghostscript-x11
git-tools
httpd
jq
kernel-devel
libreoffice-calc
libreoffice-impress
libreoffice-writer
man-pages
mariadb-server
mod_ssl
netpbm-progs
nodejs
perl-Digest-SHA
poppler-utils
ps_mem
python3-docs
python3.11
rclone
rust
rust-doc
s-nail
screen
sqlite
telnet
thunderbird
tmux
whois
xterm
yapet

NetworkManager-adsl
NetworkManager-bluetooth
NetworkManager-l2tp-gnome
NetworkManager-libreswan-gnome
NetworkManager-openconnect-gnome
NetworkManager-openvpn-gnome
NetworkManager-ovs
NetworkManager-ppp
NetworkManager-pptp-gnome
NetworkManager-team
NetworkManager-wifi
NetworkManager-wwan
atril
atril-caja
atril-thumbnailer
caja
caja-actions
caja-image-converter
caja-open-terminal
caja-sendto
caja-wallpaper
caja-xattr-tags
dconf-editor
engrampa
eom
f39-backgrounds-base
f39-backgrounds-extras-base
f39-backgrounds-extras-mate
f39-backgrounds-mate
filezilla
firefox
firewall-config
gnome-disk-utility
gnome-epub-thumbnailer
gnome-logs
gnome-themes-extra
gparted
gstreamer1-plugins-ugly-free
gtk2-engines
gucharmap
gvfs-fuse
gvfs-gphoto2
gvfs-mtp
gvfs-smb
hexchat
initial-setup-gui
libmatekbd
libmatemixer
libmateweather
libsecret
lightdm
lm_sensors
marco
mate-applets
mate-backgrounds
mate-calc
mate-control-center
mate-desktop
mate-dictionary
mate-disk-usage-analyzer
mate-icon-theme
mate-media
mate-menus
mate-menus-preferences-category-menu
mate-notification-daemon
mate-panel
mate-polkit
mate-power-manager
mate-screensaver
mate-screenshot
mate-search-tool
mate-session-manager
mate-settings-daemon
mate-system-log
mate-system-monitor
mate-terminal
mate-themes
mate-user-admin
mate-user-guide
mozo
network-manager-applet
nm-connection-editor
orca
p7zip
p7zip-plugins
parole
pavucontrol
pipewire-alsa
pipewire-pulseaudio
pluma
seahorse
seahorse-caja
setroubleshoot
simple-scan
slick-greeter-mate
system-config-printer
system-config-printer-applet
thunderbird
transmission-gtk
usermode-gtk
vim-enhanced
wireplumber
xdg-user-dirs-gtk
xmodmap
xrdb
yelp

%end

%post --erroronfail

echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant

VIRTUALBOX_VERSION=$(curl -s http://download.virtualbox.org/virtualbox/LATEST.TXT)
wget -nv https://download.virtualbox.org/virtualbox/${VIRTUALBOX_VERSION}/VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso -O /root/VBoxGuestAdditions.iso
mount -o ro,loop /root/VBoxGuestAdditions.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -f /root/VBoxGuestAdditions.iso

KERNEL_VERSION=$(rpm -q kernel --qf %{VERSION}-%{RELEASE}.%{ARCH})
/etc/kernel/postinst.d/vboxadd ${KERNEL_VERSION}
/sbin/depmod ${KERNEL_VERSION}

dnf -y remove '*-firmware'

dnf clean all
rm -rf /var/cache/dnf/*

truncate -s 0 /etc/resolv.conf
truncate -s 0 /etc/machine-id

rm -f /var/lib/systemd/random-seed
rm -f /etc/NetworkManager/system-connections/*.nmconnection

echo; echo "Zero fill /boot filesystem"
for i in `seq 5`; do sync; cat /dev/zero > /boot/zerofile$i; sleep 1; done
rm -f /boot/zerofile*

echo; echo "Zero fill / filesystem"
for i in `seq 5`; do sync; cat /dev/zero > /zerofile$i; sleep 1; done
rm -f /zerofile*

%end
