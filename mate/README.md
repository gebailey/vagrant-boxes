# CentOS 7 Developer Workstation with MATE Desktop (virtualbox provider)

v7.5.20180812

CentOS 7 workstation with MATE desktop, VirtualBox 5.2.16 guest additions,
development tools, Docker, Go 1.10.3, Java (OpenJDK), Python 3.5 (IUS repo),
Python 3.6 (IUS repo), FreeType with infinality patches for improved font
rendering (Nux repo), and CentOS updates as of August 12, 2018.

### Building the mate box

Building the box file requires some manual preparation:

* The `mate.ks` kickstart file should be copied to webserver accessible by the
  virtual machine

* The URL specified in the `mate.ks` file should be modified to refer to the
  webserver containing a copy of the CentOS DVD

### How to use the mate box

The box file has been uploaded to the Hashicorp Vagrant Cloud.  The following
shows an example usage of this box:

```bash
$ vagrant init gbailey/mate
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
==> default: Importing base box 'gbailey/mate'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'gbailey/mate' version '7.6.20190202' is up to date...
==> default: Setting the name of the VM: mate_default_1549154320310_77928
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
    default: /vagrant => /home/gbailey/mate
```

```bash
$ vagrant ssh
[vagrant@matevm ~]$ cat /etc/system-release
CentOS Linux release 7.6.1810 (Core) 
[vagrant@matevm ~]$ uname -a
Linux matevm 3.10.0-957.5.1.el7.x86_64 #1 SMP Fri Feb 1 14:54:57 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```

### Copyright

Copyright (C) 2019, Greg Bailey <gbailey@lxpro.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

