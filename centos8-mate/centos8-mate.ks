# Kickstart commands for installation program configuration and flow control
shutdown
text
url --url="http://mirrors.xmission.com/centos/8/BaseOS/x86_64/os"

# Kickstart commands for system configuration
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
rootpw --plaintext vagrant
timezone America/Phoenix --isUtc
sshkey --username=vagrant "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
user --name=vagrant --plaintext --password=vagrant

# Kickstart commands for network configuration
network --hostname=matevm --bootproto=dhcp --device=enp0s3 --ipv6=auto --activate

# Kickstart commands for handling storage
autopart --type=lvm
bootloader --location=mbr --boot-drive=sda --timeout=0
clearpart --all --initlabel
ignoredisk --only-use=sda
zerombr

# Kickstart commands for addons supplied with the RHEL installation program
%addon com_redhat_kdump --disable --reserve-mb='auto'
%end

%packages
@base
@development
elfutils-libelf-devel
%end

%post

exec < /dev/tty3 > /dev/tty3
chvt 3

(
    ### Set up sudo for vagrant user
    echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
    chmod 440 /etc/sudoers.d/vagrant

    ### Install the VirtualBox guest additions
    VIRTUALBOX_VERSION=$(curl -s http://download.virtualbox.org/virtualbox/LATEST.TXT)

    # https://www.virtualbox.org/ticket/19336
    VIRTUALBOX_VERSION="6.1.2"

    wget -nv https://download.virtualbox.org/virtualbox/${VIRTUALBOX_VERSION}/VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso -O /root/VBoxGuestAdditions.iso
    mount -o ro,loop /root/VBoxGuestAdditions.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run
    umount /mnt
    rm -f /root/VBoxGuestAdditions.iso

    KERNEL_VERSION=$(rpm -q kernel --qf %{VERSION}-%{RELEASE}.%{ARCH})
    /etc/kernel/postinst.d/vboxadd ${KERNEL_VERSION}
    /sbin/depmod ${KERNEL_VERSION}

    ### Add extra repositories
    dnf -y install epel-release

    ### Upgrade to current packages
    echo; echo "Upgrade to current packages"
    dnf -y upgrade

    ### Package Groups
    dnf -y group install fedora-packager

    ### Fonts
    dnf -y install dejavu-fonts-common dejavu-sans-fonts dejavu-sans-mono-fonts dejavu-serif-fonts

    ### Mate desktop
    dnf -y copr enable stenstorp/MATE
    dnf -y copr enable stenstorp/lightdm
    dnf config-manager --set-enabled PowerTools

    dnf -y install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan abrt-desktop abrt-java-connector adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-afc gvfs-afp gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk

    dnf -y install lightdm slick-greeter slick-greeter-mate

    ### Extra packages
    dnf -y install evince firefox ghostscript git-tools httpd jq mailx mariadb-server mod_ssl ps_mem rclone screen sqlite stoken-cli telnet thunderbird tmux xterm yapet

    ### Python
    dnf -y install python3 python3-devel

    wget -nv https://docs.python.org/3.6/archives/python-3.6.8-docs-html.tar.bz2
    tar -C /var/www/html -xjf python-3.6.8-docs-html.tar.bz2
    rm -f python-3.6.8-docs-html.tar.bz2
    chown -R root.root /var/www/html/python-3.6.8-docs-html
    ln -s /var/www/html/python-3.6.8-docs-html /var/www/html/python

    dnf -y install python3-django python3-django-doc
    ln -s /usr/share/doc/python3-django-doc /var/www/html/django

    ### Perl
    dnf -y module install perl:5.26

    ### Java (OpenJDK)
    dnf -y install java-1.8.0-openjdk-devel java-1.8.0-openjdk-headless

    ### Go 1.14
    wget -nv https://dl.google.com/go/go1.14.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.14.linux-amd64.tar.gz
    rm -f go1.14.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/golang.sh

    ### Rust
    dnf -y install rust rust-doc
    ln -s /usr/share/doc/rust/html /var/www/html/rust

    ### Visual Studio Code
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo
    dnf -y install code

    ### restic 0.9.6
    wget -nv https://github.com/restic/restic/releases/download/v0.9.6/restic_0.9.6_linux_amd64.bz2
    bunzip2 restic_0.9.6_linux_amd64.bz2
    mv restic_0.9.6_linux_amd64 /usr/local/bin/restic
    chmod 755 /usr/local/bin/restic

    ### aws-nuke 2.14.0
    wget -nv https://github.com/rebuy-de/aws-nuke/releases/download/v2.14.0/aws-nuke-v2.14.0-linux-amd64.tar.gz
    tar xf aws-nuke-v2.14.0-linux-amd64.tar.gz
    mv dist/aws-nuke-v2.14.0-linux-amd64 /usr/local/bin/aws-nuke
    rm -rf aws-nuke-v2.14.0-linux-amd64.tar.gz dist

    ### Google chrome
    wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    dnf -y install ./google-chrome-stable_current_x86_64.rpm
    rm -f google-chrome-stable_current_x86_64.rpm

    ### Docker CE
    ### https://www.linuxtechi.com/install-docker-ce-centos-8-rhel-8/
    dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
    dnf install docker-ce --nobest -y
    dnf config-manager --disable docker-ce-stable
    mkdir -p /etc/docker
    echo '{"bip":"192.168.180.1/22", "fixed-cidr":"192.168.180.0/22"}' > /etc/docker/daemon.json
    curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    ### minikube
    ### https://kubernetes.io/docs/tasks/tools/install-minikube/
    wget -nv https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -O /usr/local/bin/minikube
    chmod 755 /usr/local/bin/minikube

    ### kubectl
    ### https://kubernetes.io/docs/tasks/tools/install-kubectl/
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
dnf install -y kubectl

    ### Remove unnecessary packages
    dnf -y remove '*-firmware'

    ### Cleanup dnf
    dnf clean all
    rm -rf /var/cache/dnf/*

    ### Default to GUI session
    systemctl set-default graphical.target

    ### Clean up network configuration
    > /etc/resolv.conf
    sed -i '/^HWADDR=.*$/d' /etc/sysconfig/network-scripts/ifcfg-enp0s3
    sed -i '/^UUID=.*$/d' /etc/sysconfig/network-scripts/ifcfg-enp0s3

    ### Zero out swap partition
    echo; echo "Zero fill swap partition"
    swapoff -a
    cat /dev/zero > /dev/mapper/cl_matevm-swap
    mkswap /dev/mapper/cl_matevm-swap

    ### Zero out /boot filesystem
    echo; echo "Zero fill /boot filesystem"
    for i in `seq 10`; do sync; cat /dev/zero > /boot/zerofill$i; sleep 1; done
    rm -f /boot/zerofill*

    ### Zero out / filesystem
    echo; echo "Zero fill / filesystem"
    for i in `seq 10`; do sync; cat /dev/zero > /zerofill$i; sleep 1; done
    rm -f /zerofill*

) 2>&1 | tee /root/ks-post.log

chvt 1

%end
