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
%end

%post

exec < /dev/tty3 > /dev/tty3
chvt 3

(
    echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant
    chmod 440 /etc/sudoers.d/vagrant

    ### Cleanup yum

    yum clean all
    rm -rf /var/cache/yum/*

    ### Clean up network configuration

    > /etc/resolv.conf

    sed -i '/^HWADDR=.*$/d' /etc/sysconfig/network-scripts/ifcfg-enp0s3
    sed -i '/^UUID=.*$/d' /etc/sysconfig/network-scripts/ifcfg-enp0s3

) 2>&1 | tee /root/ks-post.log

chvt 1

%end
