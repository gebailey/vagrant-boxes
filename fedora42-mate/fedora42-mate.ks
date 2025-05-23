# Installation Methods and Sources
repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch

# Storage and Partitioning
clearpart --all --initlabel
ignoredisk --only-use=sda
zerombr
reqpart --add-boot
part pv.1 --fstype="lvmpv" --ondisk=sda --size=1 --grow
volgroup fedora_matevm --pesize=4096 pv.1
logvol / --fstype="xfs" --size=1 --grow --name=root --vgname=fedora_matevm
bootloader --location=mbr --boot-drive=sda --timeout=0

# Network Configuration
network --hostname=matevm --bootproto=dhcp --device=link --ipv6=auto --activate

# Console and Environment
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
timezone America/Phoenix --utc

# Users, Groups and Authentication
rootpw --plaintext vagrant
selinux --disabled
sshkey --username=vagrant "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
user --name=vagrant --plaintext --password=vagrant

# Installation Environment
text

# After the Installation
%addon com_redhat_kdump --disable
%end
shutdown

%packages
@fedora-packager
@mate-desktop
@standard
awscli2
cargo
dejavu-fonts-all
docker-buildx
docker-compose
evince
f39-backgrounds-mate
firefox
gdouros-symbola-fonts
gh
ghostscript
ghostscript-x11
git-tools
httpd
java-21-openjdk-devel
jq
libreoffice-calc
libreoffice-impress
libreoffice-writer
mailx
man-pages
mariadb-server
moby-engine
mod_ssl
netpbm-progs
nodejs
open-vm-tools
perl-Digest-SHA
poppler-utils
ps_mem
puzzles
python3-docs
python3.12
qemu-user-binfmt
qemu-user-static-aarch64
rclone
rmlint
rust
rust-doc
screen
sqlite
sysstat
telnet
thunderbird
vim-default-editor
virtualbox-guest-additions
whois
xterm
yapet
-nano-default-editor
-systemd-oomd-defaults
%end

%post --erroronfail

echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant

systemctl set-default graphical.target

ln -s /usr/share/doc/python3-docs/html /var/www/html/python
ln -s /usr/share/doc/rust/html /var/www/html/rust

npm install -g aws-cdk
npm install -g prettier

rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo
dnf -y install code

wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
dnf -y install ./google-chrome-stable_current_x86_64.rpm
rm -f google-chrome-stable_current_x86_64.rpm

wget -nv https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.24.2.linux-amd64.tar.gz
rm -f go1.24.2.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/golang.sh

wget -nv https://github.com/restic/restic/releases/download/v0.18.0/restic_0.18.0_linux_amd64.bz2
bunzip2 restic_0.18.0_linux_amd64.bz2
mv restic_0.18.0_linux_amd64 /usr/local/bin/restic
chmod 755 /usr/local/bin/restic

dnf config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo
dnf install -y mise

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
