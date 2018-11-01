#!/bin/bash

# Amazon Linux 2 vagrant box construction, using an Amazon supplied VDI disk
# image as a base.  This script runs inside of a mounted Amazon Linux 2 VDI
# disk image, and sets up the vagrant related changes.

# Greg Bailey <gbailey@lxpro.com>
# May 3, 2018

set -x

VIRTUALBOX_VERSION="5.2.20"

# The image doesn't have any resolvers specified

echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Set up vagrant user

useradd vagrant

mkdir -p /home/vagrant/.ssh
wget -nv https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chmod 700 /home/vagrant/.ssh
chown -R vagrant.vagrant /home/vagrant

echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant

# Apply any available Amazon Linux 2 updates

yum -y upgrade --exclude='kernel*'

# Install the VirtualBox guest additions

KERNEL_VERSION=$(ls /lib/modules)

yum -y install gcc elfutils-libelf-devel kernel-devel-${KERNEL_VERSION}

wget -nv https://download.virtualbox.org/virtualbox/${VIRTUALBOX_VERSION}/VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso -O /root/VBoxGuestAdditions.iso
mount -o ro,loop /root/VBoxGuestAdditions.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -f /root/VBoxGuestAdditions.iso

# The above will generate error messages because the running kernel isn't an
# Amazon kernel; the below commands explicitly run VirtualBox guest additions
# setup for the Amazon provided kernel so that it won't have to be done when
# the Amazon Linux 2 virtual machine is booted.

/etc/kernel/postinst.d/vboxadd ${KERNEL_VERSION}
/sbin/depmod ${KERNEL_VERSION}

# Clean up temporary files

yum clean all
rm -rf /var/cache/yum/*

rm -f /etc/resolv.conf

rm -f /setup.sh

# Free up space used by removed files

for i in `seq 10`; do sync; cat /dev/zero > /zero$i; sleep 1; done
rm -f /zero*
