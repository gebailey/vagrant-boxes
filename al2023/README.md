# Amazon Linux 2023 vagrant box (virtualbox provider)

Amazon Linux 2023 vagrant box construction, using an Amazon supplied VMDK disk
image as a base. This approach avoids actually booting the Amazon supplied VMDK
disk image by mounting it and applying vagrant related changes to it, and then
calling vagrant to package the resulting image as a box file.

### Features

These scripts also shrink the consumed disk space, such that these box files
are significantly smaller than others I've seen posted online.

VirtualBox Guest Additions are included in this box.

### How to use the al2023 box

The box file has been uploaded to the Hashicorp Vagrant Cloud. The following
shows an example usage of this box:

```bash
$ vagrant init gbailey/al2023
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.
```

```bash
$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'gbailey/al2023'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'gbailey/al2023' version '20231125.0.0' is up to date...
==> default: Setting the name of the VM: al2023_default_1700959303755_47304
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
    default: Warning: Connection reset. Retrying...
    default: Warning: Remote connection disconnect. Retrying...
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
    default: /vagrant => /home/gbailey/al2023
```

```bash
$ vagrant ssh
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
```

### Copyright

Copyright (C) 2023, Greg Bailey <gbailey@lxpro.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
