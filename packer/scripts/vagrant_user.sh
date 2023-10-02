#!/bin/bash
#create vagrant user
useradd -s /bin/bash -m vagrant
usermod --password $(echo vagrant | openssl passwd -1 -stdin) vagrant

echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/vagrant
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

#vagrant user ssh key
mkdir -p /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
curl -k -o /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
