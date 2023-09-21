# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  config.vm.provider "virtualbox" do |rs|
    rs.memory = 2048
    rs.cpus = 2
  end

  # Will not check for box updates during every startup.
  config.vm.box_check_update = false


  # Master node where ansible will be installed
  config.vm.define "controller" do |controller|
    controller.vm.box = "ubuntu/jammy64"
    controller.vm.hostname = "controller.anslab.com"
    controller.vm.network "private_network", ip: "192.168.56.3"
    controller.vm.provision "shell", path: "scripts/ansible-install.sh"
    controller.vm.provision "shell", path: "scripts/user.sh"
  end

  # Managed node 1.
  config.vm.define "m1" do |m1|
    m1.vm.box = "gusztavvargadr/windows-11"
    m1.vm.hostname = "windows_client.anslab.com"
    m1.vm.network "private_network", ip: "192.168.56.4"
#    m1.vm.provision "shell", path: "scripts/windows.ps1"
  end

end
