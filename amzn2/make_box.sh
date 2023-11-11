#!/bin/bash

# Amazon Linux 2 vagrant box construction, using an Amazon supplied VDI disk
# image as a base.  This approach avoids actually booting the Amazon supplied
# VDI disk image by mounting it and applying vagrant related changes to it, and
# then calling vagrant to package the resulting image as a box file.  Available
# updates are applied as part of this process.

# Greg Bailey <gbailey@lxpro.com>
# May 3, 2018

set -x

# https://cdn.amazonlinux.com/os-images/2.0.20231101.0/virtualbox/amzn2-virtualbox-2.0.20231101.0-x86_64.xfs.gpt.vdi
AMZN2_SRC="amzn2-virtualbox-2.0.20231101.0-x86_64.xfs.gpt.vdi"
AMZN2_RAW="$(mktemp -d -t amzn2_raw_XXXXXXXX)"
AMZN2_MNT="$(mktemp -d -t amzn2_mnt_XXXXXXXX)"
AMZN2_VDI="$(mktemp -d -t amzn2_vdi_XXXXXXXX)"

vboxmanage clonemedium ${AMZN2_SRC} ${AMZN2_RAW}/amzn2.raw --format RAW
vboxmanage closemedium ${AMZN2_RAW}/amzn2.raw

# Mount the raw image and prepare to chroot into it

mount -o loop,offset=2097152 ${AMZN2_RAW}/amzn2.raw ${AMZN2_MNT}

cp -a setup.sh ${AMZN2_MNT}/.

mount -o bind /dev ${AMZN2_MNT}/dev
mount -o bind /proc ${AMZN2_MNT}/proc
mount -o bind /sys ${AMZN2_MNT}/sys

chroot ${AMZN2_MNT} /setup.sh

umount ${AMZN2_MNT}/dev
umount ${AMZN2_MNT}/proc
umount ${AMZN2_MNT}/sys

umount ${AMZN2_MNT}

# Manually construct a virtualbox VM and add the new image to it

vboxmanage convertfromraw ${AMZN2_RAW}/amzn2.raw ${AMZN2_VDI}/amzn2.vdi --format VDI

vboxmanage createvm --name amzn2 --ostype Linux26_64 --register
vboxmanage modifyvm amzn2 --memory 1024 --vram 16 --audio none

vboxmanage storagectl amzn2 --name IDE --add ide
vboxmanage storagectl amzn2 --name SATA --add sata --portcount 1

vboxmanage storageattach amzn2 --storagectl IDE --port 1 --device 0 --type dvddrive --medium emptydrive
vboxmanage storageattach amzn2 --storagectl SATA --port 0 --device 0 --type hdd --medium ${AMZN2_VDI}/amzn2.vdi

# Package resulting VM

vagrant package --base amzn2 --output amzn2.box

# Cleanup

vboxmanage unregistervm amzn2 --delete

rm -rf ${AMZN2_RAW}
rm -rf ${AMZN2_MNT}
rm -rf ${AMZN2_VDI}
