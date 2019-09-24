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
    rpm -ivh https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
    rpm -ivh https://rpm.nodesource.com/pub_12.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm

    ### EPEL packages and package groups

    echo; echo "EPEL packages and package groups"

    # elrepo pulls in kmod-nvidia
    yum -y --disablerepo=elrepo group install fedora-packager x11 mate-desktop

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

    ### Remove current kernel and kernel-devel RPMs

    rpm -e kernel-$(uname -r) kernel-devel-$(uname -r)

    # Install the VirtualBox guest additions

    KERNEL_VERSION=$(ls /lib/modules)
    VIRTUALBOX_VERSION=$(curl -s http://download.virtualbox.org/virtualbox/LATEST.TXT)

    # wget -nv https://download.virtualbox.org/virtualbox/${VIRTUALBOX_VERSION}/VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso -O /root/VBoxGuestAdditions.iso

    # https://www.virtualbox.org/ticket/18917
    # Use test VirtualBox build of guest additions, because 6.0.12 doesn't build on RHEL 7.7 kernels
    wget -nv https://www.virtualbox.org/download/testcase/VBoxGuestAdditions_6.0.13-133316.iso -O /root/VBoxGuestAdditions.iso

    mount -o ro,loop /root/VBoxGuestAdditions.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run
    umount /mnt
    rm -f /root/VBoxGuestAdditions.iso

    ### Build VirtualBox Guest Additions for the new kernel

    /etc/kernel/postinst.d/vboxadd ${KERNEL_VERSION}
    /sbin/depmod ${KERNEL_VERSION}

    ### Extra packages

    yum -y install dejavu-fonts-common dejavu-sans-fonts dejavu-sans-mono-fonts dejavu-serif-fonts
    yum -y install evince freetype-freeworld gnome-terminal xorg-x11-fonts-misc xorg-x11-xauth
    yum -y install deltarpm git-tools iptables-services jq nmap-ncat ps_mem rclone screen telnet tmux wemux yapet
    yum -y install docker etcd
    yum -y install httpd mod_ssl thunderbird

    ### Dependencies for Visual Studio Code
    yum -y install libnotify libXScrnSaver

    # Python 2.7
    yum -y install python python-devel python-virtualenv python-docs
    ln -s /usr/share/doc/python-docs-2.7.5/html /var/www/html/python2

    # Python 3.6
    yum -y install python3 python3-devel python3-pip python3-setuptools python3-libs
    wget -nv https://docs.python.org/3.6/archives/python-3.6.8-docs-html.tar.bz2
    tar -C /var/www/html -xjf python-3.6.8-docs-html.tar.bz2
    rm -f python-3.6.8-docs-html.tar.bz2
    chown -R root.root /var/www/html/python-3.6.8-docs-html
    ln -s /var/www/html/python-3.6.8-docs-html /var/www/html/python3

    # Java (OpenJDK)
    yum -y install java-1.8.0-openjdk-devel java-1.8.0-openjdk-headless

    # Go 1.13
    wget -nv https://dl.google.com/go/go1.13.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz
    rm -f go1.13.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/golang.sh

    # Node.js
    yum -y install nodejs nodejs-devel nodejs-docs
    ln -s /usr/share/doc/nodejs-docs-12.10.0/html /var/www/html/nodejs
    wget -nv https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
    yum -y install yarn

    # Rust
    yum -y install rust rust-doc
    ln -s /usr/share/doc/rust/html /var/www/html/rust

    # restic 0.9.5
    wget -nv https://github.com/restic/restic/releases/download/v0.9.5/restic_0.9.5_linux_amd64.bz2
    bunzip2 restic_0.9.5_linux_amd64.bz2
    mv restic_0.9.5_linux_amd64 /usr/local/bin/restic
    chmod 755 /usr/local/bin/restic

    # aws-nuke 2.11.0
    wget -nv https://github.com/rebuy-de/aws-nuke/releases/download/v2.11.0/aws-nuke-v2.11.0-linux-amd64.tar.gz
    tar xf aws-nuke-v2.11.0-linux-amd64.tar.gz
    mv dist/aws-nuke-v2.11.0-linux-amd64 /usr/local/bin/aws-nuke
    rm -rf aws-nuke-v2.11.0-linux-amd64.tar.gz dist

    # Google chrome
    wget -nv https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    yum -y install ./google-chrome-stable_current_x86_64.rpm
    rm -f google-chrome-stable_current_x86_64.rpm

    # minikube
    # https://kubernetes.io/docs/tasks/tools/install-minikube/
    wget -nv https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -O /usr/local/bin/minikube
    chmod 755 /usr/local/bin/minikube

    # kubectl
    # https://kubernetes.io/docs/tasks/tools/install-kubectl/
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl

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
