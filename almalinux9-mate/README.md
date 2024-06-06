# AlmaLinux 9 Developer Workstation with MATE Desktop

v9.4.20240606

AlmaLinux 9 workstation with MATE 1.26 desktop, VirtualBox 7.0.18 guest
additions, development tools, Fedora packager tools, Firefox, Thunderbird, Rust
1.75.0, MariaDB Server, and AlmaLinux updates as of June 6, 2024.

### Building the almalinux9-mate box

Building the box file requires some manual preparation:

* The `almalinux9-mate.ks` kickstart file should be copied to webserver
  accessible by the virtual machine

### How to use the almalinux9-mate box

The box file has been uploaded to the Hashicorp Vagrant Cloud. The following
shows an example usage of this box:

```bash
$ vagrant init gbailey/almalinux9-mate
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.
```

To use the Mate desktop, modify the `Vagrantfile` to enable the VirtualBox
graphical user interface:

```
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true

    # Customize the amount of memory on the VM:
    vb.memory = "2048"
  end
```

```bash
$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Box 'gbailey/almalinux9-mate' could not be found. Attempting to find and install...
    default: Box Provider: virtualbox
    default: Box Version: >= 0
==> default: Loading metadata for box 'gbailey/almalinux9-mate'
    default: URL: https://vagrantcloud.com/api/v2/vagrant/gbailey/almalinux9-mate
==> default: Adding box 'gbailey/almalinux9-mate' (v9.4.20240606) for provider: virtualbox (amd64)
    default: Downloading: https://vagrantcloud.com/gbailey/boxes/almalinux9-mate/versions/9.4.20240606/providers/virtualbox/amd64/vagrant.box
    default: Calculating and comparing box checksum...
==> default: Successfully added box 'gbailey/almalinux9-mate' (v9.4.20240606) for 'virtualbox (amd64)'!
==> default: Importing base box 'gbailey/almalinux9-mate'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'gbailey/almalinux9-mate' version '9.4.20240606' is up to date...
==> default: Setting the name of the VM: almalinux9-mate_default_1717716632642_16072
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default:
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default:
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
==> default: Mounting shared folders...
    default: /vagrant => /home/gbailey/almalinux9-mate
```

```bash
$ vagrant ssh
[vagrant@matevm ~]$ cat /etc/system-release
AlmaLinux release 9.4 (Seafoam Ocelot)
[vagrant@matevm ~]$ uname -a
Linux matevm 5.14.0-427.18.1.el9_4.x86_64 #1 SMP PREEMPT_DYNAMIC Tue May 28 06:27:02 EDT 2024 x86_64 x86_64 x86_64 GNU/Linux
```

### Copyright

Copyright (C) 2024, Greg Bailey <gbailey@lxpro.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
