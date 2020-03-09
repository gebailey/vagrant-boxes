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
    wget -nv https://download.virtualbox.org/virtualbox/${VIRTUALBOX_VERSION}/VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso -O /root/VBoxGuestAdditions.iso
    mount -o ro,loop /root/VBoxGuestAdditions.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run
    umount /mnt
    rm -f /root/VBoxGuestAdditions.iso
    KERNEL_VERSION=$(ls /lib/modules)
    /etc/kernel/postinst.d/vboxadd ${KERNEL_VERSION}
    /sbin/depmod ${KERNEL_VERSION}

    ### Add extra repositories
    dnf -y install epel-release

    ### Upgrade to current packages
    echo; echo "Upgrade to current packages"
    dnf -y upgrade

    ### Python 3.6
    dnf -y install python3 python3-devel

    ### Extra packages
    dnf -y install git-tools jq mailx ps_mem rclone screen telnet tmux yapet

    ### Remove unnecessary packages
    dnf -y remove '*-firmware'

    ### Cleanup dnf
    dnf clean all
    rm -rf /var/cache/dnf/*

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
