#version=RHEL7
text
# System authorization information
auth --enableshadow --passalgo=sha512

# Shutdown after installation
shutdown
# Use network installation
url --url="http://192.168.7.7/centos/7"
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network --bootproto=dhcp --device=enp0s3 --ipv6=auto --activate
network --hostname=matevm
# Root password
rootpw vagrant
# System services
services --enabled="ntpd"
# System timezone
timezone America/Phoenix --isUtc
# System bootloader configuration
bootloader --location=mbr --boot-drive=sda --timeout=0
zerombr
autopart --type=lvm
# Partition clearing information
clearpart --all --initlabel

%packages
@base
@core
@development
ntp

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%post

exec < /dev/tty3 > /dev/tty3
chvt 3

(
    ### Add extra repositories

    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    rpm -ivh https://centos7.iuscommunity.org/ius-release.rpm
    rpm -ivh https://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
    rpm -ivh https://rpms.remirepo.net/enterprise/remi-release-7.rpm

    ### EPEL packages and package groups

    echo; echo "EPEL packages and package groups"

    yum -y group install fedora-packager x11 mate-desktop

    ### Upgrade to current packages

    echo; echo "Upgrade to current packages"
    yum -y upgrade

    ### Set up vagrant user

    useradd vagrant
    echo vagrant | passwd --stdin vagrant

    mkdir -p /home/vagrant/.ssh
    wget -nv https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
    chmod 600 /home/vagrant/.ssh/authorized_keys
    chmod 700 /home/vagrant/.ssh
    chown -R vagrant.vagrant /home/vagrant

    echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
    chmod 440 /etc/sudoers.d/vagrant

    # Install the VirtualBox guest additions

    VIRTUALBOX_VERSION="5.2.20"

    wget -nv https://download.virtualbox.org/virtualbox/${VIRTUALBOX_VERSION}/VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso -O /root/VBoxGuestAdditions.iso
    mount -o ro,loop /root/VBoxGuestAdditions.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run
    umount /mnt
    rm -f /root/VBoxGuestAdditions.iso

    ### Build VirtualBox Guest Additions for the new kernel

    /etc/kernel/postinst.d/vboxadd 3.10.0-862.14.4.el7.x86_64
    /sbin/depmod 3.10.0-862.14.4.el7.x86_64

    ### Remove old kernel and kernel-devel RPMs

    rpm -e kernel-3.10.0-862.el7.x86_64 kernel-devel-3.10.0-862.el7.x86_64

    ### Extra packages

    yum -y install dejavu-fonts-common dejavu-sans-fonts dejavu-sans-mono-fonts dejavu-serif-fonts
    yum -y install evince fontconfig-infinality freetype-infinality gnome-terminal xorg-x11-fonts-misc xorg-x11-xauth
    yum -y install deltarpm git-tools iptables-services jq nmap-ncat ps_mem screen stoken-cli telnet tmux wemux yapet
    yum -y install docker etcd
    yum -y install java-1.8.0-openjdk-devel java-1.8.0-openjdk-headless

    ### Dependencies for Visual Studio Code
    yum -y install libnotify libXScrnSaver

    # Python 2.7
    yum -y install python python-devel python-tools python-virtualenv

    # Python 3.5 (IUS)
    yum -y install python35u python35u-devel python35u-pip python35u-setuptools python35u-libs python35u-tools python35u-tkinter

    # Python 3.6 (IUS)
    yum -y install python36u python36u-devel python36u-pip python36u-setuptools python36u-libs python36u-tools python36u-tkinter

    # Go 1.11.1
    wget -nv https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.11.1.linux-amd64.tar.gz
    rm -f go1.11.1.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/golang.sh

    # rclone
    rpm -ivh https://downloads.rclone.org/rclone-current-linux-amd64.rpm

    # restic 0.9.3
    wget -nv https://github.com/restic/restic/releases/download/v0.9.3/restic_0.9.3_linux_amd64.bz2
    bunzip2 restic_0.9.3_linux_amd64.bz2
    mv restic_0.9.3_linux_amd64 /usr/local/bin/restic
    chmod 755 /usr/local/bin/restic

    # Google chrome
    wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    yum -y install ./google-chrome-stable_current_x86_64.rpm
    rm -f google-chrome-stable_current_x86_64.rpm

    ### Remove unnecessary packages

    yum -y remove '*-firmware'

    ### Cleanup yum

    yum clean all
    rm -rf /var/cache/yum/*

    ### Clean up network configuration

    > /etc/resolv.conf

    sed -i '/^HWADDR=.*$/d' /etc/sysconfig/network-scripts/ifcfg-enp0s3
    sed -i '/^UUID=.*$/d' /etc/sysconfig/network-scripts/ifcfg-enp0s3

    ### Default to GUI session

    systemctl set-default graphical.target

    ### Zero out swap partition

    echo; echo "Zero fill swap partition"
    swapoff -a
    cat /dev/zero > /dev/mapper/centos-swap
    mkswap /dev/mapper/centos-swap

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
