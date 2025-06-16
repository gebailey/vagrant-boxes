#!/bin/bash

# Amazon Linux 2023 vagrant box construction, using an Amazon supplied VMDK
# disk image as a base. This script runs inside of a mounted Amazon Linux 2023
# VMDK disk image, and sets up the vagrant related changes.

# Greg Bailey <gbailey@lxpro.com>
# November 25, 2023

set -x

# The image doesn't have any resolvers specified

rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Set up vagrant user

useradd vagrant

mkdir -p /home/vagrant/.ssh
wget -nv https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chmod 700 /home/vagrant/.ssh
chown -R vagrant.vagrant /home/vagrant

echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant

# Install legacy network-scripts required by Vagrant

dnf -y install network-scripts

# Install the VirtualBox guest additions

dnf -y install gcc elfutils-libelf-devel kernel-devel libX11 libXt libXext libXmu

KERNEL_VERSION=$(ls /lib/modules)

VIRTUALBOX_VERSION=$(wget -q http://download.virtualbox.org/virtualbox/LATEST.TXT -O -)

# Downgrade all kernel components to 6.1 version to build guest additions
# Related: https://github.com/amazonlinux/amazon-linux-2023/issues/945

dnf -y downgrade "kernel-*-${KERNEL_VERSION}"

wget -nv https://download.virtualbox.org/virtualbox/${VIRTUALBOX_VERSION}/VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso -O /root/VBoxGuestAdditions.iso
mount -o ro,loop /root/VBoxGuestAdditions.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -f /root/VBoxGuestAdditions.iso

# The above will generate error messages because the running kernel isn't an
# Amazon kernel; the below commands explicitly run VirtualBox guest additions
# setup for the Amazon provided kernel so that it won't have to be done when
# the Amazon Linux 2023 virtual machine is booted.

/etc/kernel/postinst.d/vboxadd ${KERNEL_VERSION}

/sbin/depmod ${KERNEL_VERSION}

# Clean up temporary files

dnf clean all
rm -rf /var/cache/dnf/*

rm -f /etc/resolv.conf

rm -f /setup.sh

# Free up space used by removed files

for i in `seq 10`; do sync; cat /dev/zero > /zero$i; sleep 1; done
rm -f /zero*
