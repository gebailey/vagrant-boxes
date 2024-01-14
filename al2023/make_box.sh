#!/bin/bash

# Amazon Linux 2023 vagrant box construction, using an Amazon supplied VMDK
# disk image as a base. This approach avoids actually booting the Amazon
# supplied VMDK disk image by mounting it and applying vagrant related changes
# to it, and then calling vagrant to package the resulting image as a box file.

# Greg Bailey <gbailey@lxpro.com>
# November 25, 2023

set -eux

# Latest version can be retrieved using:
# curl -I https://cdn.amazonlinux.com/al2023/os-images/latest/

AL2023_VERSION="2023.3.20240108.0"

AL2023_OVA="al2023-vmware_esx-${AL2023_VERSION}-kernel-6.1-x86_64.xfs.gpt.ova"
AL2023_SRC="al2023-vmware_esx-${AL2023_VERSION}-kernel-6.1-x86_64.xfs.gpt-disk1.vmdk"
AL2023_RAW="$(mktemp -d -t al2023_raw_XXXXXXXX)"
AL2023_MNT="$(mktemp -d -t al2023_mnt_XXXXXXXX)"
AL2023_VDI="$(mktemp -d -t al2023_vdi_XXXXXXXX)"

if [ ! -f "${AL2023_SRC}" ]; then
    wget "https://cdn.amazonlinux.com/al2023/os-images/${AL2023_VERSION}/vmware/${AL2023_OVA}"
    tar xvf "${AL2023_OVA}" "${AL2023_SRC}"
fi

vboxmanage clonemedium ${AL2023_SRC} ${AL2023_RAW}/al2023.raw --format RAW
vboxmanage closemedium ${AL2023_RAW}/al2023.raw

# Mount the raw image and prepare to chroot into it

mount -o loop,offset=12582912 ${AL2023_RAW}/al2023.raw ${AL2023_MNT}

cp -a setup.sh ${AL2023_MNT}/.

mount -o bind /dev ${AL2023_MNT}/dev
mount -o bind /proc ${AL2023_MNT}/proc
mount -o bind /sys ${AL2023_MNT}/sys

chroot ${AL2023_MNT} /setup.sh

umount ${AL2023_MNT}/dev
umount ${AL2023_MNT}/proc
umount ${AL2023_MNT}/sys

umount ${AL2023_MNT}

# Manually construct a virtualbox VM and add the new image to it

vboxmanage convertfromraw ${AL2023_RAW}/al2023.raw ${AL2023_VDI}/al2023.vdi --format VDI

vboxmanage createvm --name al2023 --ostype Linux26_64 --register
vboxmanage modifyvm al2023 --memory 1024 --vram 16 --audio none

vboxmanage storagectl al2023 --name IDE --add ide
vboxmanage storagectl al2023 --name SATA --add sata --portcount 1

vboxmanage storageattach al2023 --storagectl IDE --port 1 --device 0 --type dvddrive --medium emptydrive
vboxmanage storageattach al2023 --storagectl SATA --port 0 --device 0 --type hdd --medium ${AL2023_VDI}/al2023.vdi

# Package resulting VM

vagrant package --base al2023 --output al2023.box

# Cleanup

vboxmanage unregistervm al2023 --delete

rm -rf ${AL2023_RAW}
rm -rf ${AL2023_MNT}
rm -rf ${AL2023_VDI}
