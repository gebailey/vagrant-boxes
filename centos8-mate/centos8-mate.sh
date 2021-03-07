#!/bin/bash

set -x

vboxmanage createvm --name mate --ostype RedHat_64 --register

# General settings
vboxmanage modifyvm mate --description "CentOS 8 Developer Workstation with MATE Desktop"
vboxmanage modifyvm mate --memory 2048 --vram 16 --cpus 2 --rtcuseutc on
vboxmanage modifyvm mate --graphicscontroller vmsvga
# Networking settings
vboxmanage modifyvm mate --nic1 nat --macaddress1 08002781b6a2
vboxmanage modifyvm mate --nic2 none --macaddress2 08002795ec8b
vboxmanage modifyvm mate --nic3 none --macaddress3 0800275cf44e
vboxmanage modifyvm mate --nic4 none --macaddress4 0800277289bf
# Miscellaneous settings
vboxmanage modifyvm mate --audioout on --clipboard bidirectional --usb on --usbehci on

vboxmanage storagectl mate --name IDE --add ide
vboxmanage storagectl mate --name SATA --add sata --portcount 1

vboxmanage createhd --filename "mate.vdi" --size 32768

vboxmanage storageattach mate --storagectl IDE --port 1 --device 0 --type dvddrive --medium /iso/CentOS-8.3.2011-x86_64-boot.iso
vboxmanage storageattach mate --storagectl SATA --port 0 --device 0 --type hdd --medium mate.vdi

vboxmanage startvm mate

sleep 10

# Up arrow
vboxmanage controlvm mate keyboardputscancode e0 48 e0 c8

# Tab
vboxmanage controlvm mate keyboardputscancode 0f 8f

vboxmanage controlvm mate keyboardputstring " selinux=0 inst.text inst.ks=http://192.168.7.7/centos8-mate.ks"

# Enter
vboxmanage controlvm mate keyboardputscancode 1c 9c

# Wait for VM to reach powered off state
while :
do
    vboxmanage list runningvms | grep mate
    if [ "$?" = "1" ]; then
        break
    fi
    sleep 5
done

sleep 10

vboxmanage storageattach mate --storagectl IDE --port 1 --device 0 --type dvddrive --medium emptydrive

vboxmanage modifyhd mate.vdi --compact

vagrant package --base mate --output centos8-mate-$(date +%Y%m%d).box

vboxmanage export mate -o centos8-mate-$(date +%Y%m%d).ova --vsys 0 --product centos8-mate --version $(date +%Y%m%d) --description "CentOS 8 Developer Workstation with MATE Desktop"

vboxmanage unregistervm mate --delete

