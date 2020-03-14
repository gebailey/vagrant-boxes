# CentOS 8 Developer Workstation with MATE Desktop

v8.1.20200311

CentOS 8 workstation with MATE 1.22 desktop, VirtualBox 6.1.4 guest additions,
development tools, Visual Studio Code, Google chrome, Firefox, Thunderbird,
Docker CE, Go 1.14, Java (OpenJDK), Python 3.6, Rust 1.39.0, MariaDB Server,
kubectl, minikube, and CentOS updates as of March 11, 2020.

### Building the centos8-mate box

Building the box file requires some manual preparation:

* The `centos8-mate.ks` kickstart file should be copied to webserver accessible
  by the virtual machine

### How to use the centos8-mate box

The box file has been uploaded to the Hashicorp Vagrant Cloud.  The following
shows an example usage of this box:

```bash
$ vagrant init gbailey/centos8-mate
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
==> default: Box 'gbailey/centos8-mate' could not be found. Attempting to find and install...
    default: Box Provider: virtualbox
    default: Box Version: >= 0
==> default: Loading metadata for box 'gbailey/centos8-mate'
    default: URL: https://vagrantcloud.com/gbailey/centos8-mate
==> default: Adding box 'gbailey/centos8-mate' (v8.1.20200311) for provider: virtualbox
    default: Downloading: https://vagrantcloud.com/gbailey/boxes/centos8-mate/versions/8.1.20200311/providers/virtualbox.box
    default: Download redirected to host: vagrantcloud-files-production.s3.amazonaws.com
    default: Calculating and comparing box checksum...
==> default: Successfully added box 'gbailey/centos8-mate' (v8.1.20200311) for 'virtualbox'!
==> default: Importing base box 'gbailey/centos8-mate'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'gbailey/centos8-mate' version '8.1.20200311' is up to date...
==> default: Setting the name of the VM: centos8-mate_default_1584201131910_53407
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
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
    default: /vagrant => /home/gbailey/centos8-mate
```

```bash
$ vagrant ssh
Activate the web console with: systemctl enable --now cockpit.socket

[vagrant@matevm ~]$ cat /etc/system-release
CentOS Linux release 8.1.1911 (Core) 
[vagrant@matevm ~]$ uname -a
Linux matevm 4.18.0-147.5.1.el8_1.x86_64 #1 SMP Wed Feb 5 02:00:39 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

### Copyright

Copyright (C) 2020, Greg Bailey <gbailey@lxpro.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

