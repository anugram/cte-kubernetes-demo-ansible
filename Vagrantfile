# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  config.vm.network "public_network", bridge: "wlp3s0"
  config.vm.synced_folder ".","/vagrant"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = 3
    vb.name = "ubuntu"
  end
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
  end
end
