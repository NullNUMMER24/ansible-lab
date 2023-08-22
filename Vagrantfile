Vagrant.configure("2")
  config.vm.define "ansible-master" do |am|
    am.vm.box      = "ansible-master"
    am.vm.hostname = "ansible-master"
    am.vm.network :private_network, ip: "192.168.56.101"
    am.vm.keymap   = "de-ch"

  end

  config.vm.define "ubuntu-node-01" do |ubu01|
    ubu01.vm.box      = "boxdone"
    ubu01.vm.hostname = "ubuntu-node-01"
    ubu01.vm.network :private_network, ip: "192.168.56.102"

  end
